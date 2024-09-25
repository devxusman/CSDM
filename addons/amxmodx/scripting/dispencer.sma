#include < amxmodx >
#include < amxmisc >
#include < fakemeta >
#include < cstrike >
#include < engine >
#include < hamsandwich >
#include < xs >
#include < dhudmessage >

#define BREAK_COMPUTER 6
#define MAX_PLAYERS 32 + 1

#define is_valid_player(%1) ( 1 <= %1 <= gMaxPlayers )

new const gDamageSounds[ ][ ] =
{
	"debris/metal1.wav",
	"debris/metal2.wav",
	"debris/metal3.wav"
};

new const gDispenserClassname[ ] = "NiceDispenser";
new const gDispenserActive[ ] = "disp_csdm/dispenser.wav";
new const gDispenserMdl[ ] = "models/new_dispkk.mdl";
new const gHealingSprite[ ] = "sprites/dispenser.spr";
new g_iSPR_Smoke3;
new gHealingBeam;
new gMaxPlayers;
new g_iPlayerDispenser[33]
new ExplSpr
new Float:flood_disptouch[33]
#define DISPENSER_COST 5000
#define DISPENSER_COST_VIP 4000
new const d_upgcost[4] = {2000,2500,3500,5000}
new const d_upgcost_vip[4] = {1000,2000,3000,4500}
new const d_enthp[4] = {5000,6500,8000,10000}
new const d_radius[4] = {200,250,300,400}
new const d_hp[4] = {100,150,200,250}
new const d_ap[4] = {100,150,200,250}
new const Float:d_takehp[4] = {10.0,15.0,20.0,25.0}
new const Float:d_takeap[4] = {10.0,15.0,20.0,25.0}
new bool:bDispenserBuild[ MAX_PLAYERS ];
new touchdisp[33]

public plugin_init( )
{
	register_plugin( "Build Dispenser", "0.1", "pro100web" )
	register_event( "TextMsg", "EVENT_TextMsg", "a", "2&#Game_C", "2&#Game_w", "2&#Game_will_restart_in" );
	register_logevent( "LOG_RoundEnd", 2, "1=Round_End" );
	register_event ( "Spectator", "ev_Spectation", "a" )
	register_forward ( FM_TraceLine, "fw_TraceLine_Post", 1 )
	RegisterHam( Ham_TakeDamage, "func_breakable", "bacon_TakeDamage", 1 );
	RegisterHam( Ham_TakeDamage, "func_breakable", "bacon_TakeDamagePre", 0 );
	register_think( gDispenserClassname, "DispenserThink" );
	register_touch ( gDispenserClassname, "player", "fw_DispenserTouch" )
	register_clcmd( "build_dispenser", "CommandDispenserBuild" );
	register_clcmd( "detonate_dispenser", "disppp_menu" );
	gMaxPlayers = get_maxplayers( );
}

public disppp_menu(id)
{
	if(g_iPlayerDispenser[id] == 0){
		ChatColor (id, "[^4CSDM^1] ^3You Don't Have A ^4Dispencer.")
		return HAM_IGNORED
	}

	new szItem[128];
	new szItem1[128];
	new msentry_item = menu_create("\ySelect A Dispencer!", "cl_mendisp")
	static ent = -1
	while ((ent = find_ent_by_class(ent, gDispenserClassname)))
	{
		if( pev( ent, pev_iuser2) != id) continue;

		if(is_valid_ent(ent))
		{
			new iLevel = pev ( ent, pev_iuser3 )
			new iHealth = pev ( ent, pev_health )
			format(szItem, 127, "%d", ent)
			format(szItem1, 127, "\wID \r%d \w| Level \r%d \w[HP \y%d\w]", ent, iLevel, iHealth)
			menu_additem( msentry_item, szItem1, szItem, 0)
		}
	}

	menu_setprop(msentry_item, MPROP_EXIT, MEXIT_ALL)
	menu_setprop(msentry_item, MPROP_EXITNAME, "\yExit")
	menu_display(id, msentry_item, 0)

	return PLUGIN_HANDLED
}

public cl_mendisp(id, menu, item) {
	new s_Data[6], s_Name[64], i_Access, i_Callback
	menu_item_getinfo(menu, item, i_Access, s_Data, charsmax(s_Data), s_Name, charsmax(s_Name), i_Callback)
	new i_Key = str_to_num(s_Data)
	menu_destroy(menu)
	if(i_Key == 0) return 0
	if ( !is_valid_ent ( i_Key ) ) return 0
	touchdisp[id] = i_Key
	disp_menu_func(id)
	return 1
}

public disp_menu_func(id)
{
	if(g_iPlayerDispenser[id] == 0){
		ChatColor ( id, "[^4CSDM^1] ^3You Don't Have A ^4Dispencer.")
		return HAM_IGNORED
	}
	new szItem[128];
	new szItem1[128];
	new ent = touchdisp[id];
	if(ent==0) return PLUGIN_HANDLED
	new msentry_item = menu_create("\yWhat To Do With Dispencer!", "cl_mend");
	if(is_valid_ent(ent))
	{
		new iLevel = pev ( ent, pev_iuser3 )
		new iHealth = pev ( ent, pev_health )
		format(szItem, 127, "%d", ent)
		menu_additem( msentry_item, "\rDestroy")
		menu_addblank( msentry_item, 0)
		menu_addblank( msentry_item, 0)
		menu_addblank( msentry_item, 0)
		format(szItem1, 127, "\rID \y%d", ent)
		menu_addtext( msentry_item, szItem1)
		format(szItem1, 127, "\rLevel \y%d", iLevel)
		menu_addtext( msentry_item, szItem1)
		format(szItem1, 127, "\w[\rHP \y%d\w]", iHealth)
		menu_addtext( msentry_item, szItem1)
	}
	menu_setprop(msentry_item, MPROP_EXIT, MEXIT_ALL)
	menu_setprop(msentry_item, MPROP_EXITNAME, "\yExit")
	menu_display(id, msentry_item, 0)
	return PLUGIN_HANDLED
}

public cl_mend(id, menu, item) {
	item++
	menu_destroy(menu)
	new ent = touchdisp[id]
	if(!is_valid_ent(ent)) {
		touchdisp[id] = 0
		return 0
	}
	if(item == 0) return 0
	if(is_valid_ent(ent) && item == 1){
		DeleteEntity( ent )
		g_iPlayerDispenser[ id ]--;
	}
	return 1
}

public DeleteEntity( entity ){
	if(is_valid_ent(entity)){
		remove_entity(entity)
	}
}

public ev_Spectation ()
{
	new id = read_data ( 1 )
	BreakAllPlayerDispensers(id)
}

public client_connect( id )
{
	bDispenserBuild[ id ] = false;
	g_iPlayerDispenser[id] = 0
}

public client_disconnect( id )
{
	BreakAllPlayerDispensers(id)
	g_iPlayerDispenser[id] = 0
}

public plugin_precache( )
{
	gHealingBeam = precache_model( gHealingSprite );
	g_iSPR_Smoke3 = precache_model("sprites/black_smoke4.spr")
	precache_model( gDispenserMdl );
	precache_sound( gDispenserActive );
	new i;
	for( i = 0; i < sizeof gDamageSounds; i++ ) precache_sound( gDamageSounds[ i ] );
	ExplSpr = precache_model("sprites/gp_1.spr");
}

public fw_TraceLine_Post ( Float:v1[3], Float:v2[3], noMonsters, id )
{
	if ( !is_valid_player ( id ) || is_user_bot ( id ) || !is_user_alive ( id ) )
	return FMRES_IGNORED

	new iHitEnt = get_tr ( TR_pHit )

	if ( iHitEnt <= gMaxPlayers || !is_valid_ent ( iHitEnt ) )
	return FMRES_IGNORED

	new sClassname[32]
	pev ( iHitEnt, pev_classname, sClassname, charsmax ( sClassname ) )

	if ( !equal ( sClassname, gDispenserClassname ) )
	return FMRES_IGNORED

	new iTeam = pev ( iHitEnt, pev_iuser4 )

	if ( _:cs_get_user_team ( id ) != iTeam )
	return FMRES_IGNORED

	new iHealth = pev ( iHitEnt, pev_health )

	if ( iHealth <= 0 )
	return FMRES_IGNORED

	new iOwner = pev ( iHitEnt, pev_iuser2 )

	if ( !is_user_connected ( iOwner ) )
	return FMRES_IGNORED

	new sName[33]
	get_user_name ( iOwner, sName, charsmax ( sName ) )
	new iLevel = pev ( iHitEnt, pev_iuser3 )
	set_dhudmessage ( 255, 255, 255, -1.0, 0.80, 0, 0.0, 0.6, 0.0, 0.0 )
	show_dhudmessage ( id, "Installer: %s^nID %d HP: %d/%d^nLevel: %d", sName, iHitEnt, iHealth, d_enthp[iLevel-1], iLevel )
	return FMRES_IGNORED
}
public bacon_TakeDamagePre( ent, idinflictor, idattacker, Float:damage, damagebits )
{
	new szClassname[ 32 ];
	pev( ent, pev_classname, szClassname, charsmax( szClassname ) );

	if( equal( szClassname, gDispenserClassname ) )
	{
		new iOwner = pev( ent, pev_iuser2 );
		if(!is_user_connected(iOwner) || 1 > iOwner > 32 || !is_user_connected(idattacker) || 1 > idattacker > 32)
			return HAM_SUPERCEDE

		if(cs_get_user_team(iOwner)==cs_get_user_team(idattacker) && idattacker != iOwner)
			return HAM_SUPERCEDE
	}
	return HAM_IGNORED
}

public bacon_TakeDamage( ent, idinflictor, idattacker, Float:damage, damagebits )
{	
	if ( !is_valid_ent ( ent ) )
	return HAM_IGNORED

	new szClassname[ 32 ];
	pev( ent, pev_classname, szClassname, charsmax( szClassname ) );

	if( equal( szClassname, gDispenserClassname ) )
	{
		new iOwner = pev( ent, pev_iuser2 );
		if(!is_user_connected(iOwner) || 1 > iOwner > 32 || !is_user_connected(idattacker) || 1 > idattacker > 32)
			return HAM_SUPERCEDE

		if(cs_get_user_team(iOwner)==cs_get_user_team(idattacker) && idattacker != iOwner)
			return HAM_SUPERCEDE
		
		if( pev( ent, pev_health ) <= 0.0 )
		{
			new szName[ 32 ];
			get_user_name( idattacker, szName, charsmax( szName ) );
			if( idattacker == iOwner )
			{
				ChatColor ( iOwner, "^1[^4CSDM^1]^3 You Destroyed Your Own Dispencer.")
			} else {
				ChatColor ( iOwner, "^1[^4CSDM^1]^3 %s Destroyed Your Dispencer!", szName)
			}
		}
		emit_sound( ent, CHAN_STATIC, gDamageSounds[ random_num( 0, charsmax( gDamageSounds ) ) ], VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	}
	return HAM_IGNORED
}

stock create_explosion(Float:origin_[3]) {
	new origin[3]
	FVecIVec(origin_, origin)
	message_begin(MSG_ALL,SVC_TEMPENTITY,{0,0,0})
	write_byte(TE_SPRITETRAIL) //Спрайт захвата
	write_coord((origin[0]))
	write_coord((origin[1]))
	write_coord((origin[2])+20)
	write_coord((origin[0]))
	write_coord((origin[1]))
	write_coord((origin[2])+80)
	write_short(ExplSpr)
	write_byte(20)
	write_byte(20)
	write_byte(4)
	write_byte(20)
	write_byte(10)
	message_end()
}

public CommandDispenserBuild( id )
{
	if( !is_user_alive( id ) )
	{
		return PLUGIN_CONTINUE;
	}

	if( !( pev( id, pev_flags ) & FL_ONGROUND ) )
	{
		ChatColor ( id, "^1[^4CSDM^1]^3 You Can Only Build ^4Dispencer ^3On Ground!")
		return PLUGIN_HANDLED;
	}
	
	if (get_user_flags(id) & ADMIN_USER){
	if ( g_iPlayerDispenser[id] >= 2)
	{
		ChatColor ( id, "^1[^4CSDM^1]^3 You Have Already Built ^4 2 ^3Dispencers!")
		return PLUGIN_HANDLED;
	}
	}
	else
	if (get_user_flags(id) & ADMIN_LEVEL_H){
	if ( g_iPlayerDispenser[id] >= 4)
	{
		ChatColor ( id, "^1[^4CSDM VIP^1]^3 You Have Already Built ^4 4 ^3Dispencers!")
		return PLUGIN_HANDLED;
	}
	}

	new iMoney = cs_get_user_money( id );

	if (get_user_flags(id) & ADMIN_LEVEL_H)
	{
		if( iMoney < d_upgcost_vip[0] )
		{
			ChatColor ( id, "^1[^4CSDM VIP^1]^3 You Don't Have Enough Money. ^1(^4Need %d$^1)", d_upgcost_vip[0] )
			return PLUGIN_HANDLED;
		}
	}
	else
	{
		if( iMoney < d_upgcost[0] )
		{
			ChatColor ( id, "^1[^4CSDM^1]^3 You Don't Have Enough Money. ^1(^4Need %d$^1)", d_upgcost[0] )
			return PLUGIN_HANDLED;
		}
	}
	new Float:playerOrigin[3]
	entity_get_vector(id, EV_VEC_origin, playerOrigin)

	new Float:vNewOrigin[3]
	new Float:vTraceDirection[3]
	new Float:vTraceEnd[3]
	new Float:vTraceResult[3]
	velocity_by_aim(id, 64, vTraceDirection) // get a velocity in the directino player is aiming, with a multiplier of 64...
	vTraceEnd[0] = vTraceDirection[0] + playerOrigin[0] // find the new max end position
	vTraceEnd[1] = vTraceDirection[1] + playerOrigin[1]
	vTraceEnd[2] = vTraceDirection[2] + playerOrigin[2]
	trace_line(id, playerOrigin, vTraceEnd, vTraceResult) // trace, something can be in the way, use hitpoint from vTraceResult as new origin, if nothing's in the way it should be same as vTraceEnd
	vNewOrigin[0] = vTraceResult[0]// just copy the new result position to new origin
	vNewOrigin[1] = vTraceResult[1]// just copy the new result position to new origin
	vNewOrigin[2] = playerOrigin[2] // always build in the same height as player.

	if (CreateDispanser(vNewOrigin, id))
	{
		if (get_user_flags(id) & ADMIN_LEVEL_H)
		{
			cs_set_user_money(id, cs_get_user_money(id) - d_upgcost_vip[0])
			//set_bankmoney(id,d_upgcost_vip[0])
			g_iPlayerDispenser[id]++
		}
		else
		{
			cs_set_user_money(id, cs_get_user_money(id) - d_upgcost[0])
			//set_bankmoney(id,d_upgcost[0])
			g_iPlayerDispenser[id]++
		}
	}
	else
	{
		ChatColor ( id, "^1[^4CSDM^1]^3 Dispencer Can't Be Built Here!")
	}
	return PLUGIN_HANDLED;
}


stock bool:CreateDispanser(Float:origin[3], creator)
{
	if (point_contents(origin) != CONTENTS_EMPTY || TraceCheckCollides(origin, 35.0))
	{
		return false
	}

	new Float:hitPoint[3], Float:originDown[3]
	originDown = origin
	originDown[2] = -5000.0 // dunno the lowest possible height...
	trace_line(0, origin, originDown, hitPoint)
	new Float:baDistanceFromGround = vector_distance(origin, hitPoint)

	new Float:difference = 20.0 - baDistanceFromGround
	if (difference < -1 * 20.0 || difference > 20.0) return false

	new iEntity = create_entity( "func_breakable" );

	if( !is_valid_ent( iEntity ) )
	return false

	set_pev( iEntity, pev_classname, gDispenserClassname );
	new Float:flAngles[ 3 ];
	new Float:flAnglesF[ 3 ];
	pev( creator, pev_angles, flAngles );
	pev( iEntity, pev_angles, flAnglesF );
	flAnglesF[1] = flAngles[1]
	set_pev( iEntity, pev_angles, flAnglesF );
	engfunc( EngFunc_SetModel, iEntity, gDispenserMdl );
	engfunc( EngFunc_SetSize, iEntity, Float:{ -20.0, -10.0, 0.0 }, Float:{ 20.0, 10.0, 50.0 } );
	set_pev( iEntity, pev_origin, origin );
	set_pev( iEntity, pev_solid, SOLID_BBOX );
	set_pev( iEntity, pev_movetype, MOVETYPE_FLY );
	set_pev( iEntity, pev_health, float(d_enthp[0]) );
	set_pev( iEntity, pev_takedamage, 2.0 );
	set_pev( iEntity, pev_iuser1, 0 );
	//set_pev( iEntity, pev_fuser1, float(moneytraf[1]) );
	//Disp_balance[iEntity] = 1000;
	set_pev( iEntity, pev_iuser2, creator );
	set_pev( iEntity, pev_iuser3, 1 );
	set_pev( iEntity, pev_iuser4, get_user_team(creator) );
	set_pev( iEntity, pev_nextthink, get_gametime( ) + 0.1 );
	engfunc( EngFunc_DropToFloor, iEntity );
	bDispenserBuild[ creator ] = true;
	switch( cs_get_user_team( creator ) )
	{
		case CS_TEAM_T: set_pev(iEntity, pev_body, 4);
		case CS_TEAM_CT: set_pev(iEntity, pev_body, 0);
	}

	emit_sound( iEntity, CHAN_STATIC, gDispenserActive, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );

	return true;
}

public DispenserThink( iEnt )
{
	if( is_valid_ent( iEnt ) )
	{
		static iOwner; iOwner = pev( iEnt, pev_iuser2 )
		if(get_user_team(iOwner) != pev( iEnt, pev_iuser4) || !is_user_connected ( iOwner )){
			BreakAllPlayerDispensers(iOwner)
			g_iPlayerDispenser[iOwner] = 0
			return PLUGIN_CONTINUE
		}		
		new HP = pev ( iEnt, pev_health )
		if( HP <= 0.0 )
		{
			new Float:origin[3]
			entity_get_vector(iEnt, EV_VEC_origin, origin)
			DeleteEntity( iEnt )
			create_explosion(origin)
			g_iPlayerDispenser[iOwner]--
			client_cmd( iOwner, "speak ^"vox/bizwarn computer destroyed^"" );
			if(g_iPlayerDispenser[iOwner]==0)
				bDispenserBuild[ iOwner ] = false;
			return PLUGIN_CONTINUE
		}
		
		new iLevel = pev ( iEnt, pev_iuser3 )
		new Float:origin[ 3 ];
		pev( iEnt, pev_origin, origin );
		origin[2]+=35.0
		for( new id = 1; id <= gMaxPlayers; id++ )
		{
			if( !is_user_bot(id) && is_user_connected ( id ) && is_user_alive( id ) && cs_get_user_team( id ) == cs_get_user_team( iOwner ))
			{
				new Float:flOrigin[ 3 ];
				pev( id, pev_origin, flOrigin );
				if( get_distance_f( origin, flOrigin ) <= d_radius[iLevel-1])
				{
					new Healing = pev(id, pev_health);
					new Armoring = pev(id, pev_armorvalue);
					if( UTIL_IsVisible( id, iEnt, origin, flOrigin) && (Healing < d_hp[iLevel - 1] || Armoring < d_ap[iLevel - 1]))
					{
						if( Healing < d_hp[iLevel - 1] )
							set_pev(id, pev_health, floatmin(Healing + d_takehp[iLevel-1], float(d_hp[iLevel - 1])));
						
						if( Armoring < d_ap[iLevel - 1] )
							set_pev(id, pev_armorvalue, floatmin(Armoring + d_takeap[iLevel-1], float(d_ap[iLevel - 1])));
						
						UTIL_BeamEnts( flOrigin, origin);
					}
				}
			}
		}
		
		if(HP<=600.0){
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(TE_SMOKE)
			engfunc(EngFunc_WriteCoord, origin[0]+random_float(-8.0, 8.0))
			engfunc(EngFunc_WriteCoord, origin[1]+random_float(-8.0, 8.0))
			engfunc(EngFunc_WriteCoord, origin[2]+random_float(25.0, 35.0))
			write_short(g_iSPR_Smoke3)
			write_byte(random_num(3,7))
			write_byte(30)
			message_end()
		}		
		set_pev( iEnt, pev_nextthink, get_gametime( ) + 1.0 );
	}
	return PLUGIN_CONTINUE;
}

public fw_DispenserTouch ( ent, id )
{
	new iLevel = pev ( ent, pev_iuser3 );
	static Float:time;time=get_gametime()
	if(flood_disptouch[id] > time)
		return

	flood_disptouch[id] = time+2.0

	if ( !is_valid_ent ( ent ) )
		return

	if ( !is_user_connected ( id ) || !is_user_alive ( id ) )
		return

	if ( pev ( ent, pev_iuser4 ) != _:cs_get_user_team ( id ) )
		return

	if(iLevel == 4)
		return

	new iOwner = pev ( ent, pev_iuser2 )
	new money = cs_get_user_money ( id )
	if (get_user_flags(id) & ADMIN_LEVEL_H && money < d_upgcost_vip[iLevel])
	{
		ChatColor ( id, "^1[^4CSDM VIP^1]^3 You Don't Have Money. ^1(^4Need %d$^1)", d_upgcost_vip[iLevel] )
		return;
	}
	else if( money < d_upgcost[iLevel] )
	{
		ChatColor ( id, "^1[^4CSDM VIP^1]^3 You Don't Have Money. ^1(^4Need %d$^1)", d_upgcost[iLevel] )
		return;
	}
	
	if ( !is_user_connected ( iOwner ) )
		return

	if (get_user_flags(id) & ADMIN_LEVEL_H)
	{
		cs_set_user_money(id, money - d_upgcost_vip[iLevel-1])
	}
	else
	{
		cs_set_user_money(id, money - d_upgcost[iLevel-1])
	}
	new sUpgraderName[32]
	get_user_name ( id, sUpgraderName, charsmax ( sUpgraderName ) )
	ChatColor ( iOwner, "^1[^4CSDM^1] ^4%s ^3Upgraded Your ^4Dispencer!", sUpgraderName )
	fw_DispenserTouchTwo(ent)
}

public fw_DispenserTouchTwo (ent){
	new iLevel = pev ( ent, pev_iuser3 );
	iLevel++
	set_pev ( ent, pev_iuser3, iLevel )
	set_pev ( ent, pev_health, float ( d_enthp[iLevel-1] ) )
	engfunc( EngFunc_SetModel, ent, gDispenserMdl )
	engfunc( EngFunc_SetSize, ent, Float:{ -20.0, -10.0, 0.0 }, Float:{ 20.0, 10.0, 50.0 } )
	emit_sound( ent, CHAN_STATIC, gDispenserActive, VOL_NORM, ATTN_NORM, 0, PITCH_NORM )
	switch( pev ( ent, pev_iuser4 ) )
	{
		case CS_TEAM_T:
		{
			switch(iLevel)
			{
				case 2: set_pev(ent, pev_body, 5);
				case 3: set_pev(ent, pev_body, 6);
				case 4: set_pev(ent, pev_body, 7);
			}
		}
		case CS_TEAM_CT:
		{
			switch(iLevel)
			{
				case 2: set_pev(ent, pev_body, 1);
				case 3: set_pev(ent, pev_body, 2);
				case 4: set_pev(ent, pev_body, 3);
			}
		}
	}
}

public EVENT_TextMsg( )
{
	UTIL_DestroyDispensers( );
}

public LOG_RoundEnd( )
{
	UTIL_DestroyDispensers( );
}

stock UTIL_DestroyDispensers( )
{
	new iEnt = FM_NULLENT;

	while( ( iEnt = find_ent_by_class( iEnt, gDispenserClassname ) ) )
	{
		if(is_valid_ent ( iEnt )){
			new iOwner = pev( iEnt, pev_iuser2 );
			bDispenserBuild[ iOwner ] = false;
			g_iPlayerDispenser[ iOwner ]--;
			DeleteEntity( iEnt )
		}
	}
}

stock UTIL_BeamEnts(Float:flStart[ 3 ], Float:flEnd[ 3 ])
{
	engfunc( EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, flStart );
	write_byte(TE_BEAMPOINTS);
	engfunc( EngFunc_WriteCoord, flStart[ 0 ] );
	engfunc( EngFunc_WriteCoord, flStart[ 1 ] );
	engfunc( EngFunc_WriteCoord, flStart[ 2 ] );
	engfunc( EngFunc_WriteCoord, flEnd[ 0 ] );
	engfunc( EngFunc_WriteCoord, flEnd[ 1 ] );
	engfunc( EngFunc_WriteCoord, flEnd[ 2 ] );
	write_short( gHealingBeam );
	write_byte( 5 );
	write_byte( 2 );
	write_byte( 1 );
	write_byte( 20 );
	write_byte( 3 );
	write_byte( 0 );
	write_byte( 255 );
	write_byte( 0 );
	write_byte( 130 );
	write_byte( 30 );
	message_end( );
}

stock bool:UTIL_IsVisible( index, entity, Float:origin[3], Float:flStart[ 3 ]) {
	new Float:flDest[ 3 ];
	pev( index, pev_view_ofs, flDest );
	xs_vec_add( flStart, flDest, flStart );
	engfunc( EngFunc_TraceLine, flStart, origin, 0, index, 0 );
	new Float:flFraction;
	get_tr2( 0, TR_flFraction, flFraction );
	if( flFraction == 1.0 || get_tr2( 0, TR_pHit) == entity ) return true;
	return false;
}

public BreakAllPlayerDispensers(id)
{
	static ent = -1
	while ((ent = find_ent_by_class(ent, gDispenserClassname)))
	{
		if(pev( ent, pev_iuser2 ) != id)
			continue

		if(is_valid_ent(ent))
		{
			DeleteEntity( ent )
		}
	}
	bDispenserBuild[ id ] = false;
	g_iPlayerDispenser[ id ] = 0;
}


bool:TraceCheckCollides(Float:origin[3], const Float:BOUNDS)
{
	new Float:traceEnds[8][3], Float:traceHit[3], hitEnt
	traceEnds[0][0] = origin[0] - BOUNDS
	traceEnds[0][1] = origin[1] - BOUNDS
	traceEnds[0][2] = origin[2] - BOUNDS
	traceEnds[1][0] = origin[0] - BOUNDS
	traceEnds[1][1] = origin[1] - BOUNDS
	traceEnds[1][2] = origin[2] + BOUNDS
	traceEnds[2][0] = origin[0] + BOUNDS
	traceEnds[2][1] = origin[1] - BOUNDS
	traceEnds[2][2] = origin[2] + BOUNDS
	traceEnds[3][0] = origin[0] + BOUNDS
	traceEnds[3][1] = origin[1] - BOUNDS
	traceEnds[3][2] = origin[2] - BOUNDS
	traceEnds[4][0] = origin[0] - BOUNDS
	traceEnds[4][1] = origin[1] + BOUNDS
	traceEnds[4][2] = origin[2] - BOUNDS
	traceEnds[5][0] = origin[0] - BOUNDS
	traceEnds[5][1] = origin[1] + BOUNDS
	traceEnds[5][2] = origin[2] + BOUNDS
	traceEnds[6][0] = origin[0] + BOUNDS
	traceEnds[6][1] = origin[1] + BOUNDS
	traceEnds[6][2] = origin[2] + BOUNDS
	traceEnds[7][0] = origin[0] + BOUNDS
	traceEnds[7][1] = origin[1] + BOUNDS
	traceEnds[7][2] = origin[2] - BOUNDS

	for (new i = 0; i < 8; i++)
	{
		if (point_contents(traceEnds[i]) != CONTENTS_EMPTY)
		return true

		hitEnt = trace_line(0, origin, traceEnds[i], traceHit)
		if (hitEnt != 0)
		return true
		for (new j = 0; j < 3; j++)
		{
			if (traceEnds[i][j] != traceHit[j])
			return true
		}
	}

	return false
}

stock ChatColor(const id, const input[], any:...)
{
	new count = 1, players[32]
	static msg[191]
	vformat(msg, 190, input, 3)

	replace_all(msg, 190, "!g", "^4") // Green Color
	replace_all(msg, 190, "!y", "^1") // Default Color
	replace_all(msg, 190, "!team", "^3") // Team Color
	replace_all(msg, 190, "!team2", "^0") // Team2 Color

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