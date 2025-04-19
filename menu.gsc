#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\gametypes_zm\_hud_message;

#include scripts\zm\origins_menu\basegame;
#include scripts\zm\origins_menu\fullgame;
#include scripts\zm\origins_menu\panzprac;
#include scripts\zm\origins_menu\genprac;
#include scripts\zm\origins_menu\icestart;
#include scripts\zm\origins_menu\windstart;

#include scripts\zm\origins_menu\menu_utility;
#include scripts\zm\origins_menu\menu_base;

main()
{
	set_dvar_if_unset("o_menu_gamemode", "fullgame");
	level.gamemode = getDvar("o_menu_gamemode");
	level.version = "5.2";
	basegame_initialize();

	switch(level.gamemode)
	{
		case "fullgame": fullgame_initialize(); break;
		case "panzprac": panzprac_initialize(); break;
		case "genprac": genprac_initialize(); break;
		case "icestart": icestart_initialize(); break;
		case "windstart": windstart_initialize(); break;
		//case "firestart": icestart_initialize(); break;
		//case "lightningstart": icestart_initialize(); break
	}

	flag_wait("initial_blackscreen_passed");
	if(level.gamemode != "icestart" && level.gamemode != "windstart") level.game_start_time = getTime();
}

init()
{
    //level.player_out_of_playable_area_monitor = 0;

	switch(level.gamemode)
	{
		case "fullgame": level thread fullgame_run(); break;
		case "panzprac": level thread panzprac_run(); break;
		case "genprac": level thread genprac_run(); break;
		case "icestart": level thread icestart_run(); break;
		case "windstart": level thread windstart_run(); break;
	}
	level thread basegame_run();

    level thread on_player_connect_menu();
	level thread water_mark();

    level.strings = [];
    level.string_count = 1;
    level.menu_title = "Huth's O-Practice " + level.version;
    level.host_spawned = false;

    //Shaders
    precacheshader( "lui_soldier" );
    //level thread fast_quit();
}

on_player_connect_menu()
{
	while(true)
	{
		level waittill("connecting", player);

		if(player isHost())
			player.status = "Host";
		else
			player.status = "Unverified";

		player thread on_player_spawned_menu();
	}
}

on_player_spawned_menu()
{
	self endon("disconnect");
	level endon("game_ended");

	while(true)
	{
		self waittill("spawned_player");

		if(!isDefined(self.has_menu))
		{
			self.has_menu = true;
			self thread initialize_menu();
		}

		if(!level.host_spawned && self isHost())
		{
			thread overflow_fix();
			//self freezeControls(false);
			level.host_spawned = true;
		}
	}
}

water_mark()
{
	watermark = newhudelem();
	watermark.fontscale = 1;
	watermark.alignx = "right";
	watermark.aligny = "top";
	watermark.horzalign = "user_right";
	watermark.vertalign = "user_top";
	watermark.x = -4;
	watermark.y = 13;
	watermark.foreground = 1;
	watermark.alpha = 0.7;
	watermark.color = (1, 1, 1);
	watermark set_safe_text("^6O-Practice " + level.version);
}