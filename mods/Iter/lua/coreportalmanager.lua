local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

core:module('CorePortalManager')

local level_id = Global.game_settings and Global.game_settings.level_id or ''
level_id = level_id:gsub('_night$', ''):gsub('_day$', '')

if not _G.Iter.settings['map_change_' .. level_id] then

elseif level_id == 'dah' then

	local _itr_portal_bounds = {
		group1 = { -- floor 22, body, administration (ok)
			{ -3780, -2803, -4357, -4123, 374, 700 },
			{ -3320, -3261, -4686, -4545, 374, 498 },
			{ -2490, -2210, -5176, -4173, 374, 726 },
			{ -3710, -2916, -3579, -3399, 374, 567 },
		},
		group2 = { -- floor 22 + 23, body, meeting room (ok)
			{ -5977, -4699, -5400, -3999, 373, 751 },
			{ -5300, -4900, -4101, -4000, 950, 952 },
		},
		group3 = { -- floor 23 + roof, body (ok)
			{ -4680, -4160, -5225, -5020, 774, 1075 },
			{ -2790, -2220, -3830, -3599, 774, 1075 },
			{ -2400, -2024, -5401, -3599, 774, 1126 },
			{ -2455, -1390, -5401, -4150, 774, 1126 },
			{ -3925, -2430, -4702, -4140, 773, 1150 },
			{ -3577, -2459, -5129, -4950, 774, 857 },
			{ -2461, -2459, -4951, -4949, 774, 776 },
			{ -1989, -1674, -5251, -4299, 1174, 1436 },
		},
		group4 = { -- floor 23 + roof, body and arms without ends
		},
		group5 = { -- floor 23 + roof, body part (ok)
			{ -6600, -6075, -2824, -1775, 772, 1120 },
			{ -6019, -5500, -3125, -2350, 772, 1120 },
			{ -6030, -5500, -2500, -1829, 772, 1120 },
		},
		group6 = { -- floor 23 + roof, arms
			{ -1850, -650, -1000, 850, 769, 920 },
			{ -1588, -707, -1153, -1089, 774, 1018 },
			{ -630, -25, 200, 1480, 776, 920 },
			{ -338, -24, 1193, 1477, 774, 1117 },
			{ -328, -284, -125, -57, 774, 780 },
			{ -6604, -6343, -1800, 667, 774, 964 },
		},
		group7 = { -- floor 23 + roof, arm party side (ok)
			{ -1501, -1400, -1990, -1175, 772, 964 },
			{ -1513, -700, -3062, -2024, 772, 1120 },
			{ -700, -29, -3062, -2040, 772, 1120 },
			{ -1017, -26, -4100, -3335, 755, 1126 },
			{ -2003, -1666, -3134, -2640, 775, 1125 },
			{ -701, -199, -2026, -1624, 1173, 1481 },
		},
		group8 = { -- floor 22, arm unfinished side (ok)
			{ -6070, -5311, -3801, -2856, 373, 725 },
			{ -5947, -5544, 210, 836, 373, 681 },
			{ -6574, -5970, -2139, 904, 374, 726 },
			{ -5454, -5375, -1216, -1131, 374, 452 },
			{ -5787, -5100, -1901, -1496, 338, 570 }, -- shared with 11
		},
		group9 = { -- floor 22, arm party side
			{ -1226, -1224, -1835, -1833, 374, 376 },
			{ -1552, -565, -3351, -3293, 374, 641 }, -- shared with 11
			{ -1377, -877, -3033, -2302, 373, 457 }, -- shared with 11
			{ -1382, -1364, -2399, -2123, 374, 503 }, -- shared with 11
		},
		group10 = { -- floor 22 + 23, arms (ok)
			{ -1656, -636, 1000, 1479, 374, 725 },
			{ -5748, -5332, 1135, 1461, 774, 850 },
			{ -5466, -4986, 874, 1428, 374, 416 },
			{ -1325, -996, 998, 1480, 774, 915 },
		},
		group11 = { -- floor 22, body without head (ok)
			{ -5527, -4684, -3801, -2828, 350, 726 },
			{ -1813, -1362, -2462, -2446, 385, 564 },
			{ -5867, -5285, -2277, -2273, 395, 641 },
			{ -5471, -5468, -2448, -2445, 374, 376 },
			{ -928, -925, -2306, -2304, 550, 552 },
			{ -5787, -5100, -1901, -1496, 338, 570 }, -- shared with 8
			{ -1552, -565, -3351, -3293, 374, 641 }, -- shared with 9
			{ -1377, -877, -3033, -2302, 373, 457 }, -- shared with 9
			{ -1382, -1364, -2399, -2123, 374, 503 }, -- shared with 9
		},
		group12 = { -- floor 22 + 23 + roof, end of arms
			{ -1724, -632, 874, 900, 374, 1126 },
		},
		group13 = { -- vault
			{ -5275, -1325, -5460, -3800, -280, 323 },
		},
		group14 = { -- vault entry (ok)
			{ -3730, -2975, -6800, -2650, -280, 325 },
		},
		group15 = { -- not roof
		},
	}
	local itr_original_portalunitgroup_addunit = PortalUnitGroup.add_unit
	function PortalUnitGroup:add_unit(unit)
		local bounds = _itr_portal_bounds[self._name]
		if bounds then
			for _, bound in ipairs(bounds) do
				local pos = unit:position()
				if pos.x > bound[1] and pos.x < bound[2] and pos.y > bound[3] and pos.y < bound[4] and pos.z > bound[5] and pos.z < bound[6] then
					self._ids[unit:unit_data().unit_id] = true
					break
				end
			end
		end

		return itr_original_portalunitgroup_addunit(self, unit)
	end

	local _itr_portal_ids = {
		group3 = { -- floor 23 + roof, body
			702569,
			702609,
			703110,
			703118,
			703173,
		},
		group4 = { -- floor 23 + roof, body and arms without ends
			104534,
			104535,
			104536,
			104539,
			700425,
			702634,
			702638,
			702659,
			702662,
			702668,
			702680,
			702684,
			702688,
			702692,
			702694,
			702697,
			702699,
			702724,
			702757,
			702988,
			702994,
			703045,
			703049,
			703276,
			703296,
			703298,
			703316,
			703320,
			703323,
			703324,
			703331,
			703337,
			703373,
			703375,
			703379,
			703384,
			703385,
			703386,
			703393,
			703053,
			703058,
			703193,
			703326,
			703396,
			703479,
		},
		group5 = { -- floor 23 + roof, body part
			701813,
			701824,
			704312,
		},
		group6 = { -- floor 23 + roof, arms
			700058,
			700148,
			700221,
			700319,
			700744,
			700776,
			700804,
			700834,
			700921,
			701899,
			701176,
			701268,
			701280,
			701769,
			700598,
			700639,
			700664,
			700673,
			700687,
			700696,
			700725,
			700876,
			701245,
			701313,
			701380,
		},
		group7 = { -- floor 23 + roof, arm party side
			702154,
			702261,
			702316,
			702650,
			702652,
			703387,
		},
		group8 = { -- floor 22, arm unfinished side
			702100,
			702116,
			702139,
			702209,
		},
		group10 = { -- floor 22 + 23, arms
			700938,
			701006,
			701009,
			701043,
			701046,
			701062,
			701066,
		},
		group12= { -- floor 22 + 23 + roof, end of arms
			700312,
			700352,
			700370,
			700389,
			700399,
			700400,
			700435,
			700445,
			700456,
			700461,
			700469,
			700471,
			700474,
			700476,
			700488,
			700507,
			700528,
			700563,
			700633,
			700681,
			700721,
			700401,
			700422,
			700427,
			700433,
			700455,
			700472,
			700397,
			700403,
			700407,
			700428,
			700430,
		},
		group14 = { -- vault entry
			703374,
			703621,
			703706,
			703887,
			704072,
			704090,
			704099,
			704159,
			704167,
			704182,
			704184,
			704186,
			704189,
			704208,
		},
	}
	local itr_original_portalunitgroup_setids = PortalUnitGroup.set_ids
	function PortalUnitGroup:set_ids(ids)
		if self._name == 'group13' or self._name == 'group14' then
			ids = {}
		elseif self._name == 'group15' then
			ids[142963] = nil
			ids[142964] = nil
			ids[142965] = nil
			ids[142966] = nil
			ids[703387] = nil
			ids[703388] = nil
		end

		local itr_ids = _itr_portal_ids[self._name]
		if itr_ids then
			for _, id in ipairs(itr_ids) do
				ids[id] = true
			end
		end

		itr_original_portalunitgroup_setids(self, ids)
	end

	local itr_original_portalunitgroup_addshape = PortalUnitGroup.add_shape
	function PortalUnitGroup:add_shape(params)
		if self._name == 'group3' then
			params.height = params.height + 300
		end

		return itr_original_portalunitgroup_addshape(self, params)
	end

end
