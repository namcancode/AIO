_G.BB = _G.BB or {}
BB._path = ModPath
BB._data_path = SavePath .. "bb_data.txt"
BB._data = {}
BB.cops_to_intimidate = {}
BB.grace_period = 10

function BB:Save()
	local file = io.open( self._data_path, "w+" )
	if file then
		file:write( json.encode( self._data ) )
		file:close()
	end
end

function BB:Load()
	local file = io.open( self._data_path, "r" )
	if file then
		self._data = json.decode( file:read("*all") )
		file:close()
	end
end

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_BB", function(loc)
	for _, filename in pairs(file.GetFiles(BB._path .. "loc/")) do
		local str = filename:match('^(.*).txt$')
		if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
			loc:load_localization_file(BB._path .. "loc/" .. filename)
			break
		end
	end
	loc:load_localization_file(BB._path .. "loc/english.txt", false)
end)

Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_BB", function( menu_manager )
	MenuCallbackHandler.callback_health_choice = function(self, item)
		BB._data.health = item:value()
		BB:Save()
	end
	MenuCallbackHandler.callback_speed_choice = function(self, item)
		BB._data.speed = item:value()
		BB:Save()
	end
	MenuCallbackHandler.callback_move_choice = function(self, item)
		BB._data.move = item:value()
		BB:Save()
	end
	MenuCallbackHandler.callback_dodge_choice = function(self, item)
		BB._data.dodge = item:value()
		BB:Save()
	end
	MenuCallbackHandler.callback_firemode_toggle = function(self, item)
		BB._data.firemode = (item:value() == "on" and true or false)
		BB:Save()
	end
	MenuCallbackHandler.callback_dwn_toggle = function(self, item)
		BB._data.instadwn = (item:value() == "on" and true or false)
		BB:Save()
	end
	MenuCallbackHandler.callback_clk_toggle = function(self, item)
		BB._data.clkarrest = (item:value() == "on" and true or false)
		BB:Save()
	end
	MenuCallbackHandler.callback_chat_toggle = function(self, item)
		BB._data.chat = (item:value() == "on" and true or false)
		BB:Save()
	end
	MenuCallbackHandler.callback_doc_toggle = function(self, item)
		BB._data.doc = (item:value() == "on" and true or false)
		BB:Save()
	end
	MenuCallbackHandler.callback_dom_toggle = function(self, item)
		BB._data.dom = (item:value() == "on" and true or false)
		BB:Save()
	end
	MenuCallbackHandler.callback_biglob_toggle = function(self, item)
		BB._data.biglob = (item:value() == "on" and true or false)
		BB:Save()
	end
	MenuCallbackHandler.callback_reflex_toggle = function(self, item)
		BB._data.reflex = (item:value() == "on" and true or false)
		BB:Save()
	end
	MenuCallbackHandler.callback_maskup_toggle = function(self, item)
		BB._data.maskup = (item:value() == "on" and true or false)
		BB:Save()
	end
	MenuCallbackHandler.callback_equip_toggle = function(self, item)
		BB._data.equip = (item:value() == "on" and true or false)
		BB:Save()
	end
	MenuCallbackHandler.callback_combat_toggle = function(self, item)
		BB._data.combat = (item:value() == "on" and true or false)
		BB:Save()
	end
	MenuCallbackHandler.callback_ammo_toggle = function(self, item)
		BB._data.ammo = (item:value() == "on" and true or false)
		BB:Save()
	end
	BB:Load()
	MenuHelper:LoadFromJsonFile( BB._path .. "menu.txt", BB, BB._data )
end )

BB:Load()

function BB:add_cop_to_intimidation_list(unit_key)
	local t = TimerManager:game():time()
	local cop_key = self.cops_to_intimidate[unit_key]
	cop_key = t
	if Network:is_server() then
		local is_new = not cop_key or t - cop_key > self.grace_period
		if is_new then
			local p = pairs
			local gstate = managers.groupai:state()
			local function _dont_attack(unit)
				local data = unit:brain()._logic_data
				if data then
					local att_obj = data.attention_obj
					if att_obj then
						if att_obj.u_key == unit_key then
							CopLogicBase._set_attention_obj(data)
						end
					end
				end
			end
			for _, sighting in p(gstate._ai_criminals) do
				_dont_attack(sighting.unit)
			end
			for _, unit in p(gstate._converted_police) do
				_dont_attack(unit)
			end
		end
	end
end

if RequiredScript == "lib/managers/group_ai_states/groupaistatebase" then
	local p = pairs
	local math_clamp = math.clamp
	local old_cstcc = GroupAIStateBase.chk_say_teamAI_combat_chatter
	function GroupAIStateBase:chk_say_teamAI_combat_chatter(...)
		if BB._data.chat then
			return
		end
		return old_cstcc(self, ...)
	end
	local bb_original_groupaistatebase_ontasestart = GroupAIStateBase.on_tase_start
	function GroupAIStateBase:on_tase_start(cop_key, criminal_key, ...)
		local bot_record = self._ai_criminals[criminal_key]
		if bot_record then
			bot_record.unit:sound():say("f32x_any", true)
			self._police[cop_key].unit:contour():add("mark_enemy", true)
		end
		return bb_original_groupaistatebase_ontasestart(self, cop_key, criminal_key, ...)
	end
	function GroupAIStateBase:_get_balancing_multiplier(balance_multipliers)
		local nr_crim = 0
		for u_key, u_data in p(self:all_char_criminals()) do
			if not u_data.status then
				nr_crim = nr_crim + 1
			end
		end
		nr_crim = math_clamp(nr_crim, 1, 4)
		return balance_multipliers[nr_crim]
	end
end

if RequiredScript == "lib/units/player_team/teamaibase" then
	local is_server = Network:is_server()
	local old_post = TeamAIBase.post_init
	function TeamAIBase:post_init(...)
		old_post(self, ...)
		self._upgrades = {}
		self._upgrade_levels = {}
		if is_server then
			self:set_upgrade_value("player", "intimidate_enemies", 1)
			self:set_upgrade_value("player", "empowered_intimidation_mul", 1)
			self:set_upgrade_value("player", "intimidation_multiplier", 1)
		end
	end
	function TeamAIBase:set_upgrade_value(category, upgrade, level)
		HuskPlayerBase.set_upgrade_value(self, category, upgrade, level)
	end
	function TeamAIBase:upgrade_value(category, upgrade)
		return self._upgrades[category] and self._upgrades[category][upgrade]
	end
	function TeamAIBase:upgrade_level(category, upgrade)
		return self._upgrade_levels[category] and self._upgrade_levels[category][upgrade]
	end
end

if RequiredScript == "lib/units/player_team/teamaibrain" then
	local ai_mask = World:make_slot_mask(12, 25)
	local old_reset = TeamAIBrain._reset_logic_data
	function TeamAIBrain:_reset_logic_data(...)
		old_reset(self, ...)
		self._slotmask_enemies = ai_mask
		self._logic_data.enemy_slotmask = ai_mask
	end
end

if RequiredScript == "lib/units/player_team/teamaidamage" then
	local bb_original_teamaidamage_applydamage = TeamAIDamage._apply_damage
	function TeamAIDamage:_apply_damage(...)
		local damage_percent, health_subtracted = bb_original_teamaidamage_applydamage(self, ...)
		if BB._data.doc then
			local data = self._unit:brain()._logic_data
			if data then
				local my_data = data.internal_data
				if not my_data.said_hurt then
					if self._health_ratio <= 0.2 then
						if not self:need_revive() then
							my_data.said_hurt = true
							self._unit:sound():say("g80x_plu", true)
						end
					end
				end
			end
		end
		return damage_percent, health_subtracted
	end
	local bb_original_teamaidamage_regenerated = TeamAIDamage._regenerated
	function TeamAIDamage:_regenerated(...)
		if BB._data.doc then
			local data = self._unit:brain()._logic_data
			if data then
				local my_data = data.internal_data
				if my_data.said_hurt then
					my_data.said_hurt = false
				end
			end
		end
		return bb_original_teamaidamage_regenerated(self, ...)
	end
	function TeamAIDamage:friendly_fire_hit(...)
		return
	end
end

if RequiredScript == "lib/tweak_data/weapontweakdata" then
	local p = pairs
	local old_init = WeaponTweakData.init
	function WeaponTweakData:init(...)
		old_init(self, ...)
		if BB._data.combat then
			for k, v in p(self) do
				if type(v) == "table" then
					if k:match("_crew$") then
						v.DAMAGE = 1.5
						if v.auto then
							if v.auto.fire_rate then
								v.auto.fire_rate = 0.2
							end
						end
					end
				end
			end
		end
		self.m14_crew.usage = "is_pistol"
		self.m14_crew.anim_usage = "is_rifle"
		self.contraband_crew.usage = "is_pistol"
		self.contraband_crew.anim_usage = "is_rifle"
		self.sub2000_crew.usage = "is_pistol"
		self.b682_crew.usage = "is_shotgun_mag"
		self.b682_crew.anim_usage = "is_shotgun_pump"
		self.spas12_crew.usage = "is_shotgun_mag"
		self.spas12_crew.anim_usage = "is_shotgun_pump"
		self.ben_crew.usage = "is_shotgun_mag"
		self.ben_crew.anim_usage = "is_shotgun_pump"
		self.huntsman_crew.usage = "is_shotgun_mag"
		self.huntsman_crew.anim_usage = "is_shotgun_pump"
		self.ching_crew.usage = "is_pistol"
		self.ching_crew.anim_usage = "is_rifle"
	end
end

if RequiredScript == "lib/managers/criminalsmanager" then
	local p = pairs
	local is_server = Network:is_server()
	local settings = Global and Global.game_settings
	local is_offline = settings and settings.single_player
	local difficulty = settings and settings.difficulty or "normal"
	local total_chars = CriminalsManager.get_num_characters()
	CriminalsManager.MAX_NR_TEAM_AI = BB._data.biglob and total_chars or 3
	local char_tweak = tweak_data.character
	if char_tweak then
		local char_preset = char_tweak.presets
		if char_preset then
			local params = {
				health = { nil, 75, 144 },
				speed = { "very_slow", "slow", "normal", "fast", "very_fast", "lightning" },
				dodge = { "poor", "average", "heavy", "athletic", "ninja" }
			}
			local char_damage = char_preset.gang_member_damage
			if char_damage then
				local health_bot = params.health[BB._data.health or 1]
				char_damage.HEALTH_INIT = health_bot or char_damage.HEALTH_INIT
				char_damage.DOWNED_TIME = BB._data.instadwn and 0 or char_damage.DOWNED_TIME
			end
			local gang_weapon = char_preset.weapon.gang_member
			if gang_weapon then
				local speed_bot = params.speed[BB._data.speed or 5]
				local dodge_bot = params.dodge[BB._data.dodge or 4]
				local diff_index = tweak_data:difficulty_to_index(difficulty)
				for k, v in p(gang_weapon) do
					v.focus_delay = 0
					v.aim_delay = { 0, 0 }
					v.range = deep_clone(char_preset.weapon.sniper.is_rifle.range)
					v.RELOAD_SPEED = 1
					if BB._data.combat then
						v.spread = 5
						v.FALLOFF = {
							{
								r = 300,
								acc = { 1, 1 },
								dmg_mul = diff_index,
								recoil = { 0.25, 0.25 },
								mode = { 0, 0, 1, 0 }
							},
							{
								r = 10000,
								acc = { 1, 1 },
								dmg_mul = 0.1,
								recoil = { 2, 2 },
								mode = { 0, 0, 1, 0 }
							}
						}
					end
				end
				for k, v in p(char_tweak) do
					if type(v) == "table" then
						if v.access == "teamAI1" then
							v.no_run_start = true
							v.no_run_stop = true
							v.always_face_enemy = true
							v.move_speed = is_server and char_preset.move_speed[speed_bot] or v.move_speed
							if BB._data.move == 2 then
								v.dodge = char_preset.dodge[dodge_bot]
							elseif BB._data.move == 3 then
								v.allowed_poses = { stand = true }
							end
							local orig = v.weapon.weapons_of_choice
							v.weapon = deep_clone(gang_weapon)
							v.weapon.weapons_of_choice = orig
							if BB._data.combat then
								v.weapon.is_sniper.FALLOFF[1].dmg_mul = diff_index * 4
								v.weapon.is_sniper.FALLOFF[1].recoil = { 1, 1 }
								v.weapon.is_shotgun_pump.FALLOFF[1].dmg_mul = diff_index * 2
								v.weapon.is_shotgun_pump.FALLOFF[1].recoil = { 0.5, 0.5 }
							end
						end
					end
				end
			end
		end
	end
	local old_color = CriminalsManager.character_color_id_by_unit
	function CriminalsManager:character_color_id_by_unit(unit, ...)
		if is_offline then
			if not BB._data.biglob then
				local char_data = self:character_data_by_unit(unit)
				if char_data then
					if char_data.ai then
						if not char_data.ai_id then
							local ai_crim = self:nr_AI_criminals()
							char_data.ai_id = ai_crim + 1
							return char_data.ai_id
						end
						return char_data.ai_id
					end
				end
			end
		end
		return old_color(self, unit, ...)
	end
end

if RequiredScript == "lib/tweak_data/playertweakdata" then
	function PlayerTweakData:_set_singleplayer()
		return
	end
end

if RequiredScript == "lib/units/weapons/newnpcraycastweaponbase" then
	local ai_mask = World:make_slot_mask(8, 12, 25)
	local old_setup = NewNPCRaycastWeaponBase.setup
	function NewNPCRaycastWeaponBase:setup(setup_data, ...)
		old_setup(self, setup_data, ...)
		local user_unit = setup_data.user_unit
		if user_unit then
			if user_unit:in_slot(16) then
				self._bullet_slotmask = ai_mask
			end
		end
	end
end

if RequiredScript == "lib/units/weapons/npcraycastweaponbase" then
	local ai_mask = World:make_slot_mask(8, 12, 25)
	local old_setup = NPCRaycastWeaponBase.setup
	function NPCRaycastWeaponBase:setup(setup_data, ...)
		old_setup(self, setup_data, ...)
		local user_unit = setup_data.user_unit
		if user_unit then
			if user_unit:in_slot(16) then
				self._bullet_slotmask = ai_mask
			end
		end
	end
end

if RequiredScript == "lib/units/player_team/teamaimovement" then
	local p = pairs
	local math_rand = math.random
	local settings = Global and Global.game_settings
	local is_private = settings and settings.permission and settings.permission ~= "public"
	local is_offline = settings and settings.single_player
	local old_spooc = TeamAIMovement.on_SPOOCed
	function TeamAIMovement:on_SPOOCed(...)
		if BB._data.clkarrest then
			if is_private or is_offline then
				return self:on_cuffed()
			end
		end
		return old_spooc(self, ...)
	end
	if not BotWeapons then
		function TeamAIMovement:check_visual_equipment()
			if not BB._data.equip then
				local bags = { { g_medicbag = true }, { g_ammobag = true } }
				local bag_choice = bags[math_rand(#bags)]
				for k, v in p(bag_choice) do
					local mesh_obj = self._unit:get_object(Idstring(k))
					if mesh_obj then
						mesh_obj:set_visibility(v)
					end
				end
				self._unit:damage():run_sequence_simple("var_model_02")
			end
		end
	end
	local old_throw = TeamAIMovement.throw_bag
	function TeamAIMovement:throw_bag(...)
		if self:carrying_bag() then
			local carry_tweak = self:carry_tweak()
			if carry_tweak then
				local data = self._ext_brain._logic_data
				if data then
					local objective = data.objective
					if objective then
						if objective.type == "revive" then
							local no_cooldown = managers.player:is_custom_cooldown_not_active("team", "crew_inspire")
							if no_cooldown or carry_tweak.can_run then
								return
							end
						end
					end
				end
			end
		end
		return old_throw(self, ...)
	end
end

if RequiredScript == "lib/units/player_team/actions/lower_body/criminalactionwalk" then
	local p = pairs
	function CriminalActionWalk:init(...)
		return CriminalActionWalk.super.init(self, ...)
	end
	function CriminalActionWalk:_get_max_walk_speed()
		local speed = deep_clone(CriminalActionWalk.super._get_max_walk_speed(self))
		if self._ext_movement:carrying_bag() then
			local carry_mod = tweak_data.carry.types[tweak_data.carry[self._ext_movement:carry_id()].type].move_speed_modifier
			local speed_modifier = (carry_mod * 1.5) > 1 and 1 or carry_mod
			for k, v in p(speed) do
				speed[k] = v * speed_modifier
			end
		end
		return speed
	end
	function CriminalActionWalk:_get_current_max_walk_speed(move_dir)
		local speed = CriminalActionWalk.super._get_current_max_walk_speed(self, move_dir)
		if self._ext_movement:carrying_bag() then
			local carry_mod = tweak_data.carry.types[tweak_data.carry[self._ext_movement:carry_id()].type].move_speed_modifier
			local speed_modifier = (carry_mod * 1.5) > 1 and 1 or carry_mod
			speed = speed * speed_modifier
		end
		return speed
	end
end

if RequiredScript == "lib/units/player_team/logics/teamailogicidle" then
	local mvec3_norm = mvector3.normalize
	local mvec3_angle = mvector3.angle
	local p = pairs
	local t_ins = table.insert
	local math_ceil = math.ceil
	local w = World
	local REACT_COMBAT = AIAttentionObject.REACT_COMBAT
	local old_enter = TeamAILogicIdle.enter
	function TeamAILogicIdle.check_smart_reload(data, percentage)
		if not data.cool then
			if not data.internal_data.acting then
				local unit = data.unit
				if not unit:anim_data().reload then
					local current_wep = unit:inventory():equipped_unit()
					if current_wep then
						local ammo_max, ammo = current_wep:base():ammo_info()
						if ammo <= math_ceil(ammo_max * percentage) then
							local reload_action = { type = "reload", body_part = 3 }
							unit:brain():action_request(reload_action)
						end
					end
				end
			end
		end
	end
	function TeamAILogicIdle.enter(data, ...)
		old_enter(data, ...)
		TeamAILogicIdle.check_smart_reload(data, 0.4)
	end
	local function _upd_cop_vis(data)
		local vis_enemy
		if not data.cool then
			local objective = data.objective
			if not objective or objective.type ~= "revive" then
				local all_attention_objects = managers.groupai:state():get_AI_attention_objects_by_filter(data.SO_access_str)
				local crim_mov = data.unit:movement()
				local head_pos = crim_mov:m_head_pos()
				local my_tracker = crim_mov:nav_tracker()
				local chk_vis_func = my_tracker.check_visibility
				local all_enemies = managers.enemy:all_enemies()
				for u_key, u_char in p(all_enemies) do
					local attention_info = all_attention_objects[u_key]
					if attention_info then
						local att_handler = attention_info.handler
						local settings = att_handler:get_attention(data.SO_access, REACT_COMBAT, nil, data.team)
						if settings then
							if chk_vis_func(my_tracker, attention_info.nav_tracker) then
								local u_head_pos = att_handler:get_detection_m_pos()
								local vis_ray = w:raycast("ray", head_pos, u_head_pos, "slot_mask", data.visibility_slotmask, "ray_type", "ai_vision")
								if not vis_ray then
									if not vis_enemy then
										vis_enemy = true
										break
									end
								end
							end
						end
					end
				end
			end
		end
		return vis_enemy
	end
	local old_update = TeamAILogicIdle.update
	function TeamAILogicIdle.update(data, ...)
		if BB._data.reflex then
			local vis_enemy = _upd_cop_vis(data)
			if vis_enemy then
				CopLogicBase._exit(data.unit, "assault")
			end
		end
		return old_update(data, ...)
	end
	function TeamAILogicIdle._get_priority_attention(data, attention_objects, reaction_func)
		local best_target, best_target_dis, best_target_reaction
		local att_obj = data.attention_obj
		local unit = data.unit
		local head_pos = unit:movement():m_head_pos()
		local cops_to_intimidate = BB.cops_to_intimidate
		local is_team_ai = managers.groupai:state():is_unit_team_AI(unit)
		local has_ap = is_team_ai and managers.player:has_category_upgrade("team", "crew_ai_ap_ammo")
		for u_key, attention_data in p(attention_objects) do
			if attention_data.identified then
				local att_unit = attention_data.unit
				if att_unit:in_slot(data.enemy_slotmask) then
					local reaction = attention_data.reaction
					if reaction then
						if reaction >= REACT_COMBAT then
							local target_dis = attention_data.verified_dis
							if target_dis then
								local dis_mod = 1
								if att_obj and att_obj.u_key == u_key then
									target_dis = target_dis * 0.8
								end
								if attention_data.verified then
									local enemy_data = att_unit:brain()._logic_data
									if enemy_data then
										local char_tweak = attention_data.char_tweak
										local special_shout = char_tweak and char_tweak.priority_shout
										local enemy_target = enemy_data.attention_obj
										if enemy_target and enemy_target.is_human_player then
											target_dis = target_dis * 0.8
										end
										if special_shout then
											local internal_data = enemy_data.internal_data
											if special_shout == "f34" then
												dis_mod = 0.125
											elseif special_shout == "f47" then
												dis_mod = 0.25
											elseif internal_data and (internal_data.tasing or internal_data.spooc_attack) then
												dis_mod = 0.375
											elseif special_shout == "f30" then
												dis_mod = 0.5
											else
												dis_mod = 0.625
												if attention_data.is_shield then
													local is_shielded = w:raycast("ray", head_pos, attention_data.m_head_pos, "ignore_unit", {unit}, "slot_mask", 8)
													local melee_range = is_team_ai and target_dis <= 200
													if not has_ap and (is_shielded or not melee_range) then
														dis_mod = 1
													end
												end
											end
										else
											dis_mod = 0.75
										end
									else
										dis_mod = 0.875
									end
								end
								target_dis = target_dis * dis_mod
								if not best_target_dis or best_target_dis > target_dis then
									local cop_key = cops_to_intimidate[u_key]
									local intimidation_in_progress = cop_key and data.t - cop_key < BB.grace_period
									if not intimidation_in_progress then
										best_target = attention_data
										best_target_dis = target_dis
										best_target_reaction = reaction
									end
								end
							end
						end
					end
				end
			end
		end
		return best_target, best_target_dis, best_target_reaction
	end
	function TeamAILogicIdle._find_intimidateable_civilians(criminal, use_default_shout_shape, max_angle, max_dis)
		local best_civ
		local highest_wgt = 1
		local intimidateable_civilians = {}
		if use_default_shout_shape then
			max_angle = 90
			max_dis = 1200
		end
		local crim_mov = criminal:movement()
		local head_pos = crim_mov:m_head_pos()
		local look_vec = crim_mov:m_rot():y()
		local my_tracker = crim_mov:nav_tracker()
		local chk_vis_func = my_tracker.check_visibility
		local slotmask = managers.slot:get_mask("AI_visibility")
		local all_civs = managers.enemy:all_civilians()
		for u_key, u_char in p(all_civs) do
			if chk_vis_func(my_tracker, u_char.tracker) then
				local unit = u_char.unit
				local unit_mov = unit:movement()
				local u_head_pos = unit_mov:m_head_pos()
				local vec = u_head_pos - head_pos
				if mvec3_norm(vec) <= max_dis then
					if mvec3_angle(vec, look_vec) <= max_angle then
						local ray = w:raycast("ray", head_pos, u_head_pos, "slot_mask", slotmask, "ray_type", "ai_vision")
						if not ray then
							if u_char.char_tweak.intimidateable then
								if not unit:base().unintimidateable then
									local anim_data = unit:anim_data()
									if not anim_data.unintimidateable then
										if not unit:brain():is_tied() then
											if not unit:unit_data().disable_shout then
												if not unit_mov:cool() then
													if not anim_data.drop then
														t_ins(intimidateable_civilians, {
															unit = unit,
															key = u_key,
															inv_wgt = 1
														})
														best_civ = unit
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
		return best_civ, highest_wgt, intimidateable_civilians
	end
	local old_onalert = TeamAILogicIdle.on_alert
	function TeamAILogicIdle.on_alert(data, alert_data, ...)
		if BB._data.maskup then
			if data.cool then
				local alert_type = alert_data[1]
				if CopLogicBase.is_alert_aggressive(alert_type) then
					data.unit:movement():set_cool(false)
				end
			end
		end
		return old_onalert(data, alert_data, ...)
	end
end

if RequiredScript == "lib/units/player_team/logics/teamailogicassault" then
	local p = pairs
	local REACT_COMBAT = AIAttentionObject.REACT_COMBAT
	function TeamAILogicAssault.find_enemy_to_mark(enemies)
		local best_nmy, best_nmy_wgt
		local t = TimerManager:game():time()
		local has_ap = managers.player:has_category_upgrade("team", "crew_ai_ap_ammo")
		for key, attention_info in p(enemies) do
			if not attention_info.is_shield or has_ap then
				if attention_info.identified then
					if attention_info.verified or attention_info.nearly_visible then
						local att_unit = attention_info.unit
						if att_unit:in_slot(12, 25) then
							local reaction = attention_info.reaction
							if reaction then
								if reaction >= REACT_COMBAT then
									local char_tweak = attention_info.char_tweak
									if char_tweak and char_tweak.priority_shout or attention_info.is_deployable then
										local dis = attention_info.verified_dis
										if dis <= 3000 then
											if not best_nmy_wgt or best_nmy_wgt > dis then
												local mark_t = attention_info.mark_t
												if not mark_t or mark_t + 5 < t then
													best_nmy_wgt = dis
													best_nmy = att_unit
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
		return best_nmy
	end
	function TeamAILogicAssault.mark_enemy(data, criminal, to_mark, play_sound, play_action)
		local mark_data = data.detected_attention_objects[to_mark:key()]
		if mark_data then
			local is_turret = to_mark:in_slot(25)
			mark_data.mark_t = data.t
			if play_sound then
				local sound_name = is_turret and "f44" or to_mark:base():char_tweak().priority_shout
				criminal:sound():say(sound_name .. "x_any", true, true)
			end
			if play_action then
				if not criminal:movement():chk_action_forbidden("action") then
					local new_action = { type = "act", variant = "arrest", body_part = 3, align_sync = true }
					if criminal:brain():action_request(new_action) then
						data.internal_data.gesture_arrest = true
					end
				end
			end
			to_mark:contour():add(is_turret and "mark_unit_dangerous" or "mark_enemy", true)
		end
	end
end

if RequiredScript == "lib/units/player_team/logics/teamailogicbase" then
	local w = World
	local p = pairs
	local mvec3_angle = mvector3.angle
	local math_ceil = math.ceil
	local REACT_COMBAT = AIAttentionObject.REACT_COMBAT
	local function _find_enemy_to_intimidate(data)
		local best_nmy, best_priority, targets
		local look_vec = data.unit:movement():m_rot():y()
		local has_room = managers.groupai:state():has_room_for_police_hostage()
		if BB._data.dom then
			targets = data.detected_attention_objects
		else
			targets = {}
			for u_key, t in p(BB.cops_to_intimidate) do
				if data.t - t < BB.grace_period then
					targets[u_key] = data.detected_attention_objects[u_key]
				end
			end
		end
		for u_key, u_char in p(targets) do
			if u_char.identified then
				local unit = u_char.unit
				if unit:in_slot(12, 22) then
					if u_char.verified then
						local intim_dis = u_char.verified_dis
						if intim_dis then
							if intim_dis <= 1200 then
								local vec = u_char.m_pos - data.m_pos
								if mvec3_angle(vec, look_vec) <= 90 then
									local char_tweak = u_char.char_tweak
									if char_tweak.surrender then
										if not char_tweak.priority_shout then
											if unit:inventory():get_weapon() then
												local anim_data = unit:anim_data()
												if has_room or (anim_data.hands_back or anim_data.surrender) then
													local is_hurt = unit:character_damage():health_ratio() < 1
													local is_vulnerable = anim_data.hands_back or anim_data.surrender or is_hurt
													if not BB._data.dom or is_vulnerable then
														local intim_priority = anim_data.hands_back and 0.25 or anim_data.surrender and 0.5 or is_hurt and 0.75 or 1
														intim_dis = intim_dis * intim_priority
														if not best_priority or best_priority > intim_dis then
															best_nmy = unit
															best_priority = intim_dis
														end
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
		return best_nmy
	end
	local function _intimidate_law_enforcement(data, intim_unit, play_action)
		local act_name, sound_name
		local anim_data = intim_unit:anim_data()
		if anim_data.hands_back then
			act_name = "arrest"
			sound_name = "l03x_sin"
		elseif anim_data.surrender then
			act_name = "arrest"
			sound_name = "l02x_sin"
		else
			act_name = "gesture_stop"
			sound_name = "l01x_sin"
		end
		local unit = data.unit
		unit:sound():say(sound_name, true, true)
		if play_action then
			if not unit:movement():chk_action_forbidden("action") then
				local new_action = { type = "act", variant = act_name, body_part = 3, align_sync = true }
				if unit:brain():action_request(new_action) then
					data.internal_data.gesture_arrest = true
				end
			end
		end
		intim_unit:brain():on_intimidated(1, unit)
	end
	local function _do_melee(data)
		local can_melee
		local criminal = data.unit
		local current_wep = criminal:inventory():equipped_unit()
		local crim_mov = criminal:movement()
		local my_pos = crim_mov:m_head_pos()
		local look_vec = crim_mov:m_rot():y()
		local detected_obj = data.detected_attention_objects
		for u_key, u_char in p(detected_obj) do
			if u_char.identified then
				local unit = u_char.unit
				if unit:in_slot(data.enemy_slotmask) then
					if u_char.verified then
						if u_char.verified_dis <= 200 then
							local unit_pos = u_char.m_head_pos
							local vec = unit_pos - my_pos
							if mvec3_angle(vec, look_vec) <= 45 then
								if not u_char.char_tweak.immune_to_knock_down then
									if unit:inventory():get_weapon() then
										if not unit:anim_data().hurt then
											local is_shield = w:raycast("ray", my_pos, unit_pos, "ignore_unit", {criminal}, "slot_mask", 8)
											local damage = unit:character_damage()
											local health_damage = math_ceil(damage._HEALTH_INIT/2)
											local col_ray = { ray = -vec, body = unit:body("body"), position = unit_pos }
											local damage_info = {}
											damage_info.attacker_unit = criminal
											damage_info.weapon_unit = current_wep
											damage_info.variant = is_shield and "melee" or "bullet"
											damage_info.damage = is_shield and 0 or health_damage
											damage_info.col_ray = col_ray
											damage_info.origin = my_pos
											if is_shield then
												damage_info.shield_knock = true
												damage:damage_melee(damage_info)
											else
												damage_info.knock_down = true
												damage:damage_bullet(damage_info)
											end
											if not can_melee then
												can_melee = true
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
		if can_melee then
			crim_mov:play_redirect("melee")
			managers.network:session():send_to_peers("play_distance_interact_redirect", criminal, "melee")
		end
	end
	local function _interact_check(data)
		local unit = data.unit
		if not unit:character_damage():need_revive() then
			local anim_data = unit:anim_data()
			if not anim_data.tased then
				local my_data = data.internal_data
				if not my_data.acting then
					if not unit:sound():speaking() then
						local t = data.t
						if not my_data._intimidate_t or my_data._intimidate_t + 2 < t then
							local is_reloading = anim_data.reload and false or true
							local civ = TeamAILogicIdle.find_civilian_to_intimidate(unit, 90, 1200)
							local dom = _find_enemy_to_intimidate(data)
							local nmy = TeamAILogicAssault.find_enemy_to_mark(data.detected_attention_objects)
							my_data._intimidate_t = t
							if civ then
								TeamAILogicIdle.intimidate_civilians(data, unit, true, is_reloading)
							elseif dom then
								_intimidate_law_enforcement(data, dom, is_reloading)
							elseif nmy then
								TeamAILogicAssault.mark_enemy(data, unit, nmy, true, is_reloading)
							end
						end
					end
					if not my_data.melee_t or my_data.melee_t + 1 < t then
						my_data.melee_t = t
						_do_melee(data)
					end
				end
			end
		end
	end
	function TeamAILogicBase._set_attention_obj(data, new_att_obj, new_reaction)
		_interact_check(data)
		data.attention_obj = new_att_obj
		if new_att_obj then
			new_att_obj.reaction = new_reaction or new_att_obj.reaction
		end
	end
	function TeamAILogicBase._get_logic_state_from_reaction(data, reaction)
		if not reaction or reaction < REACT_COMBAT then
			return "idle"
		end
		return "assault"
	end
end

if RequiredScript == "lib/units/enemies/cop/actions/upper_body/copactionshoot" then
	local math_lerp = math.lerp
	local ip = ipairs
	local old_shoot = CopActionShoot._get_shoot_falloff
	function CopActionShoot:_get_shoot_falloff(target_dis, falloff, ...)
		if BB._data.combat then
			if self._unit:in_slot(16) then
				local i = #falloff
				local data = falloff[i]
				for i_range, range_data in ip(falloff) do
					if target_dis < range_data.r then
						i = i_range
						data = range_data
						break
					end
				end
				if i > 1 then
					local prev_data = falloff[i - 1]
					local t = (target_dis - prev_data.r) / (data.r - prev_data.r)
					local n_data = {
						dmg_mul = math_lerp(prev_data.dmg_mul, data.dmg_mul, t),
						r = target_dis,
						acc = { math_lerp(prev_data.acc[1], data.acc[1], t), math_lerp(prev_data.acc[2], data.acc[2], t) },
						recoil = { math_lerp(prev_data.recoil[1], data.recoil[1], t), math_lerp(prev_data.recoil[2], data.recoil[2], t) },
						mode = data.mode
					}
					return n_data, i
				end
				return data, i
			end
		end
		return old_shoot(self, target_dis, falloff, ...)
	end
end

if RequiredScript == "lib/units/enemies/cop/copbrain" then
	local ai_mask = World:make_slot_mask(12, 25)
	local old_convert = CopBrain.convert_to_criminal
	function CopBrain:convert_to_criminal(...)
		old_convert(self, ...)
		local char_tweak = deep_clone(self._logic_data.char_tweak)
		char_tweak.access = "teamAI1"
		char_tweak.crouch_move = false
		char_tweak.no_run_start = true
		char_tweak.no_run_stop = true
		char_tweak.always_face_enemy = true
		char_tweak.allowed_poses = { stand = true }
		self._logic_data.char_tweak = char_tweak
		self._slotmask_enemies = ai_mask
		self._logic_data.enemy_slotmask = ai_mask
	end
end

if RequiredScript == "lib/units/enemies/cop/copdamage" then
	local bb_original_copdamage_damagemelee = CopDamage.damage_melee
	function CopDamage:damage_melee(attack_data, ...)
		if attack_data.variant == "taser_tased" then
			BB:add_cop_to_intimidation_list(self._unit:key())
		end
		return bb_original_copdamage_damagemelee(self, attack_data, ...)
	end
	local bb_original_copdamage_syncdamagemelee = CopDamage.sync_damage_melee
	function CopDamage:sync_damage_melee(variant, ...)
		if variant == 5 then
			BB:add_cop_to_intimidation_list(self._unit:key())
		end
		return bb_original_copdamage_syncdamagemelee(self, variant, ...)
	end
	local old_die = CopDamage.die
	function CopDamage:die(attack_data, ...)
		if BB._data.ammo then
			local attacker_unit = attack_data.attacker_unit
			if attacker_unit then
				if attacker_unit:in_slot(16) then
					self:set_pickup(nil)
				end
			end
		end
		return old_die(self, attack_data, ...)
	end
end

if RequiredScript == "lib/units/enemies/cop/logics/coplogicbase" then
	local old_queue = CopLogicBase.queue_task
	function CopLogicBase.queue_task(internal_data, id, func, data, exec_t, asap)
		local unit = data.unit
		if unit then
			if unit:in_slot(16) then
				asap = true
			end
		end
		return old_queue(internal_data, id, func, data, exec_t, asap)
	end
end

if RequiredScript == "lib/units/enemies/cop/logics/coplogicidle" then
	local old_enter = CopLogicIdle.enter
	function CopLogicIdle.enter(data, ...)
		old_enter(data, ...)
		if data.is_converted then
			TeamAILogicIdle.check_smart_reload(data, 0.6)
		end
	end
	local old_intim = CopLogicIdle.on_intimidated
	function CopLogicIdle.on_intimidated(data, ...)
		local surrender = old_intim(data, ...)
		local unit = data.unit
		BB:add_cop_to_intimidation_list(unit:key())
		if surrender then
			unit:base():set_slot(unit, 22)
		end
		return surrender
	end
	local old_prio = CopLogicIdle._get_priority_attention
	function CopLogicIdle._get_priority_attention(data, attention_objects, reaction_func)
		local best_target, best_target_priority_slot, best_target_reaction = old_prio(data, attention_objects, reaction_func)
		if data.is_converted then
			best_target, best_target_priority_slot, best_target_reaction = TeamAILogicIdle._get_priority_attention(data, attention_objects)
		end
		return best_target, best_target_priority_slot, best_target_reaction
	end
end

if RequiredScript == "lib/managers/mission/elementmissionend" then
	local is_offline = Global and Global.game_settings and Global.game_settings.single_player
	function ElementMissionEnd:on_executed(instigator)
		if not self._values.enabled then
			return
		end
		if self._values.state ~= "none" and managers.platform:presence() == "Playing" then
			if self._values.state == "success" then
				local num_winners = managers.network:session():amount_of_alive_players()
				if is_offline then
					num_winners = managers.network:session():amount_of_alive_players() + managers.groupai:state():amount_of_winning_ai_criminals()
				end
				managers.network:session():send_to_peers("mission_ended", true, num_winners)
				game_state_machine:change_state_by_name("victoryscreen", {
					num_winners = num_winners,
					personal_win = alive(managers.player:player_unit())
				})
			elseif self._values.state == "failed" then
				managers.network:session():send_to_peers("mission_ended", false, 0)
				game_state_machine:change_state_by_name("gameoverscreen")
			elseif self._values.state == "leave" then
				MenuCallbackHandler:leave_mission()
			elseif self._values.state == "leave_safehouse" and instigator:base().is_local_player then
				MenuCallbackHandler:leave_safehouse()
			end
		elseif Application:editor() then
			managers.editor:output_error("Cant change to state " .. self._values.state .. " in mission end element " .. self._editor_name .. ".")
		end
		ElementMissionEnd.super.on_executed(self, instigator)
	end
end