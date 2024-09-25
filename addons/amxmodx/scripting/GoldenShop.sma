#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <hamsandwich>
#include <fakemeta>
#include <engine>
#include <colorchat>
#include <csx>

new g_pCvarCostGoldenAk,
	g_pCvarCostGoldenM4A1,
	g_pCvarCostGoldenMP5,
	g_pCvarCostGoldenDeagle;
	


public plugin_init()
{
	register_plugin("Admin GoldenShop", "1.1", "TSM - Mr.Pro");
	register_clcmd("say /csdmgoldshop", "ShowMenu", _, "Select team");
	register_clcmd("csdm_goldenshop", "ShowMenu", _, "Select team");
	register_concmd("csdm_goldenshop", "ShowMenu", _, "Select team");
	
	g_pCvarCostGoldenAk = register_cvar("shopcsdm_goldenak", "20000");
	g_pCvarCostGoldenM4A1 = register_cvar("shopcsdm_goldenm4a1", "20000");
	g_pCvarCostGoldenMP5 = register_cvar("shopcsdm_goldenmp5", "15000");
	g_pCvarCostGoldenDeagle = register_cvar("shopcsdm_goldendeagle", "10000")
	
}
public ShowMenu(id){
	if(get_user_flags(id) & ADMIN_BAN){

	new menu = menu_create("\w[ \rCSDM \w]^n\w[ \yAdmin GoldenShop \w]^n\w[ \yBy \rTSM - Mr.Pro \w]", "CSDM_SHOP");
	
	menu_additem(menu, "\w[ \rGoldenAK - \r20000$ \w]", "", 0); // case 0
	menu_additem(menu, "\w[ \rGoldenM4a1 - \r20000$ \w]", "", 0); // case 1
	menu_additem(menu, "\w[ \rGoldenMP5 - \r15000$ \w]", "", 0); // case 2
	menu_additem(menu, "\w[ \rGoldenDeagle - \r10000$ \w]", "", 0); // case 3
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	
	menu_display(id, menu, 0);
	}else{
	ColorChat(id, GREEN, "^4[GoldenShop] ^3You Don't Have ^4Access ^3To This ^3Admin GoldenShop.");
	}
	return PLUGIN_HANDLED;
}

public CSDM_SHOP(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_cancel(id);
		return PLUGIN_HANDLED;
	}

	new command[6], name[64], access, callback;

	menu_item_getinfo(menu, item, access, command, sizeof command - 1, name, sizeof name - 1, callback);
	
	new iMoney = cs_get_user_money(id);

	switch(item)
	{
		case 0:
				{
			if ( iMoney >= get_pcvar_num(g_pCvarCostGoldenAk))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarCostGoldenAk));
				client_cmd(id, "csdm_goldenshop_goldenak");
				ColorChat(id, GREEN, "^4[GoldenShop]^3 Have Fun With^4 Golden AK47");
			}
			
			else
			{
				ColorChat(id, GREEN, "^4[GoldenShop]^3 You Don't Have Money To Buy^4 Golden Ak ^1(^3Need ^4%i$^1)", get_pcvar_num(g_pCvarCostGoldenAk));
			}
		}
		case 1: 
				{
			if ( iMoney >= get_pcvar_num(g_pCvarCostGoldenM4A1))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarCostGoldenM4A1));
				client_cmd(id, "csdm_goldenshop_goldenm4");
				ColorChat(id, GREEN, "^4[GoldenShop]^3 Have Fun With^4 Golden M4A1");
			}
			
			else
			{
				ColorChat(id, GREEN, "^4[GoldenShop]^3 You Don't Have Money To Buy^4 Golden M4A1 ^1(^3Need ^4%i$^1)", get_pcvar_num(g_pCvarCostGoldenM4A1));
			}
		}
		case 2: 
				{
			if ( iMoney >= get_pcvar_num(g_pCvarCostGoldenMP5))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarCostGoldenMP5));
				client_cmd(id, "csdm_goldenshop_goldenmp5");
				ColorChat(id, GREEN, "^4[GoldenShop]^3 Have Fun With^4 Golden MP5");
			}
			
			else
			{
				ColorChat(id, GREEN, "^4[GoldenShop]^3 You Don't Have Money To Buy^4 Golden MP5 ^1(^3Need ^4%i$^1)", get_pcvar_num(g_pCvarCostGoldenMP5));
			}
		}
		case 3: 
				{
			if ( iMoney >= get_pcvar_num(g_pCvarCostGoldenDeagle))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarCostGoldenDeagle));
				client_cmd(id, "csdm_goldenshop_goldenDEAGLE");
				ColorChat(id, GREEN, "^4[GoldenShop]^3 Have Fun With^4 Golden Deagle");
			}
			
			else
			{
				ColorChat(id, GREEN, "^4[GoldenShop]^3 You Don't Have Money To Buy^4 Golden Deagle ^1(^3Need ^4%i$^1)", get_pcvar_num(g_pCvarCostGoldenDeagle));
			}
		}

	}

	menu_destroy(menu);

	return PLUGIN_HANDLED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
