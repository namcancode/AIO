The functions you may use in your mods are the following ones.

For a host mod, players who join your lobby/game will receive the message contained in the variable my_mod_announcement once.
-> Announcer:AddHostMod(my_mod_announcement)

For a client mod, you'll send the message contained in the variable my_mod_announcement only to the host the first time you join him.
-> Announcer:AddClientMod(my_mod_announcement)

If the message changes, you can remove the old one with:
-> Announcer:RemoveHostMod(my_mod_announcement)
-> Announcer:RemoveClientMod(my_mod_announcement)
