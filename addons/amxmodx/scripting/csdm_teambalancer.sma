/*	
* 
* 							CSDM Teambalancer V1.1 by DA 
* 							Date: 03.04.2008
* 
* 			
* 							Description:
* 										This plugin balance the teams in CS 1.6 without to end the round. It was made for CSDM (Deathmatch) Servers
* 
* 					
* 							Installation:
* 										 Download the sma file and compile it
* 										 Load the compiled csdm_teambalancer.amxx to your plugins folder
* 										 Add a line "csdm_teambalancer.amxx" (without quotes) to your plugins.ini
* 										 If you want to play a sound to the player who switched by the plugin then copy the massteleporttarget.wav to your /sound/misc/ folder and add this to your amxx.cfg: amx_tsound 1
* 										 Change the map or restart the Server
* 		
* 						
* 							SVAR's:
* 									amx_tfreq			(Default: 50)	-	All 50 (Default) death the plugin checks the players and switch they
* 									amx_tmaxplayers		(Default:  4)	-	Max players on the server that it works
* 									amx_tsound			(Default:  0)	- 	Plays a sound to the player if he will be changed	
* 
* 
* 							Credits:
* 									Jim for some code and the idea
* 									Geesu for the sound file from wc3ft
* 					
* 
*/ 



#include <amxmodx>
#include <cstrike>

#define PLUGIN	"CSDM Teambalancer"
#define AUTHOR	"DA"
#define VERSION	"1.1"

new counter=0;

public plugin_precache()
{
	if	((get_cvar_num("amx_tsound")) != 1)
		return PLUGIN_CONTINUE;
	
	precache_sound("misc/massteleporttarget.wav");
	return PLUGIN_CONTINUE;
}


public on_death()
{
	counter++;
	if	(counter >= (get_cvar_num("amx_tmaxfreq")))
	{
		if	(get_playersnum() >= (get_cvar_num("amx_tmaxplayers")))
		{
			counter = 0;
			transfer_player();
		}
	}
}


transfer_player() 
{ 
	new name[32], players[32], scores[32];
	new player, playercount, bestscore, theone, i;
	new CTCount = 0, TCount = 0;
	
	get_players ( players, playercount, "c" );
	
	for ( i = 0; i < playercount; ++i )
	{
		if ( cs_get_user_team( players[i] ) == CS_TEAM_CT )
		{
			++CTCount;
		}
		
		else
		{
			++TCount;
		}
	}
	
	new CsTeams:WhichTeam; 
	if ( ( CTCount - TCount ) >= 2 )
	{
		WhichTeam = CS_TEAM_CT;
	}
	
	else if ( ( TCount - CTCount ) >= 2 )
	{
		WhichTeam = CS_TEAM_T;
	}
	
	else
	{
		return PLUGIN_CONTINUE;
	}
	
	for	(i=0; i<playercount; i++) 
	{
		player = players[i];
		
		if ( cs_get_user_team( player ) == WhichTeam )
		{
			scores[i] = get_user_frags(player) - get_user_deaths(player);
		}
	}
	
	bestscore = -9999;
	for	(i=0; i<playercount; i++) 
	{
		if	(scores[i] > bestscore) 
		{
			bestscore = scores[i];
			theone = players[i];
		}
	}
	
	cs_set_user_team(theone, WhichTeam == CS_TEAM_T ? CS_TEAM_CT : CS_TEAM_T);
	if	(get_cvar_num("amx_tsound") == 1) 
		client_cmd(theone, "speak misc/MassTeleportTarget");
	set_hudmessage(255, 140, 0, -1.0, 0.40, 2, 0.02, 5.0, 0.01, 0.1, 2);
	show_hudmessage(theone,"[CSDM] You Have Been Transfered To %s", WhichTeam == CS_TEAM_T ? "CT" : "Terrorist");
	get_user_name(theone,name,31);
	client_print(0, print_chat, "[CSDM] %s Has Been Transfered To %s.", name, WhichTeam == CS_TEAM_T ? "CT" : "Terrorist");
	console_print(0,"[CSDM] %s Has Been Transfered To %s.", name, WhichTeam == CS_TEAM_T ? "CT" : "Terrorist");
	
	return PLUGIN_CONTINUE;
}


public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_cvar("amx_tmaxfreq", "50");
	register_cvar("amx_tmaxplayer", "4");
	register_cvar("amx_tsound", "1");
	register_event("DeathMsg", "on_death", "a");
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1031\\ f0\\ fs16 \n\\ par }
*/
