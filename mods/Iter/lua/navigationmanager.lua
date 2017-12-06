local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local mvec3_add = mvector3.add
local mvec3_ang = mvector3.angle
local mvec3_cpy = mvector3.copy
local mvec3_dis = mvector3.distance
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_div = mvector3.divide
local mvec3_lerp = mvector3.lerp
local mvec3_set = mvector3.set
local mvec3_z = mvector3.z
local math_abs = math.abs
local table_insert = table.insert
local table_remove = table.remove

if Iter.settings.streamline_path then

	function NavigationManager:itr_get_all_doors_of_segment(segment_id)
		local room_mask = {}
		if self._nav_segments[segment_id] and next(self._nav_segments[segment_id].vis_groups) then
			for _, i_vis_group in ipairs(self._nav_segments[segment_id].vis_groups) do
				local vis_group_rooms = self._visibility_groups[i_vis_group].rooms
				for i_room, _ in pairs(vis_group_rooms) do
					room_mask[i_room] = true
				end
			end
		end

		local result = {}
		for door_id, door in pairs(self._room_doors) do
			if room_mask[door.rooms[1]] or room_mask[door.rooms[2]] then
				result[door_id] = door
			end
		end
		return result
	end

	function NavigationManager:itr_get_room_to_doors(segment_id, all_seg_doors)
		local result = {}
		for door_id, door in pairs(all_seg_doors) do
			for _, room_id in pairs(door.rooms) do
				if segment_id == self:get_nav_seg_from_i_room(room_id) then
					local ri = result[room_id]
					if not ri then
						ri = {}
						result[room_id] = ri
					end
					ri[#ri+1] = door_id
				end
			end
		end
		return result
	end

	function NavigationManager:itr_is_contiguous(level, door_flood_levels, room_to_doors)
		local all_doors = self._room_doors
		local level_doors = {}
		local room_pool = {}
		for door_id, door_level in pairs(door_flood_levels) do
			if door_level == level then
				level_doors[door_id] = true
				for _, room_id in pairs(all_doors[door_id].rooms) do
					if room_to_doors[room_id] then
						room_pool[room_id] = true
					end
				end
			end
		end

		local start = next(room_pool)
		if not start then
			return false
		end
		local to_process = {[start] = true}
		local stop
		repeat
			stop = true
			local old_to_process = to_process
			to_process = {}
			for base_room_id, _ in pairs(old_to_process) do
				room_pool[base_room_id] = nil
				for _, door_id in pairs(room_to_doors[base_room_id]) do
					for _, room_id in pairs(all_doors[door_id].rooms) do
						if room_pool[room_id] then
							to_process[room_id] = true
							stop = false
						end
					end
					level_doors[door_id] = nil
				end
			end
		until stop

		return not next(level_doors)
	end

	function NavigationManager:itr_flood(from_doors, room_to_doors)
		local door_flood_levels = {}
		local to_process = {}
		local level = 1
		for _, door_id in pairs(from_doors) do
			if type(door_id) == 'number' then
				door_flood_levels[door_id] = level
				to_process[door_id] = true
			end
		end

		local all_doors = self._room_doors
		local door_level_counts = {}
		door_level_counts[1] = #from_doors
		local stop
		repeat
			stop = true
			level = level + 1
			local old_to_process = to_process
			to_process = {}
			for base_door_id, _ in pairs(old_to_process) do
				for _, room_id in pairs(all_doors[base_door_id].rooms) do
					for _, door_id in pairs(room_to_doors[room_id] or {}) do
						if not door_flood_levels[door_id] then
							if not to_process[door_id] then
								to_process[door_id] = true
								door_flood_levels[door_id] = level
								local cnt = door_level_counts[level]
								door_level_counts[level] = cnt and cnt + 1 or 1
								stop = false
							end
						end
					end
				end
			end
		until stop

		local room_flood_levels = {}
		for door_id, level in pairs(door_flood_levels) do
			for _, room_id in pairs(all_doors[door_id].rooms) do
				if room_to_doors[room_id] then -- to filter rooms of this segment
					local room_level = room_flood_levels[room_id]
					room_flood_levels[room_id] = room_level and math.min(room_level, level) or level
				end
			end
		end

		local room_level_counts = {}
		for room_id, level in pairs(room_flood_levels) do
			room_level_counts[level] = room_level_counts[level] and room_level_counts[level] + 1 or 1
		end

		return room_flood_levels, room_level_counts, door_flood_levels, door_level_counts
	end

	function NavigationManager:itr_find_choke_point(room_flood_levels, room_level_counts, room_to_doors)
		local level_max = #room_level_counts
		local threshold = math.max(4, level_max / 2)
		for level, count in pairs(room_level_counts) do
			if level > threshold or level == level_max then
				break
			end
			if count == 1 then -- choke point exists
				for room_id, room_level in pairs(room_flood_levels) do
					if room_level == level then
						-- find the door leading to the room of previous level
						local all_doors = self._room_doors
						for _, door_id in pairs(room_to_doors[room_id]) do
							local rooms = all_doors[door_id].rooms
							local other_room_id = rooms[1] == room_id and rooms[2] or rooms[1]
							if room_flood_levels[other_room_id] and room_flood_levels[other_room_id] < level then
								-- found
								return door_id
							end
						end
					end
				end
				break
			end			
		end
	end

	local tmp_vec = Vector3()
	local function itr_add_door_pos_to(sum_pos, all_doors, i_door)
		if type(i_door) == 'number' then
			local door = all_doors[i_door]
			mvec3_lerp(tmp_vec, door.pos, door.pos1, 0.5)
			mvec3_add(sum_pos, tmp_vec)
		elseif alive(i_door) then
			local start_pos = i_door:script_data().element:value('position')
			mvec3_add(sum_pos, start_pos)
		end
	end

	local function itr_get_rooms_having_access_to_next_level(start_level, all_doors, room_to_doors, room_flood_levels)
		local result = {}
		for room_id, room_level in pairs(room_flood_levels) do
			if room_level == start_level then
				for _, door_id in pairs(room_to_doors[room_id]) do
					local rooms = all_doors[door_id].rooms
					local other_room_id = rooms[1] == room_id and rooms[2] or rooms[1]
					local other_room_level = room_flood_levels[other_room_id]
					if other_room_level and other_room_level > start_level then
						result[room_id] = room_id
						break
					end
				end
			end
		end
		return result
	end

	function NavigationManager:itr_find_proxies(segment_id)
		local choke_points, choke_point_proxies = {}, {}
		local in_proxies = {}
		local out_proxies = {}
		local all_doors = self._room_doors
		local all_nav_segments = self._nav_segments
		local segment = all_nav_segments[segment_id]
		local all_seg_doors = self:itr_get_all_doors_of_segment(segment_id)
		local room_to_doors = self:itr_get_room_to_doors(segment_id, all_seg_doors)

		for neighbour_seg_id, door_list in pairs(segment.neighbours) do
			local best_level
			local min_count = 1000
			local level1_contiguous
			local room_flood_levels, room_level_counts, door_flood_levels, door_level_counts = self:itr_flood(door_list, room_to_doors)

			local important_rooms = itr_get_rooms_having_access_to_next_level(1, all_doors, room_to_doors, room_flood_levels)
			local important_doors = {}
			for room_id in pairs(important_rooms) do
				for _, door_id in pairs(room_to_doors[room_id]) do
					if door_flood_levels[door_id] == 1 then
						important_doors[door_id] = door_id
					end
				end
			end

			for level, count in pairs(door_level_counts) do
				if not self:itr_is_contiguous(level, door_flood_levels, room_to_doors) then
					break
				end
				if count <= min_count then
					best_level = level
					min_count = count
				end
				if level == 1 then
					level1_contiguous = true
				elseif level > 4 then
					break
				end
			end

			if best_level and table.size(all_seg_doors) > 20 then
				local cnt = 0
				local pos = Vector3(0, 0, 0)
				for door_id, level in pairs(door_flood_levels) do
					if level == best_level then
						itr_add_door_pos_to(pos, all_doors, door_id)
						cnt = cnt + 1
					end
				end
				if cnt > 0 and cnt < 5 then
					mvec3_div(pos, cnt)
					out_proxies[neighbour_seg_id] = pos
				end
			end

			local neighbour_in_proxies = all_nav_segments[neighbour_seg_id].in_proxies
			local already_done = neighbour_in_proxies and neighbour_in_proxies[segment_id]
			if already_done ~= nil then
				in_proxies[neighbour_seg_id] = already_done
			elseif level1_contiguous then
				local cnt = 0
				local frontier_center = Vector3(0, 0, 0)
				for door_id in pairs(important_doors) do
					itr_add_door_pos_to(frontier_center, all_doors, door_id)
					cnt = cnt + 1
				end
				if cnt > 0 then
					mvec3_div(frontier_center, cnt)
					local metawidth = 0
					for door_id in pairs(important_doors) do
						local dis
						if type(door_id) == 'number' then
							local door = all_doors[door_id]
							mvec3_lerp(tmp_vec, door.pos, door.pos1, 0.5)
							dis = mvec3_dis_sq(frontier_center, tmp_vec)
						elseif alive(door_id) then
							dis = mvec3_dis_sq(frontier_center, door_id:script_data().element:value('position'))
						end
						if dis and dis > metawidth then
							metawidth = dis
						end
					end
					in_proxies[neighbour_seg_id] = metawidth < (150 * 150) and frontier_center or nil
				end
			end

			local choke_point = self:itr_find_choke_point(room_flood_levels, room_level_counts, room_to_doors)
			if choke_point then
				local choke_door = all_doors[choke_point]
				local choke_pos = (choke_door.pos + choke_door.pos1) / 2
				choke_points[neighbour_seg_id] = choke_pos

				-- pick the closest important door
				local best_pos = Vector3()
				local min_dis = 1000000000
				for door_id in pairs(important_doors) do
					local door = all_doors[door_id]
					mvec3_lerp(tmp_vec, door.pos, door.pos1, 0.5)
					local dis = mvec3_dis_sq(tmp_vec, choke_pos)
					if dis < min_dis then
						min_dis = dis
						mvec3_set(best_pos, tmp_vec)
					end
				end
				choke_point_proxies[neighbour_seg_id] = best_pos
			end
		end

		return choke_points, choke_point_proxies, in_proxies, out_proxies
	end

	function NavigationManager:itr_prepare_streamline_data()
		for segment_id, segment in pairs(self._nav_segments) do
			segment.choke_points, segment.choke_point_proxies, segment.in_proxies, segment.out_proxies = self:itr_find_proxies(segment_id)
		end

		for segment_id, segment in pairs(self._nav_segments) do
			for neighbour_seg_id, door_list in pairs(segment.neighbours) do
				local choke_point_proxy = segment.choke_point_proxies[neighbour_seg_id]
				if choke_point_proxy then
					local neighbour_choke_point_proxies = self._nav_segments[neighbour_seg_id].choke_point_proxies
					if not neighbour_choke_point_proxies[segment_id] then
						neighbour_choke_point_proxies[segment_id] = choke_point_proxy
					end
				end
			end
		end
	end

	local itr_original_navigationmanager_sendnavfieldtoengine = NavigationManager.send_nav_field_to_engine
	function NavigationManager:send_nav_field_to_engine()
		self:itr_prepare_streamline_data()
		return itr_original_navigationmanager_sendnavfieldtoengine(self)
	end

	local itr_navlinks_usage = {}
	local function itr_log_navlink_usage(navlink, t)
		local key = navlink:key()
		local navlink_usage = itr_navlinks_usage[key]
		if not navlink_usage then
			navlink_usage = {}
			itr_navlinks_usage[key] = navlink_usage
		end
		navlink_usage[#navlink_usage + 1] = t
	end

	local function itr_get_navlink_usage(navlink, t)
		local navlink_usage = itr_navlinks_usage[navlink:key()]
		if not navlink_usage then
			return 0
		end
		local nu = navlink_usage[1]
		while nu and t - nu > 1 do
			table.remove(navlink_usage, 1)
			nu = navlink_usage[1]
		end
		return #navlink_usage
	end

	local function itr_get_closest_door_to_pos(all_doors, door_list, pos_from, pos_to, access_pos)
		local best_pos, best_pos_with_delay, t, min_congestion_risk
		local best_dis = 1000000000
		local no_navlink, through_navlink, through_navlink_with_delay

		for _, i_door in ipairs(door_list) do
			if type(i_door) == 'number' then
				local door_pos = all_doors[i_door].center
				local dis = (pos_from and mvec3_dis(pos_from, door_pos) or 0) + mvec3_dis(door_pos, pos_to)
				if dis <= best_dis then
					best_pos = door_pos
					best_dis = dis
					no_navlink = true
				end

			elseif alive(i_door) and not i_door:is_obstructed() and i_door:check_access(access_pos) then
				local element = i_door:script_data().element
				local start_pos = element:value('position')
				local end_pos = element:nav_link_end_pos()
				local dis = (pos_from and mvec3_dis(pos_from, start_pos) or 0) + mvec3_dis(start_pos, end_pos) + mvec3_dis(end_pos, pos_to)
				t = t or TimerManager:game():time()
				local congestion_risk = (t > i_door:delay_time() and 0 or 1) + itr_get_navlink_usage(i_door, t)
				if congestion_risk == 0 then
					if dis * 1.4 < best_dis then
						no_navlink = false
						best_pos = end_pos
						best_dis = dis * 1.4
						through_navlink = i_door
					end
				elseif not min_congestion_risk or congestion_risk < min_congestion_risk then
					min_congestion_risk = congestion_risk
					best_pos_with_delay = end_pos
					through_navlink_with_delay = i_door
				end
			end
		end

		if no_navlink then
			through_navlink = nil
		else
			through_navlink = through_navlink or through_navlink_with_delay
			if through_navlink then
				itr_log_navlink_usage(through_navlink, t)
			end
		end

		return best_pos or best_pos_with_delay, through_navlink
	end

	function NavigationManager:itr_get_door_between(segment1_id, segment2_id, near_pos)
		local door_list = self._nav_segments[segment1_id].neighbours[segment2_id]
		if door_list then
			return itr_get_closest_door_to_pos(self._room_doors, door_list, nil, near_pos, nil)
		end
	end

	local axis = Vector3()
	local function itr_get_door_in_alignment(all_doors, door_list, from, to)
		if not from or not to then
			return
		end
		local best_pos, best_angle
		axis = to - from
		for _, i_door in ipairs(door_list) do
			if type(i_door) == 'number' then
				local door_pos = all_doors[i_door].center
				local angle = mvec3_ang(axis, door_pos - from)
				if not best_angle or angle < best_angle then
					best_angle = angle
					best_pos = door_pos
				end
			end
		end
		return best_pos
	end

	function NavigationManager:itr_streamline(path, access_pos)
		local all_segs = self._nav_segments
		local all_doors = self._room_doors
		local path_nr = #path
		local step1 = path[1]
		local step2

		if not step1[2] then
			step1[2] = all_segs[step1[1]].pos
		end

		for i = 2, path_nr do
			step2 = path[i]

			local segment1 = all_segs[step1[1]]
			local segment2_id = step2[1]
			local door_list = segment1.neighbours[segment2_id]
			if door_list then
				local navlink
				local segment2 = all_segs[segment2_id]
				local step3 = path[i + 1]
				local segment3 = step3 and all_segs[step3[1]]
				local door_list_nr = #door_list

				-- TOTHINK: if segments share a lot of doors, it's better to use the choke_point as an out_proxy
				local best_pos = segment1.choke_point_proxies[step2[1]]

				if not best_pos then
					local out_proxy = step3 and (segment3.choke_points[step2[1]] or segment2.out_proxies[step3[1]])
					local in_proxy = segment2.in_proxies[step1[1]] or step3 and all_segs[step3[1]].pos
					best_pos = itr_get_door_in_alignment(all_doors, door_list, step1[2], out_proxy or in_proxy)
				end

				if not best_pos then
					local proxy = step3 and segment2.in_proxies[step3[1]] or path[path_nr][2]
					best_pos, navlink = itr_get_closest_door_to_pos(all_doors, door_list, step1[2], proxy, access_pos)
					if not best_pos then
						return false
					end
				end 

				step2[2] = best_pos
				step2[3] = navlink
			end

			step1 = step2
		end

		path[1][2] = nil
		if path_nr > 1 and path[path_nr - 1][1] ~= path[path_nr][1] then
			path[path_nr + 1] = { path[path_nr][1] }
		end
		return path
	end

	local function itr_get_accessibility(door_list, access_pos, access_neg)
		local min_congestion_risk, t
		for _, i_door in ipairs(door_list) do
			if type(i_door) == 'number' then
				return 0
			elseif alive(i_door) and not i_door:is_obstructed() and i_door:check_access(access_pos, access_neg) then
				t = t or TimerManager:game():time()
				local congestion_risk = ((t > i_door:delay_time() and 0 or 1) + itr_get_navlink_usage(i_door, t)) * i_door:script_data().element:nav_link_delay()
				if congestion_risk == 0 then
					return 0.1
				elseif not min_congestion_risk or congestion_risk < min_congestion_risk then
					min_congestion_risk = congestion_risk
				end
			end
		end
		return min_congestion_risk
	end

	NavigationManager.itr_navlink_coef = 600
	function NavigationManager:_execute_coarce_search(search_data)
		local navlink_coef = self.itr_navlink_coef
		local access_pos = search_data.access_pos
		local access_neg = search_data.access_neg
		local all_nav_segments = self._nav_segments
		local next_seg_id = search_data.start_i_seg
		local end_i_seg = search_data.end_i_seg
		local verify_clbk = search_data.verify_clbk
		local potential_paths = {}
		local seg_to_search = {}
		local discovered_seg = {
			[next_seg_id] = {
				path = '' .. next_seg_id,
				delay = 0,
				steps_nr = 0,
				coarse_dis = 0,
				pos = search_data.from_pos or all_nav_segments[next_seg_id].pos
			}
		}

		local stopping = false
		repeat
			if stopping then
				stopping = stopping - 1
				if stopping <= 0 then
					break
				end
			end

			local navseg = all_nav_segments[next_seg_id]
			local neighbours = navseg.neighbours
			if neighbours then
				local from = discovered_seg[next_seg_id]
				if neighbours[end_i_seg] then
					local access_cost = itr_get_accessibility(neighbours[end_i_seg], access_pos, access_neg)
					if access_cost then
						local tmp = clone(from)
						tmp.delay = tmp.delay + access_cost
						table_insert(potential_paths, tmp)
						if not stopping and tmp.delay < 0.2 then
							stopping = #seg_to_search
						end
					end
				end

				for neighbour_seg_id, door_list in pairs(neighbours) do
					local neighbour = all_nav_segments[neighbour_seg_id]
					if not neighbour.disabled then
						if not verify_clbk or verify_clbk(neighbour_seg_id) then
							local access_cost = itr_get_accessibility(door_list, access_pos, access_neg)
							if access_cost then
								local discovered = discovered_seg[neighbour_seg_id]
								if not discovered then
									table_insert(seg_to_search, neighbour_seg_id)
									discovered_seg[neighbour_seg_id] = {
										path = from.path .. ';' .. neighbour_seg_id,
										delay = from.delay + access_cost,
										steps_nr = from.steps_nr + 1,
										coarse_dis = from.coarse_dis + mvec3_dis(neighbour.pos, from.pos),
										pos = neighbour.pos
									}
								else
									local new_delay = from.delay + access_cost
									local new_coarse_dis = from.coarse_dis + mvec3_dis(neighbour.pos, from.pos)
									if new_coarse_dis + new_delay * navlink_coef < discovered.coarse_dis + discovered.delay * navlink_coef then
										table_insert(seg_to_search, neighbour_seg_id)
										discovered.path = from.path .. ';' .. neighbour_seg_id
										discovered.delay = new_delay
										discovered.steps_nr = from.steps_nr + 1
										discovered.coarse_dis = new_coarse_dis
									end
								end
							end
						end
					end
				end
			end

			next_seg_id = table_remove(seg_to_search, 1)
		until not next_seg_id

		discovered_seg = nil
		seg_to_search = nil

		local best_score = 100000000
		local best_path
		for _, ppath in ipairs(potential_paths) do
			local score = ppath.coarse_dis + ppath.delay * navlink_coef
			ppath.score = score
			if score < best_score then
				best_score = score
				best_path = ppath
			end
		end
		potential_paths = nil

		if best_path then
			local path = {}
			local i = 1
			for _, v in ipairs(best_path.path:split(';')) do
				path[i] = { tonumber(v)	}
				i = i + 1
			end
			path[i] = {
				end_i_seg,
				search_data.to_pos
			}
			return search_data.results_callback and path or self:itr_streamline(path)
		end

		return false
	end

end


local function _load_custom_data(level_id)
	dofile(Iter._path .. '/lua/_' .. level_id .. '.lua')
end

local function _segment_to_vis_groups(data)
	local result = {}
	for i, vg in ipairs(data.vis_groups) do
		result[vg.seg] = i
	end
	return result
end

local level_id = Global.game_settings.level_id
level_id = level_id:gsub('_night$', ''):gsub('_day$', '')
local itr_original_navigationmanager_setloaddata = NavigationManager.set_load_data

if not Iter.settings['map_change_' .. level_id] then
	-- qued

elseif level_id == 'alex_2'
	or level_id == 'big'
	or level_id == 'branchbank'
	or level_id == 'mia_1'
	or level_id == 'roberts'
	or level_id == 'wwh'
then

	_load_custom_data(level_id)

	function NavigationManager:set_load_data(data)
		local seg2vg = _segment_to_vis_groups(data)
		itr_set_load_data(data, seg2vg)

		itr_original_navigationmanager_setloaddata(self, data)
	end

elseif level_id == 'jolly' then

	function NavigationManager:set_load_data(data)
		data.room_borders_x_pos[2718] = data.room_borders_x_pos[2718] + 2
		data.room_borders_y_neg[2718] = data.room_borders_y_neg[2718] - 1
		data.room_borders_y_pos[3743] = data.room_borders_y_pos[3743] + 1

		local pos = mvec3_cpy(data.door_high_pos[5105])
		mvector3.set_x(data.door_high_pos[5105], pos.x + 1)

		mvector3.set_x(pos, data.room_borders_x_neg[3743])
		mvector3.set_y(pos, data.room_borders_y_pos[3743])
		local pos1 = mvec3_cpy(pos)
		mvector3.set_y(pos1, pos1.y - 1)
		table.insert(data.door_low_pos, pos)
		table.insert(data.door_high_pos, pos1)
		table.insert(data.door_low_rooms, 2718)
		table.insert(data.door_high_rooms, 3743)

		data.nav_segments[141].neighbours[87] = { #data.door_low_pos }
		data.nav_segments[87].neighbours = { [141] = { #data.door_low_pos } }

		itr_original_navigationmanager_setloaddata(self, data)
	end

elseif level_id == 'moon' then

	function NavigationManager:set_load_data(data)
		data.room_borders_x_neg[2777] = data.room_borders_x_neg[2777] - 1
		data.room_borders_y_neg[2777] = data.room_borders_y_neg[2777] - 1

		local pos = mvec3_cpy(data.door_high_pos[4981])
		mvector3.set_x(pos, pos.x - 2)
		mvector3.set_y(pos, pos.y - 2)
		local pos1 = mvec3_cpy(pos)
		mvector3.set_x(pos1, pos1.x + 1)
		table.insert(data.door_low_pos, pos)
		table.insert(data.door_high_pos, pos1)
		table.insert(data.door_low_rooms, 2777)
		table.insert(data.door_high_rooms, 2758)

		data.nav_segments[22].neighbours[23] = { #data.door_low_pos }
		data.nav_segments[23].neighbours = { [22] = { #data.door_low_pos } }

		itr_original_navigationmanager_setloaddata(self, data)
	end

elseif level_id == 'arm_for' then

	function NavigationManager:set_load_data(data)
		local r59 = data.vis_groups[59].rooms
		r59[2703] = nil
		r59[2704] = nil
		r59[2712] = nil
		r59[2713] = true
		local r60 = data.vis_groups[60].rooms
		r60[2703] = true
		r60[2704] = true
		r60[2712] = true
		r60[2713] = nil
		data.vis_groups[59].rooms = r60
		data.vis_groups[60].rooms = r59

		itr_original_navigationmanager_setloaddata(self, data)
	end

elseif level_id == 'crojob2' then

	function NavigationManager:set_load_data(data)
		local seg2vg = _segment_to_vis_groups(data)
		local rooms_to_transfer = {
			414,
			417,
			418,
			424
		}
		for _, room_id in ipairs(rooms_to_transfer) do
			data.vis_groups[seg2vg[28]].rooms[room_id] = nil
			data.vis_groups[seg2vg[74]].rooms[room_id] = true
			data.room_vis_groups[room_id] = seg2vg[74]
		end

		for _, door_id in ipairs(data.nav_segments[28].neighbours[52]) do
			table.insert(data.nav_segments[74].neighbours[52], door_id)
			table.insert(data.nav_segments[52].neighbours[74], door_id)
		end
		data.nav_segments[28].neighbours[52] = nil
		data.nav_segments[52].neighbours[28] = nil

		for _, door_id in ipairs({758, 764, 772, 773}) do
			table.insert(data.nav_segments[28].neighbours[74], door_id)
			table.insert(data.nav_segments[74].neighbours[28], door_id)
		end

		for _, door_id in ipairs({1776, 1777}) do
			table.delete(data.nav_segments[28].neighbours[74], door_id)
			table.delete(data.nav_segments[74].neighbours[28], door_id)
		end

		itr_original_navigationmanager_setloaddata(self, data)
	end

elseif level_id == 'kosugi' then

	function NavigationManager:set_load_data(data)
		local rooms_to_transfer = {
			1779,
			1782,
			1786,
			1787,
			1788,
			1790,
			1791,
			1793,
			1794,
			1801,
			1802,
			1807
		}
		for _, room_id in ipairs(rooms_to_transfer) do
			data.vis_groups[2].rooms[room_id] = nil
			data.vis_groups[3].rooms[room_id] = true
			data.room_vis_groups[room_id] = 3
		end
		for _, door_id in ipairs(data.nav_segments[123].neighbours[2]) do
			table.insert(data.nav_segments[123].neighbours[3], door_id)
			table.insert(data.nav_segments[3].neighbours[123], door_id)
		end
		data.nav_segments[2].neighbours[123] = nil
		data.nav_segments[123].neighbours[2] = nil
		data.nav_segments[2].neighbours[3] = { 3100 }
		data.nav_segments[3].neighbours[2] = { 3100 }

		itr_original_navigationmanager_setloaddata(self, data)
	end

elseif level_id == 'born' then

	function NavigationManager:set_load_data(data)
		data.room_borders_y_pos[2798] = 111

		table.insert(data.door_low_pos, Vector3(-149, 111, 22.4998))
		table.insert(data.door_high_pos, Vector3(-146, 111, 22.4998))
		table.insert(data.door_low_rooms, 2798)
		table.insert(data.door_high_rooms, 3405)

		table.insert(data.door_low_pos, Vector3(-146, 111, 22.4998))
		table.insert(data.door_high_pos, Vector3(-140, 111, 22.4998))
		table.insert(data.door_low_rooms, 2798)
		table.insert(data.door_high_rooms, 3381)

		table.insert(data.door_low_pos, Vector3(-140, 111, 22.4998))
		table.insert(data.door_high_pos, Vector3(-138, 111, 22.4998))
		table.insert(data.door_low_rooms, 2798)
		table.insert(data.door_high_rooms, 3379)

		data.nav_segments[50].neighbours[51] = { 6275, 6276, 6277 }
		data.nav_segments[51].neighbours[50] = { 6275, 6276, 6277 }

		itr_original_navigationmanager_setloaddata(self, data)
	end

elseif level_id == 'peta' then

	function NavigationManager:set_load_data(data)
		local pos = mvec3_cpy(data.door_high_pos[11860])
		mvector3.set_y(pos, pos.y + 4)
		local pos1 = mvec3_cpy(pos)
		mvector3.set_y(pos1, pos1.y + 9)
		table.insert(data.door_low_pos, pos)
		table.insert(data.door_high_pos, pos1)
		table.insert(data.door_low_rooms, 97)
		table.insert(data.door_high_rooms, 5959)

		data.nav_segments[47].neighbours[91] = { #data.door_low_pos }
		data.nav_segments[91].neighbours = { [47] = { #data.door_low_pos } }

		itr_original_navigationmanager_setloaddata(self, data)
	end

elseif level_id == 'gallery' or level_id == 'framing_frame_1' then

	function NavigationManager:set_load_data(data)
		local vg = {
			rooms = {
				[858] = true,
				[859] = true,
				[870] = true,
				[871] = true,
				[872] = true,
				[873] = true,
				[881] = true,
				[883] = true,
				[884] = true
			},
			pos = Vector3(2457, 6, 0),
			seg = 100,
			vis_groups = {}
		}
		for k, v in pairs(data.vis_groups) do
			vg.vis_groups[k] = true
		end
		table.insert(data.vis_groups, vg)

		local seg2vg = _segment_to_vis_groups(data)
		for room_id in pairs(vg.rooms) do
			data.vis_groups[seg2vg[13]].rooms[room_id] = nil
			data.room_vis_groups[room_id] = seg2vg[100]
		end
		data.nav_segments[100] = {
			location_id = 'location_unknown',
			pos = Vector3(2457, 6, 0),
			vis_groups = { seg2vg[100] },
			neighbours = {
				[1] = data.nav_segments[1].neighbours[13],
				[13] = {1561, 1589, 1590, 1616}
			}
		}

		data.nav_segments[1].neighbours[100] = data.nav_segments[1].neighbours[13]
		data.nav_segments[13].neighbours[100] = data.nav_segments[100].neighbours[13]

		data.nav_segments[1].neighbours[13] = nil
		data.nav_segments[13].neighbours[1] = nil

		itr_original_navigationmanager_setloaddata(self, data)
	end

elseif level_id == 'watchdogs_1' then

	function NavigationManager:set_load_data(data)
		local seg2vg = _segment_to_vis_groups(data)

		local rooms_to_transfer = {
			896,
			897,
			898,
			899,
		}
		for _, room_id in ipairs(rooms_to_transfer) do
			data.vis_groups[seg2vg[134]].rooms[room_id] = nil
			data.vis_groups[seg2vg[52]].rooms[room_id] = true
			data.room_vis_groups[room_id] = seg2vg[52]
		end

		local d134t52 = data.nav_segments[134].neighbours[52]
		local d52t134 = data.nav_segments[52].neighbours[134]

		local old_doors = {
			1852,
			1855,
			1943,
			1944,
			1949,
			1953,
			1959,
			1960,
		}
		for _, door_id in ipairs(old_doors) do
			table.delete(d134t52, door_id)
			table.delete(d52t134, door_id)
		end

		local new_doors = {
			1564,
			1565,
			1566,
			1573,
		}
		for _, door_id in ipairs(new_doors) do
			table.insert(d134t52, door_id)
			table.insert(d52t134, door_id)
		end

		itr_original_navigationmanager_setloaddata(self, data)
	end

elseif level_id == 'pbr' then

	function NavigationManager:set_load_data(data)
		data.room_borders_y_pos[1222] = -286
		local did = #data.door_high_pos + 1
		data.door_low_pos[did] = Vector3(38, -287, -58)
		data.door_high_pos[did] = Vector3(38, -286, -82)
		data.door_low_rooms[did] = 1147
		data.door_high_rooms[did] = 1222
		data.nav_segments[39].neighbours[40] = {did}
		data.nav_segments[40].neighbours[39] = data.nav_segments[39].neighbours[40]

		data.room_borders_x_pos[5714] = -30
		data.room_borders_y_pos[5714] = -96
		did = did + 1
		data.door_low_pos[did] = Vector3(-30, -97, -160.145)
		data.door_high_pos[did] = Vector3(-30, -96, -160.145)
		data.door_low_rooms[did] = 1818
		data.door_high_rooms[did] = 5714
		data.nav_segments[30].neighbours[52] = {did}
		data.nav_segments[52].neighbours[30] = data.nav_segments[30].neighbours[52]

		itr_original_navigationmanager_setloaddata(self, data)
	end

elseif level_id == 'flat' then

	local downed_obstacle_units = {}
	local itr_original_navigationmanager_addobstacle = NavigationManager.add_obstacle
	function NavigationManager:add_obstacle(obstacle_unit, ...)
		if not downed_obstacle_units[obstacle_unit] and tostring(obstacle_unit:name()) == 'Idstring(@IDbc8566d71eae8505@)' then
			local pos = obstacle_unit:position()
			local z = pos.z
			downed_obstacle_units[obstacle_unit] = true
			mvector3.set_z(pos, z - 5)
			obstacle_unit:set_position(pos)
		end

		itr_original_navigationmanager_addobstacle(self, obstacle_unit, ...)
	end

end
