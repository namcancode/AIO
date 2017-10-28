
if not _G.R9K then
	dofile(ModPath .. "lua/_reticle9k.lua")
end

Hooks:PostHook(HUDManager, "_player_hud_layout", "R9K_HUDManager_player_hud_layout", function()

	R9K:UpdateCrosshair()
	
end )

Hooks:PostHook(HUDManager, "_set_weapon_selected", "R9K_HUDManager_set_weapon_selected", function(self, id)

	if id == 1 then
		R9K:SetWeaponSecondary()
	else
		R9K:SetWeaponPrimary()
	end
	
end )
