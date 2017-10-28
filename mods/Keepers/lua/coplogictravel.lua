local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local kpr_original_coplogictravel_determinedestinationoccupation = CopLogicTravel._determine_destination_occupation
function CopLogicTravel._determine_destination_occupation(data, objective)
	local occupation

	local keep_position = data.unit:base().kpr_keep_position
	if keep_position then
		occupation = {type = 'defend', cover = false, pos = keep_position}
	else
		occupation = kpr_original_coplogictravel_determinedestinationoccupation(data, objective)
	end

	return occupation
end

local kpr_original_coplogictravel_getpathingprio = CopLogicTravel.get_pathing_prio
function CopLogicTravel.get_pathing_prio(data)
	local prio = kpr_original_coplogictravel_getpathingprio(data)
	if prio and data.team.id == 'converted_enemy' then
		prio = prio + 1
	end
	return prio
end
