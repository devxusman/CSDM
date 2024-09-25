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

#define VERSION "1.5"

#pragma semicolon 1

enum _:Colors {
	DontChange,
	Red,
	Blue,
	Grey
};

new const g_prefix[] = "[VIP SHOP]";

new	g_pCvarCostFrostNade,
	g_pCvarCostDartPistol,
	g_pCvarCostEthereal,
	g_pCvarCostM4a1Dark,
	g_pCvarCostAkPaladin,
	g_pCvarCostBalrog7;

public plugin_init()
{
	register_plugin("CSDM VIP Shop", VERSION, "TSM - Mr.Pro");

	register_clcmd("vip_shop", "VipShowShop");
	
	g_pCvarCostFrostNade  = register_cvar("vs_frostnade_price", "3000");
	g_pCvarCostDartPistol = register_cvar("vs_dartpistol_price", "10000");
	g_pCvarCostEthereal = register_cvar("vs_ethereal_price", "15000");
	g_pCvarCostM4a1Dark = register_cvar("vs_m4a1dark_price", "17000");
	g_pCvarCostAkPaladin = register_cvar("vs_akpaladin_price", "17000");
	g_pCvarCostBalrog7 = register_cvar("vs_balrog7_price", "20000");
}
 
public VipShowShop(id)
{
	if ( is_user_alive(id) )
	{
		new Text[64];
		{
			new menu = menu_create ("\yCSDM VIP Shop^n \yBy \d[\rTSM - Mr.Pro\d]", "VipShopHandler");
			formatex(Text, charsmax(Text), "\rFrost Nade \w[\dFreeze Player\w] \y$%d", get_pcvar_num(g_pCvarCostFrostNade));
			menu_additem(menu, Text, "1");			
			formatex(Text, charsmax(Text), "\rDart Pistol \w[\dSupreme Damage\w] \y$%d", get_pcvar_num(g_pCvarCostDartPistol));
			menu_additem(menu, Text, "2");
			formatex(Text, charsmax(Text), "\rEthereal \w[\dExtra Damage\w] \y $%d", get_pcvar_num(g_pCvarCostEthereal));
			menu_additem(menu, Text, "3");
			formatex(Text, charsmax(Text), "\rM4A1 DarkKnight \w[\dHigh Damage\w] \y$%d", get_pcvar_num(g_pCvarCostM4a1Dark));
			menu_additem(menu, Text, "4");
			formatex(Text, charsmax(Text), "\rAK Paladin \w[\dHigh Damage\w] \y$%d", get_pcvar_num(g_pCvarCostAkPaladin));
			menu_additem(menu, Text, "5");
			formatex(Text, charsmax(Text), "\rBalrog-VII \w[\dMachine Gun + Extreme DMG\w] \y$%d", get_pcvar_num(g_pCvarCostBalrog7));
			menu_additem(menu, Text, "6");
			menu_addblank(menu, 0);
			menu_additem(menu, "Exit", "10");

			menu_setprop(menu, MPROP_PERPAGE, 0);

			menu_display(id, menu);
		}
	}
}
public VipShopHandler(id, menu, item)
{
	
	new iMoney = cs_get_user_money(id);

	switch(item+1)
	{	
		case 1:
		{
			if ( iMoney >= get_pcvar_num(g_pCvarCostFrostNade))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarCostFrostNade));
				client_cmd(id, "csdm_vs_frostnade");
				client_print_color(id, DontChange, "^4%s ^3Have Fun With ^4Frost Nade", g_prefix);
			}

			else
			{
				client_print_color(id, DontChange, "^4%s ^3You Don't Have Money To Buy ^4Frost Nade ^1(^4Need %d$^1)", g_prefix, get_pcvar_num(g_pCvarCostFrostNade));
			}
		}
		
		case 2:
		{
			if ( iMoney >= get_pcvar_num(g_pCvarCostDartPistol))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarCostDartPistol));
				client_cmd(id, "csdm_vs_dartpistol");
				client_print_color(id, DontChange, "^4%s ^3Have Fun With ^4Dart Pistol", g_prefix);
			}

			else
			{
				client_print_color(id, DontChange, "^4%s ^3You Don't Have Money To Buy ^4Dart Pistol ^1(^4Need %d$^1)", g_prefix, get_pcvar_num(g_pCvarCostDartPistol));
			}
		}

		case 3:
		{
			if ( iMoney >= get_pcvar_num(g_pCvarCostEthereal))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarCostEthereal));
				client_cmd(id, "csdm_vs_ethereal");
				client_print_color(id, DontChange, "^4%s ^3Have Fun With ^4Ethereal", g_prefix);
			}

			else
			{
				client_print_color(id, DontChange, "^4%s ^3You Don't Have Money To Buy ^4Ethereal ^1(^4Need %d$^1)", g_prefix, get_pcvar_num(g_pCvarCostEthereal));
			}
		}

		case 4:
		{
			if ( iMoney >= get_pcvar_num(g_pCvarCostM4a1Dark))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarCostM4a1Dark));
				client_cmd(id, "csdm_vs_m4a1dark");
				client_print_color(id, DontChange, "^4%s ^3Have Fun With ^4M4A1 DarkKnight", g_prefix);
			}
				
			else
			{
				client_print_color(id, DontChange, "^4%s ^3You Don't Have Money To Buy ^4M4A1 DarkKnight ^1(^4Need %d$^1)", g_prefix, get_pcvar_num(g_pCvarCostM4a1Dark));
			}
		}

		case 5:
		{
			if ( iMoney >= get_pcvar_num(g_pCvarCostAkPaladin))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarCostAkPaladin));
				client_cmd(id, "csdm_vs_akpaladin");
				client_print_color(id, DontChange, "^4%s ^3Have Fun With ^4AK Paladin", g_prefix);
			}
			
			else
			{
				client_print_color(id, DontChange, "^4%s ^3You Don't Have Money To Buy ^4AK Paladin ^1(^4Need %d$^1)", g_prefix, get_pcvar_num(g_pCvarCostAkPaladin));
			}
		}
		case 6:
		{
			if ( iMoney >= get_pcvar_num(g_pCvarCostBalrog7))
			{
				cs_set_user_money(id, iMoney - get_pcvar_num(g_pCvarCostBalrog7));
				client_cmd(id, "csdm_vs_buy_balrog7");
				client_print_color(id, DontChange, "^4%s ^3Have Fun With ^4Balrog-VII", g_prefix);
			}
			
			else
			{
				client_print_color(id, DontChange, "^4%s ^3You Don't Have Money To Buy ^4Balrog-VII ^1(^4Need %d$^1)", g_prefix, get_pcvar_num(g_pCvarCostBalrog7));
			}
		}		
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

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