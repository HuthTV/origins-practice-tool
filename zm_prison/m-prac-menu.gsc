#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;

#include scripts\zm\practice_core\basegame;
#include scripts\zm\practice_core\menu_utility;
#include scripts\zm\mob_menu\freeroam;
#include scripts\zm\mob_menu\mob;
#include scripts\zm\mob_menu\mobfullgame;
#include scripts\zm\mob_menu\plane1;
#include scripts\zm\mob_menu\plane2;
#include scripts\zm\mob_menu\plane3;
#inline scripts\zm\mob_menu\mob;

/*##############################################################################
                              Practice modes
##############################################################################*/
// The first mode is the default.
register_modes()
{
	level.modes = [];
	register_mode("mobfullgame", "Fullgame",  ::mobfullgame_initialize, ::mobfullgame_run, ::mobfullgame_build_menu);
	register_mode("plane1",      "Plane I",   ::plane1_initialize,      ::plane1_run,      ::plane1_build_menu);
	register_mode("plane2",      "Plane II",  ::plane2_initialize,      ::plane2_run,      ::plane2_build_menu);
	register_mode("plane3",      "Plane III", ::plane3_initialize,      ::plane3_run,      ::plane3_build_menu);
	register_mode("freeroam",    "Freeroam",  ::freeroam_initialize,    ::freeroam_run,    ::freeroam_build_menu);
}

main()
{
	register_modes();
	practice_main(mob_practice_map(), "DEV M1");
}

init()
{
	practice_init();
}
