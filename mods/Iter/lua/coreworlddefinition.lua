local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

core:module('CoreWorldDefinition')

local level_id = Global.game_settings and Global.game_settings.level_id or ''
level_id = level_id:gsub('_night$', ''):gsub('_day$', '')

if not _G.Iter.settings['map_change_' .. level_id] then

elseif level_id == 'chill_combat' then

	local itr_original_worlddefinition_serializetoscript = WorldDefinition._serialize_to_script
	function WorldDefinition:_serialize_to_script(...)
		local result = itr_original_worlddefinition_serializetoscript(self, ...)

		local instances = result.instances
		if instances then
			for i = #instances, 1, -1 do
				local instance = instances[i]
				if _G.Iter.delete_instances[instance.name] then
					table.remove(instances, i)
				end
			end
		end

		return result
	end

	local _spare_units = {
		['units/pd2_dlc_chill/props/chl_prop_jimmy_barstool/chl_prop_jimmy_barstool_v2'] = true,
		['units/pd2_dlc_chill/props/chl_props_trophy_shelf/chl_props_trophy_shelf'] = true,
		['units/pd2_dlc_friend/props/sfm_prop_office_door_whole_black/sfm_prop_office_door_whole_black'] = true,
		['units/pd2_dlc_chill/props/chl_prop_livingroom_coffeetable_b/chl_prop_livingroom_coffeetable_b'] = true,
	}

	local function _is_ok(name, pos)
		local x, y, z = pos.x, pos.y, pos.z
		if name == 'units/dev_tools/level_tools/shadow_caster_10x10' and x - 524.999 < 0.01 and y == 2025 and z == -25 then
			-- otherwise light near Sydney's place
		elseif name == 'units/payday2/architecture/ind/ind_ext_level/ind_ext_fence_pole_2m_grey' and x == -392 and y == -386 and z == -45 then
			-- qued
		elseif not _spare_units[name] then
			if z < -10 then
				if x > 200 and x < 825 and y >= -1500 and y < -1000 then
					-- stairs to lower levels
				elseif x > 230 and x < 1600 and y > -864 and y < 0 then
					-- vault visible through floor window
				else
					return false
				end
			elseif x > 825 and x < 1202 and y > 427 and y < 775 and z > -4 and z < 291 then
				-- bathroom
				return false
			elseif x > 815 and x < 1200 and y > 1220 and y < 1575 and z > 380 and z < 689 then
				-- bathroom
				return false
			elseif x > 1200 and y > 800 then
				return false
			end
		end
		return true
	end

	function WorldDefinition:create_delayed_unit(new_unit_id)
		local spawn_data = self._delayed_units[new_unit_id]
		if spawn_data then
			local unit_data = spawn_data[1]
			if not unit_data.position or _is_ok(unit_data.name, unit_data.position) then
				PackageManager:load_delayed("unit", unit_data.name)
				self:preload_unit(unit_data.name)
				local unit = self:make_unit(unit_data, spawn_data[2])
				if unit then
					unit:set_spawn_delayed(true)
					table.insert(spawn_data[3], unit)
				end
			end
		end
	end

	function WorldDefinition:_create_statics_unit(data, offset)
		local pos = data.unit_data.position
		if not pos or _is_ok(data.unit_data.name, pos) then
			self:preload_unit(data.unit_data.name)
			return self:make_unit(data.unit_data, offset)
		end
	end

end
