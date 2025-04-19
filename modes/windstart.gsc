#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\gametypes_zm\_hud_message;

#include scripts\zm\origins_menu\menu_utility;
#include scripts\zm\origins_menu\menu_base;

windstart_initialize()
{
    replacefunc( maps\mp\zombies\_zm_ai_mechz_ffotd::mechz_round_tracker_loop_start, ::windstart_mechz_round_tracker_loop_start);
    replacefunc( maps\mp\zm_tomb_capture_zones::get_recapture_zone, ::windstart_get_recapture_zone);
	replacefunc( maps\mp\zm_tomb_capture_zones::recapture_round_tracker, ::windstart_recapture_round_tracker);
    replaceFunc( maps\mp\zm_tomb_giant_robot::robot_cycling, ::windstart_robot_cycling);
	replacefunc( maps\mp\zm_tomb_quest_crypt::chamber_discs_randomize, ::windstart_chamber_discs_randomize);
	replacefunc( maps\mp\zm_tomb_utility::zone_capture_powerup, ::windstart_zone_capture_powerup);
	replacefunc( maps\mp\zm_tomb_dig::dig_spots_respawn, ::windstart_dig_spots_respawn);
	replacefunc( maps\mp\zm_tomb_dig::waittill_dug, ::windstart_waittill_dug);
	replacefunc( maps\mp\zombies\_zm_craftables::generate_zombie_craftable_piece, ::windstart_generate_zombie_craftable_piece);
	replacefunc( maps\mp\zm_tomb_craftables::randomize_craftable_spawns, ::windstart_randomize_craftable_spawns);
	replacefunc( maps\mp\zm_tomb_tank::activate_tank_wait_with_no_cost, ::windstart_activate_tank_wait_with_no_cost);

	replacefunc( maps\mp\zm_tomb_quest_crypt::init_crypt_gems, ::windstart_init_crypt_gems);

	//removedetour(maps\mp\zombies\_zm::player_out_of_playable_area_monitor);
	//removedetour(maps\mp\zm_tomb_distance_tracking::delete_zombie_noone_looking);
	//removedetour(maps\mp\zm_tomb_distance_tracking::zombie_tracking_init);

	replacefunc( maps\mp\zombies\_zm::player_out_of_playable_area_monitor, ::windstart_player_out_of_playable_area_monitor);
	replacefunc( maps\mp\zm_tomb_distance_tracking::delete_zombie_noone_looking, ::windstart_delete_zombie_noone_looking);
	replacefunc( maps\mp\zm_tomb_distance_tracking::zombie_tracking_init, ::windstart_zombie_tracking_init );

    flag_init("start_robots");
    flag_clear("start_robots");

    level.delay_robot = true;
    level.custom_cycles = 17;
	level.n_disc_scrambles = 0;
	level.cycle_string = "awating robot cycle";

    level.robot[0] = "random";
	level.robot[1] = "odin";
	level.robot[2] = "thor";
	level.robot[3] = "freya";
	level.robot["random"] = 0;
	level.robot["odin"] = 1;
	level.robot["thor"] = 2;
	level.robot["freya"] = 3;

	level.foot[0] = "random";
	level.foot[1] = "left";
	level.foot[2] = "right";
	level.foot["random"] = 0;
	level.foot["left"] = 1;
	level.foot["right"] = 2;

    level.start_timing["time_sting"] = "";
    level.start_timing["ms"] = 0;
    level.start_timing["cycle"] = 0;

    level.timing_strings = array("13:00", "13:05", "13:10", "13:15", "13:20", "13:25", "13:30", "13:35", "13:40", "13:45", "13:50", "13:55", "14:00", "14:05", "14:10", "14:15", "14:20", "14:25", "14:30", "14:35", "14:40", "14:45");
    for(i = 0; i < level.timing_strings.size; i++ )
        level.timing_option_wait[i] = (level.timing_strings.size - (1 + i) ) * 5 + 4.95;

    set_dvar_if_unset("windstart_dt_start", 0);
    set_dvar_if_unset("windstart_trench_path", 0); //0 random, 1 gen2, 2 gen3
    set_dvar_if_unset("windstart_kill_plane", 1);
    set_dvar_if_unset("windstart_plane_part", 1);
    set_dvar_if_unset("windstart_craft_time", 4);
	set_dvar_if_unset("windstart_last_disc", 0);
	set_dvar_if_unset("windstart_maxis_body", 0);
	set_dvar_if_unset("windstart_maxis_engine", 0);
	set_dvar_if_unset("windstart_headshot_reward", 0);
	set_dvar_if_unset("windstart_skip_intro", 0);
	set_dvar_if_unset("windstart_purple_disc", 1);
	set_dvar_if_unset("windstart_early_gram", 1);

    set_dvar_if_unset("windstart_panzer_2", 0);
	set_dvar_if_unset("windstart_panzer_3", 0);

    set_dvar_if_unset("windstart_relay_start", 1);
	set_dvar_if_unset("windstart_relay_tank", 0);
    set_dvar_if_unset("windstart_relay_air", 0);
    set_dvar_if_unset("windstart_relay_elec", 1);
	set_dvar_if_unset("windstart_relay_ruins", 1);
    set_dvar_if_unset("windstart_relay_ice", 0);
    set_dvar_if_unset("windstart_relay_village", 1);

    set_dvar_if_unset("windstart_temps_2_round", 0);
    set_dvar_if_unset("windstart_temps_2_gen_1", 0);
    set_dvar_if_unset("windstart_temps_2_gen_6", 0);

	set_dvar_if_unset("windstart_temps_3_round", 0);
	set_dvar_if_unset("windstart_temps_3_gen_1", 0);
    set_dvar_if_unset("windstart_temps_3_gen_6", 0);

	for(i = 1; i < 7; i++)
	{
		set_dvar_if_unset("windstart_temps_2_gen_" + i, 1);
		set_dvar_if_unset("windstart_temps_3_gen_" + i, 1);
	}

    for(cycle = 8; cycle <= level.custom_cycles; cycle++)
	{
		set_dvar_if_unset("windstart_cycle_" + cycle, level.robot["random"]);
		set_dvar_if_unset("windstart_foot_" + cycle, level.foot["random"]);
	}

	set_dvar_if_unset("windstart_disc_3", 0);
	set_dvar_if_unset("windstart_disc_4", 0);

    set_dvar_if_unset("windstart_rain_foot", 0);
    set_dvar_if_unset("windstart_cycle_tracker_ms", 1);
}

windstart_run()
{
    if(getDvarInt("basegame_turbo_restarts")) setDvar("timescale", 10);
    flag_wait("initial_players_connected");
    attaining29 = get_players()[0];
    level thread windstart_open_map(getDvarInt("windstart_trench_path"));
    level thread windstart_tank();
    level thread windstart_relays();
    level thread windstart_portals();
    level thread windstart_crypt();
    level thread windstart_discs();
    level thread windstart_round_increment();
	level thread windstart_wallbuy_outlines();
	level thread windstart_ice_staff_complete();
    attaining29 thread windstart_box_rewards();
    attaining29 thread windstart_perks();
    attaining29 thread windstart_weapons();
    flag_wait("initial_blackscreen_passed");
    flag_set("menu_active");
    setDvar("timescale", 1);
	if(getDvarInt("windstart_cycle_tracker")) level thread windstart_cycle_tracker();
    level thread windstart_generators();
	level thread windstart_split();
	level thread staff_prints();
    attaining29 thread windstart_kill_plane();
    attaining29 thread windstart_shovel();
    attaining29 thread windstart_tablet();
    attaining29 thread windstart_get_parts();
    attaining29 thread windstart_start_teleport();
	attaining29 thread windstart_pointbased_drops();

	flag_wait("start_robots");
	wait 3;
	print("time stting " + level.game_start_time);

	/*
	while(true)
	{
		print(game_time_string());
		wait 1;
	}
	*/
}

staff_prints()
{
	while(true)
	{
		print("#########################################################");
		foreach ( staff in level.a_elemental_staffs )
		{
			print("wepneame: " + staff.weapname);
			print("charges_received: " + staff.charger.charges_received);
			print("charger is_inserted: " + staff.charger.is_inserted);
			print("charger is_charged: " + staff.charger.is_charged);
			print("xxxx");
			print("xxxx");
			print(" ");
		}
		wait 5;
	}
}

windstart_refresh()
{
    if(isDefined(level.cycle_display)) level.cycle_display set_safe_text(level.cycle_string);
	if(isDefined(level.ice_hud)) level.ice_hud set_safe_text(level.ice_time);
	if(isDefined(level.wind_hud)) level.wind_hud set_safe_text(level.wind_time);
	if(isDefined(level.fire_hud)) level.fire_hud set_safe_text(level.fire_time);
	if(isDefined(level.lightning_hud)) level.lightning_hud  set_safe_text(level.lightning_time);
	if(isDefined(level.ice_timer))level.ice_timer set_safe_text(level.ice_timer.time);
}

windstart_toggle_cycle_display()
{
    dvar = "windstart_cycle_tracker";
    new_status = 1 - getDvarInt(dvar);
    setDvar(dvar, new_status);
    if(new_status) level thread windstart_cycle_tracker();
    else level.cycle_display destroy();
    self refresh_menu();
}

windstart_cycle_tracker()
{
    level.cycle_display = createserverfontstring("default", 1.3);
	level.cycle_display setpoint("LEFT", "LEFT", 5, -232);
	level.cycle_display.alpha = 1;
	level.cycle_display set_safe_text(level.cycle_string);
}

windstart_kill_plane()
{
    plane = getentarray( "air_crystal_biplane", "targetname" );
    while(plane.size < 2)
    {
        wait 1;
        plane = getentarray( "air_crystal_biplane", "targetname" );
    }

    plane[0] dodamage( 66666, plane[plane.size].origin, self);
    plane[0] ent_flag_set( "biplane_down" );
    level notify( "biplane_down" );
}

windstart_weapons()
{
    self giveWeapon("mp40_zm");
    self maps\mp\zombies\_zm_weap_claymore::claymore_setup();
    wait 1;
    self switchToWeapon("mp40_zm");
}

windstart_generators()
{
    generators = getstructarray("s_generator", "targetname");
    foreach(gen in generators)
    {
        gen maps\mp\zm_tomb_capture_zones::set_player_controlled_area();
        gen.n_current_progress = 100;
        gen maps\mp\zm_tomb_capture_zones::generator_state_power_up();
        level setclientfield( gen.script_noteworthy, gen.n_current_progress / 100 );
    }

    //Prevent r10 gen start - gen6 skip not done
    while(level.round_number < 10) wait 0.05;
    flag_set("zone_capture_in_progress");
    while(level.round_number < 11) wait 0.05;
    flag_clear("zone_capture_in_progress");
}

windstart_ice_staff_complete()
{
	wait 2;
	a_ceiling_tile_brushes = getentarray( "ice_ceiling_tile", "script_noteworthy" );

	foreach ( tile in a_ceiling_tile_brushes )
    {
        tile maps\mp\zm_tomb_quest_ice::ceiling_tile_flip( 0 );
    }

	wait 0.05;
	flag_set( "ice_puzzle_1_complete" );

	wait 2;
	a_stone_positions = getstructarray( "puzzle_stone_water", "targetname" );
	foreach ( s_stone in a_stone_positions )
	{
		s_stone.e_model delete();
	}
	level.ice_stones_remaining = 0;
	flag_set( "ice_puzzle_2_complete" );


	flag_wait("initial_blackscreen_passed");
	flag_wait( "chamber_entrance_opened" );

	foreach ( staff in level.a_elemental_staffs )
    {
        if ( staff.weapname == "staff_water_zm" )
        {
            staff.charger.is_inserted = 1;
            maps\mp\zm_tomb_craftables::clear_player_staff( staff.weapname );
            staff.charge_trigger trigger_off();

            if ( isdefined( staff.charger.angles ) )
                staff.angles = staff.charger.angles;

            staff moveto( staff.charger.origin, 0.05 );

            staff waittill( "movedone" );

            staff setclientfield( "staff_charger", staff.enum );
			level setclientfield( "quest_state4", 3 );
            staff.charger.full = 0;
            staff show();
            staff playsound( "zmb_squest_charge_place_staff" );
            flag_set( staff.weapname + "_upgrade_unlocked" );
            staff.charger.charges_received = 2;
        }
    }


	piecespawn = maps\mp\zombies\_zm_craftables::get_craftable_piece( "elemental_staff_water", "gem" );
	piecespawn maps\mp\zombies\_zm_craftables::piece_unspawn();

	water = maps\mp\zombies\_zm_craftables::find_craftable_stub("elemental_staff_water");
	water maps\mp\zombies\_zm_craftables::craftablestub_remove();
    thread maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( water);
level setclientfield( "quest_state4", 1 );


	/*
	level setclientfield( "quest_state4", 1 );
	wait 0.1;
	level setclientfield( "quest_state4", 2 );
	wait 0.1;
	wait 0.1;
	//level setclientfield( "quest_state4", 4 );

	flag_set( "staff_water_zm_enabled" );
	flag_wait( "staff_water_zm_upgrade_unlocked" );


	wait 10;
	//flag_wait( "staff_water_zm_upgrade_unlocked" );
	level setclientfield( "quest_state4", 3 );
	wait 1;

	foreach ( staff in level.a_elemental_staffs )
    {
		if(staff.weapname == "staff_water_zm")
		{
			pl_1 = getPlayers()[0];
			maps\mp\zm_tomb_craftables::set_player_staff( "staff_water_zm", pl_1 );
			staff.charge_trigger notify( "trigger", pl_1 );
			staff.charger.is_inserted = 1;


			staff.charger.is_inserted = 1;
			maps\mp\zm_tomb_craftables::clear_player_staff( staff.weapname );
			//staff.trigger maps\mp\zm_tomb_utility::tomb_unitrigger_delete();
			//staff.charge_trigger maps\mp\zm_tomb_utility::tomb_unitrigger_delete();
			staff.charge_trigger trigger_off();
			if ( isdefined( staff.charger.angles ) ) staff.angles = staff.charger.angles;
			staff moveto( staff.charger.origin, 0.05 );
			staff waittill( "movedone" );
			staff setclientfield( "staff_charger", staff.enum );
        	staff.charger.full = 0;
			staff show();
			staff.charger.charges_received = 0;
			staff.trigger trigger_off();

		}
    }


	self.charger.is_inserted
    self.charger.is_charged = 1;
    self setclientfield( "staff_charger", 0 );
    self.charger.full = 1;
    level setclientfield( self.quest_clientfield, 4 );
            level thread spawn_upgraded_staff_triggers( self.enum );
            level.staffs_charged++;



	flag_set( "staff_water_zm_enabled" );
	wait 0.05;
	flag_clear( "staff_water_zm_enabled" );
	wait 1;
	flag_set( "staff_water_zm_enabled" );

	wait 20;
	gems = getentarray( "crypt_gem", "script_noteworthy" );
	foreach ( gem in gems )
	{
		if( gem.targetname == "crypt_gem_ice")
		{
			e_gem_model = maps\mp\zm_tomb_utility::puzzle_orb_chamber_to_crypt( "ice_orb_exit_path", gem );
			e_gem_model setclientfield( "element_glow_fx", gem.script_int );
			e_gem_model playsound( "zmb_squest_crystal_charge" );
			e_gem_model playloopsound( "zmb_squest_crystal_charge_loop", 2 );
			orbmodels = getentarray( gem.str_orb_path, "origin" );
		}

		gem thread run_crypt_gem_pos();
	}
	*/

	/*
	self moveto( v_to_pos, movetime, 0f, 0 );

    self waittill( "movedone" );

	flag_set( complete_flag );
	*/
}

windstart_init_crypt_gems()
{
	disc = getent( "crypt_puzzle_disc_main", "targetname" );
    gems = getentarray( "crypt_gem", "script_noteworthy" );

    foreach ( gem in gems )
    {
		if(gem.targetname == "crypt_gem_ice")
		{
			gem thread windstart_gem_orb();
		}
		else
		{
			gem linkto( disc );
     		gem thread run_crypt_gem_pos();
		}

    }
}

windstart_gem_orb()
{
	s_start = getstruct( "ice_orb_exit_path", "targetname" );
	s_final = getstruct( "ice_orb_plinth_final", "targetname" );

	e_new_gem = spawn( "script_model", s_final.origin );
    e_new_gem setmodel( s_start.model );
    e_new_gem.script_int = self.n_element;
    e_new_gem setclientfield( "element_glow_fx", e_new_gem.script_int );
    //e_gem_model delete();
    e_new_gem playsound( "zmb_squest_crystal_arrive" );
    e_new_gem playloopsound( "zmb_squest_crystal_charge_loop", 0.1 );
    flag_set( "staff_water_zm_upgrade_unlocked" );
}

windstart_pointbased_drops()
{
	level waittill("start_of_round");
	wait 1;
	level.score_to_drop = 33000 + randomint(1000);
	p_score = int(level.score_to_drop / 10) * 10;
	self.score_total = p_score - 1000 - (randomint(200) * 10);
	level.zombie_vars["zombie_powerup_drop_increment"] = 5004.53758257;
	level.zombie_vars["zombie_drop_item"] = 0;
}

windstart_discs()
{
	setting_to_spin[0] = randomintrange(0, 4);
	setting_to_spin[1] = 0;
	setting_to_spin[2] = 1;
	setting_to_spin[3] = 2;
	setting_to_spin[4] = 3;

    flag_wait( "chamber_entrance_opened" );
    wait 1;
	setting = getDvarInt("windstart_last_disc");


    level.n_disc_scrambles = 2;
	discs = getentarray("crypt_puzzle_disc", "script_noteworthy");
    //0 blue | 1 purple | 2 red | 3 yellow |
    discs[1].position = 0;  //bot
    discs[2].position = 0;
    discs[3].position = setting_to_spin[setting];
    discs[4].position = 0;  //top
	maps\mp\zm_tomb_quest_crypt::chamber_discs_move_all_to_position(discs);
}

windstart_perks()
{
    perks = [];
    flip = cointoss();

    perks[perks.size] = bool_compare_string(flip, "specialty_longersprint", "specialty_armorvest");
    if(getDvarInt("windstart_dt_start")) perks[perks.size] = "specialty_rof";
    perks[perks.size] = bool_compare_string(!flip, "specialty_longersprint", "specialty_armorvest");

    for (i = 0; i < perks.size; i++)
    {
        self maps\mp\zombies\_zm_perks::give_perk(perks[i]);
        wait 3;
    }
}

windstart_split()
{
	x_offset = -63;
    y_increment = 16;
	split = 1;

	level.timer["segment"] = createserverfontstring( "default", 1.3 );
	level.timer["segment"] setpoint( "CENTER", "TOP", 0, 0 );
	level.timer["segment"].alpha = 0.9;

	while(level.n_staffs_crafted < 1) wait 0.05;
	level.timer["segment"] settimerup(0);

    flag_set("start_robots");
    val = getDvarInt("windstart_craft_time");
	level thread windstart_timer(x_offset);
    offset = level.timing_option_wait[val];
    level.game_start_time = GetTime();
    level.game_start_time += offset * 1000;
    level.game_start_time -= 889950;

	level.ice_time = "^4ICE ^7" + game_time_string();
	level.ice_hud = createserverfontstring( "default", 1.4 );
	level.ice_hud setpoint( "TOPLEFT", "TOPLEFT", x_offset, 75 + (split * y_increment) );
	level.ice_hud.hidewheninmenu = 0;
    level.ice_hud set_safe_text(level.ice_time);
	split++;

	while(level.n_staffs_crafted < 2) wait 0.05;
	level.timer["segment"] settimerup(0);

	level.wind_time = "^3WIND ^7" + game_time_string();
	level.wind_hud = createserverfontstring( "default", 1.4 );
	level.wind_hud setpoint( "TOPLEFT", "TOPLEFT", x_offset, 75 + (split * y_increment) );
	level.wind_hud.hidewheninmenu = 0;
    level.wind_hud set_safe_text(level.wind_time);
	split++;

	while(level.n_staffs_crafted < 3) wait 0.05;
	level.timer["segment"] settimerup(0);

	level.fire_time = "^1FIRE ^7" + game_time_string();
	level.fire_hud = createserverfontstring( "default", 1.4 );
	level.fire_hud setpoint( "TOPLEFT", "TOPLEFT", x_offset, 75 + (split * y_increment) );
	level.fire_hud.hidewheninmenu = 0;
    level.fire_hud set_safe_text(level.fire_time);
	split++;

	while(level.n_staffs_crafted < 4) wait 0.05;
	level.timer["segment"] settimerup(0);

	level.lightning_time = "^6LIGHTNING ^7" + game_time_string();
	level.lightning_hud = createserverfontstring( "default", 1.4 );
	level.lightning_hud setpoint( "TOPLEFT", "TOPLEFT", x_offset, 75 + (split * y_increment) );
	level.lightning_hud.hidewheninmenu = 0;
    level.lightning_hud set_safe_text(level.lightning_time);
	split++;

	level.timer["segment"].alpha = 0;
	flag_wait("fire_link_enabled");
	level.timer["segment"].alpha = 1;
	level.timer["segment"] settimerup(0);
}

windstart_timer(x_offset)
{
	level.ice_timer = createserverfontstring( "default", 1.4 );
	level.ice_timer setpoint( "TOPLEFT", "TOPLEFT", x_offset + 18, 75);
	level.ice_ice_timerhud.hidewheninmenu = 0;

	while(true)
	{
		level.ice_timer.time = game_time_string();
		level.ice_timer set_safe_text(level.ice_timer.time);
		wait 0.05;
	}
}

windstart_start_teleport()
{

    oopa_status = getDvarInt("basegame_oopa");
    setDvar("basegame_oopa", 0);
	self.ignoreme = 1;

    if(getDvarInt("windstart_skip_intro") || true )
	{
		self freezecontrols( 1 );
    	setDvar("timescale", 10);
	}

	//wind chamber TP
	self setorigin((11258, -8659, -407));
	wait 5;
	self freezecontrols( 1 );

    flag_wait( "chamber_entrance_opened" );
	wait 15;
	setDvar("timescale", 1);
    setDvar("basegame_oopa", oopa_status);


	self.score = 6500;
	self maps\mp\zombies\_zm_perks::give_perk("specialty_additionalprimaryweapon");

	wait 0.25;
	self.ignoreme = 0;
    self freezecontrols( 0 );
	self.kills = 205 + randomint( 26 );
}

windstart_wallbuy_outlines()
{
    p1 = getPlayers()[0];
	goat = randomint(100) < 5;

    for( i = 0; i < level._spawned_wallbuys.size; i++)
    {
		wep = level._spawned_wallbuys[i].zombie_weapon_upgrade;
        if(wep == "mp40_zm" || wep == "claymore_zm")
            level._spawned_wallbuys[i].trigger_stub maps\mp\zombies\_zm_weapons::show_all_weapon_buys( p1, maps\mp\zombies\_zm_weapons::get_weapon_cost( wep ), maps\mp\zombies\_zm_weapons::get_ammo_cost( wep ), 0 );

		if(wep == "beretta93r_zm" && goat)
			level._spawned_wallbuys[i].trigger_stub maps\mp\zombies\_zm_weapons::show_all_weapon_buys( p1, maps\mp\zombies\_zm_weapons::get_weapon_cost( wep ), maps\mp\zombies\_zm_weapons::get_ammo_cost( wep ), 0 );
		if(wep == "ak74u_zm" && !goat && getDvarInt("windstart_trench_path") == 2)
			level._spawned_wallbuys[i].trigger_stub maps\mp\zombies\_zm_weapons::show_all_weapon_buys( p1, maps\mp\zombies\_zm_weapons::get_weapon_cost( wep ), maps\mp\zombies\_zm_weapons::get_ammo_cost( wep ), 0 );
    }

}


windstart_portals()
{
	flag("initial_blackscreen_passed");

	wait 2;

	portal_index["fire"] = 0;		//Fire
	portal_index["ice"] = 1; 		//Ice
	portal_index["wind"] = 2; 		//Wind
	portal_index["lighnting "] = 3; //Purp

	level thread windstart_open_portal( portal_index["ice"], 0);
	wait 10;
	level thread windstart_open_portal( portal_index["wind"], 1);

	level notify( "gramophone_vinyl_air_picked_up" );
	level notify( "gramophone_vinyl_player_picked_up" );
	a_stargate_gramophones = getstructarray( "stargate_gramophone_pos", "targetname" );
	//a_stargate_gramophones[1]

    //level notify( "player_teleported", get_players()[0], 3 ); ---blixt
    //level notify( "player_teleported", get_players()[0], 2 ); ---air
    //level notify( "player_teleported", get_players()[0], 1 ); ---fire
}

windstart_open_portal( index, stay_open = 0)
{
	index_plith_map[0] = 1;	//Fire
	index_plith_map[1] = 4; //Ice
	index_plith_map[2] = 2; //Wind
	index_plith_map[3] = 3; //Purp

	a_stargate_gramophones = getstructarray( "stargate_gramophone_pos", "targetname" );
    stargate_index = index; //0 fire | 1 ice | 2 wind | 3 blixt
    script_num = a_stargate_gramophones[stargate_index].script_int;

	a_stargate_gramophones[stargate_index].gramophone_model = spawn( "script_model", a_stargate_gramophones[stargate_index].origin );
    a_stargate_gramophones[stargate_index].gramophone_model.angles = a_stargate_gramophones[stargate_index].angles;
    a_stargate_gramophones[stargate_index].gramophone_model setmodel( "p6_zm_tm_gramophone" );
	level setclientfield( "piece_record_zm_player", 0 );
	flag_set( "gramophone_placed" );
    maps\mp\zm_tomb_teleporter::stargate_teleport_enable( script_num );
	flag_wait( "teleporter_building_" + script_num );
    flag_waitopen( "teleporter_building_" + script_num );

    if ( isdefined( a_stargate_gramophones[stargate_index].script_flag ) )
        flag_set( a_stargate_gramophones[stargate_index].script_flag );

	level notify( "player_teleported", get_players()[0], index_plith_map[index] ); //Ice plinth raised
	if(!stay_open)
	{
		a_stargate_gramophones[stargate_index].gramophone_model delete();
		a_stargate_gramophones[stargate_index].gramophone_model = undefined;
		flag_clear( "gramophone_placed" );
		level setclientfield( "piece_record_zm_player", 1 );
		maps\mp\zm_tomb_teleporter::stargate_teleport_disable( script_num );
	}
	else
	{
		flag_waitopen("gramophone_placed");
		flag_set( "gramophone_placed" );
		level setclientfield( "piece_record_zm_player", 0 );
	}
}

windstart_crypt()
{
    wait 0.05;
    a_door_main = getentarray( "chamber_entrance", "targetname" );
    array_thread( a_door_main, ::crypt_stairs, "vinyl_master" );
    maps\mp\zm_tomb_main_quest::chamber_blocker();
}

crypt_stairs()
{
	flag("initial_blackscreen_passed");
	trig_position = undefined;
	while(!isDefined(trig_position.trigger))
	{
		wait 1;
		trig_position = getstruct( self.targetname + "_position", "targetname" );
	}

	flag_clear( "gramophone_placed" );
	trig_position.trigger notify( "trigger", getPlayers()[0] );
	self waittill( "movedone" );

	flag_wait( "chamber_entrance_opened" );
	if(getDvarInt("windstart_early_gram"))
	{
		trig_position.gramophone_model delete();
		trig_position.gramophone_model = undefined;
		flag_clear( "gramophone_placed" );
		level setclientfield( "piece_record_zm_player", 1 );
		trig_position.trigger tomb_unitrigger_delete();
		trig_position.trigger = undefined;
	}
	else
	{
		flag_set( "gramophone_placed" );
		level setclientfield( "piece_record_zm_player", 0 );
	}
}

windstart_tablet()
{
    self.sq_one_inch_punch_stage++;
    self.sq_one_inch_punch_tablet_num = level.n_tablets_remaining;
    self setclientfieldtoplayer( "player_tablet_state", 2 );
    //self playsound( "zmb_squest_oiptablet_pickup" );
    self thread maps\mp\zm_tomb_ee_side::sq_one_inch_punch_disconnect_watch();
    self thread maps\mp\zm_tomb_ee_side::sq_one_inch_punch_death_watch();
    m_tablet = getent( "tablet_bunker_" + level.n_tablets_remaining, "targetname" );
    m_tablet delete();
    level.n_tablets_remaining--;

    self setclientfieldtoplayer( "player_tablet_state", 1 );
    self.sq_one_inch_punch_stage = 4;
    self thread maps\mp\zm_tomb_ee_side::tablet_cleanliness_thread();
}

windstart_box_rewards()
{
    index = self.characterindex;
    self thread maps\mp\zombies\_zm_weap_one_inch_punch::one_inch_punch_melee_attack();
    self maps\mp\zombies\_zm_challenges::set_stat("zc_zone_captures", 6);
    self maps\mp\zombies\_zm_challenges::increment_stat( "zc_points_spent", 30000 );
	if(getDvarInt("windstart_headshot_reward"))
	{
		self maps\mp\zombies\_zm_challenges::increment_stat( "zc_headshots" , 115);
		self.headshots = 115;
	}

    wait 10;

    a_boxes = getentarray("foot_box", "script_noteworthy");
	foreach(box in a_boxes)
	{
		//box.n_souls_absorbed = 30;
		//box notify("soul_absorbed");
		e_volume = getent( box.target, "targetname" );
    	e_volume delete();
		box delete();
	}

    wait 7; //Gong end before remove

    level._challenges.s_team.a_stats["zc_boxes_filled"].b_medal_awarded = 1;
    level._challenges.s_team.a_stats["zc_boxes_filled"].a_b_player_rewarded[index] = 1;

    box_stat = maps\mp\zombies\_zm_challenges::get_stat("zc_boxes_filled");
    self setclientfieldtoplayer( box_stat.s_parent.cf_complete, 0 );

	foreach(board in level.a_m_challenge_boards)
    {
        if(board.str_medal_tag == "j_g_medal") board showpart( "j_g_glow" );
    }

    /* EXTRA REWARDS - FIX SOUL BOX?
    level._challenges.s_team.a_stats["zc_boxes_filled"].b_medal_awarded = 1
    level._challenges.a_players[self.characterindex].a_stats

    box_stat.s_parent.b_team = 1;
    box_stat.a_b_player_rewarded[index] = 1;


    player maps\mp\zombies\_zm_challenges::increment_stat( "zc_headshots" ); HEADSHOTS
    */
}

windstart_tank()
{
    a_call_boxes = getentarray( "trig_tank_station_call", "targetname" );
    players = get_players();
    a_call_boxes[1] notify( "trigger", players[0] );

	level waittill( "stp_cd" );
	wait 3;
	level.vh_tank.t_use sethintstring( &"ZM_TOMB_X2AT", 500 );


    //try to change hint string?
}


windstart_open_map( path )
{
    setdvar( "zombie_unlock_all", 1 );
    players = get_players();

    doors = array( (-732, 2240, -64), (-864, 3168, -208), (-224, 2792, -200), (2416, 4336, -264));
    if((path - 1)) 	doors[doors.size] = (384, 3472, -248);
    else     		doors[doors.size] = (1216, 2880, -168);

    zombie_doors = getentarray( "zombie_door", "targetname" );
    for( i = 0; i < zombie_doors.size; i++ )
    {
        foreach( unlock_door in doors)
        {
            if( zombie_doors[i].origin == unlock_door)
                zombie_doors[i] notify( "trigger", players[0] );
        }
        wait 0.05;
    }

    zombie_debris = getentarray( "zombie_debris", "targetname" );
    foreach( debris in zombie_debris)
    {
        debris notify( "trigger", players[0] );
        wait 0.05;
    }

    setdvar( "zombie_unlock_all", 0 );
}

windstart_round_increment()
{
    level waittill("start_of_round");
    set_round = 11;
    level.zombie_total = 0;
    maps\mp\zombies\_zm::ai_calculate_health(set_round - 1);
    level.round_number = (set_round - 1);
    zombies = get_round_enemy_array();
    if (isDefined(zombies))
    {
        for (i = 0; i < zombies.size + 1; i++)
            zombies[i] dodamage(zombies[i].health + 666, zombies[i].origin);
    }

    level waittill("start_of_round");
    level.zombie_total = 0;
    delay = 2;
    for (i = 1; i <= level.round_number; i++) delay *= 0.95;
    level.zombie_vars["zombie_spawn_delay"] = delay;
}

windstart_shovel()
{
    n_player = self getentitynumber() + 1;
    self.dig_vars["has_shovel"] = 1;
    level setclientfield( "shovel_player" + n_player, 1 );

    //delete model?
    /*Shovel grab
    (2612, 4268, -321.75) top spawn
    (2469.25, 5280.25, -370) bottom spawn
    */
}


windstart_get_parts()
{
	//self maps\mp\zombies\_zm_craftables::player_get_craftable_piece("elemental_staff_air", "gem");
	self maps\mp\zombies\_zm_craftables::player_get_craftable_piece("elemental_staff_air", "upper_staff");
	self maps\mp\zombies\_zm_craftables::player_get_craftable_piece("elemental_staff_air", "middle_staff");
	self maps\mp\zombies\_zm_craftables::player_get_craftable_piece("elemental_staff_air", "lower_staff");

    //self maps\mp\zombies\_zm_craftables::player_get_craftable_piece("elemental_staff_water", "gem");
    self maps\mp\zombies\_zm_craftables::player_get_craftable_piece("elemental_staff_water", "upper_staff");
	self maps\mp\zombies\_zm_craftables::player_get_craftable_piece("elemental_staff_water", "middle_staff");
	self maps\mp\zombies\_zm_craftables::player_get_craftable_piece("elemental_staff_water", "lower_staff");

    self maps\mp\zombies\_zm_craftables::player_get_craftable_piece("elemental_staff_fire", "upper_staff");
	if(GetDvarInt("windstart_plane_part"))
    self maps\mp\zombies\_zm_craftables::player_get_craftable_piece("elemental_staff_fire", "middle_staff");
	self maps\mp\zombies\_zm_craftables::player_get_craftable_piece("elemental_staff_fire", "lower_staff");

	self maps\mp\zombies\_zm_craftables::player_get_craftable_piece("elemental_staff_lightning", "upper_staff");
	//self maps\mp\zombies\_zm_craftables::player_get_craftable_piece("elemental_staff_lightning", "middle_staff"); mound part
	//self maps\mp\zombies\_zm_craftables::player_get_craftable_piece("elemental_staff_lightning", "lower_staff"); church part

	self maps\mp\zombies\_zm_craftables::player_get_craftable_piece("gramophone", "vinyl_player");
	self maps\mp\zombies\_zm_craftables::player_get_craftable_piece("gramophone", "vinyl_master");
	self maps\mp\zombies\_zm_craftables::player_get_craftable_piece("gramophone", "vinyl_air");
	self maps\mp\zombies\_zm_craftables::player_get_craftable_piece("gramophone", "vinyl_ice");
	self maps\mp\zombies\_zm_craftables::player_get_craftable_piece("gramophone", "vinyl_fire");
	if(getDvarInt("windstart_purple_disc"))
	self maps\mp\zombies\_zm_craftables::player_get_craftable_piece("gramophone", "vinyl_elec");

	if(!getDvarInt("windstart_maxis_body"))
	self maps\mp\zombies\_zm_craftables::player_get_craftable_piece("equip_dieseldrone_zm", "body"); // body optional - gen5 path?
	if(!getDvarInt("windstart_maxis_engine"))
	self maps\mp\zombies\_zm_craftables::player_get_craftable_piece("equip_dieseldrone_zm", "engine"); // optional - scaffolding
    self maps\mp\zombies\_zm_craftables::player_get_craftable_piece("equip_dieseldrone_zm", "brain");

    //optional
	//self maps\mp\zombies\_zm_craftables::player_get_craftable_piece("tomb_shield_zm", "top");
	//self maps\mp\zombies\_zm_craftables::player_get_craftable_piece("tomb_shield_zm", "door");
	//self maps\mp\zombies\_zm_craftables::player_get_craftable_piece("tomb_shield_zm", "bracket");
}

windstart_plane_part_toggle()
{
    value = 1 - GetDvarInt("windstart_plane_part");
	setDvar("windstart_plane_part", value);
    if(value) setDvar("windstart_kill_plane", 1);
	self scripts\zm\origins_menu\menu_base::refresh_menu();
}

windstart_loc_text( val )
{
    locs = array("random", "floor", "mule");
    return locs[val];
}

windstart_cycle1_toggle()
{
	dvar = "windstart_trench_path";
	switch(GetDvarInt(dvar))
	{
		case 0: setDvar(dvar, 1); break;
		case 1: setDvar(dvar, 2); break;
        case 2:
		default: setDvar(dvar, 0); break;
	}
	self refresh_menu();
}

windstart_cycle1_text( val )
{
    locs = array("random", "gen2", "gen3");
    return locs[val];
}

windstart_relays()
{
    if(getDvarInt("windstart_relay_start"))   level.electric_relays["start"].position = 1;         //3 start
    if(getDvarInt("windstart_relay_tank"))    level.electric_relays["tank_platform"].position = 0; //1 start
    if(getDvarInt("windstart_relay_air"))     level.electric_relays["air"].position = 2;           //0 start
    if(getDvarInt("windstart_relay_elec"))    level.electric_relays["elec"].position = 0;          //1 start
    if(getDvarInt("windstart_relay_ruins"))   level.electric_relays["ruins"].position = 2;         //3 start
    if(getDvarInt("windstart_relay_ice"))     level.electric_relays["ice"].position = 3;           //1 start
    if(getDvarInt("windstart_relay_village")) level.electric_relays["village"].position = 2;       //1 start
    foreach(relay in level.electric_relays)  relay thread maps\mp\zm_tomb_quest_elec::update_relay_rotation();
}

windstart_mechz_round_tracker_loop_start()
{
	if(level.round_number < 13)
	{
		//if r12 panzer and r12 start panzer must spawn
		next = 4 + cointoss();
		val = GetDvarInt("windstart_panzer_2");
		if(val) next = val;
		level.next_mechz_round = 8 + next;
		level thread panzer_3_force_round();
	}
}

panzer_3_force_round()
{
    while(!level.mechz_left_to_spawn) wait 0.05;
	val = GetDvarInt("windstart_panzer_3");
	if(val)
	{
		temp_round = level.next_mechz_round;
		wait 20;
		level.next_mechz_round = temp_round + val;
	}
}

windstart_recapture_round_tracker()
{
	level.n_next_recapture_round = 11;
	level.n_templar_rounds = 1;
	if(getDvarInt("windstart_temps"))

	while(true)
	{
		level waittill("between_round_over");
		if(level.round_number >= level.n_next_recapture_round && !flag("zone_capture_in_progress") && maps\mp\zm_tomb_capture_zones::get_captured_zone_count() >= maps\mp\zm_tomb_capture_zones::get_player_controlled_zone_count_for_recapture())
		{
			level.n_templar_rounds++;
			temp_round = 0;
			if(int_in_range(level.n_templar_rounds, 2, 3))
			{
				dvar = "windstart_temps_" + level.n_templar_rounds + "_round";
				temp_round = GetDvarInt(dvar);
			}
			if(int_in_range(temp_round, 3, 5))
			{
				level.n_next_recapture_round = level.round_number + temp_round;
			}
			else
			{
				level.n_next_recapture_round = level.round_number + randomintrange(3, 6);
			}
			level thread maps\mp\zm_tomb_capture_zones::recapture_round_start();
		}
	}
}

windstart_get_recapture_zone(s_last_recapture_zone)
{
	a_s_player_zones = [];
	foreach ( str_key, s_zone in level.zone_capture.zones )
	{
		if(s_zone ent_flag("player_controlled"))
		{
			a_s_player_zones[str_key] = s_zone;
		}
	}
	s_recapture_zone = undefined;
	if(a_s_player_zones.size)
	{
		if(isDefined(s_last_recapture_zone))
		{
			n_distance_closest = undefined;
			foreach(s_zone in a_s_player_zones)
			{
				n_distance = distancesquared(s_zone.origin, s_last_recapture_zone.origin);
				if(!isDefined(n_distance_closest) || n_distance < n_distance_closest)
				{
					s_recapture_zone = s_zone;
					n_distance_closest = n_distance;
				}
			}
		}
		else if(level.n_templar_rounds < 4)
		{
			possible_gens = [];
			possible_gens[possible_gens.size] = "generator_start_bunker";
			possible_gens[possible_gens.size] = "generator_tank_trench";
			possible_gens[possible_gens.size] = "generator_mid_trench";
			possible_gens[possible_gens.size] = "generator_nml_right";
			possible_gens[possible_gens.size] = "generator_nml_left";
			possible_gens[possible_gens.size] = "generator_church";
			non_wanted_gens = [];
			for(i = 1; i < 7; i++)
			{
				gen_dvar = "windstart_temps_" + level.n_templar_rounds + "_gen_" + i;
				gen_enabled = GetDvarInt(gen_dvar);
				if(gen_enabled == 0)
				{
					non_wanted_gens[non_wanted_gens.size] = possible_gens[i - 1];
				}
			}
			invalid_gen = 1;
			timeout = 0;
			while(invalid_gen)
			{
				if(timeout == 30)
				{
					s_recapture_zone = random(a_s_player_zones);
					break;
				}
				invalid_gen = 0;
				s_recapture_zone = random(a_s_player_zones);
				foreach(loc in non_wanted_gens)
				{
					if(s_recapture_zone == level.zone_capture.zones[loc])
					{
						invalid_gen = 1;
					}
				}
				timeout++;
			}
		}
		else
		{
			s_recapture_zone = random(a_s_player_zones);
		}
	}
	return s_recapture_zone;
}

windstart_toggle_templar_round(set)
{
	dvar = "windstart_temps_" + set + "_round";
	templar_round = GetDvarInt(dvar);
	switch(templar_round)
	{
		case 0: setDvar(dvar, 3); break;
		case 3: setDvar(dvar, 4); break;
		case 4: setDvar(dvar, 5); break;
		case 5:
		default: setDvar(dvar, 0);break;
	}
	self refresh_menu();
}

windstart_cycle_panzer( num )
{
	panz_dvar = "windstart_panzer_" + num;
	switch(GetDvarInt(panz_dvar))
	{
		case 0: setDvar(panz_dvar, 4); break;
		case 4: setDvar(panz_dvar, 5); break;
        case 5:
		default: setDvar(panz_dvar, 0); break;
	}
	self refresh_menu();
}

windstart_robot_cycling()
{
    level.robot_cycle = 9;
	three_robot_round = 0;
	last_robot = -1;
	//level thread maps\mp\zm_tomb_giant_robot::giant_robot_intro_walk(1);
	//level waittill("giant_robot_intro_complete");

	if(level.delay_robot == true)
	{
        //print("waiting for start");
		flag_wait("start_robots");
	}


    offset = level.timing_option_wait[getDvarInt("windstart_craft_time")];
    //print("wait start " + offset);
    wait offset;

	while(true)
	{
		level.robot_cycle++;
		random_number = -1;
		if( !(level.round_number % 4) && three_robot_round != level.round_number)
		{
			flag_set("three_robot_round");
			if(flag("ee_all_staffs_upgraded")) random_number = 0;
		}

		if(level.robot_cycle <= level.custom_cycles)
		{
			dvar_val = GetDvarInt("windstart_cycle_" + level.robot_cycle);
			if(dvar_val) random_number = dvar_val - 1;
		}

		if(flag("ee_all_staffs_placed") && !flag("ee_mech_zombie_hole_opened"))
		{
			flag_set("three_robot_round");
			random_number = 0;
		}

		if(flag("three_robot_round"))
		{
			level.zombie_ai_limit = 22;
			if(random_number < 0)
			{
				random_number = randomint(3);
			}
			ice_menu_robot_cycle_string(1, 3);
			if(random_number == 2)
			{
				level thread windstart_giant_robot_start_walk(2);
			}
			else
			{
				level thread windstart_giant_robot_start_walk(2, 0);
			}
			wait 5;
			if(random_number == 0)
			{
				level thread windstart_giant_robot_start_walk(0);
			}
			else
			{
				level thread windstart_giant_robot_start_walk(0, 0);
			}
			wait 5;
			if(random_number == 1)
			{
				level thread windstart_giant_robot_start_walk(1);
			}
			else
			{
				level thread windstart_giant_robot_start_walk(1, 0);
			}
			level waittill("giant_robot_walk_cycle_complete");
			level waittill("giant_robot_walk_cycle_complete");
			level waittill("giant_robot_walk_cycle_complete");
			ice_menu_robot_cycle_string(0, 3);
			wait 5;
			level.zombie_ai_limit = 24;
			three_robot_round = level.round_number;
			last_robot = -1;
			flag_clear("three_robot_round");
		}
		else
		{
			if(flag("activate_zone_nml"))
			{
				while(random_number == last_robot || random_number < 0) random_number = randomint(2);
			}
			else
			{
				if(random_number < 0 || random_number > 1 ) random_number = randomint(2);
			}

			last_robot = random_number;
			ice_menu_robot_cycle_string(1, random_number);
			level thread windstart_giant_robot_start_walk(random_number);
			level waittill("giant_robot_walk_cycle_complete");
			ice_menu_robot_cycle_string(0, random_number);
			wait 5;
		}
	}
}

#using_animtree("zm_tomb_giant_robot_hatch");
windstart_giant_robot_start_walk(n_robot_id, b_has_hatch)
{
	if(!isDefined(b_has_hatch))
	{
		b_has_hatch = 1;
	}
	ai = getent("giant_robot_walker_" + n_robot_id, "targetname");
	level.gr_foot_hatch_closed[n_robot_id] = 1;
	ai.b_has_hatch = b_has_hatch;
	ai ent_flag_clear("kill_trigger_active");
	ai ent_flag_clear("robot_head_entered");
	if(isDefined(ai.b_has_hatch) && ai.b_has_hatch)
	{
		m_sole = getent("target_sole_" + n_robot_id, "targetname");
	}
	if(isDefined(m_sole) && isDefined(ai.b_has_hatch) && ai.b_has_hatch)
	{
		m_sole setcandamage(1);
		m_sole.health = 99999;
		m_sole useanimtree( #animtree );
		m_sole unlink();
	}
	wait 10;
	if(isDefined(m_sole))
	{
		foot = cointoss();
		if(flag("ee_all_staffs_crafted"))
		{
			robot_foot = GetDvarInt("windstart_rain_foot");
			if(robot_foot) foot = robot_foot - 1;
		}
		if(foot)
		{
			ai.hatch_foot = "right";
		}
		else
		{
			ai.hatch_foot = "left";
		}
		if(ai.hatch_foot == "left")
		{
			n_sole_origin = ai gettagorigin("TAG_ATTACH_HATCH_LE");
			v_sole_angles = ai gettagangles("TAG_ATTACH_HATCH_LE");
			ai.hatch_foot = "left";
			str_sole_tag = "TAG_ATTACH_HATCH_LE";
			ai attach("veh_t6_dlc_zm_robot_foot_hatch", "TAG_ATTACH_HATCH_RI");
		}
		else if(ai.hatch_foot == "right")
		{
			n_sole_origin = ai gettagorigin("TAG_ATTACH_HATCH_RI");
			v_sole_angles = ai gettagangles("TAG_ATTACH_HATCH_RI");
			ai.hatch_foot = "right";
			str_sole_tag = "TAG_ATTACH_HATCH_RI";
			ai attach("veh_t6_dlc_zm_robot_foot_hatch", "TAG_ATTACH_HATCH_LE");
		}
		m_sole.origin = n_sole_origin;
		m_sole.angles = v_sole_angles;
		wait 0.1;
		m_sole linkto(ai, str_sole_tag,  (0, 0, 0));
		m_sole show();
		ai attach("veh_t6_dlc_zm_robot_foot_hatch_lights", str_sole_tag);
	}
	if(isDefined(ai.b_has_hatch) && !ai.b_has_hatch)
	{
		ai attach("veh_t6_dlc_zm_robot_foot_hatch", "TAG_ATTACH_HATCH_RI");
		ai attach("veh_t6_dlc_zm_robot_foot_hatch", "TAG_ATTACH_HATCH_LE");
	}
	wait 0.05;
	ai thread maps\mp\zm_tomb_giant_robot::giant_robot_think(ai.trig_stomp_kill_right, ai.trig_stomp_kill_left, ai.clip_foot_right, ai.clip_foot_left, m_sole, n_robot_id);
}

ice_menu_robot_cycle_string(starting, robot, decimals = 0)
{
    robots = array("odin", "thor", "freya", "trios");
    level.cycle_string = game_time_string(getDvarInt("windstart_cycle_tracker_ms"));
    level.cycle_string = level.cycle_string + " | cycle " + level.robot_cycle + bool_compare_string(starting, " start", " end");
    level.cycle_string = level.cycle_string + " | " + robots[robot];
    if(isDefined(level.cycle_display))  level.cycle_display set_safe_text(level.cycle_string);
    print(level.cycle_string);
}

windstart_chamber_discs_randomize()
{
	if(level.n_disc_scrambles == 0) return 0;
	scramble = getDvarInt(level.gamemode + "_disc_" + level.n_disc_scrambles);
	discs = getentarray("crypt_puzzle_disc", "script_noteworthy");
	prev_disc_pos = 0;
	for( i = 1; i < 5; i++)
	{
		if(!isdefined(discs[i].target)) continue;
		if(scramble)
		{
			turn = int(scramble / pow( 10, 4 - i )) % 10;
			discs[i].position = (prev_disc_pos + turn) % 4;
		}
		else
		{
			discs[i].position = (prev_disc_pos + randomintrange(1, 3)) % 4;
		}
		prev_disc_pos = discs[i].position;
	}
	maps\mp\zm_tomb_quest_crypt::chamber_discs_move_all_to_position(discs);
}

windstart_randomize_craftable_spawns()
{
	a_randomized_craftables = array("gramophone_vinyl_ice", "gramophone_vinyl_air", "gramophone_vinyl_elec", "gramophone_vinyl_fire", "gramophone_vinyl_master", "gramophone_vinyl_player");
	foreach(str_craftable in a_randomized_craftables)
	{
		s_original_pos = getstruct(str_craftable, "targetname");
		a_alt_locations = getstructarray(str_craftable + "_alt", "targetname");
		n_loc_index = randomintrange(0, a_alt_locations.size + 1);
		if(str_craftable == "gramophone_vinyl_elec" && getDvarInt("windstart_purple_disc") == 0)
			n_loc_index = 2;

		if(n_loc_index == a_alt_locations.size) continue;
		s_original_pos.origin = a_alt_locations[n_loc_index].origin;
		s_original_pos.angles = a_alt_locations[n_loc_index].angles;
	}
}

windstart_dig_spots_respawn( a_dig_spots )
{
	while(!isDefined(level.a_dig_spots)) wait 0.05;
	o_dig_spots = level.a_dig_spots;

    while ( true )
    {
        level waittill( "end_of_round" );

        wait 2;
        a_dig_spots = array_randomize( level.a_dig_spots );
        n_respawned = 0;
        n_respawned_max = 3;

        if ( level.weather_snow > 0 )
            n_respawned_max = 0;
        else if ( level.weather_rain > 0 )
            n_respawned_max = 5;

        if ( level.weather_snow == 0 )
            n_respawned_max += randomint( get_players().size );

		override_dig_spots = array(16, 18, 19, 20);
		if(isDefined(override_dig_spots))
		{
			for ( i = 0; i < override_dig_spots.size; i++ )
			{
				dig_index = override_dig_spots[i];
				if ( isDefined( o_dig_spots[dig_index].dug ) && o_dig_spots[dig_index].dug && n_respawned < n_respawned_max && level.n_dig_spots_cur <= level.n_dig_spots_max )
				{
					o_dig_spots[dig_index].dug = undefined;
					o_dig_spots[dig_index] thread maps\mp\zm_tomb_dig::dig_spot_spawn();
					wait_network_frame();
					n_respawned++;
				}
			}
		}

        for ( i = 0; i < a_dig_spots.size; i++ )
        {
            if ( isDefined( a_dig_spots[i].dug ) && a_dig_spots[i].dug && n_respawned < n_respawned_max && level.n_dig_spots_cur <= level.n_dig_spots_max )
            {
                a_dig_spots[i].dug = undefined;
                a_dig_spots[i] thread maps\mp\zm_tomb_dig::dig_spot_spawn();
                wait_network_frame();
                n_respawned++;
            }
        }

        if ( level.weather_snow > 0 && level.ice_staff_pieces.size > 0 )
        {
            foreach ( s_staff in level.ice_staff_pieces )
            {
                a_staff_spots = [];
                n_active_mounds = 0;

                foreach ( s_dig_spot in level.a_dig_spots )
                {
                    if ( isDefined( s_dig_spot.str_zone ) && issubstr( s_dig_spot.str_zone, s_staff.zone_substr ) )
                    {
                        if ( !( isDefined( s_dig_spot.dug ) && s_dig_spot.dug ) )
                        {
                            n_active_mounds++;
                            continue;
                        }

                        a_staff_spots[a_staff_spots.size] = s_dig_spot;
                    }
                }

                if ( n_active_mounds < 2 && a_staff_spots.size > 0 && level.n_dig_spots_cur <= level.n_dig_spots_max )
                {
                    n_index = randomint( a_staff_spots.size );
                    a_staff_spots[n_index].dug = undefined;
                    a_staff_spots[n_index] thread maps\mp\zm_tomb_dig::dig_spot_spawn();
                    arrayremoveindex( a_staff_spots, n_index );
                    n_active_mounds++;
                    wait_network_frame();
                }
            }
        }
    }
}

windstart_waittill_dug(s_dig_spot)
{
	while(true)
	{
		self waittill("trigger", player);
		if(isDefined(player.dig_vars["has_shovel"]) && player.dig_vars["has_shovel"])
		{
			player playsound("evt_dig");
			s_dig_spot.dug = 1;
			level.n_dig_spots_cur--;
			playfx(level._effect["digging"], self.origin);
			player setclientfieldtoplayer("player_rumble_and_shake", 1);
			player maps\mp\zombies\_zm_stats::increment_client_stat("tomb_dig", 0);
			player maps\mp\zombies\_zm_stats::increment_player_stat("tomb_dig");
			n_good_chance = 50;

			if(player.dig_vars["n_losing_streak"] == 3)
			{
				player.dig_vars["n_losing_streak"] = 0;
				n_good_chance = 100;
			}

			if(player.dig_vars["has_upgraded_shovel"])
			{
				if(!player.dig_vars["has_helmet"])
				{
					if(randomint(100) >= 95)
					{
						player.dig_vars["has_helmet"] = 1;
						n_player = player getentitynumber() + 1;
						level setclientfield("helmet_player" + n_player, 1);
						player playsoundtoplayer("zmb_squest_golden_anything", player);
						player maps\mp\zombies\_zm_stats::increment_client_stat("tomb_golden_hard_hat", 0);
						player maps\mp\zombies\_zm_stats::increment_player_stat("tomb_golden_hard_hat");
						return;
					}
				}
				n_good_chance = 70;
			}
			if(flag("ee_mech_zombie_hole_opened") && !level.dig_n_zombie_bloods_spawned)
			{
				powerup = spawn( "script_model", self.origin );
				powerup endon( "powerup_grabbed" );
				powerup endon( "powerup_timedout" );

				level.dig_n_zombie_bloods_spawned++;
				level.dig_n_powerups_spawned++;
				level.dig_last_prize_rare = 0;
				player maps\mp\zm_tomb_dig::dig_reward_dialog( "dig_powerup" );

				powerup maps\mp\zombies\_zm_powerups::powerup_setup( "zombie_blood" );
				powerup movez( 40, 0.6 );

				powerup waittill( "movedone" );

				powerup thread maps\mp\zombies\_zm_powerups::powerup_timeout();
				powerup thread maps\mp\zombies\_zm_powerups::powerup_wobble();
				powerup thread maps\mp\zombies\_zm_powerups::powerup_grab();
			}
			else if ( player.dig_vars["n_losing_streak"] == 3 )
			{
				player.dig_vars["n_losing_streak"] = 0;
				n_good_chance = 100;
			}
			else if(randomint(100) > n_good_chance)
			{
				if(cointoss())
				{
					player maps\mp\zm_tomb_dig::dig_reward_dialog("dig_grenade");
					self thread maps\mp\zm_tomb_dig::dig_up_grenade(player);
				}
				else
				{
					player maps\mp\zm_tomb_dig::dig_reward_dialog("dig_zombie");
					self thread maps\mp\zm_tomb_dig::dig_up_zombie(player, s_dig_spot);
				}
				player.dig_vars["n_losing_streak"]++;
			}
			else if(cointoss())
			{
				self thread maps\mp\zm_tomb_dig::dig_up_powerup(player);
			}
			else
			{
				player maps\mp\zm_tomb_dig::dig_reward_dialog("dig_gun");
				self thread maps\mp\zm_tomb_dig::dig_up_weapon(player);
			}
			if(!player.dig_vars["has_upgraded_shovel"])
			{
				player.dig_vars["n_spots_dug"]++;
				if(player.dig_vars["n_spots_dug"] >= 30)
				{
					player.dig_vars["has_upgraded_shovel"] = 1;
					player thread maps\mp\zm_tomb_dig::ee_zombie_blood_dig();
					n_player = player getentitynumber() + 1;
					level setclientfield("shovel_player" + n_player, 2);
					player playsoundtoplayer("zmb_squest_golden_anything", player);
					player maps\mp\zombies\_zm_stats::increment_client_stat("tomb_golden_shovel", 0);
					player maps\mp\zombies\_zm_stats::increment_player_stat("tomb_golden_shovel");
				}
			}
			return;
		}
	}
}

windstart_player_out_of_playable_area_monitor()
{
	self notify("stop_player_out_of_playable_area_monitor");
	self endon("stop_player_out_of_playable_area_monitor");
	self endon("disconnect");
	level endon("end_game");
	while(!isdefined(self.characterindex))
	{
		wait 0.05;
	}
	c_wait = 0.15 * self.characterindex + 0.2;
	flag_wait("start_robots");
	w_time = getDvarInt("windstart_craft_time") % 3;
	wait w_time;
	wait c_wait;
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
                if(GetDvarInt("basegame_oopa_hud") && flag("initial_blackscreen_passed")) self iprintln(game_time_string() + " | OOPA ^9proc");
				self maps\mp\zombies\_zm_stats::increment_map_cheat_stat("cheat_out_of_playable");
				self maps\mp\zombies\_zm_stats::increment_client_stat("cheat_out_of_playable", 0);
				self maps\mp\zombies\_zm_stats::increment_client_stat("cheat_total", 0);
				if(GetDvarInt("basegame_oopa") == 1) self playlocalsound(level.zmb_laugh_alias);
				wait 0.5;
                if(GetDvarInt("basegame_oopa_hud") && flag("initial_blackscreen_passed")) self iprintln(game_time_string() + " | OOPA ^1kill");
                if(GetDvarInt("basegame_oopa"))
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
            if(GetDvarInt("basegame_oopa_hud") && flag("initial_blackscreen_passed")) self iprintln(game_time_string() + " | OOPA ^3tick");
        }
		wait maps\mp\zombies\_zm::get_player_out_of_playable_area_monitor_wait_time();
	}
}

windstart_zombie_tracking_init()
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

	flag_wait("start_robots");
	w_time = 3.2 + (getDvarInt("windstart_craft_time") % 2) * 5;
	wait w_time;

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

windstart_delete_zombie_noone_looking( how_close, how_high )
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
    if ( getdvarint( "basegame_despawns" ) && flag("initial_blackscreen_passed"))
    {
        a = getplayers();

        foreach ( player in a )
            player iprintln( game_time_string() + " | Distance tracking | ^1" + level.deleted_zombies + "^7/^2" + zombies + "^7 despawns | ^3" + level.inview_zombies + "^7 inview");
    }
}

windstart_generate_zombie_craftable_piece(craftablename, piecename, modelname, radius, height, drop_offset, hud_icon, onpickup, ondrop, oncrafted, use_spawn_num, tag_name, can_reuse, client_field_value, is_shared, vox_id, b_one_time_vo)
{
	if(!isDefined(is_shared))
	{
		is_shared = 0;
	}
	if(!isDefined(b_one_time_vo))
	{
		b_one_time_vo = 0;
	}
	precachemodel(modelname);
	if(isDefined(hud_icon))
	{
		precacheshader(hud_icon);
	}
	piecestub = spawnstruct();
	craftable_pieces = [];
	piece_alias = "";
	if(!isDefined(piecename))
	{
		piecename = modelname;
	}
	craftable_pieces_structs = getstructarray(craftablename + "_" + piecename, "targetname");
	foreach(index, struct in craftable_pieces_structs)
	{
		craftable_pieces[index] = struct;
		craftable_pieces[index].hasspawned = 0;
	}
	spawns = undefined;
	loc_override = 0;

	if(getDvarInt("windstart_maxis_body") && piecename == "body") loc_override = 1;
	if(getDvarInt("windstart_maxis_engine") && piecename == "engine") loc_override = 2;

	if(loc_override)
	{
		spawns = force_craftable_spawn_location(craftable_pieces, loc_override);
	}
	else
	{
		spawns = craftable_pieces;
	}
	piecestub.spawns = spawns;
	piecestub.craftablename = craftablename;
	piecestub.piecename = piecename;
	piecestub.modelname = modelname;
	piecestub.hud_icon = hud_icon;
	piecestub.radius = radius;
	piecestub.height = height;
	piecestub.tag_name = tag_name;
	piecestub.can_reuse = can_reuse;
	piecestub.drop_offset = drop_offset;
	piecestub.max_instances = 256;
	piecestub.onpickup = onpickup;
	piecestub.ondrop = ondrop;
	piecestub.oncrafted = oncrafted;
	piecestub.use_spawn_num = use_spawn_num;
	piecestub.is_shared = is_shared;
	piecestub.vox_id = vox_id;
	if(isDefined(b_one_time_vo) && b_one_time_vo)
	{
		piecestub.b_one_time_vo = b_one_time_vo;
	}
	if(isDefined(client_field_value))
	{
		if(isDefined(is_shared) && is_shared)
		{
			piecestub.client_field_id = client_field_value;
		}
	}
	else
	{
		piecestub.client_field_state = client_field_value;
	}
	return piecestub;
}

force_craftable_spawn_location(piece, loc_index)
{
	loc = [];
	loc[0] = piece[loc_index];
	return loc;
}

windstart_activate_tank_wait_with_no_cost()
{
	return 0;
}

windstart_zone_capture_powerup()
{
	return 0;
}