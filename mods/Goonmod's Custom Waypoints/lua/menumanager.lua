local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local mvec3_add = mvector3.add
local mvec3_ang = mvector3.angle
local mvec3_dis = mvector3.distance
local mvec3_mul = mvector3.multiply
local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()

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

function CustomWaypoints:GetAssociatedObjectiveWaypoint()
	local waypoints = managers.hud and managers.hud._hud and managers.hud._hud.waypoints
	if not waypoints then
		return
	end

	local my_wp = waypoints[self.prefix .. 'localplayer']
	if not my_wp then
		return
	end

	for id, waypoint in pairs(waypoints) do
		if type(id) == 'string' and id:find(self.prefix) then
		elseif waypoint.position then
			if mvec3_dis(my_wp.position, waypoint.position) < 10 then
				return id, waypoint
			end
		end
	end

	return false
end

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
	local viewport = managers.viewport
	if not viewport:get_current_camera() then
		return false
	end

	slot_mask = slot_mask or 'bullet_impact_targets'

	from = from or viewport:get_current_camera_position()

	if not to then
		to = tmp_vec1
		mvec3_set(to, viewport:get_current_camera_rotation():y())
		mvec3_mul(to, 20000)
		mvec3_add(to, from)
	end

	local colRay = World:raycast('ray', from, to, 'slot_mask', managers.slot:get_mask(slot_mask))
	return colRay
end

function CustomWaypoints:GetMyAimPos()
	local viewport = managers.viewport
	local camera_rot = viewport:get_current_camera_rotation()
	if not camera_rot then
		return false
	end

	local from = tmp_vec2
	mvec3_set(from, camera_rot:y())
	mvec3_mul(from, 20)
	mvec3_add(from, viewport:get_current_camera_position())

	local ray = Utils:GetCrosshairRay(from)
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
	local camera_pos = managers.viewport:get_current_camera_position()
	local _, ray = self:GetMyAimPos()
	if not ray then
		return
	end

	local my_aim = ray.ray
	for id, waypoint in pairs(waypoints) do
		if type(id) == 'string' and id:find(self.prefix) then
		elseif waypoint.position then
			table.insert(result, {
				id = id,
				position = waypoint.position,
				angle = mvec3_ang(my_aim, waypoint.position - camera_pos)
			})
		end
	end

	table.sort(result, function(a, b)
		return a.angle < b.angle
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

	local rank = 1
	local my_wp = managers.hud._hud.waypoints[self.prefix .. 'localplayer']
	if my_wp then
		for i = 1, nr do
			wp = sorted_waypoints[i]
			if mvec3_dis(my_wp.position, wp.position) < 10 then
				rank = i
				break
			end
		end
		rank = rank + dir
		rank = ((rank - 1) % nr) + 1
	else
		rank = dir > 0 and 1 or nr
	end

	local chosen_wp = sorted_waypoints[rank]
	self:PlaceMyWaypoint(chosen_wp.position)
end

function CustomWaypoints:PreviousWaypoint()
	self:CycleWaypoint(-1)
end

function CustomWaypoints:NextWaypoint()
	self:CycleWaypoint(1)
end
