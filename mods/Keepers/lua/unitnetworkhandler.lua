local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local kpr_original_unitnetworkhandler_markminion = UnitNetworkHandler.mark_minion
function UnitNetworkHandler:mark_minion(unit, minion_owner_peer_id, convert_enemies_health_multiplier_level, passive_convert_enemies_health_multiplier_level, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character_and_sender(unit, sender) then
		return
	end

	unit:base().kpr_minion_owner_peer_id = minion_owner_peer_id
	kpr_original_unitnetworkhandler_markminion(self, unit, minion_owner_peer_id, convert_enemies_health_multiplier_level, passive_convert_enemies_health_multiplier_level, sender)
	Keepers:SetJokerLabel(unit)
end

local kpr_original_unitnetworkhandler_hostagetrade = UnitNetworkHandler.hostage_trade
function UnitNetworkHandler:hostage_trade(unit, enable, trade_success)
	Keepers:DestroyLabel(unit)
	kpr_original_unitnetworkhandler_hostagetrade(self, unit, enable, trade_success)
end
