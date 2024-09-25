#include <amxmodx>
#include <amxmisc>
#include <dhudmessage>

#define PLUGIN	"HUD Scoreboard"
#define VERSION	"1.3"
#define AUTHOR	"Kia Armani"

new TerrorWins
new CounterWins

new Terrorists
new CounterTerrorists

new hud_r
new hud_g
new hud_b
new hud_d

new Float:g_round_start = -1.0;
new Float:g_round_time;

new mp_roundtime;


public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	/* Tasks */
	
	set_task(1.0,"HUDUpdate", 0,"",0,"b")
	
	/* CVARS */
	
	hud_r =register_cvar("hud_rcolor","0") // RED
	hud_g =register_cvar("hud_gcolor","255") // GREEN
	hud_b =register_cvar("hud_bcolor","0") // BLUE
	hud_d =register_cvar("hud_design", "1")
	
	
	register_cvar("hud_terror_prefix","T's")
	register_cvar("hud_counter_prefix","CT's")
	
	register_cvar("hud_terror_tprefix","Terrorists")
	register_cvar("hud_counter_tprefix","Counter-Terrorists")
	
	/* Events */
	
	register_event("SendAudio", "t_win", "a", "2&%!MRAD_terwin") 
	register_event("SendAudio", "ct_win", "a", "2&%!MRAD_ctwin")  
	
	register_logevent("EventRoundStart", 2, "1=Round_Start");
	register_logevent("EventRoundEnd", 2, "1=Round_End");
	register_event("TextMsg", "EventRoundRestart", "a", "2&#Game_C", "2&#Game_w");
	
	mp_roundtime = get_cvar_pointer("mp_roundtime");
}


public HUDUpdate()
{	
	new TPrefix[512],CTPrefix[512],TTeamPrefix[512],CTTeamPrefix[512]
	
	get_cvar_string("hud_terror_prefix",TPrefix,charsmax(TPrefix))
	get_cvar_string("hud_counter_prefix",CTPrefix,charsmax(CTPrefix))
	get_cvar_string("hud_terror_tprefix",TTeamPrefix,charsmax(TTeamPrefix))
	get_cvar_string("hud_counter_tprefix",CTTeamPrefix,charsmax(CTTeamPrefix))
	
	
	new iPlayers[32],iPlayers_A[32],pnum_all
	get_players(iPlayers, Terrorists, "aeh", "TERRORIST");
	get_players(iPlayers, CounterTerrorists, "aeh", "CT");
	
	get_players(iPlayers_A, pnum_all,"ah")
	
	new Float:RoundTime = get_roundtime_left()
	new RTF = floatround(RoundTime,floatround_round)
	
	switch(get_pcvar_num(hud_d))
	{
		case(1):
		{
			for(new i; i < pnum_all; i++)
			{
				new id_a = iPlayers_A[i]
				set_dhudmessage(get_pcvar_num(hud_r),get_pcvar_num(hud_g),get_pcvar_num(hud_b), -1.0, 0.14, 0, 6.0, 1.0,0.0,0.1,false)
				show_dhudmessage(id_a, "%s Alive [%i] | [%i] %s Alive" , TPrefix, Terrorists, CounterTerrorists,CTPrefix)
			}
		}
		case(2):
		{
			for(new i; i < pnum_all; i++)
			{
				new id_a = iPlayers_A[i]
				set_dhudmessage(get_pcvar_num(hud_r),get_pcvar_num(hud_g),get_pcvar_num(hud_b), -1.0, 0.14, 0, 6.0, 1.0,0.0,0.1,false)
				show_dhudmessage(id_a, "%s   |   %i | %i alive | %i | %i alive | %i   |   %s", TTeamPrefix,TerrorWins,Terrorists,RTF,CounterTerrorists,CounterWins,CTTeamPrefix)
			}
		}
	}
}

public t_win()
{
	TerrorWins++
}

public ct_win()
{
	CounterWins++
}

// Thanks to Exolent[jNr]

public EventRoundStart()
{
    g_round_start = get_gametime();
    g_round_time = get_pcvar_float(mp_roundtime) * 60.0;
}

public EventRoundEnd()
{
    g_round_start = -1.0;
}

public EventRoundRestart()
{
    g_round_start = -1.0;
}

Float:get_roundtime_left()
{
    return (g_round_start == -1.0) ? 0.0 : ((g_round_start + g_round_time) - get_gametime());
}