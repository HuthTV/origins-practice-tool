#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;

/*##############################################################################
                              Timing probe
##############################################################################*/
// Development tool, separate from the menu build: measures when the vanilla
// zombie despawn check (every map's zombie_tracking_init) and out-of-playable-
// area check (_zm player_out_of_playable_area_monitor) tick, against the run
// clock the T6 EE Timer uses (zero at initial_blackscreen_passed). The menu's
// segment starts line both checks up with these numbers (shared_monitor_delay).
//
// Remove the practice menu entries (zm_tomb\o-prac-menu.gsc, zm_prison\
// m-prac-menu.gsc) while measuring: both replace the same functions. Deploy as
// scripts\zm\timing_probe.gsc (build_single.bat -Tools), start a map in solo,
// play a few rounds, then read Plutonium's console.log for "timing_probe:" lines:
//   intro / spawn / run start   game times (ms) of the black screen, the
//                               player's spawn and the run clock's zero
//   despawn tick / oopa tick    each tick: run time, and that time modulo the
//                               check's period (the phase to compare)
// Both copies are the vanilla code (t6-scripts-main) with only the print added;
// each map's own despawn function is called through getfunction, so this one
// file loads on every map. Maps without a despawn loop of their own are only
// probed for the out-of-playable-area check.

main()
{
	level.timing_probe_map = tolower(getdvar("mapname"));
	file = timing_probe_tracking_file();
	if(isdefined(file))
	{
		init_fn = getfunction(file, "zombie_tracking_init");
		level.timing_probe_delete = getfunction(file, "delete_zombie_noone_looking");
		if(isdefined(init_fn) && isdefined(level.timing_probe_delete))
			replacefunc(init_fn, ::timing_probe_zombie_tracking_init);
		else
			print("timing_probe: " + file + " not found, despawn not probed\n");
	}
	replacefunc(maps\mp\zombies\_zm::player_out_of_playable_area_monitor, ::timing_probe_out_of_playable_area_monitor);
}

init()
{
	print("timing_probe: map " + level.timing_probe_map + "\n");
	level thread timing_probe_marks();
	level thread timing_probe_spawn();
}

// Each map's distance tracking script (vanilla zm_*.gsc threads its
// zombie_tracking_init at load).
timing_probe_tracking_file()
{
	switch(level.timing_probe_map)
	{
		case "zm_tomb":      return "maps/mp/zm_tomb_distance_tracking";
		case "zm_prison":    return "maps/mp/zm_alcatraz_distance_tracking";
		case "zm_highrise":  return "maps/mp/zm_highrise_distance_tracking";
		case "zm_buried":    return "maps/mp/zm_buried_distance_tracking";
		case "zm_transit":   return "maps/mp/zm_transit_distance_tracking";
		default:             return undefined;
	}
}

timing_probe_marks()
{
	// _zm fade_out_intro_screen_zm creates level.introscreen and holds it black.
	while(!isdefined(level.introscreen) || level.introscreen.alpha < 1) wait 0.05;
	print("timing_probe: intro at " + gettime() + "\n");
	flag_wait("initial_blackscreen_passed");
	level.timing_probe_run_start = gettime();
	print("timing_probe: run start at " + level.timing_probe_run_start + "\n");
}

timing_probe_spawn()
{
	level waittill("connected", player);
	player waittill("spawned_player");
	print("timing_probe: spawn at " + gettime() + "\n");
}

// "despawn tick at <game ms>, run 1:23.400, phase 3400 of 10000"
timing_probe_tick(name, period_ms)
{
	now = gettime();
	text = "timing_probe: " + name + " tick at " + now;
	if(isdefined(level.timing_probe_run_start))
	{
		run_ms = now - level.timing_probe_run_start;
		text += ", run " + run_ms + " ms, phase " + run_ms % period_ms + " of " + period_ms;
	}
	print(text + "\n");
}

/*##############################################################################
                              Vanilla copies
##############################################################################*/
// zombie_tracking_init of each map's *_distance_tracking (vanilla), merged.
timing_probe_zombie_tracking_init()
{
	map = level.timing_probe_map;
	level.zombie_respawned_health = [];

	// Each map's defaults.
	dist = 1500; high = 600; period = 10;
	switch(map)
	{
		case "zm_tomb":     dist = 1520; high = 1000; break;
		case "zm_highrise": dist = 1000; high = 500; break;
		case "zm_buried":   dist = 1600; period = 0.4; break;
	}
	if(!isdefined(level.zombie_tracking_dist)) level.zombie_tracking_dist = dist;
	if(!isdefined(level.zombie_tracking_high) && map != "zm_transit") level.zombie_tracking_high = high;
	if(!isdefined(level.zombie_tracking_wait)) level.zombie_tracking_wait = period;

	if(map == "zm_highrise")
	{
		building_trigs = getentarray("zombie_fell_off", "targetname");
		off_building = getfunction("maps/mp/zm_highrise_distance_tracking", "zombies_off_building");
		if(isdefined(building_trigs) && isdefined(off_building)) array_thread(building_trigs, off_building);
		level.distance_tracker_aggressive_distance = 500;
		level.distance_tracker_aggressive_height = 200;
	}

	while(true)
	{
		timing_probe_tick("despawn", int(level.zombie_tracking_wait * 1000));

		if(map == "zm_tomb")
		{
			foreach(player in get_players())
			{
				if(player maps\mp\zombies\_zm_zonemgr::player_in_zone("zone_air_stairs") || player maps\mp\zombies\_zm_zonemgr::player_in_zone("zone_bolt_stairs") || player maps\mp\zombies\_zm_zonemgr::player_in_zone("zone_fire_stairs") || player maps\mp\zombies\_zm_zonemgr::player_in_zone("zone_ice_stairs"))
				{
					player.b_in_tunnels = 1;
					continue;
				}
				player.b_in_tunnels = 0;
			}
		}

		zombies = get_round_enemy_array();
		if(!isdefined(zombies) || isdefined(level.ignore_distance_tracking) && level.ignore_distance_tracking)
		{
			wait(level.zombie_tracking_wait);
			continue;
		}
		for(i = 0; i < zombies.size; i++)
		{
			if(!isdefined(zombies[i]) || isdefined(zombies[i].ignore_distance_tracking) && zombies[i].ignore_distance_tracking) continue;
			if(map == "zm_buried" && !(isdefined(zombies[i].ignoreall) && !zombies[i].ignoreall)) continue;
			if(map == "zm_transit")
				zombies[i] thread [[ level.timing_probe_delete ]](level.zombie_tracking_dist);
			else
				zombies[i] thread [[ level.timing_probe_delete ]](level.zombie_tracking_dist, level.zombie_tracking_high);
		}
		wait(level.zombie_tracking_wait);
	}
}

// _zm player_out_of_playable_area_monitor (vanilla, without its dev blocks).
timing_probe_out_of_playable_area_monitor()
{
	self notify("stop_player_out_of_playable_area_monitor");
	self endon("stop_player_out_of_playable_area_monitor");
	self endon("disconnect");
	level endon("end_game");

	while(!isdefined(self.characterindex))
		wait 0.05;

	print("timing_probe: oopa monitor started at " + gettime() + ", characterindex " + self.characterindex + "\n");
	wait(0.15 * self.characterindex);

	while(true)
	{
		timing_probe_tick("oopa", int(maps\mp\zombies\_zm::get_player_out_of_playable_area_monitor_wait_time() * 1000));

		if(self.sessionstate == "spectator")
		{
			wait(maps\mp\zombies\_zm::get_player_out_of_playable_area_monitor_wait_time());
			continue;
		}
		if(is_true(level.hostmigration_occured))
		{
			wait(maps\mp\zombies\_zm::get_player_out_of_playable_area_monitor_wait_time());
			continue;
		}
		if(!self maps\mp\zombies\_zm::in_life_brush() && (self maps\mp\zombies\_zm::in_kill_brush() || !self maps\mp\zombies\_zm::in_enabled_playable_area()))
		{
			if(!isdefined(level.player_out_of_playable_area_monitor_callback) || self [[ level.player_out_of_playable_area_monitor_callback ]]())
			{
				self maps\mp\zombies\_zm_stats::increment_map_cheat_stat("cheat_out_of_playable");
				self maps\mp\zombies\_zm_stats::increment_client_stat("cheat_out_of_playable", 0);
				self maps\mp\zombies\_zm_stats::increment_client_stat("cheat_total", 0);
				self playlocalsound(level.zmb_laugh_alias);
				wait 0.5;
				if(get_players().size == 1 && flag("solo_game") && (isdefined(self.waiting_to_revive) && self.waiting_to_revive))
					level notify("end_game");
				else
				{
					self disableinvulnerability();
					self.lives = 0;
					self dodamage(self.health + 1000, self.origin);
					self.bleedout_time = 0;
				}
			}
		}
		wait(maps\mp\zombies\_zm::get_player_out_of_playable_area_monitor_wait_time());
	}
}
