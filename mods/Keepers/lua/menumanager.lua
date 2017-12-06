local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local mvec3_add = mvector3.add
local mvec3_cpy = mvector3.copy
local mvec3_dir = mvector3.direction
local mvec3_dis = mvector3.distance
local mvec3_mul = mvector3.multiply
local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_sub = mvector3.subtract
local mvec3_z = mvector3.z
local tmp_vec = Vector3()
local tmp_vec2 = Vector3()

function json.safe_decode(data)
	local result = nil
	pcall(function()
		result = json.decode(data)
	end)
	return result
end

_G.Keepers = _G.Keepers or {}
Keepers.path = ModPath
Keepers.data_path = SavePath .. 'keepers.txt'
Keepers.enabled = true
Keepers.clients = {}
Keepers.joker_names = {}
Keepers.radial_health = {}
Keepers.wp_to_unit_id = {}
Keepers.unitid_to_SO = {}
Keepers.settings = {
	primary_mode = 3,
	secondary_mode = 4,
	keybind_mode = 3,
	filter_shout_at_teamai = false,
	filter_shout_at_teamai_key = 'left shift',
	filter_only_stop_calls = false,
	show_joker_health = true,
	show_my_joker_name = true,
	send_my_joker_name = true,
	show_other_jokers_names = true,
	my_joker_name = 'Cave',
	jokers_run_like_teamais = true,
	icon_revive = 'wp_revive'
}

function Keepers:CanCallJokers(current_state_name)
	return current_state_name == 'standard' or current_state_name == 'carry'
end

function Keepers:CanSearchForCover(unit)
	local kpr_mode = alive(unit) and unit:base().kpr_mode
	return kpr_mode and kpr_mode > 2
end

function Keepers:IsFiltering()
	local key = self.settings.filter_shout_at_teamai_key
	return key:find('mouse ') and Input:mouse():down(Idstring(key:sub(7))) or Input:keyboard():down(Idstring(key))
end

function Keepers:ApplyFilterMode()
	local v = self.settings.filter_mode
	if v == 1 then
		self.settings.filter_shout_at_teamai = false
		self.settings.filter_only_stop_calls = false
	elseif v == 2 then
		self.settings.filter_shout_at_teamai = false
		self.settings.filter_only_stop_calls = true
	elseif v == 3 then
		self.settings.filter_shout_at_teamai = true
		self.settings.filter_only_stop_calls = false
	end
end

function Keepers:LoadSettings()
	local file = io.open(self.data_path, 'r')
	if file then
		for k, v in pairs(json.safe_decode(file:read('*all')) or {}) do
			self.settings[k] = v
		end
		file:close()
	end
	self:ApplyFilterMode()
	self:SaveSettings()

	for i = 1, 4 do
		self.joker_names[i] = ''
	end

	local peer_id = managers.network and managers.network:session() and managers.network:session():local_peer():id() or 1
	self.joker_names[peer_id] = self.settings.show_my_joker_name and self.settings.my_joker_name or ''
end

function Keepers:SaveSettings()
	local file = io.open(self.data_path, 'w+')
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

function Keepers:GetJokerNameByPeer(peer_id)
	local name = self.joker_names[peer_id]
	if managers.network:session():local_peer():id() == peer_id then
		return name
	elseif not self.settings.show_other_jokers_names then
		return ''
	elseif name == 'Cave' or name == '' then
		local peer = managers.network:session():peer(peer_id)
		if peer then
			name = "X"
		end
	end
	return name
end

function Keepers:SetJokerLabel(unit)
	local panel_id = unit:unit_data().name_label_id
	if not panel_id then
		local label_data = { unit = unit, name = self:GetJokerNameByPeer(unit:base().kpr_minion_owner_peer_id) }
		panel_id = managers.hud:_add_name_label(label_data)
		unit:unit_data().name_label_id = panel_id
	end

	local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
	local name_label = hud.panel:child('name_label' .. tostring(panel_id))

	if not name_label then
		return
	end

	local previous_icon = name_label:child('bag')
	if previous_icon then
		name_label:remove(previous_icon)
		previous_icon = nil
	end

	local radial_health = name_label:bitmap({
		name = 'bag',
		texture = 'guis/textures/pd2/hud_health',
		texture_rect = {
			128,
			0,
			-128,
			128
		},
		render_template = 'VertexColorTexturedRadial',
		blend_mode = 'add',
		alpha = 1,
		w = 16,
		h = 16,
		layer = 0,
	})
	local txt = name_label:child('text')
	radial_health:set_center_y(txt:center_y())
	local l, r, w, h = txt:text_rect()
	radial_health:set_left(txt:left() + w + 2)
	radial_health:set_visible(self.settings.show_joker_health)

	self.radial_health[unit:id()] = radial_health
end

function Keepers:IsModdedClient(peer_id)
	return not not self.clients[peer_id]
end

function Keepers:GetGoonModWaypointPosition(peer_id)
	local peer_name = peer_id == managers.network:session():local_peer():id() and 'localplayer' or peer_id
	local wp = managers.hud and managers.hud._hud.waypoints['CustomWaypoint_' .. peer_name]
	if not wp then
		return nil
	end

	local pos = wp.position
	local tracker = managers.navigation:create_nav_tracker(pos, false)
	local tracker_pos = tracker:field_position()
	managers.navigation:destroy_nav_tracker(tracker)

	mvec3_set(tmp_vec, pos)
	mvec3_set(tmp_vec2, tracker_pos)
	mvec3_set_z(tmp_vec, 0)
	mvec3_set_z(tmp_vec2, 0)
	if mvec3_dis(tmp_vec, tmp_vec2) < 100 then
		pos = tracker_pos
	end

	mvec3_set(tmp_vec, pos)
	mvec3_set(tmp_vec2, tmp_vec)
	mvec3_set_z(tmp_vec, tmp_vec.z + 10)
	mvec3_set_z(tmp_vec2, tmp_vec.z - 2000)
	local ground_slotmask = managers.slot:get_mask('AI_graph_obstacle_check')
	local ray = World:raycast('ray', tmp_vec, tmp_vec2, 'slot_mask', ground_slotmask, 'ray_type', 'walk')
	return ray and ray.hit_position
end

function Keepers:GetLuaNetworkingText(peer_id, unit, mode)
	local data = {}
	data.unit_id = unit:id()
	data.peer_id = peer_id or unit:base().kpr_minion_owner_peer_id or unit:base().kpr_following_peer_id
	data.charname = managers.criminals:character_name_by_unit(unit) or 'jokered_cop'
	data.mode = mode
	return json.encode(data)
end

function Keepers:GetMinionsByPeer(peer_id)
	local result = {}

	for key, unit in pairs(managers.groupai:state():all_converted_enemies()) do
		if alive(unit) and unit:base().kpr_minion_owner_peer_id == peer_id and not unit:character_damage():dead() then
			table.insert(result, unit)
		end
	end

	return result
end

function Keepers:GetTeamAIsOwnedByPeer(peer_id)
	local result = {}

	for _, record in pairs(managers.groupai:state():all_AI_criminals()) do
		local u = record.unit
		if alive(u) and u:base().kpr_following_peer_id == peer_id then
			table.insert(result, u)
		end
	end

	return result
end

function Keepers:GetStoppedTeamAIs()
	local result = {}

	for _, record in pairs(managers.groupai:state():all_AI_criminals()) do
		local u = record.unit
		if u:base().kpr_is_keeper then
			table.insert(result, u)
		end
	end

	return result
end

function Keepers:GetStayObjective(unit)
	local mode_to_icon = {
		nil,
		'pd2_goto',
		'pd2_defend',
		'pd2_escape'
	}
	local kpr_mode = unit:base().kpr_mode
	local keep_position = unit:base().kpr_keep_position
	if kpr_mode == 3 or kpr_mode == 4 then
		return {
			type = 'defend_area',
			kpr_icon = mode_to_icon[kpr_mode],
			nav_seg = managers.navigation:get_nav_seg_from_pos(keep_position, true),
			attitude = 'avoid',
			stance = 'hos',
			scan = true
		}
	else
		return {
			type = 'stop',
			kpr_icon = mode_to_icon[kpr_mode],
			nav_seg = managers.navigation:get_nav_seg_from_pos(keep_position, true),
			pos = mvec3_cpy(keep_position)
		}
	end
end

local brush = Draw:brush(Color(100, 106, 187, 255) / 255, 2)
function Keepers:ShowCovers(unit)
	local covers = {}
	local kpr_mode = unit:base().kpr_mode

	local keep_position = unit:base().kpr_keep_position
	if not keep_position then
		return
	end

	if kpr_mode == 3 then
		local i = 1
		for _, cover_pos in ipairs(self._covers) do
			if mvec3_dis(keep_position, cover_pos) < 400 then
				local delta_z = keep_position.z - cover_pos.z
				if delta_z > -100 and delta_z < 100 then
					covers[i] = mvec3_cpy(cover_pos)
					i = i + 1
				end
			end
		end

	elseif kpr_mode == 4 then
		local nav_seg = managers.navigation:get_nav_seg_from_pos(keep_position)
		local i = 1
		for _, cover_pos in ipairs(self._covers) do
			if managers.navigation:get_nav_seg_from_pos(cover_pos) == nav_seg then
				covers[i] = mvec3_cpy(cover_pos)
				i = i + 1
			end
		end
	end

	for _, cover in pairs(covers) do
		mvec3_set_z(cover, cover.z - 3)
		tmp_vec = mvec3_cpy(cover)
		mvec3_set_z(tmp_vec, tmp_vec.z + 20)
		brush:cone(tmp_vec, cover, 30)
	end
end

function Keepers:SendState(unit, unit_text_ref, is_keeper)
	self:SetState(unit_text_ref, is_keeper)
	if Network:is_server() then
		LuaNetworking:SendToPeers('Keeper' .. (is_keeper and 'ON' or 'OFF'), unit_text_ref)
		if managers.groupai:state()._ai_criminals[unit:key()] then
			for peer_id, peer in pairs(managers.network:session():peers()) do
				if not self:IsModdedClient(peer_id) then
					peer:send_queued_sync('sync_team_ai_stopped', unit, is_keeper)
				end
			end
		end
	else
		LuaNetworking:SendToPeer(1, 'Keeper' .. (is_keeper and 'ON' or 'OFF'), unit_text_ref)
	end
end

function Keepers:RecvState(sender, unit_text_ref, is_keeper)
	if self:SetState(unit_text_ref, is_keeper) and Network:is_server() then
		LuaNetworking:SendToPeers('Keeper' .. (is_keeper and 'ON' or 'OFF'), unit_text_ref)
	end
end

function Keepers:CanChangeState(unit)
	if not alive(unit) then
		return false
	end

	local ucd = unit:character_damage()
	if not ucd or ucd.need_revive and ucd:need_revive() or ucd.arrested and ucd:arrested() or ucd.dead and ucd:dead() then
		return false
	end

	local uad = unit:anim_data()
	if uad and uad.acting then
		return false
	end

	local brain = unit:brain()
	if brain then
		local objective = brain.objective and brain:objective()
		if objective and objective.forced then
			return false
		end
	end

	return true
end

function Keepers:GetUnit(data)
	local is_converted = data.charname == 'jokered_cop'
	if is_converted then
		for _, minion_unit in pairs(self:GetMinionsByPeer(data.peer_id)) do
			if minion_unit:id() == data.unit_id then
				return minion_unit
			end
		end
	else
		return managers.criminals and managers.criminals:character_unit_by_name(data.charname)
	end
	return false
end

function Keepers:IsPositionOK(pos, threshold)
	if not pos then
		return false
	end

	local result = true
	local closest_navseg = managers.navigation:get_nav_seg_from_pos(pos, false)
	local navseg = managers.navigation:get_nav_seg_from_pos(pos, true)

	if navseg ~= closest_navseg then
		local tracker = managers.navigation:create_nav_tracker(pos, false)
		local tracker_pos = tracker:field_position()
		managers.navigation:destroy_nav_tracker(tracker)
		if mvec3_dis(pos, tracker_pos) > (threshold or 150) then
			result = false
		end
	end

	return result, closest_navseg, navseg
end

function Keepers:SetState(unit_text_ref, is_keeper)
	local data = json.safe_decode(unit_text_ref)
	local peer_id = data.peer_id

	local unit = self:GetUnit(data)
	if not alive(unit) or not self:CanChangeState(unit) then
		return
	end

	local u_base = unit:base()
	if data.charname == 'jokered_cop' then
		if unit:character_damage():dead() and unit:unit_data().name_label_id then
			self:DestroyLabel(unit)
		end
	else
		u_base.kpr_following_peer_id = peer_id
	end

	if Network:is_server() then
		local previous_kpr_is_keeper = u_base.kpr_is_keeper
		local previous_kpr_mode = u_base.kpr_mode
		if is_keeper then
			local so = self:GetWaypointSO(unit, peer_id)
			if not so then
				local wp_pos = self:GetGoonModWaypointPosition(peer_id)
				local dest_pos = self:IsPositionOK(wp_pos) and self:GetGoonModWaypointPosition(peer_id) or unit:movement():nav_tracker():field_position()
				u_base.kpr_is_keeper = true
				u_base.kpr_mode = tonumber(data.mode)
				u_base.kpr_keep_position = mvec3_cpy(dest_pos)
				unit:brain():set_objective(self:GetStayObjective(unit))
			else
				u_base.kpr_is_keeper = true
				u_base.kpr_mode = tonumber(data.mode)
				u_base.kpr_keep_position = mvec3_cpy(so.pos)
				unit:brain():set_objective(so)
			end
		else
			u_base.kpr_is_keeper = false
			u_base.kpr_mode = 1
			u_base.kpr_keep_position = nil
			local peer = managers.network:session():peer(peer_id)
			local peer_unit = peer and peer:unit()
			local obj = peer_unit and {
				kpr_icon = nil,
				type = 'follow',
				follow_unit = peer_unit,
				scan = true,
				nav_seg = peer_unit:movement():nav_tracker():nav_segment(),
				called = true,
				pos = peer_unit:movement():nav_tracker():field_position(),
			}
			unit:brain():set_objective(obj)
		end

		local change = previous_kpr_is_keeper ~= u_base.kpr_is_keeper or previous_kpr_mode ~= u_base.kpr_mode
		return change

	else
		u_base.kpr_is_keeper = is_keeper
		u_base.kpr_mode = tonumber(data.mode)
	end
end

function Keepers:ResetLabel(unit, is_converted, icon, ext_data)
	if is_converted then
		if unit:character_damage():dead() then
			if unit:unit_data().name_label_id then
				self:DestroyLabel(unit)
			end
			return
		end

		if not unit:unit_data().name_label_id then
			self:SetJokerLabel(unit)
		end
	end

	local name_label = managers.hud:_get_name_label(unit:unit_data().name_label_id)
	if not name_label then
		log('[KPR] name_label not found for ' .. tostring(unit:base()._tweak_table))
		return
	end

	local previous_icon = name_label.panel:child('infamy')
	if previous_icon then
		name_label.panel:remove(previous_icon)
		previous_icon = nil
	end

	if icon then
		local icon_color
		if icon == Keepers.settings.icon_revive then
			icon_color = ext_data == managers.network:session():local_peer():id() and Color.red or Color.white
		end
		local color = icon_color or tweak_data.chat_colors[managers.criminals:character_color_id_by_unit(unit)]
		local texture, rect = tweak_data.hud_icons:get_icon_data(icon)
		local bmp = name_label.panel:bitmap({
			blend_mode = 'add',
			name = 'infamy',
			texture = texture,
			texture_rect = rect,
			layer = 0,
			color = color:with_alpha(0.9),
			w = 16,
			h = 16,
			visible = true,
		})
		local txt = name_label.panel:child('text')
		bmp:set_center_y(txt:center_y())
		bmp:set_right(txt:left())
	end

	if icon ~= nil and Network:is_server() then
		LuaNetworking:SendToPeers('KeepersICON', self:GetLuaNetworkingText(ext_data, unit, icon))
	end
	unit:base().kpr_icon = icon
end

function Keepers:SetIcon(sender, unit_text_ref)
	local data = json.safe_decode(unit_text_ref)
	if not data then
		return
	end

	local unit = self:GetUnit(data)
	if alive(unit) then
		self:ResetLabel(unit, data.charname == 'jokered_cop', data.mode, data.peer_id)
	end
end

function Keepers:DestroyLabel(unit)
	if alive(unit) then
		managers.hud:_remove_name_label(unit:unit_data().name_label_id)
		unit:base().kpr_is_keeper = nil
		unit:base().kpr_keep_position = nil
		unit:unit_data().name_label_id = nil
		if unit:base().kpr_minion_owner_peer_id then
			self.radial_health[unit:id()] = nil
			unit:base().kpr_minion_owner_peer_id = nil
		end
	end
end

Hooks:Add('NetworkReceivedData', 'NetworkReceivedData_KPR', function(sender, messageType, data)
	if messageType == 'KeeperON' then
		Keepers:RecvState(sender, data, true)

	elseif messageType == 'KeeperOFF' then
		Keepers:RecvState(sender, data, false)

	elseif messageType == 'KeepersICON' then
		Keepers:SetIcon(sender, data)

	elseif messageType == 'Keepers?' then
		if data then
			Keepers.joker_names[sender] = data:sub(1, 25)
		end
		Keepers.clients[sender] = true
		LuaNetworking:SendToPeer(sender, 'Keepers!', Keepers.settings.send_my_joker_name and Keepers.settings.my_joker_name or '')

	elseif messageType == 'Keepers!' then
		if sender == 1 then
			Keepers.enabled = true
		end
		if data and Keepers.settings.show_other_jokers_names and data ~= '' then
			Keepers.joker_names[sender] = data:sub(1, 25)
		end
	end

end)

Hooks:Add('BaseNetworkSessionOnLoadComplete', 'BaseNetworkSessionOnLoadComplete_KPR', function(local_peer, id)
	Keepers:LoadSettings()
	if id == 1 then
		Keepers.enabled = true
		Keepers.clients[1] = true
	else
		Keepers.enabled = false
		LuaNetworking:SendToPeers('Keepers?', Keepers.settings.send_my_joker_name and Keepers.settings.my_joker_name or '')
	end
end)

Hooks:Add('LocalizationManagerPostInit', 'LocalizationManagerPostInit_KPR', function(loc)
	for _, filename in pairs(file.GetFiles(Keepers.path .. 'loc/') or {}) do
		local str = filename:match('^(.*).txt$')
		if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
			loc:load_localization_file(Keepers.path .. 'loc/' .. filename)
			break
		end
	end

	loc:load_localization_file(Keepers.path .. 'loc/english.txt', false)
end)

Hooks:Add('MenuManagerInitialize', 'MenuManagerInitialize_KPR', function(menu_manager)
	MenuCallbackHandler.KeepersModePrimary = function(this, item)
		Keepers.settings.primary_mode = tonumber(item:value())
	end

	MenuCallbackHandler.KeepersModeSecondary = function(this, item)
		Keepers.settings.secondary_mode = tonumber(item:value())
	end

	MenuCallbackHandler.KeepersModeKeybind = function(this, item)
		Keepers.settings.keybind_mode = tonumber(item:value())
	end

	MenuCallbackHandler.KeepersFilterMode = function(this, item)
		Keepers.settings.filter_mode = tonumber(item:value())
		Keepers:ApplyFilterMode()
	end

	MenuCallbackHandler.KeepersShowJokerHealth = function(this, item)
		Keepers.settings.show_joker_health = item:value() == 'on'
	end

	MenuCallbackHandler.KeepersShowMyJokerName = function(this, item)
		Keepers.settings.show_my_joker_name = item:value() == 'on'
	end

	MenuCallbackHandler.KeepersSetJokerName = function(this, item)
		Keepers.settings.my_joker_name = item:value()
	end

	MenuCallbackHandler.KeepersSendMyJokerName = function(this, item)
		Keepers.settings.send_my_joker_name = item:value() == 'on'
	end

	MenuCallbackHandler.KeepersShowOtherJokersNames = function(this, item)
		Keepers.settings.show_other_jokers_names = item:value() == 'on'
	end

	MenuCallbackHandler.KeepersSetJokerSpeed = function(this, item)
		Keepers.settings.jokers_run_like_teamais = item:value() == 'on'
	end

	MenuCallbackHandler.KeepersSave = function(this, item)
		Keepers:SaveSettings()
	end

	function MenuCallbackHandler.KeybindFollow(this, item)
		if Keepers.enabled then
			Keepers:ChangeState(false)
		end
	end

	function MenuCallbackHandler.KeybindStay(this, item)
		if Keepers.enabled then
			Keepers:ChangeState(true)
		end
	end

	Keepers:LoadSettings()
	MenuHelper:LoadFromJsonFile(Keepers.path .. 'menu/options.txt', Keepers, Keepers.settings)

end)

function Keepers:ChangeState(new_state)
	if not (managers.network and managers.network:session() and Utils:IsInHeist()) then
		return
	end

	local peer_id = managers.network:session():local_peer():id()
	local refs = {}
	local kpr_mode = new_state and self.settings.keybind_mode or 1

	for _, unit in pairs(self:GetMinionsByPeer(peer_id)) do
		refs[unit] = self:GetLuaNetworkingText(peer_id, unit, kpr_mode)
	end

	for _, unit in pairs(new_state and self:GetTeamAIsOwnedByPeer(peer_id) or self:GetStoppedTeamAIs()) do
		refs[unit] = self:GetLuaNetworkingText(peer_id, unit, kpr_mode)
	end

	for unit, unit_text_ref in pairs(refs) do
		if not unit:base().kpr_is_keeper == new_state then
			self:SendState(unit, unit_text_ref, new_state)
		end
	end
end

function Keepers:ValidInteraction(unit)
	local forbidden_interactions = {
		access_camera = true,
		c4_bag = true,
		c4_bag_dynamic = true,
		cas_take_hook = true,
		open_from_inside = true,
		pickup_keycard = true,
		player_zipline = true,
	}

	if alive(unit) and unit:in_slot(1, 14) then
		local interaction = unit:interaction()
		if interaction and not interaction:disabled() and interaction:active() then
			if not forbidden_interactions[interaction.tweak_data] then
				local td = interaction._tweak_data
				if not td
					or td.special_equipment
					or td.equipment_consume
					or td.special_equipment_block
					or td.requires_upgrade
					or td.required_deployable
					or td.deployable_consume
					or td.contour == 'deployable'
				then
				else
					return true
				end
			end
		end
	end

	return false
end

function Keepers:GetHorizontalGap(pos)
	local tracker = managers.navigation:create_nav_tracker(pos, false)
	local tracker_pos = tracker:field_position()
	managers.navigation:destroy_nav_tracker(tracker)
	mvec3_set_z(tracker_pos, mvec3_z(pos))
	return mvec3_dis(pos, tracker_pos), tracker_pos
end

function Keepers:GetYaw(interactive_unit, interact_pos)
	mvec3_set(tmp_vec, interact_pos)
	mvec3_set_z(tmp_vec, 0)
	mvec3_set(tmp_vec2, interactive_unit:interaction():interact_position())
	mvec3_set_z(tmp_vec2, 0)
	mvec3_dir(tmp_vec, tmp_vec, tmp_vec2)
	return Rotation(tmp_vec, math.UP):yaw()
end

function Keepers:FindInteractPosition(interactive_unit, delta_yaw)
	local slot_mask = managers.slot:get_mask('AI_graph_obstacle_check')
	local i_pos = interactive_unit:interaction():interact_position()
	local i_pos_z = mvec3_z(i_pos)
	mvec3_set(tmp_vec, i_pos)

	local fwd = Rotation(((interactive_unit:rotation():yaw() + delta_yaw + 180) % 360) - 180, 0, 0):y()
	mvec3_mul(fwd, 80)
	mvec3_add(tmp_vec, fwd)
	local z = mvec3_z(tmp_vec)
	mvec3_set_z(tmp_vec, z + 20)
	mvec3_set(tmp_vec2, tmp_vec)
	mvec3_set_z(tmp_vec2, z - 10000)
	local col_ray = World:raycast('ray', tmp_vec, tmp_vec2, 'slot_mask', slot_mask)
	if col_ray then
		mvec3_set(tmp_vec, col_ray.position)
	end

	local tracker = managers.navigation:create_nav_tracker(tmp_vec, false)
	local tracker_pos = tracker:field_position()
	managers.navigation:destroy_nav_tracker(tracker)

	local tracker_z = mvec3_z(tracker_pos) - 25
	if i_pos_z - tracker_z < -10 then
		mvec3_set_z(tmp_vec, z - 100)
		local col_ray = World:raycast('ray', tmp_vec, tmp_vec2, 'slot_mask', slot_mask)
		if col_ray then
			mvec3_set(tmp_vec, col_ray.position)
		end
	end

	return mvec3_cpy(tmp_vec), i_pos_z - mvec3_z(tmp_vec)
end

function Keepers:GetInteractionPosition(interactive_unit, wp_position)
	local data = {
		{ delta_yaw = 0   },
		{ delta_yaw = 90  },
		{ delta_yaw = 180 },
		{ delta_yaw = 270 }
	}
	data[1].opposite = data[3]
	data[2].opposite = data[4]
	data[3].opposite = data[1]
	data[4].opposite = data[2]

	local slot_mask = managers.slot:get_mask('AI_graph_obstacle_check')
	local yaw = interactive_unit:rotation():yaw()
	local pos = Vector3()
	local full_length = 100

	for _, dataset in ipairs(data) do
		mvec3_set(pos, wp_position)
		local dir = Rotation(((yaw + dataset.delta_yaw + 180) % 360) - 180, 0, 0):y()
		mvec3_mul(dir, full_length)
		mvec3_add(pos, dir)
		local col_ray = World:raycast('ray', pos, wp_position, 'slot_mask', slot_mask)
		dataset.dis = col_ray and col_ray.distance or full_length
		dataset.i_pos, dataset.height = self:FindInteractPosition(interactive_unit, dataset.delta_yaw)
		dataset.z_ok = math.within(dataset.height, -20, 300)
		dataset.gap = self:GetHorizontalGap(dataset.i_pos)
	end

	table.sort(data, function (a, b)
		if a.z_ok ~= b.z_ok then
			return a.z_ok
		end
		if a.dis == b.dis then
			if a.gap == b.gap then
				return a.delta_yaw < b.delta_yaw -- sometimes, everything is ok but 0 is best
			end
			return a.gap < b.gap
		end
		return a.dis > b.dis
	end)

	if data[1].dis == full_length and data[2].dis == full_length and data[3].dis == full_length and data[4].dis < full_length then
		return data[4].opposite.i_pos
	end

	return data[1].i_pos
end

function Keepers:GetAnimation(interaction, height, action_duration)
	local interaction_name = interaction.tweak_data
	local computer_interactions = {
		big_computer_hackable = 35,
		big_computer_server = 35,
		hold_search_computer = 35,
		hack_suburbia_outline = false,
		security_station_keyboard = false,
	}

	if interaction_name == 'hold_signal_driver' then
		return 'e_so_low_kicks', nil, nil, -130

	elseif height > 130 then
		if action_duration <= 3 then
			return 'e_so_tube_interact'
		else
			return 'interact_enter', 'interact_exit'
		end

	elseif height > 60 then
		if interaction_name == 'drill_jammed' then
			return 'e_so_low_lockpick_enter', 'e_so_low_lockpick_exit', true, 10
		elseif interaction._tweak_data.is_lockpicking then
			return 'e_so_low_lockpick_enter', 'e_so_low_lockpick_exit', true
		elseif computer_interactions[interaction_name] ~= nil then
			return 'e_so_keyboard_type_loop', nil, nil, computer_interactions[interaction_name]
		elseif action_duration <= 3 then
			return 'e_so_interact_mid'
		else
			return 'interact_enter', 'interact_exit'
		end

	elseif height < 5 then
		if action_duration <= 1 then
			return 'e_so_plant_c4_floor'
		end
	end

	return 'untie'
end

function Keepers:GetInteractionIcon(interaction, icon)
	if interaction._tweak_data.is_lockpicking then
		return 'wp_key'
	end

	local td_icon = interaction._tweak_data.icon
	if td_icon and td_icon ~= 'develop' then
		return td_icon
	end

	return icon or 'pd2_generic_interact'
end

local ids_gen_drill_small_upright = Idstring('units/pd2_dlc_pal/equipment/gen_interactable_drill_small_upright/gen_interactable_drill_small_upright')
local ids_gen_saw_no_jam = Idstring('units/pd2_dlc_glace/equipment/gen_interactable_saw_no_jam/gen_interactable_saw_no_jam')
function Keepers:GetWaypointSO(bot_unit, peer_id)
	if not CustomWaypoints then
		return
	end

	local bot_brain = bot_unit:brain()
	if not bot_brain or not bot_brain._logic_data or bot_brain._logic_data.is_converted then
		return
	end

	local unit, unit_id, icon

	local wp = managers.hud._hud.waypoints[CustomWaypoints.prefix .. (peer_id == 1 and 'localplayer' or tostring(peer_id))]
	if not wp or not wp.position then
		return
	end

	local obj_wp_id = CustomWaypoints:GetAssociatedObjectiveWaypoint(wp.position)
	if obj_wp_id then
		local wp_element = managers.mission:get_element_by_id(obj_wp_id)
		if not wp_element then
			return
		end

		unit_id = self.wp_to_unit_id[wp_element._values.instance_name or obj_wp_id]
		icon = wp_element._values.icon
	end

	if unit_id then
		unit = managers.worlddefinition:get_unit(unit_id)
	end

	if not self:ValidInteraction(unit) then
		local best_unit
		local min_dis = 0
		for _, int_unit in ipairs(managers.interaction._interactive_units) do
			if self:ValidInteraction(int_unit) then
				local ipos = int_unit:interaction():interact_position()
				local dis = mvec3_dis(wp.position, ipos) - int_unit:interaction():interact_distance()
				if dis < min_dis then
					best_unit = int_unit
					min_dis = dis
				end
			end
		end

		if not best_unit then
			return
		end
		unit_id = best_unit and best_unit:unit_data() and best_unit:unit_data().unit_id
		unit = best_unit
	end

	if not self:ValidInteraction(unit) then
		return
	end
	local interaction = unit:interaction()
	local action_duration = interaction._tweak_data.timer or 0.5
	local clbk_data = {
		interactive_unit = unit,
		interaction_name = interaction.tweak_data,
		bot_unit = bot_unit,
		duration = action_duration,
	}

	local so_values
	local so_id = self.unitid_to_SO[unit_id]
	if so_id then
		local so = managers.mission:get_element_by_id(so_id)
		if not so then
			return
		end
		so_values = so._values

		local inappropriate_anim = {
			e_so_balloon = true,
		}
		if inappropriate_anim[so_values.so_action] then
			local height = so_values.position and (mvec3_z(interaction:interact_position()) - mvec3_z(so_values.position)) or 75
			so_values.so_action, clbk_data.exit_animation, clbk_data.hidden_weapon, repos = self:GetAnimation(interaction, height, action_duration)
			icon = self:GetInteractionIcon(interaction, icon)
		end
	end

	if not so_values or not so_values.position then
		so_values = {}
		icon = self:GetInteractionIcon(interaction, icon)

		local pos, repos
		local ub = unit:base()
		if ub and ub._sabotage_align_obj_name and (math.within(unit:rotation():pitch(), -10, 10) and unit:name() ~= ids_gen_drill_small_upright or unit:name() == ids_gen_saw_no_jam) then
			local align_obj = unit:get_object(Idstring(ub._sabotage_align_obj_name))
			pos = mvec3_cpy(align_obj:position())
			mvec3_set(tmp_vec, pos)
			mvec3_set_z(tmp_vec, mvec3_z(pos) - 300)
			local col_ray = World:raycast('ray', pos, tmp_vec, 'slot_mask', managers.slot:get_mask('AI_graph_obstacle_check'))
			if col_ray then
				pos = col_ray.position
			else
				mvec3_set_z(pos, mvec3_z(pos) - 25)
			end
		else
			pos = self:GetInteractionPosition(unit, wp.position)
		end

		local height = mvec3_z(interaction:interact_position()) - mvec3_z(pos)
		so_values.so_action, clbk_data.exit_animation, clbk_data.hidden_weapon, repos = self:GetAnimation(interaction, height, action_duration)
		so_values.rotation = self:GetYaw(unit, pos)

		if repos then
			mvec3_set(tmp_vec, interaction:interact_position())
			mvec3_set_z(tmp_vec, mvec3_z(pos))
			mvec3_dir(tmp_vec, pos, tmp_vec)
			mvec3_mul(tmp_vec, repos)
			mvec3_add(pos, tmp_vec)
		end
		so_values.position = pos
	end

	local pos_ok, closest_navseg = self:IsPositionOK(so_values.position)
	if not pos_ok then
		return
	end

	clbk_data.icon = icon
	local carry = bot_unit:movement().carry_id and bot_unit:movement():carry_id()
	local can_run = (not carry or tweak_data.carry.types[tweak_data.carry[carry].type].can_run) and mvec3_dis(bot_unit:position(), unit:position()) > 200

	local new_objective = {
		kpr_important_location = not not (obj_wp_id or CustomWaypoints:GetAssociatedObjectiveWaypoint(so_values.position, 200)),
		kpr_icon = icon,
		destroy_clbk_key = false,
		type = 'act',
		haste = can_run and 'run' or 'walk',
		pose = 'stand',
		interrupt_health = 0.4,
		interrupt_dis = 0,
		nav_seg = closest_navseg,
		pos = so_values.position,
		rot = so_values.rotation and Rotation(so_values.rotation, 0, 0),
		action_start_clbk = callback(self, self, 'OnActionStartedSO', clbk_data),
		complete_clbk = callback(self, self, 'OnCompletedSO', clbk_data),
		fail_clbk = callback(self, self, 'OnFailedSO', clbk_data),
		action = {
			kpr_so_expiration = true,
			variant = so_values.so_action,
			align_sync = true,
			body_part = 1,
			type = 'act',
			blocks = {
				act = -1,
				action = -1,
				aim = -1,
				heavy_hurt = -1,
				hurt = -1,
				light_hurt = -1,
				shoot = -1,
				turn = -1,
				walk = -1
			}
		},
		action_duration = action_duration,
		followup_objective = bot_brain:objective()
	}

	return new_objective
end

function Keepers:OnActionStartedSO(data)
	local bot_name = alive(data.bot_unit) and managers.criminals:character_name_by_unit(data.bot_unit)
	if not bot_name then
		return
	end

	local interaction = alive(data.interactive_unit) and data.interactive_unit:interaction()
	if not interaction or not interaction:active() or interaction:disabled() then
		local objective = data.bot_unit:brain():objective()
		data.bot_unit:brain():set_objective(objective and objective.followup_objective)
		return
	end

	local str = 'kpr;' .. bot_name .. ';' .. data.interaction_name .. (data.hidden_weapon and ';hw' or '')
	if managers.hud then
		managers.hud:kpr_teammate_progress(str, true, data.duration, false)
	end

	local session = managers.network:session()
	for peer_id, peer in pairs(session:peers()) do
		if peer_id ~= 1 and self.clients[peer_id] then
			session:send_to_peer_synched(peer, 'sync_teammate_progress', 1, true, str, data.duration, false)
		end
	end
end

function Keepers:FinalizeSO(data, success)
	local bot_name = alive(data.bot_unit) and managers.criminals:character_name_by_unit(data.bot_unit)
	if not bot_name then
		return
	end

	data.bot_unit:movement():action_request({
		body_part = 1,
		type = 'act',
		variant = data.exit_animation or 'idle',
	})

	local str = 'kpr;' .. bot_name .. ';' .. data.interaction_name .. (data.hidden_weapon and ';hw' or '')
	if managers.hud then
		managers.hud:kpr_teammate_progress(str, false, data.duration, success)
	end

	local session = managers.network:session()
	for peer_id, peer in pairs(session:peers()) do
		if peer_id ~= 1 and self.clients[peer_id] then
			session:send_to_peer_synched(peer, 'sync_teammate_progress', 1, false, str, data.duration, success)
		end
	end
end

function Keepers:OnFailedSO(data)
	self:FinalizeSO(data, false)
end

function Keepers:OnCompletedSO(data)
	local interaction = alive(data.interactive_unit) and data.interactive_unit:interaction()
	if interaction then
		local bot_unit = data.bot_unit
		if alive(bot_unit) and interaction:active() and not interaction:disabled() then
			interaction:interact(bot_unit)
		end

		local objective = bot_unit:brain():objective()
		if objective and not objective.kpr_important_location then
			-- bot should stay around if he was sent to interact on something that may be interactable again
			if interaction._remove_on_interact then
				Keepers:SendState(bot_unit, self:GetLuaNetworkingText(bot_unit:base().kpr_following_peer_id, bot_unit, 1), false)
			else
				DelayedCalls:Add('DelayedModKPR_OnCompletedSO_' .. bot_unit:id(), 1.1, function()
					local interaction = alive(data.interactive_unit) and data.interactive_unit:interaction()
					if interaction and not interaction:disabled() and interaction:active() then
						-- qued
					elseif alive(bot_unit) and bot_unit:base().kpr_is_keeper then
						Keepers:SendState(bot_unit, self:GetLuaNetworkingText(bot_unit:base().kpr_following_peer_id, bot_unit, 1), false)
					end
				end)
			end
		end
	end

	self:FinalizeSO(data, true)
end
