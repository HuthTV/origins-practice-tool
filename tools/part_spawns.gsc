#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_zonemgr;

/*##############################################################################
                              Part spawns
##############################################################################*/
// Development tool, separate from the menu build, for checking the names of the
// menu's Part Locations and Vinyl Locations.
//
// To force locations, set the dvar in the console: set oprac_force_spawn 0, then
// map_restart. The menu then spawns every part and vinyl at location 0; walk the
// map to see where they are. Parts have 0-2; vinyls have 0 to their alt count,
// where the last is the original spot. set oprac_force_spawn "" turns it off
// (so does restarting the game). This tool never sets the dvar itself.
//
// It prints each struct and workbench to the console.
// Deploy as scripts\zm\part_spawns.gsc; remove the file to turn it off.

init()
{
	level thread part_spawns_print();
}

part_spawns_print()
{
	flag_wait("initial_blackscreen_passed");

	print("part_spawns: oprac_force_spawn is \"" + getDvar("oprac_force_spawn") + "\"\n");

	pieces = array("equip_dieseldrone_zm_body", "equip_dieseldrone_zm_engine", "tomb_shield_zm_bracket", "tomb_shield_zm_top", "tomb_shield_zm_door");
	foreach(piece in pieces)
		part_spawns_print_structs(piece, getstructarray(piece, "targetname"));

	// A vinyl's own struct has already been moved to the chosen location.
	vinyls = array("vinyl_player", "vinyl_master", "vinyl_ice", "vinyl_air", "vinyl_fire", "vinyl_elec");
	foreach(vinyl in vinyls)
	{
		name = "gramophone_" + vinyl;
		part_spawns_print_structs(name + "_alt", getstructarray(name + "_alt", "targetname"));
		part_spawns_print_structs(name + " (now)", array(getstruct(name, "targetname")));
	}
	// Open-table workbenches (the drone and shield can be built at any of them).
	tables = [];
	foreach(stub in level.a_uts_craftables)
		if(stub.equipname == "open_table" || stub.equipname == "equip_dieseldrone_zm" || stub.equipname == "tomb_shield_zm")
			tables[tables.size] = stub;
	part_spawns_print_structs("workbenches (open_table / drone / shield)", tables);

	iprintln("part_spawns: printed to the console, oprac_force_spawn " + getDvar("oprac_force_spawn"));
}

part_spawns_print_structs(name, structs)
{
	print("part_spawns: " + name + " has " + structs.size + " structs\n");
	foreach(index, s in structs)
	{
		zone = get_zone_from_position(s.origin + (0, 0, 32), 1);
		if(!isDefined(zone)) zone = "none";
		print("part_spawns:   [" + index + "] " + s.origin + " zone " + zone + "\n");
	}
}
