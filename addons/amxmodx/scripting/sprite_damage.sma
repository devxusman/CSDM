#include <amxmodx>
#include <engine>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <xs>

#define MAX_DIGIT	5
#define DAMAGE_CLASSNAME	"sprite_damage"

new damage_spr[MAX_DIGIT][2][128]

new cvar_velo, cvar_rander, cvar_gravity, cvar_expire, cvar_RGB, cvar_critRGB, cvar_critchance, cvar_multiplier

/*
	255, 0, 230	//	PINK
	230, 0, 0		//	BLOODRED
	255, 122, 0	//	ORANGE
*/

new bool:bHamBot = false


public plugin_init()
{
	register_plugin("Sprite Damage", "1.0", "Lie")

	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	register_think(DAMAGE_CLASSNAME, "fw_Think")
	register_forward(FM_AddToFullPack, "fw_AddToFullPack_Post", 1)

	cvar_velo = register_cvar("sprdmg_velo", "8")
	cvar_rander = register_cvar("sprdmg_rander", "160.0")
	cvar_gravity = register_cvar("sprdmg_gravity", "0.04")
	cvar_expire = register_cvar("sprdmg_expire", "15.0")
	cvar_RGB = register_cvar("sprdmg_RGB", "255 255 255")
	cvar_critRGB = register_cvar("sprdmg_critRGB", "255 122 0")
	cvar_critchance = register_cvar("sprdmg_critchance", "25")
	cvar_multiplier = register_cvar("sprdmg_multiplier", "1.5")
}
public plugin_precache()
{
	for (new i = 0;i < MAX_DIGIT;i++)
	{
		formatex(damage_spr[i][0], charsmax(damage_spr[][]), "sprites/Digit_0%d.spr", i + 1)
		precache_model(damage_spr[i][0])
		formatex(damage_spr[i][1], charsmax(damage_spr[][]), "sprites/CritDigit_0%d.spr", i + 1)
		precache_model(damage_spr[i][1])
	}
}
public plugin_natives()
{
	register_native("make_damage_spr", "native_make_damage_spr", 1)
}
public client_putinserver(id)    
{
	if (!bHamBot && is_user_bot(id))    
	{
		bHamBot = true
		set_task(0.1, "Register_HamBot", id)
	}
}
public Register_HamBot(id) 
{
	RegisterHamFromEntity(Ham_TakeDamage, id, "fw_TakeDamage")
}  
public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damagebits)
{
	if (!is_user_connected(victim) || !is_user_alive(victim))
		return HAM_IGNORED;

	if ((victim == attacker) || !is_user_connected(attacker))
		return HAM_IGNORED;

	if (cs_get_user_team(attacker) == cs_get_user_team(victim))
		return HAM_IGNORED;

	new crit = random_num(1, 100) < get_pcvar_num(cvar_critchance) ? 1 : 0
	if (crit)
		damage *= get_pcvar_float(cvar_multiplier)

	native_make_damage_spr(attacker, victim, damage, crit)
	SetHamParamFloat(4, damage)
	return HAM_IGNORED;
}
public fw_AddToFullPack_Post(es, e, ent, host, host_flags, player, p_set)
{
	// Valid player ?
	if (!is_user_connected(host) || !pev_valid(ent))
		return FMRES_IGNORED;
	
	static classname[32]
	pev(ent, pev_classname, classname, charsmax(classname))
	if (!equal(classname, DAMAGE_CLASSNAME))
		return FMRES_IGNORED;
		
	static owner 
	owner = get_es(es, ES_Owner)
	// Player haves a valid sprite entity
	if (owner == host)
	{
		set_es(es, ES_RenderMode, kRenderTransAdd)
		set_es(es, ES_RenderAmt, get_pcvar_float(cvar_rander))
	}
	return FMRES_IGNORED;
}
public fw_Think(iEnt)
{
	if (!pev_valid(iEnt)) 
		return;
	
	set_pev(iEnt, pev_nextthink, halflife_time() + 0.005)

	static Float:fTimeRemove
	pev(iEnt, pev_fuser1, fTimeRemove)
	if (get_gametime() >= fTimeRemove)
	{
		static Float:Amount
		pev(iEnt, pev_renderamt, Amount)
		if (Amount <= get_pcvar_float(cvar_expire))
		{
			engfunc(EngFunc_RemoveEntity, iEnt)
			return;
		} 
		else
		{
			Amount -= get_pcvar_float(cvar_expire)
			set_pev(iEnt, pev_renderamt, Amount)
		}
	}
}
public native_make_damage_spr(attacker, victim, Float:damage, crit)
{
	static Float:rOrigin[3], Float:rFloat[3], Float:aim_Origin[3], digit, iDamage
	iDamage = floatround(damage)
	pev(victim, pev_origin, aim_Origin)
	aim_Origin[2] += 30.0
	for (new i = 0;i < 2;i++)
	{
		rFloat[i] = random_float(-400.0, 400.0)
		rOrigin[i] = aim_Origin[i] + rFloat[i]
	}
	rFloat[2] = random_float(100.0, 400.0)
	rOrigin[2] = aim_Origin[2] + rFloat[2]

	static str_damage[MAX_DIGIT], iFrame[MAX_DIGIT]
	formatex(str_damage, charsmax(str_damage), "%d", iDamage)
	digit = strlen(str_damage)
	for (new i = 0;i < digit;i++)
	{
		iFrame[digit - i - 1] = floatround(str_to_float(str_damage[i]) / power(10, (digit - i) - 1), floatround_floor)
		Create_Damage(attacker, aim_Origin, rOrigin, iFrame[digit - i - 1], get_pcvar_float(cvar_velo), digit - i - 1, digit, crit)
	}
	return HAM_IGNORED;
}
public Create_Damage(id, Float:Origin[3], Float:TargetOrigin[3], iFrame, Float:Speed, digit, size, crit)
{
	static Ent
	Ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_sprite"))
	if (!pev_valid(Ent))
		return;
	
	new Float:Velocity[3], Float:iScale, Float:fDistance, Float:iOrigin[3], Float:color[3], cvarRGB[12], temp[4]
	pev(id, pev_origin, iOrigin)
	fDistance = get_distance_f(iOrigin, Origin)
	iScale = fDistance * 0.000857
	if (iScale <= 0.1)
		iScale = 0.1

	if (fDistance <= 100.0)
		Speed = 3.0

	// Set info for ent
	set_pev(Ent, pev_renderfx, kRenderFxNone)
	set_pev(Ent, pev_rendercolor, {0, 0, 0})
	set_pev(Ent, pev_rendermode, kRenderTransAlpha)
	set_pev(Ent, pev_renderamt, 0)
	set_pev(Ent, pev_movetype, MOVETYPE_BOUNCE)
	get_pcvar_string(crit ? cvar_critRGB : cvar_RGB, cvarRGB, 11)
	for (new i = 0;i < 3;i++)
	{
		strtok(cvarRGB, temp, 3, cvarRGB, 11)
		color[i] = floatclamp(str_to_float(temp), 0.0, 255.0)
	}
	set_pev(Ent, pev_renderfx, kRenderFxGlowShell)
	set_pev(Ent, pev_rendercolor, color)
	if (crit)
		iScale += 0.2

	if (size >= 4)
		iScale += 0.1

	if (size >= 3)
		iScale += 0.1

	if (size < 1)
		iScale -= 0.1

	set_pev(Ent, pev_scale, iScale)
	set_pev(Ent, pev_fuser1, get_gametime() + 0.5)	// time remove
	set_pev(Ent, pev_nextthink, halflife_time() + 0.05)
	set_pev(Ent, pev_friction , 10.0)

	entity_set_string(Ent, EV_SZ_classname, DAMAGE_CLASSNAME)
	engfunc(EngFunc_SetModel, Ent, damage_spr[digit][crit])
	set_pev(Ent, pev_origin, Origin)
	set_pev(Ent, pev_gravity, get_pcvar_float(cvar_gravity))
	set_pev(Ent, pev_solid, SOLID_TRIGGER)
	set_pev(Ent, pev_frame, float(iFrame))
	set_pev(Ent, pev_owner, id)

	get_speed_vector(Origin, TargetOrigin, Speed * 10.0, Velocity)
	set_pev(Ent, pev_velocity, Velocity)
}
stock get_speed_vector(const Float:origin1[3], const Float:origin2[3], Float:speed, Float:new_velocity[3])
{
	new_velocity[0] = origin2[0] - origin1[0]
	new_velocity[1] = origin2[1] - origin1[1]
	new_velocity[2] = origin2[2] - origin1[2]
	new Float:num = floatsqroot(speed * speed / (new_velocity[0] * new_velocity[0] + new_velocity[1] * new_velocity[1] + new_velocity[2] * new_velocity[2]))
	new_velocity[0] *= num
	new_velocity[1] *= num
	new_velocity[2] *= num
	return 1;
}
stock fm_get_aim_origin(index, Float:origin[3])
{
	new Float:start[3], Float:view_ofs[3], Float:dest[3]
	pev(index, pev_origin, start)
	pev(index, pev_view_ofs, view_ofs)
	xs_vec_add(start, view_ofs, start)

	pev(index, pev_v_angle, dest)
	engfunc(EngFunc_MakeVectors, dest)
	global_get(glb_v_forward, dest)
	xs_vec_mul_scalar(dest, 9999.0, dest)
	xs_vec_add(start, dest, dest)

	engfunc(EngFunc_TraceLine, start, dest, 0, index, 0)
	get_tr2(0, TR_vecEndPos, origin)
	return 1;
}  