#define PLUGIN "Golden DEAGLE"

#include <amxmodx>
#include <fakemeta>
#include <fun>
#include <hamsandwich>
#include <cstrike>
#include <amxmisc>


#define is_valid_player(%1) (1 <= %1 <= 32)

new DEAGLE_V_MODEL[64] = "models/CSDM_GoldenShop/v_golden_deagle.mdl"
new DEAGLE_P_MODEL[64] = "models/CSDM_GoldenShop/p_golden_deagle.mdl"

/* Pcvars */
new cvar_dmgmultiplier, cvar_goldbullets,  cvar_custommodel, cvar_uclip, cvar_cost

new bool:g_HasDEAGLE[33]

new g_hasZoom[ 33 ]
new bullets[ 33 ]

// Sprite
new m_spriteTexture

const Wep_deagle = ((1<<CSW_DEAGLE))

public plugin_init()
{
	
	/* CVARS */
	cvar_dmgmultiplier = register_cvar("goldenDEAGLE_dmg_multiplier", "1.3")
	cvar_custommodel = register_cvar("goldenDEAGLE_custom_model", "1")
	cvar_goldbullets = register_cvar("goldenDEAGLE_gold_bullets", "1")
	cvar_uclip = register_cvar("goldenDEAGLE_unlimited_clip", "1")
	cvar_cost = register_cvar("goldenDEAGLE_cost", "0")
	
	// Register The Buy Cmd
	register_concmd("amx_goldenDEAGLE", "CmdGiveDEAGLE", ADMIN_LEVEL_A, "<name>")
	register_clcmd("csdm_goldenshop_goldenDEAGLE", "CmdBuyDEAGLE")
	register_clcmd("csdm_goldenshop_goldenDEAGLE", "CmdBuyDEAGLE")
	
	// Register The Plugin
	register_plugin("Golden DEAGLE", "1.0", "cSPlugins")
	// Death Msg
	register_event("DeathMsg", "Death", "a")
	// Weapon Pick Up
	register_event("WeapPickup","checkModel","b","1=19")
	// Current Weapon Event
	register_event("CurWeapon","checkWeapon","be","1=1")
	register_event("CurWeapon", "make_tracer", "be", "1=1", "3>0")
	// Ham TakeDamage
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	register_forward( FM_CmdStart, "fw_CmdStart" )
	RegisterHam(Ham_Spawn, "player", "fwHamPlayerSpawnPost", 1)
	
}

public client_connect(id)
{
	g_HasDEAGLE[id] = false
}

public client_disconnect(id)
{
	g_HasDEAGLE[id] = false
}

public Death()
{
	g_HasDEAGLE[read_data(2)] = false
}

public fwHamPlayerSpawnPost(id)
{
	g_HasDEAGLE[id] = false
}

public plugin_precache()
{
	precache_model(DEAGLE_V_MODEL)
	precache_model(DEAGLE_P_MODEL)
	m_spriteTexture = precache_model("sprites/dot.spr")
	precache_sound("weapons/zoom.wav")
}

public checkModel(id)
{
	if ( !g_HasDEAGLE[id] )
		return PLUGIN_HANDLED
	
	new szWeapID = read_data(2)
	
	if ( szWeapID == CSW_DEAGLE && g_HasDEAGLE[id] == true && get_pcvar_num(cvar_custommodel) )
	{
		set_pev(id, pev_viewmodel2, DEAGLE_V_MODEL)
		set_pev(id, pev_weaponmodel2, DEAGLE_P_MODEL)
	}
	return PLUGIN_HANDLED
}

public checkWeapon(id)
{
	new plrClip, plrAmmo, plrWeap[32]
	new plrWeapId
	
	plrWeapId = get_user_weapon(id, plrClip , plrAmmo)
	
	if (plrWeapId == CSW_DEAGLE && g_HasDEAGLE[id])
	{
		checkModel(id)
	}
	else 
	{
		return PLUGIN_CONTINUE
	}
	
	if (plrClip == 0 && get_pcvar_num(cvar_uclip))
	{
		// If the user is out of ammo..
		get_weaponname(plrWeapId, plrWeap, 31)
		// Get the name of their weapon
		give_item(id, plrWeap)
		engclient_cmd(id, plrWeap) 
		engclient_cmd(id, plrWeap)
		engclient_cmd(id, plrWeap)
	}
	return PLUGIN_HANDLED
}



public fw_TakeDamage(victim, inflictor, attacker, Float:damage)
{
	if ( is_valid_player( attacker ) && get_user_weapon(attacker) == CSW_DEAGLE && g_HasDEAGLE[attacker] )
	{
		SetHamParamFloat(4, damage * get_pcvar_float( cvar_dmgmultiplier ) )
	}
}

public fw_CmdStart( id, uc_handle, seed )
{
	if( !is_user_alive( id ) ) 
		return PLUGIN_HANDLED
	
	if( ( get_uc( uc_handle, UC_Buttons ) & IN_ATTACK2 ) && !( pev( id, pev_oldbuttons ) & IN_ATTACK2 ) )
	{
		new szClip, szAmmo
		new szWeapID = get_user_weapon( id, szClip, szAmmo )
		
		if( szWeapID == CSW_DEAGLE && g_HasDEAGLE[id] == true && !g_hasZoom[id] == true)
		{
			g_hasZoom[id] = true
			cs_set_user_zoom( id, CS_SET_AUGSG552_ZOOM, 0 )
			emit_sound( id, CHAN_ITEM, "weapons/zoom.wav", 0.20, 2.40, 0, 100 )
		}
		
		else if ( szWeapID == CSW_DEAGLE && g_HasDEAGLE[id] == true && g_hasZoom[id])
		{
			g_hasZoom[ id ] = false
			cs_set_user_zoom( id, CS_RESET_ZOOM, 0 )
			
		}
		
	}
	return PLUGIN_HANDLED
}


public make_tracer(id)
{
	if (get_pcvar_num(cvar_goldbullets))
	{
		new clip,ammo
		new wpnid = get_user_weapon(id,clip,ammo)
		new pteam[16]
		
		get_user_team(id, pteam, 15)
		
		if ((bullets[id] > clip) && (wpnid == CSW_DEAGLE) && g_HasDEAGLE[id]) 
		{
			new vec1[3], vec2[3]
			get_user_origin(id, vec1, 1) // origin; your camera point.
			get_user_origin(id, vec2, 4) // termina; where your bullet goes (4 is cs-only)
			
			
			//BEAMENTPOINTS
			message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte (0)     //TE_BEAMENTPOINTS 0
			write_coord(vec1[0])
			write_coord(vec1[1])
			write_coord(vec1[2])
			write_coord(vec2[0])
			write_coord(vec2[1])
			write_coord(vec2[2])
			write_short( m_spriteTexture )
			write_byte(1) // framestart
			write_byte(5) // framerate
			write_byte(2) // life
			write_byte(10) // width
			write_byte(0) // noise
			write_byte( 255 )     // r, g, b
			write_byte( 215 )       // r, g, b
			write_byte( 0 )       // r, g, b
			write_byte(200) // brightness
			write_byte(150) // speed
			message_end()
		}
		
		bullets[id] = clip
	}
	
}

public CmdBuyDEAGLE(id)
{
	if ( !is_user_alive(id) )
	{
		client_print(id,print_chat, "")
		return PLUGIN_HANDLED
	}
	
	new money = cs_get_user_money(id)
	
	if (money >= get_pcvar_num(cvar_cost))
	{
		cs_set_user_money(id, money - get_pcvar_num(cvar_cost))
		give_item(id, "weapon_deagle")
		g_HasDEAGLE[id] = true
	}
	
	else
	{
		client_print(id, print_chat, "", get_pcvar_num(cvar_cost))
	}
	return PLUGIN_HANDLED
}

public CmdGiveDEAGLE(id,level,cid)
{
	if (!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED;
	new arg[32];
	read_argv(1,arg,31);
	
	new player = cmd_target(id,arg,7);
	if (!player) 
		return PLUGIN_HANDLED;
	
	new name[32];
	get_user_name(player,name,31);
	
	give_item(player, "weapon_deagle")
	g_HasDEAGLE[player] = true
	
	return PLUGIN_HANDLED
}

stock drop_prim(id) 
{
	new weapons[32], num
	get_user_weapons(id, weapons, num)
	for (new i = 0; i < num; i++) {
		if (Wep_deagle & (1<<weapons[i])) 
		{
			static wname[32]
			get_weaponname(weapons[i], wname, sizeof wname - 1)
			engclient_cmd(id, "drop", wname)
		}
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
