local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

core:module('CoreMissionManager')

local level_id = Global.game_settings and Global.game_settings.level_id or ''
local kpr_original_missionmanager_addscript = MissionManager._add_script

function MissionScript:kpr_is_valid_sequence(element)
	local values = element._values
	if values.trigger_list then
		for _, trigger in ipairs(values.trigger_list) do
			local notif = trigger.notify_unit_sequence
			if notif == 'enable_interaction' or notif == 'interact_enabled' then
				return trigger.notify_unit_id, values.instance_name or element._id
			end
		end
	end
	return false
end

local table_icontains = table.icontains or table.contains
function MissionScript:kpr_find_unit_and_waypoint(element)
	local waypoint_id, unit_id
	local processed = { [element._id] = true }
	local to_process = {}

	local groups = self:element_groups()
	local group_ElementUnitSequence = groups['ElementUnitSequence'] or {}
	local group_ElementWaypoint = groups['ElementWaypoint'] or {}
	local group_MissionScriptElement = groups['MissionScriptElement'] or {}

	for _, child in ipairs(element._values.on_executed) do
		table.insert(to_process, self:element(child.id))
	end
	element = table.remove(to_process)

	while element do
		processed[element._id] = true

		if not unit_id and table_icontains(group_ElementUnitSequence, element) then
			unit_id = self:kpr_is_valid_sequence(element)

		elseif not waypoint_id and table_icontains(group_ElementWaypoint, element) then
			waypoint_id = element._id

		elseif table_icontains(group_MissionScriptElement, element) then
			for _, child in ipairs(element._values.on_executed) do
				if not processed[child.id] then
					table.insert(to_process, self:element(child.id))
				end
			end
		end

		element = table.remove(to_process)
	end

	return waypoint_id, unit_id
end

local kpr_original_missionscript_createelements = MissionScript._create_elements
function MissionScript:_create_elements(elements)
	local new_elements = kpr_original_missionscript_createelements(self, elements)

	local key_to_unit_id = _G.Keepers.key_to_unit_id
	local key_to_SO = _G.Keepers.key_to_SO
	local element_interactions = _G.Keepers.element_interactions

	if self._element_groups.ElementInteraction then
		for _, element in ipairs(self._element_groups.ElementInteraction) do
			element_interactions[element._id] = element
		end
	end

	if self._element_groups.ElementUnitSequence then
		for _, element in ipairs(self._element_groups.ElementUnitSequence) do
			local unit_id, key = self:kpr_is_valid_sequence(element)
			if key then
				key_to_unit_id[key] = unit_id
			end
		end
	end

	if self._element_groups.ElementSpecialObjectiveTrigger then
		for _, element in ipairs(self._element_groups.ElementSpecialObjectiveTrigger) do
			local instance_name = element._values.instance_name
			local key = instance_name or element._id
			if key_to_SO[key] then
			elseif element._values.event == 'complete' then
				if #element._values.elements == 1 then
					if instance_name then
						if key_to_unit_id[instance_name] then
							key_to_SO[key] = element._values.elements[1]
						end
					else
						local waypoint_id, unit_id = self:kpr_find_unit_and_waypoint(element)
						if waypoint_id and unit_id then
							key_to_SO[waypoint_id] = element._values.elements[1]
							key_to_unit_id[waypoint_id] = unit_id
						end
					end
				end
			end
		end
	end

	return new_elements
end

if level_id == 'pbr' then

	function MissionManager:_add_script(data)
		for _, element in pairs(data.elements) do
			if element.id == 100968 then
				table.remove(element.values.elements, 4)
			end
		end
		kpr_original_missionmanager_addscript(self, data)
	end

elseif level_id == 'pbr2' then

	function MissionManager:_add_script(data)
		local ref102095, elm101017
		for _, element in pairs(data.elements) do
			if element.id == 101020 then
				element.values.trigger_times = 3
				ref102095 = table.remove(element.values.on_executed, 1)
			elseif element.id == 101017 then
				elm101017 = element
			elseif element.id == 101021 then
				element.values.instigator = 'intimidated_enemies'
				element.values.trigger_times = 8
				table.insert(element.values.on_executed, { delay = 0, id = 102092 })
			elseif element.id == 102474 then
				table.remove(element.values.elements, 2)
			end
		end
		table.insert(elm101017.values.on_executed, ref102095)
		kpr_original_missionmanager_addscript(self, data)
	end

elseif level_id == 'hox_1' then

	function MissionManager:_add_script(data)
		for _, element in pairs(data.elements) do
			if element.id == 100689 then
				element.values.instigator = 'enemies'
			end
		end
		kpr_original_missionmanager_addscript(self, data)
	end

end
