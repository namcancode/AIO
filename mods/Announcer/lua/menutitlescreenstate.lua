local fs_original_menutitlescreenstate_atenter = MenuTitlescreenState.at_enter
function MenuTitlescreenState:at_enter()
	Announcer:ResetHistory()
	return fs_original_menutitlescreenstate_atenter(self)
end
