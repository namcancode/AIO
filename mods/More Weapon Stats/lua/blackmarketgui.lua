_G.MoreWeaponStats = _G.MoreWeaponStats or {}

local _alpha_unavailable = 0.1
local _alpha_disabled = 0.5
local _alpha_enabled = 1

MoreWeaponStats.unit_types = {
	'swat',
	'heavy_swat',
	'sniper',
	'taser',
	'spooc',
	'tank'
}

BlackMarketGui.mws_bonuses = {
	prison_wife      = { index = 1, required_level = 0, available = false, checked_by_default = true,  x = 0   }, -- used for headshot
	spotter_teamwork = { index = 2, required_level = 1, available = false, checked_by_default = false, x = 1.5 },
	underdog         = { index = 3, required_level = 1, available = false, checked_by_default = false, x = 2.5 },
	overkill         = { index = 4, required_level = 1, available = false, checked_by_default = false, x = 3.5 },
	body_expertise   = { index = 5, required_level = 1, available = false, checked_by_default = true,  x = 4.5 },
	backstab         = { index = 6, required_level = 1, available = false, checked_by_default = true,  x = 5.5 },
	trigger_happy    = { index = 7, required_level = 1, available = false, checked_by_default = true,  x = 6.5 },
	wolverine        = { index = 8, required_level = 1, available = false, checked_by_default = true,  x = 7.5 }
}

function BlackMarketGui:mws_check_bonus_availability()
	local function _set_bonus_checked(bonus)
		if bonus.available then
			if bonus.checked == nil then
				bonus.checked = bonus.checked_by_default
			end
		else
			bonus.checked = false
		end
	end

	for skill_name, bonus in pairs(self.mws_bonuses) do
		local skill_level = managers.skilltree._global.skills[skill_name].unlocked
		bonus.level = skill_level
		bonus.available = skill_level >= bonus.required_level
		_set_bonus_checked(bonus)
	end
end

local mws_original_blackmarketgui_updateborders = BlackMarketGui._update_borders
function BlackMarketGui:_update_borders()
	mws_original_blackmarketgui_updateborders(self)

	if self._tabs[self._selected]._data.identifier == self.identifiers.weapon then
		self:mws_check_bonus_availability()

		local weapon_info_height, wh
		if MoreWeaponStats.settings.show_spread_and_recoil then
			self._panel:child('back_button'):set_right(self._box_panel:right())

			if self._detection_panel:visible() then
				self._detection_panel:set_right(self._panel:child('back_button'):left() - 8)
				self._detection_panel:set_center_y(self._panel:child('back_button'):center_y())
				self._detection_border:hide()
			end

			if self._btn_panel then
				self._btn_panel:set_bottom(self._panel:bottom())
			end

			wh = self._weapon_info_panel:h()
			weapon_info_height = self._panel:bottom() - (self._button_count > 0 and self._btn_panel:h() + 8 or 0) - self._weapon_info_panel:top()

		else
			self._panel:child('back_button'):set_right(self._panel:right())

			if self._detection_panel:visible() then
				self._detection_panel:set_right(self._box_panel:right())
				self._detection_panel:set_center_y(self._panel:child('back_button'):center_y())
				self._detection_border:hide()
			end

			if self._btn_panel then
				self._btn_panel:set_bottom(self._box_panel:bottom())
			end

			wh = self._weapon_info_panel:h()
			weapon_info_height = self._box_panel:bottom() - (self._button_count > 0 and self._btn_panel:h() + 8 or 0) - self._weapon_info_panel:top()
		end

		self._weapon_info_panel:set_h(weapon_info_height)
		self._stats_panel:set_h(weapon_info_height)
		self._rweapon_stats_panel:set_h(weapon_info_height)
		self._info_texts_panel:set_h(weapon_info_height - 20)
		if wh ~= self._weapon_info_panel:h() then
			self._weapon_info_border:create_sides(self._weapon_info_panel, { sides = { 1, 1, 1, 1 } })
		end
	end
end

local mws_original_blackmarketgui_setinfotext = BlackMarketGui.set_info_text
function BlackMarketGui:set_info_text(id, new_string, resource_color)
	if id == 2 then
		if self.mws_breakpoints and self.mws_bp_current_damage then
			self.mws_text2 = string.gsub(new_string, '##', '')
			new_string = string.format('%s %.2f', utf8.to_upper(managers.localization:text('bm_menu_damage')), self.mws_bp_current_damage)
			self._info_texts[2]:set_h(20)
		end
	end

	mws_original_blackmarketgui_setinfotext(self, id, new_string, resource_color)

	if id == 3 or id == 5 or (id == 4 and not MoreWeaponStats.settings.show_dlc_info) then
		if self._tabs[self._selected]._data.identifier == self.identifiers.weapon then
			self._info_texts[id]:set_visible(false)
			if self._desc_mini_icons then
				for _, gui_object in pairs(self._desc_mini_icons) do
					self._panel:remove(gui_object[1])
				end
				self._desc_mini_icons = {}
			end
		end
	end
end

function BlackMarketGui:mws_realign_rcells(panel)
	for _, line in pairs(panel:children()) do
		if type(line.children) == 'function' then
			for _, cell in ipairs(line:children()) do
				if cell:width() == 45 then
					local left = cell:left()
					cell:set_left(left + 5 * (1 + (left - 100 - (left == 190 and 0 or 2)) / 45) + (left == 190 and 2 or 0))
				end
			end
		end
	end
end

function BlackMarketGui:mws_get_bottom(panel)
	local y = 0
	local lines_nr = 0

	for _, line in pairs(panel:children()) do
		if type(line.bottom) == 'function' and line:alpha() > 0 then
			y = math.max(y, line:bottom())
			lines_nr = lines_nr + 1
		end
	end

	return y, lines_nr
end

local mws_original_blackmarketgui_setup = BlackMarketGui._setup
function BlackMarketGui:_setup(...)
	mws_original_blackmarketgui_setup(self, ...)

	-- stats extension
	self.mws_stats_shown = nil
	local base_panel
	local text_columns = {}

	if self._mweapon_stats_panel and self._tabs[self._selected]._data.identifier == self.identifiers.melee_weapon then
		base_panel = self._mweapon_stats_panel
		self.mws_stats_shown = {
			{ name = 'mws_attack_delay' },
			{ name = 'mws_cooldown' },
			{ name = 'mws_unequip_delay' }
		}
		text_columns = {
			{ size = 100, name = 'name' },
			{ size = 55, align = 'right', alpha = 0.75, blend = 'add', name = 'a1' },
			{ size = 88, align = 'right', alpha = 0.75, blend = 'add', name = 'a2' },
		}
	end

	if self._rweapon_stats_panel and self._tabs[self._selected]._data.identifier == self.identifiers.weapon then
		for i, s in pairs(self._stats_shown) do
			if s.name == 'reload' then
				local reload_line = self._rweapon_stats_panel:children()[i]
				reload_line:set_alpha(0)
				break
			end
		end

		base_panel = self._rweapon_stats_panel
		self.mws_stats_shown = {
			{ name = 'mws_reload_partial', fct = self.mws_reload_partial },
			{ name = 'mws_reload_full', fct = self.mws_reload_full },
			{ name = 'mws_equip_delay', fct = self.mws_equip_delay },
			{ name = 'mws_ammo_pickup', fct = self.mws_ammo_pickup },
		}
		if MoreWeaponStats.settings.show_spread_and_recoil then
			table.insert(self.mws_stats_shown, { name = 'mws_recoil_horiz', fct = self.mws_recoil_horiz })
			table.insert(self.mws_stats_shown, { name = 'mws_recoil_vert', fct = self.mws_recoil_vert })
			table.insert(self.mws_stats_shown, { name = 'mws_accuracy_ads', fct = self.mws_accuracy_ads })
			table.insert(self.mws_stats_shown, { name = 'mws_accuracy_crouching', fct = self.mws_accuracy_crouching })
			table.insert(self.mws_stats_shown, { name = 'mws_accuracy_standing', fct = self.mws_accuracy_standing })
		end
		table.insert(self.mws_stats_shown, { name = 'mws_falloff', fct = self.mws_falloff })
		text_columns = {
			{ size = 100, name = 'name' },
			{ size = 50, align = 'right', alpha = 0.75, blend = 'add', name = 'a1' },
			{ size = 50, align = 'left', alpha = 0.75, blend = 'add', name = 'b1' },
			{ size = 50, align = 'right', alpha = 0.75, blend = 'add', name = 'a2' },
			{ size = 50, align = 'left', alpha = 0.75, blend = 'add', name = 'b2' },
		}
	end

	if self.mws_stats_shown then
		local y, lines_nr = self:mws_get_bottom(base_panel)
		local oddeven = math.mod(lines_nr, 2)

		self.mws_stats_texts = {}
		for i, stat in ipairs(self.mws_stats_shown) do
			local panel = base_panel:panel({
				layer = 1,
				x = 0,
				y = y,
				w = base_panel:w(),
				h = 20
			})
			if math.mod(i, 2) == oddeven and not panel:child(tostring(i)) then
				panel:rect({
					color = Color.black:with_alpha(0.3)
				})
			end

			y = y + 20
			local x = 2
			self.mws_stats_texts[stat.name] = {}
			for i, column in ipairs(text_columns) do
				local text_panel = panel:panel({
					layer = 0,
					x = x,
					w = column.size,
					h = panel:h()
				})
				self.mws_stats_texts[stat.name][column.name] = text_panel:text({
					text = i == 1 and managers.localization:to_upper_text(stat.name) or nil,
					font_size = tweak_data.menu.pd2_small_font_size,
					font = tweak_data.menu.pd2_small_font,
					align = column.align,
					layer = 1,
					alpha = column.alpha,
					blend_mode = column.blend,
					color = column.color or tweak_data.screen_colors.text
				})
				x = x + column.size
			end
		end

		self:show_stats()
		self:update_info_text()
	end

	if self._rweapon_stats_panel and self._tabs[self._selected]._data.identifier == self.identifiers.weapon then
		if MoreWeaponStats.settings.use_preview_to_switch_breakpoints then
			local preview_btn = self._btns.w_preview
			preview_btn._data.pc_btn = nil
			preview_btn._pc_btn = nil
		end

		-- show/hide breakpoints buttons
		self.mws_bp_switch_panel = self._panel:panel({
			w = self._buttons:w(),
			h = 30,
		})
		self.mws_bp_switch_panel:set_bottom(self._weapon_info_panel:y() + 2)
		self.mws_bp_switch_panel:set_right(self._panel:w())

		local btn_data = {
			prio = 1,
			name = 'mws_bp_show',
			pc_btn = 'menu_preview_item',
			callback = callback(self, self, 'mws_bp_show_callback')
		}
		self.mws_bp_show_btn = BlackMarketGuiButtonItem:new(self.mws_bp_switch_panel, btn_data, 10)
		self.mws_bp_show_btn._data.prio = 5 -- ugly trick for double-click
		self._btns['mws_bp_show'] = self.mws_bp_show_btn

		btn_data = {
			prio = 1,
			name = 'mws_bp_hide',
			pc_btn = 'menu_preview_item',
			callback = callback(self, self, 'mws_bp_hide_callback')
		}
		self.mws_bp_hide_btn = BlackMarketGuiButtonItem:new(self.mws_bp_switch_panel, btn_data, 10)
		self.mws_bp_hide_btn._data.prio = 5
		self._btns['mws_bp_hide'] = self.mws_bp_hide_btn

		self:show_btns(self._selected_slot)

		-- breakpoints
		self.mws_bp_panel = self._weapon_info_panel:panel({
			visible = false,
			y = 58,
			x = 10,
			layer = 1,
			w = self._weapon_info_panel:w() - 20,
			h = self._weapon_info_panel:h() - 84
		})

		-- checkable bonuses
		self.mws_bp_bonus_panel = self.mws_bp_panel:panel({
			y = 0,
			x = 0,
			layer = 1,
			w = 200,
			h = 40
		})

		local max_x = 0
		local bonus_dim = 32
		self.mws_bp_skill_bitmap = {}
		for skill_name, bonus in pairs(self.mws_bonuses) do
			local icon_xy = tweak_data.skilltree.skills[skill_name].icon_xy
			max_x = math.max(max_x, bonus.x * bonus_dim)
			self.mws_bp_skill_bitmap[bonus.index] = self.mws_bp_bonus_panel:bitmap({
				x = bonus.x * bonus_dim,
				y = 0,
				texture = 'guis/textures/pd2/skilltree_2/icons_atlas_2',
				name = skill_name,
				blend_mode = 'add',
				layer = 1,
				texture_rect = {
					icon_xy[1] * 80,
					icon_xy[2] * 80,
					80,
					80
				},
				w = bonus_dim,
				h = bonus_dim,
				alpha = not bonus.available and _alpha_unavailable or bonus.checked and _alpha_enabled or _alpha_disabled
			})
		end
		self.mws_bp_bonus_panel:set_w(max_x + bonus_dim)
		self.mws_bp_bonus_panel:set_center_x(self.mws_bp_panel:w() / 2)

		-- difficulty
		self.mws_bp_risk_panel = self.mws_bp_panel:panel({
			y = self.mws_bp_panel:h() - 60,
			x = 0,
			layer = 1,
			w = 200,
			h = 30,
			visible = not managers.crime_spree:is_active()
		})

		local can_set_difficulty = not managers.network:session()
		local risk_text = self.mws_bp_risk_panel:text({
			name = 'mws_bp_risk',
			align = 'center',
			vertical = 'center',
			text = utf8.to_upper(managers.localization:text('menu_risk')),
			font_size = tweak_data.menu.pd2_small_font_size,
			font = tweak_data.menu.pd2_small_font,
			color = tweak_data.screen_colors.risk:with_alpha(can_set_difficulty and 1 or 0.5),
			x = 0,
			y = 0,
			w = 100,
			h = 30
		})
		local _, _, w, _ = risk_text:text_rect()
		risk_text:set_w(w)

		local risks = {
			'risk_pd',
			'risk_swat',
			'risk_fbi',
			'risk_death_squad',
			'risk_easy_wish',
			'risk_murder_squad',
			'risk_sm_wish'
		}
		self.mws_bp_difficulty_bitmap = {}
		for i = 2, 7 do
			local name = risks[i]
			local texture, rect = tweak_data.hud_icons:get_icon_data(name)
			self.mws_bp_difficulty_bitmap[i] = self.mws_bp_risk_panel:bitmap({
				blend_mode = 'add',
				y = 0,
				x = risk_text:right() + (i - 2) * 35,
				name = name,
				texture = texture,
				texture_rect = rect,
				alpha = 0.25,
				color = Color.white
			})
		end

		self.mws_bp_risk_panel:set_w(self.mws_bp_difficulty_bitmap[7]:right())
		self.mws_bp_risk_panel:set_center_x(self.mws_bp_panel:w() / 2)

		-- unit names
		local col_width = 38
		self.mws_bp_unit_texts = {}
		local h = self.mws_bp_panel:h() - 50
		for i, unit_name in pairs(MoreWeaponStats.unit_types) do
			local txt = self.mws_bp_panel:text({
				vertical = 'center',
				align = 'right',
				text = managers.localization:text('mws_bp_option_' .. unit_name),
				font_size = tweak_data.menu.pd2_small_font_size,
				font = tweak_data.menu.pd2_small_font,
				color = tweak_data.screen_colors.text:with_alpha(0.3 + i * 0.06),
				x = i * col_width - 32,
				y = h - 60,
				w = 100,
				h = 30
			})
			txt:rotate(-45)
			self.mws_bp_unit_texts[i] = txt
		end

		-- cells
		self.mws_bp_damage = {}
		self.mws_bp_bullet = {}
		local row_max = math.floor(self.mws_bp_unit_texts[1]:top() / 20) - 2
		local nr = 0
		for i = 2, row_max do
			local y = i * 20
			local panel = self.mws_bp_panel:panel({
				layer = 1,
				x = 0,
				y = y,
				w = self.mws_bp_panel:w(),
				h = 20
			})
			if i % 2 == 0 then
				panel:rect({
					color = Color.black:with_alpha(0.3)
				})
			end

			self.mws_bp_damage[i - 1] = self.mws_bp_panel:text({
				name = 'mws_bp_damage_' .. tostring(i - 1),
				layer = 2,
				align = 'right',
				vertical = 'center',
				font_size = tweak_data.menu.pd2_small_font_size,
				font = tweak_data.menu.pd2_small_font,
				text = '?',
				x = 0,
				y = y,
				w = 60,
				h = 20,
				color = Color.white,
			})

			for j = 1, 6 do
				nr = nr + 1
				self.mws_bp_bullet[nr] = self.mws_bp_panel:text({
					name = 'mws_bp_bullet_' .. tostring(i - 1) .. '_' .. MoreWeaponStats.unit_types[j],
					layer = 2,
					align = 'center',
					vertical = 'center',
					font_size = tweak_data.menu.pd2_small_font_size,
					font = tweak_data.menu.pd2_small_font,
					text = '-',
					x = 80 + (j - 1) * col_width,
					y = y,
					w = 25,
					h = 20,
					color = Color.white,
					alpha = 1
				})
			end
		end

		self:mws_update_difficulty(can_set_difficulty and MoreWeaponStats.settings.last_used_difficulty or Global.game_settings.difficulty, false)

		if self.mws_breakpoints then
			self:mws_update_breakpoints()
		end
	end
end

local mws_original_blackmarketgui_showbtns = BlackMarketGui.show_btns
function BlackMarketGui:show_btns(...)
	mws_original_blackmarketgui_showbtns(self, ...)

	local btn -- no 1l expr!
	if self.mws_breakpoints then
		btn = self.mws_bp_hide_btn
	else
		btn = self.mws_bp_show_btn
	end
	if btn then
		btn:set_text_params()
		btn:show()
		if MoreWeaponStats.settings.use_preview_to_switch_breakpoints then
			self._controllers_pc_mapping[Idstring(btn._data.pc_btn):key()] = btn
		end
	end
end

function BlackMarketGui:mws_bp_show_callback(data)
	self.mws_breakpoints = true
	self._stats_panel:hide()
	self._info_texts[4]:set_visible(false)
	self.mws_bp_panel:show()
	self._button_highlighted = nil
	self:show_btns(self._selected_slot)
	self:mws_update_breakpoints()

	self:set_info_text(2, self._info_texts[2]:text(), tweak_data.screen_colors.text:with_alpha(0.35))
end

function BlackMarketGui:mws_bp_hide_callback(data)
	self.mws_breakpoints = false
	self._stats_panel:show()
	self._info_texts[4]:set_visible(true)
	self.mws_bp_panel:hide()
	self._button_highlighted = nil
	self:show_btns(self._selected_slot)

	if self.mws_text2 then
		self._info_texts[2]:set_text(self.mws_text2)
	end
end

local mws_original_blackmarketgui_showstats = BlackMarketGui.show_stats
function BlackMarketGui:show_stats()
	mws_original_blackmarketgui_showstats(self)

	MoreWeaponStats.mws_slot_data = self._slot_data
	if self.mws_breakpoints then
		self._stats_panel:hide()
		self:mws_update_breakpoints()
	end

	if self._mweapon_stats_panel and self._mweapon_stats_panel:visible() then
		if self.mws_stats_texts then
			local melee1 = managers.blackmarket:get_melee_weapon_data(self:mws_get_popup_data(true).name)
			local melee2 = not self._slot_data.equipped and managers.blackmarket:get_melee_weapon_data(self:mws_get_popup_data(false).name)

			-- bits taken from BWS's function InventoryStatsPopup:_melee_weapons_damage()
			for _, stat in pairs(self.mws_stats_shown) do
				local txt1, txt2
				if stat.name == 'mws_attack_delay' then
					txt1 = string.format('%.2fs', melee1.melee_damage_delay or 0)
					txt2 = melee2 and string.format('%.2fs', melee2.melee_damage_delay or 0) or ''
				elseif stat.name == 'mws_cooldown' then
					txt1 = string.format('%.2fs', melee1.repeat_expire_t)
					txt2 = melee2 and string.format('%.2fs', melee2.repeat_expire_t) or ''
				elseif stat.name == 'mws_unequip_delay' then
					txt1 = string.format('%.2fs', melee1.expire_t)
					txt2 = melee2 and string.format('%.2fs', melee2.expire_t) or ''
				end
				self.mws_stats_texts[stat.name].a1:set_text(txt1)
				self.mws_stats_texts[stat.name].a2:set_text(txt2)
			end
		end
	end

	if self._rweapon_stats_panel and self._rweapon_stats_panel:visible() then
		self:mws_realign_rcells(self._rweapon_stats_panel)
		if self.mws_stats_texts then
			local data1 = self:mws_get_popup_data(true)
			local data2 = not self._slot_data.equipped and self:mws_get_popup_data(false)

			for _, stat in pairs(self.mws_stats_shown) do
				if stat.fct then
					stat.fct(self, data1, '1', self.mws_stats_texts[stat.name])
					if data2 then
						stat.fct(self, data2, '2', self.mws_stats_texts[stat.name])
					else
						self.mws_stats_texts[stat.name].a2:set_text('')
						self.mws_stats_texts[stat.name].b2:set_text('')
					end
				end
			end
		end
	end
end

function BlackMarketGui:mws_get_popup_data(equipped, remove_mod, add_mod, slot_data) -- mostly a copy paste from Better Weapon Stats
	slot_data = slot_data or self._slot_data
	local category = slot_data.category
	local data

	if tweak_data.weapon[slot_data.name] and slot_data.name ~= 'sentry_gun' then
		local slot = equipped and managers.blackmarket:equipped_weapon_slot(category) or slot_data.slot
		local weapon = equipped and managers.blackmarket:equipped_item(category) or managers.blackmarket:get_crafted_category_slot(category, slot)
		local name = equipped and weapon.weapon_id or weapon and weapon.weapon_id or slot_data.name
		local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(name)

		local blueprint = deep_clone(managers.blackmarket:get_weapon_blueprint(category, slot) or managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id))
		if remove_mod and blueprint then
			for i = 1, #blueprint do
				if blueprint[i] == remove_mod then
					table.remove(blueprint, i)
					break
				end
			end
		end
		if add_mod and blueprint then
			table.insert(blueprint, add_mod)
		end

		local ammo_data = factory_id and blueprint and managers.weapon_factory:get_ammo_data_from_weapon(factory_id, blueprint) or {}
		ammo_data.fire_dot_data = tweak_data.weapon[name].fire_dot_data
		local custom_stats = factory_id and blueprint and managers.weapon_factory:get_custom_stats_from_weapon(factory_id, blueprint)
		local ammo_sub_type
		if custom_stats then
			for part_id, stats in pairs(custom_stats) do
				if tweak_data.weapon.factory.parts[part_id].type == 'ammo' then
					ammo_sub_type = tweak_data.weapon.factory.parts[part_id].sub_type
				else
					if stats.ammo_pickup_min_mul then
						ammo_data.ammo_pickup_min_mul = ammo_data.ammo_pickup_min_mul and ammo_data.ammo_pickup_min_mul * stats.ammo_pickup_min_mul or stats.ammo_pickup_min_mul
					end
					if stats.ammo_pickup_max_mul then
						ammo_data.ammo_pickup_max_mul = ammo_data.ammo_pickup_max_mul and ammo_data.ammo_pickup_max_mul * stats.ammo_pickup_max_mul or stats.ammo_pickup_max_mul
					end
				end
				if stats.fire_dot_data then
					ammo_data.fire_dot_data = stats.fire_dot_data
				end
			end
		end
		local base_stats, mods_stats, skill_stats = WeaponDescription._get_stats(name, category, slot, blueprint)
		data = {
			base_stats = base_stats,
			mods_stats = mods_stats,
			skill_stats = skill_stats,
			name = name,
			categories = tweak_data.weapon[name].categories,
			tweak = tweak_data.weapon[name],
			weapon = weapon,
			factory_id = factory_id,
			blueprint = blueprint,
			ammo_data = ammo_data,
			silencer = factory_id and blueprint and managers.weapon_factory:has_perk('silencer', factory_id, blueprint),
			cosmetics = weapon and weapon.cosmetics,
		}
	elseif tweak_data.blackmarket.melee_weapons[slot_data.name] then
		local name = equipped and managers.blackmarket:equipped_item(category) or slot_data.name
		data = {
			name = name,
		}
	end

	return data
end

function BlackMarketGui:mws_get_reload_speed_multiplier(data)
	local fake_weapon_base = MoreWeaponStats.make_newraycastweaponbase(data.factory_id, data.blueprint, data.name)

	local result
	if data.categories[1] == 'shotgun' then
		result = RaycastWeaponBase.reload_speed_multiplier(fake_weapon_base)
	elseif data.categories[1] == 'bow' and data.tweak.bow_reload_speed_multiplier then
		result = NewRaycastWeaponBase.reload_speed_multiplier(fake_weapon_base) * data.tweak.bow_reload_speed_multiplier
	else
		result = NewRaycastWeaponBase.reload_speed_multiplier(fake_weapon_base)
	end

	return result
end

function BlackMarketGui:mws_reload_full(data, index, txts)
	-- taken from BWS's function InventoryStatsPopup:_primaries_magazine()
	local reload_mul = self:mws_get_reload_speed_multiplier(data)
	local timers = data.tweak.timers
	local reload_not_empty = timers and timers.reload_not_empty
	local reload_empty = timers and timers.reload_empty
	local v

	if reload_not_empty and reload_empty then
		v = reload_empty / reload_mul
	else
		local mag = data.base_stats.magazine.value + data.mods_stats.magazine.value + data.skill_stats.magazine.value
		if timers.shotgun_reload_enter then
			v = (timers.shotgun_reload_enter + timers.shotgun_reload_shell * mag - timers.shotgun_reload_first_shell_offset) / reload_mul
		else
			v = (mag * 17 / 30 - 0.03) / reload_mul
		end
	end

	txts['a' .. index]:set_text(string.format('%.2f%s', v, managers.localization:text('menu_seconds_suffix_short')))
end

function BlackMarketGui:mws_reload_partial(data, index, txts)
	-- taken from BWS's function InventoryStatsPopup:_primaries_magazine()
	local reload_mul = self:mws_get_reload_speed_multiplier(data)
	local timers = data.tweak.timers
	local reload_not_empty = timers and timers.reload_not_empty
	local reload_empty = timers and timers.reload_empty
	local s = managers.localization:text('menu_seconds_suffix_short')

	if reload_not_empty and reload_empty then
		txts['a' .. index]:set_text(string.format('%.2f%s', reload_not_empty / reload_mul, s))
		txts['b' .. index]:set_text('')
	else
		local time_first_shell, time_additional_shell
		if timers.shotgun_reload_enter then
			time_first_shell = (timers.shotgun_reload_enter + timers.shotgun_reload_shell - timers.shotgun_reload_first_shell_offset) / reload_mul
			time_additional_shell = timers.shotgun_reload_shell / reload_mul
		else
			time_first_shell = (17 / 30 - 0.03) / reload_mul
			time_additional_shell = 17 / 30 / reload_mul
		end
		txts['a' .. index]:set_text(string.format('%.2f%s', time_first_shell, s))
		txts['b' .. index]:set_text(string.format(' | %.2f%s', time_additional_shell, s))
	end
end

function BlackMarketGui:mws_ammo_pickup(data, index, txts)
	-- taken from BWS's function InventoryStatsPopup:_primaries_totalammo()
	local pickup = data.tweak.AMMO_PICKUP
	if pickup[1] == 0 and pickup[2] == 0 then
		txts['a' .. index]:set_text('')
		txts['b' .. index]:set_text('')
	else
		local ammo_data = data.ammo_data
		local skill_pickup = 1 + managers.player:upgrade_value('player', 'pick_up_ammo_multiplier', 1) + managers.player:upgrade_value('player', 'pick_up_ammo_multiplier_2', 1) - 2
		local ammo_pickup_min_mul = ammo_data and ammo_data.ammo_pickup_min_mul or skill_pickup
		local ammo_pickup_max_mul = ammo_data and ammo_data.ammo_pickup_max_mul or skill_pickup
		txts['a' .. index]:set_text(string.format('%.2f', pickup[1] * ammo_pickup_min_mul))
		txts['b' .. index]:set_text(string.format(' | %.2f', pickup[2] * ammo_pickup_max_mul))
	end
end

function BlackMarketGui:mws_falloff(data, index, txts)
	-- taken from BWS's function InventoryStatsPopup:_primaries_damage()
	if data.tweak.categories[1] ~= 'shotgun' then
		txts['a' .. index]:set_text('')
		txts['b' .. index]:set_text('')
	else
		local ammo_data = data.ammo_data
		local near = data.tweak.damage_near / 100
		local far = data.tweak.damage_far / 100
		local near_mul = ammo_data and ammo_data.damage_near_mul or 1
		local far_mul = ammo_data and ammo_data.damage_far_mul or 1
		txts['a' .. index]:set_text(string.format('%.1fm', near * near_mul))
		txts['b' .. index]:set_text(string.format(' | %.1fm', near * near_mul + far * far_mul))
	end
end

function MoreWeaponStats.get_current_stats(data)
	-- comes from function NewRaycastWeaponBase:_update_stats_values()
	local stats = deep_clone(data.tweak.stats)

	local parts_stats = managers.weapon_factory:get_stats(data.factory_id, data.blueprint)
	local stats_tweak_data = tweak_data.weapon.stats

	local bonus = data.cosmetics and data.cosmetics.id and tweak_data.blackmarket.weapon_skins[data.cosmetics.id] and tweak_data.blackmarket.weapon_skins[data.cosmetics.id].bonus
	local bonus_stats = bonus and tweak_data.economy.bonuses[bonus] and tweak_data.economy.bonuses[bonus].stats or {}

	for stat, _ in pairs(stats) do
		if parts_stats[stat] then
			stats[stat] = stats[stat] + parts_stats[stat]
		end
		if bonus_stats[stat] then
			stats[stat] = stats[stat] + bonus_stats[stat]
		end
		stats[stat] = math.clamp(stats[stat], 1, #stats_tweak_data[stat])
	end
	local result = { indices = stats }

	local modifier_stats = data.tweak.stats_modifiers
	local _current_stats = {}
	for stat, i in pairs(stats) do
		_current_stats[stat] = stats_tweak_data[stat] and stats_tweak_data[stat][i] or 1
		if modifier_stats and modifier_stats[stat] then
			_current_stats[stat] = _current_stats[stat] * modifier_stats[stat]
		end
	end
	result.values = _current_stats

	return result
end

function MoreWeaponStats.make_state(st_moving, st_ducking, st_deploy, st_steelsight)
	return {
		_moving = st_moving,
		_steelsight = st_steelsight,
		_unit_deploy_position = st_deploy,
		_state_data = { ducking = st_ducking },
		in_steelsight = function(self)
			return self._steelsight
		end,
		get_movement_state = PlayerStandard.get_movement_state
	}
end

function MoreWeaponStats.make_user_unit(st_moving, st_ducking, st_deploy, st_steelsight)
	return {
		_movement = {
			_current_state = MoreWeaponStats.make_state(st_moving, st_ducking, st_deploy, st_steelsight)
		},
		movement = function(self)
			return self._movement
		end
	}
end

function MoreWeaponStats.make_newraycastweaponbase(factory_id, blueprint, name_id)
	local result = {}
	for k, v in pairs(RaycastWeaponBase) do
		result[k] = v
	end
	for k, v in pairs(NewRaycastWeaponBase) do
		result[k] = v
	end
	result._name_id = name_id
	result._factory_id = factory_id
	result._blueprint = blueprint
	result._sound_fire = {
		set_switch = function() end
	}
	result._muzzle_effect_table = {}
	result._parts = {}
	if MoreWeaponStats_update_stats_values then
		MoreWeaponStats_update_stats_values(result)
	else
		NewRaycastWeaponBase._update_stats_values(result)
	end
	return result
end

function MoreWeaponStats.make_playerstate(factory_id, blueprint, name_id)
	local wb = MoreWeaponStats.make_newraycastweaponbase(factory_id, blueprint, name_id)
	return {
		_equipped_unit = {
			base = function()
				return wb
			end
		}
	}
end

function MoreWeaponStats.mws_get_spread(data, st_moving, st_ducking, st_deploy, st_steelsight)
	local tmp = NewRaycastWeaponBase.replenish
	NewRaycastWeaponBase.replenish = function() end
	local fake_weapon_base = MoreWeaponStats.make_newraycastweaponbase(data.factory_id, data.blueprint, data.name)
	local fake_user_unit = MoreWeaponStats.make_user_unit(st_moving, st_ducking, st_deploy, st_steelsight)
	local spread_x, spread_y = NewRaycastWeaponBase._get_spread(fake_weapon_base, fake_user_unit)
	NewRaycastWeaponBase.replenish = tmp
	return spread_x
end

function BlackMarketGui:mws_accuracy(data, index, txts, st_ducking, st_deploy, st_steelsight)
	if data.tweak.categories[1] == 'saw' then
		txts['a' .. index]:set_text('')
		txts['b' .. index]:set_text('')
	else
		txts['a' .. index]:set_text(string.format("%.2f'", MoreWeaponStats.mws_get_spread(data, false, st_ducking, st_deploy, st_steelsight)))
		txts['b' .. index]:set_text(string.format(" | %.2f'", MoreWeaponStats.mws_get_spread(data, true, st_ducking, st_deploy, st_steelsight)))
	end
end

function BlackMarketGui:mws_accuracy_ads(data, index, txts)
	self:mws_accuracy(data, index, txts, false, false, true)
end

function BlackMarketGui:mws_accuracy_standing(data, index, txts)
	self:mws_accuracy(data, index, txts, false, false, false)
end

function BlackMarketGui:mws_accuracy_crouching(data, index, txts)
	self:mws_accuracy(data, index, txts, true, false, false)
end

function MoreWeaponStats.mws_get_recoil(data, current_stats, st_ducking, st_steelsight)
	-- comes from function PlayerStandard:_check_action_primary_attack()
	local current_state = MoreWeaponStats.make_state(st_moving, st_ducking, st_deploy, st_steelsight)

	local recoil = current_stats.values.recoil
	local recoil_addend = managers.blackmarket:recoil_addend(data.name, data.tweak.categories, current_stats.indices and current_stats.indices.recoil, data.silencer, data.blueprint)
	local recoil_base_multiplier = managers.blackmarket:recoil_multiplier(data.name, data.tweak.categories, data.silencer, data.blueprint)
	local recoil_multiplier = (recoil + recoil_addend) * recoil_base_multiplier

	local up, down, left, right = unpack(data.tweak.kick[st_steelsight and 'steelsight' or st_ducking and 'crouching' or 'standing'])
	return {
		up = up * recoil_multiplier,
		down = down * recoil_multiplier,
		left = left * recoil_multiplier,
		right = right * recoil_multiplier
	}
end

function BlackMarketGui:mws_recoil_horiz(data, index, txts)
	local current_stats = MoreWeaponStats.get_current_stats(data)
	local recoil = MoreWeaponStats.mws_get_recoil(data, current_stats, false, false)
	txts['a' .. index]:set_text(string.format("%.2f'", recoil.left))
	txts['b' .. index]:set_text(string.format(" | %.2f'", recoil.right))
end

function BlackMarketGui:mws_recoil_vert(data, index, txts)
	local current_stats = MoreWeaponStats.get_current_stats(data)
	local recoil = MoreWeaponStats.mws_get_recoil(data, current_stats, false, false)
	txts['a' .. index]:set_text(string.format("%.2f'", recoil.up))
	txts['b' .. index]:set_text(string.format(" | %.2f'", recoil.down))
end

function MoreWeaponStats.mws_get_swap_speed(data)
	local fake_player_state = MoreWeaponStats.make_playerstate(data.factory_id, data.blueprint, data.name)
	local divider = PlayerStandard._get_swap_speed_multiplier(fake_player_state)

	-- 0.7 found in PlayerStandard:_start_action_equip_weapon()
	-- 0.5 found in PlayerStandard:_start_action_unequip_weapon()
	return {
		equip = (data.tweak.timers.equip or 0.7) / divider,
		unequip = (data.tweak.timers.unequip or 0.5) / divider
	}
end

function BlackMarketGui:mws_equip_delay(data, index, txts)
	local swap_delays = MoreWeaponStats.mws_get_swap_speed(data)
	txts['a' .. index]:set_text(string.format('%.2fs', swap_delays.equip))
	txts['b' .. index]:set_text(string.format(' | %.2fs', swap_delays.unequip))
end

function BlackMarketGui:mws_update_difficulty(difficulty, can_switch)
	local difficulty_id
	if managers.network:session() then
		difficulty = Global.game_settings.difficulty
		difficulty_id = tweak_data:difficulty_to_index(difficulty)
	else
		local current_id = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
		difficulty_id = tweak_data:difficulty_to_index(difficulty)
		if can_switch and difficulty_id == current_id then
			difficulty_id = difficulty_id - 1
			difficulty = tweak_data:index_to_difficulty(difficulty_id)
		end
		Global.game_settings.difficulty = difficulty
		tweak_data.character:init(tweak_data)
		tweak_data.player:init(tweak_data)
		tweak_data.player['_set_' .. difficulty](tweak_data.player)
		tweak_data.character['_set_' .. difficulty](tweak_data.character)
	end
	MoreWeaponStats.settings.last_used_difficulty = difficulty

	local can_set_difficulty = not managers.network:session()
	for i, bmp in pairs(self.mws_bp_difficulty_bitmap) do
		local active = i < difficulty_id
		bmp:set_alpha(active and (can_set_difficulty and 1 or 0.5) or 0.25)
		bmp:set_color(active and tweak_data.screen_colors.risk or Color.white)
	end

	return can_set_difficulty
end

function MoreWeaponStats:get_breakpoints(unit_type, params)
	local result = {}
	local ct = tweak_data.character[unit_type]

	local health = ct.HEALTH_INIT
	if not health then
		return result
	end

	if managers.crime_spree:is_active() then
		if not ModifierEnemyHealthAndDamage:is_active() then
			managers.crime_spree:_setup_modifiers()			
		end
	end

	health = health * 10

	local _HEALTH_GRANULARITY = 512
	local _HEALTH_INIT_PRECENT = health / _HEALTH_GRANULARITY

	local damage_clamp
	if params.explosion then
		if managers.crime_spree:modify_value('CopDamage:DamageExplosion', 123, unit_type) == 0 then
			return result
		end
		damage_clamp = ct.DAMAGE_CLAMP_EXPLOSION
	elseif params.fire then
		-- qued
	else
		damage_clamp = ct.DAMAGE_CLAMP_BULLET
	end

	local headshot_mul = 1
	if params.explosion then
		headshot_mul = ct.damage.explosion_damage_mul or 1

	elseif params.headshot then
		if not ct.ignore_headshot then
			local headshot_dmg_mul = ct.headshot_dmg_mul or 1
			headshot_mul = managers.player:upgrade_value('weapon', 'passive_headshot_damage_multiplier', 1) * headshot_dmg_mul
		end

	elseif params.body_expertise then
		if unit_type ~= 'tank' then
			local headshot_dmg_mul = managers.player:upgrade_value('weapon', 'automatic_head_shot_add', nil)
			if headshot_dmg_mul then
				headshot_mul = headshot_dmg_mul * (ct.headshot_dmg_mul or 1)
			end
		end
	end

	local crit_mul = 0
	local crit_chance = 0
	if params.crits then
		local crits = ct.critical_hits or {}
		crit_chance = (crits.base_chance or 0) + managers.player:critical_hit_chance() * (crits.player_chance_multiplier or 1)
		if crit_chance > 0 then
			crit_mul = crits.damage_mul or ct.headshot_dmg_mul
			if not crit_mul then
				return {1}
			end
		end
	end

	local spotter_mul = 1
	if unit_type == 'swat' or unit_type == 'heavy_swat' then
	else
		if params.spotter >= 1 then
			spotter_mul = tweak_data.upgrades.values.player.marked_enemy_damage_mul
		end
		if params.spotter >= 2 then
			spotter_mul = spotter_mul * tweak_data.upgrades.values.player.marked_inc_dmg_distance[1][2]
		end
	end

	local underdog_mul = params.underdog and tweak_data.upgrades.values.temporary.dmg_multiplier_outnumbered[1][1] or 1

	local overkill_mul = params.overkill and tweak_data.upgrades.values.temporary.overkill_damage_multiplier[1][1] or 1

	local berserker_mul = 1
	if params.berserker then
		local health_ratio = tweak_data.player.damage.REVIVE_HEALTH_STEPS[1] * managers.player:upgrade_value('player', 'revived_health_regain', 1)
		local damage_health_ratio = managers.player:get_damage_health_ratio(health_ratio, primary_category or '')
		berserker_mul = 1 + managers.player:upgrade_value('player', params.berserker, 0) * damage_health_ratio
	end

	local all_mul = headshot_mul * spotter_mul * underdog_mul * overkill_mul * berserker_mul

	local th_mul1, th_mul2, th_mul3, th_mul4
	if params.trigger_happy then
		local td = tweak_data.upgrades.values.pistol.stacking_hit_damage_multiplier[params.trigger_happy]
		if params.trigger_happy == 1 then
			-- duration 2 sec, show breakpoints starting from scratch
			th_mul1 = td.damage_bonus
			th_mul2 = th_mul1 * th_mul1
			th_mul3 = th_mul2 * th_mul1
			th_mul4 = th_mul3 * th_mul1
		else
			-- duration 10 sec, consider effect is almost always active
			th_mul1 = td.damage_bonus
			all_mul = all_mul * (th_mul1 * th_mul1 * th_mul1 * th_mul1)
		end
	end

	local previous_bp
	for i = 1, _HEALTH_GRANULARITY do
		local crit_nr = math.ceil(i * crit_chance)

		local final_i = i
		if th_mul2 and crit_nr > 0 then
			-- for crits, first bullet is always accounted as such,
			-- lazily assume that next is 4th (depending on crit chance, could be more but... *yawn*)
			final_i = final_i
				+ (crit_mul - 1)
				+ (i > 1 and (th_mul1 - 1) or 0)
				+ (i > 2 and (th_mul2 - 1) or 0)
				+ (i > 3 and (th_mul3 * (crit_nr > 1 and crit_mul or 1) - 1) or 0)
			if i > 4 then
				local remaining = i - 4
				if crit_nr > 2 then
					final_i = final_i + (crit_nr - 2) * (th_mul4 * crit_mul - 1)
					remaining = remaining - (crit_nr - 2)
				end
				final_i = final_i + remaining * (th_mul4 - 1)
			end
		elseif th_mul2 then
			final_i = final_i
				+ (i > 1 and (th_mul1 - 1) or 0)
				+ (i > 2 and (th_mul2 - 1) or 0)
				+ (i > 3 and (th_mul3 - 1) or 0)
				+ (i > 4 and (th_mul4 - 1) * (i - 4) or 0)
		elseif crit_nr > 0 then
			final_i = final_i + (crit_mul - 1) * crit_nr
		end

		local dmg = health / final_i
		local bp = math.ceil(math.clamp(dmg / _HEALTH_INIT_PRECENT, 1, _HEALTH_GRANULARITY)) * _HEALTH_INIT_PRECENT

		-- NB: crits and trigger_happy brought in too many granular roundings
		if final_i == i then
			bp = bp - _HEALTH_INIT_PRECENT

		--[[ debug
		elseif params.crits and params.trigger_happy ~= 1 then
			local crit_dmg = math.ceil(math.clamp((crit_mul * bp) / _HEALTH_INIT_PRECENT, 1, _HEALTH_GRANULARITY)) * _HEALTH_INIT_PRECENT
			local dmg_done = crit_dmg * crit_nr + bp * (i - crit_nr)
			if dmg_done < health then
				log(string.format('%s\t%i\t%i\t%f\t%i\t%.1f', unit_type, i, final_i, _HEALTH_INIT_PRECENT, health, dmg_done))
			end

		elseif params.trigger_happy == 1 then
			if params.crits then
				-- TODO
			else
				local dmg_done = bp
					+ (i > 1 and bp * th_mul1 or 0)
					+ (i > 2 and bp * th_mul2 or 0)
					+ (i > 3 and bp * th_mul3 or 0)
					+ (i > 4 and bp * th_mul4 * (i - 4) or 0)
				if dmg_done < health then
					log(string.format('%s\t%i\t%i\t%f\t%i\t%.1f', unit_type, i, final_i, _HEALTH_INIT_PRECENT, health, dmg_done))
				end
			end
		--]]
		end

		bp = bp / all_mul
		if previous_bp == bp then
		elseif damage_clamp and bp > damage_clamp then
			break
		else
			if i > 1 and bp < 10 then
				break
			end
			result[i] = math.ceil(bp * 100) / 100
		end

		previous_bp = bp
	end

	return result
end

local function weapon_in_category(categories, ...)
	local arg = {...}

	if not categories then
		return false
	end

	for i = 1, #arg, 1 do
		if table.contains(categories, arg[i]) then
			return true
		end
	end

	return false
end

local function mws_get_ammo_type(data)
	local parts = tweak_data.weapon.factory.parts
	for _, part_id in ipairs(data.blueprint) do
		local part = parts[part_id]
		if part.type == 'ammo' and part.custom_stats then
			if part.custom_stats.launcher_grenade then
				local pt = tweak_data.projectiles[part.custom_stats.launcher_grenade]
				if pt.bullet_class then
					return pt.bullet_class
				end
				return pt.fire_dot_data and 'FlameBulletBase' or 'InstantExplosiveBulletBase' -- no but let's pretend yes
			end
			return part.custom_stats.bullet_class
		end
	end
	return nil
end

local function mws_equipped_selected()
	local slot_data = MoreWeaponStats.mws_slot_data
	if slot_data then
		return managers.blackmarket:get_crafted_category_slot(slot_data.category, slot_data.slot)
	end
end

function BlackMarketGui:mws_update_breakpoints()
	if not self._slot_data then
		return
	elseif self._slot_data.empty_slot or not self._slot_data.unlocked then
		self.mws_bp_panel:hide()
	else
		self.mws_bp_panel:show()
	end

	local data = self:mws_get_popup_data(false)
	if data then
		local original_primary = BlackMarketManager.equipped_primary
		local original_secondary = BlackMarketManager.equipped_secondary
		if self._slot_data.category == 'primaries' then
			BlackMarketManager.equipped_primary = mws_equipped_selected
		elseif self._slot_data.category == 'secondaries' then
			BlackMarketManager.equipped_secondary = mws_equipped_selected
		end

		local ammo_type = mws_get_ammo_type(data)
		local explosion = ammo_type == 'InstantExplosiveBulletBase'
		local fire = ammo_type == 'FlameBulletBase' or weapon_in_category(data.categories, 'flamethrower')

		local bonuses = self.mws_bonuses
		local berserker = bonuses.wolverine.checked and (weapon_in_category(data.categories, 'saw') and 'melee_damage_health_ratio_multiplier' or 'damage_health_ratio_multiplier')
		local body_expertise = bonuses.body_expertise.checked and ((data.tweak.FIRE_MODE == 'auto' or data.tweak.CAN_TOGGLE_FIREMODE) and weapon_in_category(data.categories, 'smg', 'lmg', 'assault_rifle', 'minigun') or weapon_in_category(data.categories, 'bow', 'saw'))
		local crits = bonuses.backstab.checked and not weapon_in_category(data.categories, 'grenade_launcher')
		local overkill = bonuses.overkill.checked and weapon_in_category(data.categories, 'shotgun')
		local trigger_happy = bonuses.trigger_happy.checked and weapon_in_category(data.categories, 'pistol')

		local params = {
			explosion = explosion,
			fire = fire,
			headshot = bonuses.prison_wife.checked,
			spotter = bonuses.spotter_teamwork.checked and bonuses.spotter_teamwork.level or 0,
			underdog = bonuses.underdog.checked,
			overkill = overkill,
			body_expertise = body_expertise,
			crits = crits,
			trigger_happy = trigger_happy and bonuses.trigger_happy.level,
			berserker = berserker
		}
		if explosion then
			params.headshot = false
			params.spotter = math.min(1, params.spotter)
		end
		if fire then
			params.headshot = false
			params.spotter = 0
		end
		local breakpoints_data = MoreWeaponStats:get_all_breakpoints(params)
		self.mws_bp_current_damage = math.max(data.base_stats.damage.value + data.mods_stats.damage.value + data.skill_stats.damage.value, 0)
		self.mws_bp_ref_damage, self.mws_breakpoints = MoreWeaponStats:consolidate_breakpoints(breakpoints_data, self.mws_bp_current_damage, #self.mws_bp_damage)

		BlackMarketManager.equipped_primary = original_primary
		BlackMarketManager.equipped_secondary = original_secondary

		for _, cell_dmg in pairs(self.mws_bp_bullet) do
			cell_dmg:set_text('-')
			cell_dmg:set_color(Color.white:with_alpha(0.5))
		end

		local ut = MoreWeaponStats.unit_types
		for i, cell_dmg in pairs(self.mws_bp_damage) do
			local bp = self.mws_breakpoints[i]
			if bp then
				cell_dmg:set_text(string.format('%0.2f', bp.value))
				cell_dmg:set_color(bp.value == self.mws_bp_ref_damage and Color.yellow or Color.white:with_alpha(0.5))
				for _, unit_type in pairs(ut) do
					local cell_data = self.mws_bp_panel:child('mws_bp_bullet_' .. tostring(i) .. '_' .. unit_type)
					local hit_nr = bp.hits_nr[unit_type]
					local color = bp.value == self.mws_bp_ref_damage and Color.yellow or Color.white
					if not hit_nr then
						color = color:with_alpha(0.5)
						hit_nr = bp.herited_hits_nr[unit_type] or '-'
					end
					cell_data:set_color(color)
					cell_data:set_text(hit_nr)
				end
			else
				cell_dmg:set_text('-')
				cell_dmg:set_color(Color.white:with_alpha(0.5))
			end

		end
	end
end

function MoreWeaponStats:get_all_breakpoints(params)
	local result = {}
	for _, unit_type in pairs(self.unit_types) do
		result[unit_type] = self:get_breakpoints(unit_type, params)
	end
	return result
end

function MoreWeaponStats:consolidate_breakpoints(data, damage, amount_wanted)
	local all_bp = {}
	local ref_bp = -1
	for unit_type, bps in pairs(data) do
		for hit_nr, value in pairs(bps) do
			if value <= damage and value > ref_bp then
				ref_bp = value
			end

			local bp = all_bp[value]
			if not bp then
				bp = {
					value = value,
					hits_nr = {},
					herited_hits_nr = {}
				}
				all_bp[value] = bp
			end
			bp.hits_nr[unit_type] = hit_nr
		end
	end

	local tmp = {}
	local nr = 0
	for _, bp in pairs(all_bp) do
		nr = nr + 1
		tmp[nr] = bp
	end
	all_bp = tmp
	table.sort(all_bp, function (a, b)
		return a.value < b.value
	end)

	if self.settings.fill_breakpoints then
		local ut = self.unit_types
		local last_hit_nr = {}
		for i = 1, nr do
			local bp = all_bp[i]
			for _, unit_type in pairs(ut) do
				local hit_nr = bp.hits_nr[unit_type]
				if hit_nr then
					last_hit_nr[unit_type] = hit_nr
				else
					bp.herited_hits_nr[unit_type] = last_hit_nr[unit_type]
				end
			end
		end
	end

	if all_bp[1].value >= 20 then
		while all_bp[1] and all_bp[1].value < 20 do
			table.remove(all_bp, 1)
			nr = nr - 1
		end
	end

	local result
	if amount_wanted >= nr then
		result = all_bp
	else
		result = {}
		for i = 1, nr do
			local bp = all_bp[i]
			if bp.value == ref_bp then
				local to_add = amount_wanted - 1
				local half_m = (to_add - (to_add % 2)) / 2
				local half_p = half_m + (to_add % 2)

				if half_m >= i then
					local diff = half_m - i + 1
					half_p = half_p + diff
					half_m = half_m - diff
				end

				if half_p > nr - i then
					local diff = half_p - (nr - i)
					half_p = half_p - diff
					half_m = half_m + diff
				end

				local nr2 = 1
				for j = i - half_m, i + half_p do
					result[nr2] = all_bp[j]
					nr2 = nr2 + 1
				end
				break
			end
		end
	end

	return ref_bp, result
end

local mws_original_blackmarketgui_mousemoved = BlackMarketGui.mouse_moved
function BlackMarketGui:mouse_moved(o, x, y)
	if self.mws_breakpoints and self._enabled and not self._renaming_item then
		if self.mws_bp_panel:inside(x, y) then
			if not managers.network:session() then
				for i, bmp in pairs(self.mws_bp_difficulty_bitmap) do
					if bmp:inside(x, y) then
						return true, 'link'
					end
				end
			end
			for i, bmp in pairs(self.mws_bp_skill_bitmap) do
				if self.mws_bonuses[bmp:name()].available and bmp:inside(x, y) then
					return true, 'link'
				end
			end
		end
	end

	return mws_original_blackmarketgui_mousemoved(self, o, x, y)
end

function BlackMarketGui:mws_bp_click_on_bonus(bmp)
	local enable = bmp:alpha() ~= _alpha_enabled
	bmp:set_alpha(enable and _alpha_enabled or _alpha_disabled)
	self.mws_bonuses[bmp:name()].checked = enable
end

local mws_original_blackmarketgui_mousepressed = BlackMarketGui.mouse_pressed
function BlackMarketGui:mouse_pressed(button, x, y)
	if self.mws_breakpoints and self._enabled and not self._renaming_item and button == Idstring('0') then
		if self.mws_bp_panel:inside(x, y) then
			for i, bmp in pairs(self.mws_bp_difficulty_bitmap) do
				if bmp:inside(x, y) then
					if self:mws_update_difficulty(tweak_data:index_to_difficulty(i + 1), true) then
						self:mws_update_breakpoints()
					end
					break
				end
			end
			for i, bmp in pairs(self.mws_bp_skill_bitmap) do
				if self.mws_bonuses[bmp:name()].available and bmp:inside(x, y) then
					self:mws_bp_click_on_bonus(bmp)
					self:mws_update_breakpoints()
					break
				end
			end
		end
	end

	return mws_original_blackmarketgui_mousepressed(self, button, x, y)
end
