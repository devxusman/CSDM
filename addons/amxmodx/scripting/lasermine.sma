#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>
#include <engine>
#include <hamsandwich>
#include <xs>
#include <beams>
#include <fun>
#include <crxranks>

#define LASERMINE_REWARD 2  // Xp REWARD


#define PLUGIN "SF TripMine"
#define VERSION "0.3.4"
#define AUTHOR "serfreeman1337"

// FLAGS
#define VIP ADMIN_RESERVATION
#define ADMIN ADMIN_BAN
#define SADMIN ADMIN_LEVEL_E
#define HEAD ADMIN_IMMUNITY
#define MANAGER ADMIN_LEVEL_A
#define OWNER ADMIN_RCON

#if AMXX_VERSION_NUM < 183
	#define message_begin_f(%0,%1,%2,%3)	engfunc(EngFunc_MessageBegin,%0,%1,%2,%3)
	#define write_coord_f(%0)		engfunc(EngFunc_WriteCoord,%0)
	
	#define Ham_CS_Player_ResetMaxSpeed	Ham_Item_PreFrame
	
	#include <dhudmessage>
#endif

#define SND_STOP		(1<<5)
#define TRIPMINE_CLASSNAME	"lasermine"		// Mine ClassName.

#define PLANTWAITTIME		0.1				// - Waiting Time.
#define POWERUPTIME		2.0					// - Activation Of LaserMine After Installation.
#define BEAM_WIDTH		15.0				// - BeamSize.
#define BEAM_BRIGHT		255.0				// - Beam Glow Level. 
#define PLANT_TIME		1.0				// - Plant Time.
#define PLANT_RADIUS		64.0				//  - Distance By Which Player Can Build Mine.
#define LASER_LENGTH		8128.0				//  - Maximum Beam Length.

#define REWARD_MONEY 1000

#define EV_TM_hOwner		EV_ENT_euser4
#define EV_TM_pBeam		EV_ENT_euser3
#define EV_TM_team		EV_INT_iuser4
#define EV_TM_plantTime		EV_FL_fuser4
#define EV_TM_mVecDir		EV_VEC_vuser4
#define EV_TM_mVecEnd		EV_VEC_vuser3

#define EV_TM_mineId		EV_INT_iuser3
#define ENTITY_REFERENCE	"func_breakable"

#define mine_beam1			pev_iuser1
#define mine_beam2			pev_iuser2

new const MINE_CUSTOMIZATION_FILE[] = "tripmine.ini"

enum
{
	SECTION_NONE = 0,
	SECTION_MAIN,
	SECTION_LEVEL1,
	SECTION_LEVEL2,
	SECTION_LEVEL3
}

// -- DATAS -- //
enum _:playerDataStruct {
	PD_MINE_ENT,
	Float:PD_NEXTPLANT_TIME,
	bool:PD_START_SET
}

new maxPlayers,expSpr
new playerData[33][playerDataStruct]
new HamHook:playerPostThink,thinkHooks

new BarTime

new gszKillCount[2048];
new Float:gszTimerMenu[33];

new Float:checker[2048];
new bool:checker2[2048] = false;

// Cvars

new g_Count_lasermine_vip, g_Count_lasermine_admin, g_Count_lasermine_sadmin, g_Count_lasermine_head, g_Count_lasermine_manager, g_Count_lasermine_owner

new gszMaxCount, 					gszLevelCost1,					gszLevelCost2,
	gszLevelCost3,					Float:gszLevelHealth1,			Float:gszLevelHealth2,
	Float:gszLevelHealth3,			Float:gszLevelDamage1,			Float:gszLevelDamage2,
	Float:gszLevelDamage3;

new gszModelTripMine[128],			gszModelLaserT[128],			gszModelLaserCT[128],
	gszModelMineExl[128],			gszSoundPlant[128],				gszSoundCharge[128],
	gszSoundActive[128],			gszSoundHit[128],				gszLaserType[2048],				
	gszLaserLevel[2048],			gszLaserAngle[2048],			gszCurrentLaser[33],
	gszLevelFlag2[64],				gszLevelFlag3[64];
	
public plugin_precache()
{
	LoadFile();
	
	precache_model(gszModelTripMine);
	precache_model(gszModelLaserT)
	precache_model(gszModelLaserCT)
	
	precache_sound(gszSoundPlant)
	precache_sound(gszSoundCharge)
	precache_sound(gszSoundActive)
	precache_sound(gszSoundHit)
	
	expSpr = precache_model(gszModelMineExl);
}

public plugin_init(){
	register_plugin(PLUGIN,VERSION,AUTHOR)

	BarTime = get_user_msgid("BarTime")
	maxPlayers = get_maxplayers()

	register_clcmd("+setlaser","SetLaser_CMD")
	register_clcmd("-setlaser","SetLaser_DropCMD")
	
	g_Count_lasermine_vip = register_cvar("lasermine_max_vip", "5")					// How Much Sentries A VIP Player Can Build
	g_Count_lasermine_admin = register_cvar("lasermine_max_admin", "6")				// How Much Sentries An ADMIN Can Build
	g_Count_lasermine_sadmin = register_cvar("lasermine_max_sadmin", "7")			// How Much Sentries A S.ADMIN Can Build
	g_Count_lasermine_head = register_cvar("lasermine_max_head", "8")				// How Much Sentries A HEAD ADMIN Can Build	
	g_Count_lasermine_manager = register_cvar("lasermine_max_manager", "9")			// How Much Sentries A MANAGER Can Build
	g_Count_lasermine_owner = register_cvar("lasermine_max_owner", "10")			// How Much Sentries An OWNER Can Build	
	register_think(TRIPMINE_CLASSNAME,"TripMine_Think")
	register_touch(TRIPMINE_CLASSNAME, "player", "CmdTouchTripMine")
	
	RegisterHam(Ham_TakeDamage,ENTITY_REFERENCE,"TripMine_Damage")
	RegisterHam(Ham_Killed,ENTITY_REFERENCE,"TripMine_Killed")
	
	register_logevent("RoundEnd",2,"1=Round_End")
	register_logevent("RoundEnd",2,"1=Round_Start")
	
	register_think("beam","Beam_Think")
}

//
// random beams fix attempt
//
public Beam_Think(ent){
	new mine = entity_get_edict(ent,EV_ENT_owner)
	
	if(!is_valid_ent(ent))
		UTIL_Remove(ent)
	
	if(!is_valid_ent(mine))
		return;
	
	if(entity_get_int(ent,EV_TM_mineId) != entity_get_int(mine,EV_TM_mineId))
		UTIL_Remove(ent)
	
	entity_set_float(ent,EV_FL_nextthink,get_gametime() + 0.05)
}

public RoundEnd(){
	new ent
	
	while((ent = find_ent_by_class(ent,TRIPMINE_CLASSNAME))){
		new beam = entity_get_edict(ent,EV_TM_pBeam)
		new beam1 = pev(ent, mine_beam1);
		new beam2 = pev(ent, mine_beam2);
		
		if(is_valid_ent(beam))
			remove_entity(beam)
		
		if(is_valid_ent(beam1))
			remove_entity(beam1)
		
		if(is_valid_ent(beam2))
			remove_entity(beam2)
		
		ResetMineData(ent);
		remove_entity(ent)
	}
}

public SetLaser_CMD(id){
	if (get_user_flags(id) & ADMIN_USER)
	if(GetPlayer_Mines(id) >= gszMaxCount){ // soobwenie?
		playerData[id][PD_NEXTPLANT_TIME] =  _:(get_gametime() + PLANTWAITTIME)
		ChatColor(id,"^1[^4CSDM^1]^3 Maximum Numbers Of LaserMine Built!")
		return PLUGIN_HANDLED
	}
	else
	if (get_user_flags(id) & VIP)
	{
		if ( gszMaxCount >= get_pcvar_num(g_Count_lasermine_vip))
		{
			ChatColor (id, "^1[^4CSDM VIP^1]^4 You Have Already Built %d Lasermine!", get_pcvar_num(g_Count_lasermine_vip))
			return PLUGIN_HANDLED
		}
	}
	else
	if (get_user_flags(id) & ADMIN)
	{
		if ( gszMaxCount >= get_pcvar_num(g_Count_lasermine_admin))
		{
			ChatColor (id, "^1[^4CSDM ADMIN^1]^4 You Have Already Built %d Lasermine!", get_pcvar_num(g_Count_lasermine_admin))
			return PLUGIN_HANDLED
		}
	}
	else
	if (get_user_flags(id) & SADMIN)
	{
		if ( gszMaxCount >= get_pcvar_num(g_Count_lasermine_sadmin))
		{
			ChatColor (id, "^1[^4CSDM S.ADMIN^1]^4 You Have Already Built %d Lasermine!", get_pcvar_num(g_Count_lasermine_sadmin))
			return PLUGIN_HANDLED
		}
	}
	else
	if (get_user_flags(id) & HEAD)
	{
		if ( gszMaxCount >= get_pcvar_num(g_Count_lasermine_head))
		{
			ChatColor (id, "^1[^4CSDM HEAD^1]^4 You Have Already Built %d Lasermine!", get_pcvar_num(g_Count_lasermine_head))
			return PLUGIN_HANDLED
		}
	}
	else
	if (get_user_flags(id) & MANAGER)
	{
		if ( gszMaxCount >= get_pcvar_num(g_Count_lasermine_manager))
		{
			ChatColor (id, "^1[^4CSDM MANAGER^1]^4 You Have Already Built %d Lasermine!", get_pcvar_num(g_Count_lasermine_manager))
			return PLUGIN_HANDLED
		}
	}
	else
	if (get_user_flags(id) & OWNER)
	{
		if ( gszMaxCount >= get_pcvar_num(g_Count_lasermine_owner))
		{
			ChatColor (id, "^1[^4CSDM OWNER^1]^4 You Have Already Built %d Lasermine!", get_pcvar_num(g_Count_lasermine_owner))
			return PLUGIN_HANDLED
		}
	}
	playerData[id][PD_START_SET] = true
	
	thinkHooks++
	
	if(thinkHooks == 1){
		if(!playerPostThink)
			#if AMXX_VERSION_NUM >= 183
			playerPostThink = RegisterHamPlayer(Ham_Player_PostThink,"Player_PostThink",true)
			#else
			playerPostThink = RegisterHam(Ham_Player_PostThink,"player","Player_PostThink",true)
			#endif
		else
			EnableHamForward(playerPostThink)
	}
	
	return PLUGIN_HANDLED
}

public SetLaser_DropCMD(id){
	if(!playerData[id][PD_START_SET])
		return PLUGIN_HANDLED
		
	thinkHooks--
	
	if(thinkHooks <= 0)
		DisableHamForward(playerPostThink)
		
	playerData[id][PD_START_SET] = false
	
	if(is_valid_ent(playerData[id][PD_MINE_ENT])){
		ResetMineData(playerData[id][PD_MINE_ENT]);
		remove_entity(playerData[id][PD_MINE_ENT])
		Send_BarTime(id,0.0)
		playerData[id][PD_MINE_ENT] = FM_NULLENT
		playerData[id][PD_NEXTPLANT_TIME] =  _:(get_gametime() + PLANTWAITTIME)
	}
		
	return PLUGIN_HANDLED
}

public Player_PostThink(id){
	if(playerData[id][PD_START_SET])
		if(TripMine_PlantThink(id))
			TripMine_Plant(id,playerData[id][PD_MINE_ENT]) // установка мины
}

//
// Spawn tripmine entity
//
TripMine_Spawn(){
	new tm = create_entity(ENTITY_REFERENCE)
	
	entity_set_string(tm,EV_SZ_classname,TRIPMINE_CLASSNAME)
	
	// motor
	entity_set_int(tm,EV_INT_movetype,MOVETYPE_FLY)
	entity_set_int(tm,EV_INT_solid,SOLID_NOT)
	
	entity_set_model(tm,gszModelTripMine)
	entity_set_float(tm,EV_FL_frame,0.0)
	entity_set_int(tm,EV_INT_body,3)
	entity_set_int(tm,EV_INT_sequence,7)	// TRIPMINE_WORLD
	entity_set_float(tm,EV_FL_framerate,0.0)
	
	ResetMineData(tm);
	gszLaserAngle[tm] = 35;
	
	entity_set_size(tm,Float:{-8.0,-8.0,-8.0},Float:{8.0,8.0,8.0})
	
	return tm
}

GetPlayer_Mines(id){
	new ent,cnt
	
	while((ent = find_ent_by_class(ent,TRIPMINE_CLASSNAME))){
		if(id == entity_get_edict(ent,EV_TM_hOwner))
			cnt ++
	}
	
	return cnt
}

//
// Визуальная посадка для мины
//	id - id установщика
//	reset - остановить установку
//
TripMine_PlantThink(id,bool:reset = false){
	if(playerData[id][PD_NEXTPLANT_TIME] > get_gametime())
		return false
		
	new ent = playerData[id][PD_MINE_ENT]

	if(!is_user_alive(id) || 
		cs_get_user_money(id) - gszLevelCost1 < 0
	){ // не позволяет установку во время работы или смерти
		if(is_valid_ent(ent)){
			ResetMineData(ent);
			remove_entity(ent)
			Send_BarTime(id,0.0)
		}
		
		ChatColor(id,"^1[^4CSDM^1]^3 You Don't Have Enough Money! ^1(^4Need %d$^1)",gszLevelCost1)
		
		playerData[id][PD_MINE_ENT] = FM_NULLENT
		SetLaser_DropCMD(id)
		//playerData[id][PD_NEXTPLANT_TIME] =  _:(get_gametime() + PLANTWAITTIME)
	
		return false
	}
	
	if(reset){ // уничтожить визальный объект
		if(is_valid_ent(ent)){
			ResetMineData(ent);
			remove_entity(ent)
			Send_BarTime(id,0.0)
			playerData[id][PD_MINE_ENT] = FM_NULLENT
			
			return true
		}
		
		return false
	}
	
	// установка координат / make trace origin
	new Float:vecSrc[3],Float:vecAiming[3]
	entity_get_vector(id,EV_VEC_v_angle,vecSrc)
	engfunc(EngFunc_MakeVectors,vecSrc)
	
	entity_get_vector(id,EV_VEC_origin,vecSrc)
	entity_get_vector(id,EV_VEC_view_ofs,vecAiming)
	
	xs_vec_add(vecSrc,vecAiming,vecSrc)
	get_global_vector(GL_v_forward,vecAiming)
	
	xs_vec_mul_scalar(vecAiming,PLANT_RADIUS,vecAiming)
	xs_vec_add(vecSrc,vecAiming,vecAiming)
	
	new Float:flFraction
	engfunc(EngFunc_TraceLine,vecSrc,vecAiming,IGNORE_MISSILE|IGNORE_GLASS|IGNORE_MONSTERS,id,0)
	
	get_tr2(0,TR_flFraction,flFraction)
	
	if(flFraction < 1.0){ // допустимая трассировка
		new pHit
		
		new Float:vecEnd[3],bool:noUpdate
		get_tr2(0,TR_vecEndPos,vecEnd)
		
		while((pHit = find_ent_in_sphere(pHit,vecEnd,8.0))){ //не позволяет устанавливать мины близко вместе с другими
			if(pHit <= maxPlayers || pHit == ent)
				continue
				
			new classname[32]
			entity_get_string(pHit,EV_SZ_classname,classname,charsmax(classname))	
			
			if(strcmp(classname,TRIPMINE_CLASSNAME) == 0){
				noUpdate = true
				
				if(!is_valid_ent(ent))
					return false
			}
		}
		
		if(!is_valid_ent(ent)){	// создание визуального обьекта
			ent =TripMine_Spawn()

			// установка прозрачности
			entity_set_int(ent,EV_INT_rendermode,kRenderTransAdd)
			entity_set_float(ent,EV_FL_renderamt,255.0)
			
			new Float:plantTime = PLANT_TIME
			
			// установка времени установки
			entity_set_float(ent,EV_TM_plantTime,get_gametime() + plantTime)
			entity_set_float(id,EV_FL_maxspeed,1.0)
			
			// показать прогресс установки
			Send_BarTime(id,plantTime)
			
			playerData[id][PD_MINE_ENT] = ent
		}
		
		if(!noUpdate){
			new Float:vecPlaneNormal[3],Float:angles[3]
			get_tr2(0,TR_vecPlaneNormal,vecPlaneNormal)
			vector_to_angle(vecPlaneNormal,angles)
			
			// калькулятор идеального конечного pos
			xs_vec_mul_scalar(vecPlaneNormal,8.0,vecPlaneNormal)
			xs_vec_add(vecEnd,vecPlaneNormal,vecEnd)
			
			// установка origin and angles
			entity_set_origin(ent,vecEnd)
			entity_set_vector(ent,EV_VEC_angles,angles)
		}
		
		if(entity_get_float(ent,EV_TM_plantTime) < get_gametime()){
			new Float:m_vecDir[3],Float:angles[3]
			
			entity_get_vector(ent,EV_VEC_angles,angles)
			engfunc(EngFunc_MakeVectors,angles)
			get_global_vector(GL_v_forward,m_vecDir)
			
			m_vecDir[2] = -m_vecDir[2]
			entity_set_vector(ent,EV_TM_mVecDir,m_vecDir)
			return true
		}
	}else{ // wrong origin
		if(is_valid_ent(ent)){
			ResetMineData(ent);
			remove_entity(ent)
			Send_BarTime(id,0.0)
			playerData[id][PD_MINE_ENT] = FM_NULLENT
		}
	}
		
	return false
}

//
// Plant mine
//
TripMine_Plant(id,ent){
	playerData[id][PD_MINE_ENT] = FM_NULLENT
	playerData[id][PD_NEXTPLANT_TIME] =  _:(get_gametime() + PLANTWAITTIME)
	
	entity_set_int(ent,EV_INT_rendermode,kRenderNormal)
	entity_set_float(ent,EV_FL_renderamt,0.0)
	
	entity_set_edict(ent,EV_TM_hOwner,id)
	entity_set_int(ent,EV_TM_team,get_user_team(id))
	
	emit_sound(ent,CHAN_VOICE,gszSoundPlant,1.0,ATTN_NORM,0,PITCH_NORM)
	emit_sound(ent,CHAN_BODY,gszSoundCharge,0.2,ATTN_NORM,0,PITCH_NORM)
	
	entity_set_float(ent,EV_TM_plantTime,get_gametime() + POWERUPTIME)
	entity_set_float(ent,EV_FL_nextthink,get_gametime() + POWERUPTIME)
	
	ExecuteHamB(Ham_CS_Player_ResetMaxSpeed,id)
	
	cs_set_user_money(id,cs_get_user_money(id) - gszLevelCost1)
	
	client_cmd(id, "-setlaser" )
	
	if(GetPlayer_Mines(id) >= gszMaxCount) // stop
		SetLaser_DropCMD(id)
	
	return true
}

public CmdTouchTripMine(ent, id)
{
	if(!is_valid_ent(ent))
		return;
	
	if(!is_user_alive(id))
		return;
	
	if(gszLaserLevel[ent] == 2)
		return;
	
	new Float:gametime = get_gametime();
	
	if(!(gametime >= gszTimerMenu[id]))
		return;

	gszTimerMenu[id] = gametime + 5.0;

	new Owner = entity_get_edict(ent,EV_TM_hOwner);
	
	if(Owner == id)
	{
		gszCurrentLaser[id] = ent;
		CmdLaserUpdate(id);
	}
}

public TripMine_Think(ent){
	if(entity_get_float(ent,EV_TM_plantTime)){ // проверьте возможность активации
		new Float:m_vecDir[3]
		entity_get_vector(ent,EV_TM_mVecDir,m_vecDir)
	
		new Float:vecSrc[3],Float:vecEnd[3]
		
		entity_get_vector(ent,EV_VEC_origin,vecSrc)
		xs_vec_copy(vecSrc,vecEnd)
	
		xs_vec_mul_scalar(m_vecDir,8.0,m_vecDir)
		xs_vec_add(vecSrc,m_vecDir,vecSrc)
		
		entity_get_vector(ent,EV_TM_mVecDir,m_vecDir)
		xs_vec_mul_scalar(m_vecDir,32.0,m_vecDir)
		xs_vec_add(vecEnd,m_vecDir,vecEnd)
		
		engfunc(EngFunc_TraceLine,vecSrc,vecEnd,DONT_IGNORE_MONSTERS,ent,0)
		
		new Float:flFraction
		
		get_tr2(0,TR_flFraction,flFraction)
		
		if(flFraction == 1.0){
			get_tr2(0,TR_vecEndPos,vecEnd)
			
			new f
			// убедитесь, что игрок не застрял на моем
			while((f = find_ent_in_sphere(f,vecSrc,12.0))){
				if(f > maxPlayers)
					break
					
				entity_set_float(ent,EV_FL_nextthink,get_gametime() + 0.1)
				return
			}
			
			emit_sound(ent,CHAN_BODY,gszSoundCharge,0.0,ATTN_NORM,SND_STOP,0)
			emit_sound(ent,CHAN_VOICE,gszSoundActive,0.5,ATTN_NORM,1,75)
			
			entity_set_int(ent,EV_TM_mineId,random(1337))
			
			TripMine_MakeBeam(ent, 0);

			entity_set_int(ent,EV_INT_solid,SOLID_BBOX)
			entity_set_float(ent,EV_TM_plantTime,0.0)
			
			entity_set_float(ent,EV_FL_takedamage,DAMAGE_YES)
			entity_set_float(ent,EV_FL_dmg,100.0)
			new Float:gszHealth = float(TripMineHealth(ent));
			entity_set_float(ent,EV_FL_health,gszHealth)
		}
	}
	
	new beam = entity_get_edict(ent,EV_TM_pBeam)
	
	if(entity_get_float(ent,EV_FL_health) <= 0.0 && is_valid_ent(beam)){
		ExecuteHamB(Ham_Killed,ent,0,0)
		return
	}
	
	new id = entity_get_edict(ent,EV_TM_hOwner)
	
	if(!is_user_alive(id) || get_user_team(id) != entity_get_int(ent,EV_TM_team)){ // Denote A Mine When Disconnecting Or Changing Team.
		new beam = entity_get_edict(ent,EV_TM_pBeam)
		new beam1 = pev(ent, mine_beam1);
		new beam2 = pev(ent, mine_beam2);
		
		if(is_valid_ent(beam))
			UTIL_Remove(beam)
		
		if(is_valid_ent(beam1))
			UTIL_Remove(beam1)
		
		if(is_valid_ent(beam2))
			UTIL_Remove(beam2)
		
		ResetMineData(ent);
		remove_entity(ent)
		
		return
	}
	
	if(is_valid_ent(beam)){
		new Float:vecSrc[3],Float:vecEnd[3]
		
		entity_get_vector(ent,EV_VEC_origin,vecSrc)
		entity_get_vector(ent,EV_TM_mVecEnd,vecEnd)
		
		new pHit,tr = create_tr2()
		engfunc(EngFunc_TraceLine,vecSrc,vecEnd,DONT_IGNORE_MONSTERS,ent,tr)
		
		pHit = get_tr2(tr,TR_pHit)
		get_tr2(tr,TR_vecEndPos,vecEnd)
		
		Beam_SetStartPos(beam,vecEnd) 
		
		message_begin_f(MSG_PVS,SVC_TEMPENTITY,vecEnd,0)
		write_byte(TE_SPARKS)
		write_coord_f(vecEnd[0])
		write_coord_f(vecEnd[1])
		write_coord_f(vecEnd[2])
		message_end()
		
		if(0 < pHit <= maxPlayers)
		{
			new team = entity_get_int(ent,EV_TM_team)
			new Float:gszDamage = float(TripMineDamage(ent));
			if(get_user_team(pHit) != team && entity_get_float(pHit,EV_FL_takedamage) != 0.0 && entity_get_edict(ent,EV_TM_hOwner) != pHit ){
			
				if(ExecuteHamB(Ham_TakeDamage,pHit,ent,entity_get_edict(ent,EV_TM_hOwner),gszDamage,16777216))
				{
					ExecuteHamB(Ham_TraceBleed,pHit,1337.0,Float:{0.0,0.0,0.0},tr,DMG_ENERGYBEAM)
				}
				else
				{
					gszKillCount[ent]++;
					crxranks_give_user_xp(id,LASERMINE_REWARD)
					emit_sound(pHit,CHAN_WEAPON,gszSoundHit, 1.0, ATTN_NORM, 0, PITCH_NORM )
					entity_set_vector(pHit,EV_VEC_velocity,Float:{0.0,0.0,0.0})
				}
			}
		}
		
		free_tr2(tr)
	}
	
	new beam1
	
	if(is_valid_ent(ent))
		beam1 = pev(ent, mine_beam1)
	
	if(is_valid_ent(beam1)){
		new Float:vecSrc[3],Float:vecEnd[3]
		
		entity_get_vector(ent,EV_VEC_origin,vecSrc)
		entity_get_vector(ent,EV_TM_mVecEnd,vecEnd)
		
		switch(gszLaserLevel[ent])
		{
			case 2:
			{
				new gszAngle = CheckAngleTripMine(ent);
				
				if(checker[ent] < float(gszAngle) && !checker2[ent])
				{
					checker[ent] += 50;
					vecEnd[gszLaserType[ent]] -= checker[ent];
					checker2[ent] = false;
				}
				else if(checker[ent] == float(gszAngle))
					checker2[ent] = true;
					
				if(checker2[ent])
				{
					checker[ent] -= 50
					vecEnd[gszLaserType[ent]] += checker[ent];
					
					if(checker[ent] == 0.0)
						checker2[ent] = false;
				}
			}
			default:
			{
				new gszAngle = CheckAngleTripMine(ent);
				vecEnd[gszLaserType[ent]] += float(gszAngle);
			}
		}

		new pHit,tr = create_tr2()
		engfunc(EngFunc_TraceLine,vecSrc,vecEnd,DONT_IGNORE_MONSTERS,ent,tr)
		
		pHit = get_tr2(tr,TR_pHit)
		get_tr2(tr,TR_vecEndPos,vecEnd)
		Beam_SetStartPos(beam1,vecEnd) 
		
		message_begin_f(MSG_PVS,SVC_TEMPENTITY,vecEnd,0)
		write_byte(TE_SPARKS)
		write_coord_f(vecEnd[0])
		write_coord_f(vecEnd[1])
		write_coord_f(vecEnd[2])
		message_end()
		
		if(0 < pHit <= maxPlayers){
			new team = entity_get_int(ent,EV_TM_team)
			new Float:gszDamage = float(TripMineDamage(ent));
			if(get_user_team(pHit) != team && entity_get_float(pHit,EV_FL_takedamage) != 0.0 && entity_get_edict(ent,EV_TM_hOwner) != pHit ){
			
				if(ExecuteHamB(Ham_TakeDamage,pHit,ent,entity_get_edict(ent,EV_TM_hOwner),gszDamage,16777216)){
					ExecuteHamB(Ham_TraceBleed,pHit,1337.0,Float:{0.0,0.0,0.0},tr,DMG_ENERGYBEAM)
				}else{
					gszKillCount[ent]++;
					crxranks_give_user_xp(id,LASERMINE_REWARD)
					emit_sound(pHit,CHAN_WEAPON,gszSoundHit, 1.0, ATTN_NORM, 0, PITCH_NORM )
					entity_set_vector(pHit,EV_VEC_velocity,Float:{0.0,0.0,0.0})
				}
			}
		}
		
		free_tr2(tr)
	}
	
	new beam2
	
	if(is_valid_ent(ent))
		beam2 = pev(ent, mine_beam2)
	
	if(is_valid_ent(beam2)){
		new Float:vecSrc[3],Float:vecEnd[3]
		
		entity_get_vector(ent,EV_VEC_origin,vecSrc)
		entity_get_vector(ent,EV_TM_mVecEnd,vecEnd)
		
		switch(gszLaserLevel[ent])
		{
			case 2:
			{
				new gszAngle = CheckAngleTripMine(ent);
				
				if(checker[ent] < float(gszAngle) && !checker2[ent])
				{
					checker[ent] += 50;
					vecEnd[gszLaserType[ent]] += checker[ent];
					checker2[ent] = false;
				}
				else if(checker[ent] == float(gszAngle))
					checker2[ent] = true;
					
				if(checker2[ent])
				{
					checker[ent] -= 50
					vecEnd[gszLaserType[ent]] -= checker[ent];
					
					if(checker[ent] == 0.0)
						checker2[ent] = false;
				}
			}
			default:
			{
				new gszAngle = CheckAngleTripMine(ent);
				vecEnd[gszLaserType[ent]] -= float(gszAngle);
			}
		}
		
		new pHit,tr = create_tr2()
		engfunc(EngFunc_TraceLine,vecSrc,vecEnd,DONT_IGNORE_MONSTERS,ent,tr)
		
		pHit = get_tr2(tr,TR_pHit)
		get_tr2(tr,TR_vecEndPos,vecEnd)
		
		Beam_SetStartPos(beam2,vecEnd) 
		
		message_begin_f(MSG_PVS,SVC_TEMPENTITY,vecEnd,0)
		write_byte(TE_SPARKS)
		write_coord_f(vecEnd[0])
		write_coord_f(vecEnd[1])
		write_coord_f(vecEnd[2])
		message_end()
		
		if(0 < pHit <= maxPlayers){
			new team = entity_get_int(ent,EV_TM_team)
			new Float:gszDamage = float(TripMineDamage(ent));
			if(get_user_team(pHit) != team && entity_get_float(pHit,EV_FL_takedamage) != 0.0 && entity_get_edict(ent,EV_TM_hOwner) != pHit ){
			
				if(ExecuteHamB(Ham_TakeDamage,pHit,ent,entity_get_edict(ent,EV_TM_hOwner),gszDamage,16777216)){
					ExecuteHamB(Ham_TraceBleed,pHit,1337.0,Float:{0.0,0.0,0.0},tr,DMG_ENERGYBEAM)
					//add_user_exp(id)
				}else{
					gszKillCount[ent]++;
					crxranks_give_user_xp(id,LASERMINE_REWARD)
					emit_sound(pHit,CHAN_WEAPON,gszSoundHit, 1.0, ATTN_NORM, 0, PITCH_NORM )
					entity_set_vector(pHit,EV_VEC_velocity,Float:{0.0,0.0,0.0})
				}
			}
		}
		
		free_tr2(tr)
	}

	
	if(is_valid_ent(ent)){
		TripMine_StatusInfo(ent)
		entity_set_float(ent,EV_FL_nextthink,get_gametime() + 0.1)
	}
}

TripMine_StatusInfo(ent){
	if(!is_valid_ent(ent))
		return
	
	new player,Float:origin[3],hitEnt,bh
	entity_get_vector(ent,EV_VEC_origin,origin)
	
	while((player = find_ent_in_sphere(player,origin,1024.0))){
		if(player > maxPlayers)
			break
			
		if(get_user_team(player) != entity_get_int(ent,EV_TM_team))
			continue
			
		get_user_aiming(player,hitEnt,bh)
		
		if(hitEnt != ent)
			continue
		
		new planterId,planterName[32],team = entity_get_int(ent,EV_TM_team)
		
		planterId = entity_get_edict(ent,EV_TM_hOwner)
		get_user_name(planterId,planterName,charsmax(planterName))

		set_dhudmessage(team == 1 ? 150 : 0, 0, team == 2 ? 150 : 0, -1.0, 0.35, 0, 0.0, 0.6, 0.0, 0.0)
		show_dhudmessage(player,"Owner: %s^nLevel: %i^nHealth: %.0f/%i^nKills: %i^n",planterName, gszLaserLevel[ent] + 1,entity_get_float(ent,EV_FL_health),TripMineHealth(ent), gszKillCount[ent])
	}
}

//
// Tripmine damage
//
public TripMine_Damage(ent,inflictor,attacker){
	new classname[32]
	entity_get_string(ent,EV_SZ_classname,classname,charsmax(classname))
	
	if(strcmp(classname,TRIPMINE_CLASSNAME) != 0)
		return HAM_IGNORED
		
	entity_set_edict(ent,EV_ENT_dmg_inflictor,attacker)
	
	if(!(0 < attacker <= maxPlayers))
		return HAM_IGNORED
	
	if(entity_get_int(ent,EV_TM_team) == get_user_team(attacker) && entity_get_edict(ent,EV_TM_hOwner) != attacker) // block friendly fire
		return HAM_SUPERCEDE
		
	return HAM_IGNORED
}

//
// Mine Removal
//
public TripMine_Killed(ent){
	new classname[32]
	entity_get_string(ent,EV_SZ_classname,classname,charsmax(classname))
	
	if(strcmp(classname,TRIPMINE_CLASSNAME) != 0)
		return HAM_IGNORED
		
	new beam = entity_get_edict(ent,EV_TM_pBeam)
	new beam1 = pev(ent, mine_beam1);
	new beam2 = pev(ent, mine_beam2);
	// remove beam
	if(is_valid_ent(beam))
		UTIL_Remove(beam)
	
	if(is_valid_ent(beam1))
		UTIL_Remove(beam1)
	
	if(is_valid_ent(beam2))
		UTIL_Remove(beam2)
		
	new Float:origin[3],Float:m_vecDir[3]
	entity_get_vector(ent,EV_VEC_origin,origin)
	entity_get_vector(ent,EV_TM_mVecDir,m_vecDir)
	
	xs_vec_mul_scalar(m_vecDir,8.0,m_vecDir)
	xs_vec_add(origin,m_vecDir,origin)
	
	message_begin_f(MSG_PVS,SVC_TEMPENTITY,origin,0)
	write_byte(TE_EXPLOSION)
	write_coord_f(origin[0])
	write_coord_f(origin[1])
	write_coord_f(origin[2])
	write_short(expSpr)
	write_byte(20)
	write_byte(15)
	write_byte(0)
	message_end()
	
	new killer = entity_get_edict(ent,EV_ENT_dmg_inflictor)
	new hOwner = entity_get_edict(ent,EV_TM_hOwner)
	
	if(!(0 < killer <= maxPlayers) || killer == entity_get_edict(ent,EV_TM_hOwner))
	{
		ChatColor(hOwner,"^1[^4CSDM^1]^3 Your Mine Is Destroyed!")
	}
	else{
		new exploderName[32]
		get_user_name(killer,exploderName,charsmax(exploderName))
		
		ChatColor(hOwner,"^1[^4CSDM^1]^4 %s^3 Destroyed Your Mine!",exploderName)
		cs_set_user_money ( killer, min ( cs_get_user_money ( killer ) + REWARD_MONEY, 50000 ) )
	}
	
	return HAM_IGNORED
}

//
// Mine Beam Creation
//
TripMine_MakeBeam(ent, type)
{
	new beam = Beam_Create(entity_get_int(ent,EV_TM_team) == 1 ? gszModelLaserT : gszModelLaserCT, BEAM_WIDTH)
	
	new Float:m_vecDir[3],Float:vecSrc[3],Float:vecOrigin[3]
	entity_get_vector(ent,EV_TM_mVecDir,m_vecDir)
	entity_get_vector(ent,EV_VEC_origin,vecSrc)
	
	xs_vec_copy(vecSrc,vecOrigin)
	xs_vec_mul_scalar(m_vecDir,LASER_LENGTH,m_vecDir)
	xs_vec_add(vecSrc,m_vecDir,vecSrc)
	
	Beam_PointsInit(beam,vecSrc,vecOrigin)
	Beam_SetScrollRate(beam,255.0)
	Beam_SetBrightness(beam,BEAM_BRIGHT)
	
	switch(type)
	{
		case 0: entity_set_edict(ent,EV_TM_pBeam,beam)
		case 1: set_pev(ent, mine_beam1, beam)
		case 2: set_pev(ent, mine_beam2, beam)
	}

	entity_set_vector(ent,EV_TM_mVecEnd,vecSrc)
	entity_set_edict(beam,EV_ENT_owner,ent)

	entity_set_int(beam,EV_TM_mineId,entity_get_int(ent,EV_TM_mineId))
	entity_set_float(beam,EV_FL_nextthink,get_gametime() + 0.1)
}


Send_BarTime(player,Float:duration){
	if(duration == 0.0){
		ExecuteHamB(Ham_CS_Player_ResetMaxSpeed,player)
	}
	
	message_begin(MSG_ONE,BarTime,.player = player)
	write_short(floatround(duration))
	message_end()
}


UTIL_Remove( pEntity )
{
	if ( !pEntity )
		return;
		
	entity_set_int(pEntity,EV_INT_flags,entity_get_int(pEntity,EV_INT_flags) | FL_KILLME)
}

public CmdLaserUpdate(id)
{
	new gszText[256];
	
	format(gszText, sizeof(gszText), "\yLaserMine Setting Menu^n\yMine Level:\r %i^n\yLaserMine Tilt Angle:\r %i", gszLaserLevel[gszCurrentLaser[id]]+1, gszLaserAngle[gszCurrentLaser[id]]);
	new menu = menu_create(gszText,"HandleUpdateLaser");
	
	switch(gszLaserType[gszCurrentLaser[id]])
	{
		case 0: format(gszText, sizeof(gszText), "\yHere:\r [X]");
		case 1: format(gszText, sizeof(gszText), "\yHere:\r [Horizontal]");
		case 2: format(gszText, sizeof(gszText), "\yHere:\r [Vertical]");
	}
	menu_additem(menu,gszText,"1",0);
	
	switch(gszLaserLevel[gszCurrentLaser[id]])
	{
		case 2: format(gszText, sizeof(gszText), "\dUpgrade Time\r [Not Available]^n");
		default: format(gszText, sizeof(gszText), "\yUpgrade Time\d [%i$]^n", TripMineMoney(gszLaserLevel[gszCurrentLaser[id]] + 1));
	}
	menu_additem(menu,gszText,"2",0);
	
	if(gszLaserLevel[gszCurrentLaser[id]] >= 1)
		menu_additem(menu,"\yChange Of Angle","3",0);
	else menu_additem(menu,"\dChange Of Angel \r[Available From Level 2]","3",0);

	menu_setprop(menu,MPROP_EXIT,"Exit");	
	menu_display(id,menu,0);
}

public HandleUpdateLaser(id,menu,item)
{
	if (item==MENU_EXIT)
	{
		menu_destroy(menu);	
		return PLUGIN_HANDLED;
	}
	new s_Data[6], s_Name[64], i_Access, i_Callback;
	menu_item_getinfo(menu, item, i_Access, s_Data, charsmax(s_Data), s_Name, charsmax(s_Name), i_Callback);
   
	new i_Key = str_to_num(s_Data);
	
	if(!is_valid_ent(gszCurrentLaser[id]))
	{
		ChatColor(id, "^1[^4CSDM^1]^3 Mine Destroyed! It Can't Be Upgraded!");
		return PLUGIN_HANDLED;
	}
	
	switch(i_Key)
	{
		case 1:	
		{
			if(gszLaserType[gszCurrentLaser[id]] == 2) gszLaserType[gszCurrentLaser[id]] = 0;
			else gszLaserType[gszCurrentLaser[id]] += 1;
		}
		case 2:
		{
			if(gszLaserLevel[gszCurrentLaser[id]] == 2)
			{
				ChatColor(id, "^1[^4CSDM^1]^3 Maximum Level!");
			}
			/* else if(!IsMineUpdate(id, gszCurrentLaser[id]))
			{
				ChatColor(id, "^1[^4CSDM^1]^3 Прокачка доступна только для админов");
			} */
			else if(cs_get_user_money(id) < TripMineMoney(gszLaserLevel[gszCurrentLaser[id]] + 1))
			{
				ChatColor(id, "^1[^4CSDM^1]^3 You Don't Enough Money ^1(^4Money %i^1)!", TripMineMoney(gszLaserLevel[gszCurrentLaser[id]] + 1));
			}
			else
			{
				cs_set_user_money(id, cs_get_user_money(id) - TripMineMoney(gszLaserLevel[gszCurrentLaser[id]] + 1));
				gszLaserLevel[gszCurrentLaser[id]] += 1;
				ChatColor(id, "^1[^4CSDM^1]^3 Mine Has Been Upgraded To Level^4 %i!", gszLaserLevel[gszCurrentLaser[id]] + 1);
				
				UpdateTripMine(gszCurrentLaser[id]);
				
				if(gszLaserLevel[gszCurrentLaser[id]] == 2)
					return PLUGIN_HANDLED;
			}
		}
		case 3:
		{
			if(gszLaserLevel[gszCurrentLaser[id]] > 0)
			{
				if(gszLaserAngle[gszCurrentLaser[id]] == 55) gszLaserAngle[gszCurrentLaser[id]] = 35;
				else gszLaserAngle[gszCurrentLaser[id]] += 5;
			}
		}
	}
	
	CmdLaserUpdate(id);
	return PLUGIN_HANDLED;
}

TripMineMoney(level)
{
	new Money;
	
	switch(level)
	{
		case 1: Money = gszLevelCost2;
		case 2: Money = gszLevelCost3;
	}
	
	return Money;
}

UpdateTripMine(ent)
{
	if(!is_valid_ent(ent))
		return;
	
	switch(gszLaserLevel[ent])
	{
		case 0: return;
		case 1:
		{
			TripMine_MakeBeam(ent, 1);
			TripMine_MakeBeam(ent, 2);
			
			new Float:gszHealth = float(TripMineHealth(ent));
			entity_set_float(ent,EV_FL_health,gszHealth)
		}
		case 2:
		{
			new Float:gszHealth = float(TripMineHealth(ent));
			entity_set_float(ent,EV_FL_health,gszHealth)
		}
	}
}

CheckAngleTripMine(ent)
{
	new angle;
	
	switch(gszLaserAngle[ent])
	{
		case 35: angle = 800;
		case 40: angle = 1000;
		case 45: angle = 1300;
		case 50: angle = 1600;
		case 55: angle = 2000;
	}

	return angle;
}

LoadFile()
{
	new path[64]
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/%s", path, MINE_CUSTOMIZATION_FILE)
	
	if (!file_exists(path))
	{
		new error[100]
		formatex(error, charsmax(error), "Cannot load customization file %s!", path)
		set_fail_state(error)
		return;
	}
	
	new linedata[1024], key[64], value[960], section
	
	new file = fopen(path, "rt")
	
	while (file && !feof(file))
	{
		fgets(file, linedata, charsmax(linedata))
		
		replace(linedata, charsmax(linedata), "^n", "")
		
		if (!linedata[0] || linedata[0] == ';') continue;
		
		if (linedata[0] == '[')
		{
			section++
			continue;
		}
		
		strtok(linedata, key, charsmax(key), value, charsmax(value), '=')
		
		trim(key)
		trim(value)
		
		switch (section)
		{
			case SECTION_MAIN:
			{
				if (equal(key, "MODEL_MINE"))
					copy(gszModelTripMine, sizeof(gszModelTripMine), value);
				else if (equal(key, "LASER_TT"))
					copy(gszModelLaserT, sizeof(gszModelLaserT), value);
				else if (equal(key, "LASER_CT"))
					copy(gszModelLaserCT, sizeof(gszModelLaserCT), value);
				else if (equal(key, "MINE_EXPLODE"))
					copy(gszModelMineExl, sizeof(gszModelMineExl), value);
				else if (equal(key, "PLANTSOUND"))
					copy(gszSoundPlant, sizeof(gszSoundPlant), value);
				else if (equal(key, "CHARGESOUND"))
					copy(gszSoundCharge, sizeof(gszSoundCharge), value);
				else if (equal(key, "ACTIVESOUND"))
					copy(gszSoundActive, sizeof(gszSoundActive), value);
				else if (equal(key, "HITSOUND"))
					copy(gszSoundHit, sizeof(gszSoundHit), value);
				else if (equal(key, "MAX_COUNT"))
					gszMaxCount = str_to_num(value)
			}
			case SECTION_LEVEL1:
			{
				if (equal(key, "COST"))
					gszLevelCost1 = str_to_num(value)
				else if (equal(key, "HEALTH"))
					gszLevelHealth1 = str_to_float(value)
				else if (equal(key, "DAMAGE"))
					gszLevelDamage1 = str_to_float(value)
			}
			case SECTION_LEVEL2:
			{
				if (equal(key, "COST"))
					gszLevelCost2 = str_to_num(value)
				else if (equal(key, "HEALTH"))
					gszLevelHealth2 = str_to_float(value)
				else if (equal(key, "DAMAGE"))
					gszLevelDamage2 = str_to_float(value)
				else if (equal(key, "FLAG"))
					copy(gszLevelFlag2, sizeof(gszLevelFlag2), value);
			}
			case SECTION_LEVEL3:
			{
				if (equal(key, "COST"))
					gszLevelCost3 = str_to_num(value)
				else if (equal(key, "HEALTH"))
					gszLevelHealth3 = str_to_float(value)
				else if (equal(key, "DAMAGE"))
					gszLevelDamage3 = str_to_float(value)
				else if (equal(key, "FLAG"))
					copy(gszLevelFlag3, sizeof(gszLevelFlag3), value);
			}
		}
	}
	if (file) fclose(file)
}

TripMineDamage(ent)
{
	new Damage;
	
	switch(gszLaserLevel[ent])
	{
		case 0: Damage = floatround(gszLevelDamage1);
		case 1: Damage = floatround(gszLevelDamage2);
		case 2: Damage = floatround(gszLevelDamage3);
	}
	
	return Damage;
}

TripMineHealth(ent)
{
	new Health;
	
	switch(gszLaserLevel[ent])
	{
		case 0: Health = floatround(gszLevelHealth1);
		case 1: Health = floatround(gszLevelHealth2);
		case 2: Health = floatround(gszLevelHealth3);
	}
	
	return Health;
}

stock bool:IsMineUpdate(id, ent)
{
	new gszFlag[64];
	new nextlevel = gszLaserLevel[ent] + 1;
	
	switch(nextlevel)
	{
		case 1: copy(gszFlag, sizeof(gszFlag), gszLevelFlag2);
		case 2: copy(gszFlag, sizeof(gszFlag), gszLevelFlag3);
	}
	
	if(equal(gszFlag, "ALL") || equal(gszFlag, ""))
		return true;
	
	new flag = read_flags(gszFlag);
	
	if(get_user_flags(id) & flag)
		return true;
	
	return false;
}

stock ChatColor(const id, const input[], any:...)
{
	new count = 1, players[32]
	static msg[191]
	vformat(msg, 190, input, 3)
       
	replace_all(msg, 190, "!g", "^4") // Зелённый цвет
	replace_all(msg, 190, "!y", "^1") // Default цвет
	replace_all(msg, 190, "!team", "^3") // Цвет команды
	replace_all(msg, 190, "!team2", "^0") // Цвет команды 2
       
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

ResetMineData(ent)
{
	gszLaserLevel[ent] = 0;
	gszLaserAngle[ent] = 0;
	gszLaserType[ent] = 0;
	
	gszKillCount[ent] = 0;
	checker[ent] = 0.0;
	checker2[ent] = false;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2057\\ f0\\ fs16 \n\\ par }
*/
