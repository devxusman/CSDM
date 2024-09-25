#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <crxranks>
#include <dhudmessage>

#define m_pActiveItem 373
// ColorChat
#define NORMAL DontChange
#define GREEN DontChange
#define TEAM_COLOR DontChange
#define RED Red
#define BLUE Blue
#define GREY Grey
#define ColorChat client_print_color

#define Ham_Player_ResetMaxSpeed Ham_Item_PreFrame

#define MAX_PLAYERS 32
#define LIMIT_HP 400

#pragma semicolon 1
enum _:Colors {
	DontChange,
	Red,
	Blue,
	Grey
}
enum _:{
	MEGA_NADE,
	REMOVE_MEGADMG
}
// CS Offsets For Unlimited Clip
#if cellbits == 32;
const OFFSET_CLIPAMMO = 51;
#else
const OFFSET_CLIPAMMO = 65;
#endif
const OFFSET_LINUX_WEAPONS = 4;

new const g_prefix[] = "[CSDM Shop]";
new g_HasMultiJump[MAX_PLAYERS+1];
new g_HasSpeed_Item1[MAX_PLAYERS+1];
new g_HasSpeed_Item2[MAX_PLAYERS+1];
new g_HasSpeed_Item3[MAX_PLAYERS+1];
new g_HasSpeed_Item4[MAX_PLAYERS+1];
new g_has_unlimited_clip[33];
new jumpnum[33] = 0;
new bool:dojump[33] = false;
new g_players[33],g_maxplayers;

new CvarSpeedQuantity1,
	CvarSpeedQuantity2,
	CvarSpeedQuantity3,
	CvarSpeedQuantity4,
	g_pCvarCostSpeedItem1,
	g_pCvarCostSpeedItem2,
	g_pCvarCostSpeedItem3,
	g_pCvarCostSpeedItem4,
	CvarGravityQuantity1,
	CvarGravityQuantity2,
	CvarGravityQuantity3,
	g_pCvarCostGravityItem1,
	g_pCvarCostGravityItem2,
	g_pCvarCostGravityItem3,
	CvarHealthQuantity1,
	CvarHealthQuantity2,
	CvarHealthQuantity3,
	CvarHealthQuantity4,
	CvarInvisiblityQuantity1,
	CvarInvisiblityQuantity2,
	CvarInvisiblityQuantity3,
	CvarInvisiblityQuantity4,
	CvarMegaNadeDamage,
	g_pCvarCostHealthItem1,
	g_pCvarCostHealthItem2,
	g_pCvarCostHealthItem3,
	g_pCvarCostHealthItem4,
	g_pCvarCostInvisiblityItem1,
	g_pCvarCostInvisiblityItem2,
	g_pCvarCostInvisiblityItem3,
	g_pCvarCostInvisiblityItem4,
	g_pCvarSpecCostItemMega,
	g_pCvarSpecCostItemTeleport,
	g_pCvarSpecCostItemMultiJump,
	g_pCvarSpecCostItemNoFootStep,
	g_pCvarSpecCostItemNoReload,
	g_pCvarSpecCostItemShield,
	g_MaxJumps;

// Max Clip for weapons
new const MAXCLIP[] = { -1, 13, -1, 10, 1, 7, -1, 30, 30, 1, 30, 20, 25, 30, 35, 25, 12, 20,
                        10, 30, 100, 8, 30, 30, 20, 2, 7, 30, 30, -1, 50 };
public plugin_init()
{
	register_plugin("CSDM Main", "2.1.a", "TSM - Mr.Pro");
	register_clcmd("Nightvision", "ShowMenu");
	
	//Cvars
	CvarSpeedQuantity1 = register_cvar("csdm_speedquantity_1", "350");
	CvarSpeedQuantity2 = register_cvar("csdm_speedquantity_2", "400");
	CvarSpeedQuantity3 = register_cvar("csdm_speedquantity_3", "450");
	CvarSpeedQuantity4 = register_cvar("csdm_speedquantity_4", "500");
	CvarGravityQuantity1 = register_cvar("csdm_gravityquantity_1", "0.6");
	CvarGravityQuantity2 = register_cvar("csdm_gravityquantity_2", "0.5");
	CvarGravityQuantity3 = register_cvar("csdm_gravityquantity_3", "0.4");
	CvarHealthQuantity1 = register_cvar("csdm_hpquantity_1", "100");
	CvarHealthQuantity2 = register_cvar("csdm_hpquantity_2", "200");
	CvarHealthQuantity3 = register_cvar("csdm_hpquantity_3", "300");
	CvarHealthQuantity4 = register_cvar("csdm_hpquantity_4", "400");
	CvarInvisiblityQuantity1 = register_cvar("csdm_invisquantity_1", "25");
	CvarInvisiblityQuantity2 = register_cvar("csdm_invisquantity_2", "50");
	CvarInvisiblityQuantity3 = register_cvar("csdm_invisquantity_3", "75");
	CvarInvisiblityQuantity4 = register_cvar("csdm_invisquantity_4", "100");
	CvarMegaNadeDamage = register_cvar("csdm_megagrenade_dmg", "4");
	
	g_pCvarCostSpeedItem1 = register_cvar("csdm_speedprice_1", "1000");
	g_pCvarCostSpeedItem2 = register_cvar("csdm_speedprice_2", "3000");
	g_pCvarCostSpeedItem3 = register_cvar("csdm_speedprice_3", "5000");
	g_pCvarCostSpeedItem4 = register_cvar("csdm_speedprice_4", "10000");
	g_pCvarCostGravityItem1 = register_cvar("csdm_gravityprice_1", "3000");
	g_pCvarCostGravityItem2 = register_cvar("csdm_gravityprice_2", "6000");
	g_pCvarCostGravityItem3 = register_cvar("csdm_gravityprice_3", "9000");
	g_pCvarCostHealthItem1 = register_cvar("csdm_hpprice_1", "3000");
	g_pCvarCostHealthItem2 = register_cvar("csdm_hpprice_2", "6000");
	g_pCvarCostHealthItem3 = register_cvar("csdm_hpprice_3", "9000");
	g_pCvarCostHealthItem4 = register_cvar("csdm_hpprice_4", "11000");
	g_pCvarCostInvisiblityItem1 = register_cvar("csdm_invisprice_1", "5000");
	g_pCvarCostInvisiblityItem2 = register_cvar("csdm_invisprice_2", "10000");
	g_pCvarCostInvisiblityItem3 = register_cvar("csdm_invisprice_3", "15000");
	g_pCvarCostInvisiblityItem4 = register_cvar("csdm_invisprice_4", "30000");
	g_pCvarSpecCostItemMega = register_cvar("csdm_megagrenadeprice", "5000");
	g_pCvarSpecCostItemTeleport = register_cvar("csdm_teleportprice", "1500");
	g_pCvarSpecCostItemMultiJump = register_cvar("csdm_MultiJumpPrice", "2000");
	g_pCvarSpecCostItemNoFootStep = register_cvar("csdm_NoFootStepPrice", "1000");
	g_pCvarSpecCostItemNoReload = register_cvar("csdm_unlimitedprice", "2000");
	g_pCvarSpecCostItemShield = register_cvar("csdm_itemshieldprice", "1000");
	
	g_MaxJumps = register_cvar("csdm_specshopincreasejumps","3");
	set_cvar_num("sv_maxspeed", get_pcvar_num(CvarSpeedQuantity4));
	
	//Ham
	RegisterHam(Ham_Player_ResetMaxSpeed, "player", "Player_ResetMaxSpeed", 1);
	RegisterHam(Ham_Killed,"player","On_Player_Killed");
	RegisterHam(Ham_TakeDamage,"player","On_Player_TakeDamage");
	
	//Events & Fuctions
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0");
	register_logevent("logevent_round_end", 2, "1=Round_End");
	register_event("CurWeapon", "current_weapon", "be", "1=1");	
	register_message(get_user_msgid("CurWeapon"), "message_cur_weapon");
	g_maxplayers = get_maxplayers();
}

public plugin_cfg()
{
	new directory[31];
	get_configsdir(directory, 30);
	server_cmd("exec %s/csdm_main.cfg", directory);
}
public On_Player_Killed(id){
	g_players[id] = REMOVE_MEGADMG; // Reset Ability When Player Is Died.
	jumpnum[id] = 0;
	dojump[id] = false;
	g_has_unlimited_clip[id] = false;
	set_user_footsteps(id, 0); 
	g_HasSpeed_Item1[id] = false;
	g_HasSpeed_Item2[id] = false;
	g_HasSpeed_Item3[id] = false;
	g_HasSpeed_Item4[id] = false;
	set_user_gravity(id);
	set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 0);
	g_HasMultiJump[id]  = false;
	
}
public client_putinserver(id)
{
	jumpnum[id] = 0;
	dojump[id] = false;
}

public client_disconnect(id)
{
	jumpnum[id] = 0;
	dojump[id] = false;
	g_players[id] = REMOVE_MEGADMG;
}
// Code For Unlimited Clip
public current_weapon(id)
{
		if(g_has_unlimited_clip[id])
		{
				new iWeapon = get_user_weapon(id);
				if(iWeapon == CSW_HEGRENADE)
		{
						give_item(id, "weapon_hegrenade");
						cs_set_user_bpammo(id, CSW_HEGRENADE, 245);
				}               
				if(iWeapon == CSW_HEGRENADE)
		{
						give_item( id, "weapon_smokegrenade" );
						cs_set_user_bpammo(id, CSW_SMOKEGRENADE, 245);
				}      
		}
}

// Reset flags for all players on newround
public event_round_start()
{
		for (new id; id <= 32; id++) g_has_unlimited_clip[id] = false;
}

public logevent_round_end()
{		
		for (new id; id <= 32; id++)
		{
				if(is_user_alive(id) && g_has_unlimited_clip[id])
				{
						ham_strip_weapon(id, "weapon_hegrenade");
						ham_strip_weapon(id, "weapon_smokegrenade");
				}
		}
}
public message_cur_weapon(msg_id, msg_dest, msg_entity)
{
        // Player doesn't have the unlimited clip upgrade
        if (!g_has_unlimited_clip[msg_entity])
                return;
       
        // Player not alive or not an active weapon
        if (!is_user_alive(msg_entity) || get_msg_arg_int(1) != 1)
                return;
       
        static weapon, clip;
        weapon = get_msg_arg_int(2); // get weapon ID
        clip = get_msg_arg_int(3); // get weapon clip
       
        // Unlimited Clip Ammo
        if (MAXCLIP[weapon] > 1) // skip grenades
        {
                set_msg_arg_int(3, get_msg_argtype(3), MAXCLIP[weapon]); // HUD should show full clip all the time
               
                if (clip < 2) // refill when clip is nearly empty
                {
                        // Get the weapon entity
                        static wname[32], weapon_ent;
                        get_weaponname(weapon, wname, sizeof wname - 1);
                        weapon_ent = fm_find_ent_by_owner(-1, wname, msg_entity);
                       
                        // Set max clip on weapon
                        fm_set_weapon_ammo(weapon_ent, MAXCLIP[weapon]);
                }
        }
}
public ShowMenu(id)
{
	new menu = menu_create("\rCSDM \y Main Menu^n\y By \d[\rTSM - Mr.Pro\d]", "MainMenu");
	
	menu_additem(menu, "\yBuild LaserMine \d$\r1000", "", 0); // case 0
	
	menu_additem(menu, "\yBuild Sentry \d$\r5000", "", 0); // case 1				
		
	if(get_user_flags(id) & ADMIN_USER)		
	menu_additem(menu, "\yBuild Dispenser \d$\r5000 \r[Maximum 2]^n", "", 0); // case 2
	else
	if(get_user_flags(id) & ADMIN_RESERVATION)		
	menu_additem(menu, "\yBuild Dispenser \d$\r4000 \r[Maximum 4]^n", "", 0); // case 2a
	
	menu_additem(menu, "\yMain SHOP \r[ALL Players]", "", 0); // case 3
	
	menu_additem(menu, "\yBenefits CMDS \w[\rGeneral Commands\w]", "", 0); // case 4
	
	if(get_user_flags(id) & ADMIN_RESERVATION)
	menu_additem(menu, "\yVIP MENU \r[VIP Items]", "", 0); // case 5
	else
	menu_additem(menu, "\dVIP MENU \d[\r2x Boost\d]", "", 0); // case 5a
	
	menu_additem(menu, "\yKnife Menu \r[ALL PLAYERS]", "", 0); // case 6
	
	if(get_user_flags(id) & ADMIN_BAN)
	menu_additem(menu, "\yADMIN MENU \r[ADMINS ONLY]^n", "", 0); // case 7
	else
	menu_additem(menu, "\dADMIN MENU \d[\y5x Boost\d]^n", "", 0); // case 7a
	
	if(get_user_flags(id) & ADMIN_LEVEL_A)
	menu_additem(menu, "\yMANAGER MENU \r[MANAGERS ONLY]^n", "", 0); // case 8
	else
	menu_additem(menu, "\dMANAGER MENU \d[\y15e PayPal\d]^n", "", 0); // case 8a
	
	menu_additem(menu, "\yExit", "", 0); // case 9
	
	menu_setprop(menu, MPROP_PERPAGE, 0);
	
	menu_display(id, menu, 0);
	
	return PLUGIN_HANDLED;
}

public MainMenu(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_cancel(id);
        return PLUGIN_HANDLED;
    }

    new command[6], name[64], access, callback;

    menu_item_getinfo(menu, item, access, command, sizeof command - 1, name, sizeof name - 1, callback);

    switch(item)
    {
        case 0: client_cmd(id, "+setlaser");
        case 1: client_cmd(id, "sentry_build");
        case 2: client_cmd(id, "build_dispenser");
        case 3: {
            MainShop(id);
        }
        case 4: {
            GeneralCmds(id);
        }      
		case 5: client_cmd(id, "say /vm");
        case 6: client_cmd(id, "csdm_knifemenu");       
        case 7: client_cmd(id, "csdm_adminmenu");
		case 8: client_cmd(id, "csdmmanagermenu");
        case 9: menu_cancel(id);

    }    
    menu_destroy(menu);

    return PLUGIN_HANDLED;
}
// Main Shop
public MainShop(id)
{
    new menu = menu_create("\yCSDM Main Shop Menu^n\y By \d[\rTSM - Mr.Pro\d]", "MainShopHandler");

    menu_additem(menu, "\yCustomShop \d[\rExtra Items\d]", "", 0); // case 0
    menu_additem(menu, "\yWeapons SHOP \d[\rBuy Weapons\d]", "", 0); // case 1
    menu_additem(menu, "\yExtra Speed \d[\rBuy Speed\d]", "", 0); // case 2
    menu_additem(menu, "\yExtra Gravity \d[\rBuy Speed\d]", "", 0); // case 3
    menu_additem(menu, "\yExtra Health \d[\rBuy HP\d]", "", 0); // case 4
    menu_additem(menu, "\yInvisiblity \d[\rBuy Transparency\d]", "", 0); // case 5
    menu_additem(menu, "\ySpecific Items \d[\rOther Items\d]", "", 0); // case 6
	if(get_user_flags(id) & ADMIN_RESERVATION)
    menu_additem(menu, "\yVIP SHOP \d[\rVIP Weapons\d]", "", 0); // case 7
	else
    menu_additem(menu, "\dVIP SHOP \d[\y5x Boosts\d]", "", 0); // case 7a
	if(get_user_flags(id) & ADMIN_BAN)
    menu_additem(menu, "\yADMIN GoldenShop \d[\rGolden Weapons\d]^n", "", 0); // case 8
	else
    menu_additem(menu, "\dADMIN GoldenShop \d[\y5x Boosts\d]^n", "", 0); // case 8a
    menu_additem(menu, "\rExit ", "", 0); // case 9
	
	menu_setprop(menu, MPROP_PERPAGE, 0);

    menu_display(id, menu, 0);

    return PLUGIN_HANDLED;
}

public MainShopHandler(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_cancel(id);
        return PLUGIN_HANDLED;
    }

    new command[6], name[64], access, callback;

    menu_item_getinfo(menu, item, access, command, sizeof command - 1, name, sizeof name - 1, callback);

    switch(item)
    {
    
        case 0: client_cmd(id, "say /customshop");
        case 1: client_cmd(id, "weapon_shop");
        case 2: {
            ExtraSpeedShop(id);
        }   
        case 3: {
            ExtraGravityShop(id);
        }   
        case 4: {
            ExtraHealthShop(id);
        }   
        case 5: {
            ExtraInvisiblityShop(id);
        } 
        case 6: {
            SpecificItemsShop(id);
        }  
		case 7: client_cmd(id, "vip_shop");
        case 8: client_cmd(id, "csdm_goldenshop"); 
		case 9: menu_cancel(id);		
    }    
    menu_destroy(menu);

    return PLUGIN_HANDLED;
}

// General Commands
public GeneralCmds(id)
{
    new menu = menu_create("\yCSDM General Commands Menu^n\y By \d[\rTSM - Mr.Pro\d]", "GeneralCmdsMenu");

    menu_additem(menu, "\yDonate Money \d[\rTransfer Money\d]", "", 0); // case 0
    menu_additem(menu, "\yAdmins Online \d[\rCheck Online Admins\d]", "", 0); // case 1
    menu_additem(menu, "\yRock The Vote \d[\rChange Map\d]", "", 0); // case 2
    menu_additem(menu, "\yVote Ban \d[\rBan Player\d]", "", 0); // case 3
    menu_additem(menu, "\yPrivate Message \d[\rOpen PM Menu\d]", "", 0); // case 4	
    menu_additem(menu, "\yMute Menu \d[\rMute Player\d]", "", 0); // case 5
    menu_additem(menu, "\yRespawn \d[\rRevive Yourself\d]", "", 0); // case 6	
    menu_additem(menu, "\yGameTracker Link \d[\rCheck Your Stats\d]", "", 0); // case 7
    menu_additem(menu, "\yGo Spec \d[\rJoin Spectator\d]", "", 0); // case 8	
    menu_additem(menu, "\yJoin Team \d[\rJoin Team Back\d]", "", 0); // case 9	
    menu_additem(menu, "\yContact Facebook \d[\rCheck TSM - Mr.Pro's FB\d]", "", 0); // case 10	

    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);

    menu_display(id, menu, 0);

    return PLUGIN_HANDLED;
}
public GeneralCmdsMenu(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_cancel(id);
        return PLUGIN_HANDLED;
    }

    new command[6], name[64], access, callback;

    menu_item_getinfo(menu, item, access, command, sizeof command - 1, name, sizeof name - 1, callback);

    switch(item)
    {
        case 0: client_cmd(id, "say /transfer");
        case 1: client_cmd(id, "say /users");
        case 2: client_cmd(id, "say rtv");
        case 3: client_cmd(id, "say /voteban");
        case 4: client_cmd(id, "pm_menu");
        case 5: client_cmd(id, "amx_mutemenu");
        case 6: client_cmd(id, "say /respawn");
        case 7: client_cmd(id, "say /gt");
        case 8: client_cmd(id, "say /spec");
        case 9: client_cmd(id, "say /back");
        case 10: client_cmd(id, "say /fb");
    }    
    menu_destroy(menu);

    return PLUGIN_HANDLED;
}

// Extra Speed Shop

public ExtraSpeedShop(id)
{
	if ( is_user_alive(id) )
	{
		new Text[64];
		{
			new menu = menu_create ("\yCSDM Extra Speed Shop^n \yBy \d[\rTSM - Mr.Pro\d]", "SpeedShopHandler");
			
			formatex(Text, charsmax(Text), "\rSpeed \w[\y%i\w] \d[\r$%d\d]", get_pcvar_num(CvarSpeedQuantity1), get_pcvar_num(g_pCvarCostSpeedItem1));
			menu_additem(menu, Text, "1");
			formatex(Text, charsmax(Text), "\rSpeed \w[\y%i\w] \d[\r$%d\d]", get_pcvar_num(CvarSpeedQuantity2), get_pcvar_num(g_pCvarCostSpeedItem2));
			menu_additem(menu, Text, "2");
			formatex(Text, charsmax(Text), "\rSpeed \w[\y%i\w] \d[\r$%d\d]", get_pcvar_num(CvarSpeedQuantity3), get_pcvar_num(g_pCvarCostSpeedItem3));
			menu_additem(menu, Text, "3");
			formatex(Text, charsmax(Text), "\rSpeed \w[\y%i\w] \d[\r$%d\d]", get_pcvar_num(CvarSpeedQuantity4), get_pcvar_num(g_pCvarCostSpeedItem4));
			menu_additem(menu, Text, "4");
			menu_addblank(menu, 0);
			menu_additem(menu, "\rExit", "10");

			menu_setprop(menu, MPROP_PERPAGE, 0);

			menu_display(id, menu);
		}
	}
}

public SpeedShopHandler(id, menu, item)
{
	new iMoney = cs_get_user_money(id);

	switch(item+1)
	{       
		case 1:
		{
			if ( iMoney >= get_pcvar_num(g_pCvarCostSpeedItem1))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarCostSpeedItem1));
				//set_user_maxspeed(id, get_user_maxspeed(id) + get_pcvar_num(CvarSpeedQuantity1));
				g_HasSpeed_Item1[id] = true;
				client_print_color(id, DontChange, "^4%s ^3Have Fun With ^4Speed %i", g_prefix, get_pcvar_num(CvarSpeedQuantity1));
			}
			else
			{
				client_print_color(id, DontChange, "^4%s ^3You Don't Have Money To Buy ^4Speed %i ^1(^4Need %d$^1)", g_prefix, get_pcvar_num(CvarSpeedQuantity1), get_pcvar_num(g_pCvarCostSpeedItem1));
			}
		}

		case 2:
		{
			if ( iMoney >= get_pcvar_num(g_pCvarCostSpeedItem2))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarCostSpeedItem2));
				//set_user_maxspeed(id, get_user_maxspeed(id) + get_pcvar_num(CvarSpeedQuantity2));
				g_HasSpeed_Item2[id] = true;
				client_print_color(id, DontChange, "^4%s ^3Have Fun With ^4Speed %i", g_prefix, get_pcvar_num(CvarSpeedQuantity2));
			}
			else
			{
				client_print_color(id, DontChange, "^4%s ^3You Don't Have Money To Buy ^4Speed %i ^1(^4Need %d$^1)", g_prefix, get_pcvar_num(CvarSpeedQuantity2), get_pcvar_num(g_pCvarCostSpeedItem2));
			}
		}

		case 3:
		{
			if ( iMoney >= get_pcvar_num(g_pCvarCostSpeedItem3))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarCostSpeedItem3));
				//set_user_maxspeed(id, get_user_maxspeed(id) + get_pcvar_num(CvarSpeedQuantity3));
				g_HasSpeed_Item2[id] = true;
				client_print_color(id, DontChange, "^4%s ^3Have Fun With ^4Speed %i", g_prefix, get_pcvar_num(CvarSpeedQuantity3));
			}	
			else
			{
				client_print_color(id, DontChange, "^4%s ^3You Don't Have Money To Buy ^4Speed %i ^1(^4Need %d$^1)", g_prefix, get_pcvar_num(CvarSpeedQuantity3), get_pcvar_num(g_pCvarCostSpeedItem3));
			}
		}

		case 4:
		{
			if ( iMoney >= get_pcvar_num(g_pCvarCostSpeedItem4))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarCostSpeedItem4));
				//set_user_maxspeed(id, get_user_maxspeed(id) + get_pcvar_num(CvarSpeedQuantity4));
				g_HasSpeed_Item4[id] = true;
				client_print_color(id, DontChange, "^4%s ^3Have Fun With ^4Speed %i", g_prefix, get_pcvar_num(CvarSpeedQuantity4));
			}
			else
			{
				client_print_color(id, DontChange, "^4%s ^3You Don't Have Money To Buy ^4Speed %i ^1(^4Need %d$^1)", g_prefix, get_pcvar_num(CvarSpeedQuantity4), get_pcvar_num(g_pCvarCostSpeedItem4));
			}
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

// Extra Gravity Shop

public ExtraGravityShop(id)
{
	if ( is_user_alive(id) )
	{
		new Text[64];
		{
			new menu = menu_create ("\yCSDM Extra Gravity Shop^n \yBy \d[\rTSM - Mr.Pro\d]", "GravityShopHandler");
			
			formatex(Text, charsmax(Text), "\rGravity \w[\y600\w] \d[\r$%d\d]", get_pcvar_num(g_pCvarCostGravityItem1));
			menu_additem(menu, Text, "1");
			formatex(Text, charsmax(Text), "\rGravity \w[\y500\w] \d[\r$%d\d]", get_pcvar_num(g_pCvarCostGravityItem2));
			menu_additem(menu, Text, "2");
			formatex(Text, charsmax(Text), "\rGravity \w[\y400\w] \d[\r$%d\d]", get_pcvar_num(g_pCvarCostGravityItem3));
			menu_additem(menu, Text, "3");
			menu_addblank(menu, 0);
			menu_additem(menu, "Exit", "10");

			menu_setprop(menu, MPROP_PERPAGE, 0);

			menu_display(id, menu);
		}
	}
}

public GravityShopHandler(id, menu, item)
{
	new iMoney = cs_get_user_money(id);

	switch(item+1)
	{       
		case 1:
		{
			if ( iMoney >= get_pcvar_num(g_pCvarCostGravityItem1))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarCostGravityItem1));
				set_user_gravity(id, get_pcvar_float(CvarGravityQuantity1));
				client_print_color(id, DontChange, "^4%s ^3Have Fun With ^4Gravity 600", g_prefix);
			}

			else
			{
				client_print_color(id, DontChange, "^4%s ^3You Don't Have Money To Buy ^4Gravity 600 ^1(^4Need %d$^1)", g_prefix, get_pcvar_num(g_pCvarCostGravityItem1));
			}
		}

		case 2:
		{
			if ( iMoney >= get_pcvar_num(g_pCvarCostGravityItem2))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarCostGravityItem2));
				set_user_gravity(id, get_pcvar_float(CvarGravityQuantity2));
				client_print_color(id, DontChange, "^4%s ^3Have Fun With ^4Gravity 500", g_prefix);
			}

			else
			{
				client_print_color(id, DontChange, "^4%s ^3You Don't Have Money To Buy ^4Gravity 500 ^1(^4Need %d$^1)", g_prefix, get_pcvar_num(g_pCvarCostGravityItem2));
			}
		}

		case 3:
		{
			if ( iMoney >= get_pcvar_num(g_pCvarCostGravityItem3))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarCostGravityItem3));
				set_user_gravity(id, get_pcvar_float(CvarGravityQuantity3));
				client_print_color(id, DontChange, "^4%s ^3Have Fun With ^4Gravity 400", g_prefix);
			}
				
			else
			{
				client_print_color(id, DontChange, "^4%s ^3You Don't Have Money To Buy ^4Gravity 400 ^1(^4Need %d$^1)", g_prefix, get_pcvar_num(g_pCvarCostGravityItem3));
			}
		}

	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

// Extra Health Shop

public ExtraHealthShop(id)
{
	if ( is_user_alive(id) )
	{
		new Text[64];
		{
			new menu = menu_create ("\yCSDM Extra Health Shop^n \yBy \d[\rTSM - Mr.Pro\d]", "ExtraHealthShopHandler");
			
			formatex(Text, charsmax(Text), "\rHealth \w[\y+%i\w] \d[\r$%d\d]", get_pcvar_num(CvarHealthQuantity1), get_pcvar_num(g_pCvarCostHealthItem1));
			menu_additem(menu, Text, "1");
			formatex(Text, charsmax(Text), "\rHealth \w[\y+%i\w] \d[\r$%d\d]", get_pcvar_num(CvarHealthQuantity2), get_pcvar_num(g_pCvarCostHealthItem2));
			menu_additem(menu, Text, "2");
			formatex(Text, charsmax(Text), "\rHealth \w[\y+%i\w] \d[\r$%d\d]", get_pcvar_num(CvarHealthQuantity3), get_pcvar_num(g_pCvarCostHealthItem3));
			menu_additem(menu, Text, "3");
			formatex(Text, charsmax(Text), "\rHealth \w[\y+%i\w] \d[\r$%d\d]", get_pcvar_num(CvarHealthQuantity4), get_pcvar_num(g_pCvarCostHealthItem4));
			menu_additem(menu, Text, "4");
			menu_addblank(menu, 0);
			menu_additem(menu, "\rExit", "10");

			menu_setprop(menu, MPROP_PERPAGE, 0);

			menu_display(id, menu);
		}
	}
}

public ExtraHealthShopHandler(id, menu, item)
{
	new iMoney = cs_get_user_money(id);

	switch(item+1)
	{       
		case 1:
		{
			if ( iMoney >= get_pcvar_num(g_pCvarCostHealthItem1))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarCostHealthItem1));
				set_user_health(id, min(LIMIT_HP, get_user_health(id)) + get_pcvar_num(CvarHealthQuantity1));
				client_print_color(id, DontChange, "^4%s ^3Have Fun With ^4Health +%i", g_prefix, get_pcvar_num(CvarHealthQuantity1));
			}

			else
			{
				client_print_color(id, DontChange, "^4%s ^3You Don't Have Money To Buy ^4Health +%i ^1(^4Need %d$^1)", g_prefix, get_pcvar_num(CvarHealthQuantity1), get_pcvar_num(g_pCvarCostHealthItem1));
			}
		}

		case 2:
		{
			if ( iMoney >= get_pcvar_num(g_pCvarCostHealthItem2))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarCostHealthItem2));
				set_user_health(id, min(LIMIT_HP, get_user_health(id)) + get_pcvar_num(CvarHealthQuantity2));
				client_print_color(id, DontChange, "^4%s ^3Have Fun With ^4Health +%i", g_prefix, get_pcvar_num(CvarHealthQuantity2));
			}

			else
			{
				client_print_color(id, DontChange, "^4%s ^3You Don't Have Money To Buy ^4Health +%i ^1(^4Need %d$^1)", g_prefix, get_pcvar_num(CvarHealthQuantity2), get_pcvar_num(g_pCvarCostHealthItem2));
			}
		}

		case 3:
		{
			if ( iMoney >= get_pcvar_num(g_pCvarCostHealthItem3))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarCostHealthItem3));
				set_user_health(id, min(LIMIT_HP, get_user_health(id)) + get_pcvar_num(CvarHealthQuantity3));
				client_print_color(id, DontChange, "^4%s ^3Have Fun With ^4Health +%i", g_prefix, get_pcvar_num(CvarHealthQuantity3));
			}
				
			else
			{
				client_print_color(id, DontChange, "^4%s ^3You Don't Have Money To Buy ^4Health +%i ^1(^4Need %d$^1)", g_prefix, get_pcvar_num(CvarHealthQuantity3), get_pcvar_num(g_pCvarCostHealthItem3));
			}
		}

		case 4:
		{
			if ( iMoney >= get_pcvar_num(g_pCvarCostHealthItem4))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarCostHealthItem4));
				set_user_health(id, min(LIMIT_HP, get_user_health(id)) + get_pcvar_num(CvarHealthQuantity4));
				client_print_color(id, DontChange, "^4%s ^3Have Fun With ^4Health +%i", g_prefix, get_pcvar_num(CvarHealthQuantity4));
			}
			
			else
			{
				client_print_color(id, DontChange, "^4%s ^3You Don't Have Money To Buy ^4Health +%i ^1(^4Need %d$^1)", g_prefix, get_pcvar_num(CvarHealthQuantity4), get_pcvar_num(g_pCvarCostHealthItem4));
			}
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

// Extra Invisiblity Shop

public ExtraInvisiblityShop(id)
{
	if ( is_user_alive(id) )
	{
		new Text[64];
		{
			new menu = menu_create ("\yCSDM Extra Invisiblity Shop^n \yBy \d[\rTSM - Mr.Pro\d]", "InvisiblityShopHandler");
			
			formatex(Text, charsmax(Text), "\rInvisiblity \w[\y%i\w] \d[\r$%d\d]", get_pcvar_num(CvarInvisiblityQuantity1), get_pcvar_num(g_pCvarCostInvisiblityItem1));
			menu_additem(menu, Text, "1");
			formatex(Text, charsmax(Text), "\rInvisiblity \w[\y%i\w] \d[\r$%d\d]", get_pcvar_num(CvarInvisiblityQuantity2), get_pcvar_num(g_pCvarCostInvisiblityItem2));
			menu_additem(menu, Text, "2");
			formatex(Text, charsmax(Text), "\rInvisiblity \w[\y%i\w] \d[\r$%d\d]", get_pcvar_num(CvarInvisiblityQuantity3), get_pcvar_num(g_pCvarCostInvisiblityItem3));
			menu_additem(menu, Text, "3");
			formatex(Text, charsmax(Text), "\rInvisiblity \w[\y%i\w] \d[\r$%d\d]", get_pcvar_num(CvarInvisiblityQuantity4), get_pcvar_num(g_pCvarCostInvisiblityItem4));
			menu_additem(menu, Text, "4");
			menu_addblank(menu, 0);
			menu_additem(menu, "\rExit", "10");

			menu_setprop(menu, MPROP_PERPAGE, 0);

			menu_display(id, menu);
		}
	}
}

public InvisiblityShopHandler(id, menu, item)
{
	new iMoney = cs_get_user_money(id);

	switch(item+1)
	{       
		case 1:
		{
			if ( iMoney >= get_pcvar_num(g_pCvarCostSpeedItem1))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarCostInvisiblityItem1));
				set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, get_pcvar_num(CvarInvisiblityQuantity1));
				client_print_color(id, DontChange, "^4%s ^3Have Fun With ^4Invisiblity %i", g_prefix, get_pcvar_num(CvarInvisiblityQuantity1));
			}
			else
			{
				client_print_color(id, DontChange, "^4%s ^3You Don't Have Money To Buy ^4Invisiblity %i ^1(^4Need %d$^1)", g_prefix, get_pcvar_num(CvarSpeedQuantity1), get_pcvar_num(g_pCvarCostSpeedItem1));
			}
		}

		case 2:
		{
			if ( iMoney >= get_pcvar_num(g_pCvarCostInvisiblityItem2))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarCostInvisiblityItem2));
				set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, get_pcvar_num(CvarInvisiblityQuantity2));
				client_print_color(id, DontChange, "^4%s ^3Have Fun With ^4Invisiblity %i", g_prefix, get_pcvar_num(CvarInvisiblityQuantity2));
			}
			else
			{
				client_print_color(id, DontChange, "^4%s ^3You Don't Have Money To Buy ^4Invisiblity %i ^1(^4Need %d$^1)", g_prefix, get_pcvar_num(CvarInvisiblityQuantity2), get_pcvar_num(g_pCvarCostInvisiblityItem2));
			}
		}

		case 3:
		{
			if ( iMoney >= get_pcvar_num(g_pCvarCostInvisiblityItem3))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarCostInvisiblityItem3));
				set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, get_pcvar_num(CvarInvisiblityQuantity3));
				client_print_color(id, DontChange, "^4%s ^3Have Fun With ^4Invisiblity %i", g_prefix, get_pcvar_num(CvarInvisiblityQuantity3));
			}	
			else
			{
				client_print_color(id, DontChange, "^4%s ^3You Don't Have Money To Buy ^4Invisiblity %i ^1(^4Need %d$^1)", g_prefix, get_pcvar_num(CvarInvisiblityQuantity3), get_pcvar_num(g_pCvarCostInvisiblityItem3));
			}
		}

		case 4:
		{
			if ( iMoney >= get_pcvar_num(g_pCvarCostInvisiblityItem4))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarCostSpeedItem4));
				set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, get_pcvar_num(CvarInvisiblityQuantity4));
				client_print_color(id, DontChange, "^4%s ^3Have Fun With ^4Invisiblity %i", g_prefix, get_pcvar_num(CvarInvisiblityQuantity4));
			}
			else
			{
				client_print_color(id, DontChange, "^4%s ^3You Don't Have Money To Buy ^4Invisiblity %i ^1(^4Need %d$^1)", g_prefix, get_pcvar_num(CvarInvisiblityQuantity4), get_pcvar_num(g_pCvarCostInvisiblityItem4));
			}
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

//Specific Items Shop

public SpecificItemsShop(id)
{
	if ( is_user_alive(id) )
	{
		new Text[64];
		{
			new menu = menu_create ("\yCSDM Specific Items Shop^n \yBy \d[\rTSM - Mr.Pro\d]", "SpecificItemsShopHandler");
			
			formatex(Text, charsmax(Text), "\rMega Grenade \w[\y%ix Damage\w] \d[\r$%d\d]", get_pcvar_num(CvarMegaNadeDamage), get_pcvar_num(g_pCvarSpecCostItemMega));
			menu_additem(menu, Text, "1");
			formatex(Text, charsmax(Text), "\rSmoke Teleport Grenade \w[\yTeleport Grenade\w] \d[\r$%d\d]", get_pcvar_num(g_pCvarSpecCostItemTeleport));
			menu_additem(menu, Text, "2");
			formatex(Text, charsmax(Text), "\rMulti Jump \w[\y1x Extra Jump\w] \d[\r$%d\d]", get_pcvar_num(g_pCvarSpecCostItemMultiJump));
			menu_additem(menu, Text, "3");
			formatex(Text, charsmax(Text), "\rInstant Reload \w[\yUnlimited Clip\w] \d[\r$%d\d]", get_pcvar_num(g_pCvarSpecCostItemNoReload));
			menu_additem(menu, Text, "4");
			formatex(Text, charsmax(Text), "\rSilent FootStep \w[\ySilent Run\w] \d[\r$%d\d]", get_pcvar_num(g_pCvarSpecCostItemNoFootStep));
			menu_additem(menu, Text, "5");
			formatex(Text, charsmax(Text), "\rShield \w[\yWeapon Shield\w] \d[\r$%d\d]", get_pcvar_num(g_pCvarSpecCostItemShield));
			menu_additem(menu, Text, "6");
			menu_addblank(menu, 0);
			menu_additem(menu, "\rExit", "10");

			menu_setprop(menu, MPROP_PERPAGE, 0);

			menu_display(id, menu);
		}
	}
}

public SpecificItemsShopHandler(id, menu, item)
{
	new iMoney = cs_get_user_money(id);
//	new iWeapon = get_user_weapon(id);
	
	switch(item+1)
	{       
		case 1:
		{
			if ( iMoney >= get_pcvar_num(g_pCvarSpecCostItemMega))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarSpecCostItemMega));
				if(!user_has_weapon(id,CSW_HEGRENADE))
				fm_give_item(id,"weapon_hegrenade");
		
				g_players[id] |= (1<<MEGA_NADE);
				
				client_print_color(id, DontChange, "^4%s ^3Have Fun With ^4Mega Grenade", g_prefix);
			}

			else
			{
				client_print_color(id, DontChange, "^4%s ^3You Don't Have Money To Buy ^4Mega Grenade ^1(^4Need %d$^1)", g_prefix, get_pcvar_num(g_pCvarSpecCostItemMega));
			}
		}

		case 2:
		{
			if ( iMoney >= get_pcvar_num(g_pCvarSpecCostItemTeleport))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarSpecCostItemTeleport));
				give_item(id, "weapon_smokegrenade");
				client_print_color(id, DontChange, "^4%s ^3Have Fun With ^4Teleport Smoke Grenade", g_prefix);
			}

			else
			{
				client_print_color(id, DontChange, "^4%s ^3You Don't Have Money To Buy ^4Teleport Smoke Grenade ^1(^4Need %d$^1)", g_prefix, get_pcvar_num(g_pCvarSpecCostItemTeleport));
			}
		}

		case 3:
		{
			if ( iMoney >= get_pcvar_num(g_pCvarSpecCostItemMultiJump))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarSpecCostItemMultiJump));
				g_HasMultiJump[id] = true;
				dojump[id] = true;
				jumpnum[id] = 1;
				client_print_color(id, DontChange, "^4%s ^3Have Fun With ^4Multi Jump", g_prefix);
			}
				
			else
			{
				client_print_color(id, DontChange, "^4%s ^3You Don't Have Money To Buy ^4Multi Jump ^1(^4Need %d$^1)", g_prefix, get_pcvar_num(g_pCvarSpecCostItemMultiJump));
			}
		}
		
		case 4:
		{
			if ( iMoney >= get_pcvar_num(g_pCvarSpecCostItemNoReload))
			{
				{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarSpecCostItemNoReload));
				g_has_unlimited_clip[id] = true;
				client_print_color(id, DontChange, "^4%s ^3Have Fun With ^4Unlimited Clip", g_prefix);
				}
			}
			
			else
			{
				client_print_color(id, DontChange, "^4%s ^3You Don't Have Money To Buy ^4Unlimited Clip ^1(^4Need %d$^1)", g_prefix, get_pcvar_num(g_pCvarSpecCostItemNoReload));
			}
		}
		case 5:
		{
			if ( iMoney >= get_pcvar_num(g_pCvarSpecCostItemNoFootStep))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarSpecCostItemNoFootStep));
				set_user_footsteps(id);
				client_print_color(id, DontChange, "^4%s ^3Have Fun With ^4Silent Run", g_prefix);
			}
			
			else
			{
				client_print_color(id, DontChange, "^4%s ^3You Don't Have Money To Buy ^4Silent Run ^1(^4Need %d$^1)", g_prefix, get_pcvar_num(g_pCvarSpecCostItemNoFootStep));
			}
		}
		case 6:
		{
			if ( iMoney >= get_pcvar_num(g_pCvarSpecCostItemShield))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarSpecCostItemShield));
				give_item(id, "weapon_shield");
				client_print_color(id, DontChange, "^4%s ^3Have Fun With ^4Shield", g_prefix);
			}
			
			else
			{
				client_print_color(id, DontChange, "^4%s ^3You Don't Have Money To Buy ^4Shield ^1(^4Need %d$^1)", g_prefix, get_pcvar_num(g_pCvarSpecCostItemShield));
			}
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

/*================================================================================
 [Other Fuction, Tasks & Stocks]
=================================================================================*/
// Mega Grenade
public On_Player_TakeDamage(victim,idinflictor,idattacker,Float:damage,damagebits){
	if(!idattacker || idattacker > g_maxplayers)
		return HAM_IGNORED;
		
	if(!g_players[idattacker])
		return HAM_IGNORED;
	
	if(0 < idinflictor <= g_maxplayers){
		new classname[32];
		pev(idinflictor,pev_classname,classname,31);
		
		if(!strcmp(classname,"grenade") && (g_players[idattacker] & (1 << MEGA_NADE))){
			set_task(0.5,"deSetNade",idattacker);
			
			damage *= get_pcvar_float(CvarMegaNadeDamage);
			SetHamParamFloat(4, damage);
		}
	}
	return HAM_IGNORED;
}
public deSetNade(id)
	g_players[id] &= ~(1<<MEGA_NADE);
// Speed
public Player_ResetMaxSpeed( id )
{
	if ( is_user_alive ( id ) )
	{
		if ( get_user_maxspeed(id) != -1.0 )
		{
			if ( g_HasSpeed_Item1[id] )
			{
				set_user_maxspeed(id, get_pcvar_float(CvarSpeedQuantity1));
			}
			if ( g_HasSpeed_Item2[id] )
			{
				set_user_maxspeed(id, get_pcvar_float(CvarSpeedQuantity2));
			}
			if ( g_HasSpeed_Item3[id] )
			{
				set_user_maxspeed(id, get_pcvar_float(CvarSpeedQuantity3));
			}
			if ( g_HasSpeed_Item4[id] )
			{
				set_user_maxspeed(id, get_pcvar_float(CvarSpeedQuantity4));
			}
		}
	}
}
// Unlimited Clip Stock
// Find entity by its owner (from fakemeta_util)
/*stock fm_find_ent_by_owner(entity, const classname[], owner)
{
        while ((entity = engfunc(EngFunc_FindEntityByString, entity, "classname", classname)) && pev(entity, pev_owner) != owner) {}
       
        return entity;
}*/

// Set Weapon Clip Ammo
stock fm_set_weapon_ammo(entity, amount)
{
        set_pdata_int(entity, OFFSET_CLIPAMMO, amount, OFFSET_LINUX_WEAPONS);
}

stock ham_strip_weapon(id,weapon[])
{
    if(!equal(weapon,"weapon_",7)) return 0;

    new wId = get_weaponid(weapon);
    if(!wId) return 0;

    new wEnt;
    while((wEnt = engfunc(EngFunc_FindEntityByString,wEnt,"classname",weapon)) && pev(wEnt,pev_owner) != id) {}
    if(!wEnt) return 0;

    if(get_user_weapon(id) == wId) ExecuteHamB(Ham_Weapon_RetireWeapon,wEnt);

    if(!ExecuteHamB(Ham_RemovePlayerItem,id,wEnt)) return 0;
    ExecuteHamB(Ham_Item_Kill,wEnt);

    set_pev(id,pev_weapons,pev(id,pev_weapons) & ~(1<<wId));

    return 1;
}
// Multi Jump

public client_PreThink(id)
{
	if(is_user_alive(id) &&  g_HasMultiJump[id])
	{
		new nbut = get_user_button(id);
		new obut = get_user_oldbutton(id);
		if((nbut & IN_JUMP) && !(get_entity_flags(id) & FL_ONGROUND) && !(obut & IN_JUMP))
		{
			if(jumpnum[id] < get_pcvar_num(g_MaxJumps))
			{
				dojump[id] = true;
				jumpnum[id]++;
				return PLUGIN_CONTINUE;
			}
		}
		if((nbut & IN_JUMP) && (get_entity_flags(id) & FL_ONGROUND))
		{
			jumpnum[id] = 0;
			return PLUGIN_CONTINUE;
		}
		return PLUGIN_CONTINUE;
	}
	return PLUGIN_CONTINUE;
}

public client_PostThink(id)
{
	if(!is_user_alive(id) &&  g_HasMultiJump[id])
	{
		if(dojump[id] == true)
		{
			new Float:velocity[3];
			entity_get_vector(id,EV_VEC_velocity,velocity);
			velocity[2] = random_float(265.0,285.0);
			entity_set_vector(id,EV_VEC_velocity,velocity);
			return PLUGIN_CONTINUE;
		}
		return PLUGIN_CONTINUE;
	}
	
	return PLUGIN_CONTINUE;
}

// Color Chat Stocks
stock const g_szTeamName[Colors][] = 
{
	"UNASSIGNED",
	"TERRORIST",
	"CT",
	"SPECTATOR"
};

stock client_print_color(id, iColor=DontChange, const szMsg[], any:...)
{
	// check if id is different from 0
	if( id && !is_user_connected(id) )
	{
		return 0;
	}

	if( iColor > Grey )
	{
		iColor = DontChange;
	}

	new szMessage[192];
	if( iColor == DontChange )
	{
		szMessage[0] = 0x04;
	}
	else
	{
		szMessage[0] = 0x03;
	}

	new iParams = numargs();
	// Specific player code
	if(id)
	{
		if( iParams == 3 )
		{
			copy(szMessage[1], charsmax(szMessage)-1, szMsg);
		}
		else
		{
			vformat(szMessage[1], charsmax(szMessage)-1, szMsg, 4);
		}

		if( iColor )
		{
			new szTeam[11]; // store current team so we can restore it
			get_user_team(id, szTeam, charsmax(szTeam));

			// set id TeamInfo in consequence
			// so SayText msg gonna show the right color
			Send_TeamInfo(id, id, g_szTeamName[iColor]);

			// Send the message
			Send_SayText(id, id, szMessage);

			// restore TeamInfo
			Send_TeamInfo(id, id, szTeam);
		}
		else
		{
			Send_SayText(id, id, szMessage);
		}
	} 

	// Send message to all players
	else
	{
		// Figure out if at least 1 player is connected
		// so we don't send useless message if not
		// and we gonna use that player as team reference (aka SayText message sender) for color change
		new iPlayers[32], iNum;
		get_players(iPlayers, iNum, "ch");
		if( !iNum )
		{
			return 0;
		}

		new iFool = iPlayers[0];

		new iMlNumber, i, j;
		new Array:aStoreML = ArrayCreate();
		if( iParams >= 5 ) // ML can be used
		{
			for(j=4; j<iParams; j++)
			{
				// retrieve original param value and check if it's LANG_PLAYER value
				if( getarg(j) == LANG_PLAYER )
				{
					i=0;
					// as LANG_PLAYER == -1, check if next parm string is a registered language translation
					while( ( szMessage[ i ] = getarg( j + 1, i++ ) ) ) {}
					if( GetLangTransKey(szMessage) != TransKey_Bad )
					{
						// Store that arg as LANG_PLAYER so we can alter it later
						ArrayPushCell(aStoreML, j++);

						// Update ML array saire so we'll know 1st if ML is used,
						// 2nd how many args we have to alterate
						iMlNumber++;
					}
				}
			}
		}

		// If arraysize == 0, ML is not used
		// we can only send 1 MSG_BROADCAST message
		if( !iMlNumber )
		{
			if( iParams == 3 )
			{
				copy(szMessage[1], charsmax(szMessage)-1, szMsg);
			}
			else
			{
				vformat(szMessage[1], charsmax(szMessage)-1, szMsg, 4);
			}

			if( iColor )
			{
				new szTeam[11];
				get_user_team(iFool, szTeam, charsmax(szTeam));
				Send_TeamInfo(0, iFool, g_szTeamName[iColor]);
				Send_SayText(0, iFool, szMessage);
				Send_TeamInfo(0, iFool, szTeam);
			}
			else
			{
				Send_SayText(0, iFool, szMessage);
			}
		}

		// ML is used, we need to loop through all players,
		// format text and send a MSG_ONE_UNRELIABLE SayText message
		else
		{
			new szTeam[11], szFakeTeam[10];
			
			if( iColor )
			{
				get_user_team(iFool, szTeam, charsmax(szTeam));
				copy(szFakeTeam, charsmax(szFakeTeam), g_szTeamName[iColor]);
			}

			for( i = 0; i < iNum; i++ )
			{
				id = iPlayers[i];

				for(j=0; j<iMlNumber; j++)
				{
					// Set all LANG_PLAYER args to player index ( = id )
					// so we can format the text for that specific player
					setarg(ArrayGetCell(aStoreML, j), _, id);
				}

				// format string for specific player
				vformat(szMessage[1], charsmax(szMessage)-1, szMsg, 4);

				if( iColor )
				{
					Send_TeamInfo(id, iFool, szFakeTeam);
					Send_SayText(id, iFool, szMessage);
					Send_TeamInfo(id, iFool, szTeam);
				}
				else
				{
					Send_SayText(id, iFool, szMessage);
				}
			}
			ArrayDestroy(aStoreML);
		}
	}
	return 1;
}

stock Send_TeamInfo(iReceiver, iPlayerId, szTeam[])
{
	static iTeamInfo = 0;
	if( !iTeamInfo )
	{
		iTeamInfo = get_user_msgid("TeamInfo");
	}
	message_begin(iReceiver ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, iTeamInfo, .player=iReceiver);
	write_byte(iPlayerId);
	write_string(szTeam);
	message_end();
}

stock Send_SayText(iReceiver, iPlayerId, szMessage[])
{
	static iSayText = 0;
	if( !iSayText )
	{
		iSayText = get_user_msgid("SayText");
	}
	message_begin(iReceiver ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, iSayText, .player=iReceiver);
	write_byte(iPlayerId);
	write_string(szMessage);
	message_end();
}