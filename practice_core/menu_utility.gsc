#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\gametypes_zm\_hud_message;
#include maps\mp\zombies\_zm_weapons;

#include scripts\zm\practice_core\basegame;
#include scripts\zm\practice_core\menu_base;

getCFG( string )
{
    return level.mode_cfg[string];
}

setCFG( string, val, write)
{
    level.mode_cfg[string] = val;
    if(write || !isdefined(write))
    write_config();
}

read_config( file_name )
{
    cfg_settings = [];

    config_handle = fs_fopen(file_name, "read");
    settings = fs_read(config_handle);

    foreach(setting in strtok(settings, "\n"))
    {
        split = strtok(setting, "=");
        cfg_settings[split[0]] = split[1];
    }

    fs_fclose(config_handle);

    return cfg_settings;
}

write_config( cfg_array, file_name )
{
    data = "";

    if(isDefined(cfg_array))
    {
        foreach(setting in getarraykeys(cfg_array))
        {
            data += setting + "=" + cfg_array[setting] + "\n";
        }
    }

    fs_remove(file_name);

    config_handle = fs_fopen(file_name, "write");
    fs_write(config_handle, data);
    fs_fclose(config_handle);
}

// Returns defaults overlaid with the saved file and creates the file on first run.
cfg_load(file_name, defaults)
{
    if(!fs_testfile(file_name))
    {
        write_config(defaults, file_name);
        return defaults;
    }

    read_cfg = read_config(file_name);
    foreach(setting in getarraykeys(read_cfg))
        defaults[setting] = read_cfg[setting];
    return defaults;
}

mode_cfg_load(name, defaults)
{
    level.mode_cfg_str = level.practice_map.cfg_dir + name + ".cfg";
    // Kept for "Restore default settings" (GSC arrays are copied on assignment).
    level.mode_cfg_defaults = defaults;
    level.mode_cfg = cfg_load(level.mode_cfg_str, defaults);
}

// Omit initialize and run to register a placeholder mode. build_menu(root) adds
// the mode's own menus after Practice Modes. Returns the mode, so the caller can
// add data fields to it.
register_mode(name, label, initialize, run, build_menu)
{
    mode = spawnstruct();
    mode.name = name;
    mode.label = label;
    mode.initialize = initialize;
    mode.run = run;
    mode.build_menu = build_menu;
    level.modes[level.modes.size] = mode;
    return mode;
}

mode_is_implemented(mode)
{
    return isDefined(mode.initialize) && isDefined(mode.run);
}

// Unknown names and placeholders fall back to the first registered mode.
get_mode(name)
{
    for(i = 0; i < level.modes.size; i++)
        if(level.modes[i].name == name && mode_is_implemented(level.modes[i]))
            return level.modes[i];
    return level.modes[0];
}

set_gamemode(mode)
{
    setDvar(level.practice_map.mode_dvar, mode);
    setDvar("timescale", 1);
    map_restart();
}

upgrade_weapon()
{
    baseweapon = get_base_name(self getcurrentweapon());
    weapon = get_upgrade(baseweapon);
    if(isDefined(weapon))
    {
        self takeweapon(baseweapon);
        self giveweapon(weapon, 0, self get_pack_a_punch_weapon_options(weapon));
        self switchtoweapon(weapon);
        self givemaxammo(weapon);
    }
}

get_upgrade(weapon)
{
    if(isDefined(level.zombie_weapons[weapon].upgrade_name) && isDefined(level.zombie_weapons[weapon]))
        return get_upgrade_weapon(weapon, 0 );
    else
        return get_upgrade_weapon(weapon, 1 );
}

play_sound()
{
	self playlocalSound("mus_lau_rank_up");
}

destroy_array(array)
{
	keys=getArrayKeys(array);
	for(a=0;a < keys.size;a++)
		if(isDefined(array[keys[ a ] ][0]))
			for(e=0;e < array[keys[ a ] ].size;e++)
				array[keys[ a ] ][e] destroy();
		else
			array[keys[ a ] ] destroy();
}

get_cfg_int(setting)
{
    // Check mode_cfg first (primary), then fallback to base_cfg
    if(isDefined(level.mode_cfg[setting]))
        return int(level.mode_cfg[setting]);
    else if(isDefined(level.base_cfg[setting]))
        return int(level.base_cfg[setting]);
    else
        return 0; // default fallback
}

get_cfg_float(setting)
{
    if(isDefined(level.mode_cfg[setting]))
        return float(level.mode_cfg[setting]);
    else if(isDefined(level.base_cfg[setting]))
        return float(level.base_cfg[setting]);
    else
        return 0;
}

cfgint_compare(setting, d_true, d_false)
{
    value = get_cfg_int(setting);

    if(isDefined(d_true))
    {
        if(value)   return d_true;
        else        return d_false;
    }
    else
    {
        if(value)   return "^2enabled";
        else        return "^1disabled";
    }
}

int_compare(value, d_true, d_false)
{
    if(isDefined(d_true))
    {
        if(value)   return d_true;
        else        return d_false;
    }
    else
    {
        if(value)   return "^2enabled";
        else        return "^1disabled";
    }
}

cfg_toggle_speedometer()
{
    speed_status = undefined;
    if(self isHost())
    {
        speed_status = cfg_toggle_binary("hud_speed");
    }
    else
    {
        speed_dvar = self.name + "_speedometer";
        speed_status = getdvar(speed_dvar);
        setdvar(speed_dvar, 1 - speed_status);
    }
    
    if(speed_status == 1)
    {
        if(!isDefined(self.speedometer))
            self thread basegame_speedometer();
        else if(isDefined(self.speedometer))
        {
            self notify("kill_speedometer");
            self.speedometer destroy();
            self.speedometer = undefined;
        }
    }
    self refresh_menu();
}

// Cheat: opens every door. A map whose doors need more than triggers sets
// level.practice_map.open_doors to replace this, or open_doors_extra to add steps.
open_all_doors()
{
    if(isDefined(level.practice_map.open_doors))
    {
        self [[ level.practice_map.open_doors ]]();
        return;
    }

    setdvar( "zombie_unlock_all", 1 );
    flag_set( "power_on" );
    players = get_players();
    zombie_doors = getentarray( "zombie_door", "targetname" );

    for ( i = 0; i < zombie_doors.size; i++ )
    {
        zombie_doors[i] notify( "trigger", players[0] );

        if ( is_true( zombie_doors[i].power_door_ignore_flag_wait ) )
            zombie_doors[i] notify( "power_on" );

        wait 0.05;
    }

    zombie_airlock_doors = getentarray( "zombie_airlock_buy", "targetname" );

    for ( i = 0; i < zombie_airlock_doors.size; i++ )
    {
        zombie_airlock_doors[i] notify( "trigger", players[0] );
        wait 0.05;
    }

    zombie_debris = getentarray( "zombie_debris", "targetname" );

    for ( i = 0; i < zombie_debris.size; i++ )
    {
        zombie_debris[i] notify( "trigger", players[0] );
        wait 0.05;
    }

    if ( isdefined( level.practice_map.open_doors_extra ) )
        players[0] [[ level.practice_map.open_doors_extra ]]();

    level notify( "open_sesame" );
    wait 1;
    setdvar( "zombie_unlock_all", 0 );
}


game_time_string(ms = 1, custom_duration)
{
    duration = 0;
    if(isDefined(custom_duration))
    {
        duration = custom_duration;
    }
    else if(isDefined(level.game_start_time))
    {
        duration = getTime() - level.game_start_time;
    }
    else
    {
        return "00:00.00";
    }

    total_sec = int(duration / 1000);
    mn = int(total_sec / 60);           //minutes
    se = total_sec % 60;                //seconds
    ce = ( int(duration) % 1000) / 10;  //centiseconds
    time_string = "";

    //minutes
    if(mn == 0)     { time_string = time_string + "00:"; }
    else if(mn > 9) { time_string = time_string + mn + ":"; }
	else            { time_string = time_string + "0" + mn + ":"; }

    //seconds
	if(se > 9)      { time_string = time_string + se; }
	else            { time_string = time_string + "0" + se; }

    if(ms)
    {
        //centiseconds
        if(ce < 10) { time_string = time_string + ".0" + ce; }
        else        { time_string = time_string + "." + ce; }
    }

	return time_string;
}

set_points( amount )
{
    self.score = amount;
}

demi_god()
{
    self endon( "disable_godmode" );

    while ( true )
    {
        if ( self.health < 999999 )
        {
            self.maxhealth = 999999;
            self.health = self.maxhealth;
        }

        wait 0.05;
    }
}

bool_compare_string(bol, a, b)
{
    if(bol) return a;
    else    return b;
}

int_in_range( val, min, max )
{
    return min <= val && max >= val;
}
