local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local mvec3_add = mvector3.add
local mvec3_mul = mvector3.multiply
local mvec3_set = mvector3.set
local tmp_vec1 = Vector3()

_G.CustomWaypoints = _G.CustomWaypoints or {}
CustomWaypoints._path = ModPath
CustomWaypoints._data_path = SavePath .. 'CustomWaypoints.txt'
CustomWaypoints.network = {
	place_waypoint = 'CustomWaypointPlace',
	remove_waypoint = 'CustomWaypointRemove'
}
CustomWaypoints.prefix = 'CustomWaypoint_'
CustomWaypoints.settings = {
	show_distance = true,
	always_show_my_waypoint = true,
	always_show_others_waypoints = false
}

function CustomWaypoints.Save()
	local file = io.open(CustomWaypoints._data_path, 'w+')
	if file then
		file:write(json.encode(CustomWaypoints.settings))
		file:close()
	end
end

function CustomWaypoints.Load()
	local file = io.open(CustomWaypoints._data_path, 'r')
	if file then
		for k, v in pairs(json.decode(file:read('*all')) or {}) do
			CustomWaypoints.settings[k] = v
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
		CustomWaypoints.Save()
	end

	MenuCallbackHandler.KeybindRemoveWaypoint = function(this, item)
		if Utils:IsInGameState() then
			CustomWaypoints.RemoveMyWaypoint()
		end
	end

	MenuCallbackHandler.KeybindPlaceWaypoint = function(this, item)
		if Utils:IsInGameState() then
			CustomWaypoints.PlaceMyWaypoint()
		end
	end

	CustomWaypoints.Load()
	MenuHelper:LoadFromJsonFile(CustomWaypoints._path .. 'menu/options.txt', CustomWaypoints, CustomWaypoints.settings)
end)

-- Add
function CustomWaypoints.PlaceWaypoint(waypoint_name, pos, peer_id)
	if managers.hud then
		managers.hud:add_waypoint(
			CustomWaypoints.prefix .. waypoint_name,
			{
				icon = 'infamy_icon',
				distance = CustomWaypoints.settings.show_distance,
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

function CustomWaypoints.GetMyAimPos()
	local camera_rot = managers.viewport:get_current_camera_rotation()
	if not camera_rot then
		return
	end

	local camera_pos
	local player = managers.player:player_unit()
	if player then
		camera_pos = player:movement():m_head_pos()
	else
		camera_pos = managers.viewport:get_current_camera_position()
	end

	local aim_pos_far = tmp_vec1
	mvec3_set(aim_pos_far, camera_rot:y())
	mvec3_mul(aim_pos_far, 20000)
	mvec3_add(aim_pos_far, camera_pos)

	local ray = Utils:GetCrosshairRay(camera_pos, aim_pos_far)
	if not ray then
		return false
	end
	return ray.hit_position
end

function CustomWaypoints.PlaceMyWaypoint()
	local pos = CustomWaypoints.GetMyAimPos()
	if not pos then
		return
	end

	CustomWaypoints.PlaceWaypoint('localplayer', pos, LuaNetworking:LocalPeerID())
	LuaNetworking:SendToPeers(CustomWaypoints.network.place_waypoint, Vector3.ToString(pos))
end

function CustomWaypoints.NetworkPlace(peer_id, position)
	if peer_id then
		local pos = string.ToVector3(position)
		if pos ~= nil then
			CustomWaypoints.PlaceWaypoint(peer_id, pos, peer_id)
		end
	end
end

-- Remove
function CustomWaypoints.RemoveWaypoint(waypoint_name)
	if managers.hud then
		managers.hud:remove_waypoint(CustomWaypoints.prefix .. waypoint_name)
	end
end

function CustomWaypoints.RemoveMyWaypoint()
	LuaNetworking:SendToPeers(CustomWaypoints.network.remove_waypoint, '')
	CustomWaypoints.RemoveWaypoint('localplayer')
end

function CustomWaypoints.NetworkRemove(peer_id)
	CustomWaypoints.RemoveWaypoint(peer_id)
end
