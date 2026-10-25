#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes_zm\_hud_util;

/*##############################################################################
                              Position HUD
##############################################################################*/
// Development tool, separate from the menu build: shows each player's origin
// and view angles on screen for collecting teleport locations.
// Deploy as scripts\zm\position_hud.gsc; remove the file to turn it off.

init()
{
	level thread position_hud_on_connect();
}

position_hud_on_connect()
{
	for(;;)
	{
		level waittill("connected", player);
		player thread position_hud();
	}
}

position_hud()
{
	self endon("disconnect");
	self waittill("spawned_player");

	hud = self createFontString("default", 1.2);
	hud setPoint("TOPRIGHT", "TOPRIGHT", -10, 80);
	hud.hidewheninmenu = 1;
	hud.foreground = true;

	for(;;)
	{
		// getPlayerAngles is the view direction; pass it to setPlayerAngles when teleporting.
		hud setTextUnlimited("origin " + self.origin + "\nangles " + self getPlayerAngles());
		wait 0.05;
	}
}
