_G.Announcer = _G.Announcer or {}
Announcer._path = ModPath
Announcer._data_path = SavePath .. "announcer.txt"
Announcer.steam_friends = {}
Announcer.profiles = {}
Announcer.settings = {
	keep_quiet = true,
	dont_bother_steam_friends = false
}

function Announcer:CheckSteamFriend(peer)
	return not (self.settings.dont_bother_steam_friends and self.steam_friends[peer:user_id()])
end

function Announcer:CheckHost(peer)
	return peer:id() == 1 and self:CheckSteamFriend(peer)
end

Announcer.profiles.client = {
	history_file = SavePath .. "announcer_session_client.txt",
	history = {},
	chk_fct = Announcer.CheckHost,
	mods = {},
	hash = 0,
	message = ""
}
Announcer.profiles.host = {
	history_file = SavePath .. "announcer_session_host.txt",
	history = {},
	chk_fct = Announcer.CheckSteamFriend,
	mods = {},
	hash = 0,
	message = ""
}

local string_byte = string.byte
function Announcer.StupidHash(message)
	local result = 0
	for i = 1, message:len() do
		result = result + string_byte(message, i)
	end
	return result
end

function Announcer.ComposeMessage(tbl)
	local sz = table.size(tbl)
	local intro = {
		" ",
		" "
	}

	local one_line
	if sz == 1 then
		one_line = intro[1] .. tostring(tbl[1]) .. "."
	else
		one_line = intro[2] .. "\n- " .. table.concat(tbl, ",\n- ") .. "."
	end

	local message
	if sz == 1 or one_line:len() < 256 then
		message = one_line
	else
		message = {intro[2]}
		for _, line in pairs(tbl) do
			table.insert(message, "- " .. line .. ",")
		end
		message[#message] = message[#message]:gsub(",$", ".")
	end

	return message, Announcer.StupidHash(one_line)
end

function Announcer:AddMod(text, profile)
	if not table.contains(profile.mods, text) then
		table.insert(profile.mods, text)
		table.sort(profile.mods)
		profile.message, profile.hash = self.ComposeMessage(profile.mods)
	end
end

function Announcer:RemoveMod(text, profile)
	if table.contains(profile.mods, text) then
		table.delete(profile.mods, text)
		profile.message, profile.hash = self.ComposeMessage(profile.mods)
	end
end

function Announcer:AddHostMod(text)
	self:AddMod(text, self.profiles.host)
end

function Announcer:RemoveHostMod(text)
	self:RemoveMod(text, self.profiles.host)
end

function Announcer:AddClientMod(text)
	self:AddMod(text, self.profiles.client)
end

function Announcer:RemoveClientMod(text)
	self:RemoveMod(text, self.profiles.client)
end

function Announcer.LoadHistory(profile)
	local file = io.open(profile.history_file, "r")
	if file then
		local data = file:read("*all")
		if data and data:len() > 0 then
			profile.history = json.decode(data)
		end
		file:close()
	end
end

function Announcer.SaveHistory(profile)
	local file = io.open(profile.history_file, "w+")
	if file then
		file:write(json.encode(profile.history))
		file:close()
	end
end

function Announcer:ResetHistory()
	for _, profile in pairs(self.profiles) do
		local file = io.open(profile.history_file, "w+")
		if file then
			file:write()
			file:close()
		end
	end
end

function Announcer:CheckNotAnnouncedYet(peer, profile)
	if table.size(profile.history) == 0 then
		self.LoadHistory(profile)
	end

	local steamid = peer:user_id()
	if profile.history[steamid] == profile.hash then
		return false
	end
	profile.history[steamid] = profile.hash
	self.SaveHistory(profile)
	return true
end

function Announcer:AnnounceTo(peer_id, profile)
	if self.settings.keep_quiet then
		return
	end
	if table.size(profile.mods) > 0 then
		local peer = managers.network:session() and managers.network:session():peer(peer_id)
		if peer and profile.chk_fct(self, peer) then
			if self:CheckNotAnnouncedYet(peer, profile) then
				if type(profile.message) == "table" then
					for _, line in pairs(profile.message) do
						peer:send("send_chat_message", ChatManager.GAME, line)
					end
				else
					peer:send("send_chat_message", ChatManager.GAME, profile.message)
				end
			end
		end
	end
end

function Announcer:AnnounceHostModTo(peer_id)
	self:AnnounceTo(peer_id, self.profiles.host)
end

function Announcer:AnnounceClientModTo(peer_id)
	self:AnnounceTo(peer_id, self.profiles.client)
end

function Announcer:Load()
	if Steam:logged_on() then
		for _, friend in pairs(Steam:friends() or {}) do
			self.steam_friends[friend:id()] = true
		end
	end

	local file = io.open(self._data_path, "r")
	if file then
		for k, v in pairs(json.decode(file:read("*all")) or {}) do
			self.settings[k] = v
		end
		file:close()
	end
end

function Announcer:Save()
	local file = io.open(self._data_path, "w+")
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_ANCR", function(loc)
	for _, filename in pairs(file.GetFiles(Announcer._path .. "loc/")) do
		local str = filename:match('^(.*).txt$')
		if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
			loc:load_localization_file(Announcer._path .. "loc/" .. filename)
			break
		end
	end

	loc:load_localization_file(Announcer._path .. "loc/english.txt", false)
end)

Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_ANCR", function(menu_manager)

	MenuCallbackHandler.AnnouncerSetDontBotherSteamFriends = function(this, item)
		Announcer.settings.dont_bother_steam_friends = item:value() == "on"
	end

	MenuCallbackHandler.AnnouncerSetKeepQuiet = function(this, item)
		Announcer.settings.keep_quiet = item:value() == "on"
	end

	MenuCallbackHandler.AnnouncerSave = function(this, item)
		Announcer:Save()
	end

	Announcer:Load()
	MenuHelper:LoadFromJsonFile(Announcer._path .. "menu/options.txt", Announcer, Announcer.settings)

end)
