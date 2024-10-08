/* Plugin generated by AMXX-Studio */

#include <amxmodx> 
#include <engine>

#define PLUGIN  "Show Admins Online" 
#define VERSION "1.1" 
#define AUTHOR  "vato loco [GE-S] & Alka" 

new bool:g_bAdminNick
new bool:is_admin_connected[33]
new g_msg[512]

new g_admin_enable
new g_online_color
new g_offline_color
new g_msg_xypos

new g_SyncAdmin
new g_iAdminCount 
new g_iMaxPlayers

new g_ClassName[] = "admin_msg"

public plugin_init() 
{ 
	register_plugin( PLUGIN, VERSION, AUTHOR )
	
	register_think(g_ClassName,"ForwardThink")
	
	g_admin_enable = register_cvar("sa_plugin_on","1")
	g_online_color = register_cvar("sa_online_color","0 130 0")
	g_offline_color = register_cvar("sa_offline_color","255 0 0")
	g_msg_xypos = register_cvar("sa_msg_xypos","0.88 0.12")
	
	g_SyncAdmin = CreateHudSyncObj()
	g_iMaxPlayers = get_maxplayers()
	
	new iEnt = create_entity("info_target")
	entity_set_string(iEnt, EV_SZ_classname, g_ClassName)
	entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 2.0)
} 

public client_putinserver(id)
{
	if(get_user_flags(id) & ADMIN_BAN)
	{
		is_admin_connected[id] = true
		g_iAdminCount++
		set_admin_msg()
	}
	if(g_iAdminCount == 0)
		set_admin_msg()
}

public client_disconnect(id)
{
	if(is_admin_connected[id])
	{
		is_admin_connected[id] = false
		g_iAdminCount--
		set_admin_msg()
	}
}

public client_infochanged(id)
{
	if(is_admin_connected[id])
	{
		static NewName[32], OldName[32]
		get_user_info(id, "name", NewName, 31)
		get_user_name(id, OldName, 31)
		
		if(!equal(OldName, NewName))
		{
			g_bAdminNick = true
		}
	}
}

public set_admin_msg()
{
	static g_iAdminName[32], pos, i
	pos = 0
	pos += formatex(g_msg[pos], 511-pos, "[CSDM] Admins Online: %d", g_iAdminCount)
	
	for(i = 1 ; i <= g_iMaxPlayers ; i++)
	{	
		if(is_admin_connected[i])
		{
			get_user_name(i, g_iAdminName, 31)
			pos += formatex(g_msg[pos], 511-pos, "^n%s", g_iAdminName)
		}
	}
}

public admins_online() 
{
	if(get_pcvar_num(g_admin_enable))
	{
		static r, g, b, Float:x,Float:y
		HudMsgPos(x,y)
		
		if (g_iAdminCount > 0)
		{
			HudMsgColor(g_online_color, r, g, b)
			set_hudmessage(r, g, b, x, y, _, _, 4.0, _, _, 4)
			ShowSyncHudMsg(0, g_SyncAdmin, "%s", g_msg)
		}
		else
		{
			HudMsgColor(g_offline_color, r, g, b)
			set_hudmessage(r, g, b, x, y, _, _, 4.0, _, _, 4)
			ShowSyncHudMsg(0, g_SyncAdmin, "%s", g_msg)
		}
	}
	return PLUGIN_HANDLED
} 

public ForwardThink(iEnt)
{
	admins_online()
	
	if(g_bAdminNick)
	{
		set_admin_msg()
		g_bAdminNick = false
	}
        entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 2.0)
}

public HudMsgColor(cvar, &r, &g, &b)
{
	static color[16], piece[5]
	get_pcvar_string(cvar, color, 15)
	
	strbreak( color, piece, 4, color, 15)
	r = str_to_num(piece)
	
	strbreak( color, piece, 4, color, 15)
	g = str_to_num(piece)
	b = str_to_num(color)
}

public HudMsgPos(&Float:x, &Float:y)
{
	static coords[16], piece[10]
	get_pcvar_string(g_msg_xypos, coords, 15)
	
	strbreak(coords, piece, 9, coords, 15)
	x = str_to_float(piece)
	y = str_to_float(coords)
}
