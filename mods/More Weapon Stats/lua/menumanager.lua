_G.MoreWeaponStats = _G.MoreWeaponStats or {}
MoreWeaponStats._path = ModPath
MoreWeaponStats._data_path = SavePath .. 'more_weapon_stats.txt'
MoreWeaponStats.settings = {
	show_dlc_info = true,
	show_spread_and_recoil = true,
	last_used_difficulty = 'overkill_290',
	fill_breakpoints = true,
	use_preview_to_switch_breakpoints = true
}

function MoreWeaponStats:Load()
	local file = io.open(self._data_path, 'r')
	if file then
		for k, v in pairs(json.decode(file:read('*all')) or {}) do
			self.settings[k] = v
		end
		file:close()
	end
end

function MoreWeaponStats:Save()
	local file = io.open(self._data_path, 'w+')
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

Hooks:Add('LocalizationManagerPostInit', 'LocalizationManagerPostInit_MoreWeaponStats', function(loc)
	for _, filename in pairs(file.GetFiles(MoreWeaponStats._path .. 'loc/')) do
		local str = filename:match('^(.*).txt$')
		if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
			loc:load_localization_file(MoreWeaponStats._path .. 'loc/' .. filename)
			break
		end
	end
	
	loc:load_localization_file(MoreWeaponStats._path .. 'loc/english.txt', false)
end)

Hooks:Add('MenuManagerInitialize', 'MenuManagerInitialize_MoreWeaponStats', function(menu_manager)

	MenuCallbackHandler.MoreWeaponStatsShowDLCInfo = function(this, item)
		MoreWeaponStats.settings.show_dlc_info = item:value() == 'on'
	end

	MenuCallbackHandler.MoreWeaponStatsShowSpreadAndRecoil = function(this, item)
		MoreWeaponStats.settings.show_spread_and_recoil = item:value() == 'on'
	end
	
	MenuCallbackHandler.MoreWeaponStatsFillBreakpoints = function(this, item)
		MoreWeaponStats.settings.fill_breakpoints = item:value() == 'on'
	end

	MenuCallbackHandler.MoreWeaponStatsUsePreviewForBreakpoints = function(this, item)
		MoreWeaponStats.settings.use_preview_to_switch_breakpoints = item:value() == 'on'
	end

	MenuCallbackHandler.MoreWeaponStatsSave = function(this, item)
		MoreWeaponStats:Save()
	end

	MoreWeaponStats:Load()

	MenuHelper:LoadFromJsonFile(MoreWeaponStats._path .. 'menu/options.txt', MoreWeaponStats, MoreWeaponStats.settings)

end)
