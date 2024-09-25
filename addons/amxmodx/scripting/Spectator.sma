#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <colorchat>

#define ADMIN_SPECTATE ADMIN_BAN // Check Access To Join /spec.

public plugin_init() 
{
	register_plugin("Spectate", "1.0", "DON KHAN");

	register_clcmd("say", "Join_Spectate");
	register_clcmd("say_team","Join_Spectate");
}

public Join_Spectate(id) 
{
	new said[10];
	read_args(said,9);
	remove_quotes(said);

	if(equali(said, "/spec",5)) // Here you can edit chat command to join spectator.

		if( !( get_user_flags(id) & ADMIN_SPECTATE ) )
			ColorChat(id, GREEN, "^4[Join Spectate] ^3You Don't Have ^4Access ^3To Join ^4Spectate^1.");
		else
			cs_set_user_team(id, CS_TEAM_SPECTATOR);
		if(is_user_alive(id))
			user_silentkill(id)
			ColorChat(id, GREEN, "^4[Join Spectate] ^3You Are Now Become A ^4Spectator^1.");
}