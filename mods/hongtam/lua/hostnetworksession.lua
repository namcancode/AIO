
if not _G.R9K then
	dofile(ModPath .. "lua/_reticle9k.lua")
end

Hooks:PostHook(HostNetworkSession, "on_peer_entered_lobby", "R9K_HostNetworkSession_on_peer_entered_lobby", function(self, peer)
	DelayedCalls:Add("R9KDelayedSendModAnnounceHostOnLobby" .. tostring(peer:id()), 1, function()
		R9K:SendModAnnounceHost(peer:id())
	end)
end)

Hooks:PostHook(HostNetworkSession, "on_peer_sync_complete" , "R9K_HostNetworkSession_on_peer_sync_complete" , function(self, peer, peer_id)
	DelayedCalls:Add("R9KDelayedSendModAnnounceHostOnSync" .. tostring(peer_id), 1, function()
		R9K:SendModAnnounceHost(peer_id)
	end)
end)
