Hooks:PostHook(CrimeSpreeTweakData, "init", "BLEH",function(self, tweak_data)

	
	self.crash_causes_loss = false
	--self.winning_streak_reset_on_failure = true
	--self.continue_cost = {1, 0.7}
	--self.cost_per_level = 0.001
	--self.base_difficulty = "overkill_145" -- raises the diff to DW  -- "overkill_145""sm_wish"
	self.randomization_cost = 1
	self.randomization_multiplier = 1
	
	
	end)


function CrimeSpreeTweakData:init_gage_assets(tweak_data)
	local asset_cost = 0
	self.max_assets_unlocked = 4
	self.assets = {}
	self.assets.increased_health = {}
	self.assets.increased_health.name_id = "menu_cs_ga_increased_health"
	self.assets.increased_health.unlock_desc_id = "menu_cs_ga_increased_health_desc"
	self.assets.increased_health.icon = "csb_health"
	self.assets.increased_health.cost = asset_cost
	self.assets.increased_health.data = {health = 10}
	self.assets.increased_health.class = "GageModifierMaxHealth"
	self.assets.increased_armor = {}
	self.assets.increased_armor.name_id = "menu_cs_ga_increased_armor"
	self.assets.increased_armor.unlock_desc_id = "menu_cs_ga_increased_armor_desc"
	self.assets.increased_armor.icon = "csb_armor"
	self.assets.increased_armor.cost = asset_cost
	self.assets.increased_armor.data = {armor = 10}
	self.assets.increased_armor.class = "GageModifierMaxArmor"
	self.assets.increased_stamina = {}
	self.assets.increased_stamina.name_id = "menu_cs_ga_increased_stamina"
	self.assets.increased_stamina.unlock_desc_id = "menu_cs_ga_increased_stamina_desc"
	self.assets.increased_stamina.icon = "csb_stamina"
	self.assets.increased_stamina.cost = asset_cost
	self.assets.increased_stamina.data = {stamina = 100}
	self.assets.increased_stamina.class = "GageModifierMaxStamina"
	self.assets.increased_ammo = {}
	self.assets.increased_ammo.name_id = "menu_cs_ga_increased_ammo"
	self.assets.increased_ammo.unlock_desc_id = "menu_cs_ga_increased_ammo_desc"
	self.assets.increased_ammo.icon = "csb_ammo"
	self.assets.increased_ammo.cost = asset_cost
	self.assets.increased_ammo.data = {ammo = 15}
	self.assets.increased_ammo.class = "GageModifierMaxAmmo"
	self.assets.increased_lives = {}
	self.assets.increased_lives.name_id = "menu_cs_ga_increased_lives"
	self.assets.increased_lives.unlock_desc_id = "menu_cs_ga_increased_lives_desc"
	self.assets.increased_lives.icon = "csb_lives"
	self.assets.increased_lives.cost = asset_cost
	self.assets.increased_lives.data = {lives = 1}
	self.assets.increased_lives.class = "GageModifierMaxLives"
	self.assets.increased_throwables = {}
	self.assets.increased_throwables.name_id = "menu_cs_ga_increased_throwables"
	self.assets.increased_throwables.unlock_desc_id = "menu_cs_ga_increased_throwables_desc"
	self.assets.increased_throwables.icon = "csb_throwables"
	self.assets.increased_throwables.cost = asset_cost
	self.assets.increased_throwables.data = {throwables = 70}
	self.assets.increased_throwables.class = "GageModifierMaxThrowables"
	self.assets.increased_deployables = {}
	self.assets.increased_deployables.name_id = "menu_cs_ga_increased_deployables"
	self.assets.increased_deployables.unlock_desc_id = "menu_cs_ga_increased_deployables_desc"
	self.assets.increased_deployables.icon = "csb_deployables"
	self.assets.increased_deployables.cost = asset_cost
	self.assets.increased_deployables.data = {deployables = 50}
	self.assets.increased_deployables.class = "GageModifierMaxDeployables"
	self.assets.increased_absorption = {}
	self.assets.increased_absorption.name_id = "menu_cs_ga_increased_absorption"
	self.assets.increased_absorption.unlock_desc_id = "menu_cs_ga_increased_absorption_desc"
	self.assets.increased_absorption.icon = "csb_absorb"
	self.assets.increased_absorption.cost = asset_cost
	self.assets.increased_absorption.data = {absorption = 0.5}
	self.assets.increased_absorption.class = "GageModifierDamageAbsorption"
	self.assets.quick_reload = {}
	self.assets.quick_reload.name_id = "menu_cs_ga_quick_reload"
	self.assets.quick_reload.unlock_desc_id = "menu_cs_ga_quick_reload_desc"
	self.assets.quick_reload.icon = "csb_reload"
	self.assets.quick_reload.cost = asset_cost
	self.assets.quick_reload.data = {speed = 25}
	self.assets.quick_reload.class = "GageModifierQuickReload"
	self.assets.quick_switch = {}
	self.assets.quick_switch.name_id = "menu_cs_ga_quick_switch"
	self.assets.quick_switch.unlock_desc_id = "menu_cs_ga_quick_switch_desc"
	self.assets.quick_switch.icon = "csb_switch"
	self.assets.quick_switch.cost = asset_cost
	self.assets.quick_switch.data = {speed = 50}
	self.assets.quick_switch.class = "GageModifierQuickSwitch"
	self.assets.melee_invulnerability = {}
	self.assets.melee_invulnerability.name_id = "menu_cs_ga_melee_invulnerability"
	self.assets.melee_invulnerability.unlock_desc_id = "menu_cs_ga_melee_invulnerability_desc"
	self.assets.melee_invulnerability.icon = "csb_melee"
	self.assets.melee_invulnerability.cost = asset_cost
	self.assets.melee_invulnerability.data = {time = 5}
	self.assets.melee_invulnerability.class = "GageModifierMeleeInvincibility"
	self.assets.explosion_immunity = {}
	self.assets.explosion_immunity.name_id = "menu_cs_ga_explosion_immunity"
	self.assets.explosion_immunity.unlock_desc_id = "menu_cs_ga_explosion_immunity_desc"
	self.assets.explosion_immunity.icon = "csb_explosion"
	self.assets.explosion_immunity.cost = asset_cost
	self.assets.explosion_immunity.data = {}
	self.assets.explosion_immunity.class = "GageModifierExplosionImmunity"
	self.assets.life_steal = {}
	self.assets.life_steal.name_id = "menu_cs_ga_life_steal"
	self.assets.life_steal.unlock_desc_id = "menu_cs_ga_life_steal_desc"
	self.assets.life_steal.icon = "csb_lifesteal"
	self.assets.life_steal.cost = asset_cost
	self.assets.life_steal.data = {
		cooldown = 5,
		health_restored = 0.05,
		armor_restored = 0.05
	}
	self.assets.life_steal.class = "GageModifierLifeSteal"
	self.assets.quick_pagers = {}
	self.assets.quick_pagers.name_id = "menu_cs_ga_quick_pagers"
	self.assets.quick_pagers.unlock_desc_id = "menu_cs_ga_quick_pagers_desc"
	self.assets.quick_pagers.icon = "csb_pagers"
	self.assets.quick_pagers.cost = asset_cost
	self.assets.quick_pagers.data = {speed = 50}
	self.assets.quick_pagers.stealth = true
	self.assets.quick_pagers.class = "GageModifierQuickPagers"
	self.assets.increased_body_bags = {}
	self.assets.increased_body_bags.name_id = "menu_cs_ga_increased_body_bags"
	self.assets.increased_body_bags.unlock_desc_id = "menu_cs_ga_increased_body_bags_desc"
	self.assets.increased_body_bags.icon = "csb_bodybags"
	self.assets.increased_body_bags.cost = asset_cost
	self.assets.increased_body_bags.data = {bags = 2}
	self.assets.increased_body_bags.stealth = true
	self.assets.increased_body_bags.class = "GageModifierMaxBodyBags"
	self.assets.quick_locks = {}
	self.assets.quick_locks.name_id = "menu_cs_ga_quick_locks"
	self.assets.quick_locks.unlock_desc_id = "menu_cs_ga_quick_locks_desc"
	self.assets.quick_locks.icon = "csb_locks"
	self.assets.quick_locks.cost = asset_cost
	self.assets.quick_locks.data = {speed = 25}
	self.assets.quick_locks.stealth = true
	self.assets.quick_locks.class = "GageModifierQuickLocks"
end
function CrimeSpreeTweakData:init_modifiers(tweak_data)
	local health_increase = 25
	local damage_increase = 25
	self.max_modifiers_displayed = 3
	self.modifier_levels = {
		forced = 50,
		loud = 20,
		stealth = 26
	}
	self.modifiers = {
		forced = {
			{
				id = "damage_health_1",
				class = "ModifierEnemyHealthAndDamage",
				icon = "crime_spree_health",
				level = 50,
				data = {
					health = {1, "add"},
					damage = {15, "add"}
				}
			}
		},
		loud = {
			{
				id = "shield_reflect",
				class = "ModifierShieldReflect",
				icon = "crime_spree_shield_reflect",
				data = {}
			},
			{
				id = "cloaker_smoke",
				class = "ModifierCloakerKick",
				icon = "crime_spree_cloaker_smoke",
				data = {
					effect = {"smoke", "none"}
				}
			},
			{
				id = "medic_heal_1",
				class = "ModifierHealSpeed",
				icon = "crime_spree_medic_speed",
				data = {
					speed = {1, "add"}
				}
			},
			{
				id = "no_hurt",
				class = "ModifierNoHurtAnims",
				icon = "crime_spree_no_hurt",
				data = {}
			},
			{
				id = "taser_overcharge",
				class = "ModifierTaserOvercharge",
				icon = "crime_spree_taser_overcharge",
				data = {
					speed = {50, "add"}
				}
			},
			{
				id = "heavies",
				class = "ModifierHeavies",
				icon = "crime_spree_heavies",
				data = {}
			},
			{
				id = "medic_1",
				class = "ModifierMoreMedics",
				icon = "crime_spree_more_medics",
				data = {
					inc = {2, "add"}
				}
			},
			{
				id = "heavy_sniper",
				class = "ModifierHeavySniper",
				icon = "crime_spree_heavy_sniper",
				data = {
					spawn_chance = {5, "add"}
				}
			},
			{
				id = "dozer_rage",
				class = "ModifierDozerRage",
				icon = "crime_spree_dozer_rage",
				data = {
					damage = {100, "add"}
				}
			},
			{
				id = "cloaker_tear_gas",
				class = "ModifierCloakerTearGas",
				icon = "crime_spree_cloaker_tear_gas",
				data = {
					diameter = {4, "none"},
					damage = {30, "none"},
					duration = {10, "none"}
				}
			},
			{
				id = "dozer_1",
				class = "ModifierMoreDozers",
				icon = "crime_spree_more_dozers",
				data = {
					inc = {2, "add"}
				}
			},
			{
				id = "medic_heal_2",
				class = "ModifierHealSpeed",
				icon = "crime_spree_medic_speed",
				data = {
					speed = {1, "add"}
				}
			},
			{
				id = "dozer_lmg",
				class = "ModifierSkulldozers",
				icon = "crime_spree_dozer_lmg",
				data = {}
			},
			{
				id = "medic_adrenaline",
				class = "ModifierMedicAdrenaline",
				icon = "crime_spree_medic_adrenaline",
				data = {
					damage = {100, "add"}
				}
			},
			{
				id = "shield_phalanx",
				class = "ModifierShieldPhalanx",
				icon = "crime_spree_shield_phalanx",
				data = {}
			},
			{
				id = "dozer_2",
				class = "ModifierMoreDozers",
				icon = "crime_spree_more_dozers",
				data = {
					inc = {2, "add"}
				}
			},
			{
				id = "medic_deathwish",
				class = "ModifierMedicDeathwish",
				icon = "crime_spree_medic_deathwish",
				data = {}
			},
			{
				id = "dozer_minigun",
				class = "ModifierDozerMinigun",
				icon = "crime_spree_dozer_minigun",
				data = {}
			},
			{
				id = "medic_2",
				class = "ModifierMoreMedics",
				icon = "crime_spree_more_medics",
				data = {
					inc = {2, "add"}
				}
			},
			{
				id = "dozer_immunity",
				class = "ModifierExplosionImmunity",
				icon = "crime_spree_dozer_explosion",
				data = {}
			},
			{
				id = "dozer_medic",
				class = "ModifierDozerMedic",
				icon = "crime_spree_dozer_medic",
				data = {}
			},
			{
				id = "assault_extender",
				class = "ModifierAssaultExtender",
				icon = "crime_spree_assault_extender",
				data = {
					duration = {50, "add"},
					spawn_pool = {50, "add"},
					deduction = {4, "add"},
					max_hostages = {8, "none"}
				}
			},
			{
				id = "cloaker_arrest",
				class = "ModifierCloakerArrest",
				icon = "crime_spree_cloaker_arrest",
				data = {}
			},
			{
				id = "medic_rage",
				class = "ModifierMedicRage",
				icon = "crime_spree_medic_rage",
				data = {
					damage = {20, "add"}
				}
			}
		},
		stealth = {
			{
				id = "pagers_1",
				class = "ModifierLessPagers",
				icon = "crime_spree_pager",
				level = 26,
				data = {
					count = {1, "max"}
				}
			},
			{
				id = "civs_1",
				class = "ModifierCivilianAlarm",
				icon = "crime_spree_civs_killed",
				level = 26,
				data = {
					count = {10, "min"}
				}
			},
			{
				id = "conceal_1",
				class = "ModifierLessConcealment",
				icon = "crime_spree_concealment",
				level = 26,
				data = {
					conceal = {3, "add"}
				}
			},
			{
				id = "civs_2",
				class = "ModifierCivilianAlarm",
				icon = "crime_spree_civs_killed",
				level = 52,
				data = {
					count = {7, "min"}
				}
			},
			{
				id = "pagers_2",
				class = "ModifierLessPagers",
				icon = "crime_spree_pager",
				level = 78,
				data = {
					count = {2, "max"}
				}
			},
			{
				id = "conceal_2",
				class = "ModifierLessConcealment",
				icon = "crime_spree_concealment",
				level = 104,
				data = {
					conceal = {3, "add"}
				}
			},
			{
				id = "pagers_3",
				class = "ModifierLessPagers",
				icon = "crime_spree_pager",
				level = 130,
				data = {
					count = {3, "max"}
				}
			},
			{
				id = "civs_3",
				class = "ModifierCivilianAlarm",
				icon = "crime_spree_civs_killed",
				level = 156,
				data = {
					count = {4, "min"}
				}
			},
			{
				id = "pagers_4",
				class = "ModifierLessPagers",
				icon = "crime_spree_pager",
				level = 182,
				data = {
					count = {4, "max"}
				}
			}
		}
	}
	self.repeating_modifiers = {
		forced = {
			{
				id = "damage_health_rpt_",
				class = "ModifierEnemyHealthAndDamage",
				icon = "crime_spree_health",
				level = 5,
				data = {
					health = {20, "add"},
					damage = {15, "add"}
				}
			}
		}
	}
end