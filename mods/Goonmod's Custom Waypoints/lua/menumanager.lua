local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local mvec3_add = mvector3.add
local mvec3_ang = mvector3.angle
local mvec3_dis = mvector3.distance
local mvec3_mul = mvector3.multiply
local mvec3_set = mvector3.set
local tmp_vec1 = Vector3()

_G.CustomWaypoints = _G.CustomWaypoints or {}
CustomWaypoints._path = ModPath
CustomWaypoints._data_path = SavePath .. 'CustomWaypoints.txt'
CustomWaypoints.prefix = 'CustomWaypoint_'
CustomWaypoints.network = {
	place_waypoint = 'CustomWaypointPlace',
	remove_waypoint = 'CustomWaypointRemove'
}
CustomWaypoints.settings = {
	show_distance = true,
	always_show_my_waypoint = true,
	always_show_others_waypoints = false
}

function CustomWaypoints:Save()
	local file = io.open(self._data_path, 'w+')
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

function CustomWaypoints:Load()
	local file = io.open(self._data_path, 'r')
	if file then
		for k, v in pairs(json.decode(file:read('*all')) or {}) do
			self.settings[k] = v
		end
		file:close()
	end
end

Hooks:Add('LocalizationManagerPostInit', 'LocalizationManagerPostInit_CustomWaypoints', function(loc)
	for _, filename in pairs(file.GetFiles(CustomWaypoints._path .. 'loc/')) do
		local str = filename:match('^(.*).txt$')
		if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
			loc:load_localization_file(CustomWaypoints._path .. 'loc/' .. filename)
			break
		end
	end
	loc:load_localization_file(CustomWaypoints._path .. 'loc/english.txt', false)
end)

Hooks:Add('MenuManagerInitialize', 'MenuManagerInitialize_CustomWaypoints', function(menu_manager)
	MenuCallbackHandler.ToggleWaypointShowDistance = function(this, item)
		CustomWaypoints.settings.show_distance = item:value() == 'on'
	end

	MenuCallbackHandler.ToggleWaypointAlwaysShowMyWaypoint = function(this, item)
		CustomWaypoints.settings.always_show_my_waypoint = item:value() == 'on'
	end

	MenuCallbackHandler.ToggleWaypointAlwaysShowOthersWaypoints = function(this, item)
		CustomWaypoints.settings.always_show_others_waypoints = item:value() == 'on'
	end

	MenuCallbackHandler.CustomWaypointsSave = function(this, item)
		CustomWaypoints:Save()
	end

	MenuCallbackHandler.KeybindRemoveWaypoint = function(this, item)
		if Utils:IsInGameState() then
			CustomWaypoints:RemoveMyWaypoint()
		end
	end

	MenuCallbackHandler.KeybindPlaceWaypoint = function(this, item)
		if Utils:IsInGameState() then
			CustomWaypoints:PlaceMyWaypoint()
		end
	end

	MenuCallbackHandler.KeybindPreviousWaypoint = function(this, item)
		if Utils:IsInGameState() then
			CustomWaypoints:PreviousWaypoint()
		end
	end

	MenuCallbackHandler.KeybindNextWaypoint = function(this, item)
		if Utils:IsInGameState() then
			CustomWaypoints:NextWaypoint()
		end
	end

	CustomWaypoints:Load()
	MenuHelper:LoadFromJsonFile(CustomWaypoints._path .. 'menu/options.txt', CustomWaypoints, CustomWaypoints.settings)
end)

-- Add
function CustomWaypoints:PlaceWaypoint(waypoint_name, pos, peer_id)
	if managers.hud then
		managers.hud:add_waypoint(
			self.prefix .. waypoint_name,
			{
				icon = 'infamy_icon',
				distance = self.settings.show_distance,
				position = pos,
				no_sync = false,
				present_timer = 0,
				state = 'present',
				radius = 50,
				color = tweak_data.preplanning_peer_colors[peer_id or 1],
				blend_mode = 'add'
			} 
		)
	end
end

function Utils:GetCrosshairRay(from, to, slot_mask)
	slot_mask = slot_mask or 'bullet_impact_targets'

	if not from then
		local player = managers.player:player_unit()
		if player then
			from = player:movement():m_head_pos()
		else
			from = managers.viewport:get_current_camera_position()
		end
	end

	if not to then
		to = tmp_vec1
		mvec3_set(to, player:camera():forward())
		mvec3_mul(to, 20000)
		mvec3_add(to, from)
	end

	local colRay = World:raycast('ray', from, to, 'slot_mask', managers.slot:get_mask(slot_mask))
	return colRay
end

function CustomWaypoints.GetMyPos()
	local player = managers.player:player_unit()
	if player then
		return player:movement():m_head_pos()
	else
		return managers.viewport:get_current_camera_position()
	end
end

function CustomWaypoints:GetMyAimPos()
	local camera_rot = managers.viewport:get_current_camera_rotation()
	if not camera_rot then
		return
	end

	local camera_pos = self.GetMyPos()
	local aim_pos_far = tmp_vec1
	mvec3_set(aim_pos_far, camera_rot:y())
	mvec3_mul(aim_pos_far, 20000)
	mvec3_add(aim_pos_far, camera_pos)

	local ray = Utils:GetCrosshairRay(camera_pos, aim_pos_far)
	if not ray then
		return false
	end

	return ray.hit_position, ray
end

function CustomWaypoints:PlaceMyWaypoint(pos)
	pos = pos or self:GetMyAimPos()
	if not pos then
		return
	end

	self:PlaceWaypoint('localplayer', pos, LuaNetworking:LocalPeerID())
	LuaNetworking:SendToPeers(self.network.place_waypoint, Vector3.ToString(pos))
end

function CustomWaypoints:NetworkPlace(peer_id, position)
	if peer_id then
		local pos = string.ToVector3(position)
		if pos ~= nil then
			self:PlaceWaypoint(peer_id, pos, peer_id)
		end
	end
end

-- Remove
function CustomWaypoints:RemoveWaypoint(waypoint_name)
	if managers.hud then
		managers.hud:remove_waypoint(self.prefix .. waypoint_name)
	end
end

function CustomWaypoints:RemoveMyWaypoint()
	LuaNetworking:SendToPeers(self.network.remove_waypoint, '')
	self:RemoveWaypoint('localplayer')
end

function CustomWaypoints:NetworkRemove(peer_id)
	self:RemoveWaypoint(peer_id)
end

-- Cycle
function CustomWaypoints:SortWaypoints()
	local waypoints = managers.hud and managers.hud._hud and managers.hud._hud.waypoints
	if not waypoints then
		return
	end

	local result = {}
	local my_pos = self.GetMyPos()
	for id, waypoint in pairs(waypoints) do
		if type(id) == 'string' and id:find(self.prefix) then
		else
			table.insert(result, {
				id = id,
				state = waypoint.state,
				position = waypoint.position,
				v = waypoint.position - my_pos
			})
		end
	end

	local _, ray = self:GetMyAimPos()
	local my_aim = ray.ray
	table.sort(result, function(a, b)
		if a.state ~= b.state then
			return b.state == 'offscreen'
		end
		return mvec3_ang(my_aim, a.v) < mvec3_ang(my_aim, b.v)
	end)

	return result
end

function CustomWaypoints:CycleWaypoint(dir)
	local sorted_waypoints = self:SortWaypoints()
	if not sorted_waypoints then
		return
	end

	local nr = #sorted_waypoints
	if nr == 0 then
		return
	end

	local my_wp = managers.hud._hud.waypoints['CustomWaypoint_localplayer']
	local rank = 1
	if my_wp then
		for i = 1, nr do
			wp = sorted_waypoints[i]
			if mvec3_dis(my_wp.position, wp.position) < 300 then
				rank = i
				break
			end
		end
	end

	rank = rank + dir
	rank = ((rank - 1) % nr) + 1
	local chosen_wp = sorted_waypoints[rank]

	local tracker = managers.navigation:create_nav_tracker(chosen_wp.position, false)
	local pos = tracker:field_position()
	managers.navigation:destroy_nav_tracker(tracker)

	self:PlaceMyWaypoint(pos)
end

function CustomWaypoints:PreviousWaypoint()
	self:CycleWaypoint(-1)
end

function CustomWaypoints:NextWaypoint()
	self:CycleWaypoint(1)
end
