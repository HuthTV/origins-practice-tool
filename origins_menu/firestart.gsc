#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;

#include scripts\zm\practice_core\menu_utility;
#include scripts\zm\origins_menu\segmentutil;
#include scripts\zm\origins_menu\puzzlerng;
#include scripts\zm\origins_menu\staffutil;
#inline scripts\zm\origins_menu\oprac;

/*##############################################################################
                              Firestart
##############################################################################*/
// Ice and Wind completed and placed, Ice with "Ice prefills" souls (0 by default)
// and Wind with none, Gen4 relay solved; the player starts on round 12 with 1
// zombie left, carrying the Fire crystal, with Fire uncrafted and the gramophone
// in hand (Craft) or at the Wind tunnel (Exit).

// Start spots (origin, view angles). Craft: excavation floor, facing the Fire
// staff. Exit: Firestart opens the Wind portal, so the Wind Crazy Place exit.
#define FIRE_CRAFT_ORIGIN  (118.633, 163.427, -751.875)
#define FIRE_CRAFT_ANGLES  (15.5005, 49.2187, 0)
#define FIRE_EXIT_ORIGIN   (11234, -8687.25, -407.875)
#define FIRE_EXIT_ANGLES   (0.0976524, 302.888, 0)
#define FIRE_ICE_SOULS_MAX 10   // "Ice prefills": souls already in the placed Ice staff.

firestart_initialize()
{
    // Craft time presets: 19:50 to 21:50, every 5 seconds, 21:25 by default.
    // Custom Craft: 19 to 27 minutes (Windstart + 3).
    shared_craft_time_setup("19:50", "21:50", 5, "21:25", 19, 27);
    puzzle_rng_install();
    mode_cfg_load("firestart", firestart_default_cfg());
    shared_segment_install(firestart_segment());
    shared_held_start_install();
}

firestart_run()
{
    level shared_run_segment(level.segment);
}

firestart_segment()
{
    segment = shared_segment();
    segment.split = SPLIT_FIRE;
    // Round 12 with 1 zombie left (user, 2026-10-20). shared_set_round counts
    // anything planned for round 12 as done: a 4 rounder Panzer 2 never comes,
    // and Panzer 3 (its setting, or random) counts from 12: 16 or 17. A 5
    // rounder Panzer 2 comes on 13.
    segment.round = 12;
    segment.round_zombies = 1;
    segment.tank_trips = 1; // One setup trip (church to bunkers), not two (user, 2026-10-20).
    segment.staffs = array(ICE, WIND);
    segment.gems = array(ICE, FIRE, WIND);
    segment.spots = shared_start_spots(FIRE_CRAFT_ORIGIN, FIRE_CRAFT_ANGLES, FIRE_EXIT_ORIGIN, FIRE_EXIT_ANGLES);
    segment.use_exit = get_cfg_int("fire_spawn") == 1;
    segment.solved_relays = array("relay_air"); // The route has the Gen4 Lightning relay solved from here on.
    segment.setup = ::firestart_setup;

    // TEMP TEST (user, 2026-10-29): Firestart is the Fire torch test until this
    // block, firestart_torch_test and its two helpers are removed. No setup,
    // straight to the church with the fire staff and the torch puzzle up.
    segment.use_exit = true;
    segment.start = ::firestart_torch_test;
    segment.perks = array(); // The perk threads give a perk every 3 s; none needed.
    return segment;
}

// TEMP TEST, remove with the block in firestart_segment (user, 2026-10-29): quick
// tests of the Fire torch settings. The player is held at the Exit spot from the
// spawn (shared_hold_at_start), then stripped of guns, so the staff is not taken
// back by the weapon limit, given the fire staff and moved into the church. The
// sacrifice puzzle is marked done, which brings up the torch puzzle and shows the
// four symbols. Setup does not run and no zombies spawn.
firestart_torch_test()
{
    iprintln("^3Fire Torch Test: giving the fire staff");
    // The starting loadout lands in the first moments; strip it after.
    wait 0.5;
    foreach(weapon in self getweaponslistprimaries())
        self takeWeapon(weapon);
    self firestart_give_fire_staff();
    self thread firestart_keep_fire_staff();

    // The church: the middle of the torches, down to the floor.
    torches = getstructarray("church_torch_target", "script_noteworthy");
    centre = (0, 0, 0);
    foreach(torch in torches)
        centre += torch.origin;
    centre = centre / torches.size;
    floor = bullettrace(centre + (0, 0, 100), centre - (0, 0, 600), false, self)["position"];
    self setorigin(floor + (0, 0, 8));
    iprintln("^3Fire Torch Test: church at " + int(floor[0]) + " " + int(floor[1]) + " " + int(floor[2]));
    flag_set("fire_puzzle_1_complete");

    // Normal speed for 500 ms before the player is released.
    setDvar("timescale", 1);
    wait 0.5;
    flag_set("segment_ready");
    self freezecontrols(0);
}

firestart_give_fire_staff()
{
    self giveWeapon("staff_fire_zm");
    self switchToWeapon("staff_fire_zm");
}

// Something in the start (loadout threads) may take the staff back in the first
// seconds; gives it again and says so, for 15 s.
firestart_keep_fire_staff()
{
    self endon("disconnect");
    start = gettime();
    while(gettime() - start < 15000)
    {
        wait 0.25;
        if(self hasweapon("staff_fire_zm")) continue;
        iprintln("^1Fire Torch Test: the staff was taken, giving it again");
        foreach(weapon in self getweaponslistprimaries())
            self takeWeapon(weapon);
        self firestart_give_fire_staff();
    }
}

firestart_setup()
{
    self shared_staff_setup_start();
    souls = get_cfg_int("ice_souls");
    if(souls > FIRE_ICE_SOULS_MAX) souls = FIRE_ICE_SOULS_MAX;
    self shared_complete_staff(ICE, souls);
    self shared_complete_staff(WIND, 0);
    self shared_get_staff_pieces(FIRE);
    self shared_open_portals(WIND, level.segment.use_exit);
    // Craft start: the gramophone comes back to the excavation in hand; the
    // Exit start leaves it at the Wind tunnel portal.
    if(!level.segment.use_exit) self shared_take_gramophone(WIND);
}

firestart_default_cfg()
{
	settings_ar = [];

	settings_ar["dt_start"] = 1;
    settings_ar["fire_spawn"] = 0;   // Start Location: 0 Craft (default, user 2026-10-20), 1 Exit.
    settings_ar["stg_start"] = STG_NO; // STG acquired: STG_NO, STG_YES or STG_PAPPED.
    settings_ar["ice_souls"] = 0;  // "Ice prefills" (0 to FIRE_ICE_SOULS_MAX).
    settings_ar["last_disc"] = 0; // Craft start disc turn: 0 random, 1 = 0 turns, 2 = 1 turn...
    settings_ar["trioskip"] = 0; // 1: non-standard "No trios" robot timing.
    settings_ar = shared_craft_time_defaults(settings_ar);
	settings_ar = shared_part_defaults(settings_ar);
	settings_ar = shared_segment_item_defaults(settings_ar);
	settings_ar["headshot_reward"] = 0;

	settings_ar["panzer_2"] = 0;
	settings_ar["panzer_3"] = 0;

	settings_ar["relay_start"] = 1;
	settings_ar["relay_tank"] = 1; // Gen2 electrical relay: solved tank_platform orientation.
	settings_ar["relay_air"] = 0;
	settings_ar["relay_elec"] = 1;
	settings_ar["relay_ruins"] = 1;
	settings_ar["relay_ice"] = 0;
	settings_ar["relay_village"] = 1;

	settings_ar = shared_templar_defaults(settings_ar);

	// Robot cycles and feet
	for(cycle = 1; cycle <= ROBOT_CYCLE_COUNT; cycle++)
	{
		settings_ar["cycle_" + cycle] = ROBOT_RANDOM;
		settings_ar["foot_" + cycle] = FOOT_RANDOM;
	}

    for(scramble = 3; scramble <= 4; scramble++)
        settings_ar["disc_" + scramble] = 0;

    settings_ar["rain_foot"] = FOOT_LEFT;
    settings_ar["rain_robot"] = ROBOT_ODIN; // Rain Fire hatch robot (segment default).
    settings_ar["cycle_tracker_ms"] = 0;
    settings_ar["cycle_tracker"] = 1;

    settings_ar = puzzle_rng_defaults(settings_ar);
    return settings_ar;
}
