
if not _G.R9K then
	dofile(ModPath .. "lua/_reticle9k.lua")
end

Hooks:PostHook(PlayerStandard, "_start_action_steelsight", "R9K_PlayerStandard_start_action_steelsight", function(self, t, gadget_state)

	R9K:SetWeaponPositionAim()
	
end )

Hooks:PostHook(PlayerStandard, "_end_action_steelsight", "R9K_PlayerStandard_end_action_steelsight", function(self, t)

	R9K:SetWeaponPositionHip()
	
end )
