local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local kpr_original_teamailogicidle_update = TeamAILogicIdle.update
function TeamAILogicIdle.update(data)
	local my_data = data.internal_data
	local u_base = data.unit:base()
	if u_base.kpr_keep_position and data.objective and Keepers:CanChangeState(data.unit) then
		if u_base.kpr_mode == 3 and mvector3.distance(u_base.kpr_keep_position, data.unit:movement():m_pos()) > 50 then
			TeamAILogicBase._exit(data.unit, "travel")
			return
		elseif u_base.kpr_mode == 4 then
			if not my_data.kpr_wait_cover_t then
				my_data.kpr_wait_cover_t = data.t
			elseif data.t - my_data.kpr_wait_cover_t > 1 then
				local area = managers.groupai:state():get_area_from_nav_seg_id(managers.navigation:get_nav_seg_from_pos(u_base.kpr_keep_position))
				local cover = managers.navigation:find_cover_in_nav_seg_1(area.nav_segs)
				if cover then
					u_base.kpr_keep_position = mvector3.copy(cover[1])
					TeamAILogicBase._exit(data.unit, "travel")
				end
				return
			end
		end
	end

	kpr_original_teamailogicidle_update(data)
end
