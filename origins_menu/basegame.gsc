#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\gametypes_zm\_hud_message;

#include scripts\zm\origins_menu\menu_utility;
#include scripts\zm\origins_menu\menu_base;

basegame_initialize()
{
    reset_replacefuncs();
    basegame_cfg_init();
    basegame_overrides();
}

basegame_run()
{
    level thread say_command_monitor();
    flag_wait("initial_blackscreen_passed");
    iPrintLn( "^7Huth's Origins Practice Tool ^3" + level.oprac_version );
    iPrintLn( "^7Press [^6[{+melee}]^7] + [^6[{+smoke}]^7] ^7To Open" );
    wait 1.8;

    if(get_cfg_int("hud_remaning")) level thread basegame_zombie_remaining_hud();
    if(get_cfg_int("hud_spawned")) level thread basegame_zombie_spawned_hud();
    if(get_cfg_int("hud_points")) level thread basegame_points_hud();
}

reset_replacefuncs()
{
    replacefuncs = [];

    fullgame_replacefuncs = array(
        maps\mp\zm_tomb_giant_robot::robot_cycling,
        maps\mp\zm_tomb_giant_robot::giant_robot_start_walk,
        maps\mp\zm_tomb_craftables::randomize_craftable_spawns,
        maps\mp\zombies\_zm_craftables::generate_zombie_craftable_piece,
        maps\mp\zm_tomb_capture_zones::get_recapture_zone,
        maps\mp\zm_tomb_capture_zones::recapture_round_tracker,
        maps\mp\zm_tomb_dig::waittill_dug,
        maps\mp\zm_tomb_dig::bonus_points_powerup_override,
        maps\mp\zm_tomb_dig::dig_spots_respawn,
        maps\mp\zombies\_zm_perk_random::get_weighted_random_perk,
        maps\mp\zm_tomb_quest_crypt::chamber_discs_randomize,
        maps\mp\zm_tomb_ee_main_step_4::stage_logic,
        maps\mp\zombies\_zm_powerups::randomize_powerups,
        maps\mp\zombies\_zm_powerups::powerup_drop
    );

    replacefuncs = combinearrays(fullgame_replacefuncs, replacefuncs);

    panzprac_replacefuncs= array(
        //maps\mp\zm_tomb_giant_robot::robot_cycling,
        maps\mp\zombies\_zm_ai_mechz::mechz_spawn
    );

    replacefuncs = combinearrays(panzprac_replacefuncs, replacefuncs);

    genprac_replacefuncs= array(
        maps\mp\zm_tomb_capture_zones::recapture_round_start,
        maps\mp\zombies\_zm_ai_mechz::mechz_spawning_logic,
        maps\mp\zombies\_zm_weap_beacon::player_throw_beacon
    );

    replacefuncs = combinearrays(genprac_replacefuncs, replacefuncs);

    icestart_replacefuncs= array(
        maps\mp\zombies\_zm_ai_mechz_ffotd::mechz_round_tracker_loop_start,
        maps\mp\zm_tomb_utility::zone_capture_powerup,
        maps\mp\zm_tomb_tank::activate_tank_wait_with_no_cost
        //maps\mp\zm_tomb_giant_robot::giant_robot_start_walk,
        //maps\mp\zm_tomb_craftables::generate_zombie_craftable_piece,
        //maps\mp\zm_tomb_capture_zones::get_recapture_zone,
        //maps\mp\zm_tomb_capture_zones::recapture_round_tracker
        //maps\mp\zm_tomb_dig::dig_spots_respawn,
        //maps\mp\zm_tomb_dig::waittill_dug,
        //maps\mp\zm_tomb_giant_robot::robot_cycling,
        //maps\mp\zm_tomb_quest_crypt::chamber_discs_randomize,
        //maps\mp\zm_tomb_craftables::randomize_craftable_spawns
    );

    replacefuncs = combinearrays(icestart_replacefuncs, replacefuncs);

	foreach(func in replacefuncs)
		replacefunc(func, func);
}

reset_dvars()
{
	setDvar("timescale", 1);
	setDvar("g_speed", 190);
	setDvar("g_ai", 1);
}

basegame_cfg_init()
{
    // Initialize basegame-specific cfg system
    level.base_cfg = [];
    level.base_cfg = basegame_default_cfg();
    level.base_cfg_str = "OPRAC/basegame.cfg";

    // Load existing config if exists
    if(fs_testfile(level.base_cfg_str))
    {
        read_cfg = read_config( level.base_cfg_str );
        foreach(setting in getarraykeys(read_cfg))
            level.base_cfg[setting] = read_cfg[setting];
    }
    else
    {
        // Create default config file
        write_config(level.base_cfg, level.base_cfg_str);
    }
}

basegame_default_cfg()
{
    settings_ar = [];

    // Convert all set_dvar_if_unset calls to cfg defaults
    settings_ar["hud_points"] = 0;
    settings_ar["oopa_hud"] = 0;
    settings_ar["oopa"] = 1;
    settings_ar["despawns"] = 0;
    settings_ar["hud_remaning"] = 0;
    settings_ar["hud_spawned"] = 0;
    settings_ar["hud_speed"] = 0;
    settings_ar["turbo_restarts"] = 1;

    return settings_ar;
}

basegame_overrides()
{
    replacefunc( maps\mp\zombies\_zm::player_out_of_playable_area_monitor, ::basegame_player_out_of_playable_area_monitor);
	replacefunc( maps\mp\zm_tomb_distance_tracking::zombie_tracking_init, ::basegame_zombie_tracking_init );
	replacefunc( maps\mp\zm_tomb_distance_tracking::delete_zombie_noone_looking, ::basegame_delete_zombie_noone_looking);
    replacefunc( maps\mp\zombies\_zm_powerups::watch_for_drop, ::basegame_watch_for_drop );
}

basegame_refresh()
{
    if(isDefined(level.zombie_counter_hud))
    {
        level.zombie_counter_hud.label = &"remaning: ^1";
        notify_label_text();
    }
    if(isDefined(level.zombie_spawned_hud))
    {
        level.zombie_spawned_hud.label = &"spawned: ^1";
        notify_label_text();
    }
    if(isDefined(level.point_based_hud))
    {
        level.point_based_hud set_safe_text( level.point_based_hud.text);
    }
}

// toggles
toggle_remaining()
{
    setting = "hud_remaning";
    new_status = 1 - get_cfg_int(setting);
    level.base_cfg[setting] = new_status;
    write_config(level.base_cfg, level.base_cfg_str);
    if(new_status) level thread basegame_zombie_remaining_hud();
    else level.zombie_counter_hud destroy();
    self refresh_menu();
}

toggle_spawned()
{
    setting = "hud_spawned";
    new_status = 1 - get_cfg_int(setting);
    level.base_cfg[setting] = new_status;
    write_config(level.base_cfg, level.base_cfg_str);
    if(new_status) level thread basegame_zombie_spawned_hud();
    else level.zombie_spawned_hud destroy();
    self refresh_menu();
}

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

pointbased_text()
{
    options = array("^1disabaled", "^3relative", "^3absolute");
    return options[get_cfg_int("hud_points")];
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
    level.point_based_hud = new_tracked_server_font( "hudsmall", 1.4 );
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
            level.point_based_hud set_safe_text( level.point_based_hud.text );
        }
        else if(mode == 2)
        {
            point_req = int( level.score_to_drop + 0.99 );
            point_cur = new_total_score;

            level.point_based_hud.text = point_cur + "/" + point_req;
            level.point_based_hud set_safe_text( level.point_based_hud.text );
        }

        if ( level.zombie_vars["zombie_drop_item"] )
            level.point_based_hud.color = (0.54, 0.17, 0.89);
        else
            level.point_based_hud.color = ( 1, 1, 1 );

        wait 0.05;
    }
}

basegame_zombie_remaining_hud()
{
	level.zombie_counter_hud = new_tracked_server_font("hudsmall", 1.3);
	level.zombie_counter_hud setpoint("CENTER", "CENTER", "CENTER", 185);
	level.zombie_counter_hud.label = &"remaning: ^1";
    notify_label_text();

	while(isDefined(level.zombie_counter_hud))
	{
		level.zombie_counter_hud setvalue(get_round_enemy_array().size + level.zombie_total);
		wait 0.05;
	}
}

basegame_zombie_spawned_hud()
{
	level.zombie_spawned_hud = new_tracked_server_font("hudsmall", 1.3);
	level.zombie_spawned_hud setpoint("CENTER", "CENTER", "CENTER", 200);
	level.zombie_spawned_hud.label = &"spawned: ^1";
    notify_label_text();

	while(isDefined(level.zombie_spawned_hud))
	{
		level.zombie_spawned_hud setvalue(get_round_enemy_array().size);
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
	wait 0.15 * self.characterindex;
	while(true)
	{
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
		if(!self maps\mp\zombies\_zm::in_life_brush() && self maps\mp\zombies\_zm::in_kill_brush() || !self maps\mp\zombies\_zm::in_enabled_playable_area())
		{
			if(!isdefined(level.player_out_of_playable_area_monitor_callback) || self [[level.player_out_of_playable_area_monitor_callback]]())
			{
                if(get_cfg_int("oopa_hud") && flag("initial_blackscreen_passed")) self iprintln(game_time_string() + " | OOPA ^9proc");
				self maps\mp\zombies\_zm_stats::increment_map_cheat_stat("cheat_out_of_playable");
				self maps\mp\zombies\_zm_stats::increment_client_stat("cheat_out_of_playable", 0);
				self maps\mp\zombies\_zm_stats::increment_client_stat("cheat_total", 0);
				if(get_cfg_int("oopa") == 1) self playlocalsound(level.zmb_laugh_alias);
				wait 0.5;
                if(get_cfg_int("oopa_hud") && flag("initial_blackscreen_passed")) self iprintln(game_time_string() + " | OOPA ^1kill");
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
            if(get_cfg_int("oopa_hud") && flag("initial_blackscreen_passed")) self iprintln(game_time_string() + " | OOPA ^3tick");
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

basegame_zombie_tracking_init()
{
    level.zombie_respawned_health = [];
    level.deleted_zombies = -1;
	level.inview_zombies = -1;

    if ( !isdefined( level.zombie_tracking_dist ) )
        level.zombie_tracking_dist = 1500;

    if ( !isdefined( level.zombie_tracking_high ) )
        level.zombie_tracking_high = 600;

    if ( !isdefined( level.zombie_tracking_wait ) )
        level.zombie_tracking_wait = 10;

    while ( true )
    {
        level.deleted_zombies = 0;
		level.inview_zombies = 0;
        zombies = get_round_enemy_array();

        if ( !isdefined( zombies ) || isdefined( level.ignore_distance_tracking ) && level.ignore_distance_tracking )
        {
            wait( level.zombie_tracking_wait );
            continue;
        }
        else
        {
            for ( i = 0; i < zombies.size; i++ )
            {
                if ( isdefined( zombies[i] ) && !( isdefined( zombies[i].ignore_distance_tracking ) && zombies[i].ignore_distance_tracking ) )
                    zombies[i] thread  maps\mp\zm_tomb_distance_tracking::delete_zombie_noone_looking( level.zombie_tracking_dist, level.zombie_tracking_high );
            }

			print_despawns(zombies.size);
        }

        wait( level.zombie_tracking_wait );
    }
}

basegame_delete_zombie_noone_looking( how_close, how_high )
{
    self endon( "death" );

    if ( !isdefined( how_close ) )
        how_close = 1500;

    if ( !isdefined( how_high ) )
        how_high = 600;

    distance_squared_check = how_close * how_close;
    too_far_dist = distance_squared_check * 3;

    if ( isdefined( level.zombie_tracking_too_far_dist ) )
        too_far_dist = level.zombie_tracking_too_far_dist * level.zombie_tracking_too_far_dist;

    self.inview = 0;
    self.player_close = 0;
    n_distance_squared = 0;
    n_height_difference = 0;
    players = get_players();

    for ( i = 0; i < players.size; i++ )
    {
        if ( players[i].sessionstate == "spectator" )
            continue;

        if ( isdefined( level.only_track_targeted_players ) )
        {
            if ( !isdefined( self.favoriteenemy ) || self.favoriteenemy != players[i] )
                continue;
        }

        can_be_seen = self player_can_see_me( players[i] );

        if ( can_be_seen && distancesquared( self.origin, players[i].origin ) < too_far_dist )
            self.inview++;

        n_modifier = 1.0;

        if ( isdefined( players[i].b_in_tunnels ) && players[i].b_in_tunnels )
            n_modifier = 2.25;

        n_distance_squared = distancesquared( self.origin, players[i].origin );
        n_height_difference = abs( self.origin[2] - players[i].origin[2] );

        if ( n_distance_squared < distance_squared_check * n_modifier && n_height_difference < how_high )
            self.player_close++;
    }

    if ( self.inview == 0 && self.player_close == 0 )
    {
		level.deleted_zombies++;
        if ( !isdefined( self.animname ) || self.animname != "zombie" && self.animname != "mechz_zombie" )
            return;

        if ( isdefined( self.electrified ) && self.electrified == 1 )
            return;

        if ( isdefined( self.in_the_ground ) && self.in_the_ground == 1 )
            return;

        zombies = getaiarray( "axis" );

        if ( ( !isdefined( self.damagemod ) || self.damagemod == "MOD_UNKNOWN" ) && self.health < self.maxhealth )
        {
            if ( !( isdefined( self.exclude_distance_cleanup_adding_to_total ) && self.exclude_distance_cleanup_adding_to_total ) && !( isdefined( self.isscreecher ) && self.isscreecher ) )
            {
                level.zombie_total++;
                level.zombie_respawned_health[level.zombie_respawned_health.size] = self.health;
            }
        }
        else if ( zombies.size + level.zombie_total > 24 || zombies.size + level.zombie_total <= 24 && self.health >= self.maxhealth )
        {
            if ( !( isdefined( self.exclude_distance_cleanup_adding_to_total ) && self.exclude_distance_cleanup_adding_to_total ) && !( isdefined( self.isscreecher ) && self.isscreecher ) )
            {
                level.zombie_total++;

                if ( self.health < level.zombie_health )
                    level.zombie_respawned_health[level.zombie_respawned_health.size] = self.health;
            }
        }

        self maps\mp\zombies\_zm_spawner::reset_attack_spot();
        self notify( "zombie_delete" );

        if ( isdefined( self.is_mechz ) && self.is_mechz )
        {
            self notify( "mechz_cleanup" );
            level.mechz_left_to_spawn++;
            wait_network_frame();
            level notify( "spawn_mechz" );
        }

        self delete();
        recalc_zombie_array();
    }
	else if( self.inview == 1 && self.player_close == 0)
    {
		level.inview_zombies++;
	}
}

print_despawns(zombies)
{
    if ( get_cfg_int( "despawns" ) && flag("initial_blackscreen_passed"))
    {
        a = getplayers();

        foreach ( player in a )
            player iprintln( game_time_string() + " | Distance tracking | ^1" + level.deleted_zombies + "^7/^2" + zombies + "^7 despawns | ^3" + level.inview_zombies + "^7 inview");
    }
}

say_command_monitor()
{
	while(true)
	{
		level waittill("say", message, player);
		switch(message)
		{
			case "max":
				player give_drop("full_ammo");
				break;

			case "insta":
				player give_drop("insta_kill");
				break;

			case "blood":
				player give_drop("zombie_blood");
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
            case "parts":
                player thread get_all_parts();
                break;
		}
	}
}
