local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

if Iter.settings.streamline_path then
	local cur_pos

	local itr_original_copbrain_searchforcoarsepath = CopBrain.search_for_coarse_path
	function CopBrain:search_for_coarse_path(...)
		cur_pos = self._logic_data.m_pos

		local result = itr_original_copbrain_searchforcoarsepath(self, ...)

		if cur_pos then
			local cs = managers.navigation._coarse_searches
			local cs_nr = #cs
			if cs_nr > 0 then
				cs[cs_nr].from_pos = cur_pos
			end
			cur_pos = nil
		end

		return result
	end

	local itr_original_copbrain_clbkcoarsepathingresults = CopBrain.clbk_coarse_pathing_results
	function CopBrain:clbk_coarse_pathing_results(search_id, path)
		cur_pos = nil
		if path then
			path[1][2] = self._logic_data.m_pos

			local objective = self._logic_data.objective
			if objective then
				if objective.follow_unit then
					path[#path][2] = objective.follow_unit:position()
				else
					local dest_pos = self._unit:base().kpr_keep_position
					if dest_pos then
						path[#path][2] = dest_pos
					end
				end
			end

			path = managers.navigation:itr_streamline(path, self._SO_access)
		end
		itr_original_copbrain_clbkcoarsepathingresults(self, search_id, path)
	end
end

local itr_original_copbrain_clbkpathingresults = CopBrain.clbk_pathing_results
function CopBrain:clbk_pathing_results(search_id, path)
	itr_original_copbrain_clbkpathingresults(self, search_id, path)
	if path then
		local my_data = self._logic_data.internal_data
		if my_data.coarse_path then
			local walk_action = my_data.advancing
			if walk_action and walk_action:itr_append_next_step(path) then
				self._logic_data.pathing_results[search_id] = nil
				my_data.processing_advance_path = nil
				if my_data.coarse_path_index >= #my_data.coarse_path - 2 then
					if self._logic_data.objective then
						local end_rot = self._logic_data.objective.rot
						if end_rot then
							walk_action._end_rot = end_rot
						end
					end
				end
			end
		end
	end
end
