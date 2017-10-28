
-- create the core mod object
_G.R9K = {}
R9K.version =								"2.0"

R9K.WEAPON_PRIMARY = 						1
R9K.WEAPON_SECONDARY = 						2
R9K.WEAPON_POSITION_HIP =					1
R9K.WEAPON_POSITION_AIM =					2

-- add functions
dofile(ModPath .. "lua/_reticle9k_functions.lua")

-- add som data
R9K.mod_path =								ModPath
R9K.save_path =								SavePath .. "reticle9k_"
R9K.localization_path =						R9K.mod_path .. "loc/"
R9K.localization_default_file =				R9K.localization_path .. "english.txt"
R9K.menu_configuration_file =				R9K.mod_path .. "cfg/mod_options_menu.txt"
R9K.texture_path_gage =						"units/pd2_dlc1/weapons/wpn_effects_textures/"
R9K.texture_path_butcher =					"units/pd2_dlc_butcher_mods/weapons/wpn_effects_textures/"
--R9K.mod_announce_host =						"using mod: reticle9k (_crosshair_customization_)"
R9K.announce_list_length =					20

R9K.quick_edit_mode =						1
R9K.quick_edit_timeout =					7
R9K.quick_edit_context =					1
R9K.quick_edit_context_weapon =				R9K.WEAPON_PRIMARY
R9K.quick_edit_context_weapon_position =	R9K.WEAPON_POSITION_HIP
R9K.game_weapon =							R9K.WEAPON_SECONDARY
R9K.game_weapon_position =					R9K.WEAPON_POSITION_HIP
R9K.delayed_remove_quick_edit_menu_id =		""
R9K.uid =									0

R9K.authorTexts = {
	"Version " .. R9K.version,
	"<( MurderSpray )>",
	"<( Tatsu! )>",
	"<( DazAttack )>",
	"<( Baron O' Beef-Dip )>",
	"The Reticle",
	"Is",
	"OVER9000 !!!",
	"See: readme.txt"
}

R9K.quick_edit_modes = {
	{ mode = "context",			id_loc_mode = "r9k_id_loc_quick_edit_mode_context",			id_loc_mode_description = "r9k_id_loc_quick_edit_mode_context_description"			},
	{ mode = "display",			id_loc_mode = "r9k_id_loc_quick_edit_mode_display",			id_loc_mode_description = "r9k_id_loc_quick_edit_mode_display_description"			},
	{ mode = "type",			id_loc_mode = "r9k_id_loc_quick_edit_mode_type",			id_loc_mode_description = "r9k_id_loc_quick_edit_mode_type_description"				},
	{ mode = "size",			id_loc_mode = "r9k_id_loc_quick_edit_mode_size",			id_loc_mode_description = "r9k_id_loc_quick_edit_mode_size_description"				},
	{ mode = "color",			id_loc_mode = "r9k_id_loc_quick_edit_mode_color",			id_loc_mode_description = "r9k_id_loc_quick_edit_mode_color_description"			},
	{ mode = "saturation",		id_loc_mode = "r9k_id_loc_quick_edit_mode_saturation",		id_loc_mode_description = "r9k_id_loc_quick_edit_mode_saturation_description"		},
	{ mode = "opacity",			id_loc_mode = "r9k_id_loc_quick_edit_mode_opacity",			id_loc_mode_description = "r9k_id_loc_quick_edit_mode_opacity_description"			},
	{ mode = "settings",		id_loc_mode = "r9k_id_loc_quick_edit_mode_settings",		id_loc_mode_description = "r9k_id_loc_quick_edit_mode_settings_description"			},
	{ mode = "readme",			id_loc_mode = "r9k_id_loc_quick_edit_mode_readme",			id_loc_mode_description = "r9k_id_loc_quick_edit_mode_readme_description"			}
}

R9K.reticle_textures = {
	{ uri = R9K.texture_path_gage    .. "wpn_sight_reticle_s_1",	id = "Dot 1"			},	-- disabled: this so you can override it with an empty texture thus "hiding" the weapons original sight reticle
	{ uri = R9K.texture_path_gage    .. "wpn_sight_reticle_m_1",	id = "Dot 2 / Custom"	},	-- use this one to override with a custom reticle
	{ uri = R9K.texture_path_gage    .. "wpn_sight_reticle_l_1",	id = "Dot 3"			},
	{ uri = R9K.texture_path_gage    .. "wpn_sight_reticle_2",		id = "Cross 1"			},
	{ uri = R9K.texture_path_gage    .. "wpn_sight_reticle_3",		id = "Cross 2"			},
	{ uri = R9K.texture_path_gage    .. "wpn_sight_reticle_4",		id = "Cross 3"			}
	--{ uri = R9K.texture_path_gage    .. "wpn_sight_reticle_5",		id = "Circle 1"			},
	--{ uri = R9K.texture_path_gage    .. "wpn_sight_reticle_6",		id = "Circle 2"			},
	--{ uri = R9K.texture_path_gage    .. "wpn_sight_reticle_7",		id = "Circle 3"			},
	--{ uri = R9K.texture_path_gage    .. "wpn_sight_reticle_8",		id = "Circle 4"			},
	--{ uri = R9K.texture_path_gage    .. "wpn_sight_reticle_9",		id = "Angle 1"			},
	--{ uri = R9K.texture_path_gage    .. "wpn_sight_reticle_10",		id = "Angle 2"			},
	--{ uri = R9K.texture_path_butcher .. "wpn_sight_reticle_11",		id = "First Circle"		},
	--{ uri = R9K.texture_path_butcher .. "wpn_sight_reticle_12",		id = "Flat"				},
	--{ uri = R9K.texture_path_butcher .. "wpn_sight_reticle_13",		id = "Sun"				},
	--{ uri = R9K.texture_path_butcher .. "wpn_sight_reticle_14",		id = "Hunter"			},
	--{ uri = R9K.texture_path_butcher .. "wpn_sight_reticle_15",		id = "On/Off"			},
	--{ uri = R9K.texture_path_butcher .. "wpn_sight_reticle_16",		id = "Cross"			},
	--{ uri = R9K.texture_path_butcher .. "wpn_sight_reticle_17",		id = "Insert Here"		},
	--{ uri = R9K.texture_path_butcher .. "wpn_sight_reticle_18",		id = "Hashtag"			},
	--{ uri = R9K.texture_path_butcher .. "wpn_sight_reticle_19",		id = "Overkill"			},
	--{ uri = R9K.texture_path_butcher .. "wpn_sight_reticle_20",		id = "Starbreeze"		},
	--{ uri = R9K.texture_path_butcher .. "wpn_sight_reticle_21",		id = "Fuck You!"		},
	--{ uri = R9K.texture_path_butcher .. "wpn_sight_reticle_22",		id = "Rock On!"			},
	--{ uri = R9K.texture_path_butcher .. "wpn_sight_reticle_23",		id = "Lion Game Lion"	}
}

R9K.reticle_texture_colors = {
	{ color = Color.red,	id_loc_name = "r9k_id_loc_color_red",		texture_postfix = "_il"			},
	--{ color = Color.green,	id_loc_name = "r9k_id_loc_color_green",		texture_postfix = "_green_il"	},
--	{ color = Color.blue,	id_loc_name = "r9k_id_loc_color_blue",		texture_postfix = "_blue_il"	},
--	{ color = Color.yellow,	id_loc_name = "r9k_id_loc_color_yellow",	texture_postfix = "_yellow_il"	}
}

-- load the default settings / state
R9K:SetDefaultSettings()

-- load user specific settings if available
R9K:LoadSettings()

-- R9K:LogObject("R9K.settings", R9K.settings)
