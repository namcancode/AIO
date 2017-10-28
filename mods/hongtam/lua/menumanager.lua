
if not _G.R9K then
	dofile(ModPath .. "lua/_reticle9k.lua")
end

Hooks:Add("LocalizationManagerPostInit", "R9K_LocalizationManagerPostInit", function(localization_manager)

	R9K:LoadLocalization()

end)

Hooks:Add("MenuManagerInitialize", "R9K_MenuManagerInitialize", function(menu_manager)

	R9K.KeybindQuickEditLeft = function(self)
		R9K:HandleQuickEditAction("left")
	end	

	R9K.KeybindQuickEditRight = function(self)
		R9K:HandleQuickEditAction("right")
	end

	MenuHelper:LoadFromJsonFile(R9K.menu_configuration_file, R9K, {})

end)
