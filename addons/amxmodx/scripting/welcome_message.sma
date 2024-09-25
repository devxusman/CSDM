/* Welcome Message with three colors by [BaD CopY */

#include <amxmodx>
#include <amxmisc>
#include <csx>
#include <csstats>
#include <nvault>
#include <dhudmessage>

#define PLUGIN "Welcome Message"
#define VERSION "1.0"
#define AUTHOR "[BaD CopY"

new gTime[33]
new gVault
new hostname[64]


public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	gVault = nvault_open("TIME")
}

public client_authorized(id)
{
	loaddata(id)
}

public client_disconnect(id)
{
	gTime[id] += get_user_time(id)
	savedata(id)
}

public client_putinserver(id)
{
	if(is_user_bot(id)) return
	
	set_task(10.0, "welcomeHUD", id)
	set_task(10.0, "hostHUD", id)
	set_task(5.0, "adminHUD", id)
}

public welcomeHUD(id)
{
	new stats[8], body[8], nick[32], hostname[64]
	
	new rank_pos = get_user_stats(id, stats, body)
	new rank_max = get_statsnum()
	get_user_name(id, nick, 31)
	get_cvar_string("hostname",hostname,63)
	new iTimeMins = gTime[id] / 60
	
	static Deaths = 0, Kills = 0, Float:Ratio = 0.0
	
	Deaths = stats[1], Kills = stats[0], Ratio = Deaths == 0 ? (float(Kills)) : (float(Kills) / float(Deaths))
	
	set_dhudmessage(0, 255, 0, 0.03, 0.30, 2, 6.0, 8.0 )
	show_dhudmessage(id, "Welcome, %s^nRank: %d of %d^nKills: %d Deaths: %d KPD: %.2f^nOnline: %i m^nEnjoY!", nick,rank_pos,rank_max,stats[0], stats[1], Ratio,iTimeMins)
}

stock savedata(id)
{
	new AuthId[65]
	get_user_authid(id, AuthId, charsmax(AuthId))
	
	new VaultKey[64], VaultData[256]
	format(VaultKey, 63, "%s-TIME", AuthId)
	format(VaultData, 254, "%i", gTime[id])
	
	nvault_set(gVault, VaultKey, VaultData)
	
	return PLUGIN_CONTINUE
}

stock loaddata(id)
{
	new AuthID[35] 
	get_user_authid(id,AuthID,charsmax(AuthID ))
	new vaultkey[64],vaultdata[256]
	
	format(vaultkey,63,"%s-TIME" ,AuthID) 
	format(vaultdata,255,"%i",gTime[id]) 
	
	nvault_get(gVault,vaultkey,vaultdata,charsmax (vaultdata))
	
	new Time[33]
	parse(vaultdata, Time, charsmax(Time))
	
	gTime[id] = str_to_num(Time)
}

public hostHUD(id)
{
          get_cvar_string("hostname", hostname, 63)

	set_dhudmessage(212, 42, 255, 0.03, 0.5, 2, 6.0, 10.0)
	show_dhudmessage(id, "%s^nDon't forget to add IP to your favourites!", hostname)
}

public adminHUD(id)
{
	if (is_user_admin(id))
	{
		set_dhudmessage(0, 255, 255, 0.03, 0.75, 2, 6.0, 8.0);
		show_dhudmessage(id, "You Are Now Administrator!");
	}
}
