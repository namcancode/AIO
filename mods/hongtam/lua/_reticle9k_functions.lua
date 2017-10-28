

-- ---[ default settings ]--------------------------------------------------------- --

function R9K:CreateDefaultCrosshair(type_index, color_index)
	local crosshair_configuration = {}
	crosshair_configuration.display =		true
	crosshair_configuration.type_index =	type_index
	crosshair_configuration.color_index =	color_index
	crosshair_configuration.size =			50
	crosshair_configuration.saturation =	1
	crosshair_configuration.opacity =		100
	return crosshair_configuration
end

function R9K:SetDefaultSettings()

	R9K.settings = {}
	
	R9K.settings.version = R9K.version
	
	R9K.settings.crosshair = {}
	
	R9K.settings.crosshair.primary = {}
	R9K.settings.crosshair.secondary = {}	
	
	-- initialize with some differens attributes to make it easier for newcommers to understand the context concept, maybe?
	
	R9K.settings.crosshair.primary.hip = R9K:CreateDefaultCrosshair(6, 2)
	R9K.settings.crosshair.primary.aim = R9K:CreateDefaultCrosshair(10, 3)
	
	R9K.settings.crosshair.secondary.hip = R9K:CreateDefaultCrosshair(4, 1)
	R9K.settings.crosshair.secondary.aim = R9K:CreateDefaultCrosshair(11, 4)

end


-- ---[ i/o related ]-------------------------------------------------------------- --

function R9K:SaveJSON(name, object_to_save)
	local file_path = R9K.save_path .. name .. ".json"
	local file = io.open(file_path, "w+")
	if file then
		file:write(json.encode(object_to_save))
		file:close()
	end
end

function R9K:LoadJSON(name)
	local file_path = R9K.save_path .. name .. ".json"
	local file = io.open(file_path, "r")
	if file then
		local jsonObject = json.decode(file:read("*all"))
		file:close()
		return jsonObject
	end
	return nil
end

function R9K:SaveSettings()
	R9K:SaveJSON("settings", R9K.settings)
end

function R9K:LoadSettings()
	local settings = R9K:LoadJSON("settings")
	if settings then
		if settings.version then
			if settings.version == R9K.version then
				R9K.settings = settings
			end
		end
	end
end

function R9K:LoadState()
	R9K.state = R9K:LoadJSON("state")
	if not R9K.state then
		R9K.state = {}
		R9K.state.announce_list = {}
	end
end

function R9K:SaveState()
	R9K:SaveJSON("state", R9K.state)
end


-- ---[ translation ]-------------------------------------------------------------- --

function R9K:LoadLocalization()

	local localization_file = R9K.localization_default_file

	local localization_files = file.GetFiles(R9K.localization_path) 
	local system_language_key = SystemInfo:language():key()

	for i, filename in pairs(localization_files) do
		local this_language = filename:match("^(.*).txt$")
		local this_language_key = Idstring(this_language):key()
		if this_language_key == system_language_key then
			localization_file = R9K.localization_path .. filename
			break
		end
	end
	
	LocalizationManager:load_localization_file(localization_file)
	
end


-- ---[ data resolving helpers ]--------------------------------------------------- --

function R9K:GetReticleColor(color_index)
	return R9K.reticle_texture_colors[color_index].color
end

function R9K:GetReticleColorName(color_index)
	return managers.localization:text(R9K.reticle_texture_colors[color_index].id_loc_name)
end

function R9K:GetReticleTexture(reticle_index, reticle_color_index)
	local color_postfix = R9K.reticle_texture_colors[reticle_color_index].texture_postfix
	return R9K.reticle_textures[reticle_index].uri .. color_postfix
end

function R9K:GetReticleTextureId(reticle_index)
	return R9K.reticle_textures[reticle_index].id
end

function R9K:GeteQuickEditLabel(quick_edit_mode_index)
	local quick_edit_mode = R9K.quick_edit_modes[quick_edit_mode_index]
	return managers.localization:text(quick_edit_mode.id_loc_mode)
end


-- ---[ misc ]--------------------------------------------------------------------- --

function R9K:GetNumericUID()
	R9K.uid = R9K.uid + 1 
	return R9K.uid
end

function R9K:GetStringUID()
	return tostring(R9K:GetNumericUID())
end

function R9K:GetArraySize(the_array)
	local size = 0
	if the_array then 
		for index, value in pairs(the_array) do
			size = size + 1
		end
	end
	return size
end

function R9K:IsEmptyString(value)
	value = tostring(value)
	return value == nil or value == ''
end

function R9K:InList(values, value)
	for _, aValue in pairs(values) do
		if aValue == value then
			return true
		end
	end
	return false
end

function R9K:GetPeer(peer_id)
	return managers.network:session():peer(peer_id)
end

function R9K:GetPeerName(peer_id, default_name)
	local peer = R9K:GetPeer(peer_id)
	if peer and peer:name() then
		local name = peer:name()
		if not R9K:IsEmptyString(name) then
			return tostring(name)
		end
	end
	return default_name
end

function R9K:GetTextPanelMaxHeight(text_panel_a, text_panel_b)
	local _, hight_a, hight_b
	_,_,_,hight_a = text_panel_a:text_rect()
	_,_,_,hight_b = text_panel_b:text_rect()
	return math.max(hight_a, hight_b)
end


-- ---[ messaging ]---------------------------------------------------------------- --

-- display a system message in chat, this message will only be visible to you.
function R9K:SystemMessage(message)
	if not managers or not managers.chat or not message then
		return
	end
	local username = managers.localization:to_upper_text("menu_system_message")
	managers.chat:_receive_message(1, username, message, tweak_data.system_chat_color)
end

-- send a message to other player, this message will only be visible to the other player.
function R9K:SendMessage(peer_id, message)
	if not managers or not managers.chat or not peer_id or not message then
		return
	end
	local peer = R9K:GetPeer(peer_id)
	if not peer then return end
	
	peer:send("send_chat_message", ChatManager.GAME, message)

end

-- display a message in middle of screen, this message is only visible to you.
function R9K:DisplayHint(message, duration)
	if not managers or not managers.hud or not message then
		return
	end
	if not duration then
		duration = 3
	end
	local hint = {
		text = tostring(message),
		time = tonumber(duration)
	}
	managers.hud:show_hint(hint)
end


-- ---[ gui utilities ]------------------------------------------------------------ --

function R9K:GetHudPanel()
	return managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2).panel
end

function R9K:CreatePanel(panel, name, layer)
	local panel_data = {
		name = name,
		layer = layer
	}
	return panel:panel(panel_data)
end

function R9K:CreateRect(panel, name, layer, color, alpha)
	local rect_data = {
		name = name,
		layer = layer,
		visible = true,
		color = color,
		alpha = alpha
	}
	return panel:rect(rect_data)
end

function R9K:CreateText(panel, layer, font, font_size, color, text, align, halign, valign)
	local panel_data = {
		name = "r9k_text_" .. R9K:GetStringUID(),
		layer = layer,
		font = font,
		font_size = font_size,
		color = color,
		text = text,
		wrap = false,
		word_wrap = false,
		align = align,
		halign = halign,
		valign = valign 
	}
	return panel:text(panel_data)
end


-- ---[ crosshair rendering ]------------------------------------------------------ --

function R9K:CreateCrosshairPanelBitmap(panel, name, texture, size, color)
	local bitmap = panel:bitmap({
		name			= name,
		texture 		= texture,
		w 				= size,
		h 				= size,
		color			= color,
		blend_mode		= "add",
		layer 			= 0
	})
	bitmap:set_center(panel:center())
end

function R9K:RenderCrosshair(crosshair_settings)

	if not HUDManager then
		return
	end
	
	local texture = R9K:GetReticleTexture(crosshair_settings.type_index, crosshair_settings.color_index)
	local color = R9K:GetReticleColor(crosshair_settings.color_index)
	
	local hud_panel = R9K:GetHudPanel()
	
	R9K.crosshair_panel = hud_panel:panel({
		name	= "crosshair_panel",
		halign	= "grow",
		valign	= "grow"
	})
	
	if crosshair_settings.opacity ~= 100 then
		local alpha = crosshair_settings.opacity / 100
		if alpha < 0.01 then
			alpha = 0.01
		end
		if alpha < 1 then
			R9K.crosshair_panel:set_alpha(alpha)
		end
	end
	
	for i = 0, crosshair_settings.saturation, 1 do
		R9K:CreateCrosshairPanelBitmap(R9K.crosshair_panel, "reticle" .. tostring(i) , texture, crosshair_settings.size, color)
	end

end

function R9K:RemoveCrosshair()
	if R9K.crosshair_panel then
		local hud_panel = R9K:GetHudPanel()
		hud_panel:remove(R9K.crosshair_panel)
		R9K.crosshair_panel = nil
	end
end

function R9K:UpdateCrosshair()
	if R9K.crosshair_panel then
		R9K:RemoveCrosshair()
	end
	
	local crosshair_settings
	
	if R9K.quick_edit_panel ~= nil then
		crosshair_settings = R9K:GetCrosshairSettingsMenu()
	else
		crosshair_settings = R9K:GetCrosshairSettingsGame()
	end
	
	if crosshair_settings.display == true then
		R9K:RenderCrosshair(crosshair_settings)
	end
end


-- ---[ crosshair state changes ]-------------------------------------------------- --

function R9K:SetWeaponPrimary()
	R9K.game_weapon = R9K.WEAPON_PRIMARY
	R9K:UpdateCrosshair()
end

function R9K:SetWeaponSecondary()
	R9K.game_weapon = R9K.WEAPON_SECONDARY
	R9K:UpdateCrosshair()
end

function R9K:SetWeaponPositionHip()
	if R9K.game_weapon_position == R9K.WEAPON_POSITION_AIM then
		R9K.game_weapon_position = R9K.WEAPON_POSITION_HIP
		R9K:UpdateCrosshair()
	end
end

function R9K:SetWeaponPositionAim()
	if R9K.game_weapon_position == R9K.WEAPON_POSITION_HIP then
		R9K.game_weapon_position = R9K.WEAPON_POSITION_AIM
		R9K:UpdateCrosshair()
	end
end


-- ---[ quick edit menu rendering ]------------------------------------------------ --

function R9K:RenderQuickEditMenu()

	if not HUDManager then
		return
	end
	
	DelayedCallsFix:Remove(R9K.delayed_remove_quick_edit_menu_id)
	
	R9K:RemoveQuickEditMenu()
	
	local menu = R9K:BuildQuickEditMenuConfig()
	
	-- add structure elements

	local layer = tweak_data.gui.DIALOG_LAYER + 100
	
	local qe_panel = R9K:CreatePanel(R9K:GetHudPanel(), "qe_panel", layer)
		R9K.quick_edit_panel = qe_panel
		layer = layer + 10
	local qe_container_panel = R9K:CreatePanel(qe_panel, "qe_container_panel", layer)
		layer = layer + 10
	local qe_background_rect = R9K:CreateRect(qe_container_panel, "qe_background_rect", layer, menu.background.color, menu.background.alpha)
		layer = layer + 10
	local qe_padding_panel = R9K:CreatePanel(qe_container_panel, "qe_padding_panel", layer)
		layer = layer + 10
	
	
	-- add the contents
	
	-- add header
	menu.header.panel = R9K:CreateText(qe_padding_panel, layer, menu.header.font, menu.header.size, menu.header.color, menu.header.text, "center", "grow", "grow")
	-- add author
	menu.author.panel = R9K:CreateText(qe_padding_panel, layer, menu.author.font, menu.author.size, menu.author.color, menu.author.text, "center", "grow", "grow")
	-- add line
	menu.line.panel_1 = R9K:CreateText(qe_padding_panel, layer, menu.line.font, menu.line.size, menu.line.color, menu.line.text, "center", "grow", "grow")
	-- add all the settings
	for i, menu_item in ipairs(menu.items) do
		menu.items[i].label_panel = R9K:CreateText(qe_padding_panel, layer, menu.item.label.font, menu.item.label.size, menu.item.label.color, menu_item.label, "left", "grow", "grow")
		menu.items[i].value_panel = R9K:CreateText(qe_padding_panel, layer, menu.item.value.font, menu.item.value.size, menu.item.value.color, menu_item.value, "right", "grow", "grow")
	end
	-- add line
	menu.line.panel_2 = R9K:CreateText(qe_padding_panel, layer, menu.line.font, menu.line.size, menu.line.color, menu.line.text, "center", "grow", "grow")
	-- add footer
	menu.footer.panel = R9K:CreateText(qe_padding_panel, layer, menu.footer.font, menu.footer.size, menu.footer.color, menu.footer.text, "center", "grow", "grow")

	
	-- layout content items to get total inner width and height
	
	local top
	local _left, _top, _width, _height
	
	_left, _top, _width, _height = menu.header.panel:text_rect()
	top = _top + _height
	
	menu.author.panel:set_top(top)
	_left, _top, _width, _height = menu.author.panel:text_rect()
	top = _top + _height
	
	menu.line.panel_1:set_top(top)
	_left, _top, _width, _height = menu.line.panel_1:text_rect()
	top = _top + _height
	
	for i, menu_item in ipairs(menu.items) do
	
		-- layout the label
		menu_item.label_panel:set_top(top)
		
		-- layout the value
		menu_item.value_panel:set_top(top)
		menu_item.value_panel:set_align("right")
		menu_item.value_panel:set_halign("right")
		
		-- apply highlightning (for active item)
		if menu_item.highlight then
			menu_item.label_panel:set_color(menu.item.label.highlight.color)
			menu_item.value_panel:set_color(menu.item.value.highlight.color)
		end
		
		top = top + R9K:GetTextPanelMaxHeight(menu_item.label_panel, menu_item.value_panel)
	end

	menu.line.panel_2:set_top(top)
	_left, _top, _width, _height = menu.line.panel_2:text_rect()
	top = _top + _height
	
	menu.footer.panel:set_top(top)
	_left, _top, _width, _height = menu.footer.panel:text_rect()
	top = _top + _height
	
	
	-- layout/adjust size on background and padding 

	-- set width n height of qe_padding_panel
	qe_padding_panel:set_width(menu.width)
	qe_padding_panel:set_height(top)
	
	-- set width n height of qe_container_panel
	qe_container_panel:set_width(qe_padding_panel:width() + (menu.padding * 2))
	qe_container_panel:set_height(qe_padding_panel:height() + (menu.padding * 2))

	-- position the qe_container_panel
	local center_x = math.floor( qe_panel:width() * menu.center_x )
	local center_y = math.floor( qe_panel:height() * menu.center_y )
	qe_container_panel:set_center_x(center_x)
	qe_container_panel:set_center_y(center_y)

	-- apply padding to qe_padding_panel
	qe_padding_panel:set_left(menu.padding)
	qe_padding_panel:set_top(menu.padding)
	
	
	-- add a delayed call to close/remove the menu if user does not interact with it for a specific period of time
	R9K.delayed_remove_quick_edit_menu_id = "R9KDelayedRemoveQuickEditMenu_" .. R9K:GetStringUID()
	DelayedCallsFix:Add(R9K.delayed_remove_quick_edit_menu_id, R9K.quick_edit_timeout, function()
		R9K:RemoveQuickEditMenu()
		-- if the menu times out, reset navigation and random auther text
		R9K.quick_edit_mode = 1
		R9K:UpdateCrosshair()
	end)

end

function R9K:RemoveQuickEditMenu()
	if R9K.quick_edit_panel then
		R9K:GetHudPanel():remove(R9K.quick_edit_panel)
		R9K.quick_edit_panel = nil
	end
end

function R9K:BuildQuickEditMenuConfig()

	-- I'm sure all this menu/meta data and gui element handling can be done in a MUCH sexier way!
	-- However I'm old and lazy and have a life to live soo.. ..YOU fix it!

	local crosshair_settings = R9K:GetCrosshairSettingsMenu()
	
	local menu = {}
	
	menu.width = 155
	menu.padding = 15
	menu.center_x = 0.30
	menu.center_y = 0.50
	
	menu.background = {}
	menu.background.alpha = 0.8
	menu.background.color = Color(0,0,0)
	
	menu.header = {}
	menu.header.font = tweak_data.hud_present.title_font
	menu.header.size = math.floor(tweak_data.hud_present.title_size)
	menu.header.color = Color(0,1,0):with_alpha(1)
	menu.header.text = "r e t i c l e 9 k "
	
	menu.author = {}
	menu.author.font = tweak_data.hud_present.text_font
	menu.author.size = math.floor(tweak_data.hud_present.text_size/2)
	menu.author.color = Color(0.6,0.6,0.6):with_alpha(1)
	menu.author.text = R9K.authorTexts[R9K.quick_edit_mode]
	
	menu.line = {}
	menu.line.font = tweak_data.hud_present.title_font
	menu.line.size = math.floor(tweak_data.hud_present.title_size/1.25)
	menu.line.color = Color(0.5,0.5,0.5):with_alpha(0.75)
	menu.line.text = "- - - - - - - - - -"
	
	menu.footer = {}
	menu.footer.font = tweak_data.hud_present.text_font
	menu.footer.size = math.floor(tweak_data.hud_present.text_size/2)
	menu.footer.color = Color(0.5,0.5,0.5):with_alpha(1)
	local quick_edit_mode = R9K.quick_edit_modes[R9K.quick_edit_mode]
	menu.footer.text = managers.localization:text(quick_edit_mode.id_loc_mode_description)
	
	menu.item = {}
	
	menu.item.label = {}
	menu.item.label.font = tweak_data.hud_present.text_font
	menu.item.label.size = math.floor(tweak_data.hud_present.text_size/1.5)
	menu.item.label.color = Color(0.95,0.95,0.95):with_alpha(1)
	menu.item.label.highlight = {}
	menu.item.label.highlight.font = tweak_data.hud_present.text_font
	menu.item.label.highlight.size = math.floor(tweak_data.hud_present.text_size/1.5)
	menu.item.label.highlight.color = Color(0,1,0):with_alpha(1)
	
	menu.item.value = {}
	menu.item.value.font = tweak_data.hud_present.text_font
	menu.item.value.size = math.floor(tweak_data.hud_present.text_size/1.5)
	menu.item.value.color = Color(0.5,0.5,0.5):with_alpha(1) --Color(1,1,0):with_alpha(1)
	menu.item.value.highlight = {}
	menu.item.value.highlight.font = tweak_data.hud_present.text_font
	menu.item.value.highlight.size = math.floor(tweak_data.hud_present.text_size/1.5)
	menu.item.value.highlight.color = Color(0,1,0):with_alpha(1)
	
	
	-- add the menu items
	
	menu.items = {}
	local item
	local index = 0
	
	
	-- context
	index = index + 1
	item = {}
	item.name = R9K.quick_edit_modes[index].mode
	item.label = R9K:GeteQuickEditLabel(index)
	if R9K.quick_edit_context == 1 then
		item.value = managers.localization:text("r9k_id_loc_quick_edit_weapon_primary")
		item.value = item.value .. " " .. managers.localization:text("r9k_id_loc_quick_edit_weapon_position_hip")
	elseif R9K.quick_edit_context == 2 then
		item.value = managers.localization:text("r9k_id_loc_quick_edit_weapon_primary")
		item.value = item.value .. " " .. managers.localization:text("r9k_id_loc_quick_edit_weapon_position_aim")
	elseif R9K.quick_edit_context == 3 then
		item.value = managers.localization:text("r9k_id_loc_quick_edit_weapon_secondary")
		item.value = item.value .. " " .. managers.localization:text("r9k_id_loc_quick_edit_weapon_position_hip")
	elseif R9K.quick_edit_context == 4 then
		item.value = managers.localization:text("r9k_id_loc_quick_edit_weapon_secondary")
		item.value = item.value .. " " .. managers.localization:text("r9k_id_loc_quick_edit_weapon_position_aim")
	end
	menu.items[index] = item

	-- display
	index = index + 1
	item = {}
	item.name = R9K.quick_edit_modes[index].mode
	item.label = R9K:GeteQuickEditLabel(index)
	if crosshair_settings.display == true then
		item.value = managers.localization:text("r9k_id_loc_quick_edit_value_on")
	else
		item.value = managers.localization:text("r9k_id_loc_quick_edit_value_off")
	end
	menu.items[index] = item
	
	-- type
	index = index + 1
	item = {}
	item.name = R9K.quick_edit_modes[index].mode
	item.label = R9K:GeteQuickEditLabel(index)
	item.value = R9K:GetReticleTextureId(crosshair_settings.type_index)
	menu.items[index] = item
	
	-- size
	index = index + 1
	item = {}
	item.name = R9K.quick_edit_modes[index].mode
	item.label = R9K:GeteQuickEditLabel(index)
	item.value = tostring(crosshair_settings.size)
	menu.items[index] = item
	
	-- color
	index = index + 1
	item = {}
	item.name = R9K.quick_edit_modes[index].mode
	item.label = R9K:GeteQuickEditLabel(index)
	item.value = R9K:GetReticleColorName(crosshair_settings.color_index)
	menu.items[index] = item
	
	-- saturation
	index = index + 1
	item = {}
	item.name = R9K.quick_edit_modes[index].mode
	item.label = R9K:GeteQuickEditLabel(index)
	item.value = tostring(crosshair_settings.saturation)
	menu.items[index] = item
	
	-- opacity
	index = index + 1
	item = {}
	item.name = R9K.quick_edit_modes[index].mode
	item.label = R9K:GeteQuickEditLabel(index)
	item.value = tostring(crosshair_settings.opacity) 
	menu.items[index] = item
	
	-- settings
	index = index + 1
	item = {}
	item.name = R9K.quick_edit_modes[index].mode
	item.label = R9K:GeteQuickEditLabel(index)
	item.value = ""
	menu.items[index] = item
	
	-- readme
	index = index + 1
	item = {}
	item.name = R9K.quick_edit_modes[index].mode
	item.label = R9K:GeteQuickEditLabel(index)
	item.value = ""
	menu.items[index] = item
	
	
	-- find and set highlighted menu item also apply some additional formatting =]
	for i, menu_item in ipairs(menu.items) do
		if menu_item.name == R9K.quick_edit_modes[R9K.quick_edit_mode].mode then
			menu_item.highlight = true
			menu_item.label = "- " .. menu_item.label
			menu_item.value = menu_item.value .. "  "
		else
			menu_item.label = "  " .. menu_item.label
			menu_item.value = menu_item.value .. "  "
		end
	end

	return menu
	
end


-- ---[ quick edit menu functions ]------------------------------------------------ --

function R9K:HandleQuickEditAction(action)
	if Utils:IsInGameState() then
	
		if CoreInput.ctrl() or CoreInput.alt() or CoreInput.shift() then
		
			local is_ctrl = CoreInput.ctrl()
			local is_alt = CoreInput.alt()
			local is_shift = CoreInput.shift()
			
			local qe_mode = R9K.quick_edit_modes[R9K.quick_edit_mode].mode
				
			if  qe_mode == "context" then
				R9K:QuickEditActionContext(is_ctrl, is_alt, is_shift, action)
			elseif  qe_mode == "display" then
				R9K:QuickEditActionDisplay(is_ctrl, is_alt, is_shift, action)
			elseif qe_mode == "type" then
				R9K:QuickEditActionType(is_ctrl, is_alt, is_shift, action)
			elseif qe_mode == "size" then
				R9K:QuickEditActionSize(is_ctrl, is_alt, is_shift, action)
			elseif qe_mode == "color" then
				R9K:QuickEditActionColor(is_ctrl, is_alt, is_shift, action)
			elseif qe_mode == "saturation" then
				R9K:QuickEditActionSaturation(is_ctrl, is_alt, is_shift, action)
			elseif qe_mode == "opacity" then
				R9K:QuickEditActionOpaque(is_ctrl, is_alt, is_shift, action)
			elseif qe_mode == "settings" then
				R9K:QuickEditActionSettings(is_ctrl, is_alt, is_shift, action)
			elseif qe_mode == "readme" then
				R9K:QuickEditActionReadMe(is_ctrl, is_alt, is_shift, action)
			end
		
		else
			if R9K.quick_edit_panel then
				R9K:QuickEditActionNavigate(action)
			end
		end
		
		R9K:RenderQuickEditMenu()
		R9K:UpdateCrosshair()

	end
end

function R9K:QuickEditActionNavigate(action)
	if action == "left" then
		R9K.quick_edit_mode = R9K.quick_edit_mode - 1
		if R9K.quick_edit_mode < 1 then 
			R9K.quick_edit_mode = R9K:GetArraySize(R9K.quick_edit_modes)
		end
	else
		R9K.quick_edit_mode = R9K.quick_edit_mode + 1
		if R9K.quick_edit_mode > R9K:GetArraySize(R9K.quick_edit_modes) then 
			R9K.quick_edit_mode = 1
		end
	end
end

function R9K:QuickEditActionContext(is_ctrl, is_alt, is_shift, action)

	if action == "left" then
		R9K.quick_edit_context = R9K.quick_edit_context - 1
		if R9K.quick_edit_context < 1 then 
			R9K.quick_edit_context = 1
		end
	else
		R9K.quick_edit_context = R9K.quick_edit_context + 1
		if R9K.quick_edit_context > 4 then 
			R9K.quick_edit_context = 4
		end
	end
	
	if R9K.quick_edit_context == 1 then
		R9K.quick_edit_context_weapon = R9K.WEAPON_PRIMARY
		R9K.quick_edit_context_weapon_position = R9K.WEAPON_POSITION_HIP
		
	elseif R9K.quick_edit_context == 2 then
		R9K.quick_edit_context_weapon = R9K.WEAPON_PRIMARY
		R9K.quick_edit_context_weapon_position = R9K.WEAPON_POSITION_AIM
		
	elseif R9K.quick_edit_context == 3 then
		R9K.quick_edit_context_weapon =  R9K.WEAPON_SECONDARY
		R9K.quick_edit_context_weapon_position = R9K.WEAPON_POSITION_HIP
		
	elseif R9K.quick_edit_context == 4 then
		R9K.quick_edit_context_weapon =  R9K.WEAPON_SECONDARY
		R9K.quick_edit_context_weapon_position = R9K.WEAPON_POSITION_AIM
		
	end

end

function R9K:QuickEditActionDisplay(is_ctrl, is_alt, is_shift, action)
	local crosshair_settings = R9K:GetCrosshairSettingsMenu()
	if action == "left" then
		crosshair_settings.display = false
	else
		crosshair_settings.display = true
	end
end

function R9K:QuickEditActionType(is_ctrl, is_alt, is_shift, action)
	local crosshair_settings = R9K:GetCrosshairSettingsMenu()
	if action == "left" then
		crosshair_settings.type_index = crosshair_settings.type_index - 1
		if crosshair_settings.type_index < 1 then
			crosshair_settings.type_index = R9K:GetArraySize(R9K.reticle_textures)
		end
	else
		crosshair_settings.type_index = crosshair_settings.type_index + 1
		if crosshair_settings.type_index > R9K:GetArraySize(R9K.reticle_textures) then
			crosshair_settings.type_index = 1
		end
	end
end

function R9K:QuickEditActionSize(is_ctrl, is_alt, is_shift, action)
	local crosshair_settings = R9K:GetCrosshairSettingsMenu()
	local step_size = 1
	if is_alt then
		step_size = 50
	elseif is_shift then
		step_size = 25
	end
	if action == "left" then
		crosshair_settings.size = crosshair_settings.size - step_size
		if crosshair_settings.size < 1 then
			crosshair_settings.size = 1
		end
	else
		crosshair_settings.size = crosshair_settings.size + step_size
		if crosshair_settings.size > 800 then
			crosshair_settings.size = 800
		end
	end
end

function R9K:QuickEditActionColor(is_ctrl, is_alt, is_shift, action)
	local crosshair_settings = R9K:GetCrosshairSettingsMenu()
	if action == "left" then
		crosshair_settings.color_index = crosshair_settings.color_index - 1
		if crosshair_settings.color_index < 1 then
			crosshair_settings.color_index = 4
		end
	else
		crosshair_settings.color_index = crosshair_settings.color_index + 1
		if crosshair_settings.color_index > 4 then
			crosshair_settings.color_index = 1
		end
	end
end

function R9K:QuickEditActionSaturation(is_ctrl, is_alt, is_shift, action)
	local crosshair_settings = R9K:GetCrosshairSettingsMenu()
	if action == "left" then
		crosshair_settings.saturation = crosshair_settings.saturation - 1
		if crosshair_settings.saturation < 1 then
			crosshair_settings.saturation = 1
		end
	else
		crosshair_settings.saturation = crosshair_settings.saturation + 1
		if crosshair_settings.saturation > 5 then
			crosshair_settings.saturation = 5
		end
	end
end

function R9K:QuickEditActionOpaque(is_ctrl, is_alt, is_shift, action)
	local crosshair_settings = R9K:GetCrosshairSettingsMenu()
	local step_size = 1
	if is_alt then
		step_size = 20
	elseif is_shift then
		step_size = 5
	end
	if action == "left" then
		crosshair_settings.opacity = crosshair_settings.opacity - step_size
		if crosshair_settings.opacity < 1 then
			crosshair_settings.opacity = 1
		end
	else
		crosshair_settings.opacity = crosshair_settings.opacity + step_size
		if crosshair_settings.opacity > 100 then
			crosshair_settings.opacity = 100
		end
	end
end

function R9K:QuickEditActionSettings(is_ctrl, is_alt, is_shift, action)
	if action == "left" then
		R9K:LoadSettings()
		R9K:DisplayHint(managers.localization:text("r9k_id_loc_load_complete_notification"), 3)
	else
		R9K:SaveSettings()
		R9K:DisplayHint(managers.localization:text("r9k_id_loc_save_complete_notification"), 3)
	end
end

function R9K:QuickEditActionReadMe(is_ctrl, is_alt, is_shift, action)
	R9K:DisplayHint("readme.txt", 3)
end

function R9K:GetCrosshairSettingsMenu()
	return R9K:GetCrosshairSettings(R9K.quick_edit_context_weapon, R9K.quick_edit_context_weapon_position)
end

function R9K:GetCrosshairSettingsGame()
	return R9K:GetCrosshairSettings(R9K.game_weapon, R9K.game_weapon_position)
end

function R9K:GetCrosshairSettings(weapon, weapon_position)
	if weapon == R9K.WEAPON_PRIMARY then
		if weapon_position == R9K.WEAPON_POSITION_HIP then
			return R9K.settings.crosshair.primary.hip
		else
			return R9K.settings.crosshair.primary.aim
		end
	else
		if weapon_position == R9K.WEAPON_POSITION_HIP then
			return R9K.settings.crosshair.secondary.hip
		else
			return R9K.settings.crosshair.secondary.aim
		end
	end
end


-- ---[ mod announce ]------------------------------------------------------------- --

function R9K:SendModAnnounceHost(peer_id)

	if not peer_id then
		return
	end
	
	local peer_name = R9K:GetPeerName(peer_id, "unknown")
	
	local debug_message = "[R9K][ModAnnounce][" .. tostring(peer_id) .. "][" .. peer_name .. "]"
	
	if R9K:ShallSendModAnnounce(peer_id) then
		R9K:SendMessage(peer_id, R9K.mod_announce_host)
		debug_message = debug_message .. " <sent>"
	else
		debug_message = debug_message .. " <already sent>"
	end
	
	-- R9K:SystemMessage(debug_message)

end

function R9K:ShallSendModAnnounce(peer_id)

	local doAnnounce = false
	
	local peer_name = R9K:GetPeerName(peer_id, nil)
	if peer_name then
		R9K:LoadState()

		if not R9K:InList(R9K.state.announce_list, peer_name) then
			table.insert( R9K.state.announce_list, peer_name )		-- inserts at end of list
			doAnnounce = true
			
			local list_length = R9K:GetArraySize(R9K.state.announce_list)
			if list_length > R9K.announce_list_length then
				while list_length > R9K.announce_list_length do
					table.remove(R9K.state.announce_list, 1)		-- remove from beginning of list
					list_length = R9K:GetArraySize(R9K.state.announce_list)
				end
			end
			
		end
		
		R9K:SaveState()	
	end

	return doAnnounce
end


-- ---[ nice to have ]------------------------------------------------------------- --

function R9K:LogObject(name, obj)
	local obj_wrapper = {}
	obj_wrapper[name] = obj
	local obj_string = R9K:ObjectToString( obj_wrapper )
	log("\n" .. obj_string .. "\n")
end 

function R9K:ObjectToString(obj, depth, output)

	depth = depth or 0
	output = output or ""
	
	local whitespace = ""
	for i = 0, depth, 1 do
		whitespace = whitespace .. "\t"
	end
	
	for key,value in pairs(obj) do
		if (type(value) == "boolean") then
			output = output .. "\n" .. whitespace .. key .. ": " .. tostring(value)
		end
	end
	
	for key,value in pairs(obj) do
		if (type(value) == "number") then
			output = output .. "\n" .. whitespace .. key .. ": " .. tostring(value)
		end
	end
	
	for key,value in pairs(obj) do
		if (type(value) == "string") then
			output = output .. "\n" .. whitespace .. key .. ": \"" .. tostring(value) .. "\""
		end
	end
	
	for key,value in pairs(obj) do
		if (type(value) == "userdata") then
			output = output .. "\n" .. whitespace .. key .. ": " .. tostring(value) or "<???>"
		end
	end
	
	for key,value in pairs(obj) do
		if (type(value) == "nil") then
			output = output .. "\n" .. whitespace .. key .. ": <nil>"
		end
	end
	
	for key,value in pairs(obj) do
		if (type(value) == "function") then
			output = output .. "\n" .. whitespace .. key .. "()"
		end
	end
	
	for key,value in pairs(obj) do
		if (type(value) == "thread") then
			output = output .. "\n" .. whitespace .. key .. ": <THREAD>"
		end
	end
	
	for key,value in pairs(obj) do
		if (type(value) == "table") then
			output = output .. "\n" .. whitespace .. key .. ":"
			output = R9K:ObjectToString(value, depth + 1, output)
		end
	end
	
	return output
end