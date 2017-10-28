--Give melee kill movement speed
Hooks:PostHook(PlayerManager, "on_killshot", "ReworkPlayerManagerKill", function(self, killed_unit, variant)

    if variant == "melee" and self:has_category_upgrade("temporary", "melee_kill_bonus_movement_speed") then
        self:activate_temporary_upgrade("temporary", "melee_kill_bonus_movement_speed")
    end

end)

--Check  melee kill movement speed
local player_movementspeed_multiplier_orig = PlayerManager.movement_speed_multiplier
function PlayerManager:movement_speed_multiplier(speed_state, bonus_multiplier, upgrade_level, health_ratio)
    
    local multiplier = player_movementspeed_multiplier_orig(self, speed_state, bonus_multiplier, upgrade_level, health_ratio)
    
    multiplier = multiplier * self:temporary_upgrade_value("temporary", "melee_kill_bonus_movement_speed", 1)
    
	return multiplier
end

--stamina boost per bag (fix)
local playermanager_stamina_multiplier_bag_orig = PlayerManager.stamina_multiplier
function PlayerManager:stamina_multiplier()
	
	local multiplier = playermanager_stamina_multiplier_bag_orig(self)
	
	if self:has_category_upgrade("player", "secured_bags_stamina_multiplier") then
		local bags = 0
		bags = bags + (managers.loot:get_secured_mandatory_bags_amount() or 0)
		bags = bags + (managers.loot:get_secured_bonus_bags_amount() or 0)
		multiplier = multiplier + bags * (self:upgrade_value("player", "secured_bags_stamina_multiplier", 1) - 1)
	end
	
	return multiplier
end

--armour boost per bag (fix)
local playermanager_armour_multiplier_bag_orig = PlayerManager.body_armor_skill_multiplier
function PlayerManager:body_armor_skill_multiplier(override_armor)
	
	local multiplier = playermanager_armour_multiplier_bag_orig(self, override_armor)
	
	if self:has_category_upgrade("player", "secured_bags_armour_multiplier") then
		local bags = 0
		bags = bags + (managers.loot:get_secured_mandatory_bags_amount() or 0)
		bags = bags + (managers.loot:get_secured_bonus_bags_amount() or 0)
		multiplier = multiplier + bags * (self:upgrade_value("player", "secured_bags_armour_multiplier", 1) - 1)
	end
	
	return multiplier
end

--armour boost for having a converted (fix)
local playermanager_armour_multiplier_convert_orig = PlayerManager.body_armor_skill_multiplier
function PlayerManager:body_armor_skill_multiplier(override_armor)
	
	local multiplier = playermanager_armour_multiplier_convert_orig(self, override_armor)
	
	if self:num_local_minions() > 0 and self:has_category_upgrade("player", "convert_has_armour_multiplier") then
		multiplier = multiplier * (self:upgrade_value("player", "convert_has_armour_multiplier", 1) - 1)
	end
	
	return multiplier
end

--function PlayerManager:_on_enter_trigger_happy_event(attacker_unit, unit, variant)
--	if attacker_unit == self:player_unit() and variant == "bullet" and not self._coroutine_mgr:is_running("trigger_happy") and self:is_current_weapon_of_category("pistol") then
--		local data = self:upgrade_value("pistol", "stacking_hit_damage_multiplier", 0)
--		if data ~= 0 then
--			self._coroutine_mgr:add_coroutine("trigger_happy", PlayerAction.TriggerHappy, self, data.damage_bonus, data.max_stacks, Application:time() + data.max_time)
--		end
--	end
--end


-- armour addend 
local playermanager_armour_addend_lucario_orig = PlayerManager.body_armor_skill_addend
function PlayerManager:body_armor_skill_addend(override_armor)

	local addend = playermanager_armour_addend_lucario_orig(self, override_armor)
	
	if self:has_category_upgrade("player", "lucario_armour_addend") then
		addend = addend + (self:upgrade_value("player", "lucario_armour_addend", 1) - 1)
	end
	
	return addend
end

--	if self:num_local_minions() > 0 then
--		multiplier = multiplier + (self:upgrade_value("player", "minion_master_speed_multiplier", 1) - 1)

-- damage reduction based on health ratio?

--local playermanager_damage_resist_health_orig = PlayerManager.damage_reduction_skill_multiplier
--function PlayerManager:damage_reduction_skill_multiplier(damage_type, current_state, enemy_type)

--	local multiplier = playermanager_damage_resist_health_orig(self, damage_type, current_state, enemy_type)
	
--	local dmg_red_mul = self:team_upgrade_value("damage_dampener", "team_damage_reduction", 1)
	
--	if self:has_category_upgrade("player", "damage_resist_endure_it") then
--		local health_ratio = self:player_unit():character_damage():health_ratio()
--		local min_ratio = self:upgrade_value("player", "damage_resist_endure_it")
--		if health_ratio < min_ratio then
--			dmg_red_mul = dmg_red_mul - (1 - dmg_red_mul)
--		end
--	end
--	
--	multiplier = multiplier * dmg_red_mul
--	
--	return multiplier
--end

-- armour based on health ratio?

--local playermanager_armour_boosted_health_orig = PlayerManager.body_armor_skill_multiplier
--function PlayerManager:body_armor_skill_multiplier(override_armor)

--	local multiplier = playermanager_armour_boosted_health_orig(self, override_armor)
	
--	if self:has_category_upgrade("player", "armour_boost_endure_it") then
--		local health_ratio = self:player_unit():character_damage():health_ratio()
--		local min_ratio = self:upgrade_value("player", "armour_boost_endure_it")
--		if health_ratio < min_ratio then
--			multiplier = multiplier - (1 - multiplier)
--		end
--	end
	
	--multiplier = multiplier * dmg_red_mul
	
--	return multiplier
--end
	
--	if self:has_category_upgrade("player", "passive_damage_reduction") then
--		local health_ratio = self:player_unit():character_damage():health_ratio()
--		local min_ratio = self:upgrade_value("player", "passive_damage_reduction")
--		if health_ratio < min_ratio then
--			dmg_red_mul = dmg_red_mul - (1 - dmg_red_mul)
--		end
--	end

--function PlayerManager:body_armor_skill_addend(override_armor)
--	local addend = 0
--	addend = addend + self:upgrade_value("player", tostring(override_armor or managers.blackmarket:equipped_armor(true, true)) .. "_armor_addend", 0)
--	if self:has_category_upgrade("player", "armor_increase") then
--		local health_multiplier = self:health_skill_multiplier()
--		local max_health = (PlayerDamage._HEALTH_INIT + self:thick_skin_value()) * health_multiplier
--		addend = addend + max_health * self:upgrade_value("player", "armor_increase", 1)
--	end
--	return addend
--end


-- self._player_timer = TimerManager:timer(ids_player) or TimerManager:make_timer(ids_player, TimerManager:pausable())

--	if self:has_category_upgrade("player", "secured_bags_speed_multiplier") then
--		local bags = 0
--		bags = bags + (managers.loot:get_secured_mandatory_bags_amount() or 0)
--		bags = bags + (managers.loot:get_secured_bonus_bags_amount() or 0)
--		multiplier = multiplier + bags * (self:upgrade_value("player", "secured_bags_speed_multiplier", 1) - 1)
--	end

--Give melee kill armour value
--Hooks:PostHook(PlayerManager, "on_killshot", "ArmorPlayerManagerKill", function(self, killed_unit, variant)
--
 --   if self:has_category_upgrade("temporary", "melee_kill_bonus_armour_value") then
  --      self:activate_temporary_upgrade("temporary", "melee_kill_bonus_armour_value")
   -- end
--
--end)

--Check  melee kill armour value
--local playermanager_armor_mul_melee_gain_orig = PlayerManager.body_armor_skill_multiplier
--function PlayerManager:body_armor_skill_multiplier(override_armor)
 --   
  --  local multiplier = player_armor_mul_melee_gain_orig(self, override_armor)
  --  
  --  multiplier = multiplier * self:temporary_upgrade_value("temporary", "melee_kill_bonus_armour_value", 1)
   -- 
--	return multiplier
--end

--armor penalty
--local playermanager_armor_mul_health_ratio_orig = PlayerManager.body_armor_skill_multiplier
--function PlayerManager:body_armor_skill_multiplier(override_armor, health_ratio)
--	
--	local multiplier = playermanager_armor_mul_health_ratio_orig(self, override_armor, health_ratio)
--    
--	if health ratio then
--		local damage_health_ratio = self:get_damage_health_ratio(health_ratio, "armor_skill")
--        multiplier = multiplier * (1 + managers.player:upgrade_value("player", "armour_skill_damage_health_ratio_multiplier", 0) * damage_health_ratio) 
--    end  
--    
--	return multiplier
--end

--Give damage resist melee kill
--Hooks:PostHook(PlayerManager, "on_killshot", "LucPlayerManagerKill", function(self, killed_unit, variant)
--
--    if variant == "melee" and self:has_category_upgrade("temporary", "melee_kill_bonus_damage_resist_lucario") then
--        self:activate_temporary_upgrade("temporary", "melee_kill_bonus_damage_resist_lucario")
--    end
--
--end

--Check damage resist
--local playermanager_damage_dampener_lucario_banter_orig = PlayerManager.damage_reduction_skill_multiplier
--function PlayerManager:damage_reduction_skill_multiplier(damage_type, current_state, enemy_type)
--    
--    local multiplier = playermanager_damage_dampener_lucario_banter_orig(self, damage_type, current_state, enemy_type)
--    
 --   multiplier = multiplier * self:temporary_upgrade_value("temporary", "melee_kill_bonus_damage_resist_lucario", 1)
 --   
--	return multiplier
--end


--Hyper Debuffed Executioner Health Regen (To allow this huge armour Damage resist buff!)

--local player_health_regen_executioner_orig = PlayerManager.health_regen()
--function PlayerManager:health_regen()

--	local health_regen = player_health_regen_executioner_orig(self)
	
--	health_regen = health_regen + self:upgrade_value("player", "executioner_health_regen", 0)
	
--	return health_regen

--end

-- armor kit damage reduction on use
--local playermanager_damage_reduction_armor_kit_orig = PlayerManager.damage_reduction_skill_multiplier
--function PlayerManager:damage_reduction_skill_multiplier(damage_type, current_state, enemy_type)
--
--	local multiplier = playermanager_damage_reduction_armor_kit_orig(self, damage_type, current_state, enemy_type)
--	
--	if self:has_category_upgrade("temporary", "armor_kit_damage_reduction") then
--		multiplier = multiplier * self:temporary_upgrade_value("temporary", "armor_kit_damage_reduction", 1)
--	end
--	
--	return multiplier
--end

--local playermanager_damage_health_ratio_active = PlayerManager:is_damage_health_ratio_active
--function PlayerManager:is_damage_health_ratio_active(health_ratio)


--function PlayerManager:is_damage_health_ratio_active(health_ratio)
--	return self:has_category_upgrade("player", "melee_damage_health_ratio_multiplier") and self:get_damage_health_ratio(health_ratio, "melee") > 0 or self:has_category_upgrade("player", "armor_regen_damage_health_ratio_multiplier") and 0 < self:get_damage_health_ratio(health_ratio, "armor_regen") or self:has_category_upgrade("player", "damage_health_ratio_multiplier") and 0 < self:get_damage_health_ratio(health_ratio, "damage") or self:has_category_upgrade("player", "movement_speed_damage_health_ratio_multiplier") and 0 < self:get_damage_health_ratio(health_ratio, "movement_speed") or self:has_category_upgrade("player", "armour_bonus_damage_health_ratio_multiplier") and self:get_damage_health_ratio(health_ratio, "armor_skill") > 0
--end

--	if health_ratio then
--		local damage_health_ratio = self:get_damage_health_ratio(health_ratio, "movement_speed")
--		multiplier = multiplier * (1 + managers.player:upgrade_value("player", "movement_speed_damage_health_ratio_multiplier", 0) * damage_health_ratio)
--	end

--armor penalty
--local playermanager_armor_mul_health_ratio_orig = PlayerManager.body_armor_skill_multiplier
--function PlayerManager:body_armor_skill_multiplier(override_armor, health_ratio)
--	
--	local multiplier = playermanager_armor_mul_health_ratio_orig(self, override_armor, health_ratio)
--    
--	if health ratio then
--		local damage_health_ratio = self:get_damage_health_ratio(health_ratio, "armor_skill")
--        multiplier = multiplier * (1 + managers.player:upgrade_value("player", "armour_skill_damage_health_ratio_multiplier", 0) * damage_health_ratio) 
--    end  
--    
--	return multiplier
--end




--damage resistance based on armour test, does it work? Answer : ocourse
local playermanager_damage_reduction_armor_based_2_orig = PlayerManager.damage_reduction_skill_multiplier
function PlayerManager:damage_reduction_skill_multiplier(damage_type, current_state, enemy_type)

	local multiplier = playermanager_damage_reduction_armor_based_2_orig(self, damage_type, current_state, enemy_type)
	
	if self:has_category_upgrade("player", "level_2_damage_resist_addend") then
		multiplier = multiplier * self:upgrade_value("player", tostring(override_armor or managers.blackmarket:equipped_armor(true, true)) .. "_damage_resist_addend")
	end
	
	return multiplier
end

--damage resistance based on armour test, does it work? Answer : ye
local playermanager_damage_reduction_armor_based_1_orig = PlayerManager.damage_reduction_skill_multiplier
function PlayerManager:damage_reduction_skill_multiplier(damage_type, current_state, enemy_type)

	local multiplier = playermanager_damage_reduction_armor_based_1_orig(self, damage_type, current_state, enemy_type)
	
	if self:has_category_upgrade("player", "level_1_damage_resist_addend") then
		multiplier = multiplier * self:upgrade_value("player", tostring(override_armor or managers.blackmarket:equipped_armor(true, true)) .. "_damage_resist_addend")
	end
	
	return multiplier
end

--damage resistance based on armour test, does it work? Answer : yep
local playermanager_damage_reduction_armor_based_3_orig = PlayerManager.damage_reduction_skill_multiplier
function PlayerManager:damage_reduction_skill_multiplier(damage_type, current_state, enemy_type)

	local multiplier = playermanager_damage_reduction_armor_based_3_orig(self, damage_type, current_state, enemy_type)
	
	if self:has_category_upgrade("player", "level_3_damage_resist_addend") then
		multiplier = multiplier * self:upgrade_value("player", tostring(override_armor or managers.blackmarket:equipped_armor(true, true)) .. "_damage_resist_addend")
	end
	
	return multiplier
end

--damage resistance based on armour test, does it work? Answer : aye
local playermanager_damage_reduction_armor_based_4_orig = PlayerManager.damage_reduction_skill_multiplier
function PlayerManager:damage_reduction_skill_multiplier(damage_type, current_state, enemy_type)

	local multiplier = playermanager_damage_reduction_armor_based_4_orig(self, damage_type, current_state, enemy_type)
	
	if self:has_category_upgrade("player", "level_4_damage_resist_addend") then
		multiplier = multiplier * self:upgrade_value("player", tostring(override_armor or managers.blackmarket:equipped_armor(true, true)) .. "_damage_resist_addend")
	end
	
	return multiplier
end

--damage resistance based on armour test, does it work? Answer : uhuh
local playermanager_damage_reduction_armor_based_5_orig = PlayerManager.damage_reduction_skill_multiplier
function PlayerManager:damage_reduction_skill_multiplier(damage_type, current_state, enemy_type)

	local multiplier = playermanager_damage_reduction_armor_based_5_orig(self, damage_type, current_state, enemy_type)
	
	if self:has_category_upgrade("player", "level_5_damage_resist_addend") then
		multiplier = multiplier * self:upgrade_value("player", tostring(override_armor or managers.blackmarket:equipped_armor(true, true)) .. "_damage_resist_addend")
	end
	
	return multiplier
end

--damage resistance based on armour test, does it work? Answer : sure does
local playermanager_damage_reduction_armor_based_6_orig = PlayerManager.damage_reduction_skill_multiplier
function PlayerManager:damage_reduction_skill_multiplier(damage_type, current_state, enemy_type)

	local multiplier = playermanager_damage_reduction_armor_based_6_orig(self, damage_type, current_state, enemy_type)
	
	if self:has_category_upgrade("player", "level_6_damage_resist_addend") then
		multiplier = multiplier * self:upgrade_value("player", tostring(override_armor or managers.blackmarket:equipped_armor(true, true)) .. "_damage_resist_addend")
	end
	
	return multiplier
end

--damage resistance based on armour test, does it work? Answer : must do
local playermanager_damage_reduction_armor_based_7_orig = PlayerManager.damage_reduction_skill_multiplier
function PlayerManager:damage_reduction_skill_multiplier(damage_type, current_state, enemy_type)

	local multiplier = playermanager_damage_reduction_armor_based_7_orig(self, damage_type, current_state, enemy_type)
	
	if self:has_category_upgrade("player", "level_7_damage_resist_addend") then
		multiplier = multiplier * self:upgrade_value("player", tostring(override_armor or managers.blackmarket:equipped_armor(true, true)) .. "_damage_resist_addend")
	end
	
	return multiplier
end

--damage resistance bonus for executioner
local playermanager_damage_dampener_executioner_orig = PlayerManager.damage_reduction_skill_multiplier
function PlayerManager:damage_reduction_skill_multiplier(damage_type, current_state, enemy_type)

	local multiplier = playermanager_damage_dampener_executioner_orig(self, damage_type, current_state, enemy_type)
	
	if self:has_category_upgrade("player", "damage_dampener_executioner") then
		multiplier = multiplier * self:upgrade_value("player", "damage_dampener_executioner")
	end
	
	return multiplier
end

--damage resistance bonus for exmilitary
local playermanager_damage_dampener_exmilitary_orig = PlayerManager.damage_reduction_skill_multiplier
function PlayerManager:damage_reduction_skill_multiplier(damage_type, current_state, enemy_type)

	local multiplier = playermanager_damage_dampener_exmilitary_orig(self, damage_type, current_state, enemy_type)
	
	if self:has_category_upgrade("player", "damage_dampener_exmilitary") then
		multiplier = multiplier * self:upgrade_value("player", "damage_dampener_exmilitary")
	end
	
	return multiplier
end

--damage resistance bonus for lucario
local playermanager_damage_dampener_lucario_passive_orig = PlayerManager.damage_reduction_skill_multiplier
function PlayerManager:damage_reduction_skill_multiplier(damage_type, current_state, enemy_type)

	local multiplier = playermanager_damage_dampener_lucario_passive_orig(self, damage_type, current_state, enemy_type)
	
	if self:has_category_upgrade("player", "damage_dampener_lucario_passive") then
		multiplier = multiplier * self:upgrade_value("player", "damage_dampener_lucario_passive")
	end
	
	return multiplier
end

--damage resistance bonus for sniper vs sniper???
local playermanager_damage_dampener_sniper_orig = PlayerManager.damage_reduction_skill_multiplier
function PlayerManager:damage_reduction_skill_multiplier(damage_type, current_state, enemy_type)

	local multiplier = playermanager_damage_dampener_sniper_orig(self, damage_type, current_state, enemy_type)
	
	if current_state == "carry" and self:has_category_upgrade("player", "damage_dampener_sniper") then
		multiplier = multiplier * managers.player:upgrade_value("player", "damage_dampener_sniper")
	end
	
	return multiplier
end

--Damage Absorption bonus? FAIL.
--local playermanager_damage_absorb_orig = PlayerManager.set_damage_absorption
--function PlayerManager:set_damage_absorption(value)
--
--	local value = playermanager_damage_absorb_orig(self, value)
--	
--	if self:has_category_upgrade("player", "damage_damage_absorb_pro") then
--		value = value + self:upgrade_value("player", "damage_damage_absorb_pro", 0)
--	end
	
--	return value
--end

--CopDamage and CopDamage.is_Sniper(enemy_type)
--CopDamage and CopDamage.Sniper(enemy_type)
--	if current_state and current_state:_interacting()  managers.player

--melee damage resistance bonus for executioner
local playermanager_melee_damage_dampener_executioner_orig = PlayerManager.damage_reduction_skill_multiplier
function PlayerManager:damage_reduction_skill_multiplier(damage_type, current_state, enemy_type)

	local multiplier = playermanager_melee_damage_dampener_executioner_orig(self, damage_type, current_state, enemy_type)
	
	if damage_type == "melee" and self:has_category_upgrade("player", "melee_damage_dampener_executioner") then
		multiplier = multiplier * self:upgrade_value("player", "melee_damage_dampener_executioner")
	end
	
	return multiplier
end

--executioner health regen custom (to nerf his overall survivability!)
local playermanager_health_regen_executioner_orig = PlayerManager.health_regen
function PlayerManager:health_regen()

	local health_regen = playermanager_health_regen_executioner_orig(self)
	
	if self:has_category_upgrade("player", "health_regen_executioner") then
		health_regen = health_regen + self:upgrade_value("player", "health_regen_executioner", 0)
	end
	
	return health_regen
end

--movement speed ?
local player_movementspeed_multiplier_orig = PlayerManager.movement_speed_multiplier
function PlayerManager:movement_speed_multiplier(speed_state, bonus_multiplier, upgrade_level, health_ratio)
    
    local multiplier = player_movementspeed_multiplier_orig(self, speed_state, bonus_multiplier, upgrade_level, health_ratio)
    
    multiplier = multiplier * self:temporary_upgrade_value("temporary", "movement_speed_boost", 1)
    
	return multiplier
end

--movement speed ?
local player_movementspeed_multiplier_orig = PlayerManager.movement_speed_multiplier
function PlayerManager:movement_speed_multiplier(speed_state, bonus_multiplier, upgrade_level, health_ratio)
    
    local multiplier = player_movementspeed_multiplier_orig(self, speed_state, bonus_multiplier, upgrade_level, health_ratio)
    
	if self:has_category_upgrade("player", "movement_speed_boost") then
		multiplier = multiplier * self:upgrade_value("player", "movement_speed_boost", 1)
    end
	
	return multiplier
end

--health bonus
local playermanager_health_mul_orig_bonus = PlayerManager.health_skill_multiplier
function PlayerManager:health_skill_multiplier(override_armor)
    
    local multiplier = playermanager_health_mul_orig_bonus(self, override_armor)
    
    if self:has_category_upgrade("player", "health_bonus_multiplier") then
        multiplier = multiplier * self:upgrade_value("player", "health_bonus_multiplier")
    end

    return multiplier
    
end

--armor penalty
local playermanager_armor_mul_orig = PlayerManager.body_armor_skill_multiplier
function PlayerManager:body_armor_skill_multiplier(override_armor)
	
	local multiplier = playermanager_armor_mul_orig(self, override_armor)
    
    if self:has_category_upgrade("player", "armour_penalty_multiplier") then
        multiplier = multiplier * self:upgrade_value("player", "armour_penalty_multiplier") 
    end  
    
	return multiplier
end

--stamina boost (fix)
local playermanager_stamina_multiplier_orig = PlayerManager.stamina_multiplier
function PlayerManager:stamina_multiplier()
	
	local multiplier = playermanager_stamina_multiplier_orig(self)
	
	if self:has_category_upgrade("player", "stamina_bonus_multiplier") then
		multiplier = multiplier + self:upgrade_value("player", "stamina_bonus_multiplier", 1) - 1
	end
	
	return multiplier
end

-- team stamina boost (needs fix)
--local playermanager_stamina_multiplier_orig = PlayerManager.stamina_multiplier
--function PlayerManager:stamina_multiplier()
	
	--local multiplier = playermanager_stamina_multiplier_orig()
	
	--if self:has_category_upgrade("team", "stamina_super_multiplier") then
		--multiplier = multiplier + team:upgrade_value("team", "stamina_super_multiplier")
	--end

	--return multiplier
--end

--dodge chance
local playermanager_dodge_chance_orig = PlayerManager.skill_dodge_chance
function PlayerManager:skill_dodge_chance(running, crouching, on_zipline, override_armor, detection_risk)
    
    local chance = playermanager_dodge_chance_orig(self, running, crouching, on_zipline, override_armor, detection_risk)
    
    if self:has_category_upgrade("player", "dodge_bonus_passive_always") then
        chance = chance + self:upgrade_value("player", "dodge_bonus_passive_always", 0)
    end
    
    return chance
	
end

--dodge chance ICTV answer : NO CLU
--local playermanager_dodge_chance_armor_based_7_orig = PlayerManager.skill_dodge_chance
--function PlayerManager:skill_dodge_chance(running, crouching, on_zipline, override_armor, detection_risk)
--    
--    local chance = playermanager_dodge_chance_armor_based_7_orig(self, running, crouching, on_zipline, override_armor, detection_risk)
--    
--    if self:has_category_upgrade("player", "level_7_dodge_addend") then
--		chance = chance + self:upgrade_value("player", tostring(override_armor or managers.blackmarket:equipped_armor(true, true)) .. "_dodge_addend", 0)
--    end
--    
--    return chance	
--end



--dodge bonusu on detection_risk (Fixed)
local playermanager_dodge_bonus_chance_orig = PlayerManager.skill_dodge_chance
function PlayerManager:skill_dodge_chance(running, crouching, on_zipline, override_armor, detection_risk)
    
    local multiplier = playermanager_dodge_bonus_chance_orig(self, crouching, on_zipline, override_armor, detection_risk)
	
    if self:has_category_upgrade("player", "detection_risk_add_super_dodge_percent") then
        --Apply armour bonus (multiplicatively)
        multiplier = multiplier + self:detection_risk_add_super_dodge_percent()
    end
    
	return multiplier
end

function PlayerManager:detection_risk_add_super_dodge_percent()
	local multiplier = 0
	local detection_risk_add_super_dodge_percent = managers.player:upgrade_value("player", "detection_risk_add_super_dodge_percent")
	multiplier = multiplier + self:get_value_from_risk_upgrade(detection_risk_add_super_dodge_percent)
	return multiplier
end

--someshite
--function PlayerManager:body_armor_skill_addend(override_armor)
--	local addend = 0
--	addend = addend + self:upgrade_value("player", tostring(override_armor or managers.blackmarket:equipped_armor(true, true)) .. "_armor_addend", 0)
--	if self:has_category_upgrade("player", "armor_increase") then
--		local health_multiplier = self:health_skill_multiplier()
--		local max_health = (PlayerDamage._HEALTH_INIT + self:thick_skin_value()) * health_multiplier
--		addend = addend + max_health * self:upgrade_value("player", "armor_increase", 1)
--	end
--	return addend
--end


--Armour multiplier on detection_risk (Fixed)
local playermanager_armor_mul_orig = PlayerManager.body_armor_skill_multiplier
function PlayerManager:body_armor_skill_multiplier(override_armor)
    
    local multiplier = playermanager_armor_mul_orig(self, override_armor)
    
    if self:has_category_upgrade("player", "detection_risk_add_armour_percent") then
        --Apply armour bonus (additively)
        multiplier = multiplier + self:detection_risk_armour_percent_bonus()
    end
    
	return multiplier
end

function PlayerManager:detection_risk_armour_percent_bonus()
	local multiplier = 0
	local detection_risk_add_armour_percent = managers.player:upgrade_value("player", "detection_risk_add_armour_percent")
	multiplier = multiplier + self:get_value_from_risk_upgrade(detection_risk_add_armour_percent)
	return multiplier
end

--Give armour% on civvy dom
--local playermanager_armour_multi_original = PlayerManager.body_armor_skill_multiplier
--function PlayerManager:body_armor_skill_multiplier(override_armor)

--	local multiplier = playermanager_armour_multi_original(self, override_armor)
	
--	if self:has_category_upgrade("player", "hostages_are_important") then
--		--hostage boosts armour? plz gabe
--		multiplier = multiplier + self:get_hostage_bonus_multiplier("hostages_are_important") - 1
--	end
	
--	return multiplier	
--end

--dodge bonus to level 7 ictv

local playermanager_dodge_chance_orig_lvl7 = PlayerManager.skill_dodge_chance
function PlayerManager:skill_dodge_chance(running, crouching, on_zipline, override_armor, detection_risk)
    
    local chance = playermanager_dodge_chance_orig_lvl7(self, running, crouching, on_zipline, override_armor, detection_risk)
    
    if self:has_category_upgrade("player", "level_7_dodge_bonus_passive_always_level_7") then
        chance = chance + self:upgrade_value("player", tostring(override_armor or managers.blackmarket:equipped_armor(true, true)) .. "_dodge_bonus_passive_always_level_7")
    end
    
    return chance
	
end

--	chance = chance + self:upgrade_value("player", tostring(override_armor or managers.blackmarket:equipped_armor(true, true)) .. "_dodge_addend_level_7", 0)

--Potential Dodge / damage resist / armour value on low HP?

--local playermanager_dodge_chance_orig_hp = PlayerManager.skill_dodge_chance
--function PlayerManager:skill_dodge_chance(running, health_ratio, crouching, on_zipline, override_armor, detection_risk)
--    
--    local chance = playermanager_dodge_chance_orig_hp(self, running, health_ratio, crouching, on_zipline, override_armor, detection_risk)
--    
--	if health_ratio then
--		local damage_health_ratio = self:get_damage_health_ratio(health_ratio, "dodge_bonus_passive_always_hp")
--		chance = chance + (1 - managers.player:upgrade_value("player", "dodge_bonus_passive_always_hp", 0) * damage_health_ratio)
--	end
--    
--    return chance
--	
--end

--	if health_ratio then
--		local damage_health_ratio = self:get_damage_health_ratio(health_ratio, "dodge_bonus_passive_always_hp")
--		chance = chance + (1 - managers.player:upgrade_value("player", "dodge_bonus_passive_always_hp", 0) * damage_health_ratio)
--	end
	
--    if self:has_category_upgrade("player", "dodge_bonus_passive_always_hp") then
   --     chance = chance + self:upgrade_value("player", "dodge_bonus_passive_always", 0)
 --   end
 
--damage resistance bonus vs bulldozer
--local playermanager_dozer_damage_dampener_orig = PlayerManager.damage_reduction_skill_multiplier
--function PlayerManager:damage_reduction_skill_multiplier(damage_type, current_state, enemy_type)
--
--	local multiplier = playermanager_dozer_damage_dampener_orig(self, damage_type, current_state, enemy_type)
--	
--	if enemy_type == "tank" and self:has_category_upgrade("player", "dozer_damage_dampener") then
--		multiplier = multiplier * self:upgrade_value("player", "dozer_damage_dampener")
--	end
--	
--	return multiplier
--end
-- Message On Screen
