-- Chat Prefix:
local prefix = "[HoBien]"

-- Code:
local chatmode = ForceReady.settings.chatmode

local function localize(str)
	return managers.localization:text(str)
end

local function sendMessage(msg, color)
	if managers.chat then
		if chatmode == 3 then
			managers.chat:send_message(ChatManager.GAME, managers.network.account:username(), prefix .. " " .. msg)
		elseif chatmode == 2 then
			managers.chat:_receive_message(ChatManager.GAME, prefix, msg, color)
		end
	end
end

if Network:is_server() and Utils:IsInGameState() and not Utils:IsInHeist() then
	local Is_Synched = true
	for _, peer in pairs(managers.network:session():peers()) do
		if not peer:synched() then
			local name = peer:name()
			sendMessage(string.format(localize("fr_not_synched"), name), Color.red)
			Is_Synched = false
		end
	end

	if Is_Synched then
		sendMessage(localize("fr_force_start"), Color.green)

		--managers.network:session():spawn_players() -- Causes issues
		game_state_machine:current_state():start_game_intro()
	else
		sendMessage(localize("fr_fail_start"), Color.red)
	end
end