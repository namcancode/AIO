_networkgameLoadOriginal = _networkgameLoadOriginal or BaseNetworkSession.load
function BaseNetworkSession:load( ... )
	_networkgameLoadOriginal(self, ...)
	Application:set_pause( false )
end
_dropInOriginal = _dropInOriginal or BaseNetworkSession.on_drop_in_pause_request_received
function BaseNetworkSession:on_drop_in_pause_request_received( peer_id, ... )
	if state then
		if not managers.network:session():closing() then
			managers.hud:show_hint( { text = managers.localization:text( "dialog_dropin_title", { USER = string.upper( nickname ) } ) } )
		end
	elseif self._dropin_pause_info[ peer_id ] then
		managers.hud:show_hint( { text = "Co nguoi vao" } ) 
	end
	_dropInOriginal(self, peer_id, ... )
	Application:set_pause( false )
	SoundDevice:set_rtpc( "ingame_sound", 1 ) -- unmute gameplay sounds
end