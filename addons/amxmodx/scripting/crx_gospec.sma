#include <amxmodx>
#include <cromchat>
#include <cstrike>
#include <hamsandwich>

#define PLUGIN_VERSION "1.2"

enum _:Cvars
{
	gospec_respawn
}

new g_eCvars[Cvars]

new CsTeams:g_iOldTeam[33]

public plugin_init()
{
	register_plugin("GoSpec", PLUGIN_VERSION, "OciXCrom")
	register_cvar("@CRXGoSpec", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED)
	register_dictionary("GoSpec.txt")
	
	register_clcmd("say /spec", "GoSpec")
	register_clcmd("say /back", "GoBack")
	register_clcmd("say /change", "SwitchTeam")
	g_eCvars[gospec_respawn] = register_cvar("gospec_respawn", "1")
	CC_SetPrefix("[&x03CSDM-GoSpec&x01]")
}

public GoSpec(id)
{
	new CsTeams:iTeam = cs_get_user_team(id)
		
	if(iTeam == CS_TEAM_SPECTATOR)
		CC_SendMessage(id, "%L", id, "GOSPEC_ALREADY_SPECTATOR")
	else
	{
		g_iOldTeam[id] = iTeam
		cs_set_user_team(id, CS_TEAM_SPECTATOR)
		CC_SendMessage(id, "%L", id, "GOSPEC_NOW_SPECTATOR")
		
		if(is_user_alive(id))
			user_silentkill(id)
	}
	
	return PLUGIN_HANDLED
}

public GoBack(id)
{		
	if(cs_get_user_team(id) != CS_TEAM_SPECTATOR)
		CC_SendMessage(id, "%L", id, "GOSPEC_NOT_SPECTATOR")
	else
	{
		new iPlayers[32], iCT, iT
		get_players(iPlayers, iCT, "e", "CT")
		get_players(iPlayers, iT, "e", "TERRORIST")
		
		if(iCT == iT)
		{
			cs_set_user_team(id, g_iOldTeam[id])
			CC_SendMessage(id, "%L", id, "GOSPEC_TRANSFERED_TO_PREVIOUS")
		}
		else
		{
			cs_set_user_team(id, iCT > iT ? CS_TEAM_T : CS_TEAM_CT)
			CC_SendMessage(id, "%L", id, "GOSPEC_TRANSFERED_TO_LESS")
		}
		
		if(get_pcvar_num(g_eCvars[gospec_respawn]))
			ExecuteHamB(Ham_CS_RoundRespawn, id)
	}		
	
	return PLUGIN_HANDLED
}

public SwitchTeam(id)
{		
	new CsTeams:iTeam = cs_get_user_team(id)
		
		
	if(iTeam == CS_TEAM_SPECTATOR)
		CC_SendMessage(id, "%L", id, "GOSPEC_CANT_USE")
	else
	{
		cs_set_user_team(id, cs_get_user_team(id) == CS_TEAM_CT ? CS_TEAM_T : CS_TEAM_CT)
		CC_SendMessage(id, "%L", id, "GOSPEC_TRANSFERED_TO_OPPOSITE")
		
		if(is_user_alive(id))
		{
			user_silentkill(id)
			
			if(get_pcvar_num(g_eCvars[gospec_respawn]))
				ExecuteHamB(Ham_CS_RoundRespawn, id)
		}			
	}
	
	return PLUGIN_HANDLED
}