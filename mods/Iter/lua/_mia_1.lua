function itr_set_load_data(data, seg2vg)
	-- room 101
	local rid = #data.room_borders_x_neg + 1
	data.room_borders_x_pos[rid] = 222
	data.room_borders_x_neg[rid] = 213
	data.room_borders_y_pos[rid] = -79
	data.room_borders_y_neg[rid] = -85
	data.room_heights_xp_yp[rid] = 47.5
	data.room_heights_xp_yn[rid] = 47.5
	data.room_heights_xn_yp[rid] = 47.5
	data.room_heights_xn_yn[rid] = 47.5
	data.room_vis_groups[rid] = seg2vg[3]
	data.vis_groups[seg2vg[3]].rooms[rid] = true

	rid = rid + 1
	data.room_borders_x_pos[rid] = 222
	data.room_borders_x_neg[rid] = 219
	data.room_borders_y_pos[rid] = -55
	data.room_borders_y_neg[rid] = -62
	data.room_heights_xp_yp[rid] = 47.5
	data.room_heights_xp_yn[rid] = 47.5
	data.room_heights_xn_yp[rid] = 47.5
	data.room_heights_xn_yn[rid] = 47.5
	data.room_vis_groups[rid] = seg2vg[3]
	data.vis_groups[seg2vg[3]].rooms[rid] = true

	-- room 102
	rid = rid + 1
	data.room_borders_x_pos[rid] = 222
	data.room_borders_x_neg[rid] = 213
	data.room_borders_y_pos[rid] = -135
	data.room_borders_y_neg[rid] = -141
	data.room_heights_xp_yp[rid] = 47.5
	data.room_heights_xp_yn[rid] = 47.5
	data.room_heights_xn_yp[rid] = 47.5
	data.room_heights_xn_yn[rid] = 47.5
	data.room_vis_groups[rid] = seg2vg[20]
	data.vis_groups[seg2vg[20]].rooms[rid] = true

	rid = rid + 1
	data.room_borders_x_pos[rid] = 222
	data.room_borders_x_neg[rid] = 219
	data.room_borders_y_pos[rid] = -111
	data.room_borders_y_neg[rid] = -118
	data.room_heights_xp_yp[rid] = 47.5
	data.room_heights_xp_yn[rid] = 47.5
	data.room_heights_xn_yp[rid] = 47.5
	data.room_heights_xn_yn[rid] = 47.5
	data.room_vis_groups[rid] = seg2vg[20]
	data.vis_groups[seg2vg[20]].rooms[rid] = true

	-- room 103
	rid = rid + 1
	data.room_borders_x_pos[rid] = 195
	data.room_borders_x_neg[rid] = 189
	data.room_borders_y_pos[rid] = -148
	data.room_borders_y_neg[rid] = -153
	data.room_heights_xp_yp[rid] = 47.5
	data.room_heights_xp_yn[rid] = 47.5
	data.room_heights_xn_yp[rid] = 47.5
	data.room_heights_xn_yn[rid] = 47.5
	data.room_vis_groups[rid] = seg2vg[22]
	data.vis_groups[seg2vg[22]].rooms[rid] = true

	rid = rid + 1
	data.room_borders_x_pos[rid] = 222
	data.room_borders_x_neg[rid] = 207
	data.room_borders_y_pos[rid] = -148
	data.room_borders_y_neg[rid] = -156
	data.room_heights_xp_yp[rid] = 47.5
	data.room_heights_xp_yn[rid] = 47.5
	data.room_heights_xn_yp[rid] = 47.5
	data.room_heights_xn_yn[rid] = 47.5
	data.room_vis_groups[rid] = seg2vg[22]
	data.vis_groups[seg2vg[22]].rooms[rid] = true

	rid = rid + 1
	data.room_borders_x_pos[rid] = 222
	data.room_borders_x_neg[rid] = 220
	data.room_borders_y_pos[rid] = -173
	data.room_borders_y_neg[rid] = -181
	data.room_heights_xp_yp[rid] = 47.5
	data.room_heights_xp_yn[rid] = 47.5
	data.room_heights_xn_yp[rid] = 47.5
	data.room_heights_xn_yn[rid] = 47.5
	data.room_vis_groups[rid] = seg2vg[22]
	data.vis_groups[seg2vg[22]].rooms[rid] = true

	-- room 104
	rid = rid + 1
	data.room_borders_x_pos[rid] = 145
	data.room_borders_x_neg[rid] = 138
	data.room_borders_y_pos[rid] = -167
	data.room_borders_y_neg[rid] = -176
	data.room_heights_xp_yp[rid] = 47.5
	data.room_heights_xp_yn[rid] = 47.5
	data.room_heights_xn_yp[rid] = 47.5
	data.room_heights_xn_yn[rid] = 47.5
	data.room_vis_groups[rid] = seg2vg[9]
	data.vis_groups[seg2vg[9]].rooms[rid] = true

	rid = rid + 1
	data.room_borders_x_pos[rid] = 168
	data.room_borders_x_neg[rid] = 160
	data.room_borders_y_pos[rid] = -174
	data.room_borders_y_neg[rid] = -176
	data.room_heights_xp_yp[rid] = 47.5
	data.room_heights_xp_yn[rid] = 47.5
	data.room_heights_xn_yp[rid] = 47.5
	data.room_heights_xn_yn[rid] = 47.5
	data.room_vis_groups[rid] = seg2vg[9]
	data.vis_groups[seg2vg[9]].rooms[rid] = true

	-- room 105
	rid = rid + 1
	data.room_borders_x_pos[rid] = 131
	data.room_borders_x_neg[rid] = 127
	data.room_borders_y_pos[rid] = -143
	data.room_borders_y_neg[rid] = -176
	data.room_heights_xp_yp[rid] = 47.5
	data.room_heights_xp_yn[rid] = 47.5
	data.room_heights_xn_yp[rid] = 47.5
	data.room_heights_xn_yn[rid] = 47.5
	data.room_vis_groups[rid] = seg2vg[26]
	data.vis_groups[seg2vg[26]].rooms[rid] = true

	rid = rid + 1
	data.room_borders_x_pos[rid] = 104
	data.room_borders_x_neg[rid] = 98
	data.room_borders_y_pos[rid] = -143
	data.room_borders_y_neg[rid] = -149
	data.room_heights_xp_yp[rid] = 47.5
	data.room_heights_xp_yn[rid] = 47.5
	data.room_heights_xn_yp[rid] = 47.5
	data.room_heights_xn_yn[rid] = 47.5
	data.room_vis_groups[rid] = seg2vg[26]
	data.vis_groups[seg2vg[26]].rooms[rid] = true

	rid = rid + 1
	data.room_borders_x_pos[rid] = 105
	data.room_borders_x_neg[rid] = 98
	data.room_borders_y_pos[rid] = -174
	data.room_borders_y_neg[rid] = -176
	data.room_heights_xp_yp[rid] = 47.5
	data.room_heights_xp_yn[rid] = 47.5
	data.room_heights_xn_yp[rid] = 47.5
	data.room_heights_xn_yn[rid] = 47.5
	data.room_vis_groups[rid] = seg2vg[26]
	data.vis_groups[seg2vg[26]].rooms[rid] = true

	-- room 106
	rid = rid + 1
	data.room_borders_x_pos[rid] = 46
	data.room_borders_x_neg[rid] = 40
	data.room_borders_y_pos[rid] = -167
	data.room_borders_y_neg[rid] = -176
	data.room_heights_xp_yp[rid] = 47.5
	data.room_heights_xp_yn[rid] = 47.5
	data.room_heights_xn_yp[rid] = 47.5
	data.room_heights_xn_yn[rid] = 47.5
	data.room_vis_groups[rid] = seg2vg[12]
	data.vis_groups[seg2vg[12]].rooms[rid] = true

	rid = rid + 1
	data.room_borders_x_pos[rid] = 70
	data.room_borders_x_neg[rid] = 63
	data.room_borders_y_pos[rid] = -174
	data.room_borders_y_neg[rid] = -176
	data.room_heights_xp_yp[rid] = 47.5
	data.room_heights_xp_yn[rid] = 47.5
	data.room_heights_xn_yp[rid] = 47.5
	data.room_heights_xn_yn[rid] = 47.5
	data.room_vis_groups[rid] = seg2vg[12]
	data.vis_groups[seg2vg[12]].rooms[rid] = true

	-- room 107
	rid = rid + 1
	data.room_borders_x_pos[rid] = 33
	data.room_borders_x_neg[rid] = 24
	data.room_borders_y_pos[rid] = -167
	data.room_borders_y_neg[rid] = -176
	data.room_heights_xp_yp[rid] = 47.5
	data.room_heights_xp_yn[rid] = 47.5
	data.room_heights_xn_yp[rid] = 47.5
	data.room_heights_xn_yn[rid] = 47.5
	data.room_vis_groups[rid] = seg2vg[48]
	data.vis_groups[seg2vg[48]].rooms[rid] = true

	rid = rid + 1
	data.room_borders_x_pos[rid] = 7
	data.room_borders_x_neg[rid] = 0
	data.room_borders_y_pos[rid] = -174
	data.room_borders_y_neg[rid] = -176
	data.room_heights_xp_yp[rid] = 47.5
	data.room_heights_xp_yn[rid] = 47.5
	data.room_heights_xn_yp[rid] = 47.5
	data.room_heights_xn_yn[rid] = 47.5
	data.room_vis_groups[rid] = seg2vg[48]
	data.vis_groups[seg2vg[48]].rooms[rid] = true

	rid = rid + 1
	data.room_borders_x_pos[rid] = 6
	data.room_borders_x_neg[rid] = 0
	data.room_borders_y_pos[rid] = -143
	data.room_borders_y_neg[rid] = -149
	data.room_heights_xp_yp[rid] = 47.5
	data.room_heights_xp_yn[rid] = 47.5
	data.room_heights_xn_yp[rid] = 47.5
	data.room_heights_xn_yn[rid] = 47.5
	data.room_vis_groups[rid] = seg2vg[48]
	data.vis_groups[seg2vg[48]].rooms[rid] = true

	-- room 108
	data.room_borders_x_neg[1395] = -24
	data.room_borders_y_neg[1395] = -121

	rid = rid + 1
	data.room_borders_x_pos[rid] = -15
	data.room_borders_x_neg[rid] = -24
	data.room_borders_y_pos[rid] = -92
	data.room_borders_y_neg[rid] = -98
	data.room_heights_xp_yp[rid] = 47.5
	data.room_heights_xp_yn[rid] = 47.5
	data.room_heights_xn_yp[rid] = 47.5
	data.room_heights_xn_yn[rid] = 47.5
	data.room_vis_groups[rid] = seg2vg[6]
	data.vis_groups[seg2vg[6]].rooms[rid] = true

	-- room 202
	data.room_borders_x_pos[1754] = 222

	rid = rid + 1
	data.room_borders_x_pos[rid] = 204
	data.room_borders_x_neg[rid] = 189
	data.room_borders_y_pos[rid] = -111
	data.room_borders_y_neg[rid] = -118
	data.room_heights_xp_yp[rid] = 447.5
	data.room_heights_xp_yn[rid] = 447.5
	data.room_heights_xn_yp[rid] = 447.5
	data.room_heights_xn_yn[rid] = 447.5
	data.room_vis_groups[rid] = seg2vg[5]
	data.vis_groups[seg2vg[5]].rooms[rid] = true

	rid = rid + 1
	data.room_borders_x_pos[rid] = 197
	data.room_borders_x_neg[rid] = 189
	data.room_borders_y_pos[rid] = -139
	data.room_borders_y_neg[rid] = -144
	data.room_heights_xp_yp[rid] = 447.5
	data.room_heights_xp_yn[rid] = 447.5
	data.room_heights_xn_yp[rid] = 447.5
	data.room_heights_xn_yn[rid] = 447.5
	data.room_vis_groups[rid] = seg2vg[5]
	data.vis_groups[seg2vg[5]].rooms[rid] = true

	-- room 203
	rid = rid + 1
	data.room_borders_x_pos[rid] = 194
	data.room_borders_x_neg[rid] = 189
	data.room_borders_y_pos[rid] = -148
	data.room_borders_y_neg[rid] = -154
	data.room_heights_xp_yp[rid] = 447.5
	data.room_heights_xp_yn[rid] = 447.5
	data.room_heights_xn_yp[rid] = 447.5
	data.room_heights_xn_yn[rid] = 447.5
	data.room_vis_groups[rid] = seg2vg[7]
	data.vis_groups[seg2vg[7]].rooms[rid] = true

	rid = rid + 1
	data.room_borders_x_pos[rid] = 194
	data.room_borders_x_neg[rid] = 189
	data.room_borders_y_pos[rid] = -174
	data.room_borders_y_neg[rid] = -181
	data.room_heights_xp_yp[rid] = 447.5
	data.room_heights_xp_yn[rid] = 447.5
	data.room_heights_xn_yp[rid] = 447.5
	data.room_heights_xn_yn[rid] = 447.5
	data.room_vis_groups[rid] = seg2vg[7]
	data.vis_groups[seg2vg[7]].rooms[rid] = true

	rid = rid + 1
	data.room_borders_x_pos[rid] = 210
	data.room_borders_x_neg[rid] = 204
	data.room_borders_y_pos[rid] = -148
	data.room_borders_y_neg[rid] = -162
	data.room_heights_xp_yp[rid] = 447.5
	data.room_heights_xp_yn[rid] = 447.5
	data.room_heights_xn_yp[rid] = 447.5
	data.room_heights_xn_yn[rid] = 447.5
	data.room_vis_groups[rid] = seg2vg[7]
	data.vis_groups[seg2vg[7]].rooms[rid] = true

	-- room 204
	rid = rid + 1
	data.room_borders_x_pos[rid] = 140
	data.room_borders_x_neg[rid] = 135
	data.room_borders_y_pos[rid] = -143
	data.room_borders_y_neg[rid] = -151
	data.room_heights_xp_yp[rid] = 447.5
	data.room_heights_xp_yn[rid] = 447.5
	data.room_heights_xn_yp[rid] = 447.5
	data.room_heights_xn_yn[rid] = 447.5
	data.room_vis_groups[rid] = seg2vg[8]
	data.vis_groups[seg2vg[8]].rooms[rid] = true

	rid = rid + 1
	data.room_borders_x_pos[rid] = 156
	data.room_borders_x_neg[rid] = 150
	data.room_borders_y_pos[rid] = -143
	data.room_borders_y_neg[rid] = -147
	data.room_heights_xp_yp[rid] = 447.5
	data.room_heights_xp_yn[rid] = 447.5
	data.room_heights_xn_yp[rid] = 447.5
	data.room_heights_xn_yn[rid] = 447.5
	data.room_vis_groups[rid] = seg2vg[8]
	data.vis_groups[seg2vg[8]].rooms[rid] = true

	rid = rid + 1
	data.room_borders_x_pos[rid] = 168
	data.room_borders_x_neg[rid] = 161
	data.room_borders_y_pos[rid] = -143
	data.room_borders_y_neg[rid] = -148
	data.room_heights_xp_yp[rid] = 447.5
	data.room_heights_xp_yn[rid] = 447.5
	data.room_heights_xn_yp[rid] = 447.5
	data.room_heights_xn_yn[rid] = 447.5
	data.room_vis_groups[rid] = seg2vg[8]
	data.vis_groups[seg2vg[8]].rooms[rid] = true

	rid = rid + 1
	data.room_borders_x_pos[rid] = 168
	data.room_borders_x_neg[rid] = 161
	data.room_borders_y_pos[rid] = -171
	data.room_borders_y_neg[rid] = -176
	data.room_heights_xp_yp[rid] = 447.5
	data.room_heights_xp_yn[rid] = 447.5
	data.room_heights_xn_yp[rid] = 447.5
	data.room_heights_xn_yn[rid] = 447.5
	data.room_vis_groups[rid] = seg2vg[8]
	data.vis_groups[seg2vg[8]].rooms[rid] = true

	-- room 205
	rid = rid + 1
	data.room_borders_x_pos[rid] = 105
	data.room_borders_x_neg[rid] = 98
	data.room_borders_y_pos[rid] = -143
	data.room_borders_y_neg[rid] = -148
	data.room_heights_xp_yp[rid] = 447.5
	data.room_heights_xp_yn[rid] = 447.5
	data.room_heights_xn_yp[rid] = 447.5
	data.room_heights_xn_yn[rid] = 447.5
	data.room_vis_groups[rid] = seg2vg[14]
	data.vis_groups[seg2vg[14]].rooms[rid] = true

	rid = rid + 1
	data.room_borders_x_pos[rid] = 131
	data.room_borders_x_neg[rid] = 123
	data.room_borders_y_pos[rid] = -143
	data.room_borders_y_neg[rid] = -147
	data.room_heights_xp_yp[rid] = 447.5
	data.room_heights_xp_yn[rid] = 447.5
	data.room_heights_xn_yp[rid] = 447.5
	data.room_heights_xn_yn[rid] = 447.5
	data.room_vis_groups[rid] = seg2vg[14]
	data.vis_groups[seg2vg[14]].rooms[rid] = true

	rid = rid + 1
	data.room_borders_x_pos[rid] = 131
	data.room_borders_x_neg[rid] = 117
	data.room_borders_y_pos[rid] = -158
	data.room_borders_y_neg[rid] = -164
	data.room_heights_xp_yp[rid] = 447.5
	data.room_heights_xp_yn[rid] = 447.5
	data.room_heights_xn_yp[rid] = 447.5
	data.room_heights_xn_yn[rid] = 447.5
	data.room_vis_groups[rid] = seg2vg[14]
	data.vis_groups[seg2vg[14]].rooms[rid] = true

	-- room 206
	rid = rid + 1
	data.room_borders_x_pos[rid] = 42
	data.room_borders_x_neg[rid] = 37
	data.room_borders_y_pos[rid] = -143
	data.room_borders_y_neg[rid] = -151
	data.room_heights_xp_yp[rid] = 447.5
	data.room_heights_xp_yn[rid] = 447.5
	data.room_heights_xn_yp[rid] = 447.5
	data.room_heights_xn_yn[rid] = 447.5
	data.room_vis_groups[rid] = seg2vg[13]
	data.vis_groups[seg2vg[13]].rooms[rid] = true

	rid = rid + 1
	data.room_borders_x_pos[rid] = 58
	data.room_borders_x_neg[rid] = 52
	data.room_borders_y_pos[rid] = -143
	data.room_borders_y_neg[rid] = -147
	data.room_heights_xp_yp[rid] = 447.5
	data.room_heights_xp_yn[rid] = 447.5
	data.room_heights_xn_yp[rid] = 447.5
	data.room_heights_xn_yn[rid] = 447.5
	data.room_vis_groups[rid] = seg2vg[13]
	data.vis_groups[seg2vg[13]].rooms[rid] = true

	rid = rid + 1
	data.room_borders_x_pos[rid] = 70
	data.room_borders_x_neg[rid] = 63
	data.room_borders_y_pos[rid] = -143
	data.room_borders_y_neg[rid] = -158
	data.room_heights_xp_yp[rid] = 447.5
	data.room_heights_xp_yn[rid] = 447.5
	data.room_heights_xn_yp[rid] = 447.5
	data.room_heights_xn_yn[rid] = 447.5
	data.room_vis_groups[rid] = seg2vg[13]
	data.vis_groups[seg2vg[13]].rooms[rid] = true

	-- room 207
	rid = rid + 1
	data.room_borders_x_pos[rid] = 7
	data.room_borders_x_neg[rid] = 0
	data.room_borders_y_pos[rid] = -143
	data.room_borders_y_neg[rid] = -148
	data.room_heights_xp_yp[rid] = 447.5
	data.room_heights_xp_yn[rid] = 447.5
	data.room_heights_xn_yp[rid] = 447.5
	data.room_heights_xn_yn[rid] = 447.5
	data.room_vis_groups[rid] = seg2vg[80]
	data.vis_groups[seg2vg[80]].rooms[rid] = true

	rid = rid + 1
	data.room_borders_x_pos[rid] = 33
	data.room_borders_x_neg[rid] = 27
	data.room_borders_y_pos[rid] = -143
	data.room_borders_y_neg[rid] = -148
	data.room_heights_xp_yp[rid] = 447.5
	data.room_heights_xp_yn[rid] = 447.5
	data.room_heights_xn_yp[rid] = 447.5
	data.room_heights_xn_yn[rid] = 447.5
	data.room_vis_groups[rid] = seg2vg[80]
	data.vis_groups[seg2vg[80]].rooms[rid] = true

	rid = rid + 1
	data.room_borders_x_pos[rid] = 33
	data.room_borders_x_neg[rid] = 19
	data.room_borders_y_pos[rid] = -158
	data.room_borders_y_neg[rid] = -164
	data.room_heights_xp_yp[rid] = 447.5
	data.room_heights_xp_yn[rid] = 447.5
	data.room_heights_xn_yp[rid] = 447.5
	data.room_heights_xn_yn[rid] = 447.5
	data.room_vis_groups[rid] = seg2vg[80]
	data.vis_groups[seg2vg[80]].rooms[rid] = true

	-- room 208
	rid = rid + 1
	data.room_borders_x_pos[rid] = 9
	data.room_borders_x_neg[rid] = 0
	data.room_borders_y_pos[rid] = -113
	data.room_borders_y_neg[rid] = -122
	data.room_heights_xp_yp[rid] = 447.5
	data.room_heights_xp_yn[rid] = 447.5
	data.room_heights_xn_yp[rid] = 447.5
	data.room_heights_xn_yn[rid] = 447.5
	data.room_vis_groups[rid] = seg2vg[79]
	data.vis_groups[seg2vg[79]].rooms[rid] = true
end
