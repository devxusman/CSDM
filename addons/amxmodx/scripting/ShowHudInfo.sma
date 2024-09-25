#include < amxmodx >
#include < fakemeta >
#include < hamsandwich >
#include < cstrike >
#include < crxranks >

new const PLUGIN_NAME[  ] = "Hud Info( Show Armor / Health / Money )";
new const PLUGIN_VERSION[  ] = "1.1";
new const PLUGIN_AUTHOR[  ] = "LuXo KING Gaming & TSM - Mr.Pro";

#define ColorRed		0
#define ColorGreen	255
#define ColorBlue		0
#define SpecColorRed	0
#define SpecColorGreen	200
#define SpecColorBlue	200

// Thanks Aragon for this codes( director HUD )

#define clamp_byte(%1)		( clamp( %1, 0, 255 ) )
#define pack_color(%1,%2,%3)	( %3 + ( %2 << 8 ) + ( %1 << 16 ) )
const PEV_SPEC_TARGET = pev_iuser2;
new SyncHudMessage;
new g_cvar_show_type;

public plugin_init(  ) {
    register_plugin( PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR );
    register_event( "ResetHUD", "event_ResetHud", "be" );
    RegisterHam( Ham_Spawn, "player", "Ham_PlayerSpawnedPost", 1 );
    g_cvar_show_type = register_cvar( "csdm_hudinfo_show", "1" );
    SyncHudMessage = CreateHudSyncObj(  );
}
public Ham_PlayerSpawnedPost( id )
if( is_user_connected( id ) )
    set_task( 1.0, "ShowHud", id, _, _, "b" );

public event_ResetHud( id )
    ShowHud( id );

public ShowHud( id ) {
    switch( get_pcvar_num( g_cvar_show_type ) ) {
        case 0: {
            if( is_user_alive( id ) && ( get_user_team( id ) == 1 || get_user_team( id ) == 2 ) ) {
    			new szPlayerName[ 32 ];
    			get_user_name( id, szPlayerName, 31 );
                new szMessage[ 256 ];
                formatex( szMessage, sizeof( szMessage ) - 1,"[Name %s]^n[Health: %d]^n[Armor: %d]^n[Money: %d]^n[By TSM - Mr.Pro]", szPlayerName, get_user_health( id ), get_user_armor( id ), cs_get_user_money( id ) );
                set_hudmessage( random_num(0,255), random_num(0,255), random_num(0,255), 0.02, 0.19, 0, 0.5, 15.0, 2.0, 2.0, -1 );
                //set_hudmessage( ColorRed, ColorGreen, ColorBlue, 0.02, 0.19, 0, 0.5, 15.0, 2.0, 2.0, -1 );
                ShowSyncHudMsg( id, SyncHudMessage, szMessage );
                set_pdata_int( id, 361, get_pdata_int( id, 361 ) | ( 1<<3 ) );
            }else {
                new idSpec;
                new szPlayerName[ 32 ];
                idSpec = pev( id, PEV_SPEC_TARGET );
                get_user_name( idSpec, szPlayerName, 31 );
                ShowSyncHudMsg( id, SyncHudMessage, "[SPECTATING: %s]^n[Health: %d]^n[Armor: %d]^n[Money: %d]^n[By TSM - Mr.Pro]", szPlayerName, get_user_health( idSpec ), get_user_armor( idSpec ), cs_get_user_money( idSpec ) );
    			set_hudmessage( random_num(0,255), random_num(0,255), random_num(0,255), -1.0, 0.7, 0, 0.5, 19.0, 2.0, 2.0, -1 );
                //set_hudmessage( SpecColorRed, SpecColorGreen, SpecColorBlue, -1.0, 0.7, 0, 0.5, 19.0, 2.0, 2.0, -1 );
                }
    		}
    		case 1: {
    			if( is_user_connected( id ) && is_user_alive( id ) && ( get_user_team( id ) == 1 || get_user_team( id ) == 2 ) ) {
    			new szPlayerName[ 32 ];
    			get_user_name( id, szPlayerName, 31 );
    			new szMessage[ 256 ];
    			formatex( szMessage, sizeof( szMessage ) - 1,"[CSDM MOD]^n[Name: %s]^n[Health: %d]^n[Armor: %d]^n[Money: %d]^n[By TSM - Mr.Pro]", szPlayerName, get_user_health( id ), get_user_armor( id ), cs_get_user_money( id ) );
    			ShowHudMessage( id, szMessage, random_num(0,255), random_num(0,255), random_num(0,255), 0.02, 0.08, 0, _, 1.0 );
    			//ShowHudMessage( id, szMessage, ColorRed, ColorGreen, ColorBlue, 0.02, 0.19, 0, _, 1.0 );
    			set_pdata_int( id, 361, get_pdata_int( id, 361 ) | ( 1<<3 ) );
   			}else {
   				new idSpec;
   				new szPlayerName[ 32 ];
 				idSpec = pev( id, PEV_SPEC_TARGET );
    			get_user_name( idSpec, szPlayerName, 31 );
    			new szMessage[ 256 ];
    			formatex( szMessage, sizeof( szMessage ) - 1,"[SPECTATING: %s]^n{Health: %d}^n{Armor: %d}^n{Money: %d}^n{By TSM - Mr.Pro}", szPlayerName, get_user_health( idSpec ), get_user_armor( idSpec ), cs_get_user_money( idSpec ) );
    			ShowHudMessage( id, szMessage, random_num(0,255), random_num(0,255), random_num(0,255), -1.0, 0.7, 0, _, 1.0 );
    			//ShowHudMessage( id, szMessage, SpecColorRed, SpecColorGreen, SpecColorBlue, -1.0, 0.7, 0, _, 1.0 );
    			}
    		}
    	}
    }
stock ShowHudMessage( const id, const szMessage[  ], red = 0, green = 160, blue = 0, Float:x = -1.0, Float:y = 0.65, effects = 2, Float:fxtime = 0.01, Float:holdtime = 3.0, Float:fadeintime = 0.01, Float:fadeouttime = 0.01 ) {
    	new iCount = 1, szPlayers[ 32 ];
    	if( id )
    		szPlayers[ 0 ] = id;
    	else
    	get_players( szPlayers, iCount, "ch"); {
    		for( new i = 0; i < iCount; i++ ) {
    			if( is_user_connected( szPlayers[ i ] ) ) {
    				new iColor = pack_color( clamp_byte( red ), clamp_byte( green ), clamp_byte( blue ) )
    				message_begin( MSG_ONE_UNRELIABLE, SVC_DIRECTOR, _, szPlayers[ i ] );
    				write_byte( strlen( szMessage ) + 31 );
    				write_byte( DRC_CMD_MESSAGE );
    				write_byte( effects );
    				write_long( iColor );
    				write_long( _:x );
    				write_long( _:y );
    				write_long( _:fadeintime );
    				write_long( _:fadeouttime );
    				write_long( _:holdtime );
    				write_long( _:fxtime );
    				write_string( szMessage );
    				message_end(  );
    			}
    		}
    	}
    }
