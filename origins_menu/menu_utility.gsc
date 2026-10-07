#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\gametypes_zm\_hud_message;
#include maps\mp\zombies\_zm_weapons;

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

set_gamemode(mode)
{
    setDvar("o_menu_gamemode", mode);
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

get_player_name(player)
{
    playerName = getSubStr(player.name, 0, player.name.size);
    for(i = 0; i < playerName.size; i++)
    {
		if(playerName[i] == "]")
			break;
    }
    if(playerName.size != i)
		playerName = getSubStr(playerName, i + 1, playerName.size);

    return playerName;
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

is_verified()
{
    return true;
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

get_all_parts()
{
    players = get_players();
	players[0] maps\mp\zombies\_zm_craftables::player_get_craftable_piece("elemental_staff_air", "upper_staff");
	players[0] maps\mp\zombies\_zm_craftables::player_get_craftable_piece("elemental_staff_air", "middle_staff");
	players[0] maps\mp\zombies\_zm_craftables::player_get_craftable_piece("elemental_staff_air", "lower_staff");

    players[0] maps\mp\zombies\_zm_craftables::player_get_craftable_piece("elemental_staff_water", "upper_staff");
	players[0] maps\mp\zombies\_zm_craftables::player_get_craftable_piece("elemental_staff_water", "middle_staff");
	players[0] maps\mp\zombies\_zm_craftables::player_get_craftable_piece("elemental_staff_water", "lower_staff");

    players[0] maps\mp\zombies\_zm_craftables::player_get_craftable_piece("elemental_staff_fire", "upper_staff");
    players[0] maps\mp\zombies\_zm_craftables::player_get_craftable_piece("elemental_staff_fire", "middle_staff");
	players[0] maps\mp\zombies\_zm_craftables::player_get_craftable_piece("elemental_staff_fire", "lower_staff");

	players[0] maps\mp\zombies\_zm_craftables::player_get_craftable_piece("elemental_staff_lightning", "upper_staff");
	players[0] maps\mp\zombies\_zm_craftables::player_get_craftable_piece("elemental_staff_lightning", "middle_staff");
	players[0] maps\mp\zombies\_zm_craftables::player_get_craftable_piece("elemental_staff_lightning", "lower_staff");

	players[0] maps\mp\zombies\_zm_craftables::player_get_craftable_piece("gramophone", "vinyl_player");
	players[0] maps\mp\zombies\_zm_craftables::player_get_craftable_piece("gramophone", "vinyl_master");
	players[0] maps\mp\zombies\_zm_craftables::player_get_craftable_piece("gramophone", "vinyl_air");
	players[0] maps\mp\zombies\_zm_craftables::player_get_craftable_piece("gramophone", "vinyl_ice");
	players[0] maps\mp\zombies\_zm_craftables::player_get_craftable_piece("gramophone", "vinyl_fire");
	players[0] maps\mp\zombies\_zm_craftables::player_get_craftable_piece("gramophone", "vinyl_elec");

	players[0] maps\mp\zombies\_zm_craftables::player_get_craftable_piece("equip_dieseldrone_zm", "body");
	players[0] maps\mp\zombies\_zm_craftables::player_get_craftable_piece("equip_dieseldrone_zm", "engine");
    players[0] maps\mp\zombies\_zm_craftables::player_get_craftable_piece("equip_dieseldrone_zm", "brain");

	players[0] maps\mp\zombies\_zm_craftables::player_get_craftable_piece("tomb_shield_zm", "top");
	players[0] maps\mp\zombies\_zm_craftables::player_get_craftable_piece("tomb_shield_zm", "door");
	players[0] maps\mp\zombies\_zm_craftables::player_get_craftable_piece("tomb_shield_zm", "bracket");
}

open_all_doors() {
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

force_craftable_spawn_location(piece, loc_index)
{
	loc = [];
	loc[0] = piece[loc_index];
	return loc;
}

panzer_3_force_round()
{
    while(!level.mechz_left_to_spawn) wait 0.05;
	val = get_cfg_int("panzer_3");
	if(val)
	{
		temp_round = level.next_mechz_round;
		wait 20;
		level.next_mechz_round = temp_round + val;
	}
}
