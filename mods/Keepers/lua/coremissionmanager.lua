local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

core:module("CoreMissionManager")

local level_id = Global.game_settings and Global.game_settings.level_id or ""
local kpr_original_missionmanager_addscript = MissionManager._add_script

if level_id == "pbr" then

	function MissionManager:_add_script(data)
		for _, element in pairs(data.elements) do
			if element.id == 100968 then
				table.remove(element.values.elements, 4)
			end
		end
		kpr_original_missionmanager_addscript(self, data)
	end

elseif level_id == "pbr2" then

	function MissionManager:_add_script(data)
		local ref102095, elm101017
		for _, element in pairs(data.elements) do
			if element.id == 101020 then
				element.values.trigger_times = 3
				ref102095 = table.remove(element.values.on_executed, 1)
			elseif element.id == 101017 then
				elm101017 = element
			elseif element.id == 101021 then
				element.values.instigator = "intimidated_enemies"
				element.values.trigger_times = 8
				table.insert(element.values.on_executed, { delay = 0, id = 102092 })
			elseif element.id == 102474 then
				table.remove(element.values.elements, 2)
			end
		end
		table.insert(elm101017.values.on_executed, ref102095)
		kpr_original_missionmanager_addscript(self, data)
	end

elseif level_id == "hox_1" then

	function MissionManager:_add_script(data)
		for _, element in pairs(data.elements) do
			if element.id == 100689 then
				element.values.instigator = "enemies"
			end
		end
		kpr_original_missionmanager_addscript(self, data)
	end

end
