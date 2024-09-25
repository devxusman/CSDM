#include <amxmodx>
#include <fun>
#include <hamsandwich>

#define PLUGIN_VERSION "1.0.1"
#define TASK_PROTECT 222567

enum _:Cvars
{
	sp_time,
	sp_glow_t,
	sp_glow_ct,
	sp_glow_spec,
	sp_glow_alpha
}

new g_eCvars[Cvars]

new g_iAlpha
new g_iColors[3][3]
new Float:g_fTime
new bool:g_bProtect[33]

public plugin_init()
{
	register_plugin("Spawn Protection", PLUGIN_VERSION, "OciXCrom")
	register_cvar("CRXSpawnProtection", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED)
	RegisterHam(Ham_Spawn, "player", "OnPlayerSpawn", 1)
	RegisterHam(Ham_TraceAttack, "player", "OnPlayerAttack")
	
	g_eCvars[sp_time] = register_cvar("sp_time", "3.0")
	g_eCvars[sp_glow_t] = register_cvar("sp_glow_t", "255 0 0")
	g_eCvars[sp_glow_ct] = register_cvar("sp_glow_ct", "0 0 255")
	g_eCvars[sp_glow_spec] = register_cvar("sp_glow_spec", "255 255 255")
	g_eCvars[sp_glow_alpha] = register_cvar("sp_glow_alpha", "40")
}

public plugin_cfg()
{
	g_iAlpha = get_pcvar_num(g_eCvars[sp_glow_alpha])
	g_fTime = get_pcvar_float(g_eCvars[sp_time])
	
	new szColor[12]
	get_pcvar_string(g_eCvars[sp_glow_spec], szColor, charsmax(szColor))
	parse_color(szColor, g_iColors[0][0], g_iColors[0][1], g_iColors[0][2])
	get_pcvar_string(g_eCvars[sp_glow_t], szColor, charsmax(szColor))
	parse_color(szColor, g_iColors[1][0], g_iColors[1][1], g_iColors[1][2])
	get_pcvar_string(g_eCvars[sp_glow_ct], szColor, charsmax(szColor))
	parse_color(szColor, g_iColors[2][0], g_iColors[2][1], g_iColors[2][2])
}

public OnPlayerAttack(iVictim, iAttacker)
	return g_bProtect[iVictim] ? HAM_SUPERCEDE : HAM_IGNORED

public OnPlayerSpawn(id)
{
	if(!is_user_alive(id))
		return
		
	g_bProtect[id] = true
	new iTeam = get_user_team(id)
	
	if(iTeam > 2)
		iTeam = 0
		
	set_user_rendering(id, kRenderFxGlowShell, g_iColors[iTeam][0], g_iColors[iTeam][1], g_iColors[iTeam][2], kRenderNormal, g_iAlpha)
	set_task(g_fTime, "RemoveProtection", id + TASK_PROTECT)
}

public RemoveProtection(id)
{
	id -= TASK_PROTECT
	g_bProtect[id] = false
	
	if(is_user_connected(id))
		set_user_rendering(id, kRenderFxNone, 0, 0, 0, kRenderNormal, 0)
}

parse_color(szRGB[], &iRed, &iGreen, &iBlue)
{
	new szColor[3][4]
	parse(szRGB, szColor[0], charsmax(szColor[]), szColor[1], charsmax(szColor[]), szColor[2], charsmax(szColor[]))
	iRed = str_to_num(szColor[0])
	iGreen = str_to_num(szColor[1])
	iBlue = str_to_num(szColor[2])
}
