#include <amxmodx>

#define PLUGIN_NAME "IP Shower"
#define PLUGIN_VERSION "1.0"
#define PLUGIN_AUTHOR "OciXCrom"

new const szPrefix[] = "[IP Shower]"

enum Color
{
	NORMAL = 1, // clients scr_concolor cvar color
	GREEN, // Green Color
	TEAM_COLOR, // Red, grey, blue
	GREY, // grey
	RED, // Red
	BLUE, // Blue
}

new TeamName[][] = 
{
	"",
	"TERRORIST",
	"CT",
	"SPECTATOR"
}

new cvar_adminonly, cvar_adminflag, cvar_hideadmins, cvar_showport

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
	
	cvar_adminonly = register_cvar("showip_adminonly", "1")
	cvar_adminflag = register_cvar("showip_adminflag", "c")
	cvar_hideadmins = register_cvar("showip_hideadmins", "0")
	cvar_showport = register_cvar("showip_showport", "0")
	
	register_concmd("amx_showip", "cmd_showip", ADMIN_KICK, "shows users' IP adresses")
	register_clcmd("say /showip", "cmd_ipmenu")
	register_clcmd("say_team /showip", "cmd_ipmenu")
}

public cmd_showip(id)
{
	if(get_pcvar_num(cvar_adminonly) == 1)
	{
		if(!user_has_flag(id, cvar_adminflag))
		{
			new adminflag[2]
			get_pcvar_string(cvar_adminflag, adminflag, charsmax(adminflag))
			client_print(id, print_console, "%s Only users with flag ^"%s^" can use this command.", szPrefix, adminflag)
			return PLUGIN_HANDLED
		}
	}
	
	new g_players[32], num, player
	get_players(g_players, num)
	
	new time[32]
	get_time("%d.%m.%Y - %X", time, charsmax(time))
	
	client_print(id, print_console, "< ----- < IP Shower By TSM - Mr.Pro > ----- < %s > ----- < IP Shower By TSM - Mr.Pro > ----- >^n", time)
	
	new info[100], name[32], ip[32]
	new showport = (get_pcvar_num(cvar_showport) == 1) ? 0 : 1
	
	for(new i = 0; i < num; i++)
	{
		player = g_players[i]
		get_user_name(player, name, charsmax(name))
		if(get_pcvar_num(cvar_hideadmins) == 1)
		{
			if(user_has_flag(player, cvar_adminflag)) formatex(ip, charsmax(ip), "HIDDEN IP")
			else get_user_ip(player, ip, charsmax(ip), showport)	
		}
		else get_user_ip(player, ip, charsmax(ip), showport)
		formatex(info, charsmax(info), "%s [ %s ]", name, ip)
		client_print(id, print_console, info)
	}
	
	client_print(id, print_console, "^n< ----- < IP Shower By TSM - Mr.Pro > ----- < %s > ----- < IP Shower TSM - Mr.Pro > ----- >", time)
	return PLUGIN_HANDLED
}


public cmd_ipmenu(id)
{
	if(get_pcvar_num(cvar_adminonly) == 1)
	{
		if(!user_has_flag(id, cvar_adminflag))
		{
			new adminflag[2]
			get_pcvar_string(cvar_adminflag, adminflag, charsmax(adminflag))
			ColorChat(id, TEAM_COLOR, "^4%s ^1Only users with flag^3 ^"%s^" ^1can use this command.", szPrefix, adminflag)
			return PLUGIN_HANDLED
		}
	}
	
	new title[100]
	formatex(title, charsmax(title), "\y%s \wChoose a player:\r", szPrefix)
	
	new ipmenu = menu_create(title, "ipmenu_handler")
	
	new players[32], num, player
	new name[32], userid[32]
	
	get_players(players, num)
	
	for(new i = 0; i < num; i++)
	{
		player = players[i]
		get_user_name(player, name, charsmax(name))
		formatex(userid, charsmax(userid), "%d", get_user_userid(player))
		menu_additem(ipmenu, name, userid, 0)
	}
	
	menu_setprop(ipmenu, MPROP_BACKNAME, "\yPrevious Page")
	menu_setprop(ipmenu, MPROP_NEXTNAME, "\yNext Page")
	menu_setprop(ipmenu, MPROP_EXITNAME, "\yClose")
	
	menu_display(id, ipmenu, 0)
	return PLUGIN_HANDLED
}

public ipmenu_handler(id, ipmenu, item)
{
	new data[6], name[64]
	new item_access, item_callback
	
	menu_item_getinfo(ipmenu, item, item_access, data, charsmax(data), name, charsmax(name), item_callback)
	new userid = str_to_num(data)
	
	new player = find_player("k", userid)
	new showport = (get_pcvar_num(cvar_showport) == 1) ? 0 : 1
	
	new time[32]
	get_time("%d.%m.%Y - %X", time, charsmax(time))
	
	if(player)
	{
		new name[32], ip[32]
		get_user_name(player, name, charsmax(name))
		if(get_pcvar_num(cvar_hideadmins) == 1)
		{
			if(user_has_flag(player, cvar_adminflag)) formatex(ip, charsmax(ip), "HIDDEN")
			else get_user_ip(player, ip, charsmax(ip), showport)
		}
		else get_user_ip(player, ip, charsmax(ip), showport)
		ColorChat(id, TEAM_COLOR, "^4%s ^1Player ^4%s^1's ^3IP Adress ^1is ^4%s^1. The time is ^3%s", szPrefix, name, ip, time)
	}	
	
	menu_destroy(ipmenu)
	return PLUGIN_HANDLED
}

stock user_has_flag(id, cvar)
{
	new flags[32]
	get_flags(get_user_flags(id), flags, charsmax(flags))
	
	new vip_flag[2]
	get_pcvar_string(cvar, vip_flag, charsmax(vip_flag))
	
	return (contain(flags, vip_flag) != -1) ? true : false
}

/* ColorChat */

ColorChat(id, Color:type, const msg[], {Float,Sql,Result,_}:...)
{
	static message[256];

	switch(type)
	{
		case NORMAL: // clients scr_concolor cvar color
		{
			message[0] = 0x01;
		}
		case GREEN: // Green
		{
			message[0] = 0x04;
		}
		default: // White, Red, Blue
		{
			message[0] = 0x03;
		}
	}

	vformat(message[1], 251, msg, 4);

	// Make sure message is not longer than 192 character. Will crash the server.
	message[192] = '^0';

	static team, ColorChange, index, MSG_Type;
	
	if(id)
	{
		MSG_Type = MSG_ONE;
		index = id;
	} else {
		index = FindPlayer();
		MSG_Type = MSG_ALL;
	}
	
	team = get_user_team(index);
	ColorChange = ColorSelection(index, MSG_Type, type);

	ShowColorMessage(index, MSG_Type, message);
		
	if(ColorChange)
	{
		Team_Info(index, MSG_Type, TeamName[team]);
	}
}

ShowColorMessage(id, type, message[])
{
	message_begin(type, get_user_msgid("SayText"), _, id);
	write_byte(id)		
	write_string(message);
	message_end();	
}

Team_Info(id, type, team[])
{
	message_begin(type, get_user_msgid("TeamInfo"), _, id);
	write_byte(id);
	write_string(team);
	message_end();

	return 1;
}

ColorSelection(index, type, Color:Type)
{
	switch(Type)
	{
		case RED:
		{
			return Team_Info(index, type, TeamName[1]);
		}
		case BLUE:
		{
			return Team_Info(index, type, TeamName[2]);
		}
		case GREY:
		{
			return Team_Info(index, type, TeamName[0]);
		}
	}

	return 0;
}

FindPlayer()
{
	static i;
	i = -1;

	while(i <= get_maxplayers())
	{
		if(is_user_connected(++i))
		{
			return i;
		}
	}

	return -1;
}