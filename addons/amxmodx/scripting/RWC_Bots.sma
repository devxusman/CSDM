#include < amxmodx >
#include < cstrike >
#include < fakemeta >

enum Cvars
{
    botname1,
    botname2,
	botname3,
    minplayers,
    starttime,
    endtime,
    onecon,
    onebot,
    norounds
};

new const cvar_names[ Cvars ][] =
{
    "amx_botname",
    "amx_botname2",
	"amx_botname3",
    "amx_minplayers",
    "amx_starttime",
    "amx_endtime",
    "amx_onecon",
    "amx_onebot",
    "amx_norounds"
};

new const cvar_defaults[ Cvars ][] =
{
    "1x Boost = 1 Month VIP",
    "3x Boost = 1 Month Admin",
	"100H Free ADMINSHIP",
    "29",
    "00",
    "24",
    "0",
    "0",
    "0"
};

// Message IDs vars
new g_msgTeamInfo;

//Offsets
#define m_iTeam  114
#define CBASEMONSTER_LINUX_XTRA_OFF     5 

new cvar_pointer[ Cvars ];
new bool:g_isTime = false;
new bool:g_ePlayers = false;
new bool:g_isFirstRound = true;
new g_BotNum = 0, g_maxplayers, g_bID1, g_bID2;

new const g_ConfigFile[] = "addons/amxmodx/configs/rwcbots.cfg"

public plugin_init() 
{
    register_plugin("RWC Bots", "2.3", "OvidiuS & Desikac")
    register_cvar("rwcbots", "1" , (FCVAR_SERVER|FCVAR_SPONLY))
    
    register_logevent("Event_RoundEnd", 2, "1=Round_End");
    register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0");
    // Message IDs
    g_msgTeamInfo = get_user_msgid("TeamInfo"); 
	
    for ( new Cvars:i = botname1 ; i < Cvars ; i++ )
        cvar_pointer[ i ] = register_cvar( cvar_names[ i ] , cvar_defaults[ i ] );
    
    g_maxplayers = get_maxplayers();
    server_cmd("exec %s", g_ConfigFile)
    set_task(3.0, "isit")
}

public isit() {
    if(get_pcvar_num(cvar_pointer[norounds]))
        set_task(30.0, "CheckConditions",0,"",0,"b")
}

public plugin_precache() 
{
    if(!file_exists(g_ConfigFile)) 
    {
		write_file(g_ConfigFile, "RWC Bots - Settings^n")
		write_file(g_ConfigFile, "amx_botname ^"1x Boost = 1 Month VIP^"   //First Bot Name")
		write_file(g_ConfigFile, "amx_botname2 ^"3x Boost = 1 Month Admin^"   //The Name of 2nd Bot")
		write_file(g_ConfigFile, "amx_botname3 ^"100H Free ADMINSHIP^"   //The Name of 3rd Bot")
		write_file(g_ConfigFile, "amx_minplayers ^"29^"   //Bots will only be dropped if the number of players is smaller than this value.")
		write_file(g_ConfigFile, "amx_starttime ^"0^"   //How many hours are the bots on the server?")
		write_file(g_ConfigFile, "amx_endtime ^"24^"   //How many hours do the bots be on the server?")
		write_file(g_ConfigFile, "amx_onecon ^"0^"   //Should only one condition be met to add bots?")
		write_file(g_ConfigFile, "amx_onebot ^"0^"   //Does plugin use only one Bot?")
		write_file(g_ConfigFile, "amx_norounds ^"0^"   //Does not this round end on this server?")
    }
}

public Event_RoundEnd()
{
    if (!g_isFirstRound)
        return;
 
    g_isFirstRound = false;
}

public Event_NewRound()
{
    if(g_isFirstRound)
        return;
        
    CheckConditions();
}

public CheckConditions()
{
    static iHours, m, s
    time(iHours, m, s)

    new iMin = get_pcvar_num(cvar_pointer[ starttime ]);
    new iMax = get_pcvar_num(cvar_pointer[ endtime ]);
    
    if(iMin == iMax)
        g_isTime = true;
    else if(iMin > iMax) 
    {
        switch(iHours) 
        {
            case 0..11: 
            {
                if(iMin >= iHours && iMax > iHours)
                    g_isTime = true;
            }
            case 12..23: 
            {
                if(iMin <= iHours && iMax < iHours)
                    g_isTime = true;
            }
        }
    }
    else if(iMin <= iHours && iMax > iHours)
        g_isTime = true;
    else 
        g_isTime = false;
        
    new iNum, iPlayers[32];
    get_players(iPlayers, iNum, "c");
    
    if(iNum <= get_pcvar_num(cvar_pointer[minplayers]))
        g_ePlayers = true;
    else
        g_ePlayers = false;

    if(g_maxplayers - iNum < 2)
        g_ePlayers = false;
    
    if(get_pcvar_num(cvar_pointer[minplayers]) == 0)
        g_ePlayers = true
    
    new iCondition = get_pcvar_num(cvar_pointer[ onecon ]);
    if( (!g_ePlayers && g_isTime || !g_isTime && g_ePlayers) && iCondition) 
    {
        g_isTime = true;
        g_ePlayers = true;
    }
    
    
        
    if((g_isTime && g_ePlayers) && !g_BotNum)
    {
        if(!get_pcvar_num(cvar_pointer[onebot]))
            set_task(1.5, "Task_AddBot")
        set_task(2.8, "Task_AddBot")
    }
    else if((!g_isTime || !g_ePlayers) && 0 < g_BotNum <= 2 )
    {
        g_BotNum = 0;
        server_cmd("kick #%d", g_bID1)
        server_cmd("kick #%d", g_bID2)
    }
}

public Task_AddBot()
{
    static iBot;
    new iBotName[35];
    
    switch(g_BotNum)
    {
        case 0: get_pcvar_string(cvar_pointer[ botname1 ], iBotName, charsmax( iBotName ));
        case 1:    get_pcvar_string(cvar_pointer[ botname2 ], iBotName, charsmax( iBotName ));
        case 2: return;
    }

    iBot = engfunc( EngFunc_CreateFakeClient, iBotName );
    
    if(!iBot)
        return;
        
    dllfunc( MetaFunc_CallGameEntity, "player", iBot );
    set_pev( iBot, pev_flags, FL_FAKECLIENT );

    set_pev( iBot, pev_model, "" );
    set_pev( iBot, pev_viewmodel2, "" );
    set_pev( iBot, pev_modelindex, 0 );

    set_pev( iBot, pev_renderfx, kRenderFxNone );
    set_pev( iBot, pev_rendermode, kRenderTransAlpha );
    set_pev( iBot, pev_renderamt, 0.0 );

    set_pdata_int( iBot, 114, 3 );
    cs_set_user_team( iBot, CS_TEAM_UNASSIGNED );
    
    switch(g_BotNum) 
    {
        case 0: g_bID1 = get_user_userid(iBot);
        case 1: g_bID2 = get_user_userid(iBot);
    }
    g_BotNum++;
	
	if(pev_valid(iBot) != 2)
        return;

    set_pdata_int(iBot, m_iTeam, 3, CBASEMONSTER_LINUX_XTRA_OFF);
    
    dllfunc(DLLFunc_ClientUserInfoChanged, iBot, engfunc(EngFunc_GetInfoKeyBuffer, iBot));

        message_begin(MSG_BROADCAST, g_msgTeamInfo);
    write_byte(iBot);
    write_string("SPECTATOR");
    message_end(); 

}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/ 