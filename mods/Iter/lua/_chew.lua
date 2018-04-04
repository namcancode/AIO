function itr_set_load_data(data, seg2vg)
	local rid = 160
	data.room_borders_x_neg[rid] = -2
	mvector3.set_x(data.door_low_pos[258], -2)
	mvector3.set_x(data.door_low_pos[259], -2)

	rid = #data.room_borders_x_neg + 1
	data.room_borders_x_pos[rid] = -2
	data.room_borders_x_neg[rid] = -8
	data.room_borders_y_pos[rid] = -15
	data.room_borders_y_neg[rid] = -24
	data.room_heights_xp_yp[rid] = 30.8
	data.room_heights_xp_yn[rid] = 30.8
	data.room_heights_xn_yp[rid] = 30.8
	data.room_heights_xn_yn[rid] = 30.8
	data.room_vis_groups[rid] = seg2vg[49]
	data.vis_groups[seg2vg[49]].rooms[rid] = true

	data.door_low_rooms[258] = rid

	local did = #data.door_low_rooms + 1
	data.door_low_pos[did] = Vector3(-7, -15, 30.8)
	data.door_high_pos[did] = Vector3(-2, -15, 30.8)
	data.door_low_rooms[did] = 41
	data.door_high_rooms[did] = 288
	table.insert(data.nav_segments[10].neighbours[49], did)
	table.insert(data.nav_segments[49].neighbours[10], did)

	did = did + 1
	data.door_low_pos[did] = Vector3(-2, -24, 30.8)
	data.door_high_pos[did] = Vector3(-2, -15, 30.8)
	data.door_low_rooms[did] = 160
	data.door_high_rooms[did] = 288

	rid = rid + 1
	data.room_borders_x_pos[rid] = -2
	data.room_borders_x_neg[rid] = -8
	data.room_borders_y_pos[rid] = -34
	data.room_borders_y_neg[rid] = -48
	data.room_heights_xp_yp[rid] = 30.8
	data.room_heights_xp_yn[rid] = 30.8
	data.room_heights_xn_yp[rid] = 30.8
	data.room_heights_xn_yn[rid] = 30.8
	data.room_vis_groups[rid] = seg2vg[49]
	data.vis_groups[seg2vg[49]].rooms[rid] = true

	did = did + 1
	data.door_low_pos[did] = Vector3(-8, -48, 30.8)
	data.door_high_pos[did] = Vector3(-2, -48, 30.8)
	data.door_low_rooms[did] = 18
	data.door_high_rooms[did] = 289
	table.insert(data.nav_segments[4].neighbours[49], did)
	table.insert(data.nav_segments[49].neighbours[4], did)

	did = did + 1
	data.door_low_pos[did] = Vector3(-2, -48, 30.8)
	data.door_high_pos[did] = Vector3(-2, -34, 30.8)
	data.door_low_rooms[did] = 160
	data.door_high_rooms[did] = 289
end
