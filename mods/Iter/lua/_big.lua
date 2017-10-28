function itr_set_load_data(data, seg2vg)
	-- prevent chars to walk into wall
	data.room_borders_x_neg[489] = 66
	mvector3.set_x(data.door_low_pos[800], 66)
	mvector3.set_x(data.door_low_pos[801], 66)
end
