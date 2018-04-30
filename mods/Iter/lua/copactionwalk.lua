local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local mvec3_cpy = mvector3.copy

if Network:is_server() then

	function CopActionWalk:itr_check_extensible()
		if not self.itr_path_ahead then
			return
		end

		if self._end_of_curved_path or self._end_of_path or self._host_stop_pos_ahead then
			return
		end

		if self._haste ~= 'run' then
			return
		end

		if self._action_desc.path_simplified then
			return
		end

		return true
	end

	function CopActionWalk:itr_append_next_step(path)
		if not self:itr_check_extensible() then
			return
		end

		processed_path = {}
		for _, nav_point in pairs(path) do
			if nav_point.x then
				table.insert(processed_path, nav_point)
			elseif alive(nav_point) then
				table.insert(processed_path, {
					element = nav_point:script_data().element,
					c_class = nav_point
				})
			else
				return
			end
		end

		local nr = #self._simplified_path
		self.itr_step_pos = self._nav_point_pos(self._simplified_path[nr])
		local good_pos = mvec3_cpy(self.itr_step_pos)
		local simplified_path = self._calculate_simplified_path(good_pos, processed_path, (not self._sync or self._common_data.stance.name == "ntl") and 2 or 1, self._sync, true)

		for i = 2, #simplified_path do
			nr = nr + 1
			self._simplified_path[nr] = simplified_path[i]
		end

		return true
	end

	local itr_original_copactionwalk_advancesimplifiedpath = CopActionWalk._advance_simplified_path
	function CopActionWalk:_advance_simplified_path()
		if self:itr_check_extensible() then
			self.fs_wanted_walk_dir_cached = nil
			self.fs_move_dir_norm_cached = nil
			if self._nav_point_pos(self._simplified_path[2]) == self.itr_step_pos then
				self.itr_fake_complete = true
				self._unit:brain():action_complete_clbk(self)
				self.itr_fake_complete = nil
			end
		end

		itr_original_copactionwalk_advancesimplifiedpath(self)
	end

	local itr_original_CopActionWalk_onexit = CopActionWalk.on_exit
	function CopActionWalk:on_exit()
		self.itr_path_ahead = false
		return itr_original_CopActionWalk_onexit(self)
	end

end

if Iter.settings.streamline_path then

	function CopActionWalk:itr_delete_path_ahead()
		if not self.itr_step_pos then
			return
		end

		local s_path = self._simplified_path
		if s_path[1] == self.itr_step_pos then
			self._expired = true
			return
		end

		for i = 2, #s_path do
			pos = s_path[i]
			if pos == self.itr_step_pos then
				i = i + 1
				while s_path[i] do
					table.remove(s_path, i)
				end
				break
			end
		end
	end

end
