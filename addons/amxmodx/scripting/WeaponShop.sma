#include <amxmodx>
#include <cstrike>
#include <fun>
#include <hamsandwich>
#include <fakemeta>
#include <engine>

#define NORMAL DontChange
#define GREEN DontChange
#define TEAM_COLOR DontChange
#define RED Red
#define BLUE Blue
#define GREY Grey
#define ColorChat client_print_color

#define VERSION "1.0"

//#define IsPlayer(%1) ( 1 <= %1 <= g_iMaxPlayers )

//#define Ham_Player_ResetMaxSpeed Ham_Item_PreFrame

#pragma semicolon 1

enum _:Colors {
	DontChange,
	Red,
	Blue,
	Grey
};

new const g_prefix[] = "[CSDM Weapon Shop]";

//new g_iMaxPlayers;

new g_pCvarCostHe,
	g_pCvarCostAk47,
	g_pCvarCostM4a1,
	g_pCvarCostM249,
	g_pCvarCostMp5,
	g_pCvarCostSg550,
	g_pCvarCostg3sg1,
	g_pCvarCostAug,
	g_pCvarCostGoldenAk;

public plugin_init()
{
	register_plugin("Weapon Shop", VERSION, "TSM - Mr.Pro");

	register_clcmd("weapon_shop", "ShowShop");

	g_pCvarCostHe = register_cvar("shopweap_he_grenade", "500");
	g_pCvarCostAk47 = register_cvar("shopweap_ak47", "3000");
	g_pCvarCostM4a1 = register_cvar("shopweap_m4a1", "3000");
	g_pCvarCostM249 = register_cvar("shopweap_m249", "5000");
	g_pCvarCostMp5 = register_cvar("shopweap_mp5", "1500");
	g_pCvarCostSg550 = register_cvar("shopweap_sg550", "5000");
	g_pCvarCostg3sg1 = register_cvar("shopweap_g3sg1", "5000");
	g_pCvarCostAug = register_cvar("shopweap_aug", "3000");
	g_pCvarCostGoldenAk = register_cvar("shopweap_goldenak", "30000");

	//RegisterHam(Ham_Spawn, "player", "Player_Spawn_Post", 1);
	//RegisterHam(Ham_TakeDamage, "player", "ham_TakeDamage_Pre");
	//RegisterHam(Ham_Item_Deploy, "weapon_knife", "ham_ItemDeploy_Post", 1);
	//RegisterHam(Ham_Player_ResetMaxSpeed, "player", "Player_ResetMaxSpeed",  1);
	
	//g_iMaxPlayers = get_maxplayers();
}
 
public ShowShop(id)
{
	if ( is_user_alive(id) )
	{
		new Text[64];
		{
			new menu = menu_create ("\yCSDM Weapon Shop^n \yBy \d[\rTSM - Mr.Pro\d]", "ShopHandler");
			
			formatex(Text, charsmax(Text), "\rHe Grenade \y$%d", get_pcvar_num(g_pCvarCostHe));
			menu_additem(menu, Text, "1");
			formatex(Text, charsmax(Text), "\rAk47 \w[\dAssualt Rifle\w] \y $%d", get_pcvar_num(g_pCvarCostAk47));
			menu_additem(menu, Text, "2");
			formatex(Text, charsmax(Text), "\rM4A1 Carbine \w[\dAssualt Rifle\w] \y$%d", get_pcvar_num(g_pCvarCostM4a1));
			menu_additem(menu, Text, "3");
			formatex(Text, charsmax(Text), "\rM249 \w[\dMachine Gun\w] \y$%d", get_pcvar_num(g_pCvarCostM249));
			menu_additem(menu, Text, "4");
			formatex(Text, charsmax(Text), "\yMP5 \w[\dSub-Machine Gun\w] \y$%d", get_pcvar_num(g_pCvarCostMp5));
			menu_additem(menu, Text, "5");
			formatex(Text, charsmax(Text), "\ySG550 \w[\dAuto-Sniper\w] \y$%d", get_pcvar_num(g_pCvarCostSg550));
			menu_additem(menu, Text, "6");
			formatex(Text, charsmax(Text), "\yG3SG1 \w[\dAuto-Sniper\w] \y$%d", get_pcvar_num(g_pCvarCostg3sg1));
			menu_additem(menu, Text, "7");
			formatex(Text, charsmax(Text), "\yAUG \w[\dAssault Rifle\w] \y$%d", get_pcvar_num(g_pCvarCostAug));
			menu_additem(menu, Text, "8");
			formatex(Text, charsmax(Text), "\yGolden Ak47 \w[\dGolden Weapon\w] \y$%d", get_pcvar_num(g_pCvarCostGoldenAk));
			menu_additem(menu, Text, "9");
			menu_addblank(menu, 0);
			menu_additem(menu, "Exit", "10");

			menu_setprop(menu, MPROP_PERPAGE, 0);

			menu_display(id, menu);
		}
	}
}
public ShopHandler(id, menu, item)
{
	
	new iMoney = cs_get_user_money(id);

	switch(item+1)
	{       
		case 1:
		{
			if ( iMoney >= get_pcvar_num(g_pCvarCostHe))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarCostHe));
				give_item(id,"weapon_hegrenade");
				client_print_color(id, DontChange, "^4%s ^3Have Fun With ^4He Grenade", g_prefix);
			}

			else
			{
				client_print_color(id, DontChange, "^4%s ^3You Don't Have Money To Buy ^4He Grenade ^1(^4Need %d$^1)", g_prefix, get_pcvar_num(g_pCvarCostHe));
			}
		}

		case 2:
		{
			if ( iMoney >= get_pcvar_num(g_pCvarCostAk47))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarCostAk47));
				give_item(id,"weapon_ak47");
				give_item(id,"ammo_762nato");
				give_item(id,"ammo_762nato");
				give_item(id,"ammo_762nato"); 
				client_print_color(id, DontChange, "^4%s ^3Have Fun With ^4Ak47", g_prefix);
			}

			else
			{
				client_print_color(id, DontChange, "^4%s ^3You Don't Have Money To Buy ^4Ak47 ^1(^4Need %d$^1)", g_prefix, get_pcvar_num(g_pCvarCostAk47));
			}
		}

		case 3:
		{
			if ( iMoney >= get_pcvar_num(g_pCvarCostM4a1))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarCostM4a1));
				give_item(id,"weapon_m4a1");
				give_item(id,"ammo_556nato");
				give_item(id,"ammo_556nato");
				give_item(id,"ammo_556nato");
				client_print_color(id, DontChange, "^4%s ^3Have Fun With ^4M4A1 Carbine", g_prefix);
			}
				
			else
			{
				client_print_color(id, DontChange, "^4%s ^3You Don't Have Money To Buy ^4M4A1 Carbine ^1(^4Need %d$^1)", g_prefix, get_pcvar_num(g_pCvarCostM4a1));
			}
		}

		case 4:
		{
			if ( iMoney >= get_pcvar_num(g_pCvarCostM249))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarCostM249));
				give_item(id,"weapon_m249");
				give_item(id,"ammo_762nato");
				give_item(id,"ammo_762nato");
				give_item(id,"ammo_762nato");
				give_item(id,"ammo_762nato");
				client_print_color(id, DontChange, "^4%s ^3Have Fun With ^4M249", g_prefix);
			}
			
			else
			{
				client_print_color(id, DontChange, "^4%s ^3You Don't Have Money To Buy ^4M249 ^1(^4Need %d$^1)", g_prefix, get_pcvar_num(g_pCvarCostM249));
			}
		}
		case 5:
		{
			if ( iMoney >= get_pcvar_num(g_pCvarCostMp5))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarCostMp5));
				give_item(id,"weapon_mp5navy");
				give_item(id,"ammo_556nato");
				give_item(id,"ammo_556nato");
				give_item(id,"ammo_556nato");
				give_item(id,"ammo_556nato");
				client_print_color(id, DontChange, "^4%s ^3Have Fun With ^4MP5", g_prefix);
			}
			
			else
			{
				client_print_color(id, DontChange, "^4%s ^3You Don't Have Money To Buy ^4MP5 ^1(^4Need %d$^1)", g_prefix, get_pcvar_num(g_pCvarCostMp5));
			}
		}
		case 6:
		{
			if ( iMoney >= get_pcvar_num(g_pCvarCostSg550))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarCostSg550));
				give_item(id,"weapon_sg550");
				give_item(id,"ammo_556nato");
				give_item(id,"ammo_556nato");
				give_item(id,"ammo_556nato");
				give_item(id,"ammo_556nato");
				client_print_color(id, DontChange, "^4%s ^3Have Fun With ^4SG550 Auto-Sniper", g_prefix);
			}
			
			else
			{
				client_print_color(id, DontChange, "^4%s ^3You Don't Have Money To Buy ^4SG550 Auto-Sniper ^1(^4Need %d$^1)", g_prefix, get_pcvar_num(g_pCvarCostSg550));
			}
		}
		case 7:
		{
			if ( iMoney >= get_pcvar_num(g_pCvarCostg3sg1))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarCostg3sg1));
				give_item(id,"weapon_g3sg1");
				give_item(id,"ammo_762nato");
				give_item(id,"ammo_762nato");
				give_item(id,"ammo_762nato");
				give_item(id,"ammo_762nato");
				client_print_color(id, DontChange, "^4%s ^3Have Fun With ^4G3SG1 Auto-Sniper", g_prefix);
			}
			
			else
			{
				client_print_color(id, DontChange, "^4%s ^3You Don't Have Money To Buy ^4G3SG1 Auto-Sniper ^1(^4Need %d$^1)", g_prefix, get_pcvar_num(g_pCvarCostg3sg1));
			}
		}
		
		case 8:
		{
			if ( iMoney >= get_pcvar_num(g_pCvarCostAug))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarCostAug));
				give_item(id,"weapon_aug");
				give_item(id,"ammo_556nato");
				give_item(id,"ammo_556nato");
				give_item(id,"ammo_556nato");
				give_item(id,"ammo_556nato");
				client_print_color(id, DontChange, "^4%s ^3Have Fun With ^4AUG", g_prefix);
			}
			
			else
			{
				client_print_color(id, DontChange, "^4%s ^3You Don't Have Money To Buy ^4AUG ^1(^4Need %d$^1)", g_prefix), get_pcvar_num(g_pCvarCostAug);
			}
		}
		case 9:
		{
			if ( iMoney >= get_pcvar_num(g_pCvarCostGoldenAk))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarCostGoldenAk));
				client_cmd(id, "csdm_buy_goldenak");
				client_print_color(id, DontChange, "^4%s ^3Have Fun With ^4Golden-AK47", g_prefix);
			}
			
			else
			{
				client_print_color(id, DontChange, "^4%s ^3You Don't Have Money To Buy ^4Golden-AK47 ^1(^4Need %d$^1)", g_prefix, get_pcvar_num(g_pCvarCostGoldenAk));
			}
		}		
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
 
 
 
 
/*public plugin_precache()
{

}
 
//public ham_TakeDamage_Pre(victim, inflictor, attacker, Float:damage, damage_bits)
//{
//
//	{
//		SetHamParamFloat( 4, damage * 77 );
//	}
//}
 
 
public ham_ItemDeploy_Post(weapon_ent)
{
	static owner;
	owner = get_pdata_cbase(weapon_ent, 41, 4);


	{

	}
}*/


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

/*stock register_dictionary_colored(const filename[])
{
	if( !register_dictionary(filename) )
	{
		return 0;
	}

	new szFileName[256];
	get_localinfo("amxx_datadir", szFileName, charsmax(szFileName));
	format(szFileName, charsmax(szFileName), "%s/lang/%s", szFileName, filename);
	new fp = fopen(szFileName, "rt");
	if( !fp )
	{
		log_amx("Failed to open %s", szFileName);
		return 0;
	}

	new szBuffer[512], szLang[3], szKey[64], szTranslation[256], TransKey:iKey;

	while( !feof(fp) )
	{
		fgets(fp, szBuffer, charsmax(szBuffer));
		trim(szBuffer);

		if( szBuffer[0] == '[' )
		{
			strtok(szBuffer[1], szLang, charsmax(szLang), szBuffer, 1, ']');
		}
		else if( szBuffer[0] )
		{
			strbreak(szBuffer, szKey, charsmax(szKey), szTranslation, charsmax(szTranslation));
			iKey = GetLangTransKey(szKey);
			if( iKey != TransKey_Bad )
			{
				while( replace(szTranslation, charsmax(szTranslation), "!g", "^4") ){}
				while( replace(szTranslation, charsmax(szTranslation), "!t", "^3") ){}
				while( replace(szTranslation, charsmax(szTranslation), "!n", "^1") ){}
				AddTranslation(szLang, iKey, szTranslation[2]);
			}
		}
	}
	
	fclose(fp);
	return 1;
}*/