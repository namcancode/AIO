
--[[
	We setup the global table for our mod, along with some path variables, and a data table.
	We cache the ModPath directory, so that when our hooks are called, we aren't using the ModPath from a
		different mod.
]]
betterCrNt = betterCrNt or {}
betterCrNt._path = ModPath
betterCrNt.options_path = SavePath .. "betterCrNt.txt"
betterCrNt.options = {} 

--[[
	A simple save function that json encodes our options table and saves it to a file.
]]
function betterCrNt:Save()
	local file = io.open( self.options_path, "w+" )
	if file then
		file:write( json.encode( self.options ) )
		file:close()
	end
end

--[[
	A simple load function that decodes the saved json options table if it exists.
]]
function betterCrNt:Load()
	local file = io.open( self.options_path, "r" )
	if file then
		self.options = json.decode( file:read("*all") )
		file:close()
	else
	log("No previous save found. Creating new using default values")
	local default_file = io.open(self._path .."default_values.txt")
		if default_file then
			self.options = json.decode( default_file:read("*all") )
			self:Save()
		end
	end
end

if not betterCrNt.setup then
	betterCrNt:Load()
	betterCrNt.setup = true
	log("Menu Restore loaded")
end

if RequiredScript == "lib/tweak_data/guitweakdata" then
	
	local guicnet = GuiTweakData.init

	function GuiTweakData:init()
		guicnet(self)
		
		if betterCrNt.options.crimenet_cleanup_comp then
		self.crime_net.special_contracts = {
		{
			id = "gage_assignment",
			name_id = "menu_cn_gage_assignment",
			desc_id = "menu_cn_gage_assignment_desc",
			menu_node = "crimenet_gage_assignment",
			x = 590,
			y = 85,
			icon = "guis/textures/pd2/crimenet_marker_gage",
			dlc = "gage_pack_jobs"
		},
		{
			id = "premium_buy",
			name_id = "menu_cn_premium_buy",
			desc_id = "menu_cn_premium_buy_desc",
			menu_node = "crimenet_contract_special",
			x = 920,
			y = 970,
			icon = "guis/textures/pd2/crimenet_marker_buy"
		},
		{
			id = "contact_info",
			name_id = "menu_cn_contact_info",
			desc_id = "menu_cn_contact_info_desc",
			menu_node = "crimenet_contact_info",
			x = 680,
			y = 920,
			icon = "guis/textures/pd2/crimenet_marker_codex"
		},
		{
			id = "challenge",
			name_id = "menu_cn_challenge",
			desc_id = "menu_cn_challenge_desc",
			menu_node = "crimenet_contract_challenge",
			x = 1000,
			y = 85,
			icon = "guis/textures/pd2/crimenet_challenge"
		},
		{
			id = "casino",
			name_id = "menu_cn_casino",
			desc_id = "menu_cn_casino_desc",
			menu_node = "crimenet_contract_casino",
			x = 680,
			y = 970,
			icon = "guis/textures/pd2/crimenet_casino",
			unlock = "unlock_level",
			pulse = false, -- true / false
			pulse_color = Color(204, 255, 209, 32) / 255
		},
		{
			id = "short",
			name_id = "menu_cn_short",
			desc_id = "menu_cn_short_desc",
			menu_node = "crimenet_contract_short",
			x = 695,
			y = 85,
			icon = "guis/textures/pd2/crimenet_tutorial",
			pulse = true,
			pulse_level = 10,
			pulse_color = Color(204, 255, 209, 32) / 255
 		},
		{
			id = "mutators",
			name_id = "menu_mutators",
			desc_id = "menu_mutators_help",
			menu_node = "mutators",
			x = 1130,
			y = 920,
			icon = "guis/textures/pd2/crimenet_marker_mutators",
			pulse = true,
			pulse_level = 10,
			pulse_color = Color(255, 255, 0, 255) / 255, 
			mutators_color = Color(255, 255, 0, 255) / 255
 		},
		{
			id = "crime_spree",
			name_id = "cn_crime_spree",
			desc_id = "cn_crime_spree_help_start",
			menu_node = "crimenet_crime_spree_contract_host",
			mp_only = true,
			x = 1130,
			y = 970,
			icon = "guis/textures/pd2/crimenet_marker_crimespree",
			pulse = true,
			pulse_level = 10,
			pulse_color = Color(255, 255, 255, 0) / 255
		},
		{
			id = "crime_spree",
			name_id = "cn_crime_spree",
			desc_id = "cn_crime_spree_help_start",
			menu_node = "crimenet_crime_spree_contract_singleplayer",
			sp_only = true,
			x = 1130,
			y = 970,
			icon = "guis/textures/pd2/crimenet_marker_crimespree",
			pulse = true,
			pulse_level = 10,
			pulse_color = Color(255, 255, 255, 0) / 255
		}
	}
	end
		--[[	table.insert(self.crime_net.special_contracts,{
			id = "casino",
			name_id = "menu_cn_casino",
			desc_id = "menu_cn_casino_desc",
			menu_node = "crimenet_contract_casino",
			x = 680,
			y = 970,
			icon = "guis/textures/pd2/crimenet_casino",
			unlock = "unlock_level",
			pulse = false, -- true / false
			pulse_color = Color(204, 255, 209, 32) / 255
 		}) ]]
	end

end

if RequiredScript == "lib/managers/customsafehousemanager" then

	local spawn_safehouse_combat_contract_ori = CustomSafehouseManager.spawn_safehouse_combat_contract
	local spawn_safehouse_contract_ori = CustomSafehouseManager.spawn_safehouse_contract
	
	

	function CustomSafehouseManager:spawn_safehouse_combat_contract()
	
	if betterCrNt.options.crimenet_cleanup_comp then
	
		if self._has_spawned_safehouse_contract or not self._global._has_entered_safehouse then
			return
		end
	
	local contract_data = {
		id = "safehouse_combat",
		name_id = "menu_cn_chill_combat",
		desc_id = "menu_cn_chill_combat_desc",
		menu_node = "crimenet_contract_chill",
		x = 920,
		y = 920,
		icon = "guis/dlcs/chill/textures/pd2/safehouse/crimenet_marker_safehouse",
		pulse = true,
		pulse_color = Color(204, 255, 32, 32) / 255
		}
		if managers.menu_component._crimenet_gui then
			managers.menu_component:post_event("pln_sfr_cnc_01_01")
			managers.menu_component._crimenet_gui:add_special_contract(contract_data)
			managers.menu_component._crimenet_gui:remove_job("safehouse", true)
			self._has_spawned_safehouse_contract = true
		end
	end
	end

	function CustomSafehouseManager:spawn_safehouse_contract()
	
	if betterCrNt.options.crimenet_cleanup_comp then
	
		if self._has_spawned_safehouse_contract or managers.menu_component._crimenet_gui and managers.menu_component._crimenet_gui:does_job_exist("safehouse") then
			return
		end
		local contract_data = {
		id = "safehouse",
		name_id = "menu_cn_chill",
		desc_id = "menu_cn_chill_desc",
		menu_node = "custom_safehouse",
		x = 920,
		y = 920,
		icon = "guis/dlcs/chill/textures/pd2/safehouse/crimenet_marker_safehouse",
		pulse = true,
		pulse_level = 10,
		pulse_color = Color(204, 255, 209, 32) / 255
		}
		if managers.menu_component._crimenet_gui then
			managers.menu_component._crimenet_gui:remove_job("safehouse_combat", true)
			managers.menu_component._crimenet_gui:add_special_contract(contract_data)
		end
	end
	end
	
end
--[[
local modify_filter_node_actual = MenuCrimeNetFiltersInitiator.modify_node
local clbk_choice_difficulty_filter = MenuCallbackHandler.choice_difficulty_filter
local server_count = {10, 20, 30, 40, 50, 60, 70}
local difficulties = {"menu_all", "menu_difficulty_normal", "menu_difficulty_hard", "menu_difficulty_very_hard", "menu_difficulty_overkill", "menu_difficulty_easy_wish", "menu_difficulty_apocalypse", "menu_difficulty_sm_wish", "menu_difficulty_hard", "menu_difficulty_very_hard", "menu_difficulty_overkill", "menu_difficulty_easy_wish", "menu_difficulty_apocalypse"}

function MenuCrimeNetFiltersInitiator:modify_node(original_node, ...)
	local res = modify_filter_node_actual(self, original_node, ...)
	if server_count ~= nil then
		local max_lobbies = original_node:item("max_lobbies_filter")
		if max_lobbies ~= nil then
			max_lobbies:clear_options()
			for __, count in ipairs(server_count) do
				max_lobbies:add_option(CoreMenuItemOption.ItemOption:new({
					_meta = "option",
					text_id = tostring(count),
					value = count,
					localize = false
				}))
			end
			max_lobbies:_show_options(nil)
		end
	end
	if difficulties ~= nil then
		local diff_filter = original_node:item("difficulty_filter")
		if diff_filter ~= nil then
			diff_filter:clear_options()
			for k, v in ipairs(difficulties) do
				diff_filter:add_option(CoreMenuItemOption.ItemOption:new({
					_meta = "option",
					text_id = managers.localization:text(v) .. (k > 8 and " +" or ""),
					value = k,
					localize = false
				}))
			end
			diff_filter:_show_options(nil)
			local matchmake_filters = managers.network.matchmake:lobby_filters()
			if matchmake_filters and matchmake_filters.difficulty then 
				diff_filter:set_value(matchmake_filters.difficulty.value + (matchmake_filters.difficulty.comparision_type == "equal" and 0 or 4))
			end
		end
	end
	return res
end

function MenuCallbackHandler:choice_difficulty_filter(item)
	local diff_filter = item:value()
	clbk_choice_difficulty_filter(self, item)
	local comp = "equal"
	if diff_filter > 8 then
		comp = "equalto_or_greater_than"
		diff_filter = diff_filter - 4
	elseif diff_filter <= 1 then
		diff_filter = -1
	end
	managers.network.matchmake:add_lobby_filter("difficulty", diff_filter, comp)
end
]]
--[[
	Load our localization keys for our menu, and menu items.
]]
Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_betterCrNt", function( loc )
	loc:load_localization_file( betterCrNt._path .. "Loc/english.txt")
end)

--[[
	Setup our menu callbacks, load our saved data, and build the menu from our json file.
]]
Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_betterCrNt", function( menu_manager )

	--[[
		Setup our callbacks as defined in our item callback keys, and perform our logic on the data retrieved.
	]]

	MenuCallbackHandler.callback_crnt_sort = function(self, item)
		betterCrNt.options.crnt_sort = (item:value() =="on")
		betterCrNt:Save()
	end
	
	MenuCallbackHandler.callback_crnt_align = function(self, item)
		betterCrNt.options.crnt_align = (item:value() =="on")
		betterCrNt:Save()
	end
	
	MenuCallbackHandler.callback_crnt_colorize = function(self, item)
		betterCrNt.options.crnt_colorize = (item:value() =="on")
		betterCrNt:Save()
	end
	
	MenuCallbackHandler.callback_crnt_size = function(self, item)
		betterCrNt.options.crnt_size = item:value()
		betterCrNt:Save()
	end
	
	MenuCallbackHandler.callback_crimenet_cleanup_comp = function(self, item)
		betterCrNt.options.crimenet_cleanup_comp = (item:value() =="on")
		betterCrNt:Save()
	end

	--[[
		Load our previously saved data from our save file.
	]]
	betterCrNt:Load()

	--[[
		Load our menu json file and pass it to our MenuHelper so that it can build our in-game menu for us.
		We pass our parent mod table as the second argument so that any keybind functions can be found and called
			as necessary.
		We also pass our data table as the third argument so that our saved values can be loaded from it.
	]]
	MenuHelper:LoadFromJsonFile( betterCrNt._path .. "Menu/menu.txt", betterCrNt, betterCrNt.options )

end )
