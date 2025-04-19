#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\gametypes_zm\_hud_message;
#include maps\mp\zombies\_zm_weapons;

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

increment_int(dvar, minmax)
{
    value = GetDvarInt(dvar);
    new_val = (value + 1) % (minmax[1] + 1);
    if(new_val < minmax[0]) new_val = minmax[0];
	setDvar(dvar, new_val);
    self scripts\zm\origins_menu\menu_base::refresh_menu();
}

dvarint_compare(dvar, d_true, d_false)
{
    value = GetDvarInt(dvar);
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

toggle_binary(dvar)
{
	value = GetDvarInt(dvar);
	setDvar(dvar, 1 - value);
	self scripts\zm\origins_menu\menu_base::refresh_menu();
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

toggle_demigod()
{
    if ( self.health < 6666 )
    {
        self.maxhealth = 999999;
        self.health = self.maxhealth;
        self.demigod = 1;
        self thread demi_god();
    }
    else
    {
        self notify( "disable_godmode" );
        self.demigod = 0;

        if ( self hasperk( "specialty_armorvest" ) )
        {
            self.maxhealth = 250;
            self.health = self.maxhealth;
        }
        else
        {
            self.maxhealth = 100;
            self.health = self.maxhealth;
        }
    }
    self scripts\zm\origins_menu\menu_base::refresh_menu();
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