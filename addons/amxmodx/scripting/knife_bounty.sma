#include < amxmodx >
#include < cstrike >
#include < hamsandwich >

#define PLUGIN "Knife Bounty + Secure"
#define VERSION "1.5"
#define AUTHOR "DoNii"

#define NO_MONEY 0

new g_iCvars[ 3 ];

new bool:g_bHasSafety[ 33 ];

new const g_szCommandList[ ][ ] = { "say /secure", "say secure", "say_team /secure", "say_team secure" };

public plugin_init( )
{
	register_plugin( PLUGIN, VERSION, AUTHOR );

	register_dictionary( "knife_bounty.txt" );
	
	for ( new i; i < sizeof g_szCommandList; i++ )
	{
		register_clcmd( g_szCommandList[ i ], "SecurePlayer" );
	}
	
	RegisterHam( Ham_Killed, "player", "fw_HamKilledPost", 1 );
	RegisterHam( Ham_Spawn, "player", "fw_HamSpawnPost", 1 );

	g_iCvars[ 0 ] = register_cvar( "knife_bounty_enabled", "1" ); // Plugin On/Off <0|1> - <Off|On>
	g_iCvars[ 1 ] = register_cvar( "knife_bounty_secure", "1" ); // allow players to secure their money <0|1> - <Disallow|Allow>
	g_iCvars[ 2 ] = register_cvar( "knife_bounty_secure_price", "10000" ); // Price to secure your money
	
	register_cvar( "knife_bounty_version", VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED );
}

public fw_HamKilledPost( iVictim, iAttacker, iShouldGib )
{
	if( ! get_pcvar_num( g_iCvars[ 0 ] ) )
	{
		return HAM_IGNORED;
	}
	
	if( ! is_user_connected( iAttacker ) || ! is_user_connected( iVictim ) )
	{
		return HAM_IGNORED;
	}
	
	if( get_user_weapon( iAttacker ) != CSW_KNIFE )
	{
		return HAM_IGNORED;
	}
	
	if( g_bHasSafety[ iVictim ] )
	{
		client_print( iAttacker, print_chat, "%L", iAttacker, "VICTIM_SECURED" );
		client_print( iVictim, print_chat, "%L", iVictim, "VICTIM_DIDNT_LOSE" );
		
		g_bHasSafety[ iVictim ] = false;
		
		return HAM_IGNORED;
	}
	
	new iVictimMoney = cs_get_user_money( iVictim );
	new iAttackerMoney = cs_get_user_money( iAttacker );

	if( iVictimMoney == NO_MONEY )
	{
		client_print( iAttacker, print_chat, "%L", iAttacker, "VICTIM_MONEY_LOW" );
		return HAM_IGNORED;
	}
	
	cs_set_user_money( iAttacker, iAttackerMoney + iVictimMoney );
	cs_set_user_money( iVictim, NO_MONEY );
	
	new szVictimName[ 32 ], szAttackerName[ 32 ];
	
	get_user_name( iVictim, szVictimName, charsmax( szVictimName ) );
	get_user_name( iAttacker, szAttackerName, charsmax( szAttackerName ) );
	
	client_print( iAttacker, print_chat, "%L", iAttacker, "ATTACKER_BOUNTY", szVictimName, iVictimMoney );
	client_print( iVictim, print_chat, "%L", iVictim, "VICTIM_LOST_MONEY", szAttackerName, iVictimMoney );
	
	return HAM_IGNORED;
}

public fw_HamSpawnPost( id )
{
	if( ! get_pcvar_num( g_iCvars[ 0 ] ) || ! is_user_alive( id ) )
	{
		return HAM_IGNORED;
	}
	
	g_bHasSafety[ id ] = false;	
	
	if( ! get_pcvar_num( g_iCvars[ 1 ] ) )
	{
		return HAM_IGNORED;
	}
	
	client_print( id, print_chat, "%L", id, "SECURE_AD" );
	return HAM_IGNORED;
}

public SecurePlayer( id )
{
	if( ! get_pcvar_num( g_iCvars[ 0 ] ) )
	{
		return HAM_IGNORED;
	}
	
	if( ! get_pcvar_num( g_iCvars[ 1 ] ) )
	{
		client_print( id, print_chat, "%L", id, "SECURE_DISABLED" );
		return HAM_IGNORED;
	}

	if( ! is_user_alive( id ) )
	{
		client_print( id, print_chat, "%L", id, "CANT_SECURE_DEAD" );
		return PLUGIN_HANDLED;
	}

	new iPlayerMoney = cs_get_user_money( id );
	new iSecurePriceValue = get_pcvar_num( g_iCvars[ 2 ] );

	if( iPlayerMoney < iSecurePriceValue )
	{
		client_print( id, print_chat, "%L", id, "NOT_ENOUGH_MONEY" );
		return PLUGIN_HANDLED;
	}

	cs_set_user_money( id, iPlayerMoney - iSecurePriceValue );

	g_bHasSafety[ id ] = true;
	client_print( id, print_chat, "%L", id, "SECURED_MONEY", iSecurePriceValue );

	return PLUGIN_CONTINUE;
}

public client_connect( id )
{
	g_bHasSafety[ id ] = false;
}