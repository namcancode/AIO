local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local unit_type_teammate = 2
local unit_type_minion = 22

local kpr_original_playerstandard_getinteractiontarget = PlayerStandard._get_interaction_target
function PlayerStandard:_get_interaction_target(char_table, my_head_pos, cam_fwd)
	if Keepers.enabled then
		if not Keepers.settings.filter_only_stop_calls and Keepers.settings.filter_shout_at_teamai and not Keepers:IsFiltering() then
			for i = #char_table, 1, -1 do
				if char_table[i].unit_type == unit_type_teammate then
					local record = managers.groupai:state():all_criminals()[char_table[i].unit:key()]
					if record.ai then
						table.remove(char_table, i)
					end
				end
			end
		else
			if self.add_minions_to_teammates then
				local peer_id = managers.network:session():local_peer():id()
				for key, unit in pairs(managers.groupai:state():all_converted_enemies()) do
					if alive(unit) and unit:base().kpr_minion_owner_peer_id == peer_id and not unit:character_damage():dead() then
						self:_add_unit_to_char_table(char_table, unit, unit_type_minion, 100000, true, true, 0.01, my_head_pos, cam_fwd)
					end
				end
			end
		end
	end

	return kpr_original_playerstandard_getinteractiontarget(self, char_table, my_head_pos, cam_fwd)
end

local kpr_original_playerstandard_getintimidationaction = PlayerStandard._get_intimidation_action
function PlayerStandard:_get_intimidation_action(prime_target, char_table, amount, primary_only, detect_only, secondary)
	if Keepers.enabled and prime_target and not detect_only then
		local u_mov = prime_target.unit:movement()
		if u_mov and u_mov.cool and not u_mov:cool() then
			local kpr_mode = Keepers.settings[secondary and 'secondary_mode' or 'primary_mode']
			local is_teammate_ai, needs_revive, is_arrested
			if prime_target.unit_type == unit_type_teammate then
				local record = managers.groupai:state():all_criminals()[prime_target.unit:key()]
				if record and record.ai then
					is_teammate_ai = true
					local rally_skill_data = self._ext_movement:rally_skill_data()
					if rally_skill_data and rally_skill_data.range_sq > mvector3.distance_sq(self._pos, record.m_pos) then
						if prime_target.unit:base().is_husk_player then
							is_arrested = u_mov:current_state_name() == 'arrested'
							needs_revive = prime_target.unit:interaction():active() and u_mov:need_revive() and not is_arrested
						else
							is_arrested = prime_target.unit:character_damage():arrested()
							needs_revive = prime_target.unit:character_damage():need_revive()
						end
					end
				end
			end

			if not needs_revive and not is_arrested then
				local is_converted = prime_target.unit_type == unit_type_minion
				local peer_id = managers.network:session():local_peer():id()
				local is_owned_minion = peer_id == prime_target.unit:base().kpr_minion_owner_peer_id

				if is_teammate_ai or is_converted and is_owned_minion then
					local player_need_revive = self._unit:character_damage():need_revive()
					local wp_position = managers.hud and managers.hud:gcw_get_my_custom_waypoint()
					if player_need_revive or kpr_mode == 1
						or (not secondary and Keepers.settings.filter_only_stop_calls and not Keepers:IsFiltering())
						or (prime_target.unit:base().kpr_is_keeper and not wp_position)
						or (is_teammate_ai and prime_target.unit:base().kpr_following_peer_id ~= peer_id and not wp_position)
					then
						Keepers:SendState(prime_target.unit, Keepers:GetLuaNetworkingText(peer_id, prime_target.unit, 1), false)
						if is_converted and not player_need_revive then
							self._intimidate_t = TimerManager:game():time() - 0.5
							return 'come', false, prime_target
						end

					else
						self._intimidate_t = TimerManager:game():time() - 0.5
						if is_teammate_ai then
							DelayedCalls:Add('DelayedModKPR_bot_ok_' .. prime_target.unit:id(), 1.5, function()
								if alive(prime_target.unit) then
									prime_target.unit:sound():say('r03x_sin')
								end
							end)
						end
						Keepers:SendState(prime_target.unit, Keepers:GetLuaNetworkingText(peer_id, prime_target.unit, kpr_mode), true)
						Keepers:ShowCovers(prime_target.unit)
						if wp_position then
							self:say_line('f40_any', managers.groupai:state():whisper_mode())
							if not self:_is_using_bipod() then
								self:_play_distance_interact_redirect(TimerManager:game():time(), 'cmd_gogo')
							end
							return 'kpr_boost', false, prime_target -- will do nothing
						else
							return 'ai_stay', false, prime_target
						end
					end
					secondary = false
				end
			end
		end
	end

	return kpr_original_playerstandard_getintimidationaction(self, prime_target, char_table, amount, primary_only, detect_only, secondary)
end

local kpr_original_playerstandard_getunitintimidationaction = PlayerStandard._get_unit_intimidation_action
function PlayerStandard:_get_unit_intimidation_action(intimidate_enemies, intimidate_civilians, intimidate_teammates, only_special_enemies, intimidate_escorts, intimidation_amount, primary_only, detect_only, secondary)
	self.add_minions_to_teammates = Keepers.enabled and Keepers:CanCallJokers(self._ext_movement:current_state_name()) and intimidate_teammates
	return kpr_original_playerstandard_getunitintimidationaction(self, intimidate_enemies, intimidate_civilians, intimidate_teammates, only_special_enemies, intimidate_escorts, intimidation_amount, primary_only, detect_only, secondary)
end
