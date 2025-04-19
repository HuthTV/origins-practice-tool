#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\gametypes_zm\_hud_message;

#include scripts\zm\origins_menu\menu_utility;
#include scripts\zm\origins_menu\menu_base;

gamemodename_initialize()
{
	replaceFunc(maps\mp\animscripts\zm_utility::wait_network_frame, ::wait_network_frame_fix);
	replaceFunc(maps\mp\zombies\_zm_utility::wait_network_frame, ::wait_network_frame_fix);
}

gamemodename_run()
{
	flag_set("menu_active");
}

gamemodename_refresh()
{

}