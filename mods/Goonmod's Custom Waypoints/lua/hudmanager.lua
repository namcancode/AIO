local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local gcw_original_hudmanager_save = HUDManager.save
function HUDManager:save(data)
	gcw_original_hudmanager_save(self, data)

	local remove_list = {}
	for id, _ in pairs(data.HUDManager.waypoints) do
		if type(id) == 'string' and id:find(CustomWaypoints.prefix) == 1 then
			remove_list[id] = true
		end
	end

	for id in pairs(remove_list) do
		data.HUDManager.waypoints[id] = nil
	end
end

local function gcw_set_visibility(data)
	local offscreen = data.state == 'offscreen'
	if offscreen ~= data.arrow:visible() then
	elseif offscreen then
		data.arrow:set_visible(false)
		data.bitmap:set_visible(false)
	else
		data.bitmap:set_visible(true)
	end
end

local _settings = CustomWaypoints.settings
local _prefix = CustomWaypoints.prefix
local _prefix_local = _prefix .. 'localplayer'

local gcw_original_hudmanager_updatewaypoints = HUDManager._update_waypoints
function HUDManager:_update_waypoints(t, dt)
	gcw_original_hudmanager_updatewaypoints(self, t, dt)

	local always_show_my_waypoint = _settings.always_show_my_waypoint
	local always_show_others_waypoints = _settings.always_show_others_waypoints
	if not always_show_my_waypoint or not always_show_others_waypoints then
		for id, data in pairs(self._hud.waypoints) do
			if id == _prefix_local then
				if not always_show_my_waypoint then
					gcw_set_visibility(data)
				end
			elseif type(id) == 'string' and id:find(_prefix) == 1 then
				if not always_show_others_waypoints then
					gcw_set_visibility(data)
				end
			end
		end
	end
end
