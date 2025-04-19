#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\gametypes_zm\_hud_message;

#include scripts\zm\origins_menu\menu_utility;
#include scripts\zm\origins_menu\menu_base;

fullgame_initialize()
{
	replaceFunc(maps\mp\zm_tomb_giant_robot::robot_cycling, ::fullgame_robot_cycling);
	//replaceFunc(maps\mp\zm_tomb_giant_robot::giant_robot_start_walk, ::fullgame_giant_robot_start_walk);

	replacefunc( maps\mp\zombies\_zm_craftables::generate_zombie_craftable_piece, ::fullgame_generate_zombie_craftable_piece);
	replacefunc( maps\mp\zm_tomb_craftables::randomize_craftable_spawns, ::fullgame_randomize_craftable_spawns);

	replacefunc( maps\mp\zm_tomb_capture_zones::get_recapture_zone, ::fullgame_get_recapture_zone);
	replacefunc( maps\mp\zm_tomb_capture_zones::recapture_round_tracker, ::fullgame_recapture_round_tracker);

	replacefunc( maps\mp\zm_tomb_dig::dig_spots_respawn, ::fullgame_dig_spots_respawn);
	replacefunc( maps\mp\zm_tomb_dig::waittill_dug, ::fullgame_waittill_dug);
	replacefunc( maps\mp\zm_tomb_dig::bonus_points_powerup_override, ::fullgame_bonus_points_powerup_override);

	replacefunc( maps\mp\zombies\_zm_perk_random::get_weighted_random_perk, ::fullgame_get_weighted_random_perk);
	replacefunc( maps\mp\zm_tomb_quest_crypt::chamber_discs_randomize, ::fullgame_chamber_discs_randomize);

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


	level.cycle_string = "awating robot cycle";
	level.first_dig_list = array("random", "bonus_points_player", "nuke", "double_points", "zombie_blood", "ballista_zm", "c96_zm", "870mcs_zm", "dsr50_zm", "srm1216_zm");
	level.robot_cycle = 0;
	level.n_disc_scrambles = 0;
	level.custom_cycles = 17;

	set_dvar_if_unset("fullgame_cycle_tracker", 1);
	set_dvar_if_unset("fullgame_cycle_tracker_ms", 0);

	set_dvar_if_unset("fullgame_rain_robot", level.robot["odin"]);
	set_dvar_if_unset("fullgame_rain_foot", level.foot["random"]);

	set_dvar_if_unset("fullgame_cycle_1", level.robot["thor"]);
	set_dvar_if_unset("fullgame_cycle_2", level.robot["thor"]);
	set_dvar_if_unset("fullgame_cycle_3", level.robot["odin"]);
	set_dvar_if_unset("fullgame_cycle_4", level.robot["freya"]);

	set_dvar_if_unset("fullgame_foot_4", level.foot["left"]);

	for(cycle = 1; cycle <= level.custom_cycles; cycle++)
	{
		set_dvar_if_unset("fullgame_cycle_" + cycle, level.robot["random"]);
		set_dvar_if_unset("fullgame_foot_" + cycle, level.foot["random"]);
	}

	set_dvar_if_unset("fullgame_gramophone_vinyl_player_loc", 0);
	set_dvar_if_unset("fullgame_gramophone_vinyl_master_loc", 0);
	set_dvar_if_unset("fullgame_gramophone_vinyl_air_loc", 0);
	set_dvar_if_unset("fullgame_gramophone_vinyl_ice_loc", 0);
	set_dvar_if_unset("fullgame_gramophone_vinyl_fire_loc", 0);
	set_dvar_if_unset("fullgame_gramophone_vinyl_elec_loc", 0);
	set_dvar_if_unset("fullgame_maxis_body", 0);
	set_dvar_if_unset("fullgame_maxis_engine", 0);
	set_dvar_if_unset("fullgame_shield_gen2", 0);
	set_dvar_if_unset("fullgame_shield_gen3", 0);
	set_dvar_if_unset("fullgame_shield_nml", 0);

	set_dvar_if_unset("fullgame_temps_1_round", 0);
	set_dvar_if_unset("fullgame_temps_2_round", 0);

	set_dvar_if_unset("fullgame_panzer_2", 0);
	set_dvar_if_unset("fullgame_panzer_3", 0);

	for(i = 1; i < 7; i++)
	{
		set_dvar_if_unset("fullgame_temps_1_gen_" + i, 1);
		set_dvar_if_unset("fullgame_temps_2_gen_" + i, 1);
		set_dvar_if_unset("fullgame_temps_3_gen_" + i, 1);
	}

	set_dvar_if_unset("fullgame_fizz_1", 0);
	set_dvar_if_unset("fullgame_fizz_2", 0);
	set_dvar_if_unset("fullgame_fizz_location", 0);

	set_dvar_if_unset("fullgame_box_location", 0);
	set_dvar_if_unset("fullgame_box_tier", 0);
	set_dvar_if_unset("fullgame_box_hit_1", 0);
	set_dvar_if_unset("fullgame_box_hit_2", 0);
	set_dvar_if_unset("fullgame_box_no_stock_mp40", 0);

	set_dvar_if_unset("fullgame_bunker_dig", 0);
	set_dvar_if_unset("fullgame_nml_dig", 0);
	set_dvar_if_unset("fullgame_village_dig", 0);
	set_dvar_if_unset("fullgame_blood_dig", 1);

	set_dvar_if_unset("fullgame_1st_dig", 0);
	set_dvar_if_unset("fullgame_250_digs", 0);
	set_dvar_if_unset("fullgame_r4_snow", 0);
	set_dvar_if_unset("fullgame_r10_digs", 1);
	set_dvar_if_unset("fullgame_early_ice", 0);
	set_dvar_if_unset("fullgame_ending_digs", 1);

	set_dvar_if_unset("fullgame_disc_1", 0);
	set_dvar_if_unset("fullgame_disc_2", 0);
	set_dvar_if_unset("fullgame_disc_3", 0);
	set_dvar_if_unset("fullgame_disc_4", 0);
}

fullgame_run()
{
	if(getDvarInt("basegame_turbo_restarts")) setDvar("timescale", 10);
	level thread fullgame_force_wheater();
	level thread fullgame_panzer_rounds();

	fizz_loc = getDvarInt("fullgame_fizz_location");
	if(fizz_loc) level thread fullgame_fizz_start_location(fizz_loc - 1);

	box_loc = getDvarInt("fullgame_box_location");
	if(box_loc) level thread fullgame_start_box_location(box_loc - 1);

	box_tier = getDvarInt("fullgame_box_tier");
	if(box_tier) level thread fullgame_box_patch(box_tier);

	flag_wait("initial_blackscreen_passed");
	setDvar("timescale", 1);
	flag_set("menu_active");

	if(getDvarInt("fullgame_cycle_tracker")) level thread fullgame_cycle_tracker();
}


//##############GAME FUNCTIONS####################

fullgame_force_wheater()
{
	level waittill("start_of_round");
	if(getDvarInt("fullgame_early_ice")) level.force_weather[2] = "rain";
	level waittill("start_of_round");
	if(getDvarInt("fullgame_r4_snow")) level.force_weather[4] = "snow";
}

fullgame_panzer_rounds()
{
	flag_wait("initial_blackscreen_passed");
	level.mechz_left_to_spawn = 0;
	while(!level.mechz_left_to_spawn) wait 0.05;
	val = GetDvarInt("fullgame_panzer_2");
	if(0 < val)
	{
		temp_round = level.next_mechz_round;
		wait 20;
		level.next_mechz_round = temp_round + val;
	}
	wait 20;
	while(!level.mechz_left_to_spawn) wait 0.05;
	val = GetDvarInt("fullgame_panzer_3");
	if(0 < val)
	{
		temp_round = level.next_mechz_round;
		wait 20;
		level.next_mechz_round = temp_round + val;
	}
}

fullgame_fizz_start_location(loc)
{
	level waittill("initial_players_connected");
	wait 3;
	machines = getentarray("random_perk_machine", "targetname");
	index = loc + 1;
	level.random_perk_start_machine = machines[index];
	foreach(machine in machines)
	{
		if(machine != level.random_perk_start_machine)
		{
			machine hidepart("j_ball");
			machine.is_current_ball_location = 0;
			machine setclientfield("turn_on_location_indicator", 0);
			continue;
		}
		machine.is_current_ball_location = 1;
		level.wunderfizz_starting_machine = machine;
		level notify("wunderfizz_setup");
		machine thread maps\mp\zombies\_zm_perk_random::machine_think();
	}
}

fullgame_start_box_location( box_loc_val )
{
	level waittill("initial_players_connected");
	if(box_loc_val)
	{
		if(box_loc_val == 1)
		{
			start_chest = "bunker_tank_chest";
		}
		else
		{
			start_chest = "bunker_cp_chest";
		}
		for(i = 0; i < level.chests.size; i++)
		{
			if(level.chests[i].script_noteworthy == start_chest)
			{
				desired_chest_index = i;
				continue;
			}
			if(level.chests[i].hidden == 0)
			{
				nondesired_chest_index = i;
			}
		}
		if(isdefined(nondesired_chest_index) && nondesired_chest_index < desired_chest_index)
		{
			level.chests[nondesired_chest_index] maps\mp\zombies\_zm_magicbox::hide_chest();
			level.chests[nondesired_chest_index].hidden = 1;
			level.chests[desired_chest_index].hidden = 0;
			level.chests[desired_chest_index] maps\mp\zombies\_zm_magicbox::show_chest();
			level.chest_index = desired_chest_index;
		}
	}
}

fullgame_box_patch(tier)
{
	box_guns = [];
	foreach(weapon in level.zombie_weapons)
		weapon.is_in_box = 0;

	if(GetDvarInt("fullgame_box_no_stock_mp40"))
		{mpf = "mp40_zm";}
	else
		{mpf = "mp40_stalker_zm";}

	switch(tier)
	{
		case 5: box_guns = combinearrays(box_guns, array("srm1216_zm", "ksg_zm", "dsr50_zm", "python_zm")); //D
		case 4: box_guns = combinearrays(box_guns, array("fivesevendw_zm", "beretta93r_extclip_zm", "kard_zm", "qcw05_zm", "fnfal_zm")); //C
		case 3: box_guns = combinearrays(box_guns, array("pdw57_zm", "mg08_zm", "hamr_zm", "type95_zm", "thompson_zm")); //B
		case 2: box_guns = combinearrays(box_guns, array("galil_zm", "ak74u_extclip_zm", "evoskorpion_zm", mpf)); //A
		case 1: box_guns = combinearrays(box_guns, array("scar_zm")); //S
			break;

		case 6:
			level.special_weapon_magicbox_check = undefined;
			level.zombie_weapons["raygun_mark2_zm"].is_in_box = 1;
			break;
	}
}

//##############MENU FUNCTIONS####################

fullgame_refresh()
{
	if(isDefined(level.cycle_display)) level.cycle_display set_safe_text(level.cycle_string);
}

fullgame_box_tier_text()
{
	box_loc = array("normal", "S", "A", "B", "C", "D", "MK2");
	return box_loc[GetDvarInt("fullgame_box_tier")];
}

fullgame_box_loc_text()
{
	box_loc = array("random", "gen 3", "gen 2");
	return box_loc[GetDvarInt("fullgame_box_location")];
}

fullgame_fizz_loc_text()
{
	fizz_loc = array("random", "gen 4", "gen 5");
	return fizz_loc[GetDvarInt("fullgame_fizz_location")];
}

fullgame_fizz_hit_text(hit)
{
	perk_list = array("^1r^3a^2n^5d^4o^1m ^3p^2e^5r^4k", "^3double tap", "^2speed cola", "^8deadshot", "^1juggernog", "^3stamin-up", "^2mule kick", "^6PhD flopper", "^9electric cherry", "^5quick revive");
	return perk_list[GetDvarInt("fullgame_fizz_" + hit)];
}

fullgame_first_dig_text()
{
	first_dig_list_names = array("random", "blood money", "nuke", "duble points", "zombie blood", "ballista", "mauser", "remington", "DSR50", "M1216");
	return first_dig_list_names[GetDvarInt("fullgame_1st_dig")];
}

fullgame_reset_vinyls_loc()
{
	setDvar("fullgame_gramophone_vinyl_player_loc", 0);
	setDvar("fullgame_gramophone_vinyl_master_loc", 0);
	setDvar("fullgame_gramophone_vinyl_air_loc", 0);
	setDvar("fullgame_gramophone_vinyl_ice_loc", 0);
	setDvar("fullgame_gramophone_vinyl_fire_loc", 0);
	setDvar("fullgame_gramophone_vinyl_elec_loc", 0);

	self refresh_menu();
}

fullgame_reset_part_loc()
{
	setDvar("fullgame_maxis_body", 0);
	setDvar("fullgame_maxis_engine", 0);
	setDvar("fullgame_shield_gen2", 0);
	setDvar("fullgame_shield_gen3", 0);
	setDvar("fullgame_shield_nml", 0);

	self refresh_menu();
}

fullgame_random_discs()
{
	setDvar( level.gamemode + "_disc_1", 0);
	setDvar( level.gamemode + "_disc_2", 0);
	setDvar( level.gamemode + "_disc_3", 0);
	setDvar( level.gamemode + "_disc_4", 0);
	self refresh_menu();
}

fullgame_perfect_discs()
{
	setDvar( level.gamemode + "_disc_1", 2222);
	setDvar( level.gamemode + "_disc_2", 1222);
	setDvar( level.gamemode + "_disc_3", 2112);
	setDvar( level.gamemode + "_disc_4", 1121);
	self refresh_menu();
}

fullgame_worst_discs()
{
	setDvar( level.gamemode + "_disc_1", 2122);
	setDvar( level.gamemode + "_disc_2", 1122);
	setDvar( level.gamemode + "_disc_3", 1211);
	setDvar( level.gamemode + "_disc_4", 2222);
	self refresh_menu();
}

fullgame_all_random_cycles()
{
	setDvar("fullgame_rain_robot", level.robot["random"]);
	for(i = 1; i <= level.custom_cycles; i++)
		setDvar("fullgame_cycle_" + i, level.robot["random"]);

    self refresh_menu();
}

fullgame_all_random_feet()
{
	setDvar("fullgame_rain_foot", level.foot["random"]);
	for(i = 1; i <= level.custom_cycles; i++)
		setDvar("fullgame_foot_" + i, level.foot["random"]);

	self refresh_menu();
}

fullgame_gram_to_text()
{
	locs = array("random", "far", "close");
	return locs[GetDvarInt("fullgame_gramophone_vinyl_player_loc")];
}

fullgame_maxis_to_text(part)
{
	dvar = "fullgame_maxis_" + part;
	locs["body"] = array("random", "tunnel", "gen 5", "gen 4");
	locs["engine"] = array("random", "pap", "gram", "scaffolding");

	spot = GetDvarInt(dvar);
	return locs[part][spot];
}

fullgame_disk_to_text(part)
{
	dvar = "fullgame_gramophone_vinyl_" + part + "_loc";
	locs["master"] = array("random", "wheelbarrow", "stairs", "back");
	locs["air"] = array("random", "tunnel", "boxes", "stam");
	locs["ice"] = array("random", "dial", "mystery box", "table");
	locs["fire"] = array("random", "top", "gen", "bottom");
	locs["elec"] = array("random", "fizz", "tunnel", "wagon");

	spot = GetDvarInt(dvar);
	return locs[part][spot];
}

fullgame_shield_to_text(part)
{
	dvar = "fullgame_shield_" + part;
	locs["gen2"] = array("random", "claymore", "wheelbarrow", "footprint");
	locs["gen3"] = array("random", "tunnel", "wheelbarrow", "ak74u");
	locs["nml"] = array("random", "gen 4 box", "gen 4 side", "gen 5 side");

	spot = GetDvarInt(dvar);
	return locs[part][spot];
}

fullgame_reset_templar(set)
{
	for(i = 1; i < 7; i++)
		setDvar(level.gamemode + "_temps_" + set + "_gen_" + i, 1);
	self refresh_menu();
}

fullgame_cycle_panzer( num )
{
	panz_dvar = "fullgame_panzer_" + num;
	switch(GetDvarInt(panz_dvar))
	{
		case 0: setDvar(panz_dvar, 4); break;
		case 4: setDvar(panz_dvar, 5); break;
        case 5:
		default: setDvar(panz_dvar, 0); break;
	}
	self refresh_menu();
}

fullgame_toggle_cycle_display()
{
    dvar = "fullgame_cycle_tracker";
    new_status = 1 - getDvarInt(dvar);
    setDvar(dvar, new_status);
    if(new_status) level thread fullgame_cycle_tracker();
    else level.cycle_display destroy();
    self refresh_menu();
}

fullgame_cycle_tracker()
{
    level.cycle_display = createserverfontstring("default", 1.3);
	level.cycle_display setpoint("LEFT", "LEFT", 5, -232);
	level.cycle_display.alpha = 1;
	level.cycle_display set_safe_text(level.cycle_string);
}

fullgame_menu_robot_cycle_string(starting, robot, decimals = 0)
{
    robots = array("odin", "thor", "freya", "trios");
    level.cycle_string = game_time_string(getDvarInt("fullgame_cycle_tracker_ms"));
    level.cycle_string = level.cycle_string + " | cycle " + level.robot_cycle + bool_compare_string(starting, " start", " end");
    level.cycle_string = level.cycle_string + " | " + robots[robot];
    if(isDefined(level.cycle_display))  level.cycle_display set_safe_text(level.cycle_string);
    print(level.cycle_string);
}


fullgame_toggle_templar_round(set)
{
	dvar = "fullgame_temps_" + set + "_round";
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

fullgame_temp_round_to_text(set)
{
	dvar = level.gamemode + "_temps_" + set + "_round";
	val = GetDvarInt(dvar);

	if(val) return val + " rounder";
	else 	return "random round";
}

fullgame_reset_scramble( num )
{
	dvar = level.gamemode + "_disc_" + num;
	setDvar(dvar, 0);
	self refresh_menu();
}

fullgame_flip_scramble(index, num)
{
	dvar = level.gamemode + "_disc_" + num;
	scramble = getDvarInt(dvar);
	if(scramble < 1)
	{
		setDvar(dvar, 1111);
		self refresh_menu();
		return;
	}

	pow = pow( 10, (3 - index) );
	val = int(scramble / pow) % 10;

	if(val == 1)
		scramble = scramble + pow;
	else
		scramble = scramble - pow;

	setDvar(dvar, scramble);
	self refresh_menu();
}

fullgame_scramble_text( index, num )
{
	dvar = level.gamemode + "_disc_" + num;
	scramble = getDvarInt(dvar);
	if(scramble)
	{
		color = array("blue", "purple", "red", "yellow");
		colors = array("^4", "^6", "^1", "^3");
		decoded = [];
		prev_disc_pos = 0;
		for( i = 1; i < 5; i++)
		{
			turn = int(scramble / pow( 10, 4 - i )) % 10;
			decoded[i - 1] = (prev_disc_pos + turn) % 4;
			prev_disc_pos = decoded[i - 1];
		}
		return colors[decoded[index]] + "[" + "] " + color[decoded[index]];
	}
	else
	{
		return "^8[] random";
	}
}

fullgame_scramble_text_line( num )
{
	dvar = level.gamemode + "_disc_" + num;
	scramble = getDvarInt(dvar);
	if(scramble)
	{
		inline = "^8]";
		color = array("B", "P", "R", "Y");
		colors = array("^4", "^6", "^1", "^3");
		decoded = [];
		prev_disc_pos = 0;
		for( i = 1; i < 5; i++)
		{
			turn = int(scramble / pow( 10, 4 - i )) % 10;
			prev_disc_pos = (prev_disc_pos + turn) % 4;
			inline = colors[prev_disc_pos] + color[prev_disc_pos] + inline;
		}
		inline = "^8[" + inline;
		return inline;
	}
	else
	{
		return "^8[random]";
	}
}

//##############hud elements####################

//##############overrides####################
fullgame_bonus_points_powerup_override()
{
	points = 250;
	if(!getDvarInt("fullgame_250_digs"))
		points = randomintrange( 1, 6 ) * 50;
    level thread maps\mp\zombies\_zm_audio_announcer::leaderdialog( "blood_money" );
    return points;
}

fullgame_waittill_dug(s_dig_spot)
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
			s_staff_piece = s_dig_spot fullgame_dig_spot_get_staff_piece(player);
			if(isDefined(s_staff_piece))
			{
				s_staff_piece maps\mp\zm_tomb_main_quest::show_ice_staff_piece(self.origin);
				player maps\mp\zm_tomb_dig::dig_reward_dialog("dig_staff_part");
			}
			else
			{
				n_good_chance = 50;
				if(player.dig_vars["n_spots_dug"] == 0 || player.dig_vars["n_losing_streak"] == 3)
				{
					player.dig_vars["n_losing_streak"] = 0;
					n_good_chance = 100;
				}
				if(player.dig_vars["has_upgraded_shovel"])
				{
					if(!player.dig_vars["has_helmet"])
					{
						n_helmet_roll = randomint(100);
						if(n_helmet_roll >= 95)
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
				n_prize_roll = randomint(100);
				if(flag("ee_mech_zombie_hole_opened") && !level.dig_n_zombie_bloods_spawned && GetDvarInt("fullgame_blood_dig"))
				{
					self thread first_dig(player, "zombie_blood");
				}
				else if(player.dig_vars["n_spots_dug"] == 0 && getDvarInt("fullgame_1st_dig"))
				{
					value = getDvarInt("fullgame_1st_dig");
					if(value < 5)
						self thread first_dig(player, level.first_dig_list[value]);
					else if(value < 10)
						self thread weapon_first(player, level.first_dig_list[value]);
				}
				else if(n_prize_roll > n_good_chance)
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

first_dig( player, powerup_item)
{
    powerup = spawn( "script_model", self.origin );
    powerup endon( "powerup_grabbed" );
    powerup endon( "powerup_timedout" );

	if( powerup_item == "zombie_blood")
	{
		level.dig_n_zombie_bloods_spawned++;
		level.dig_n_powerups_spawned++;
		level.dig_last_prize_rare = 0;
		player maps\mp\zm_tomb_dig::dig_reward_dialog( "dig_powerup" );
	}
	else if( powerup_item == "bonus_points_player")
	{
		level.dig_last_prize_rare = 0;
		player maps\mp\zm_tomb_dig::dig_reward_dialog( "dig_cash" );
	}
    else
    {
        level.dig_last_prize_rare = 1;
        level.dig_n_powerups_spawned++;
        player maps\mp\zm_tomb_dig::dig_reward_dialog( "dig_powerup" );
        maps\mp\zm_tomb_dig::dig_set_powerup_spawned( powerup_item );
    }

    powerup maps\mp\zombies\_zm_powerups::powerup_setup( powerup_item );
    powerup movez( 40, 0.6 );

    powerup waittill( "movedone" );

    powerup thread maps\mp\zombies\_zm_powerups::powerup_timeout();
    powerup thread maps\mp\zombies\_zm_powerups::powerup_wobble();
    powerup thread maps\mp\zombies\_zm_powerups::powerup_grab();
}

weapon_first( digger, weapon )
{
	str_spec_model = undefined;
	v_spawnpt = self.origin + ( 0, 0, 40 );
    v_angles = digger getplayerangles();
    v_angles = ( 0, v_angles[1], 0 ) + vectorscale( ( 0, 1, 0 ), 90.0 ) + ( 0, 0, 0 );
    m_weapon = spawn_weapon_model( weapon, str_spec_model, v_spawnpt, v_angles );

    m_weapon.angles = v_angles;
    m_weapon playloopsound( "evt_weapon_digup" );
    m_weapon thread maps\mp\zm_tomb_dig::timer_til_despawn( v_spawnpt, 40 * -1 );
    m_weapon endon( "dig_up_weapon_timed_out" );
    playfxontag( level._effect["special_glow"], m_weapon, "tag_origin" );
    m_weapon.trigger = maps\mp\zm_tomb_utility::tomb_spawn_trigger_radius( v_spawnpt, 100, 1 );
    m_weapon.trigger.hint_string = &"ZM_TOMB_X2PU";
    m_weapon.trigger.hint_parm1 = getweapondisplayname( weapon );

    m_weapon.trigger waittill( "trigger", player );

    m_weapon.trigger notify( "weapon_grabbed" );
    m_weapon.trigger thread swap_weapon( weapon, player );

    if ( isDefined( m_weapon.trigger ) )
    {
        m_weapon.trigger maps\mp\zm_tomb_utility::tomb_unitrigger_delete();
        m_weapon.trigger = undefined;
    }

    if ( isDefined( m_weapon ) )
        m_weapon delete();

    if ( player != digger )
        digger notify( "dig_up_weapon_shared" );
}

fullgame_dig_spot_get_staff_piece(e_player)
{
	level notify("sam_clue_dig", e_player);
	str_zone = self.str_zone;
	foreach(s_staff in level.ice_staff_pieces)
	{
		if(!isDefined(s_staff.num_misses))
			s_staff.num_misses = 0;

		if(issubstr(str_zone, s_staff.zone_substr))
		{
			miss_chance = 100 / (s_staff.num_misses + 1);
			if(level.weather_snow <= 0)
				miss_chance = 101;

			switch(s_staff.zone_substr)
			{
				case "bunker":
					if(GetDvarInt("fullgame_bunker_dig") && miss_chance < 100) return s_staff;
					break;

				case "nml":
					if(GetDvarInt("fullgame_nml_dig") && miss_chance < 100) return s_staff;
					break;

				case "village":
					if(GetDvarInt("fullgame_village_dig") && miss_chance < 100) return s_staff;
					break;
			}

			if(randomint(100) > miss_chance || s_staff.num_misses > 3 && miss_chance < 100)
			{
				return s_staff;
			}
			s_staff.num_misses++;
			break;
		}
	}
	return undefined;
}

fullgame_randomize_craftable_spawns()
{
	a_randomized_craftables = array("gramophone_vinyl_ice", "gramophone_vinyl_air", "gramophone_vinyl_elec", "gramophone_vinyl_fire", "gramophone_vinyl_master", "gramophone_vinyl_player");
	foreach(str_craftable in a_randomized_craftables)
	{
		s_original_pos = getstruct(str_craftable, "targetname");
		a_alt_locations = getstructarray(str_craftable + "_alt", "targetname");
		dvar = GetDvarInt(level.gamemode + "_" + str_craftable + "_loc");
		if(dvar)
		{
			n_loc_index = dvar - 1;
		}
		else
		{
			n_loc_index = randomintrange(0, a_alt_locations.size + 1);
		}
		if(n_loc_index == a_alt_locations.size)
		{
			continue;
		}
		s_original_pos.origin = a_alt_locations[n_loc_index].origin;
		s_original_pos.angles = a_alt_locations[n_loc_index].angles;
	}
}

fullgame_generate_zombie_craftable_piece(craftablename, piecename, modelname, radius, height, drop_offset, hud_icon, onpickup, ondrop, oncrafted, use_spawn_num, tag_name, can_reuse, client_field_value, is_shared, vox_id, b_one_time_vo)
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
	switch(piecename)
	{
		case "body": loc_override = GetDvarInt("fullgame_maxis_body"); break;
		case "engine": loc_override = GetDvarInt("fullgame_maxis_engine"); break;

		case "top": loc_override = GetDvarInt("fullgame_shield_gen3"); break;
		case "door": loc_override = GetDvarInt("fullgame_shield_nml"); break;
		case "bracket": loc_override = GetDvarInt("fullgame_shield_gen2"); break;
	}
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
	loc[0] = piece[loc_index - 1];
	return loc;
}

fullgame_robot_cycling()
{
	level.robot_start_time = GetTime();
	three_robot_round = 0;
	last_robot = -1;
	level thread maps\mp\zm_tomb_giant_robot::giant_robot_intro_walk(1);
	level waittill("giant_robot_intro_complete");

	/**
	if(level.delay_robot)
	{
		flag_wait("start_robots");
	}
	**/


	while(true)
	{
		level.robot_cycle++;
		random_number = -1;
		if( !(level.round_number % 4) && three_robot_round != level.round_number)
		{
			flag_set("three_robot_round");
			if(flag("ee_all_staffs_upgraded"))
			{
				dvar_val = GetDvarInt("fullgame_rain_robot");
				if(dvar_val) random_number = dvar_val - 1;
			}
		}

		if(level.robot_cycle <= level.custom_cycles)
		{
			dvar_val = GetDvarInt("fullgame_cycle_" + level.robot_cycle);
			if(dvar_val) random_number = dvar_val - 1;
		}

		if(flag("ee_all_staffs_placed") && !flag("ee_mech_zombie_hole_opened"))
		{
			flag_set("three_robot_round");
			dvar_val = GetDvarInt("fullgame_rain_robot");
			if(dvar_val) random_number = dvar_val - 1;
		}

		if(flag("three_robot_round"))
		{
			level.zombie_ai_limit = 22;
			if(random_number < 0)
			{
				random_number = randomint(3);
			}
			fullgame_menu_robot_cycle_string(1, 3);
			if(random_number == 2)
			{
				level thread fullgame_giant_robot_start_walk(2);
			}
			else
			{
				level thread fullgame_giant_robot_start_walk(2, 0);
			}
			wait 5;
			if(random_number == 0)
			{
				level thread fullgame_giant_robot_start_walk(0);
			}
			else
			{
				level thread fullgame_giant_robot_start_walk(0, 0);
			}
			wait 5;
			if(random_number == 1)
			{
				level thread fullgame_giant_robot_start_walk(1);
			}
			else
			{
				level thread fullgame_giant_robot_start_walk(1, 0);
			}
			level waittill("giant_robot_walk_cycle_complete");
			level waittill("giant_robot_walk_cycle_complete");
			level waittill("giant_robot_walk_cycle_complete");
			fullgame_menu_robot_cycle_string(0, 3);
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
			fullgame_menu_robot_cycle_string(1, random_number);
			level thread fullgame_giant_robot_start_walk(random_number);
			level waittill("giant_robot_walk_cycle_complete");
			fullgame_menu_robot_cycle_string(0, random_number);
			wait 5;
		}
	}
}


#using_animtree("zm_tomb_giant_robot_hatch");
fullgame_giant_robot_start_walk(n_robot_id, b_has_hatch)
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
		if(level.robot_cycle <= level.custom_cycles)
		{
			robot_foot = GetDvarInt("fullgame_foot_" + level.robot_cycle);
			if(robot_foot)
			{
				foot = robot_foot - 1;
			}
		}
		if(flag("ee_all_staffs_crafted"))
		{
			robot_foot = GetDvarInt("fullgame_rain_foot");
			if(robot_foot)
			{
				foot = robot_foot - 1;
			}
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

fullgame_recapture_round_tracker()
{
	level.n_next_recapture_round = 10;
	level.n_templar_rounds = 0;
	while(true)
	{
		level waittill("between_round_over");
		if(level.round_number >= level.n_next_recapture_round && !flag("zone_capture_in_progress") && maps\mp\zm_tomb_capture_zones::get_captured_zone_count() >= maps\mp\zm_tomb_capture_zones::get_player_controlled_zone_count_for_recapture())
		{
			level.n_templar_rounds++;
			temp_round = 0;
			if(int_in_range(level.n_templar_rounds, 1, 2))
			{
				set = level.n_templar_rounds + 1;
				dvar = "fullgame_temps_" + set + "_round";
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

fullgame_get_recapture_zone(s_last_recapture_zone)
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
				gen_dvar = "fullgame_temps_" + level.n_templar_rounds + "_gen_" + i;
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

fullgame_dig_spots_respawn( a_dig_spots )
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

		override_dig_spots = undefined;
        //custom logic
		if(getDvarInt("fullgame_early_ice") && level.round_number < 5)
		{
			//exca box, mp40, nml door
			override_dig_spots = array(1, 17, 21);
		}
		else if(getDvarInt("fullgame_r10_digs") && level.round_number < 11)
		{
			//slow fast dig, cutch box, fast dig, far freya, front tank
			override_dig_spots = array(2, 12, 13, 14, 27);
		}
		else if(getDvarInt("fullgame_ending_digs") && level.round_number < 16)
		{
			// slow foot, rain dig, gen5 box, old bulb2 line
			override_dig_spots = array(16, 18, 19, 20);
		}

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

fullgame_get_weighted_random_perk(player)
{
	hits = player maps\mp\gametypes_zm\_globallogic_score::getpersstat("use_perk_random");
	hacked_perks = array("specialty_rof", "specialty_fastreload", "specialty_deadshot", "specialty_armorvest", "specialty_longersprint", "specialty_additionalprimaryweapon", "specialty_flakjacket", "specialty_grenadepulldeath", "specialty_quickrevive");
	fizz_1 = GetDvarInt("fullgame_fizz_1");
	fizz_2 = GetDvarInt("fullgame_fizz_2");
	if(hits == 1 && 0 < fizz_1)
	{
		perk = hacked_perks[fizz_1 - 1];
		if(!(player hasperk(perk)))
			return perk;
	}
	else if(hits == 2 && 0 < fizz_2)
	{
		perk = hacked_perks[fizz_2 - 1];
		if(!(player hasperk(perk)))
			return perk;
	}
	keys = array_randomize(getarraykeys(level._random_perk_machine_perk_list));
	if(isdefined(level.custom_random_perk_weights))
	{
		keys = player [[level.custom_random_perk_weights]]();
	}
	i = 0;
	while(i < keys.size)
	{
		key = keys[i];
		if(player hasperk(level._random_perk_machine_perk_list[key]))
		{
			continue;
		}
		else
		{
			return level._random_perk_machine_perk_list[key];
		}
		i++;
	}
	return level._random_perk_machine_perk_list[keys[0]];
}

fullgame_chamber_discs_randomize()
{
	level.n_disc_scrambles++;
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

level_print( text )
{
	print(text);
}