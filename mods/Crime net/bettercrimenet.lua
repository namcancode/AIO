
	local _create_locations_original = CrimeNetGui._create_locations
	local _get_job_location_original = CrimeNetGui._get_job_location
	local _create_job_gui_original = CrimeNetGui._create_job_gui
	local colorizeCrNt = betterCrNt.options.crnt_colorize
	
	function CrimeNetGui:_create_locations()
		_create_locations_original(self)
		if betterCrNt.options.crnt_align then
			local newDots = {}
			local xx,yy = 12,10
			for i=1,xx do -- 224~1666 1442
				for j=1,yy do -- 165~945 780
					local newX = 150+ 1642*i/xx
						local newY = 150+ 680*(i % 2 == 0 and j or j - 0.5)/yy
						if  (i >= 3) or ( j < 7 ) then
							-- avoiding fixed points
							table.insert(newDots,{ newX, newY })
						end
				end
			end
			self._locations[1][1].dots = newDots
		end
	end
		
		cl = {
	LavenderBlush = Color(1,16/17,49/51), PaleGoldenrod = Color(14/15,232/255,2/3), PaleGreen = Color(152/255,251/255,152/255), Red = Color(1,0,0), Tomato = Color(1,33/85,71/255), Wheat = Color(49/51,74/85,179/255),
	White = Color(1,1,1)
	}
		
	function CrimeNetGui:_create_job_gui(data, type, fixed_x, fixed_y, fixed_location)
		local sizeMulCrNt = betterCrNt.options.crnt_size
		
		local size = tweak_data.menu.pd2_small_font_size
		tweak_data.menu.pd2_small_font_size = size * sizeMulCrNt
		local result = _create_job_gui_original(self, data, type, fixed_x, fixed_y, fixed_location)
		tweak_data.menu.pd2_small_font_size = size
		if colorizeCrNt and result.side_panel and result.side_panel:child('job_name') then
			local colors = {cl.Red,cl.PaleGreen,cl.PaleGoldenrod,cl.LavenderBlush,cl.Wheat,cl.Tomato}
			result.side_panel:child('job_name'):set_color(colors[data.difficulty_id] or cl.White)
		end
		if colorizeCrNt and result.heat_glow then
			result.heat_glow:set_alpha(result.heat_glow:alpha()*0.5)
		end
		return result
	end

	function CrimeNetGui:_get_job_location(data)
		if betterCrNt.options.crnt_sort then
			_get_job_location_original(self, data)
			local diff = (data and data.difficulty_id or 2) - 2
			local diffX = 236 + ( 1700 / 7 ) * diff
			local locations = self:_get_contact_locations()
			local sorted = {}
				for k,dot in pairs(locations[1].dots) do
				if not dot[3] then
					table.insert(sorted,dot)
				end
			end
			if #sorted > 0 then
				local abs = math.abs
				table.sort(sorted,function(a,b)
					return abs(diffX-a[1]) < abs(diffX-b[1])
				end)
				local dot = sorted[1]
				local x,y = dot[1],dot[2]
				local tw = math.max(self._map_panel:child("map"):texture_width(), 1)
				local th = math.max(self._map_panel:child("map"):texture_height(), 1)
				x = math.round(x / tw * self._map_size_w)
				y = math.round(y / th * self._map_size_h)

				return x,y,dot
			end
		else
			return _get_job_location_original(self, data)
		end
	end