local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

function ElementSpawnEnemyDummy:unspawn_all_units()
	for _, unit in pairs(self._units) do
		if alive(unit) then
			local brain = unit:brain()
			if brain._logic_data and not brain._logic_data.is_converted then
				unit:brain():set_active(false)
				unit:base():set_slot(unit, 0)
			end
		end
	end
end
