List of Features
----------------

- Bots will automatically mark Tasers when they are tased
- Bots can dominate cops
- Bots can melee enemies, knocking them down and dealing half of their health in damage
- Bots can dominate, intimidate, and mark NPCs independently, rather than sharing a timer for these actions
- Additionally, bots will not mark enemies who are already marked, increasing the variety of marked enemies;
  the code for marking has also been improved for efficiency
- Furthermore, bots will now mark turrets
- Bots are included in the difficulty calculations by the game, allowing for a more human game experience
- Bots have had their "aim delay" and "focus delay" values set to 0, enabling them to aim and shoot at enemies
  immediately
- Bots can now hit targets at any range, including Snipers
- Bots have had their "run_start" and "run_stop" animations removed, enabling them to better keep up with
  players
- Bots will use human player outlines in offline mode
- Bots can shoot through one another and even hostages, so no more dead dominated cops
- Bots will not drop their bags if they can inspire the player or the bag is light enough to run with
- Further, bots' movement penalty when carrying bags is now similar to human players
- Bots will wear the Lightweight Ballistic Vest and either a doctor bag or ammo bag (chosen at random) to
  make them appear more human (note that the bags cannot be deployed and the armor does not increase their
  durability, both are purely cosmetic)
- Bots will automatically reload their weapons if they are out of combat and their magazines are at least
  half empty, rather than only reloading when their mags are totally dry
- Bots' targeting has been overhauled, prioritizing enemies based on distance and focusing on specials
- The bots' code for intimidating civilians has been improved and optimized for performance; bots will
  shout at civilians immediately if they are not on the floor, no matter what
- Bots' reactions have been streamlined and optimized for faster reflexes and target acquisition
- Many of these changes will also apply to Jokers, such as the improved targeting and reloading out of combat
- Bots will no longer attempt to revive teammates who are already in the process of being revived
- Bots will count for the "crew alive" experience and money bonus at the end of the heist in offline mode

Explanation of Options
----------------------

"Bot Health": Changes the bot health amount. The options are as follows (default is "Default"):
	- "Default": Vanilla health behaviour.
	- "No Scaling (750)": Removes the scaling factor from the vanilla health; bots will be as
	  durable on OD as they are on Normal.
	- "Zeal (1440)": Gives the bots the health of a ZEAL Team member on One Down difficulty.

"Bot Speed": Changes the bot speed. Max is "Lightning" (the speed of Cloakers), default is
"Very Fast." Options are "Very Slow," "Slow," "Normal," "Fast," "Very Fast," and "Lightning."
The speeds are based on the NPCs' default speeds.

"Bot Movement": There are two alternative movement rules that the bots can follow. The default
is "Default." The options are:
	- "Default": No special movement rules.
	- "Dodge": Bots will roll around and dive to avoid damage, much like enemy cops can do.
	  Choose what type of dodging in the "Dodge Type" option.
	- "No Crouching": This prevents the bots from ever crouching. This keeps them standing
	  up and engaging the enemy.
	
"Dodge Type": Changes what type of dodging the bots will use. Default is "Athletic"; the
highest is "Ninja," which is what Cloakers use. Note that "Bot Movement" must be set to "Dodge"
in order for this setting to work.

"Bots Have One Down": While bots do not have a set number of downs (nor can have any, as there
wouldn't be any way to restore those downs), this option will essentially give the bots a
single down (in reality, it sets their "down timer" to zero). Once a bot goes down to damage
(not by incapacitation, such as Cloakers and Tasers), it will immediately go into custody.
This is a good option for those who think bots are too tanky and want an additional challenge.

"Bots Arrested By Cloakers": This option, if checked, will cause bots to be arrested by
Cloakers (like in Payday: The Heist) rather than incapacitated. This option does not work in
public lobbies, only friends-only, private, and offline mode.

"Disable Warcries": The bots have unique voicelines that play during an assault wave called warcries.
Human players don't have these, and if your game is modded so that NPC actions are faster (ie, Brand0's
AI Improver or TdlQ's Full Speed Swarm) then the bots will almost constantly be talking. If this annoys you
or you just want the bots to sound like human players, this option will disable those warcries.

"Bots Announce Low Health": While the bots will regenerate their health regularly, it can be useful to know
when they're taking too much punishment. Enabling this option will cause the bots to call out for a doctor bag
when they are below 20% of their max health (same as human players). This also has the effect of making the 
bots sound more human.

"Bots Dominate Cops Independently": Normally, the bots will assist in dominating cops whom you are shouting
at and/or tasered enemies, but will not attempt to dominate any enemies on their own. Additionally, enemies
you shout at or tase will not be attacked by the bots at all for ten seconds, regardless if the domination
attempt was successful. Enabling this option will force the bots to attempt to dominate cops within their
shout range, even if you aren't trying to dominate any cops yourself.

"Big Lobby": As the name implies, enabling this option will populate the available player slots with bots when
using the Big Lobby mod.

"Hyper Reflexes": This option will drastically improve the speed of bots' reactions. While this does make the
bots extremely alert to all enemies, it can have a potential framerate impact. Leave this unchecked if you run
into performance issues.

"Mask Up Upon Alert": Normally, the bots only mask up when the actual alarm has gone off. Enabling this option will
cause them to mask up immediately upon an aggressive alert being made (gunshots, explosions, etc).

"Disable Bot Equipment": Checking this option will cause the bots to not wear the lightweight ballistic vest and a
doctor/ammo bag, like vanilla bots.

"Combat Improvements": Enabling this option will give the bots improved damage/accuracy/etc values that have been
rebalanced to more closely resemble human players. Keep this off if you use other mods that affect these values,
such as Bot Weapons.

"Bot Kills Do Not Drop Ammo": With this option enabled, enemies won't drop ammo if they are killed by teammate AI.
This loosely approximates ammo consumption by the bots (think of it as the bots grabbing the pickups immediately)
and also prevents the issue of bots farming ammo for the player, resulting in a more realistic experience overall.

Credits and Contributions
-------------------------

Schmuddel - Creator of BB; maintenance of updates and bug fixes
Spruebox - Contributor and co-creator of BB
TdlQ - Fixed bots shooting at Shields and rewrote parts of code to avoid the need for updates
	with additional heisters; wrote the language changing code; prevented the bots from targeting
	tasered cops; various input in all aspects of the mod, particularly involving optimization for
	performance
Darkenednunit100 - Rewrote and simplified parts of the code, specifically the sections meant for 
	player customization; wrote the entirety of the bot domination code; general contributions to
	all aspects of the mod
topfpflanzen-würger - Advice and assistance on certain features; created BotWeapons and
	collaborated on making it compatible with BB; wrote the bot damage lerp code
Sandman/Droidaka - Inspiration and advice; crucial to the development of certain features,
	general performance, and maintenance
Frankelstner - Dumped and decoded mission scripts and wrote the code needed to edit them; also
	created The Long Guide, which was an invaluable resource
Yaph1l - Dumped the LUA code of the game, without which no modding would be possible; pointed
	out Frankelstner's mission script dumps
LycanCHKN - Contributed the Italian localization
PsychoticFalcon - Contributed the Swedish localization
chrom[K]a - Contributed the Russian localization
shadows - Contributed the Chinese localization
SC - Advice on disabling the "run_stop" and "run_start" animations and general feedback; wrote the code
	fixing the bots' bag carrying speed
Punk Foxy - Bug reporting and testing; general feedback