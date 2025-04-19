#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\gametypes_zm\_hud_message;
#include maps\mp\zombies\_zm_weap_beacon;

#include scripts\zm\origins_menu\menu_utility;
#include scripts\zm\origins_menu\menu_base;

genprac_initialize()
{
    replacefunc( maps\mp\zm_tomb_capture_zones::recapture_round_start, ::genprac_recapture_round_start);
	replacefunc( maps\mp\zombies\_zm_ai_mechz::mechz_spawning_logic, ::genprac_mechz_spawning_logic);
    replacefunc( maps\mp\zombies\_zm_weap_beacon::player_throw_beacon, ::genprac_player_throw_beacon);
    setDvar("basegame_oopa", 0);
    set_dvar_if_unset("genprac_start_bunker", 0); //gen1
    set_dvar_if_unset("genprac_tank_trench", 1); //gen2
    set_dvar_if_unset("genprac_mid_trench",1); //gen3
    set_dvar_if_unset("genprac_nml_left", 1); //gen4
    set_dvar_if_unset("genprac_nml_right", 1); //gen5
    set_dvar_if_unset("genprac_church", 0); //gen6
    set_dvar_if_unset("genprac_teleport_throw", 0);

}

genprac_run()
{
    level thread genprac_setup_map();
	level thread on_player_connect_gen();

	flag_wait("initial_blackscreen_passed");
	thread open_all_doors();
	thread activate_generators();
}

on_player_connect_gen()
{
	for(;;)
	{
		level waittill("connected", player);
		player thread on_player_spawned_gen();
	}
}

on_player_spawned_gen()
{

	self waittill("spawned_player");
	flag_wait("initial_blackscreen_passed");
    self freezecontrols( 1 );
	a_boxes = getentarray("foot_box", "script_noteworthy");

    foreach(a_box in a_boxes)
    {
		a_box.n_souls_absorbed = 30;
		a_box notify("soul_absorbed", self);

    }

	self.score = 10000;
    self giveWeapon("mp40_zm");
	self switchToWeapon("mp40_zm");
	self maps\mp\zombies\_zm_perks::give_perk("specialty_longersprint");
	self maps\mp\zombies\_zm_perks::give_perk("specialty_armorvest");
	self maps\mp\zombies\_zm_weap_beacon::player_give_beacon();

	self setOrigin( (-173, -20, 320) );
	self thread beacon_ammo();
    self thread beacon_tp();
    level waittill("start_of_round");
    level waittill("start_of_round");
    self freezecontrols( 0 );



    while(true)
    {
        tped = 0;
        while(self fragbuttonpressed())
        {
            if(tped == 0)
            {
                tped = 1;
                self setOrigin( (-173, -20, 320) );
            }
            wait 0.05;
        }
        wait 0.05;
    }
}

reset_all_gens()
{
    setDvar("genprac_start_bunker", 1); //gen1
    setDvar("genprac_tank_trench", 1); //gen2
    setDvar("genprac_mid_trench",1); //gen3
    setDvar("genprac_nml_left", 1); //gen4
    setDvar("genprac_nml_right", 1); //gen5
    setDvar("genprac_church", 1); //gen6
    setDvar("genprac_teleport_throw", 1);
    self refresh_menu();
}

genprac_setup_map()
{
    setDvar("timescale", 10);
	level waittill("start_of_round");
	level.zombie_total = 0;
    maps\mp\zombies\_zm::ai_calculate_health(15);
    level.round_number = 15;
    zombies = get_round_enemy_array();
    if (isDefined(zombies))
    {
        for (i = 0; i < zombies.size + 1; i++)
            zombies[i] dodamage(zombies[i].health + 666, zombies[i].origin);
    }
	flag_clear( "spawn_zombies" );
	level waittill("start_of_round");
	setDvar("timescale", 1);
    flag_set("menu_active");

	wait 1;
	flag_wait("recapture_zombies_cleared");

	while(true)
	{
		maps\mp\zm_tomb_capture_zones::recapture_round_start();
		wait 3;
	}
}

activate_generators() {
    a_s_generator = getstructarray("s_generator", "targetname");

    for (i = 0; i < a_s_generator.size; i++) {
        a_s_generator[i].n_current_progress = 100;
        a_s_generator[i] handle_generator_capture();
    }
}

beacon_tp()
{
    while(true)
    {
        level waittill("beacon_land");
        if(getDvarInt("genprac_teleport_throw"))
        {
            self setOrigin( level.beacon_cord );
        }
    }
}

beacon_ammo()
{
	while ( true )
        {
            self givemaxammo( "beacon_zm" );
            wait 1;
        }
}

genprac_get_recapture_zone( s_last_recapture_zone )
{
    a_s_player_zones = [];

    foreach ( str_key, s_zone in level.zone_capture.zones )
    {
        if ( s_zone ent_flag( "player_controlled" ) )
            a_s_player_zones[str_key] = s_zone;
    }

    s_recapture_zone = undefined;

    if ( a_s_player_zones.size )
    {
        if ( isdefined( s_last_recapture_zone ) )
        {
            n_distance_closest = undefined;

            foreach ( s_zone in a_s_player_zones )
            {
                n_distance = distancesquared( s_zone.origin, s_last_recapture_zone.origin );

                if ( !isdefined( n_distance_closest ) || n_distance < n_distance_closest )
                {
                    s_recapture_zone = s_zone;
                    n_distance_closest = n_distance;
                }
            }
        }
        else
        {
            s_recapture_zone = random( a_s_player_zones );
        }
    }

    active = [];
    generators = array("_start_bunker", "_tank_trench", "_mid_trench", "_nml_left", "_nml_right", "_church");

    foreach( dvar in generators)
    {
        gen_active = getDvarInt("genprac" + dvar);
        if(gen_active) active[active.size] = "generator" + dvar;
    }

    active = array_randomize(active);

    foreach(option in active)
    {
        foreach(gen in a_s_player_zones)
        {
            if(level.zone_capture.zones[option] == gen)
            {
                return gen;
            }
        }
    }

    return random( a_s_player_zones );
}

#using_animtree("zombie_beacon");

genprac_player_throw_beacon( grenade, num_attractors, max_attract_dist, attract_dist_diff )
{
    self endon( "disconnect" );
    self endon( "starting_beacon_watch" );

    if ( isdefined( grenade ) )
    {
        grenade endon( "death" );

        if ( self maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
        {
            if ( isdefined( grenade.damagearea ) )
                grenade.damagearea delete();

            grenade delete();
            return;
        }

        grenade hide();
        model = spawn( "script_model", grenade.origin );
        model endon( "weapon_beacon_timeout" );
        model setmodel( "t6_wpn_zmb_homing_beacon_world" );
        model useanimtree( #animtree );
        model linkto( grenade );
        model.angles = grenade.angles;
        model thread beacon_cleanup( grenade );
        model.owner = self;
        clone = undefined;

        if ( isdefined( level.beacon_dual_view ) && level.beacon_dual_view )
        {
            model setvisibletoallexceptteam( level.zombie_team );
            clone = maps\mp\zombies\_zm_clone::spawn_player_clone( self, vectorscale( ( 0, 0, -1 ), 999.0 ), level.beacon_clone_weapon, undefined );
            model.simulacrum = clone;
            clone maps\mp\zombies\_zm_clone::clone_animate( "idle" );
            clone thread clone_player_angles( self );
            clone notsolid();
            clone ghost();
        }

        grenade thread watch_for_dud( model, clone );
        info = spawnstruct();
        info.sound_attractors = [];
        grenade thread monitor_zombie_groans( info );

        grenade waittill( "stationary" );

        if ( isdefined( level.grenade_planted ) )
            self thread [[ level.grenade_planted ]]( grenade, model );

        if ( isdefined( grenade ) )
        {
            if ( isdefined( model ) )
            {
                model thread weapon_beacon_anims();

                if ( !( isdefined( grenade.backlinked ) && grenade.backlinked ) )
                {
                    model unlink();
                    model.origin = grenade.origin;
                    model.angles = grenade.angles;
                }
            }

            if ( isdefined( clone ) )
            {
                clone forceteleport( grenade.origin, grenade.angles );
                clone thread hide_owner( self );
                grenade thread proximity_detonate( self );
                clone show();
                clone setinvisibletoall();
                clone setvisibletoteam( level.zombie_team );
            }

            grenade resetmissiledetonationtime();
            model setclientfield( "play_beacon_fx", 1 );
            valid_poi = check_point_in_enabled_zone( grenade.origin, undefined, undefined );

            if ( isdefined( level.check_valid_poi ) )
                valid_poi = grenade [[ level.check_valid_poi ]]( valid_poi );

            if ( valid_poi )
            {
                grenade create_zombie_point_of_interest( max_attract_dist, num_attractors, 10000 );
                grenade.attract_to_origin = 1;
                grenade thread create_zombie_point_of_interest_attractor_positions( 4, attract_dist_diff );
                grenade thread wait_for_attractor_positions_complete();
                grenade thread do_beacon_sound( model, info );
                model thread wait_and_explode( grenade );
                model.time_thrown = gettime();

                while ( isdefined( level.weapon_beacon_busy ) && level.weapon_beacon_busy )
                {
                    wait 0.1;
                    continue;
                }

                if ( flag( "three_robot_round" ) && flag( "fire_link_enabled" ) )
                    model thread start_artillery_launch_ee( grenade );
                else
                    model thread start_artillery_launch_normal( grenade );

                level.beacons[level.beacons.size] = grenade;
                level.beacon_cord = grenade.origin;
                level notify( "beacon_land" );
            }
            else
            {
                grenade.script_noteworthy = undefined;
                level thread grenade_stolen_by_sam( grenade, model, clone );
            }
        }
        else
        {
            grenade.script_noteworthy = undefined;
            level thread grenade_stolen_by_sam( grenade, model, clone );
        }
    }
}

genprac_recapture_round_start()
{
    flag_set( "recapture_event_in_progress" );
    flag_clear( "recapture_zombies_cleared" );
    flag_clear( "generator_under_attack" );
    level.recapture_zombies_killed = 0;
    b_is_first_generator_attack = 1;
    s_recapture_target_zone = undefined;
    capture_event_handle_ai_limit();
    recapture_round_audio_starts();

    while ( !flag( "recapture_zombies_cleared" ) && get_captured_zone_count() > 0 )
    {
        s_recapture_target_zone = genprac_get_recapture_zone( s_recapture_target_zone );
        level.zone_capture.recapture_target = s_recapture_target_zone.script_noteworthy;
        s_recapture_target_zone maps\mp\zm_tomb_capture_zones_ffotd::recapture_event_start();

        if ( b_is_first_generator_attack )
            s_recapture_target_zone thread monitor_recapture_zombies();

        set_recapture_zombie_attack_target( s_recapture_target_zone );
        s_recapture_target_zone thread generator_under_attack_warnings();
        s_recapture_target_zone ent_flag_set( "current_recapture_target_zone" );
        s_recapture_target_zone thread hide_zone_objective_while_recapture_group_runs_to_next_generator( b_is_first_generator_attack );
        s_recapture_target_zone activate_capture_zone( b_is_first_generator_attack );
        s_recapture_target_zone ent_flag_clear( "attacked_by_recapture_zombies" );
        s_recapture_target_zone ent_flag_clear( "current_recapture_target_zone" );

        if ( b_is_first_generator_attack && !s_recapture_target_zone ent_flag( "player_controlled" ) )
            delay_thread( 3, ::broadcast_vo_category_to_team, "recapture_started" );

        b_is_first_generator_attack = 0;
        s_recapture_target_zone maps\mp\zm_tomb_capture_zones_ffotd::recapture_event_end();
        wait 0.05;
    }

    if ( s_recapture_target_zone.n_current_progress == 0 || s_recapture_target_zone.n_current_progress == 100 )
        s_recapture_target_zone handle_generator_capture();

    capture_event_handle_ai_limit();
    kill_all_recapture_zombies();
    recapture_round_audio_ends();
    flag_clear( "recapture_event_in_progress" );
    flag_clear( "generator_under_attack" );
}

genprac_mechz_spawning_logic()
{
	return 0;
}