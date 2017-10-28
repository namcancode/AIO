function itr_set_load_data(data, seg2vg)
	data.room_borders_x_pos[971] = 151
	data.room_borders_x_neg[971] = 148
	data.room_borders_y_pos[971] = 195
	data.room_borders_y_neg[971] = 171
	data.room_heights_xp_yp[971] = 1243.8
	data.room_heights_xp_yn[971] = 972.5
	data.room_heights_xn_yp[971] = 1243.8
	data.room_heights_xn_yn[971] = 972.5

	local did = #data.door_low_pos + 1
	data.door_low_pos[did] = Vector3(148, 171, 972.5)
	data.door_high_pos[did] = Vector3(151, 171, 972.5)
	data.door_low_rooms[did] = 442
	data.door_high_rooms[did] = 971

	data.nav_segments[19].neighbours[23] = { did }
	data.nav_segments[23].neighbours[19] = { did }

	local rid = #data.room_borders_x_neg + 1
	data.room_borders_x_pos[rid] = 151
	data.room_borders_x_neg[rid] = 148
	data.room_borders_y_pos[rid] = 202
	data.room_borders_y_neg[rid] = 195
	data.room_heights_xp_yp[rid] = 1243.8
	data.room_heights_xp_yn[rid] = 1243.8
	data.room_heights_xn_yp[rid] = 1243.8
	data.room_heights_xn_yn[rid] = 1243.8
	data.room_vis_groups[rid] = seg2vg[36]
	data.vis_groups[seg2vg[36]].rooms[rid] = true

	did = did + 1
	data.door_low_pos[did] = Vector3(148, 195, 1243.8)
	data.door_high_pos[did] = Vector3(151, 195, 1243.8)
	data.door_low_rooms[did] = 835
	data.door_high_rooms[did] = rid

	did = did + 1
	data.door_low_pos[did] = Vector3(148, 202, 1243.8)
	data.door_high_pos[did] = Vector3(151, 202, 1243.8)
	data.door_low_rooms[did] = 971
	data.door_high_rooms[did] = rid

	data.nav_segments[19].neighbours[36] = { did }
	data.nav_segments[36].neighbours[19] = { did }
end
