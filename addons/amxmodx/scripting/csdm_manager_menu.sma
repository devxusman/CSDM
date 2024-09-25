#include <amxmodx>
#include <amxmisc>

/******************************************************************
* THIS PLUGIN WAS MADE IN MOROCCO								  *
* DONT LEECH THIS PLUGIN JUST BECAUSE IT IS PROVIDED FOR FREE  *
* Please Respect The Original Authors							  *
*******************************************************************/

enum _:PlayerData
{
	g_szName[32],
	g_szSteamID[32],
	g_iOption,
	g_iPlayer,
	g_iChoosen
}

new g_PlayerInfo[33][PlayerData]

#define MANAGER_FLAG ADMIN_LEVEL_A

enum
{
	DIR_USERS
}

new const g_szDataDir[][] =
{
	"addons/amxmodx/configs/users.ini"
}

enum RELOAD_TYPE
{
	RLD_ADMINS
}

new const g_szReloadCmds[RELOAD_TYPE][] =
{
	"amx_reloadadmins"
}

new const g_szZPMenuItems[][] =
{
	"\wRank \rMenu"
}

new const g_szZPRankMenuItems[][] =
{
	"\yGive Rank",
	"\yRemove Rank",
	"\yReload Ranks"
}
//*/**/**/*/*/*/*/*/*/ Change or Add The Ranks Names and Flags Here (Respectively) //*/*/*/*/*/*/*/*//
//Note Last line should not have a comma ',' but other should have one ',' as you can notice
new const g_szRanks[][] =
{
	"OWNER",
	"MANAGER",
	"HEAD ADMIN",
	"SUPER-ADMIN",
	"ADMIN",
	"VIP"
}

new const g_szFlags[][] =
{
	"abcdefghijklmnopqrstuvwxy",
	"abcdefgijmnopqrstu",
	"abcdefijnopqrstu",
	"bcdefijnorspqt",
	"bcdefijknot",
	"bit"
}

//***********************************************************************************************************************************//

public plugin_init()
{
	register_plugin("[CSDM] Manager Menu", "1.3", "ZinoZack47, Bara & TSM - Mr.Pro")
	register_concmd("csdmmanagermenu", "CheckAccess")
	register_concmd("ENTER_PW", "PwEntred")
	
}

public client_authorized(id)
{
	get_user_name(id, g_PlayerInfo[id][g_szName], charsmax(g_PlayerInfo[][g_szName]))
	get_user_authid(id, g_PlayerInfo[id][g_szSteamID], charsmax(g_PlayerInfo[][g_szSteamID]))
}

public CheckAccess(id)
{
	if(get_user_flags(id) & MANAGER_FLAG)
		CSDMRankMenu(id)
	else
		zino_colored_print(id, "!g[CSDM-ADMIN MANAGER]!t Only !gManagers !tCan Use This !gMenu!t.")
}

public CSDMRankMenu(id)
{
	zino_colored_print(id, "!g[CSDM]!y Welcome To The !gManager Menu!t %s", g_PlayerInfo[id][g_szName])
	
	new iMenuID = menu_create("\r.::[\y CSDM \rManager \d: \yMenu\r]::.^n\r.::[\yBy \rTSM - Mr.Pro\r]::.", "CSDMMenuHandle")
	for(new i=0; i<sizeof(g_szZPMenuItems); i++) menu_additem(iMenuID, g_szZPMenuItems[i])
	menu_display(id, iMenuID)

}

public CSDMMenuHandle(id, iMenuID, iItem)
{
	if(iItem == MENU_EXIT)
	{
		menu_destroy(iMenuID)
		return;
	}
	switch(iItem)
	{
		case 0: RankMenu(id)
	}
	
	g_PlayerInfo[id][g_iOption] = iItem+1
	
}

public RankMenu(id)
{	
	new iMenuID = menu_create("\yRank Menu^n\wBy \rTSM - Mr.Pro\w:", "RankMenuHandle")
	for(new i=0; i<sizeof(g_szZPRankMenuItems); i++) menu_additem(iMenuID, g_szZPRankMenuItems[i])
	menu_display(id, iMenuID)
}

public RankMenuHandle(id, iMenuID, iItem)
{
	if(iItem == MENU_EXIT)
	{
		menu_destroy(iMenuID);
		return;
	}
	
	switch(iItem)
	{
		case 0: AddRankMenu(id)
		case 1: ChooseRrankPlayer(id)
		case 2: Reload(RLD_ADMINS)
	}
}

public AddRankMenu(id)
{
	new iMenuID = menu_create("\yAdmin Manager Menu^n\wBy \rTSM - Mr.Pro\w:", "AddRankMenuHandle")
	new szText[128]
	for(new i=0; i<sizeof(g_szRanks) && i<sizeof(g_szFlags); i++)
	{
		formatex(szText, charsmax(szText), "\y%s \w(\r %s \w)", g_szRanks[i] ,g_szFlags[i])
		menu_additem(iMenuID, szText)
	}
	menu_display(id, iMenuID)
}

public AddRankMenuHandle(id, iMenuID, iItem)
{
	if(iItem == MENU_EXIT)
	{
		menu_destroy(iMenuID);
		return;
	}
	
	switch(iItem)
	{
		case 0 .. 10:
		{
			g_PlayerInfo[id][g_iOption] = iItem+1
			ChooseRankPlayer(id)
		}
	}
}

public ChooseRankPlayer(id)
{
	new szItem[32], iMenuID = menu_create("\yChoose Target \w:", "ChooseRankPlayerHandle");
	
	for(new i=0, n=0; i<=32; i++)
	{
		if(!is_user_connected(i)) continue
		
		g_PlayerInfo[n++][g_iPlayer] = i
		
		get_user_name(i, szItem, charsmax(szItem))
		menu_additem(iMenuID, szItem, "0", 0)
	}
	
	menu_display(id, iMenuID)
}

public ChooseRankPlayerHandle(id, iMenuID, iItem)
{
	if(iItem == MENU_EXIT)
	{
		menu_destroy(iMenuID)
		return;
	}
	
	g_PlayerInfo[id][g_iChoosen] = g_PlayerInfo[iItem][g_iPlayer]
	
	if(!is_user_connected(g_PlayerInfo[id][g_iChoosen]))
	{
		zino_colored_print(id,  "!g[CSDM] !tTarget Not Founded In The Server.")
		AddRankMenu(id)
		return;
	}
	
	client_cmd(id, "messagemode ENTER_PW")
}

public PwEntred(id)
{
	new szPassword[20]
	read_argv(1, szPassword, charsmax(szPassword))
	
	if (strlen(szPassword) < 3)
	{
		zino_colored_print(id, "!g[CSDM]!t Invalid Password !y(!gReason !y: !g%s!y).", !strlen(szPassword) ? "EMPTY" : "TOO SHORT");
		AddRankMenu(id);
		return;
	}
	if (strlen(szPassword) > 18)
	{
		zino_colored_print(id, "!g[CSDM]!y Invalid Password !y(!gReason !y: !gToo Long!y).");
		AddRankMenu(id);
		return;
	}
	for(new i = 0; i < sizeof(szPassword); i++)
	{
		if (isspace(szPassword[i]))
		{
			zino_colored_print(id, "!g[CSDM]!t Invalid Password !y(!gReason !y: !gContaining Spaces!y).");
			AddRankMenu(id);
			return;
		}	
	}


	new g_admin = is_user_admin(g_PlayerInfo[id][g_iChoosen])
	
	new szText[256]
	for(new i = 1; i < sizeof(g_szRanks) && i < sizeof(g_szFlags); i++)
	{
		if (g_PlayerInfo[id][g_iOption] == i)
		{
			formatex(szText, charsmax(szText), "^"%s^" ^"%s^" ^"%s^" ^"a^" ; [%s] [%s]", g_PlayerInfo[g_PlayerInfo[id][g_iChoosen]][g_szName], szPassword, g_szFlags[i-1], g_PlayerInfo[g_PlayerInfo[id][g_iChoosen]][g_szSteamID], g_szRanks[i-1]);
			zino_colored_print(0,  "!g[CSDM] !t%s !yHas Made !t%s !g%s.", g_PlayerInfo[id][g_szName], g_PlayerInfo[g_PlayerInfo[id][g_iChoosen]][g_szName], g_szRanks[i-1]);
			g_admin ? remove_admin(g_PlayerInfo[id][g_iChoosen], szText) : write_file(g_szDataDir[DIR_USERS], szText);
			zino_colored_print(g_PlayerInfo[id][g_iChoosen], "!g[CSDM]!y You Got A !tNew Rank!y On This Server. Check Your !gConsole For More Info!");
			client_print(g_PlayerInfo[id][g_iChoosen], print_console, "//***[CSDM] You Are Now %s. Next Map Disconnect And Copy Paste This On your console: setinfo _pw ^"%s^" and You're Done***\\", g_szRanks[i-1], szPassword);
		}
	}
	
}

public ChooseRrankPlayer(id)
{
	new szItem[32], iMenuID = menu_create("\yChoose Target \w:", "ChooseRrankPlayerHandle");
	
	for(new i=0, n=0; i<=32; i++)
	{
		if(!is_user_connected(i)) continue;
		
		if(get_user_flags(i) & ADMIN_USER) continue;
		
		g_PlayerInfo[n++][g_iPlayer] = i;
		
		get_user_name(i, szItem, charsmax(szItem));
		menu_additem(iMenuID, szItem, "0", 0);
	}
	
	menu_display(id, iMenuID);
}

public ChooseRrankPlayerHandle(id, iMenuID, iItem)
{
	if(iItem == MENU_EXIT)
	{
		menu_destroy(iMenuID);
		return;
	}
	
	g_PlayerInfo[id][g_iChoosen] = g_PlayerInfo[iItem][g_iPlayer];
	
	if(!is_user_connected(g_PlayerInfo[id][g_iChoosen]))
	{
		zino_colored_print(id,  "!g[CSDM] !tTarget Not Founded In The Server.");
		return;
	}
	
	remove_admin(g_PlayerInfo[id][g_iChoosen])
	
	zino_colored_print(id, "!g[CSDM] !tYou !tHave Removed !t%s !yRank.", g_PlayerInfo[g_PlayerInfo[id][g_iChoosen]][g_szName]);
}
	
stock remove_admin(Player, Text[] = "")
{
	new szText[256], iLine, iLen, szLineData[4][32]

	while((iLine = read_file(g_szDataDir[DIR_USERS], iLine, szText, charsmax(szText), iLen)))
	{
		if(!iLen || szText[0] == ';' || szText[0] == '/' && szText[1] == '/') continue;
		if(parse(szText, szLineData[0], charsmax(szLineData[]), szLineData[1], charsmax(szLineData[]), szLineData[2], charsmax(szLineData[]), szLineData[3], charsmax(szLineData[])) < 4) continue;
		if(equal(g_PlayerInfo[Player][g_szName], szLineData[0]) || equal(g_PlayerInfo[Player][g_szSteamID], szLineData[0]))
			equal(Text, "") ? delete_line(g_szDataDir[DIR_USERS], iLine) : write_file(g_szDataDir[DIR_USERS], Text, iLine-1);
	}
}

//Special Thanks to Raheem
stock delete_line(const szFile[], iLine)
{
	if (file_exists(szFile))
	{
		new iMaxLines = file_size(szFile, 1)
		
		new Array:szFileLines, szLine[512], iTextLen
		
		szFileLines = ArrayCreate(512)
		
		for (new iLineToRead = 0; iLineToRead < iMaxLines; iLineToRead++)
		{
			if (iLineToRead + 1 == iLine)
				continue
			
			read_file(szFile, iLineToRead, szLine, charsmax(szLine), iTextLen)
			
			ArrayPushString(szFileLines, szLine)
		}
		
		delete_file(szFile)
		
		for (new iLineToRead = 0; iLineToRead < ArraySize(szFileLines); iLineToRead++)
		{
			ArrayGetString(szFileLines, iLineToRead, szLine, charsmax(szLine))
			
			write_file(szFile, szLine)
		}
		
		ArrayDestroy(szFileLines)
	}
}

stock Reload(RELOAD_TYPE:iType) server_cmd(g_szReloadCmds[iType])

// Stock: zino_colored_print
stock zino_colored_print(const id, const input[], any:...)
{
	new count = 1, players[32]
	static msg[191]
	vformat(msg, 190, input, 3)

	replace_all(msg, 190, "!g", "^4");
	replace_all(msg, 190, "!y", "^1");
	replace_all(msg, 190, "!t", "^3");

	if (id) players[0] = id; else get_players(players, count, "ch")
	{
		for (new i = 0; i < count; i++)
		{
			if (is_user_connected(players[i]))
			{
				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i])
				write_byte(players[i]);
				write_string(msg);
				message_end();
			}
		}
	}
}
