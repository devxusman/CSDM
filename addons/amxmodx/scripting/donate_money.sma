#include <amxmodx>
#include <amxmisc>
#include <colorchat>
#include <cstrike>

#define PLUGIN "Money Transfer"
#define VERZIJA "2.0"
#define AUTOR "BS & TSM - Mr.Pro"

#pragma semicolon 1
new mt_advert, suma[33];

public plugin_init(){
	register_plugin(PLUGIN, VERZIJA, AUTOR);
	register_cvar("moneytransfer","1", (FCVAR_SERVER | FCVAR_SPONLY));
	mt_advert = register_cvar("mt_advert", "240.0");
	register_clcmd("say /transfer", "SayTransfer");
	register_clcmd("say_team /transfer", "SayTransfer");
	set_task(get_pcvar_float(mt_advert), "Advert",_,_,_,"b");
}

public client_putinserver(id)
	suma[id] = 0;
	
public client_disconnect(id)
	suma[id] = 0;

public Advert()
	ColorChat(0, TEAM_COLOR, "^4[Money]^3For Transfering ^4Money ^3To Anyone^4 say /transfer");

public SayTransfer(id){
	static CsTeams:team;
	team = cs_get_user_team(id);
	if(team == CS_TEAM_SPECTATOR || !is_user_alive(id))
		return PLUGIN_HANDLED;
	new menu = menu_create("\rChoose Amount Of Money^n\wBy \rTSM - Mr.Pro", "MenuHandler");
	menu_additem(menu, "\y1000\r$");
	menu_additem(menu, "\y2500\r$");
	menu_additem(menu, "\y5000\r$");
	menu_additem(menu, "\y10000\r$");
	menu_additem(menu, "\y15000\r$");
	menu_additem(menu, "\y20000\r$");
	menu_display(id, menu);
	set_hudmessage(255, 255, 0, 0.03, 0.23, 0, 6.0, 12.0);
	show_hudmessage(id, "The Transfer Price Is 50$");
	return PLUGIN_HANDLED;
}

public MenuHandler(id, menu, item) {
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	switch(item){
		case 0: suma[id] = 1000;
		case 1: suma[id] = 2500;
		case 2: suma[id] = 5000;
		case 3: suma[id] = 10000;
		case 4: suma[id] = 15000;
		case 5: suma[id] = 20000;
	}
	new iMoney;
	iMoney = cs_get_user_money(id);
	if(iMoney < suma[id] + 50){
		set_hudmessage(255, 255, 0, 0.03, 0.23, 0, 6.0, 12.0);
		show_hudmessage(id, "You Don't Have Money To To Pay Tax For Transfering");
		SayTransfer(id);
	}
	else {
		new szText[192];
		formatex(szText, charsmax(szText), "\rTransfer \w%i\y$ ^n\yChoose A Player^n\wBy \rTSM - Mr.Pro", suma[id]);
		new menu = menu_create (szText, "PlMenHand");
		new num, players[32], igrac, szTempID [10], tempname[32];
		get_players (players, num, "a");
		for (new i = 0; i < num; i++) {
			igrac = players [i];
			get_user_name (igrac, tempname, 31);
			num_to_str (igrac, szTempID, 9);
			menu_additem (menu, tempname, szTempID, 0);
		}
		menu_display (id, menu);
	}
	return PLUGIN_HANDLED;
}

public PlMenHand(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], name[64];
	new access, callback;
	menu_item_getinfo (menu, item, access, data, 5, name, 63, callback);
	new igrac = str_to_num(data);
	new szName[33], szPlayerName[33];
	get_user_name(id, szName, charsmax(szName));
	get_user_name(igrac, szPlayerName, charsmax(szPlayerName));
	cs_set_user_money(id, cs_get_user_money(id) - (suma[id] + 50));
	cs_set_user_money(igrac, cs_get_user_money(id) + suma[id]);
	set_hudmessage(255, 0, 0, -1.0, 0.18, 0, 6.0, 12.0);
	show_hudmessage(igrac, "You Got %i$ From %s", suma[id], szName);
	ColorChat(id, TEAM_COLOR, "^4[Money]^3 Successfully Transfered^4 %i$^3 Money To^4 %s", suma[id], szPlayerName);
	return PLUGIN_HANDLED;
}