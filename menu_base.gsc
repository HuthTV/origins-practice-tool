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

build_menu_tree()
{
	if(self is_verified())
	{
		create_menu(self.menu_tree["menu"], undefined, self.menu_tree["menu"]);

			TOP="gamemodes";
			create_option(self.menu_tree["menu"], ">Practice Modes", ::enter_menu, TOP, "Modes");
				create_menu(TOP, self.menu_tree["menu"], "Modes");
					create_option(TOP, "Full Game " + gamemode_color("fullgame"), ::set_gamemode, "fullgame");
					create_option(TOP, "Ice Start " + gamemode_color("icestart"), ::set_gamemode, "icestart");
					create_option(TOP, "Wind Start " + gamemode_color("windstart"), ::set_gamemode, "windstart");
					create_option(TOP, "Panzer Practice " + gamemode_color("panzprac"), ::set_gamemode, "panzprac");
					create_option(TOP, "Gen Practice " + gamemode_color("genprac"), ::set_gamemode, "genprac");
					create_option(TOP, "-Wind Bulbs ", ::n_test);
					create_option(TOP, "-Ice Code ", ::n_test);
					create_option(TOP, "-Wind Code ", ::n_test);
					create_option(TOP, "-Fire Code ", ::n_test);
					create_option(TOP, "-Ending prac ", ::n_test);
					create_option(TOP, "-Raise hell prac ", ::n_test);

			TOP="game";
			create_option(self.menu_tree["menu"], ">Game Settings", ::enter_menu, TOP, "Game");
				create_menu(TOP, self.menu_tree["menu"], "Game");
					create_option(TOP, "Cycle tracker: " + dvarint_compare(level.gamemode + "_cycle_tracker"), ::toggle_binary, level.gamemode + "_cycle_tracker");
					create_option(TOP, "Super Fast Restarts: " + dvarint_compare("basegame_turbo_restarts"), ::toggle_binary, "basegame_turbo_restarts");
					create_option(TOP, "Movment Dvars: ^3" + getDvar("basegame_strafe_dvars"), ::basegame_strafe_cycle);
					create_option(TOP, "Super Fast Quit", ::fast_quit);

			if(level.gamemode == "panzprac")
			{
				TOP="panz_prac";
				create_option(self.menu_tree["menu"], ">Panz Prac", ::enter_menu, TOP, "Panz Prac");
					create_menu(TOP, self.menu_tree["menu"], "Panz Prac");
						create_option(TOP, "Box: ^3" + getDvar("panzprac_box"), scripts\zm\origins_menu\panzprac::cycle_box);
						create_option(TOP, "Claymore: " + dvarint_compare("panzprac_clay"), ::toggle_binary, "panzprac_clay");
						create_option(TOP, "Prefills: ^3" + getDvar("panzprac_prefills"), ::increment_int, "panzprac_prefills", array(5,15));
						create_option(TOP, "Hud Info: "  + dvarint_compare("panzprac_hud"), ::toggle_binary, "panzprac_hud");
			}

			if(level.gamemode == "genprac")
			{
				TOP="gen_prac";
				create_option(self.menu_tree["menu"], ">Gen Prac", ::enter_menu, TOP, "Gen Prac");
					create_menu(TOP, self.menu_tree["menu"], "Gen Prac");
						P1 = "gens";
						create_option(TOP, ">Active Gens", ::enter_menu, P1, "Gens");
						create_menu(P1, TOP, "Gens");
							create_option(P1, "Activate All", scripts\zm\origins_menu\genprac::reset_all_gens);
							create_option(P1, "Gen 1: " + dvarint_compare("genprac_start_bunker"), ::toggle_binary, "genprac_start_bunker");
							create_option(P1, "Gen 2: " + dvarint_compare("genprac_tank_trench"), ::toggle_binary, "genprac_tank_trench");
							create_option(P1, "Gen 3: " + dvarint_compare("genprac_mid_trench"), ::toggle_binary, "genprac_mid_trench");
							create_option(P1, "Gen 4: " + dvarint_compare("genprac_nml_right"), ::toggle_binary, "genprac_nml_right");
							create_option(P1, "Gen 5: " + dvarint_compare("genprac_nml_left"), ::toggle_binary, "genprac_nml_left");
							create_option(P1, "Gen 6: " + dvarint_compare("genprac_church"), ::toggle_binary, "genprac_church");
						create_option(TOP, "Teleport Throws: " + dvarint_compare("genprac_teleport_throw"), ::toggle_binary, "genprac_teleport_throw");
			}

			if(level.gamemode == "windstart")
			{
				TOP="mapsettigns";
				create_option(self.menu_tree["menu"], ">Map Settings", ::enter_menu, TOP, "Map");
					create_menu(TOP, self.menu_tree["menu"], "Map");
						create_option(TOP, "RLACE: ^3 s", ::test);
				TOP="panzer";
				create_option(self.menu_tree["menu"], ">Panzer", ::enter_menu, TOP, "Panzer");
					create_menu(TOP, self.menu_tree["menu"], "Panzer");
						P1 ="panzer";
							create_option(P1, "Panzer 2: ^3" + dvarint_compare("windstart_panzer_2", getDvarInt("windstart_panzer_2") + " rounder", "random"), scripts\zm\origins_menu\windstart::windstart_cycle_panzer, 2);
							create_option(P1, "Panzer 3: ^3" + dvarint_compare("windstart_panzer_3", getDvarInt("windstart_panzer_3") + " rounder", "random"), scripts\zm\origins_menu\windstart::windstart_cycle_panzer, 3);

				TOP="templars";
				create_option(self.menu_tree["menu"], ">Templars", ::enter_menu, TOP, "Templars");
					create_menu(TOP, self.menu_tree["menu"], "Templars");
						D1="templars_2";
						create_option(TOP, ">Templars II", ::enter_menu, D1, "Temps II");
							create_menu(D1, TOP, "Templars II");
								create_option(D1, "Reset", ::fullgame_reset_templar, 2);
								for(i = 1; i < 7; i++)
									create_option(D1, "Gen " + i + " " + dvarint_compare("windstart_temps_2_gen_" + i), ::toggle_binary, "windstart_temps_2_gen_" + i);
						D2="templars_3";
						create_option(TOP, ">Templars III", ::enter_menu, D2, "Temps III");
							create_menu(D2, TOP, "Templars III");
								create_option(D2, "Reset", ::fullgame_reset_templar, 3);
								for(i = 1; i < 7; i++)
									create_option(D2, "Gen " + i + " " +  dvarint_compare("windstart_temps_3_gen_" + i), ::toggle_binary, "windstart_temps_3_gen_" + i);
					create_option(TOP, "Templar II: ^3" + fullgame_temp_round_to_text(2), scripts\zm\origins_menu\windstart::windstart_toggle_templar_round, 2);
					create_option(TOP, "Templar III: ^3" + fullgame_temp_round_to_text(3), scripts\zm\origins_menu\windstart::windstart_toggle_templar_round, 3);
			}


			if(level.gamemode == "icestart")
			{
				create_option("game", "Skip Intro: "+ dvarint_compare("icestart_skip_intro"), ::toggle_binary, "icestart_skip_intro");

				TOP="mapsettigns";
				create_option(self.menu_tree["menu"], ">Map Settings", ::enter_menu, TOP, "Map");
					create_menu(TOP, self.menu_tree["menu"], "Map");
						create_option(TOP, "Craft Time: ^3 " + level.timing_strings[getDvarInt("icestart_craft_time")], ::increment_int, "icestart_craft_time", array(0, 21));
						create_option(TOP, "Cycle 1 Foot: ^3 " + icestart_cycle1_text(getDvarInt("icestart_trench_path")), scripts\zm\origins_menu\icestart::icestart_cycle1_toggle);
						create_option(TOP, "Rain Foot: ^3" + level.foot[getDvarInt("icestart_rain_foot")], ::increment_int, "icestart_rain_foot", array(0, 2));
						create_option(TOP, "Ice Disc Turn: ^3" + dvarint_compare("icestart_last_disc", getDvarInt("icestart_last_disc") - 1 + " turn", "random"), ::increment_int, "icestart_last_disc", array(0, 4));
						create_option(TOP, "Start Location: ^3" + icestart_loc_text(getDvarInt("icestart_start_loc")), scripts\zm\origins_menu\icestart::icestart_startloc_toggle);
						create_option(TOP, "Early Gram: "+ dvarint_compare("icestart_early_gram", "^2yes", "^1no"), ::toggle_binary, "icestart_early_gram");
				TOP="items";
				create_option(self.menu_tree["menu"], ">Items settings", ::enter_menu, TOP, "Items");
					create_menu(TOP, self.menu_tree["menu"], "Items");
						create_option(TOP, "Purple Disc: "+ dvarint_compare("icestart_purple_disc", "^2collected", "^3chariot"), ::toggle_binary, "icestart_purple_disc");
						create_option(TOP, "Tank Path Maxis: "+ dvarint_compare("icestart_maxis_body"), ::toggle_binary, "icestart_maxis_body");
						create_option(TOP, "Scaffolding Maxis: "+ dvarint_compare("icestart_maxis_engine"), ::toggle_binary, "icestart_maxis_engine");
						create_option(TOP, "Plane Shot: "+ dvarint_compare("icestart_kill_plane"), ::toggle_binary, "icestart_kill_plane");
						create_option(TOP, "Plane Part: "+ dvarint_compare("icestart_plane_part", "^2collected", "^1disperse"), ::icestart_plane_part_toggle, "icestart_plane_part");
						create_option(TOP, "Fizz DT: "+ dvarint_compare("icestart_dt_start"), ::toggle_binary, "icestart_dt_start");
						create_option(TOP, "115 Reward: "+ dvarint_compare("icestart_headshot_reward"), ::toggle_binary, "icestart_headshot_reward");
				TOP="discs";
				create_option(self.menu_tree["menu"], ">Mound discs", ::enter_menu, TOP, "Discs");
					create_menu(TOP, self.menu_tree["menu"], "Discs");
						create_option(TOP, "Optimal Discs", ::fullgame_perfect_discs);
						create_option(TOP, "Worst Discs", ::fullgame_worst_discs);
						create_option(TOP, "Random Discs", ::fullgame_random_discs);
						S2 = "scramb_2";
						create_option(TOP, ">Scramble II " + fullgame_scramble_text_line(2), ::enter_menu, S2, "Disc II");
						create_menu(S2, TOP, "Disc II");
							create_option(S2, "Random", ::fullgame_reset_scramble, 2);
							create_option(S2, "Top: " + fullgame_scramble_text(3, 2), ::fullgame_flip_scramble, 3, 2);
							create_option(S2, "2nd: " + fullgame_scramble_text(2, 2), ::fullgame_flip_scramble, 2, 2);
							create_option(S2, "3rd: " + fullgame_scramble_text(1, 2), ::fullgame_flip_scramble, 1, 2);
							create_option(S2, "Bot: " + fullgame_scramble_text(0, 2), ::fullgame_flip_scramble, 0, 2);
						S3  = "scramb_3";
						create_option(TOP, ">Scramble III " + fullgame_scramble_text_line(3), ::enter_menu, S3, "Disc III");
						create_menu(S3, TOP, "Disc III");
							create_option(S3, "Random", ::fullgame_reset_scramble, 3);
							create_option(S3, "Top: " + fullgame_scramble_text(3, 3), ::fullgame_flip_scramble, 3, 3);
							create_option(S3, "2nd: " + fullgame_scramble_text(2, 3), ::fullgame_flip_scramble, 2, 3);
							create_option(S3, "3rd: " + fullgame_scramble_text(1, 3), ::fullgame_flip_scramble, 1, 3);
							create_option(S3, "Bot: " + fullgame_scramble_text(0, 3), ::fullgame_flip_scramble, 0, 3);
						S4 = "scramb_4";
						create_option(TOP, ">Scramble IV " + fullgame_scramble_text_line(4), ::enter_menu, S4, "Disc IV");
						create_menu(S4, TOP, "Disc IV");
							create_option(S4, "Random", ::fullgame_reset_scramble, 4);
							create_option(S4, "Top: " + fullgame_scramble_text(3, 4), ::fullgame_flip_scramble, 3, 4);
							create_option(S4, "2nd: " + fullgame_scramble_text(2, 4), ::fullgame_flip_scramble, 2, 4);
							create_option(S4, "3rd: " + fullgame_scramble_text(1, 4), ::fullgame_flip_scramble, 1, 4);
							create_option(S4, "Bot: " + fullgame_scramble_text(0, 4), ::fullgame_flip_scramble, 0, 4);
				TOP="relays";
				create_option(self.menu_tree["menu"], ">Electric Relays", ::enter_menu, TOP, "Relays");
					create_menu(TOP, self.menu_tree["menu"], "Relays");
						create_option(TOP, "Spawn: " + dvarint_compare("icestart_relay_start", "^2solved", "^1unsolved"), ::toggle_binary, "icestart_relay_start");
						create_option(TOP, "Gen2: " + dvarint_compare("icestart_relay_tank", "^2solved", "^1unsolved"), ::toggle_binary, "icestart_relay_tank");
						create_option(TOP, "Gen4: " + dvarint_compare("icestart_relay_air", "^2solved", "^1unsolved"), ::toggle_binary, "icestart_relay_air");
						create_option(TOP, "Gen5: " + dvarint_compare("icestart_relay_elec", "^2solved", "^1unsolved"), ::toggle_binary, "icestart_relay_elec");
						create_option(TOP, "Middle: " + dvarint_compare("icestart_relay_ruins", "^2solved", "^1unsolved"), ::toggle_binary, "icestart_relay_ruins");
						create_option(TOP, "Bot Church: " + dvarint_compare("icestart_relay_ice", "^2solved", "^1unsolved"), ::toggle_binary, "icestart_relay_ice");
						create_option(TOP, "Top Church: " + dvarint_compare("icestart_relay_village", "^2solved", "^1unsolved"), ::toggle_binary, "icestart_relay_village");
				TOP="templars";
				create_option(self.menu_tree["menu"], ">Templars", ::enter_menu, TOP, "Templars");
					create_menu(TOP, self.menu_tree["menu"], "Templars");
						D1="temps_1";
						create_option(TOP, ">Templars I", ::enter_menu, D1, "Temps I");
						create_menu(D1, TOP, "Templars I");
							create_option(D1, "Reset", ::fullgame_reset_templar, 1);
							for(i = 1; i < 7; i++)
								create_option(D1, "Gen " + i + " " + dvarint_compare("icestart_temps_1_gen_" + i), ::toggle_binary, "icestart_temps_1_gen_" + i);
						D2="templars_2";
						create_option(TOP, ">Templars II", ::enter_menu, D2, "Temps II");
						create_menu(D2, TOP, "Templars II");
							create_option(D2, "Reset", ::fullgame_reset_templar, 2);
							for(i = 1; i < 7; i++)
								create_option(D2, "Gen " + i + " " + dvarint_compare("icestart_temps_2_gen_" + i), ::toggle_binary, "icestart_temps_2_gen_" + i);
						D3="templars_3";
						create_option(TOP, ">Templars III", ::enter_menu, D3, "Temps III");
						create_menu(D3, TOP, "Templars III");
							create_option(D3, "Reset", ::fullgame_reset_templar, 3);
							for(i = 1; i < 7; i++)
								create_option(D3, "Gen " + i + " " +  dvarint_compare("icestart_temps_3_gen_" + i), ::toggle_binary, "icestart_temps_3_gen_" + i);
					create_option(TOP, "Templar II: ^3" + fullgame_temp_round_to_text(2), scripts\zm\origins_menu\icestart::icestart_toggle_templar_round, 2);
					create_option(TOP, "Templar III: ^3" + fullgame_temp_round_to_text(3), scripts\zm\origins_menu\icestart::icestart_toggle_templar_round, 3);
				TOP="panzer";
				create_option(self.menu_tree["menu"], ">Panzer", ::enter_menu, TOP, "Panzer");
					create_menu(TOP, self.menu_tree["menu"], "Panzer");
						P1 ="panzer";
							create_option(P1, "Panzer 2: ^3" + dvarint_compare("icestart_panzer_2", getDvarInt("icestart_panzer_2") + " rounder", "random"), scripts\zm\origins_menu\icestart::icestart_cycle_panzer, 2);
							create_option(P1, "Panzer 3: ^3" + dvarint_compare("icestart_panzer_3", getDvarInt("icestart_panzer_3") + " rounder", "random"), scripts\zm\origins_menu\icestart::icestart_cycle_panzer, 3);
				TOP="cycles";
				create_option(self.menu_tree["menu"], ">Robot Cycles", ::enter_menu, TOP, "Cycles");
					create_menu(TOP, self.menu_tree["menu"], "Cycles");
						create_option(TOP, "All random", scripts\zm\origins_menu\fullgame::fullgame_all_random_cycles); //FIX!!!!!
						for( cycle = 8; cycle <= level.custom_cycles; cycle++)
						{
							create_option(TOP, "Cycle " + cycle + ": ^3" + level.robot[getDvarInt("icestart_cycle_" + cycle)], ::increment_int, "icestart_cycle_" + cycle, array(0, 3));
						}
			}

			if(level.gamemode == "fullgame")
			{
				TOP="cycles";
				create_option(self.menu_tree["menu"], ">Robot Cycles", ::enter_menu, TOP, "Cycles");
					create_menu(TOP, self.menu_tree["menu"], "Cycles");
						create_option(TOP, "All random", scripts\zm\origins_menu\fullgame::fullgame_all_random_cycles);
						create_option(TOP, "Rain fire: ^3" + level.robot[getDvarInt("fullgame_rain_robot")], ::increment_int, "fullgame_rain_robot", array(0, 3));
						for( cycle = 1; cycle <= level.custom_cycles; cycle++)
						{
							create_option(TOP, "Cycle " + cycle + ": ^3" + level.robot[getDvarInt("fullgame_cycle_" + cycle)], ::increment_int, "fullgame_cycle_" + cycle, array(0, 3));
						}

				TOP="feet";
				create_option(self.menu_tree["menu"], ">Robot Feet", ::enter_menu, TOP, "Feet");
					create_menu(TOP, self.menu_tree["menu"], "Feet");
						create_option(TOP, "All random", scripts\zm\origins_menu\fullgame::fullgame_all_random_feet);
						create_option(TOP, "Rain foot: ^3" + level.foot[getDvarInt("fullgame_rain_foot")], ::increment_int, "fullgame_rain_foot", array(0, 2));
						for( cycle = 1; cycle <= level.custom_cycles; cycle++)
						{
							create_option(TOP, "Cycle " + cycle + ": ^3" + level.foot[getDvarInt("fullgame_foot_" + cycle)], ::increment_int, "fullgame_foot_" + cycle, array(0, 2));
						}

				TOP="templars";
				create_option(self.menu_tree["menu"], ">Templars", ::enter_menu, TOP, "Templars");
					create_menu(TOP, self.menu_tree["menu"], "Templars");
						D1="temps_1";
						create_option(TOP, ">Templars I", ::enter_menu, D1, "Temps I");
						create_menu(D1, TOP, "Templars I");
							create_option(D1, "Reset", ::fullgame_reset_templar, 1);
							for(i = 1; i < 7; i++)
								create_option(D1, "Gen " + i + " " + dvarint_compare("fullgame_temps_1_gen_" + i), ::toggle_binary, "fullgame_temps_1_gen_" + i);
						D2="templars_2";
						create_option(TOP, ">Templars II", ::enter_menu, D2, "Temps II");
						create_menu(D2, TOP, "Templars II");
							create_option(D2, "Reset", ::fullgame_reset_templar, 2);
							for(i = 1; i < 7; i++)
								create_option(D2, "Gen " + i + " " + dvarint_compare("fullgame_temps_2_gen_" + i), ::toggle_binary, "fullgame_temps_2_gen_" + i);
						D3="templars_3";
						create_option(TOP, ">Templars III", ::enter_menu, D3, "Temps III");
						create_menu(D3, TOP, "Templars III");
							create_option(D3, "Reset", ::fullgame_reset_templar, 3);
							for(i = 1; i < 7; i++)
								create_option(D3, "Gen " + i + " " +  dvarint_compare("fullgame_temps_3_gen_" + i), ::toggle_binary, "fullgame_temps_3_gen_" + i);
					create_option(TOP, "Templar II: ^3" + fullgame_temp_round_to_text(2), scripts\zm\origins_menu\fullgame::fullgame_toggle_templar_round, 2);
					create_option(TOP, "Templar III: ^3" + fullgame_temp_round_to_text(3), scripts\zm\origins_menu\fullgame::fullgame_toggle_templar_round, 3);

				TOP="vinyls";
				create_option(self.menu_tree["menu"], ">Vinyl Locations", ::enter_menu, TOP, "Vinyls");
					create_menu(TOP, self.menu_tree["menu"], "Vinyls");
						create_option(TOP, "Gramophone: ^3" + fullgame_gram_to_text(), ::increment_int, "fullgame_gramophone_vinyl_player_loc", array(0,2));
						create_option(TOP, "Master: ^3" + fullgame_disk_to_text("master"), ::increment_int, "fullgame_gramophone_vinyl_master_loc", array(0,3));
						create_option(TOP, "Ice: ^3" + fullgame_disk_to_text("ice"), ::increment_int, "fullgame_gramophone_vinyl_ice_loc", array(0,3));
						create_option(TOP, "Wind: ^3" + fullgame_disk_to_text("air"), ::increment_int, "fullgame_gramophone_vinyl_air_loc", array(0,3));
						create_option(TOP, "Fire: ^3" + fullgame_disk_to_text("fire"), ::increment_int, "fullgame_gramophone_vinyl_fire_loc", array(0,3));
						create_option(TOP, "Lightning: ^3" + fullgame_disk_to_text("elec"), ::increment_int, "fullgame_gramophone_vinyl_elec_loc", array(0,3));
						create_option(TOP, "Reset all", scripts\zm\origins_menu\fullgame::fullgame_reset_vinyls_loc);

				TOP="parts";
				create_option(self.menu_tree["menu"], ">Part Locations", ::enter_menu, TOP, "Parts");
					create_menu(TOP, self.menu_tree["menu"], "Parts");
						create_option(TOP, "Maxis Body: ^3" + fullgame_maxis_to_text("body"), ::increment_int, "fullgame_maxis_body", array(0,3));
						create_option(TOP, "Maxis Engine: ^3" + fullgame_maxis_to_text("engine"), ::increment_int, "fullgame_maxis_engine", array(0,3));
						create_option(TOP, "Maxis Brain", ::test);
						create_option(TOP, "Shield Gen2: ^3" + fullgame_shield_to_text("gen2"), ::increment_int, "fullgame_shield_gen2", array(0,3));
						create_option(TOP, "Shield Gen3: ^3" + fullgame_shield_to_text("gen3"), ::increment_int, "fullgame_shield_gen3", array(0,3));
						create_option(TOP, "Shield NML: ^3" + fullgame_shield_to_text("nml"), ::increment_int, "fullgame_shield_nml", array(0,3));
						create_option(TOP, "Reset all", scripts\zm\origins_menu\fullgame::fullgame_reset_part_loc);

				TOP="randomness";
				create_option(self.menu_tree["menu"], ">Randomness", ::enter_menu, TOP, "RNG");
					create_menu(TOP, self.menu_tree["menu"], "RNG");
						E1="digs";
						create_option(TOP, ">Dig Settings", ::enter_menu, E1, "Digs");
						create_menu(E1, TOP, "Digs");
							create_option(E1, "Trenches: " + dvarint_compare("fullgame_bunker_dig", "^3early", "^3normal"), ::toggle_binary, "fullgame_bunker_dig");
							create_option(E1, "NML: " + dvarint_compare("fullgame_nml_dig", "^3early", "^3normal"), ::toggle_binary, "fullgame_nml_dig");
							create_option(E1, "Church: " + dvarint_compare("fullgame_village_dig", "^3early", "^3normal"), ::toggle_binary, "fullgame_village_dig");
							create_option(E1, "First Dig: ^3" + fullgame_first_dig_text(), ::increment_int, "fullgame_1st_dig", array(0,9));
							create_option(E1, "Ending Blood: " + dvarint_compare("fullgame_blood_dig"), ::toggle_binary, "fullgame_blood_dig");
							create_option(E1, "Round 10 Spots: " + dvarint_compare("fullgame_r10_digs"), ::toggle_binary, "fullgame_r10_digs");
							create_option(E1, "Ending Spots: " + dvarint_compare("fullgame_ending_digs"), ::toggle_binary, "fullgame_ending_digs");
							create_option(E1, "Early Ice Spots: " + dvarint_compare("fullgame_early_ice"), ::toggle_binary, "fullgame_early_ice");
							create_option(E1, "Round 4 Snow: " + dvarint_compare("fullgame_r4_snow"), ::toggle_binary, "fullgame_r4_snow");
							create_option(E1, "Points Always 250: " + dvarint_compare("fullgame_250_digs"), ::toggle_binary, "fullgame_250_digs");
						E2="discs";
						create_option(TOP, ">Mound discs", ::enter_menu, E2, "Discs");
						create_menu(E2, TOP, "Discs");
							create_option(E2, "Optimal Discs", ::fullgame_perfect_discs);
							create_option(E2, "Worst Discs", ::fullgame_worst_discs);
							create_option(E2, "Random Discs", ::fullgame_random_discs);
							E21 = "scramb_1";
							create_option(E2, ">Scramble I " + fullgame_scramble_text_line(1), ::enter_menu, E21, "Disc I");
							create_menu(E21, E2, "Disc I");
								create_option(E21, "Random", ::fullgame_reset_scramble, 1);
								create_option(E21, "Top: " + fullgame_scramble_text(3, 1), ::fullgame_flip_scramble, 3, 1);
								create_option(E21, "2nd: " + fullgame_scramble_text(2, 1), ::fullgame_flip_scramble, 2, 1);
								create_option(E21, "3rd: " + fullgame_scramble_text(1, 1), ::fullgame_flip_scramble, 1, 1);
								create_option(E21, "Bot: " + fullgame_scramble_text(0, 1), ::fullgame_flip_scramble, 0, 1);
							E22 = "scramb_2";
							create_option(E2, ">Scramble II " + fullgame_scramble_text_line(2), ::enter_menu, E22, "Disc II");
							create_menu(E22, E2, "Disc II");
								create_option(E22, "Random", ::fullgame_reset_scramble, 2);
								create_option(E22, "Top: " + fullgame_scramble_text(3, 2), ::fullgame_flip_scramble, 3, 2);
								create_option(E22, "2nd: " + fullgame_scramble_text(2, 2), ::fullgame_flip_scramble, 2, 2);
								create_option(E22, "3rd: " + fullgame_scramble_text(1, 2), ::fullgame_flip_scramble, 1, 2);
								create_option(E22, "Bot: " + fullgame_scramble_text(0, 2), ::fullgame_flip_scramble, 0, 2);
							E23 = "scramb_3";
							create_option(E2, ">Scramble III " + fullgame_scramble_text_line(3), ::enter_menu, E23, "Disc III");
							create_menu(E23, E2, "Disc III");
								create_option(E23, "Random", ::fullgame_reset_scramble, 3);
								create_option(E23, "Top: " + fullgame_scramble_text(3, 3), ::fullgame_flip_scramble, 3, 3);
								create_option(E23, "2nd: " + fullgame_scramble_text(2, 3), ::fullgame_flip_scramble, 2, 3);
								create_option(E23, "3rd: " + fullgame_scramble_text(1, 3), ::fullgame_flip_scramble, 1, 3);
								create_option(E23, "Bot: " + fullgame_scramble_text(0, 3), ::fullgame_flip_scramble, 0, 3);
							E24 = "scramb_4";
							create_option(E2, ">Scramble IV " + fullgame_scramble_text_line(4), ::enter_menu, E24, "Disc IV");
							create_menu(E24, E2, "Disc IV");
								create_option(E24, "Random", ::fullgame_reset_scramble, 4);
								create_option(E24, "Top: " + fullgame_scramble_text(3, 4), ::fullgame_flip_scramble, 3, 4);
								create_option(E24, "2nd: " + fullgame_scramble_text(2, 4), ::fullgame_flip_scramble, 2, 4);
								create_option(E24, "3rd: " + fullgame_scramble_text(1, 4), ::fullgame_flip_scramble, 1, 4);
								create_option(E24, "Bot: " + fullgame_scramble_text(0, 4), ::fullgame_flip_scramble, 0, 4);
						E3="fizz";
						create_option(TOP, ">Wunderfizz", ::enter_menu, E3, "Fizz");
						create_menu(E3, TOP, "Fizz");
							create_option(E3, "Location: ^3" + fullgame_fizz_loc_text(), ::increment_int, "fullgame_fizz_location", array(0,2));
							create_option(E3, "Fizz 1: " + fullgame_fizz_hit_text(1), ::increment_int, "fullgame_fizz_1", array(0,9));
							create_option(E3, "Fizz 2: " + fullgame_fizz_hit_text(2), ::increment_int, "fullgame_fizz_2", array(0,9));
						E4="panzer";
						create_option(TOP, ">Panzer", ::enter_menu, E4, "Panzer");
						create_menu(E4, TOP, "Panzer");
							create_option(E4, "Panzer 2: ^3" + dvarint_compare("fullgame_panzer_2", getDvarInt("fullgame_panzer_2") + " rounder", "random"), scripts\zm\origins_menu\fullgame::fullgame_cycle_panzer, 2);
							create_option(E4, "Panzer 3: ^3" + dvarint_compare("fullgame_panzer_3", getDvarInt("fullgame_panzer_3") + " rounder", "random"), scripts\zm\origins_menu\fullgame::fullgame_cycle_panzer, 3);
							create_option(E4, "Panzer rain delay: ^3" + fullgame_mechz_rain_text(), ::fullgame_mechz_rain_rng);
							create_option(E4, "-panzer blood", ::n_test);


						E5="box";
						create_option(TOP, ">Mystery Box", ::enter_menu, E5, "Box");
						create_menu(E5, TOP, "box");
							create_option(E5, "Location: ^3" + fullgame_box_loc_text(), ::increment_int, "fullgame_box_location", array(0,2));
							create_option(E5, "Box tier: ^3" + fullgame_box_tier_text(), ::increment_int, "fullgame_box_tier", array(0,6));
							create_option(E5, "MP40 no-stock: ^3" + dvarint_compare("fullgame_box_no_stock_mp40"), ::toggle_binary, "fullgame_box_no_stock_mp40");
							create_option(E5, "-hit 1", ::n_test);
							create_option(E5, "-hit 2", ::n_test);
						E6="presets";
						create_option(TOP, ">Game Presets", ::enter_menu, E6, "Presets");
						create_menu(E6, TOP, "Presets");
							create_option(E6, "-29 rng", ::n_test);
							create_option(E6, "-perfect 29 rng", ::n_test);
							create_option(E6, "-f4d rng", ::n_test);
			}

			TOP="HUD";
			create_option(self.menu_tree["menu"], ">HUD", ::enter_menu, TOP, "HUD");
				create_menu(TOP, self.menu_tree["menu"], "HUD");

					if(level.gamemode == "fullgame") {
						create_option(TOP, "Cycle display ms: " + dvarint_compare("fullgame_cycle_tracker_ms"), ::toggle_binary, "fullgame_cycle_tracker_ms");
						create_option(TOP, "Cycle display: " + dvarint_compare("fullgame_cycle_tracker"), ::fullgame_toggle_cycle_display);
					}
					create_option(TOP, "OOPA Print: " + dvarint_compare("basegame_oopa_hud"), ::toggle_binary, "basegame_oopa_hud");
					create_option(TOP, "Despawn Print: " + dvarint_compare("basegame_despawns"), ::toggle_binary, "basegame_despawns");
					create_option(TOP, "Zombies Spawned: " + dvarint_compare("basegame_hud_spawned"), scripts\zm\origins_menu\basegame::toggle_spawned);
					create_option(TOP, "Zombies Remaning: " + dvarint_compare("basegame_hud_remaning"), scripts\zm\origins_menu\basegame::toggle_remaining);
					create_option(TOP, "Point based: " + pointbased_text(), scripts\zm\origins_menu\basegame::toggle_pointbased);

					create_option(TOP, "-Health", ::n_test);
					create_option(TOP, "-Velocity", ::n_test);

			TOP="cheats";
			create_option(self.menu_tree["menu"], ">Cheats", ::enter_menu, TOP, "Cheats");
				create_menu(TOP, self.menu_tree["menu"], "Cheats");
					create_option(TOP, "OOPA: " + dvarint_compare("basegame_oopa"), ::toggle_binary, "basegame_oopa");
					create_option(TOP, "Demigod: " + int_compare(self.demigod), ::toggle_demigod);
					F1 = "drops";
					create_option(TOP, ">Drops", ::enter_menu, F1, "Drops");
						create_menu(F1, TOP, "Drops");
							create_option(F1, "Nuke", ::give_drop, "nuke");
							create_option(F1, "Max Ammo", ::give_drop, "full_ammo");
							create_option(F1, "Double Points", ::give_drop, "double_points");
							create_option(F1, "Insta kill", ::give_drop, "insta_kill");
							create_option(F1, "Zombie Blood", ::give_drop, "zombie_blood");
							create_option(F1, "Fire Sale", ::give_drop, "fire_sale");
							create_option(F1, "Blood Money", ::give_drop, "bonus_points_player");
					create_option(TOP, "Pap weapon", ::upgrade_weapon);
					create_option(TOP, "Max Points", ::set_points, 1000000);

	}
	if(self isHost() && level.gamemode == "fullgame")
	{
		create_option(self.menu_tree["menu"], ">Players", ::enter_menu, "PlayersMenu", "Players");
			create_menu("PlayersMenu", self.menu_tree["menu"], "Players");
				for (i = 0; i < 18; i++)
					create_menu("pOpt " + i, "PlayersMenu", "");
}
}

initialize_menu()
{
	self endon("disconnect");
	level endon("game_ended");

	self.menu = spawnstruct();

	self.menu_tree = [];
	self.menu_tree["menu"] = level.gamemode;

	self.curent_menu = self.menu_tree["menu"];
	self.current_title = self.menu_tree["menu"];
	self.demigod = 0;

	self build_menu_tree();
	self initialize_menu_variables();

	while(true)
	{
		if(get_open_buttons() && !isDefined(self.menu.open) && flag("menu_active"))
		{
			level_print("menu open call");
			self thread open_menu();
			self playlocalSound("");
			wait .15;
		}
		if(self menu_open())
		{
			if(self actionslotfourbuttonpressed())
			{
				if(isDefined(self.menu.previousmenu[self.curent_menu]))
					self enter_menu(self.menu.previousmenu[self.curent_menu], self.menu.subtitle[self.menu.previousmenu[self.curent_menu]]);
				else
					self thread close_menu();

				//wait 0.05;
			}
			else if(self actionslotonebuttonpressed() || self actionslottwobuttonpressed()) //menu scrolling
			{
				if(!self actionslotonebuttonpressed() || !self actionslottwobuttonpressed())
				{
					self.menu.curs[self.curent_menu] += self actionslottwobuttonpressed();
					self.menu.curs[self.curent_menu] -= self actionslotonebuttonpressed();
					self update_scrollbar();
					self get_menu_scroll();
					//wait 0.05;
				}
			}
			else if(  false /*self actionslotfourbuttonpressed()*/ )
			{
                //slider
				curent_menu = self.curent_menu;
				curs = self.menu.curs[self.curent_menu];

				if(isDefined(self.menu.menuslider[curent_menu][curs]))
				{
					if(!isDefined(self.menu.slider[curent_menu + "_cursor_" + curs]))
						self.menu.slider[curent_menu + "_cursor_" + curs] = 1;

					if(!self actionslotfourbuttonpressed())
						self.menu.slider[curent_menu + "_cursor_" + curs]++;

                    /* BACK SCROLL
                    if(!self actionslotfourbuttonpressed())
						self.menu.slider[curent_menu + "_cursor_" + curs]--;
                    */

					if(self.menu.slider[curent_menu + "_cursor_" + curs] > self.menu.menuslider[curent_menu][curs].size-1)
						self.menu.slider[curent_menu + "_cursor_" + curs] = 1;
					if(self.menu.slider[curent_menu + "_cursor_" + curs] < 1)
						self.menu.slider[curent_menu + "_cursor_" + curs] = self.menu.menuslider[curent_menu][curs].size-1;

					self update_menu_text(self.menu.menuslider[ curent_menu ][ curs ][ 0 ]  + self.menu.menuslider[ curent_menu ][ curs ][ self.menu.slider[curent_menu + "_cursor_" + curs] ]);
					//wait 0.05;
				}
			}
			else if(self actionslotthreebuttonpressed())
			{
				curent_menu = self.curent_menu;
				curs = self.menu.curs[self.curent_menu];

				if(!isDefined(self.menu.slider[curent_menu + "_cursor_" + curs]))
					self.menu.slider[curent_menu + "_cursor_" + curs] = 1;

				if(isDefined(self.menu.menuslider[curent_menu][curs]))
					self thread [[self.menu.menufunc[self.curent_menu][self.menu.curs[self.curent_menu]]]](self.menu.menuslider[ curent_menu ][ curs ][ self.menu.slider[curent_menu + "_cursor_" + curs] ], self.menu.menuinput[self.curent_menu][self.menu.curs[self.curent_menu]], self.menu.menuinput1[self.curent_menu][self.menu.curs[self.curent_menu]]);
				else
					self thread [[self.menu.menufunc[self.curent_menu][self.menu.curs[self.curent_menu]]]](self.menu.menuinput[self.curent_menu][self.menu.curs[self.curent_menu]], self.menu.menuinput1[self.curent_menu][self.menu.curs[self.curent_menu]]);
				//wait 0.05;
			}
		}
		wait .05;
	}
}

create_menu(Menu, prevmenu, menutitle)
{
    self.menu.getmenu[Menu] = Menu;
    self.menu.scrollerpos[Menu] = 0;
    self.menu.curs[Menu] = 0;
    self.menu.menucount[Menu] = 0;
    self.menu.subtitle[Menu] = menutitle;
    self.menu.previousmenu[Menu] = prevmenu;
}

create_option(Menu, Text, Func, arg1, arg2, toggle)
{
    Menu = self.menu.getmenu[Menu];
    Num = self.menu.menucount[Menu];
    self.menu.menuopt[Menu][Num] = Text;
    self.menu.menufunc[Menu][Num] = Func;
    self.menu.menuinput[Menu][Num] = arg1;
    self.menu.menuinput1[Menu][Num] = arg2;
    if(isDefined(toggle))
    	self.menu.toggle[Menu][Num] = toggle;
    else
    	self.menu.toggle[Menu][Num] = undefined;
    self.menu.menucount[Menu]++;
}

add_slider(Menu, Text, Slider, Func, arg1, arg2)
{
    Menu = self.menu.getmenu[Menu];
    Num = self.menu.menucount[Menu];

    if(isDefined(slider))
    	self.menu.menuslider[Menu][Num] = strTok(slider,";");
    self.menu.menuopt[Menu][Num] = Text;
    self.menu.menufunc[Menu][Num] = Func;
    self.menu.menuinput[Menu][Num] = arg1;
    self.menu.menuinput1[Menu][Num] = arg2;
    self.menu.menucount[Menu]++;
}

initialize_menu_variables()
{
	if(!isDefined(self.Candy))
		self.Candy = [];

	//self.Candy["menu_colour"] = (0, 0, 255);
	self.Candy["menu_colour"] = (0.54, 0.17, 0.89);
	self.Candy["opt_colour"] = (1,1,1);
	self.Candy["bg_colour"] = (0,0,0);
}

overflow_fix()
{
	level endon("game_ended");
	level endon("host_migration_begin");

	level.test = createServerFontString("default", 1);
	level.test setText("overflow");
	level.test.alpha = 0;

	max_string_count = 55;

	while(true)
	{
		level waittill("textset");

		if(level.string_count >= max_string_count)
		{
			level.test ClearAllTextAfterHudElem();
			level.string_count = 0;

            //global stings refresh, robots, wind bulbs etc

			foreach(player in level.players)
			{
				if(player menu_open())
				{
					player refresh_title();
					player enter_menu(player.curent_menu, player.current_title);
					player.helptext set_safe_text("^7UP/DOWN ^3[{+actionslot 1}]/[{+actionslot 2}]\n^7ENTER/EXIT ^3[{+actionslot 3}]/[{+actionslot 4}]");
				}
			}
		}

		//Global elem
		switch(level.gamemode)
		{
			case "fullgame": fullgame_refresh(); break;
			case "panzprac": panzprac_refresh(); break;
			case "icestart": icestart_refresh(); break;
			case "windstart": windstart_refresh(); break;
		}
		basegame_refresh();
	}
}

open_menu()
{
	self.ignoreme = 1;
	self.menu.open = true;
	self.recreateOptions = true;
	self open_nav_text(0, 0);
	self draw_menu();
	self refresh_menu();
	self update_scrollbar();
	self.recreateOptions = undefined;
}

close_menu()
{
	self.ignoreme = 0;
	self.menu.open = undefined;
	self.helptext destroy();
	self destroy_menu(true);
}

draw_menu()
{
	self.menu_tree["HUD"]["Background"] = self create_rectangle("CENTER","CENTER",200,-30,180,190,self.Candy["bg_colour"],"lui_soldier",0,0);
	self.menu_tree["HUD"]["Background"] thread hud_fade(.5, .1);

	self.menu_tree["HUD"]["Leftline"] = self create_rectangle("CENTER","CENTER",110,-30,2,190,self.Candy["menu_colour"],"white",5,0);
	self.menu_tree["HUD"]["Leftline"] thread hud_fade(1, .1);

	self.menu_tree["HUD"]["Rightline"] = self create_rectangle("CENTER","CENTER",290,-30,2,190,self.Candy["menu_colour"],"white",5,0);
	self.menu_tree["HUD"]["Rightline"] thread hud_fade(1, .1);

	self.menu_tree["HUD"]["Bottomline"] = self create_rectangle("CENTER","CENTER",201,64,180,2,self.Candy["menu_colour"],"white",5,0);
	self.menu_tree["HUD"]["Bottomline"] thread hud_fade(1, .1);

	self.menu_tree["HUD"]["Topline"] = self create_rectangle("CENTER","CENTER",200,-131,182,18,self.Candy["menu_colour"],"white",5,0);//menu line -124
	self.menu_tree["HUD"]["Topline"] thread hud_fade(1, .1);

	self.menu_tree["HUD"]["Title"] = self draw_text_title(level.menu_title,"default",1.4,"LEFT","CENTER",114,-130,(1,1,1),0,10);
	self.menu_tree["HUD"]["SubTitle"] = self draw_text_title("","big",1.5,"LEFT","CENTER",230,-130,(1,1,1),0,10);

	self refresh_title();
	self draw_text(self.current_title);
}

draw_text(menu)
{
	self.menu_tree["HUD"]["SubTitle"] set_safe_text(menu);

	if(isDefined(self.recreateOptions))
		for(i = 0; i < 7; i++)
			self.menu_tree["OPT"][i] = draw_text_title("","small",1.4,"LEFT","CENTER",117,-103+(i*23),self.Candy["opt_colour"],1,10);
}

update_scrollbar()
{
	if(self.menu.curs[self.curent_menu]<0)
		self.menu.curs[self.curent_menu] = self.menu.menuopt[self.curent_menu].size-1;

	if(self.menu.curs[self.curent_menu]>self.menu.menuopt[self.curent_menu].size-1)
		self.menu.curs[self.curent_menu] = 0;

	if(!isDefined(self.menu.menuopt[self.curent_menu][self.menu.curs[self.curent_menu]-3])||self.menu.menuopt[self.curent_menu].size<=7)
	{
    	for(i = 0; i < 7; i++)
    	{
	    	if(isDefined(self.menu.menuopt[self.curent_menu][i]))
				self.menu_tree["OPT"][i] set_safe_text(self.menu.menuopt[self.curent_menu][i]);
			else
				self.menu_tree["OPT"][i] set_safe_text("");

			if(self.menu.curs[self.curent_menu] == i)
				self.menu_tree["OPT"][i].color = self.Candy["menu_colour"];
			else
				self.menu_tree["OPT"][i].color = self.Candy["opt_colour"];
		}
	}
	else
	{
	    if(isDefined(self.menu.menuopt[self.curent_menu][self.menu.curs[self.curent_menu]+3]))
	    {
			xePixTvx = 0;
			for(i=self.menu.curs[self.curent_menu]-3;i<self.menu.curs[self.curent_menu]+4;i++)
			{
			    if(isDefined(self.menu.menuopt[self.curent_menu][i]))
					self.menu_tree["OPT"][xePixTvx] set_safe_text(self.menu.menuopt[self.curent_menu][i]);
				else
					self.menu_tree["OPT"][xePixTvx] set_safe_text("");

				if(self.menu.curs[self.curent_menu]==i)
					self.menu_tree["OPT"][xePixTvx].color = self.Candy["menu_colour"];
				else
					self.menu_tree["OPT"][xePixTvx].color = self.Candy["opt_colour"];

				xePixTvx ++;
			}
		}
		else
		{
			for(i = 0; i < 7; i++)
			{
				self.menu_tree["OPT"][i] set_safe_text(self.menu.menuopt[self.curent_menu][self.menu.menuopt[self.curent_menu].size+(i-7)]);

         		if(self.menu.curs[self.curent_menu]==self.menu.menuopt[self.curent_menu].size+(i-7))
					self.menu_tree["OPT"][i].color = self.Candy["menu_colour"];
				else
					self.menu_tree["OPT"][i].color = self.Candy["opt_colour"];
			}
		}
	}
}

open_nav_text(x, y)
{
	self.helptext = self createfontString("hudbig", 1.5);
	self.helptext setpoint("right", "center", 155, 75);
	self.helptext set_safe_text("^7UP/DOWN ^3[{+actionslot 1}]/[{+actionslot 2}]\n^7ENTER/EXIT ^3[{+actionslot 3}]/[{+actionslot 4}]");
	self.helptext.alpha = 1;
}



enter_menu(menu, title)
{
	for(i = 0; i < self.menu_tree["OPT"].size; i++)
		self.menu_tree["OPT"][i].alpha = 0;
	self.menu_tree["Title"].alpha = 0;

	if(menu == self.menu_tree["menu"])
		self thread draw_text(self.menu_tree["menu"]);
	else
		self thread draw_text(title);

	if(menu == "PlayersMenu")
	{
		self player_menu();
		self thread draw_text("Players");
	}
	else
		self thread draw_text(title);

	self.curent_menu = menu;
	self.current_title = title;

	self.menu.scrollerpos[menu] = self.menu.curs[menu];
	self.menu.curs[menu] = self.menu.scrollerpos[menu];

	for(i = 0; i < self.menu_tree["OPT"].size; i++)
		self.menu_tree["OPT"][i].alpha = 1;
	self.menu_tree["SubTitle"].alpha = 1;

	self refresh_title();
	self update_scrollbar();
}

refresh_title()
{
	if(isDefined(self.menu_tree["HUD"]["Title"]))
		self.menu_tree["HUD"]["Title"] destroy();

	self.menu_tree["HUD"]["Title"] = self draw_text_title(level.menu_title,"default",1.4,"LEFT","CENTER",114,-130,(1,1,1),1,10);
	self.menu_tree["HUD"]["Title"].glowAlpha = 1;
	self.menu_tree["HUD"]["Title"].glowColor = self.Candy["menu_colour"];
	self.menu_tree["HUD"]["SubTitle"] thread hud_fade(1, .1);
}

destroy_menu(all)
{
	if(isDefined(all))
	{
		for(i=0;i<self.menu_tree["OPT"].size;i++)
		self.menu_tree["OPT"][i] destroy();

		self destroy_array(self.menu_tree["HUD"]);
	}
}

refresh_menu()
{
	savedCurs = [];
	foreach(key in getArrayKeys(self.menu.curs))
		savedCurs[key] = self.menu.curs[key];
	self build_menu_tree();
	foreach(key in getArrayKeys(savedCurs))
		self.menu.curs[key] = savedCurs[key];
	if(self menu_open())
	{
		self refresh_title();
		self update_scrollbar();
	}
}

menu_open()
{
	if(isDefined(self.has_menu) && isDefined(self.menu.open))
		return true;
	return false;
}

set_safe_text(text)
{
	level.string_count += 1;
	level notify("textset");
	self setText(text);
}

notify_label_text( num )
{
	val = 1;
	if(isDefined(num))
		val = num;

	for(i = 0; i < val; i++)
	{
		level.string_count += val;
		level notify("textset");
	}
}

hud_fade(alpha, time)
{
	self fadeOverTime(time);
	self.alpha = alpha;
	wait time;
}

update_menu_text(text,menu,pointer)
{
	if(!isDefined(menu)) menu = self.curent_menu;
	if(!isDefined(pointer)) pointer = self.menu.curs[menu];
	self.menu_tree["options"][pointer] set_safe_text(text);
	self.menu.menuopt[menu][pointer] = text;
	self thread update_scrollbar();
}

player_menu()
{
	self endon("disconnect");

	self.menu.menucount["PlayersMenu"] = 0;

	for (i = 0; i < 18; i++)
	{
		player = level.players[i];
		playerName = get_player_name(player);
		playersizefixed = level.players.size - 1;

        if(self.menu.curs["PlayersMenu"] > playersizefixed)
        {
            self.menu.scrollerpos["PlayersMenu"] = playersizefixed;
            self.menu.curs["PlayersMenu"] = playersizefixed;
        }

		create_option("PlayersMenu", "["+player.status+"^7] " + playerName, ::enter_menu, "pOpt " + i, "["+player.status+"^7] " + playerName);
			create_menu("pOpt " + i, "PlayersMenu", "["+player.status+"^7] " + playerName);
				create_option("pOpt " + i, "Status", ::enter_menu, "pOpt " + i + "_3", "["+player.status+"^7] " + playerName);
					create_menu("pOpt " + i + "_3", "pOpt " + i, "["+player.status+"^7] " + playerName);
						create_option("pOpt " + i + "_3", "Verify", ::test, player, "Verified");

		if(!player isHost())
		{
				create_option("pOpt " + i, "OPT", ::enter_menu, "pOpt " + i + "_2", "[" +player.status+ "^7] " +playerName);
					create_menu("pOpt " + i + "_2", "pOpt " + i, "[" +player.status+ "^7] " +playerName);
						create_option("pOpt " + i + "_2", "Test", ::test, player);
		}
	}
}

god_mode_bool()
{
	if(!isDefined(self.God))
	{
		self.God = true;
		self EnableInvulnerability();
	}
	else
	{
		self.God = undefined;
		self DisableInvulnerability();
	}
	self refresh_menu();
}


draw_text_title(text, font, fontScale, align, relative, x, y, color, alpha, sort)
{
	hud = self createFontString(font, fontScale);
	hud setPoint(align, relative, x, y);
	hud.color = color;
	hud.alpha = alpha;
	hud.hideWhenmenu_open = true;
	hud.sort = sort;
	hud.foreground = true;
	if(self issplitscreen()) hud.x += 100;
	hud set_safe_text(text);
	return hud;
}

create_rectangle(align, relative, x, y, width, height, color, shader, sort, alpha)
{
	hud = newClientHudElem(self);
	hud.elemType = "bar";
	hud.children = [];
	hud.sort = sort;
	hud.color = color;
	hud.alpha = alpha;
	hud.hideWhenmenu_open = true;
	hud.foreground = true;
	hud setParent(level.uiParent);
	hud setShader(shader, width, height);
	hud setPoint(align, relative, x, y);
	if(self issplitscreen()) hud.x += 100;
	return hud;
}

hudMoveY(y, time)
{
	self moveOverTime(time);
	self.y = y;
	wait time;
}

hudMoveX(x, time)
{
	self moveOverTime(time);
	self.x = x;
	wait time;
}

get_menu_count()
{
	return self.menu.scrollerpos[self.curent_menu][self.menu.curs[self.curent_menu]];
}

get_menu_scroll()
{
	self iprintln("Menu Scroll ^3" +get_menu_count());
}

bool_to_text(bool, string1, string2)
{
	if(isDefined(bool) && bool)
		return string1;
	return string2;
}

n_test( e )
{
	return self iprintln("Not implemented");
}

test( e )
{
	if(isDefined( e ))
		return self iprintln( e );
	return self iprintln("you have no brain?");
}

int_test(value)
{
	self iprintln("Int is: ^2" +value);
}

debugexit()
{
	exitlevel(false);
}

bool_test()
{
	if(!isDefined(self.bool))
	{
		self.bool = true;
		self iprintln("Test: ^2On");
	}
	else
	{
		self.bool = undefined;
		self iprintln("Test: ^1Off");
	}

	self refresh_menu();
}

fast_quit()
{
    //level waittill_any_return("end_game", "game_ended");
    KillServer();
}

divide_color(c1,c2,c3)
{
	return(c1 / 255, c2 / 255, c3 / 255);
}

get_menu_name()
{
	return self.menu.getmenu[self.curent_menu][self.menu.curs[self.curent_menu]];
}

get_menu_function()
{
	return self.menu.menufunc[self.curent_menu][self.menu.curs[self.curent_menu]];
}

get_menu_option()
{
	return self.menu.menuopt[self.curent_menu][self.menu.curs[self.curent_menu]];
}

gamemode_color( mode )
{
	if(level.gamemode == mode)
		return "^9[^3live^9]";
	else
		return "";
}

get_open_buttons()
{
	return (self meleebuttonpressed() && self secondaryoffhandbuttonpressed());
}

level_print( text )
{
	print(text);
}