_G.ForceReady = _G.ForceReady or {}
ForceReady._path = ModPath
ForceReady._data_path = SavePath .. "forceready.txt"
ForceReady.settings = {
	chatmode = 3
}

function ForceReady:Load()
	local file = io.open(self._data_path, "r")
	if file then
		for k, v in pairs(json.decode(file:read("*all"))) do
			self.settings[k] = v
		end
		file:close()
	end
end

function ForceReady:Save()
	local file = io.open(self._data_path, "w+")
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_ForceReady", function(loc)
	for _, filename in pairs(file.GetFiles(ForceReady._path.. "loc/")) do
		local str = filename:match('^(.*).txt$')
		if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
			loc:load_localization_file(ForceReady._path.. "loc/" .. filename)
			break
		end
	end

	loc:load_localization_file(ForceReady._path .. "loc/english.txt", false)
end)

Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_ForceReady", function(menu_manager)
	function MenuCallbackHandler.fr_chatmode_callback(this, item)
		ForceReady.settings.fr_chatmode = item._current_index
	end
	function MenuCallbackHandler.fr_options_save(this, item)
		ForceReady:Save()
	end

	ForceReady:Load()
	MenuHelper:LoadFromJsonFile(ForceReady._path .. "menu/options.txt", ForceReady, ForceReady.settings)
end)

