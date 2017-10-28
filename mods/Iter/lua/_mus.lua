function itr_set_load_data(data, seg2vg)
	-- war room
	local rid = #data.room_borders_x_neg + 1
	data.room_borders_x_pos[rid] = -66
	data.room_borders_x_neg[rid] = -69
	data.room_borders_y_pos[rid] = -58
	data.room_borders_y_neg[rid] = -94
	data.room_heights_xp_yp[rid] = -277.5
	data.room_heights_xp_yn[rid] = -277.5
	data.room_heights_xn_yp[rid] = -277.5
	data.room_heights_xn_yn[rid] = -277.5
	data.room_vis_groups[rid] = seg2vg[34]
	data.vis_groups[seg2vg[34]].rooms[rid] = true
end
