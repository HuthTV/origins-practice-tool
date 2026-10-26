#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\gametypes_zm\_hud_message;

#include scripts\zm\practice_core\menu_base;
#include scripts\zm\practice_core\menu_utility;

/*##############################################################################
                              Map descriptor and start-up
##############################################################################*/
// The core never names map code. Each map's entry script (zm_tomb\o-prac-menu.gsc,
// zm_prison\m-prac-menu.gsc) describes its map with this struct, fills in the hooks it
// needs, registers its modes and calls practice_main and practice_init.
// Every hook is optional:
//   initialize()               while the map loads, after the base cfg and before
//                              the mode's initialize: map-wide replacefuncs
//   build_hud(menu)            HUD rows after the core rows
//   build_cheats(menu)         Cheats rows after the core rows
//   base_cfg_defaults(cfg)     returns cfg plus the map's basegame.cfg settings
//   say_command(message)       chat words the core does not know (self = player)
//   open_doors()               replaces the core Open Doors
//   open_doors_extra()         extra step inside the core Open Doors (self = player)
//   oopa_tick()                each out-of-playable-area check (self = player)
//   oopa_hud_spot()            where the OOPA Countdown shows, e.g. a trick (self = player)
//   oopa_hud_spot_label        name of its "only" choice in the HUD menu, like "R2L only"
//   hud_left_shift()           x offset for the left HUD (zone, HP) (self = player)
//   run()                      map-wide threads, started with the core HUDs
practice_map(menu_title, tool_name, cfg_dir, mode_dvar)
{
    map = spawnstruct();
    map.menu_title = menu_title;     // Menu header
    map.tool_name = tool_name;       // Start-up message
    map.cfg_dir = cfg_dir;           // Folder of every cfg file, like "O_PRAC/"
    map.mode_dvar = mode_dvar;       // Dvar holding the selected mode
    map.accent_color = (0.54, 0.17, 0.89);
    return map;
}

// Call from the entry's main(), after registering the modes. The first
// registered mode is the default.
practice_main(map, version)
{
    level.practice_map = map;
    level.practice_version = version;

    setdvar("scr_allowFileIo", 1);
    set_dvar_if_unset(map.mode_dvar, level.modes[0].name);
    level.mode = get_mode(getDvar(map.mode_dvar));
    level.gamemode = level.mode.name;

    basegame_initialize();
    [[ level.mode.initialize ]]();

    flag_wait("initial_blackscreen_passed");
    // A map may have started the run clock earlier (Mob: its afterlife intro).
    if(!isDefined(level.game_start_time)) level.game_start_time = getTime();
}

// Call from the entry's init().
practice_init()
{
    level thread [[ level.mode.run ]]();
    level thread basegame_run();
    level thread on_player_connect_menu();
    level.menu_title = level.practice_map.menu_title + " " + level.practice_version;
    precacheshader( "lui_soldier" );	//Shader of menu bg
}

on_player_connect_menu()
{
	while(true)
	{
		level waittill("connecting", player);
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
        self thread basegame_health_damage_monitor();

		if(!isDefined(self.has_menu))
		{
			self.has_menu = true;
			self thread initialize_menu();
		}

		flag_wait("initial_blackscreen_passed");

		if(self isHost())
		{
			if(get_cfg_int("hud_speed"))
				self thread basegame_speedometer();
		}
		else
		{
			speeddvar = self.name + "_speedometer";
			set_dvar_float_if_unset( speeddvar, "1" );
			if(int(getdvar(speeddvar)))
				self thread basegame_speedometer();
		}
	}
}

basegame_initialize()
{
    basegame_cfg_init();
    basegame_overrides();
    basegame_apply_show_identifier();
    if(isDefined(level.practice_map.initialize)) [[ level.practice_map.initialize ]]();
}

basegame_run()
{
    level thread say_command_monitor();
    flag_wait("initial_blackscreen_passed");
    iPrintLn( "^7" + level.practice_map.tool_name + " ^3" + level.practice_version );
    iPrintLn( "^7Press [^6[{+melee}]^7] + [^6[{+smoke}]^7] ^7To Open" );
    wait 1.8;

    level thread basegame_unitrigger_hud_monitor();
    level thread basegame_optional_hud_monitor();
    level thread basegame_zone_hud_monitor();
    level thread basegame_oopa_hud_monitor();
    if(isDefined(level.practice_map.run)) level thread [[ level.practice_map.run ]]();
    if(get_cfg_int("hud_points")) level thread basegame_points_hud();
}

reset_dvars()
{
	setDvar("timescale", 1);
	setDvar("g_speed", 190);
	setDvar("g_ai", 1);
}

basegame_cfg_init()
{
    level.base_cfg_str = level.practice_map.cfg_dir + "basegame.cfg";
    level.base_cfg = cfg_load(level.base_cfg_str, basegame_default_cfg());
}

basegame_default_cfg()
{
    settings_ar = [];

    // Convert all set_dvar_if_unset calls to cfg defaults
    settings_ar["hud_points"] = 0;
    settings_ar["oopa"] = 1;
    settings_ar["hud_remaning"] = 0;
    settings_ar["hud_spawned"] = 0;
    settings_ar["hud_health"] = 0;
    settings_ar["hud_zone"] = 0;
    settings_ar["hud_speed"] = 0;
    settings_ar["hud_unitrigger"] = 0;
    settings_ar["hud_oopa"] = 1; // OOPA Countdown: 0 off, 1 on, 2 the map's spot only (Origins: R2L)
    settings_ar["show_identifier"] = 0; // Plutonium's session identifier and script hashes.

    if(isDefined(level.practice_map.base_cfg_defaults))
        settings_ar = [[ level.practice_map.base_cfg_defaults ]](settings_ar);
    return settings_ar;
}

// Plutonium's on-screen session identifier (cg_drawIdentifier) and the script
// hashes it flashes at the start of a game (cg_flashScriptHashes). Solo, the
// host's dvars are the player's own.
basegame_apply_show_identifier()
{
    show = get_cfg_int("show_identifier");
    setdvar("cg_flashScriptHashes", show);
    setdvar("cg_drawIdentifier", show);
}

// Menu action for "Show Identifier/Hashes".
basegame_toggle_show_identifier()
{
    self cfg_toggle_binary("show_identifier");
    basegame_apply_show_identifier();
}

basegame_overrides()
{
    replacefunc( maps\mp\zombies\_zm::player_out_of_playable_area_monitor, ::basegame_player_out_of_playable_area_monitor);
    replacefunc( maps\mp\zombies\_zm_powerups::watch_for_drop, ::basegame_watch_for_drop );
}

// toggles




toggle_pointbased()
{
    setting = "hud_points";
    status = get_cfg_int(setting);

    switch (status) {
    case 2:
        new_status = 0;
        level.point_based_hud destroy();
        break;
    case 0:             //relative
        level thread basegame_points_hud();
        new_status = 1;
        break;
    case 1:             //absollute
        new_status = 2;
        break;
    }
    level.base_cfg[setting] = new_status;
    write_config(level.base_cfg, level.base_cfg_str);
    self refresh_menu();
}

//funcs

give_drop( drop )
{
    powerup = level maps\mp\zombies\_zm_powerups::specific_powerup_drop( drop, self.origin );
    powerup thread maps\mp\zombies\_zm_powerups::powerup_timeout();
}

//HUD ELEMS

basegame_points_hud()
{
    self endon( "disconnect" );
    level.point_based_hud = createServerFontString( "hudsmall", 1.4 );
    level.point_based_hud.alignx = "left";
    level.point_based_hud.aligny = "middle";
    level.point_based_hud.horzalign = "right";
    level.point_based_hud.vertalign = "bottom";
    level.point_based_hud.x = -170;
    level.point_based_hud.y = 8;
    level.point_based_hud.alpha = 0.8;
    level.point_based_hud.hidewheninmenu = 0;

    while(isDefined(level.point_based_hud))
    {
        players = get_players();
        new_total_score = 0;

        for ( i = 0; i < players.size; i++ )
        {
            if ( isdefined( players[i].score_total ) )
                new_total_score += players[i].score_total;
        }

        mode = get_cfg_int( "hud_points" );
        if(mode == 1)
        {
            point_req = int( level.score_to_drop + 0.99 ) - ( players[0].score_total - players[0].score );
            point_cur = players[0].score;

            level.point_based_hud.text = point_cur + "/" + point_req;
            level.point_based_hud setTextUnlimited( level.point_based_hud.text );
        }
        else if(mode == 2)
        {
            point_req = int( level.score_to_drop + 0.99 );
            point_cur = new_total_score;

            level.point_based_hud.text = point_cur + "/" + point_req;
            level.point_based_hud setTextUnlimited( level.point_based_hud.text );
        }

        if ( level.zombie_vars["zombie_drop_item"] )
            level.point_based_hud.color = (0.54, 0.17, 0.89);
        else
            level.point_based_hud.color = ( 1, 1, 1 );

        wait 0.05;
    }
}





//OOOOOOOOOOOOOOOOVERUDDDDDDES

basegame_watch_for_drop()
{
    flag_wait( "start_zombie_round_logic" );
    flag_wait( "begin_spawning" );
    players = get_players();
    level.score_to_drop = players.size * level.zombie_vars["zombie_score_start_" + players.size + "p"] + level.zombie_vars["zombie_powerup_drop_increment"];

    while ( true )
    {
        flag_wait( "zombie_drop_powerups" );
        players = get_players();
        curr_total_score = 0;

        for ( i = 0; i < players.size; i++ )
        {
            if ( isdefined( players[i].score_total ) )
                curr_total_score += players[i].score_total;
        }

        if ( curr_total_score > level.score_to_drop )
        {
            level.zombie_vars["zombie_powerup_drop_increment"] *= 1.14;
            level.score_to_drop = curr_total_score + level.zombie_vars["zombie_powerup_drop_increment"];
            level.zombie_vars["zombie_drop_item"] = 1;
        }

        wait 0.5;
    }
}

// Vanilla player_out_of_playable_area_monitor's condition: outside every life
// brush, and in a kill brush or outside the enabled playable area.
basegame_out_of_playable_area()
{
	return !self maps\mp\zombies\_zm::in_life_brush() && (self maps\mp\zombies\_zm::in_kill_brush() || !self maps\mp\zombies\_zm::in_enabled_playable_area());
}

// OOPA Countdown (hud_oopa): a bar filling from each out-of-playable-area check
// to the next, framed red once a check caught the player out. 1 on: while the
// player is out of the playable area, or at the map's spot. 2: only at the
// map's spot (practice_map oopa_hud_spot, self = player; Origins: the R2L trick
// until trig_zone_bunker_6 fires). No bar before the first check (segment
// starts hold it until their clock starts).
basegame_oopa_hud_monitor()
{
	level endon("end_game");
	while(true)
	{
		setting = get_cfg_int("hud_oopa");
		foreach(player in get_players())
		{
			show = false;
			if(setting && isdefined(player.practice_oopa_tick))
			{
				spot = isdefined(level.practice_map.oopa_hud_spot) && player [[ level.practice_map.oopa_hud_spot ]]();
				if(setting == 2) show = spot;
				else show = spot || player basegame_out_of_playable_area();
			}
			if(show)
			{
				if(!isdefined(player.practice_oopa_bar))
				{
					player.practice_oopa_bar = player createbar((1, 1, 1), 24, 2);
					player.practice_oopa_bar setpoint("CENTER", "CENTER", 0, 12);
				}
				elapsed = (gettime() - player.practice_oopa_tick) / (maps\mp\zombies\_zm::get_player_out_of_playable_area_monitor_wait_time() * 1000);
				if(elapsed > 1) elapsed = 1;
				player.practice_oopa_bar updatebar(elapsed);
				if(is_true(player.practice_oopa_failing)) player.practice_oopa_bar.color = (1, 0, 0);
				else player.practice_oopa_bar.color = (0, 0, 0);
			}
			else if(isdefined(player.practice_oopa_bar))
			{
				player.practice_oopa_bar destroyelem();
				player.practice_oopa_bar = undefined;
			}
		}
		wait 0.05;
	}
}

basegame_player_out_of_playable_area_monitor()
{
	self notify("stop_player_out_of_playable_area_monitor");
	self endon("stop_player_out_of_playable_area_monitor");
	self endon("disconnect");
	level endon("end_game");
	while(!isdefined(self.characterindex))
	{
		wait 0.05;
	}
	//MODIFIED: a mode may hold the first check instead (level.oopa_first_check, self =
	// player); segment starts pause it until their run clock starts, then phase it.
	if(isdefined(level.oopa_first_check)) self [[ level.oopa_first_check ]]();
	else wait 0.15 * self.characterindex;
	//MODIFIED END
	while(true)
	{
		//MODIFIED: the OOPA Countdown times from each check and shows its result
		self.practice_oopa_tick = gettime();
		self.practice_oopa_failing = self basegame_out_of_playable_area();
		if(isdefined(level.practice_map.oopa_tick)) self [[ level.practice_map.oopa_tick ]]();
		//MODIFIED END
		if(self.sessionstate == "spectator")
		{
			wait maps\mp\zombies\_zm::get_player_out_of_playable_area_monitor_wait_time();
			continue;
		}
		if(is_true(level.hostmigration_occured))
		{
			wait maps\mp\zombies\_zm::get_player_out_of_playable_area_monitor_wait_time();
			continue;
		}
		//MODIFIED: vanilla's condition, shared with the OOPA Countdown
		if(self basegame_out_of_playable_area())
		//MODIFIED END
		{
			if(!isdefined(level.player_out_of_playable_area_monitor_callback) || self [[level.player_out_of_playable_area_monitor_callback]]())
			{
				self maps\mp\zombies\_zm_stats::increment_map_cheat_stat("cheat_out_of_playable");
				self maps\mp\zombies\_zm_stats::increment_client_stat("cheat_out_of_playable", 0);
				self maps\mp\zombies\_zm_stats::increment_client_stat("cheat_total", 0);
				if(get_cfg_int("oopa") == 1) self playlocalsound(level.zmb_laugh_alias);
				wait 0.5;
                if(get_cfg_int("oopa"))
                {
                    if(get_players().size == 1 && flag("solo_game") && (isdefined(self.waiting_to_revive) && self.waiting_to_revive))
                    {
                        level notify("end_game");
                    }
                    else
                    {
                        self disableinvulnerability();
                        self.lives = 0;
                        self dodamage(self.health + 1000, self.origin);
                        self.bleedout_time = 0;
                    }
                }
			}
		}
        else
        {
        }
		wait maps\mp\zombies\_zm::get_player_out_of_playable_area_monitor_wait_time();
	}
}

basegame_speedometer()
{
    self endon("kill_speedometer");

    self.speedometer = createfontstring("default", 1.4);
    self.speedometer.alpha = 0.8;
    self.speedometer.hidewheninmenu = 1;
    self.speedometer setpoint("CENTER", "CENTER", 0, 190);

    while (true)
    {
        self set_speedometer_color();
        wait 0.05;
    }
}

set_speedometer_color()
{
    velocity = int(length(self getvelocity() * (1, 1, 0))); //ignore vertical velocity
    self.speedometer setValue(velocity);

    if(isdefined( self.afterlife ) && self.afterlife )
    {
        self.speedometer.color = (0.6, 1.0, 1.0);      //pale cyan
        self.speedometer.glowcolor = (0.3, 0.8, 1.0);  //cyan glow
        return;
    }

    //Speed range for color gradient
    if(self hasperk("specialty_longersprint"))
    {
        min_speed = 310.0;
        max_speed = 390.0;
    }
    else
    {
        min_speed = 260.0;
        max_speed = 350.0;
    }

    //clamp value 0-1
    ratio = (velocity - min_speed) / (max_speed - min_speed);
    ratio = max(0, min(1, ratio));

    if (ratio < 0.5)
    {
        rt = ratio / 0.5;
        self.speedometer.color = (0.6 + 0.4 * rt, 1.0, 0.6); // green -> yellow
        self.speedometer.glowcolor = (0.4 + 0.3 * rt, 0.7, 0.4);
    }
    else
    {
        rt = (ratio - 0.5) / 0.5;
        self.speedometer.color = (1.0, 1.0 - 0.8 * rt, 0.6 - 0.6 * rt); // yellow -> red
        self.speedometer.glowcolor = (0.7, 0.7 - 0.6 * rt, 0.4 - 0.4 * rt);
	}
}

say_command_monitor()
{
	while(true)
	{
		level waittill("say", message, player);
		switch(tolower(message))
		{
			case "max":
				player give_drop("full_ammo");
				break;

			case "insta":
				player give_drop("insta_kill");
				break;

			case "nuke":
				player give_drop("nuke");
				break;

			case "double":
				player give_drop("double_points");
				break;

			case "points":
				player set_points(1000000);
				break;

			case "demi":
				player toggle_demigod();
				break;
			case "pap":
				player upgrade_weapon();
				break;
            case "doors":
                player thread open_all_doors();
                break;
            default:
                if(isdefined(level.practice_map.say_command))
                    player thread [[ level.practice_map.say_command ]](tolower(message));
                break;
		}
	}
}

// Unitrigger HUD functions
basegame_toggle_unitrigger_hud()
{
    level.base_cfg["hud_unitrigger"] = 1 - get_cfg_int("hud_unitrigger");
    write_config(level.base_cfg, level.base_cfg_str);
    if(!get_cfg_int("hud_unitrigger")) basegame_unitrigger_hud_destroy_all();
    self refresh_menu();
}

basegame_unitrigger_hud_destroy_all()
{
    if(!isDefined(level.unitrigger_debug_huds)) return;
    foreach(record in level.unitrigger_debug_huds)
        if(isDefined(record) && isDefined(record.hud)) record.hud destroy();
    level.unitrigger_debug_huds = [];
}

basegame_unitrigger_hud_monitor()
{
    level notify("stop_unitrigger_debug");
    level endon("stop_unitrigger_debug");
    basegame_unitrigger_hud_destroy_all();
    level.unitrigger_debug_huds = [];
    level thread basegame_unitrigger_hud_game_end();
    while(true)
    {
        if(!get_cfg_int("hud_unitrigger"))
            basegame_unitrigger_hud_destroy_all();
        else
        {
            present = [];
            foreach(player in get_players())
            {
                if(!isDefined(player)) continue;
                index = player getentitynumber();
                present[index] = true;
                record = level.unitrigger_debug_huds[index];
                if(isDefined(record) && record.player != player)
                {
                    if(isDefined(record.hud)) record.hud destroy();
                    record = undefined;
                }
                if(!isDefined(record))
                {
                    record = spawnstruct();
                    record.player = player;
                    record.hud = player createFontString("hudsmall", 1.1);
                    record.hud setpoint("LEFT", "TOP", 12, 110);
                    record.text = "";
                    level.unitrigger_debug_huds[index] = record;
                }
                text = player basegame_unitrigger_debug_text();
                if(text != record.text)
                {
                    record.hud setTextUnlimited(text);
                    record.text = text;
                }
            }
            // Keep HUD ownership outside the player entity so disconnect cleanup works.
            foreach(index, record in level.unitrigger_debug_huds)
            {
                if(isDefined(record) && !isDefined(present[index]))
                {
                    if(isDefined(record.hud)) record.hud destroy();
                    level.unitrigger_debug_huds[index] = undefined;
                }
            }
        }
        wait 0.1;
    }
}

basegame_unitrigger_hud_game_end()
{
    level notify("replace_unitrigger_debug_cleanup");
    level endon("replace_unitrigger_debug_cleanup");
    level waittill("game_ended");
    level notify("stop_unitrigger_debug");
    basegame_unitrigger_hud_destroy_all();
}

basegame_unitrigger_debug_text()
{
    trigger = level._unitriggers.trigger_pool[self getentitynumber()];
    status = "^7selected (inactive)";
    if(isDefined(trigger.thread_running) && trigger.thread_running) status = "^2active";
    name = "unnamed";
    type = "unitrigger";
    if(isDefined(trigger.stub))
    {
        if(isDefined(trigger.stub.targetname) && trigger.stub.targetname != "") name = trigger.stub.targetname;
        else if(isDefined(trigger.stub.equipname)) name = trigger.stub.equipname;
        else if(isDefined(trigger.stub.script_noteworthy)) name = trigger.stub.script_noteworthy;
        if(isDefined(trigger.stub.script_unitrigger_type)) type = trigger.stub.script_unitrigger_type;
    }
    return "^3Unit trigger: " + status + " ^7#" + trigger getentitynumber() + " " + name + " (" + type + ")";
}

// One owner creates, updates and destroys optional HUDs during gameplay.
basegame_optional_hud_monitor()
{
    level thread basegame_watch_game_over();
    while(true)
    {
        spawned = get_round_enemy_array().size;
        if(get_cfg_int("hud_remaning"))
        {
            if(!isdefined(level.zombie_counter_hud))
            {
                level.zombie_counter_hud = createServerFontString("hudsmall", 1.3);
                level.zombie_counter_hud setpoint("LEFT", "CENTER", 60, 185);
                level.zombie_counter_hud.label = &"remaining: ^1";
            }
            level.zombie_counter_hud setvalue(spawned + level.zombie_total);
        }
        else if(isdefined(level.zombie_counter_hud))
        {
            level.zombie_counter_hud destroy();
            level.zombie_counter_hud = undefined;
        }
        if(get_cfg_int("hud_spawned"))
        {
            if(!isdefined(level.zombie_spawned_hud))
            {
                level.zombie_spawned_hud = createServerFontString("hudsmall", 1.3);
                level.zombie_spawned_hud setpoint("LEFT", "CENTER", 60, 200);
                level.zombie_spawned_hud.label = &"spawned: ^1";
            }
            level.zombie_spawned_hud setvalue(spawned);
        }
        else if(isdefined(level.zombie_spawned_hud))
        {
            level.zombie_spawned_hud destroy();
            level.zombie_spawned_hud = undefined;
        }
        foreach(player in get_players())
            player basegame_update_health_bar();
        wait 0.05;
    }
}

basegame_update_health_bar()
{
    if(!get_cfg_int("hud_health"))
    {
        if(isdefined(self.practice_health_bg)) self.practice_health_bg destroy();
        if(isdefined(self.practice_health_fill)) self.practice_health_fill destroy();
        if(isdefined(self.practice_health_value)) self.practice_health_value destroy();
        if(isdefined(self.practice_regen_bg)) self.practice_regen_bg destroy();
        if(isdefined(self.practice_regen_fill)) self.practice_regen_fill destroy();
        self.practice_regen_bg = undefined;
        self.practice_regen_fill = undefined;
        self.practice_health_value = undefined;
        self.practice_health_bg = undefined;
        self.practice_health_fill = undefined;
        return;
    }
    if(!isdefined(self.practice_health_bg))
    {
        self.practice_health_bg = newclienthudelem(self);
        self.practice_health_bg.horzalign = "left";
        self.practice_health_bg.vertalign = "bottom";
        self.practice_health_bg.alignx = "left";
        self.practice_health_bg.aligny = "top";
        self.practice_health_bg.x = -10;
        self.practice_health_bg.y = -42;
        self.practice_health_bg.color = (0.1, 0.1, 0.1);
        self.practice_health_bg.alpha = 0.8;
        self.practice_health_bg.sort = 1999;
        self.practice_health_bg setshader("white", 70, 8);
        self.practice_health_fill = newclienthudelem(self);
        self.practice_health_fill.horzalign = "left";
        self.practice_health_fill.vertalign = "bottom";
        self.practice_health_fill.alignx = "left";
        self.practice_health_fill.aligny = "top";
        self.practice_health_fill.x = -9;
        self.practice_health_fill.y = -41;
        self.practice_health_fill.sort = 2000;
    }
    if(!isdefined(self.practice_health_value))
    {
        self.practice_health_value = createfontstring("default", 1.4);
        self.practice_health_value.horzalign = "left";
        self.practice_health_value.vertalign = "bottom";
        self.practice_health_value.alignx = "left";
        self.practice_health_value.aligny = "middle";
        self.practice_health_value.x = -30;
        self.practice_health_value.y = -36;
        self.practice_health_value.sort = 2000;
        self.practice_health_value.color = (1, 1, 1);
    }
    shift = self basegame_hud_left_shift();
    self.practice_health_bg.x = -10 + shift;
    self.practice_health_fill.x = -9 + shift;
    self.practice_health_value.x = -30 + shift;
    self.practice_hud_shift = shift;

    // Downed and game-over players keep 100 health; show them as dead.
    alive = self basegame_hud_alive();
    health = 0;
    if(alive) health = self.health;
    self.practice_health_value setvalue(health);
    fraction = 0;
    if(alive && isdefined(self.maxhealth) && self.maxhealth > 0)
        fraction = self.health / self.maxhealth;
    if(fraction < 0) fraction = 0;
    if(fraction > 1) fraction = 1;
    width = int(68 * fraction);
    if(width < 1) width = 1;
    self.practice_health_fill setshader("white", width, 6);
    self.practice_health_fill.alpha = 0.9;
    if(fraction <= 0) self.practice_health_fill.alpha = 0;
    self.practice_health_fill.color = (1, 1, 1);
    self basegame_update_regen_bar();
}


basegame_zone_hud_monitor()
{
    level endon("end_game");
    while(true)
    {
        foreach(player in get_players())
            player basegame_update_zone_hud();
        wait 0.25;
    }
}

basegame_update_zone_hud()
{
    if(!get_cfg_int("hud_zone"))
    {
        if(isdefined(self.practice_zone_hud)) self.practice_zone_hud destroy();
        self.practice_zone_hud = undefined;
        self.practice_zone_text = undefined;
        return;
    }
    if(!isdefined(self.practice_zone_hud))
    {
        self.practice_zone_hud = createfontstring("hudsmall", 1.3);
        self.practice_zone_hud.horzalign = "left";
        self.practice_zone_hud.vertalign = "bottom";
        self.practice_zone_hud.alignx = "left";
        self.practice_zone_hud.aligny = "middle";
        self.practice_zone_hud.x = -30;
        self.practice_zone_hud.y = -55;
        self.practice_zone_hud.sort = 2000;
        self.practice_zone_hud.hidewheninmenu = 1;
    }
    self.practice_zone_hud.x = -30 + self basegame_hud_left_shift();
    zone = undefined;
    if(isdefined(level.zones)) zone = self maps\mp\zombies\_zm_zonemgr::get_player_zone();
    if(!isdefined(zone)) zone = "unknown";
    if(zone.size >= 5 && getsubstr(zone, 0, 5) == "zone_")
        zone = getsubstr(zone, 5, zone.size);
    if(zone.size >= 5 && getsubstr(zone, zone.size - 5, zone.size) == "_zone")
        zone = getsubstr(zone, 0, zone.size - 5);
    if(!isdefined(self.practice_zone_text) || self.practice_zone_text != zone)
    {
        self.practice_zone_hud setTextUnlimited("zone: " + zone);
        self.practice_zone_text = zone;
    }
}


// Observe damage notifications, including grenade self-damage.
basegame_health_damage_monitor()
{
    self notify("practice_health_damage_monitor");
    self endon("practice_health_damage_monitor");
    self endon("disconnect");
    self endon("death");
    level endon("end_game");
    self.practice_hurt_time = undefined;
    self.practice_severe_hurt = false;
    while(true)
    {
        self waittill("damage", amount, attacker);
        if(isdefined(attacker) && attacker != self && isplayer(attacker) && attacker.team == self.team) continue;
        self.practice_hurt_time = gettime();
    }
}

basegame_update_regen_bar()
{
    if(!isdefined(self.practice_regen_bg))
    {
        self.practice_regen_bg = newclienthudelem(self);
        self.practice_regen_bg.horzalign = "left";
        self.practice_regen_bg.vertalign = "bottom";
        self.practice_regen_bg.alignx = "left";
        self.practice_regen_bg.aligny = "top";
        self.practice_regen_bg.x = -10;
        self.practice_regen_bg.y = -32;
        self.practice_regen_bg.color = (0.1, 0.1, 0.1);
        self.practice_regen_bg.sort = 1999;
        self.practice_regen_bg setshader("white", 70, 5);
        self.practice_regen_fill = newclienthudelem(self);
        self.practice_regen_fill.horzalign = "left";
        self.practice_regen_fill.vertalign = "bottom";
        self.practice_regen_fill.alignx = "left";
        self.practice_regen_fill.aligny = "top";
        self.practice_regen_fill.x = -9;
        self.practice_regen_fill.y = -31;
        self.practice_regen_fill.color = (0.65, 0.65, 0.65);
        self.practice_regen_fill.sort = 2000;
    }
    self.practice_regen_bg.x = -10 + self.practice_hud_shift;
    self.practice_regen_fill.x = -9 + self.practice_hud_shift;
    self.practice_regen_bg.alpha = 0;
    self.practice_regen_fill.alpha = 0;
    if(!self basegame_hud_alive() || !isdefined(self.maxhealth) || self.health >= self.maxhealth)
    {
        self.practice_hurt_time = undefined;
        self.practice_severe_hurt = false;
        return;
    }
    if(!isdefined(self.practice_hurt_time)) return;
    if(self.health / self.maxhealth <= level.healthoverlaycutoff)
        self.practice_severe_hurt = true;
    delay = level.playerhealth_regularregendelay;
    self.practice_regen_fill.color = (1, 1, 1);
    if(self.practice_severe_hurt)
    {
        delay = level.longregentime;
        self.practice_regen_fill.color = (1, 0, 0);
    }
    if(delay <= 0) return;
    fraction = (gettime() - self.practice_hurt_time) / delay;
    if(fraction < 0) fraction = 0;
    if(fraction > 1) fraction = 1;
    width = int(68 * fraction);
    if(width < 1) width = 1;
    self.practice_regen_bg.alpha = 0.8;
    self.practice_regen_fill setshader("white", width, 3);
    if(fraction > 0) self.practice_regen_fill.alpha = 0.9;
}


basegame_hud_alive()
{
    // A solo bleed-out ends the game with the player still playing at full health.
    if(is_true(level.practice_game_over)) return false;
    if(!isalive(self) || self.sessionstate != "playing") return false;
    return !self maps\mp\zombies\_zm_laststand::player_is_in_laststand();
}

basegame_watch_game_over()
{
    level waittill("end_game");
    level.practice_game_over = true;
}

// x offset for the left-side HUD (zone, HP and regen); the map can move it
// around its own HUD icons.
basegame_hud_left_shift()
{
    if(isdefined(level.practice_map.hud_left_shift)) return self [[ level.practice_map.hud_left_shift ]]();
    return 0;
}


