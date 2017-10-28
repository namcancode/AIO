local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local kpr_original_navigationmanager_registercoverunits = NavigationManager.register_cover_units
function NavigationManager:register_cover_units()
	local _debug = self._debug
	self._debug = true
	kpr_original_navigationmanager_registercoverunits(self)
	Keepers._covers = self._covers
	self._debug = _debug
end
