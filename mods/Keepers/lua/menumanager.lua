local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local mvec_cpy = mvector3.copy
local mvec_dis = mvector3.distance
local mvec_set = mvector3.set
local mvec_set_z = mvector3.set_z
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
Keepers.key_to_unit_id = {}
Keepers.key_to_SO = {}
Keepers.element_interactions = {}
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

	mvec_set(tmp_vec, pos)
	mvec_set(tmp_vec2, tracker_pos)
	mvec_set_z(tmp_vec, 0)
	mvec_set_z(tmp_vec2, 0)
	if mvec_dis(tmp_vec, tmp_vec2) < 100 then
		pos = tracker_pos
	end

	mvec_set(tmp_vec, pos)
	mvec_set(tmp_vec2, tmp_vec)
	mvec_set_z(tmp_vec, tmp_vec.z + 10)
	mvec_set_z(tmp_vec2, tmp_vec.z - 2000)
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
			nav_seg = managers.navigation:get_nav_seg_from_pos(keep_position),
			attitude = 'avoid',
			stance = 'hos',
			scan = true
		}
	else
		return {
			type = 'stop',
			kpr_icon = mode_to_icon[kpr_mode],
			nav_seg = managers.navigation:get_nav_seg_from_pos(keep_position),
			pos = mvec_cpy(keep_position)
		}
	end
end

local brush = Draw:brush(Color(100, 106, 187, 255) / 255, 2)
function Keepers:ShowCovers(unit)
	local covers = {}
	local kpr_mode = unit:base().kpr_mode

	if kpr_mode == 3 then
		local keep_position = unit:base().kpr_keep_position
		local i = 1
		for _, cover in pairs(self._covers) do
			local cover_pos = cover[1]
			if mvec_dis(keep_position, cover_pos) < 400 then
				local delta_z = keep_position.z - cover_pos.z
				if delta_z > -100 and delta_z < 100 then
					covers[i] = mvec_cpy(cover_pos)
					i = i + 1
				end
			end
		end

	elseif kpr_mode == 4 then
		local nav_seg = managers.navigation:get_nav_seg_from_pos(unit:base().kpr_keep_position)
		local i = 1
		for _, cover in pairs(self._covers) do
			if managers.navigation:get_nav_seg_from_pos(cover[1]) == nav_seg then
				covers[i] = mvec_cpy(cover[1])
				i = i + 1
			end
		end
	end

	for _, cover in pairs(covers) do
		mvec_set_z(cover, cover.z - 3)
		tmp_vec = mvec_cpy(cover)
		mvec_set_z(tmp_vec, tmp_vec.z + 20)
		brush:cone(tmp_vec, cover, 30)
	end
end

function Keepers:SendState(unit, unit_text_ref, is_keeper)
	local is_server = Network:is_server()
	if is_server then
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

	self:SetState(unit_text_ref, is_keeper, is_server)
end

function Keepers:RecvState(sender, unit_text_ref, is_keeper)
	if Network:is_server() then
		LuaNetworking:SendToPeers('Keeper' .. (is_keeper and 'ON' or 'OFF'), unit_text_ref)
	end

	self:SetState(unit_text_ref, is_keeper, true)
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

function Keepers:SetState(unit_text_ref, is_keeper, update_teamai_leader)
	local data = json.safe_decode(unit_text_ref)
	local peer_id = data.peer_id
	local unit = self:GetUnit(data)
	if not alive(unit) or not self:CanChangeState(unit) then
		return
	end

	local u_base = unit:base()
	if update_teamai_leader and not is_converted then
		u_base.kpr_following_peer_id = peer_id
	end

	u_base.kpr_is_keeper = is_keeper
	u_base.kpr_mode = tonumber(data.mode)
	u_base.kpr_keep_position = is_keeper and mvec_cpy(self:GetGoonModWaypointPosition(peer_id) or unit:movement():nav_tracker():field_position()) or nil

	if Network:is_server() then
		if is_keeper then
			unit:brain():set_objective(self:GetWaypointSO(unit) or self:GetStayObjective(unit))
		else
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
			unit:brain():set_objective(self:GetWaypointSO(unit, obj) or obj)
		end
	end

	if is_converted and unit:character_damage():dead() then
		if unit:unit_data().name_label_id then
			self:DestroyLabel(unit)
		end
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

	local panel_id = unit:unit_data().name_label_id
	local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
	local name_label = hud.panel:child('name_label' .. tostring(panel_id))
	if not name_label then
		log('[KPR] name_label not found for ' .. tostring(unit:base()._tweak_table))
		return
	end

	local previous_icon = name_label:child('infamy')
	if previous_icon then
		name_label:remove(previous_icon)
		previous_icon = nil
	end

	if icon then
		local icon_color
		if icon == Keepers.settings.icon_revive then
			icon_color = ext_data == managers.network:session():local_peer():id() and Color.red or Color.white
		end
		local color = icon_color or tweak_data.chat_colors[managers.criminals:character_color_id_by_unit(unit)]
		local texture, rect = tweak_data.hud_icons:get_icon_data(icon)
		local bmp = name_label:bitmap({
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
		local txt = name_label:child('text')
		bmp:set_center_y(txt:center_y())
		bmp:set_right(txt:left())
	end

	if icon ~= nil and Network:is_server() then
		LuaNetworking:SendToPeers('KeepersICON', self:GetLuaNetworkingText(ext_data, unit, icon))
	end
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

function Keepers:GetWaypointSO(bot_unit, followup_objective)
	local bot_brain = bot_unit:brain()
	if bot_brain and bot_brain._logic_data and bot_brain._logic_data.is_converted then
		return
	end

	local obj_wp_id = CustomWaypoints and CustomWaypoints:GetAssociatedObjectiveWaypoint()
	if not obj_wp_id then
		return
	end

	local wp_element = managers.mission:get_element_by_id(obj_wp_id)
	if not wp_element then
		return
	end

	local key = wp_element._values.instance_name or obj_wp_id
	local unit

	for id, element in pairs(self.element_interactions) do
		if element._values.enabled and element._values.instance_name == key then
			unit = element._unit
			break
		end
	end

	if not unit then
		local unit_id = self.key_to_unit_id[key]
		if not unit_id then
			return
		end

		unit = managers.worlddefinition:get_unit(unit_id)
	end

	if not alive(unit) then
		return
	end

	local so_id = self.key_to_SO[key]
	if not so_id then
		return
	end

	local so = managers.mission:get_element_by_id(so_id)
	if not so then
		return
	end

	local interaction = unit:interaction()
	if not interaction or interaction:disabled() or not interaction:active() then
		return
	end
	if interaction._tweak_data.requires_upgrade or interaction._tweak_data.special_equipment then
		return
	end

	local so_values = so._values
	local carry = bot_unit:movement().carry_id and bot_unit:movement():carry_id()
	local can_run = not carry or tweak_data.carry.types[tweak_data.carry[carry].type].can_run
	local new_objective = {
		kpr_icon = wp_element._values.icon,
		destroy_clbk_key = false,
		type = 'act',
		haste = can_run and 'run' or 'walk',
		pose = 'stand',
		interrupt_health = 0.4,
		interrupt_dis = 0,
		nav_seg = managers.navigation:get_nav_seg_from_pos(so_values.position, true),
		pos = so_values.position,
		rot = so_values.rotation and Rotation(so_values.rotation, 0, 0),
		complete_clbk = callback(self, self, 'OnCompletedSO', {unit, bot_unit}),
		action = {
			variant = so_values.so_action,
			align_sync = true,
			body_part = 1,
			type = 'act',
			blocks = {
				action = -1,
				aim = -1,
				walk = -1
			}
		},
		action_duration = math.max(interaction._tweak_data.timer or 1, so_values.action_duration_min or 0),
		followup_objective = followup_objective or bot_brain:objective()
	}

	bot_unit:base().kpr_keep_position = mvec_cpy(so_values.position)

	return new_objective
end

function Keepers:OnCompletedSO(units)
	if alive(units[1]) and alive(units[2]) then
		local interaction = units[1]:interaction()
		if interaction and interaction:active() and not interaction:disabled() then
			interaction:interact(units[2])
		end
	end
end
