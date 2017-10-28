local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

function CopLogicIdle.queued_update(data)
	local my_data = data.internal_data
	local delay = data.logic._upd_enemy_detection(data)
	if data.internal_data ~= my_data then
		CopLogicBase._report_detections(data.detected_attention_objects)
		return
	end

	local is_criminal = data.team.id == "criminal1" or data.is_converted
	if is_criminal and data.objective then
		local u_base = data.unit:base()
		if u_base.kpr_keep_position and Keepers:CanChangeState(data.unit) then
			if u_base.kpr_mode == 3 and mvector3.distance(u_base.kpr_keep_position, data.unit:movement():m_pos()) > 50 then
				data.objective.in_place = nil
				CopLogicBase._exit(data.unit, "travel")
				return
			elseif u_base.kpr_mode == 4 then
				if not my_data.kpr_wait_cover_t then
					my_data.kpr_wait_cover_t = data.t
				elseif data.t - my_data.kpr_wait_cover_t > 1 then
					local area = managers.groupai:state():get_area_from_nav_seg_id(managers.navigation:get_nav_seg_from_pos(u_base.kpr_keep_position))
					local cover = managers.navigation:find_cover_in_nav_seg_1(area.nav_segs)
					if cover then
						data.objective.in_place = nil
						u_base.kpr_keep_position = mvector3.copy(cover[1])
						CopLogicBase._exit(data.unit, "travel")
					end
					return
				end
			end
		end
	end

	if my_data.has_old_action then
		CopLogicIdle._upd_stop_old_action(data, my_data, data.objective)
		CopLogicBase.queue_task(my_data, my_data.detection_task_key, CopLogicIdle.queued_update, data, data.t + delay, data.important and true)
		return
	end

	if is_criminal and (not data.objective or data.objective.type == "free") and (not data.path_fail_t or data.t - data.path_fail_t > 1) then
		managers.groupai:state():on_criminal_jobless(data.unit)
		if my_data ~= data.internal_data then
			return
		end
	end

	if CopLogicIdle._chk_exit_non_walkable_area(data) then
		return
	end
	if CopLogicIdle._chk_relocate(data) then
		return
	end

	CopLogicIdle._perform_objective_action(data, my_data, data.objective)
	CopLogicIdle._upd_stance_and_pose(data, my_data, data.objective)
	CopLogicIdle._upd_pathing(data, my_data)
	CopLogicIdle._upd_scan(data, my_data)
	if data.cool then
		CopLogicIdle.upd_suspicion_decay(data)
	end
	if data.internal_data ~= my_data then
		CopLogicBase._report_detections(data.detected_attention_objects)
		return
	end

	if data.important then
		delay = 0.1
	else
		delay = delay or 0.3
	end
	CopLogicBase.queue_task(my_data, my_data.detection_task_key, CopLogicIdle.queued_update, data, data.t + delay, data.important and true)
end
