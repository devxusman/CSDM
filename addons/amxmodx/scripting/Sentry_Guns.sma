new const PLUGINNAME[] = "Sentry guns"
new const VERSION[] = "0.5.3"
new const AUTHOR[] = "JGHG & GlobalModders.net Scripting Team"

#define MODEL_SENTRYGUN_BASE_TR		"models/CSDM_By_TSM/base.mdl"
#define MODEL_SENTRYGUN_LEVEL1_TR	"models/CSDM_By_TSM/sentry1_t.mdl"
#define MODEL_SENTRYGUN_LEVEL2_TR	"models/CSDM_By_TSM/sentry2_t.mdl"
#define MODEL_SENTRYGUN_LEVEL3_TR	"models/CSDM_By_TSM/sentry3_t.mdl"

#define MODEL_SENTRYGUN_BASE_CT		"models/CSDM_By_TSM/base.mdl"
#define MODEL_SENTRYGUN_LEVEL1_CT	"models/CSDM_By_TSM/sentry1_ct.mdl"
#define MODEL_SENTRYGUN_LEVEL2_CT	"models/CSDM_By_TSM/sentry2_ct.mdl"
#define MODEL_SENTRYGUN_LEVEL3_CT	"models/CSDM_By_TSM/sentry3_ct.mdl"

//#define DEBUG

/*#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fun>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>*/


#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fun>
#include <cstrike>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <xs>
#include <dhudmessage>


#if defined DEBUG
#include <amxmisc>
#endif

#define VIP ADMIN_LEVEL_H

new sentry_max, sentryvip_max, sentry_cost1, sentry_cost2, sentry_cost3, sentry_team;
#define MAXSENTRIESTOTAL 12
// ---------- Adjust below settings to your liking ---------------------------------------------------------------------------------------------------------------------------------
//#define MAXPLAYERSENTRIES		1				// how many sentries each player can build
#define MAXPLAYERSENTRIES		get_pcvar_num(sentry_max)				// how many sentries each player can build
#define MAXVIPSENTRIES		get_pcvar_num(sentryvip_max)
#define DMG_EXPLOSION_TAKE		90				// how much HP at most an exploding sentry takes from a player - the further away the less dmg is dealt to player
#define SENTRYEXPLODERADIUS		250.0			// how far away it is safe to be from an exploding sentry without getting kicked back and hurt
#define THINKFIREFREQUENCY		0.1				// the rate in seconds between each bullet when firing at a locked target
#define SENTRYTILTRADIUS		830.0			// likely you won't need to touch this. it's how accurate the cannon will aim at the target vertically (up/down, just for looks, aim is calculated differently)
/*#if !defined DEBUG
#define DISALLOW_OWN_UPGRADES				// you cannot upgrade your own sentry to level 2 (only to level 3 if someone else upgraded it already) (only have this commented in debug mode)
#define DISALLOW_TWO_UPGRADES				// the upgrader cannot upgrade again, builder must upgrade to level 3 (only have this commented in debug mode)
#endif*/
//#define SENTRIES_SURVIVE_ROUNDS				// comment this define to have sentries removed between rounds, else they will stay where they are.
//#define RANDOM_TOPCOLOR						// sentries have two colors, one top and one bottom. The top one will be random if you leave this define be, else always red for T and blue for CT.
//#define RANDOM_BOTTOMCOLOR					// sentries have two colors, one top and one bottom. The bottom one will be random if you leave this define be, else always red for T and blue for CT.
#define EXPLODINGSENTRIES						// comment this out if you don't want the sentries to explode, push people away and hurt them (should now be stable!)
// Bots will build sentries at objective critical locations (around dropped bombs, at bomb targets, near hostages etc)
// They can also build randomly around maps using these values:
#define BOT_WAITTIME_MIN		0.0				// waittime = the time a bot will wait after he's decided to build a sentry, before actually building (seconds)
#define BOT_WAITTIME_MAX		15.0
#define BOT_NEXT_MIN			0.0				// next = after building a sentry, this specifies the time a bot will wait until considering about waittime again (seconds)
#define BOT_NEXT_MAX			120.0
// These are per sentry level, 1-3
new const g_SENTRYFRAGREWARDS[3] = {300, 400, 1000}		// how many $ you get if your sentry frags someone. If you built and upgraded to level 3 you would get $300 + $150 = $450. If built and upgraded all you would get $600.
new const g_DMG[3] = {10, 20, 35}						// how much damage a bullet from a sentry does per hit
new const Float:g_THINKFREQUENCIES[3] = {0.5, 0.3, 0.1}	// how often, in seconds, a sentry searches for targets when not locked at a target, a lower value means a sentry will lock on targets faster
new const Float:g_HITRATIOS[3] = {0.75, 0.85, 1.0}		// how good a sentry is at hitting its target. 1.0 = always hit, 0.0 = never hit
new const Float:g_HEALTHS[3] = {3000.0, 12000.0, 24000.0}	// how many HP a sentry has. Increase to make sentry sturdier
//new const g_COST[3] = {5000, 1000, 3000}					// fun has a price, first is build cost, the next two upgrade costs
#define COST_INIT get_pcvar_num(sentry_cost1)
#define COST_UP get_pcvar_num(sentry_cost2)
#define COST_UPTWO get_pcvar_num(sentry_cost3)
// ---------- Adjust above settings to your liking ---------------------------------------------------------------------------------------------------------------------------------

#if !defined PI
#define PI						3.141592654 // feel free to find a PI more exact than this
#endif

#define MENUBUTTON1				(1<<0)
#define MENUBUTTON2				(1<<1)
#define MENUBUTTON3				(1<<2)
#define MENUBUTTON4				(1<<3)
#define MENUBUTTON5				(1<<4)
#define MENUBUTTON6				(1<<5)
#define MENUBUTTON7				(1<<6)
#define MENUBUTTON8				(1<<7)
#define MENUBUTTON9				(1<<8)
#define MENUBUTTON0				(1<<9)
#define MENUSELECT1				0
#define MENUSELECT2				1
#define MENUSELECT3				2
#define MENUSELECT4				3
#define MENUSELECT5				4
#define MENUSELECT6				5
#define MENUSELECT7				6
#define MENUSELECT8				7
#define MENUSELECT9				8
#define MENUSELECT0				9
#define MAXHTMLSIZE				1536

#define MAXSENTRIES				32 * MAXSENTRIESTOTAL

#define SENTRY_VEC_PEOPLE			EV_VEC_vuser1
#define OWNER						0
#define UPGRADER_1					1
#define UPGRADER_2					2
//#define SENTRY_VECENT_OWNER			SENTRY_VEC_PEOPLE + OWNER
//#define SENTRY_VECENT_UPGRADER_1	SENTRY_VEC_PEOPLE + UPGRADER_1
//#define SENTRY_VECENT_UPGRADER_2	SENTRY_VEC_PEOPLE + UPGRADER_2

GetSentryPeople(sentry, who) {
new Float:people[3]
entity_get_vector(sentry, SENTRY_VEC_PEOPLE, people)
return floatround(people[who])
}
SetSentryPeople(sentry, who, is) {
new Float:people[3]
entity_get_vector(sentry, SENTRY_VEC_PEOPLE, people)
people[who] = is + 0.0
entity_set_vector(sentry, SENTRY_VEC_PEOPLE, people)
}

#define SENTRY_ENT_TARGET		EV_ENT_euser1
#define SENTRY_ENT_BASE			EV_ENT_euser2
#define SENTRY_ENT_SPYCAM		EV_ENT_euser3
#define SENTRY_INT_FIRE			EV_INT_iuser1
#define SENTRY_INT_TEAM			EV_INT_iuser2
#define SENTRY_INT_LEVEL		EV_INT_iuser3
#define SENTRY_INT_PENDDIR		EV_INT_iuser4 // 1st bit: sentry cannon, 2nd bit: radar
#define SENTRY_FL_ANGLE			EV_FL_fuser1
#define SENTRY_FL_SPINSPEED		EV_FL_fuser2
#define SENTRY_FL_MAXSPIN		EV_FL_fuser3
#define SENTRY_FL_RADARANGLE	EV_FL_fuser4

// These are bits used in SENTRY_INT_PENDDIR
#define SENTRY_DIR_CANNON		0
#define SENTRY_DIR_RADAR		1

#define BASE_ENT_SENTRY			EV_ENT_euser1
#define BASE_INT_TEAM			EV_INT_iuser1

#define SENTRY_LEVEL_1			0
#define SENTRY_LEVEL_2			1
#define SENTRY_LEVEL_3			2
#define SENTRY_FIREMODE_NO		0
#define SENTRY_FIREMODE_YES		1
#define SENTRY_FIREMODE_NUTS	2

#define SENTRY_FIREMODE_ROCKETS	10

#define TASKID_SENTRYFIRE		1000
#define TASKID_BOTBUILDRANDOMLY	2000
#define TASKID_SENTRYSTATUS		3000
#define TASKID_THINK			4000
#define TASKID_THINKPENDULUM	5000
#define TASKID_SENTRYONRADAR	6000
#define TASKID_SPYCAM			7000
#define DUCKINGPLAYERDIFFERENCE	18.0
#define TARGETUPMODIFIER		DUCKINGPLAYERDIFFERENCE // if player ducks on ground, traces don't hit...
#define DMG_BULLET				(1<<1)	// shot
#define DMG_BLAST				(1<<6)	// explosive blast damage
#define TE_EXPLFLAG_NONE		0
#define TE_EXPLOSION			3
#define	TE_TRACER				6
#define TE_BREAKMODEL			108
#define BASESENTRYDELAY			2.0 // seconds from base is built until sentry top appears
#define PENDULUM_MAX			45.0 // how far sentry turret turns in each direction when idle, before turning back
#define PENDULUM_INCREMENT		10.0 // speed of turret turning...
#define RADAR_INCREMENT			1.5 // speed of small radar turning on top of sentry level 3...
#define MAXUPGRADERANGE			75.0 // farthest distance to sentry you can upgrade using upgrade command
#define COLOR_BOTTOM_CT			160 // default bottom colour of CT:s sentries
#define COLOR_TOP_CT			150 // default top colour of CT:s sentries
#define COLOR_BOTTOM_T			0 // default bottom colour of T:s sentries
#define COLOR_TOP_T				0 // default top colour of T:s sentries
#define SENTRYSHOCKPOWER		3.0 // multiplier, increase to make exploding sentries throw stuff further away
#define CANNONHEIGHTFROMFEET	20.0 // tweakable to make tracer originate from the same height as the sentry's cannon. Also traces rely on this Y-wise offset.
#define PLAYERORIGINHEIGHT		36.0 // this is the distance from a player's EV_VEC_origin to ground, if standing up
#define HEIGHTDIFFERENCEALLOWED	20.0 // increase value to allow building in slopes with higher angles. You can set to 0.0 and you will only be able to build on exact flat ground. note: mostly applies to downhill building, uphill is still likely to "collide" with ground...

// This cannot account for sentries which are still under construction (only base, no sentry head yet):
// How many (or more) sentries:
#define BOT_MAXSENTRIESNEAR		1
// cannot be in the vicinity of this radius:
#define BOT_MAXSENTRIESDISTANCE	2000.0
// for a bot to build at a location. Use higher values and bots will build sentries less close to other sentries on same team.

#define BOT_OBJECTIVEWAIT		10 // nr of seconds that must pass after a bot has built an objective related sentry until he can build such a sentry again.


#define SENTRY_TILT_TURRET			EV_BYTE_controller2
#define SENTRY_TILT_LAUNCHER		EV_BYTE_controller3
#define SENTRY_TILT_RADAR			EV_BYTE_controller4
#define PEV_SENTRY_TILT_TURRET		pev_controller_1
#define PEV_SENTRY_TILT_LAUNCHER	pev_controller_2
#define PEV_SENTRY_TILT_RADAR		pev_controller_3

#define STATUSINFOTIME			0.5 // the frequency of hud message updates when spectating a sentry, don't set too low or it could overflow clients. Data should now always send again as soon as it updates though.
#define SENTRY_RADAR			20 // use as high as possible but should still be working (ie be able to see sentries plotted on radar while in menu, too high values doesn't seem to work)
#define SENTRY_RADAR_TEAMBUILT	21 // same as above

#define SPYCAMTIME				5.0 // nr of seconds the spycam is active

enum OBJECTTYPE {
OBJECT_GENERIC,
OBJECT_GRENADE,
OBJECT_PLAYER,
OBJECT_ARMOURY
}

// Global vars below
new g_sentriesNum = 0
new g_sentries[MAXSENTRIES]
new g_playerSentries[32] = {0, ...}
new g_playerSentriesEdicts[32][MAXSENTRIESTOTAL]
new g_sModelIndexFireball
new g_msgDamage
new g_msgDeathMsg
new g_msgScoreInfo
new g_msgHostagePos
new g_msgHostageK
new g_MAXPLAYERS
//new g_MAXENTITIES
new Float:g_ONEEIGHTYTHROUGHPI
//new g_hasSentries = 0
new Float:g_sentryOrigins[32][3]
new g_aimSentry[32]
//new bool:g_inBuilding[32]
new bool:g_resetArmouryThisRound = true
new bool:g_hasArmouries = false
new Float:g_lastGameTime = 1.0 // dunno, looks like get_systime() is always 1.0 first time...
new Float:g_gameTime
new Float:g_deltaTime
new g_sentryStatusBuffer[32][256]
new g_sentryStatusTrigger
new g_selectedSentry[32] = {-1, ...}
new g_menuId // used to store index of menu
new g_lastObjectiveBuild[32]
new g_inSpyCam[32]
new Float:g_spyCamOffset[3] = {26.0, 29.0, 26.0} // for the three levels, just what looks good...
//Shaman: For disabling building until some time passes after the new round
new bool:g_allowBuild //Building, upgrading and reparing is not allowed if this is false
new sentry_wait //The cvar
// Global vars above


//Shaman: Event function that removes sentries of a player after team change
public jointeam_event()
	{
	//Get the di from the event data
	new id= read_data(1)	
	
	//Remove sentries
	while(GetSentryCount(id)>0)
		sentry_detonate_by_owner(id, true)
	
	return PLUGIN_CONTINUE
	}

//Shaman: The function that enables building
public enablesentrybur()
	{
	g_allowBuild= true;
	}

public createsentryhere(id) {
//Shaman: Check if the player is allowed to build
{
	sentry_build(id)
	}

new sentry = AimingAtSentry(id, true)
// if a valid sentry
// if within range
// we can try to upgrade/repair...
if (sentry && entity_range(sentry, id) <= MAXUPGRADERANGE)
{
	/*//client_print(id, print_chat, "Уровень: %d, Обновление: %d", entity_get_int(sentry, SENTRY_INT_LEVEL) + 1, entity_get_edict(sentry, SENTRY_ENT_LASTUPGRADER))
	//#if defined DISALLOW_OWN_UPGRADES
	// Don't allow builder to upgrade his own sentry first time.
	if (entity_get_int(sentry, SENTRY_INT_LEVEL) == SENTRY_LEVEL_1 && id == GetSentryPeople(sentry, OWNER)) {
		ChatColor(id,"^1[^4CSDM^1]^3You Can't Upgrade Your Own ^4Sentry.")
		return PLUGIN_HANDLED
	}
	//#if defined DISALLOW_TWO_UPGRADES
	// Don't allow upgrader to upgrade again.
	if (entity_get_int(sentry, SENTRY_INT_LEVEL) == SENTRY_LEVEL_2 && id == GetSentryPeople(sentry, UPGRADER_1)) {
		ChatColor(id,"^1[^4CSDM^1]^3You Can't Upgrade This Sentry To Level ^42.")
		return PLUGIN_HANDLED
	}*/
	g_aimSentry[id - 1] = sentry
	//if (entity_
	sentry_upgrade(id, sentry)
}
else {
	is_user_alive(id)
}

return PLUGIN_HANDLED
}

public sentry_build(id) {

if (GetSentryCount(id) >= MAXPLAYERSENTRIES) {
	new wordnumbers[128]
	getnumbers(MAXPLAYERSENTRIES, wordnumbers, 127)
	new maxsentries = MAXPLAYERSENTRIES // stupid, but compiler gives warning on next line if a defined constant is used
	ChatColor(id,"^1[^4CSDM^1]^3You can Only Build ^4%s ^3Sentries.", wordnumbers, maxsentries != 1 ? "s" : "")
	return
}
else
if (GetSentryCount(id) >= MAXVIPSENTRIES){
	if(get_user_flags(id) && VIP){
	new wordnumbers[128]
	getnumbers(MAXVIPSENTRIES, wordnumbers, 127)
	new maxvipsentries = MAXVIPSENTRIES // stupid, but compiler gives warning on next line if a defined constant is used
	ChatColor(id,"^1[^4CSDM VIP^1]^3You can Only Build ^4%s ^3Sentries.", wordnumbers, maxvipsentries != 1 ? "s" : "")
	return
	}
}
/*else if (g_inBuilding[id - 1]) {
	ChatColor(id,"^1[^4CSDM^1]^4WoW! ^3You Are Fast ^4Builder.")
	return
}*/
else if (!is_user_alive(id)) {
	return
}
else if (cs_get_user_money(id) < g_COST(0)) {
	ChatColor(id,"^1[^4CSDM^1]^3You Don't Have Money To Build ^4Sentry^3. (^4You Need: %d $^3)", g_COST(0))
	return
}
else if (!entity_is_on_ground(id)) {
	ChatColor(id,"^1[^4CSDM^1]^3You Must Be On ^4Ground ^3To Build ^4Sentry^3.")
	return
}
/*else if (entity_get_int(id, EV_INT_flags) & FL_DUCKING) {
else if (entity_get_int(id, EV_INT_bInDuck)) {
	ChatColor(id,"^1[^4CSDM^1]^3Да, право, попытайтесь строить автоматизированное орудие, сидящее на Вашем !")
	return
}*/
else if ( get_pcvar_num( sentry_team ) ) {
	if( get_pcvar_num( sentry_team ) < 0 && !is_user_admin(id) ){
		ChatColor(id,"^1[^4CSDM^1]^3For ^4Admins ^3Only.")
		return
	}
	else if( !(abs(get_pcvar_num( sentry_team )) & _:cs_get_user_team(id)) ){
		ChatColor(id,"^1[^4CSDM^1]^3Your ^4Team ^3Can't ^4Build^3!")
		return
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

if (CreateSentryBase(vNewOrigin, id)) {
	cs_set_user_money(id, cs_get_user_money(id) - g_COST(0))
	//SetHasSentry(id, true)
	//client_print(id, print_chat, "Done creating a sentry at %f %f %f!", vNewOrigin[0], vNewOrigin[1], vNewOrigin[2])
}
else {
	//SetHasSentry(id, false)
	ChatColor(id,"^1[^4CSDM^1]^4Sentry ^3Can't Built Here.")
}
}

GetSentryCount(id) {
return g_playerSentries[id - 1]

//else

/*
if (id < 1 || id > get_maxplayers())
	return false

//spambits(id, g_hasSentries)

return g_hasSentries & (1<<(id - 1)) ? true : false // g_hasSentries[id - 1] //
*/
}

bool:GetStatusTrigger(player) {
if (!is_user_alive(player))
	return false

return g_sentryStatusTrigger & (1<<(player-1)) ? true : false
}
SetStatusTrigger(player, bool:onOrOff) {
if (onOrOff)
	g_sentryStatusTrigger |= (1<<(player - 1))
else
	g_sentryStatusTrigger &= ~(1<<(player - 1))
}

IncreaseSentryCount(id, sentryEntity) {
g_playerSentriesEdicts[id - 1][g_playerSentries[id - 1]] = sentryEntity
g_playerSentries[id - 1] = g_playerSentries[id - 1] + 1
new Float:sentryOrigin[3], iSentryOrigin[3]
entity_get_vector(sentryEntity, EV_VEC_origin, sentryOrigin)
FVecIVec(sentryOrigin, iSentryOrigin)

new name[32]
get_user_name(id, name, 31)
new CsTeams:builderTeam = cs_get_user_team(id)
for (new i = 1; i <= g_MAXPLAYERS; i++) {
	if (!is_user_connected(i) || !is_user_alive(i) || cs_get_user_team(i) != builderTeam || id == i)
		continue
	ChatColor(i, "^1[^4CSDM^1]^3 The Player (^4%s^3) Has Built A ^4Sentry ^3At The Distance Of ^4%d ^3Meters.", name, floatround(entity_range(i, sentryEntity)))

	//client_print(parm[0], print_chat, "Plotting closest sentry %d on radar: %f %f %f", parm[1], sentryOrigin[0], sentryOrigin[1], sentryOrigin[2])
	message_begin(MSG_ONE, g_msgHostagePos, {0,0,0}, i)
	write_byte(i)
	write_byte(SENTRY_RADAR_TEAMBUILT)
	write_coord(iSentryOrigin[0])
	write_coord(iSentryOrigin[1])
	write_coord(iSentryOrigin[2])
	message_end()

	message_begin(MSG_ONE, g_msgHostageK, {0,0,0}, i)
	write_byte(SENTRY_RADAR_TEAMBUILT)
	message_end()
}
//client_print(0, print_chat, "%s has built a sentry gun", name)
}

DecreaseSentryCount(id, sentry) {
// Note that sentry does not exist at this moment, it's just an old index that should get zeroed where it occurs in g_playerSentriesEdicts[id - 1][]
g_selectedSentry[id - 1] = -1

for (new i = 0; i < g_playerSentries[id - 1]; i++) {
	if (g_playerSentriesEdicts[id - 1][i] == sentry) {
		// Copy last sentry edict index to this one
		g_playerSentriesEdicts[id - 1][i] = g_playerSentriesEdicts[id - 1][g_playerSentries[id - 1] - 1]
		// Zero out last sentry index
		g_playerSentriesEdicts[id - 1][g_playerSentries[id - 1] - 1] = 0
		break
	}
}
g_playerSentries[id - 1] = g_playerSentries[id - 1] - 1
}

/*
SetHasSentry(id, bool:trueOrFalse) {
//g_hasSentries[id - 1] = trueOrFalse
//spambits(id, g_hasSentries)
if (trueOrFalse) {
	g_hasSentries |= (1<<(id - 1))
	new name[32]
	get_user_name(id, name, 31)
	new CsTeams:builderTeam = cs_get_user_team(id)
	for (new i = 0; i < g_MAXPLAYERS; i++) {
		if (!is_user_connected(i) || !is_user_alive(i) || cs_get_user_team(i) != builderTeam || id == i)
			continue
		client_print(i, print_center, "Игрок %s построил пушку. Обновите её !", name)
	}
}
else
	g_hasSentries &= ~(1<<(id - 1))

//spambits(id, g_hasSentries)
}
*/

stock bool:CreateSentryBase(Float:origin[3], creator) {
// Check contents of point, also trace lines from center to each of the eight ends
if (point_contents(origin) != CONTENTS_EMPTY || TraceCheckCollides(origin, 24.0)) {
	return false
}

// Check that a trace from origin straight down to ground results in a distance which is the same as player height over ground?
new Float:hitPoint[3], Float:originDown[3]
originDown = origin
originDown[2] = -5000.0 // dunno the lowest possible height...
trace_line(0, origin, originDown, hitPoint)
new Float:baDistanceFromGround = vector_distance(origin, hitPoint)
//client_print(creator, print_chat, "Base distance from ground: %f", baDistanceFromGround)

new Float:difference = PLAYERORIGINHEIGHT - baDistanceFromGround
if (difference < -1 * HEIGHTDIFFERENCEALLOWED || difference > HEIGHTDIFFERENCEALLOWED) {
	//client_print(creator, print_chat, "You can't build here! %f", difference)
	return false
}

new entbase = create_entity("func_breakable") // func_wall
if (!entbase)
	return false

// Set sentrybase health
new healthstring[16]
num_to_str(floatround(g_HEALTHS[0]), healthstring, 15)
DispatchKeyValue(entbase, "health", healthstring)
DispatchKeyValue(entbase, "material", "6")

DispatchSpawn(entbase)
// Change classname
entity_set_string(entbase, EV_SZ_classname, "sentrybase")
// Set model
new iTeam = get_user_team(creator);

entity_set_model(entbase, (iTeam == 1) ? MODEL_SENTRYGUN_BASE_TR : MODEL_SENTRYGUN_BASE_CT) // later set according to level
// Set size
new Float:mins[3], Float:maxs[3]
mins[0] = -16.0
mins[1] = -16.0
mins[2] = 0.0
maxs[0] = 16.0
maxs[1] = 16.0
maxs[2] = 1000.0 // Set to 16.0 later.
entity_set_size(entbase, mins, maxs)
//client_print(creator, print_chat, "Creating sentry %d with bounds %f", ent, BOUNDS)
// Set origin
entity_set_origin(entbase, origin)
// Set starting angle
//entity_get_vector(creator, EV_VEC_angles, origin)
//origin[0] = 0.0
//origin[1] += 180.0
//origin[2] = 0.0
//entity_set_vector(ent, EV_VEC_angles, origin)
// Set solidness
entity_set_int(entbase, EV_INT_solid, SOLID_SLIDEBOX) // SOLID_SLIDEBOX
// Set movetype
entity_set_int(entbase, EV_INT_movetype, MOVETYPE_TOSS) // head flies, base falls

// Set team
entity_set_int(entbase, BASE_INT_TEAM, iTeam)

new parms[2]
parms[0] = entbase
parms[1] = creator

g_sentryOrigins[creator - 1] = origin

emit_sound(creator, CHAN_AUTO, "sentries/building.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

set_task(BASESENTRYDELAY, "createsentryhead", 0, parms, 2)
//g_inBuilding[creator - 1] = true

return true
}

public createsentryhead(parms[2]) {
new entbase = parms[0]

new creator = parms[1]
/*if (!g_inBuilding[creator - 1]) {
	// g_inBuilding is reset upon new round, then don't continue with building sentry head. Remove base and return.
	if (is_valid_ent(entbase))
		remove_entity(entbase)
	return
}*/

new Float:origin[3]
origin = g_sentryOrigins[creator - 1]

new ent = create_entity("func_breakable")
if (!ent) {
	if (is_valid_ent(entbase))
		remove_entity(entbase)
	return
}

new Float:mins[3], Float:maxs[3]
// Set true	size of base... if it exists!
// Also set sentry <-> base connections, if base still exists
if (is_valid_ent(entbase)) {
	mins[0] = -16.0
	mins[1] = -16.0
	mins[2] = 0.0
	maxs[0] = 16.0
	maxs[1] = 16.0
	maxs[2] = 16.0
	entity_set_size(entbase, mins, maxs)

	entity_set_edict(ent, SENTRY_ENT_BASE, entbase)
	entity_set_edict(entbase, BASE_ENT_SENTRY, ent)
}

// Store our sentry in array
g_sentries[g_sentriesNum] = ent

new healthstring[16]
num_to_str(floatround(g_HEALTHS[0]), healthstring, 15)
DispatchKeyValue(ent, "health", healthstring)
DispatchKeyValue(ent, "material", "6")

DispatchSpawn(ent)
// Change classname
entity_set_string(ent, EV_SZ_classname, "sentry")
// Set model
new iTeam = get_user_team(creator);

entity_set_model(ent, (iTeam == 1) ? MODEL_SENTRYGUN_LEVEL1_TR : MODEL_SENTRYGUN_LEVEL1_CT) // later set according to level
// Set size
mins[0] = -16.0
mins[1] = -16.0
mins[2] = 0.0
maxs[0] = 16.0
maxs[1] = 16.0
maxs[2] = 48.0
entity_set_size(ent, mins, maxs)
//client_print(creator, print_chat, "Creating sentry %d with bounds %f", ent, BOUNDS)
// Set origin
entity_set_origin(ent, origin)
// Set starting angle
entity_get_vector(creator, EV_VEC_angles, origin)
origin[0] = 0.0
origin[1] += 180.0
entity_set_float(ent, SENTRY_FL_ANGLE, origin[1])
origin[2] = 0.0
entity_set_vector(ent, EV_VEC_angles, origin)
// Set solidness
entity_set_int(ent, EV_INT_solid, SOLID_SLIDEBOX) // SOLID_SLIDEBOX
// Set movetype
entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS) // head flies, base doesn't
// Set tilt of cannon
set_pev(ent, PEV_SENTRY_TILT_TURRET, 127) //entity_set_byte(ent, SENTRY_TILT_TURRET, 127) // 127 is horisontal
// Tilt of rocket launcher barrels at level 3
set_pev(ent, PEV_SENTRY_TILT_LAUNCHER, 127) //entity_set_byte(ent, SENTRY_TILT_LAUNCHER, 127) // 127 is horisontal
// Angle of small radar at level 3
entity_set_float(ent, SENTRY_FL_RADARANGLE, 127.0)
set_pev(ent, PEV_SENTRY_TILT_RADAR, 127) //entity_set_byte(ent, SENTRY_TILT_RADAR, 127) // 127 is middle


// Set owner
//entity_set_edict(ent, SENTRY_ENT_OWNER, creator)
SetSentryPeople(ent, OWNER, creator)

// Set team
entity_set_int(ent, SENTRY_INT_TEAM, iTeam)

// Set level (not really necessary, but for looks)
entity_set_int(ent, SENTRY_INT_LEVEL, SENTRY_LEVEL_1)

// Top color
#if defined RANDOM_TOPCOLOR
new topColor = random_num(0, 255)
#else
new topColor = cs_get_user_team(creator) == CS_TEAM_CT ? COLOR_TOP_CT : COLOR_TOP_T
#endif
// Bottom color
#if defined RANDOM_BOTTOMCOLOR
new bottomColor = random_num(0, 255)
#else
new bottomColor = cs_get_user_team(creator) == CS_TEAM_CT ? COLOR_BOTTOM_CT : COLOR_BOTTOM_T
#endif

// Set color
new map = topColor | (bottomColor<<8)
//spambits(creator, topColor)
//spambits(creator, bottomColor)
//spambits(creator, map)
entity_set_int(ent, EV_INT_colormap, map)

g_sentriesNum++

emit_sound(ent, CHAN_AUTO, "sentries/turrset.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

IncreaseSentryCount(creator, ent)

new parm[4]
parm[0] = ent
set_task(g_THINKFREQUENCIES[0], "sentry_think", TASKID_THINK + parm[0], parm, 1)

parm[1] = random_num(0, 1)
parm[2] = 0
parm[3] = 0
new directions = (random_num(0, 1)<<SENTRY_DIR_CANNON) | (random_num(0, 1)<<SENTRY_DIR_RADAR)
entity_set_int(ent, SENTRY_INT_PENDDIR, directions)

//entity_set_float(ent, SENTRY_FL_RADARDIR, random_num(0, 1) + 0.0)

//g_inBuilding[creator - 1] = false

if (!is_valid_ent(entbase)) {
	// Someone probably destroyed the base before head was built!
	// Sentry should go nuts. :-P
	entity_set_int(ent, SENTRY_INT_FIRE, SENTRY_FIREMODE_NUTS)
}
}

public server_frame() {
g_gameTime = get_gametime()
g_deltaTime = g_gameTime - g_lastGameTime
//server_print("Gametime: %f, Last gametime: %f", g_gameTime, g_lastGameTime)

new tempSentries[MAXSENTRIES], Float:angles[3]

new tempSentriesNum = 0
for (new i = 0; i < g_sentriesNum; i++) {
	//sentry_pendulum(g_sentries[i], g_deltaTime)
	tempSentries[i] = g_sentries[i]
	tempSentriesNum++
}

for (new i = 0; i < tempSentriesNum; i++) {
	//if (entity_get_float(tempSentries[i], EV_FL_nextthink) < g_game
	sentry_pendulum(tempSentries[i], g_deltaTime)
	if (entity_get_edict(tempSentries[i], SENTRY_ENT_SPYCAM) != 0) {
		entity_get_vector(tempSentries[i], EV_VEC_angles, angles)
		entity_set_vector(entity_get_edict(tempSentries[i], SENTRY_ENT_SPYCAM), EV_VEC_angles, angles)
	}
}

g_lastGameTime = g_gameTime
return PLUGIN_CONTINUE
}

sentry_pendulum(sentry, Float:deltaTime) {
switch (entity_get_int(sentry, SENTRY_INT_FIRE)) {
	case SENTRY_FIREMODE_NO: {
		new Float:angles[3]
		entity_get_vector(sentry, EV_VEC_angles, angles)
		new Float:baseAngle = entity_get_float(sentry, SENTRY_FL_ANGLE)
		new directions = entity_get_int(sentry, SENTRY_INT_PENDDIR)
		if (directions & (1<<SENTRY_DIR_CANNON)) {
			angles[1] -= (PENDULUM_INCREMENT * deltaTime) // PENDULUM_INCREMENT get_cvar_float("pend_inc")
			if (angles[1] < baseAngle - PENDULUM_MAX) {
				angles[1] = baseAngle - PENDULUM_MAX
				directions &= ~(1<<SENTRY_DIR_CANNON)
				entity_set_int(sentry, SENTRY_INT_PENDDIR, directions)
			}
		}
		else {
			angles[1] += (PENDULUM_INCREMENT * deltaTime) // PENDULUM_INCREMENT get_cvar_float("pend_inc")
			if (angles[1] > baseAngle + PENDULUM_MAX) {
				angles[1] = baseAngle + PENDULUM_MAX
				directions |= (1<<SENTRY_DIR_CANNON)
				entity_set_int(sentry, SENTRY_INT_PENDDIR, directions)
			}
		}

		entity_set_vector(sentry, EV_VEC_angles, angles);

		if (entity_get_int(sentry, SENTRY_INT_LEVEL) == SENTRY_LEVEL_3) {
			//new radarAngle = entity_get_byte(sentry, SENTRY_TILT_RADAR)
			//SENTRY_FL_RADARANGLE
			new Float:radarAngle = entity_get_float(sentry, SENTRY_FL_RADARANGLE)

			if (directions & (1<<SENTRY_DIR_RADAR)) {
				radarAngle = radarAngle - RADAR_INCREMENT // get_cvar_float("radar_increment")
				if (radarAngle < 0.0) {
					radarAngle = 0.0
					directions &= ~(1<<SENTRY_DIR_RADAR)
					entity_set_int(sentry, SENTRY_INT_PENDDIR, directions)
				}
			}
			else {
				radarAngle = radarAngle + RADAR_INCREMENT // get_cvar_float("radar_increment")
				if (radarAngle > 255.0) {
					radarAngle = 255.0
					directions |= (1<<SENTRY_DIR_RADAR)
					entity_set_int(sentry, SENTRY_INT_PENDDIR, directions)
				}
			}
			entity_set_float(sentry, SENTRY_FL_RADARANGLE, radarAngle)
			set_pev(sentry, PEV_SENTRY_TILT_RADAR, floatround(radarAngle)) //entity_set_byte(sentry, SENTRY_TILT_RADAR, floatround(radarAngle))
		}

		return
	}
	case SENTRY_FIREMODE_NUTS: {
		new Float:angles[3]
		entity_get_vector(sentry, EV_VEC_angles, angles)

		new Float:spinSpeed = entity_get_float(sentry, SENTRY_FL_SPINSPEED)
		if (entity_get_int(sentry, SENTRY_INT_PENDDIR) & (1<<SENTRY_DIR_CANNON)) {
			angles[1] -= (spinSpeed * deltaTime)
			if (angles[1] < 0.0) {
				angles[1] = 360.0 + angles[1]
			}
		}
		else {
			angles[1] += (spinSpeed * deltaTime)
			if (angles[1] > 360.0) {
				angles[1] = angles[1] - 360.0
			}
		}
		// Increment speed raise
		entity_set_float(sentry, SENTRY_FL_SPINSPEED, (spinSpeed += random_float(1.0, 2.0)))

		new Float:maxSpin = entity_get_float(sentry, SENTRY_FL_MAXSPIN)
		if (maxSpin == 0.0) {
			// Set rotation speed to explode at
			entity_set_float(sentry, SENTRY_FL_MAXSPIN, maxSpin = random_float(500.0, 750.0))
			//client_print(0, print_chat, "parm3 set to %d", parm[3])
		}
		else if (spinSpeed >= maxSpin) {
			//client_print(0, print_chat, "Detonating!")
			sentry_detonate(sentry, false, false)
			//remove_entity(parm[0])
			return
		}
		entity_set_vector(sentry, EV_VEC_angles, angles);

		return
	}
}
}

// Checks the contents of eight points corresponding to the bbox around ent origin. Also does a trace from origin to each point. If anything goes wrong, report a hit.
// TODO: high bounds should get higher, so that building in tight places not gets sentries stuck in roof... TraceCheckCollides
bool:TraceCheckCollides(Float:origin[3], const Float:BOUNDS) {
new Float:traceEnds[8][3], Float:traceHit[3], hitEnt

// x, z, y
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
//
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

for (new i = 0; i < 8; i++) {
	if (point_contents(traceEnds[i]) != CONTENTS_EMPTY)
		return true

	hitEnt = trace_line(0, origin, traceEnds[i], traceHit)
	if (hitEnt != 0)
		return true
	for (new j = 0; j < 3; j++) {
		if (traceEnds[i][j] != traceHit[j])
			return true
	}
}

return false
}


//#define	TE_TRACER			6		// tracer effect from point to point
// coord, coord, coord (start)
// coord, coord, coord (end)

tracer(Float:start[3], Float:end[3]) {
//new start_[3]
new start_[3], end_[3]
FVecIVec(start, start_)
FVecIVec(end, end_)
message_begin(MSG_BROADCAST, SVC_TEMPENTITY) //  MSG_PAS MSG_BROADCAST
write_byte(TE_TRACER)
write_coord(start_[0])
write_coord(start_[1])
write_coord(start_[2])
write_coord(end_[0])
write_coord(end_[1])
write_coord(end_[2])
message_end()
}

/*
#define TE_BREAKMODEL		108		// box of models or sprites
// coord, coord, coord (position)
// coord, coord, coord (size)
// coord, coord, coord (velocity)
// byte (random velocity in 10's)
// short (sprite or model index)
// byte (count)
// byte (life in 0.1 secs)
// byte (flags)
*/

stock create_explosion(Float:origin_[3]) {
new origin[3]
FVecIVec(origin_, origin)
//client_print(0, print_chat, "Creating explosion at %d %d %d", origin[0], origin[1], origin[2])

message_begin(MSG_BROADCAST, SVC_TEMPENTITY, origin) // MSG_PAS not really good here
write_byte(TE_EXPLOSION)
write_coord(origin[0])
write_coord(origin[1])
write_coord(origin[2])
write_short(g_sModelIndexFireball)
write_byte(random_num(0, 20) + 50) // scale * 10 // random_num(0, 20) + 20
write_byte(12) // framerate
write_byte(TE_EXPLFLAG_NONE)
message_end()

// Blast stuff away
genericShock(origin_, SENTRYEXPLODERADIUS, "weaponbox", 32, SENTRYSHOCKPOWER, OBJECT_GENERIC)
genericShock(origin_, SENTRYEXPLODERADIUS, "armoury_entity", 32, SENTRYSHOCKPOWER, OBJECT_ARMOURY)
genericShock(origin_, SENTRYEXPLODERADIUS, "player", 32, SENTRYSHOCKPOWER, OBJECT_PLAYER)
genericShock(origin_, SENTRYEXPLODERADIUS, "grenade", 32, SENTRYSHOCKPOWER, OBJECT_GRENADE)
genericShock(origin_, SENTRYEXPLODERADIUS, "hostage_entity", 32, SENTRYSHOCKPOWER, OBJECT_GENERIC)

// Hurt ppl in vicinity

new Float:playerOrigin[3], Float:distance, Float:flDmgToDo, Float:dmgbase = DMG_EXPLOSION_TAKE + 0.0, newHealth
for (new i = 1; i <= g_MAXPLAYERS; i++) {
	if (!is_user_alive(i) || get_user_godmode(i))
		continue

	entity_get_vector(i, EV_VEC_origin, playerOrigin)
	distance = vector_distance(playerOrigin, origin_)
	if (distance <= SENTRYEXPLODERADIUS) {
		flDmgToDo = dmgbase - (dmgbase * (distance / SENTRYEXPLODERADIUS))
		//client_print(i, print_chat, "flDmgToDo = %f, dmgbase = %f, distance = %f, SENTRYEXPLODERADIUS = %f", flDmgToDo, dmgbase, distance, SENTRYEXPLODERADIUS)
		newHealth = get_user_health(i) - floatround(flDmgToDo)
		if (newHealth <= 0) {
			// Somehow if player is killed here server crashes out saying some message (Damage or Death) has not been sent yet when trying to send another message.
			// By delaying death with 0.0 (huuh?) seconds this seems to be fixed.
			set_task(0.0, "TicketToHell", i)
			continue
		}

		set_user_health(i, newHealth)

		message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, {0,0,0}, i)
		write_byte(floatround(flDmgToDo))
		write_byte(floatround(flDmgToDo))
		write_long(DMG_BLAST)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2])
		message_end()
	}
}
}

// Hacks, damn you!
public TicketToHell(player) {
if (!is_user_connected(player))
	return
new frags = get_user_frags(player)
user_kill(player, 1) // don't decrease frags
new parms[4]
parms[0] = player
parms[1] = frags
parms[2] = cs_get_user_deaths(player)
parms[3] = int:cs_get_user_team(player)
set_task(0.0, "DelayedScoreInfoUpdate", 0, parms, 4)
}

public DelayedScoreInfoUpdate(parms[4]) {
scoreinfo_update(parms[0], parms[1], parms[2], parms[3])
}

stock genericShock(Float:hitPointOrigin[3], Float:radius, classString[], maxEntsToFind, Float:power, OBJECTTYPE:objecttype) { // bool:isthisplayer, bool:isthisarmouryentity, bool:isthisgrenade/*, Float:pullup*/) {
new entList[32]
if (maxEntsToFind > 32)
	maxEntsToFind = 32

new entsFound = find_sphere_class(0, classString, radius, entList, maxEntsToFind, hitPointOrigin)

new Float:entOrigin[3]
new Float:velocity[3]
new Float:cOrigin[3]

for (new j = 0; j < entsFound; j++) {
	switch (objecttype) {
		case OBJECT_PLAYER: {
			if (!is_user_alive(entList[j])) // Don't move dead players
				continue
		}
		case OBJECT_GRENADE: {
			new l_model[16]
			entity_get_string(entList[j], EV_SZ_model, l_model, 15)
			if (equal(l_model, "models/w_c4.mdl")) // don't move planted c4s :-P
				continue
		}
	}

	entity_get_vector(entList[j], EV_VEC_origin, entOrigin) // get_entity_origin(entList[j],entOrigin)

	new Float:distanceNadePl = vector_distance(entOrigin, hitPointOrigin)

	// Stuff on ground AND below explosion are "placed" a distance above explosion Y-wise ([2]), so that they fly off ground etc.
	if (entity_is_on_ground(entList[j]) && entOrigin[2] < hitPointOrigin[2])
		entOrigin[2] = hitPointOrigin[2] + distanceNadePl

	entity_get_vector(entList[j], EV_VEC_velocity, velocity)

	cOrigin[0] = (entOrigin[0] - hitPointOrigin[0]) * radius / distanceNadePl + hitPointOrigin[0]
	cOrigin[1] = (entOrigin[1] - hitPointOrigin[1]) * radius / distanceNadePl + hitPointOrigin[1]
	cOrigin[2] = (entOrigin[2] - hitPointOrigin[2]) * radius / distanceNadePl + hitPointOrigin[2]

	velocity[0] += (cOrigin[0] - entOrigin[0]) * power
	velocity[1] += (cOrigin[1] - entOrigin[1]) * power
	velocity[2] += (cOrigin[2] - entOrigin[2]) * power

	entity_set_vector(entList[j], EV_VEC_velocity, velocity)
}
}

stock entity_is_on_ground(entity) {
return entity_get_int(entity, EV_INT_flags) & FL_ONGROUND
}


public message_tempentity() {
if (get_msg_args() != 15 && get_msg_arg_int(1) != TE_BREAKMODEL)
	return PLUGIN_CONTINUE

// Something broke, maybe it was one of our sentries. Loop through all sentries to see if any of them has health <=0.
for (new i = 0; i < g_sentriesNum; i++) {
	if (entity_get_float(g_sentries[i], EV_FL_health) <= 0.0) {
		//server_cmd("amx_box %d", g_sentries[i])
		sentry_detonate(i, false, true)

		//origin[0] = get_msg_arg_float(2)
		//origin[1] = get_msg_arg_float(3)
		//origin[2] = get_msg_arg_float(4)

		// Rewind iteration loop; the last sentry may have been destroyed also
		i--
	}
}

return PLUGIN_CONTINUE
}

/*
public think_sentry(ent) {
// Hmm this place can be used to tell when a sentry breaks...

sentry_detonate(ent, false)
// All of these always give 0 values :-(
//client_print(0, print_chat, "%d thinks: inflictor: %d, EV_ENT_enemy: %d, EV_ENT_aiment: %d, EV_ENT_chain: %d, EV_ENT_owner: %d", ent, entity_get_edict(ent, EV_ENT_dmg_inflictor), entity_get_edict(ent, EV_ENT_enemy), entity_get_edict(ent, EV_ENT_aiment), entity_get_edict(ent, EV_ENT_chain), entity_get_edict(ent, EV_ENT_owner))

return PLUGIN_CONTINUE
}
*/
public think_sentrybase(sentrybase) {
// Hmm this place can be used to tell when a sentrybase breaks...

sentrybase_broke(sentrybase)
//sentry_detonate(ent, false)

// All of these always give 0 values :-(
//client_print(0, print_chat, "%d thinks: inflictor: %d, EV_ENT_enemy: %d, EV_ENT_aiment: %d, EV_ENT_chain: %d, EV_ENT_owner: %d", ent, entity_get_edict(ent, EV_ENT_dmg_inflictor), entity_get_edict(ent, EV_ENT_enemy), entity_get_edict(ent, EV_ENT_aiment), entity_get_edict(ent, EV_ENT_chain), entity_get_edict(ent, EV_ENT_owner))

return PLUGIN_CONTINUE
}

sentrybase_broke(sentrybase) {
new sentry = entity_get_edict(sentrybase, BASE_ENT_SENTRY)
if (is_valid_ent(sentrybase))
	remove_entity(sentrybase)

// Sentry could be 0 which should mean it has not been built yet. No need to do anything in that case.
if (sentry == 0)
	return

entity_set_int(sentry, SENTRY_INT_FIRE, SENTRY_FIREMODE_NUTS)
// Set cannon tower straight, calculate tower tilt offset to angles later... entityviewhitpoint fn needs changing for this to use a custom angle vector
set_pev(sentry, PEV_SENTRY_TILT_TURRET, 127) //entity_set_byte(sentry, SENTRY_TILT_TURRET, 127)
}

sentry_detonate(sentry, bool:quiet, bool:isIndex) {
// Explode!
new i
if (isIndex) {
	i = sentry
	sentry = g_sentries[sentry]
	if (!is_valid_ent(sentry))
		return
}
else {
	if (!is_valid_ent(sentry))
		return
	// Find index of this sentry
	for (new j = 0; j < g_sentriesNum; j++) {
		if (g_sentries[j] == sentry) {
			i = j
			break
		}
	}
}


// Kill tasks
remove_task(TASKID_THINK + sentry) // removes think
remove_task(TASKID_THINKPENDULUM + sentry) // removes think
remove_task(TASKID_SENTRYONRADAR + sentry) // in case someone's displaying this on radar

new owner = GetSentryPeople(sentry, OWNER)

// If sentry has a spycam, call the stuff to remove it now
if (entity_get_edict(sentry, SENTRY_ENT_SPYCAM) != 0) {
	remove_task(TASKID_SPYCAM + owner) // remove the ongoing task...
	// And call this now on our own...
	new parms[3]
	parms[0] = owner
	parms[1] = entity_get_edict(sentry, SENTRY_ENT_SPYCAM)
	parms[2] = sentry
	DestroySpyCam(parms)
}

if (!quiet) {
	#if defined EXPLODINGSENTRIES
	new Float:origin[3]
	entity_get_vector(sentry, EV_VEC_origin, origin)
	create_explosion(origin)
	#endif

	// Report to owner that it broke
	ChatColor(owner, "^1[^4CSDM^1] ^3Your Gun Is Destroyed.")
}
DecreaseSentryCount(owner, sentry)
//SetHasSentry(GetSentryPeople(sentry, OWNER), false)

// Remove base first
//server_cmd("amx_entinfo %d", ent)
if (entity_get_int(sentry, SENTRY_INT_FIRE) != SENTRY_FIREMODE_NUTS)
	set_task(0.0, "delayedremovalofentity", entity_get_edict(sentry, SENTRY_ENT_BASE))
//remove_entity(entity_get_edict(g_sentries[i], SENTRY_ENT_BASE))
// Remove this entity
//server_cmd("amx_entinfo %d", ent)
set_task(0.0, "delayedremovalofentity", sentry)
//remove_entity(g_sentries[i])
// Put the last sentry in the deleted entity's place
g_sentries[i] = g_sentries[g_sentriesNum - 1]
// Lower nr of sentries
g_sentriesNum--
}

public delayedremovalofentity(entity) {
if (!is_valid_ent(entity)) {
	//client_print(0, print_chat, "Was gonna remove %d, but it's not valid", entity)
	return
}
//client_print(0, print_chat, "removing %d", entity)
remove_entity(entity)
}

sentry_detonate_by_owner(owner, bool:quiet = false) {

/*
for (new i = g_MAXPLAYERS + 1, classname[7]; i < g_MAXENTITIES; i++) {
	if (!is_valid_ent(i))
		continue
	entity_get_string(i, EV_SZ_classname, classname, 6)
	if (!equal(classname, "sentry"))
		continue

	if (entity_get_edict(i, SENTRY_ENT_OWNER) == owner) {
		sentry_detonate(i, quiet)
		return
	}
}
*/

for(new i = 0; i < g_sentriesNum; i++) {
	if (GetSentryPeople(g_sentries[i], OWNER) == owner) {
		sentry_detonate(i, quiet, true)
		break
	}
}
}

public client_disconnect(id) {
while (GetSentryCount(id) > 0)
	sentry_detonate_by_owner(id)
}

public sentry_think(parm[1]) {
if (!is_valid_ent(parm[0])) {
	ChatColor(0,"^1[^4CSDM^1] ^4%d ^3Not A Valid Ent, Ending sentry_think", parm[0])
	return
}

new ent = parm[0]

new Float:sentryOrigin[3], Float:hitOrigin[3], hitent
entity_get_vector(ent, EV_VEC_origin, sentryOrigin)
sentryOrigin[2] += CANNONHEIGHTFROMFEET // Move up some, this should be the Y origin of the cannon

// If fire, do a trace and fire
new firemode = entity_get_int(ent, SENTRY_INT_FIRE)
new target = entity_get_edict(ent, SENTRY_ENT_TARGET)
if (firemode == SENTRY_FIREMODE_YES && is_valid_ent(target) && is_user_alive(target) && get_user_team(target) != entity_get_int(ent, SENTRY_INT_TEAM)) { // temp removed team check:  && get_user_team(target) != entity_get_int(ent, SENTRY_INT_TEAM)
	new sentryLevel = entity_get_int(ent, SENTRY_INT_LEVEL)

	// Is target still visible?
	new Float:targetOrigin[3]
	entity_get_vector(target, EV_VEC_origin, targetOrigin)

	// Adjust for ducking. This is still not 100%. :-(
	if (entity_get_int(target, EV_INT_flags) & FL_DUCKING) {
		//client_print(0, print_chat, "%d: Target %d is ducking, moving its origin up by %f", ent, target, TARGETUPMODIFIER)
		targetOrigin[2] += TARGETUPMODIFIER
	}

	hitent = trace_line(ent, sentryOrigin, targetOrigin, hitOrigin)
	if (hitent == entity_get_edict(ent, SENTRY_ENT_BASE)) {
		// We traced into our base, do another trace from there
		hitent = trace_line(hitent, hitOrigin, targetOrigin, hitOrigin)
		//client_print(0, print_chat, "%d: I first hit my own base, and after doing another trace I hit %d, target: %d", ent, hitent, target)
	}
	
		if (hitent != target && is_user_alive(hitent) && entity_get_int(ent, SENTRY_INT_TEAM) != get_user_team(hitent)) {
		// Another new enemy target got into scope, pick this new enemy as a new target...
		target = hitent
		entity_set_edict(ent, SENTRY_ENT_TARGET, hitent)
		entity_set_int(ent, SENTRY_INT_FIRE, SENTRY_FIREMODE_ROCKETS)
		
	}
	
	if (hitent != target && is_user_alive(hitent) && entity_get_int(ent, SENTRY_INT_TEAM) != get_user_team(hitent)) {
		// Another new enemy target got into scope, pick this new enemy as a new target...
		target = hitent
		entity_set_edict(ent, SENTRY_ENT_TARGET, hitent)
	}
	
	if (hitent == target) {
		// Fire here
		//client_print(0, print_chat, "%d: I see %d, will fire. Dist: %f, Hitorigin: %f %f %f", ent, hitent, dist, hitOrigin[0], hitOrigin[1], hitOrigin[2])
		sentry_turntotarget(ent, sentryOrigin, target, targetOrigin)
		// Firing sound
		emit_sound(ent, CHAN_WEAPON, "weapons/m249-1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

		new Float:hitRatio = random_float(0.0, 1.0) - g_HITRATIOS[sentryLevel] // ie 0.5 - 0.7 = -0.2, a hit and 0.8 - 0.7 = a miss by 0.1

		if (!get_user_godmode(target) && hitRatio <= 0.0) {
			// Do damage to player
			sentry_damagetoplayer(ent, sentryLevel, sentryOrigin, target)
			// Tracer effect to target
		}
		else {
			// Tracer hitOrigin adjusted for miss...
			/*
			MAKE_VECTORS(pEnt->v.v_angle);
			vVector = gpGlobals->v_forward * iVelocity;

			vRet[0] = amx_ftoc(vVector.x);
			vRet[1] = amx_ftoc(vVector.y);
			vRet[2] = amx_ftoc(vVector.z);
			*/
			new Float:sentryAngle[3] = {0.0, 0.0, 0.0}

			new Float:x = hitOrigin[0] - sentryOrigin[0]
			new Float:z = hitOrigin[1] - sentryOrigin[1]
			new Float:radians = floatatan(z/x, radian)
			sentryAngle[1] = radians * g_ONEEIGHTYTHROUGHPI
			if (hitOrigin[0] < sentryOrigin[0])
				sentryAngle[1] -= 180.0

			new Float:h = hitOrigin[2] - sentryOrigin[2]
			new Float:b = vector_distance(sentryOrigin, hitOrigin)
			radians = floatatan(h/b, radian)
			sentryAngle[0] = radians * g_ONEEIGHTYTHROUGHPI;

			sentryAngle[0] += random_float(-10.0 * hitRatio, 10.0 * hitRatio) // aim is a little off here :-)
			sentryAngle[1] += random_float(-10.0 * hitRatio, 10.0 * hitRatio) // aim is a little off here :-)
			engfunc(EngFunc_MakeVectors, sentryAngle)
			new Float:vector[3]
			get_global_vector(GL_v_forward, vector)
			for (new i = 0; i < 3; i++)
				vector[i] *= 1000;

			new Float:traceEnd[3]
			for (new i = 0; i < 3; i++)
				traceEnd[i] = vector[i] + sentryOrigin[i]

			new hitEnt = ent
			while((hitEnt = trace_line(hitEnt, hitOrigin, traceEnd, hitOrigin))) {
				// continue tracing until hit nothing...
			}

			//for (new i = 0; i < 3; i++)
				//hitOrigin[i] += random_float(-5.0, 5.0)
		}
		tracer(sentryOrigin, hitOrigin)
		
		if(sentryLevel==SENTRY_LEVEL_3 && (firemode==SENTRY_FIREMODE_ROCKETS||firemode==9))
		{
			new Float:flDistance = get_distance_f (sentryOrigin, hitOrigin)   
		
			if(flDistance>150.0)
				create_rocket(ent, sentryOrigin, hitOrigin)
		}
		firemode--
		if(firemode<SENTRY_FIREMODE_YES)firemode=SENTRY_FIREMODE_ROCKETS
		entity_set_int(ent, SENTRY_INT_FIRE, firemode)

		// Don't do any more here
		//set_task(THINKFIREFREQUENCY, "sentry_think", ent)
		set_task(THINKFIREFREQUENCY, "sentry_think", TASKID_THINK + parm[0], parm, 1)
		return
	}
	else {
		//client_print(target, print_chat, "%d: Lost track of you! Hit: %d", ent, target, hitent)
		//client_print(0, print_chat, "%d: I can't see %d, i see %d... will not fire. Dist: %f, Hitorigin: %f %f %f", ent, entity_get_edict(ent, SENTRY_ENT_TARGET), hitent, dist, hitOrigin[0], hitOrigin[1], hitOrigin[2])
		// Else target isn't still visible, unset fire state.
		entity_set_int(ent, SENTRY_INT_FIRE, SENTRY_FIREMODE_NO)
		// vvvv - Not really necessary but it's cleaner. Leave it out for now and be sure to set a fresh target each time SENTRY_INT_FIRE is set to 1!!!
		// vvvv - Else this is breaking this think altogether! :-(
		//entity_set_edict(ent, SENTRY_ENT_TARGET, 0)

		// Don't return here, continue with searching for targets below...
	}
}
else if (firemode == SENTRY_FIREMODE_NUTS) {
	//client_print(0, print_chat, "Gone nuts firing... spin speed: %f", entity_get_float(ent, SENTRY_FL_SPINSPEED))
	new hitEnt = entityviewhitpoint(ent, sentryOrigin, hitOrigin)
	// Firing sound
	emit_sound(ent, CHAN_WEAPON, "weapons/m249-1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	// Tracer effect
	tracer(sentryOrigin, hitOrigin)

	if (is_user_connected(hitEnt) && is_user_alive(hitEnt) && !get_user_godmode(hitEnt)) {
		// Do damage to player
		sentry_damagetoplayer(ent, entity_get_int(ent, SENTRY_INT_LEVEL), sentryOrigin, hitEnt)
	}

	// Don't do any more here
	set_task(THINKFIREFREQUENCY, "sentry_think", TASKID_THINK + parm[0], parm, 1)
	return
}
else {
	//client_print(0, print_chat, "My firemode: %d", firemode)
	// Either wasn't meant to fire or target was not a valid entity or dead, set both to 0.
	//client_print(target, print_chat, "%d: Fire: %d Target: %d (%s)", ent, entity_get_int(ent, SENTRY_INT_FIRE), target, is_valid_ent(target) ? (is_user_alive(target) ? "alive" : "dead") : "invalid")

	//entity_set_int(ent, SENTRY_INT_FIRE, 0)
	//entity_set_edict(ent, SENTRY_ENT_TARGET, 0)
}

// Tell what players you see
if (random_num(0, 99) < 10)
	emit_sound(ent, CHAN_AUTO, "sentries/turridle.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

new closestTarget = 0, Float:closestDistance, Float:distance, Float:closestOrigin[3], Float:playerOrigin[3], sentryTeam = entity_get_int(ent, SENTRY_INT_TEAM)
for (new i = 1; i <= g_MAXPLAYERS; i++) {
	if (!is_user_connected(i) || !is_user_alive(i) || get_user_team(i) == sentryTeam) // temporarily dont check team:  || get_user_team(i) == sentryTeam
		continue

	entity_get_vector(i, EV_VEC_origin, playerOrigin)

	// Adjust for ducking. This is still not 100%. :-(
	if (entity_get_int(i, EV_INT_flags) & FL_DUCKING) {
		//client_print(0, print_chat, "%d: Target %d is ducking, moving its origin up by %f", ent, target, TARGETUPMODIFIER)
		playerOrigin[2] += TARGETUPMODIFIER
	}

	//playerOrigin[2] += TARGETUPMODIFIER

	hitent = trace_line(ent, sentryOrigin, playerOrigin, hitOrigin)
	if (hitent == entity_get_edict(ent, SENTRY_ENT_BASE)) {
		// We traced into our base, do another trace from there
		hitent = trace_line(hitent, hitOrigin, playerOrigin, hitOrigin)
		//client_print(0, print_chat, "%d (scanning): I first hit my own base, and after doing another trace I hit %d, target: %d", ent, hitent, i)
	}
	//client_print(0, print_chat, "%d: t: %f %f %f - %f %f %f - %f %f %f, i: %d hitent: %d", ent, sentryOrigin[0], sentryOrigin[1], sentryOrigin[2], playerOrigin[0], playerOrigin[1], playerOrigin[2], hitOrigin[0], hitOrigin[1], hitOrigin[2], i, hitent)
	if (hitent == i) {
		//len += format(seethese[len], 63 - len, "%d,", hitent)

		distance = vector_distance(sentryOrigin, playerOrigin)
		closestOrigin = playerOrigin

		if (distance < closestDistance || closestTarget == 0) {
			closestTarget = i
			closestDistance = distance
		}
	}
}

if (closestTarget) {
	// We found a target, play sound and turn to target
	emit_sound(ent, CHAN_AUTO, "sentries/turrspot.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	sentry_turntotarget(ent, sentryOrigin, closestTarget, closestOrigin)

	// Set to fire mode and set target (always set also a new target when setting fire mode 1!!!)
	entity_set_int(ent, SENTRY_INT_FIRE, SENTRY_FIREMODE_YES)
	entity_set_edict(ent, SENTRY_ENT_TARGET, closestTarget)
	// Set radar straight...
	entity_set_float(ent, SENTRY_FL_RADARANGLE, 127.0)
	set_pev(ent, PEV_SENTRY_TILT_RADAR, 127)
}
else
	entity_set_int(ent, SENTRY_INT_FIRE, SENTRY_FIREMODE_NO)

//set_task(g_THINKFREQUENCIES[entity_get_int(ent, SENTRY_INT_LEVEL)], "sentry_think", ent)
//client_print(0, print_chat, "%d: my inflictor: %d, EV_ENT_enemy: %d, EV_ENT_aiment: %d, EV_ENT_chain: %d, EV_ENT_owner: %d", ent, entity_get_edict(ent, EV_ENT_dmg_inflictor), entity_get_edict(ent, EV_ENT_enemy), entity_get_edict(ent, EV_ENT_aiment), entity_get_edict(ent, EV_ENT_chain), entity_get_edict(ent, EV_ENT_owner))
set_task(g_THINKFREQUENCIES[entity_get_int(ent, SENTRY_INT_LEVEL)], "sentry_think", TASKID_THINK + parm[0], parm, 1)
}

stock sentry_damagetoplayer(sentry, sentryLevel, Float:sentryOrigin[3], target) {
new newHealth = get_user_health(target) - g_DMG[sentryLevel]

if (newHealth <= 0) {
	new targetFrags = get_user_frags(target) + 1
	new owner = GetSentryPeople(sentry, OWNER)
	new ownerFrags = get_user_frags(owner) + 1
	set_user_frags(target, targetFrags) // otherwise frags are subtracted from victim for dying (!!)
	set_user_frags(owner, ownerFrags)
	// Give money to player here
	new contributors[3], moneyRewards[33] = {0, ...}
	contributors[0] = owner
	contributors[1] = GetSentryPeople(sentry, UPGRADER_1)
	contributors[2] = GetSentryPeople(sentry, UPGRADER_2)
	for (new i = SENTRY_LEVEL_1; i <= sentryLevel; i++) {
		moneyRewards[contributors[i]] += g_SENTRYFRAGREWARDS[i]
	}
	for (new i = 1; i <= g_MAXPLAYERS; i++) {
		if (moneyRewards[i] && is_user_connected(i))
			cs_set_user_money(i, cs_get_user_money(i) + moneyRewards[i])
	}

	message_begin(MSG_ALL, g_msgDeathMsg, {0, 0, 0} ,0)
	write_byte(owner)
	write_byte(target)
	write_byte(0)
	write_string("sentry gun")
	message_end()

	scoreinfo_update(owner, ownerFrags, cs_get_user_deaths(owner), int:cs_get_user_team(owner))
	//scoreinfo_update(target, targetFrags, targetDeaths, targetTeam) // dont need to update frags of victim, because it's done after set_user_health

	set_msg_block(g_msgDeathMsg, BLOCK_ONCE)
}

set_user_health(target, newHealth)

message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, {0,0,0}, target) //
write_byte(g_DMG[sentryLevel]) // write_byte(DMG_SAVE)
write_byte(g_DMG[sentryLevel])
write_long(DMG_BULLET)
write_coord(floatround(sentryOrigin[0]))
write_coord(floatround(sentryOrigin[1]))
write_coord(floatround(sentryOrigin[2]))
message_end()
}

scoreinfo_update(id, frags, deaths, team) {
// Send msg to update ppls scoreboards.
/*
MESSAGE_BEGIN( MSG_ALL, gmsgScoreInfo );
	WRITE_BYTE( params[1] );
	WRITE_SHORT( pPlayer->v.frags );
	WRITE_SHORT( params[2] );
	WRITE_SHORT( 0 );
	WRITE_SHORT( g_pGameRules->GetTeamIndex( m_szTeamName ) + 1 );
MESSAGE_END();

*/
message_begin(MSG_ALL, g_msgScoreInfo)
write_byte(id)
write_short(frags)
write_short(deaths)
write_short(0)
write_short(team)
message_end()
}

sentry_turntotarget(ent, Float:sentryOrigin[3], target, Float:closestOrigin[3]) {
if (target) {
	new name[32]
	get_user_name(target, name, 31)

// Alter ent's angle
	new Float:newAngle[3]
	entity_get_vector(ent, EV_VEC_angles, newAngle)
	new Float:x = closestOrigin[0] - sentryOrigin[0]
	new Float:z = closestOrigin[1] - sentryOrigin[1]
	//new Float:y = closestOrigin[2] - sentryOrigin[2]
	/*
	//newAngle[0] = floatasin(x/floatsqroot(x*x+y*y), degrees)
	newAngle[1] = floatasin(z/floatsqroot(x*x+z*z), degrees)
	*/

	new Float:radians = floatatan(z/x, radian)
	newAngle[1] = radians * g_ONEEIGHTYTHROUGHPI
	if (closestOrigin[0] < sentryOrigin[0])

		newAngle[1] -= 180.0

	entity_set_float(ent, SENTRY_FL_ANGLE, newAngle[1])
	// Tilt is handled thorugh the EV_BYTE_controller1 member. 0-255 are the values, 127ish should be horisontal aim, 255 is furthest down (about 50 degrees off)
	// and 0 is also about 50 degrees up. Scope = ~100 degrees

	// Set tilt
	new Float:h = closestOrigin[2] - sentryOrigin[2]
	new Float:b = vector_distance(sentryOrigin, closestOrigin)
	radians = floatatan(h/b, radian)
	new Float:degs = radians * g_ONEEIGHTYTHROUGHPI;
	// Now adjust EV_BYTE_controller1
	// Each degree corresponds to about 100/256 "bytes", = ~0,39 byte / degree (ok this is not entirely true, just tweaked for now with SENTRYTILTRADIUS)
	new Float:RADIUS = SENTRYTILTRADIUS // get_cvar_float("sentry_tiltradius");
	new Float:degreeByte = RADIUS/256.0; // tweak radius later
	new Float:tilt = 127.0 - degreeByte * degs; // 127 is center of 256... well, almost
	//client_print(GetSentryPeople(ent, OWNER), print_chat, "%d: Setting tilt to %d", ent, floatround(tilt))
	set_pev(ent, PEV_SENTRY_TILT_TURRET, floatround(tilt)) //entity_set_byte(ent, SENTRY_TILT_TURRET, floatround(tilt))
	entity_set_vector(ent, EV_VEC_angles, newAngle)
}
else {
	//entity_set_int(ent, SENTRY_INT_FIRE, 0)
	//entity_set_edict(ent, SENTRY_ENT_TARGET, 0)
	//client_print(0, print_chat, "%d: I don't see anyone.", ent)
}
}

public menumain(id) {
if (!is_user_alive(id))
	return PLUGIN_HANDLED

menumain_starter(id)

return PLUGIN_HANDLED
}

AimingAtSentry(id, bool:alwaysReturn = false) {
//new Float:hitOrigin[3]
//new hitEnt = userviewhitpoint(id, hitOrigin)
new hitEnt, bodyPart
//
if (get_user_aiming(id, hitEnt, bodyPart) == 0.0)
	return 0

//if (get_user_aiming_func(id, hitEnt, bodyPart) == 0.0)
	//return 0

new sentry = 0
while (hitEnt) {
	new classname[32], l_sentry
	entity_get_string(hitEnt, EV_SZ_classname, classname, 31)
	if (equal(classname, "sentry_base"))
		l_sentry = entity_get_edict(hitEnt, BASE_ENT_SENTRY)
	else if (equal(classname, "sentry"))
		l_sentry = hitEnt
	else
		break

	if (alwaysReturn)
		return l_sentry

	new sentryLevel = entity_get_int(l_sentry, SENTRY_INT_LEVEL)
	new owner = GetSentryPeople(l_sentry, OWNER)
	if (cs_get_user_team(owner) == cs_get_user_team(id) && sentryLevel < 2) {
#if defined DISALLOW_OWN_UPGRADES
		// Don't allow builder to upgrade his own sentry first time.
		if (sentryLevel == SENTRY_LEVEL_1 && id == owner)
			break
#endif
#if defined DISALLOW_TWO_UPGRADES
		// Don't allow upgrader to upgrade again.
		if (sentryLevel == SENTRY_LEVEL_2 && id == GetSentryPeople(l_sentry, UPGRADER_1))
			break
#endif
		sentry = l_sentry
	}
	break
}

return sentry
}

menumain_starter(id) {
if (g_inSpyCam[id - 1])
	return

g_aimSentry[id - 1] = 0
new menuBuffer[256], len = 0, flags = MENUBUTTON0
len += format(menuBuffer[len], 255 - len, "\ySentry gun menu^n^n")

len += format(menuBuffer[len], 255 - len, "%s1. Build sentry, $%d^n", GetSentryCount(id) < MAXPLAYERSENTRIES && cs_get_user_money(id) >= g_COST(0) ? "\w" : "\d", g_COST(0))

//if (GetSentryCount(id) == 1)
	//g_selectedSentry[id - 1] = g_playerSentriesEdicts[id - 1][0]
//g_selectedSentry[id - 1] = GetClosestSentry(id)
if (GetSentryCount(id) > 0 && g_selectedSentry[id - 1] == -1)
	g_selectedSentry[id - 1] = g_playerSentriesEdicts[id - 1][0]
// g_playerSentriesEdicts[id - 1]

if (g_selectedSentry[id - 1]) {
	new parm[2]
	parm[0] = id
	parm[1] = g_selectedSentry[id - 1]
	set_task(0.0, "SentryRadarBlink", TASKID_SENTRYONRADAR + g_selectedSentry[id - 1], parm, 2)
}

//len += format(menuBuffer[len], 255 - len, "%s2. Detonate %ssentry^n", GetSentryCount(id) > 0 ? "\w" : "\d", GetSentryCount(id) > 1 ? "closest " : "")
len += format(menuBuffer[len], 255 - len, "%s2. Detonate sentry flashing on radar^n", GetSentryCount(id) > 0 ? "\w" : "\d")

while (len) {
	new sentry = AimingAtSentry(id)
	if (!sentry)
		break
	new sentryLevel = entity_get_int(sentry, SENTRY_INT_LEVEL)

	if (entity_range(sentry, id) <= MAXUPGRADERANGE) {
		if (cs_get_user_money(id) >= g_COST(sentryLevel + 1)) {
			len += format(menuBuffer[len], 255 - len, "\w3. Upgrade this sentry, $%d^n", g_COST(sentryLevel + 1))
			flags |= MENUBUTTON3
			g_aimSentry[id - 1] = sentry
		}
		else
			len += format(menuBuffer[len], 255 - len, "\d3. Upgrade this sentry (needs $%d)^n", g_COST(sentryLevel + 1))
	}
	else
		len += format(menuBuffer[len], 255 - len, "\d3. Upgrade this sentry, $%d (out of range)^n", g_COST(sentryLevel + 1))
	//}

	break
}
if (GetSentryCount(id) > 1) {
	len += format(menuBuffer[len], 255 - len, "\w4. Detonate all sentries^n")
	len += format(menuBuffer[len], 255 - len, "^n\w5. Select previous sentry^n")
	len += format(menuBuffer[len], 255 - len, "\w6. Select next sentry^n")
	flags |= MENUBUTTON4 | MENUBUTTON5 | MENUBUTTON6
}

len += format(menuBuffer[len], 255 - len, "%s7. View from sentry flashing on radar^n", g_selectedSentry[id - 1] != -1 ? "\w" : "\d")
if (g_selectedSentry[id - 1] != -1)
	flags |= MENUBUTTON7

//len += format(menuBuffer[len], 255 - len, "%s4. View from sentry^n", HasSentry(id) ? "\w" : "\d")

len += format(menuBuffer[len], 255 - len, "^n\w0. Exit")

if (GetSentryCount(id) > 0) {
	flags |= MENUBUTTON2
}
if (GetSentryCount(id) < MAXPLAYERSENTRIES && cs_get_user_money(id) >= g_COST(SENTRY_LEVEL_1))
	flags |= MENUBUTTON1

show_menu(id, flags, menuBuffer)
}

public SentryRadarBlink(parm[2]) {
// 0 = player
// 1 = sentry
if (!is_user_connected(parm[0]) || !is_valid_ent(parm[1]))
	return

new Float:sentryOrigin[3]
entity_get_vector(parm[1], EV_VEC_origin, sentryOrigin)
//client_print(parm[0], print_chat, "Plotting closest sentry %d on radar: %f %f %f", parm[1], sentryOrigin[0], sentryOrigin[1], sentryOrigin[2])
message_begin(MSG_ONE, g_msgHostagePos, {0,0,0}, parm[0])
write_byte(parm[0])
write_byte(SENTRY_RADAR)
write_coord(floatround(sentryOrigin[0]))
write_coord(floatround(sentryOrigin[1]))
write_coord(floatround(sentryOrigin[2]))
message_end()

message_begin(MSG_ONE, g_msgHostageK, {0,0,0}, parm[0])
write_byte(SENTRY_RADAR)
message_end()

new usermenuid, keys
get_user_menu(parm[0], usermenuid, keys)
if (g_menuId == usermenuid)
	set_task(1.5, "SentryRadarBlink", TASKID_SENTRYONRADAR + parm[1], parm, 2)
}

stock GetClosestSentry(id) {
// Find closest sentry
new sentry = 0, closestSentry = 0, Float:closestDistance, Float:distance
while ((sentry = find_ent_by_class(sentry, "sentry"))) {
	if (GetSentryPeople(sentry, OWNER) != id)
		continue

	distance = entity_range(id, sentry)
	if (distance < closestDistance || closestSentry == 0) {
		closestSentry = sentry
		closestDistance = distance
	}
}

return closestSentry
}

public menumain_handle(id, key) {
new bool:stayInMenu = false
switch (key) {
	case MENUSELECT1: {
		// Build if still not has
		if (GetSentryCount(id) < MAXPLAYERSENTRIES) {
			sentry_build(id)
		}
		else {
			new numwords[128]
			getnumbers(MAXPLAYERSENTRIES, numwords, MAXPLAYERSENTRIES)
			ChatColor(id,"^1[^4CSDM^1]^3You Have Built ^4%s ^3Sentries Which Is ^4Maximum^3.", numwords)
		}
	}
	case MENUSELECT2: {
		// Detonate if still has
		new sentryCount = GetSentryCount(id)

		if (sentryCount == 1)
			sentry_detonate_by_owner(id)
		else if (sentryCount > 1) {
			sentry_detonate(g_selectedSentry[id - 1], false, false)
		}
	}
	case MENUSELECT3: {
		// Upgrade sentry
		new sentry = g_aimSentry[id - 1]
		if (is_valid_ent(sentry) && entity_range(sentry, id) <= MAXUPGRADERANGE) {
			sentry_upgrade(id, sentry)
		}
	}
	case MENUSELECT4: {
		while(GetSentryCount(id) > 0)
			sentry_detonate_by_owner(id, true)
	}
	case MENUSELECT5: {
		// one back
		CycleSelectedSentry(id, -1)
		stayInMenu = true
	}
	case MENUSELECT6: {
		// one forward
		CycleSelectedSentry(id, 1)
		stayInMenu = true
	}
	case MENUSELECT7: {
		if (g_selectedSentry[id - 1] != -1) {
			new spycam = CreateSpyCam(id, g_selectedSentry[id - 1])
			if (!spycam)
				return PLUGIN_HANDLED

			new parms[3]
			parms[0] = id
			parms[1] = spycam
			parms[2] = g_selectedSentry[id - 1]
			set_task(SPYCAMTIME, "DestroySpyCam", TASKID_SPYCAM + id, parms, 3)
		}
	}
	case MENUSELECT0: {
		// nothing
		//stayInMenu = false
	}
}

if (stayInMenu)
	menumain_starter(id)

return PLUGIN_HANDLED
}

CreateSpyCam(id, sentry) {
new spycam = create_entity("info_target")
if (!spycam)
	return 0

// Set connection from sentry to this spycam
entity_set_edict(sentry, SENTRY_ENT_SPYCAM, spycam)

// Set classname
entity_set_string(spycam, EV_SZ_classname, "spycam")

// Set origin, pull up some
new Float:origin[3]
entity_get_vector(sentry, EV_VEC_origin, origin)
origin[2] += g_spyCamOffset[entity_get_int(sentry, SENTRY_INT_LEVEL)]
entity_set_vector(spycam, EV_VEC_origin, origin)

// Set model, has to have one... but make it invisible with the stuff below
entity_set_model(spycam, (get_user_team(id) == 1) ? MODEL_SENTRYGUN_BASE_TR : MODEL_SENTRYGUN_BASE_CT)
entity_set_int(spycam, EV_INT_rendermode, kRenderTransColor)
entity_set_float(spycam, EV_FL_renderamt, 0.0)
entity_set_int(spycam, EV_INT_renderfx, kRenderFxNone)

// Set initial angle, this is also done in server_frame
new Float:angles[3]
entity_get_vector(sentry, EV_VEC_angles, angles)
entity_set_vector(spycam, EV_VEC_angles, angles)

// Set view of player
engfunc(EngFunc_SetView, id, spycam)
g_inSpyCam[id - 1] = true

return spycam
}

public DestroySpyCam(parms[3]) {
new id = parms[0]
new spycam = parms[1]
new sentry = parms[2]
g_inSpyCam[id - 1] = false

// If user is still around, set his view back
if (is_user_connected(id))
	engfunc(EngFunc_SetView, id, id)

// Remove connection from sentry (this sentry could've been removed because of a newround, or it was destroyed...)
if (is_valid_ent(sentry) && entity_get_edict(sentry, SENTRY_ENT_SPYCAM) == spycam)
	entity_set_edict(sentry, SENTRY_ENT_SPYCAM, 0)

remove_entity(spycam)
}

CycleSelectedSentry(id, steps) {
// Find current index
new index = -1
for (new i = 0; i < g_playerSentries[id - 1]; i++) {
	if (g_playerSentriesEdicts[id - 1][i] == g_selectedSentry[id - 1]) {
		index = i
		break
	}
}
if (index == -1)
	return // error :-P

remove_task(TASKID_SENTRYONRADAR + g_selectedSentry[id - 1])

if (steps > 0) {
	do {
		index++
		steps--
		if (index == g_playerSentries[id - 1])
			index = 0
	}
	while(steps > 0)
}
else if (steps < 0) {
	do {
		index--
		steps++
		if (index == -1)
			index = g_playerSentries[id - 1] - 1
	}
	while(steps < 0)
}

g_selectedSentry[id - 1] = g_playerSentriesEdicts[id - 1][index]
}

sentry_upgrade(id, sentry) {
new sentryLevel = entity_get_int(sentry, SENTRY_INT_LEVEL)
new iTeam = get_user_team(id);
if (entity_get_int(sentry, SENTRY_INT_FIRE) == SENTRY_FIREMODE_NUTS) {
	ChatColor(id,"^1[^4CSDM^1]^3This ^4Sentry ^3Can No Longer Be Upgraded.")
	return
}
else if (iTeam != entity_get_int(sentry, SENTRY_INT_TEAM)) {
	ChatColor(id,"^1[^4CSDM^1]^3You Can Only Upgrade Your ^4Team's Sentries^3.")
	return
}
#if defined DISALLOW_OWN_UPGRADES
else if (sentryLevel == SENTRY_LEVEL_1 && GetSentryPeople(sentry, OWNER) == id) {
	// Don't print anything here, it could get spammy
	//ChatColor(id,"^1[^4CSDM^1]^3")
	return
}
#endif
#if defined DISALLOW_TWO_UPGRADES
else if (sentryLevel == SENTRY_LEVEL_2 && GetSentryPeople(sentry, UPGRADER_1) == id) {
	// Don't print anything here, it could get spammy
	//ChatColor(id,"^1[^4CSDM^1]^3")
	return
}
#endif
sentryLevel++
new bool:newLevelIsOK = true, upgraderField
switch (sentryLevel) {
	case SENTRY_LEVEL_2: {
		entity_set_model(sentry, (iTeam == 1) ? MODEL_SENTRYGUN_LEVEL2_TR : MODEL_SENTRYGUN_LEVEL2_CT)
		upgraderField = UPGRADER_1
	}
	case SENTRY_LEVEL_3: {
		entity_set_model(sentry, (iTeam == 1) ? MODEL_SENTRYGUN_LEVEL3_TR : MODEL_SENTRYGUN_LEVEL3_CT)
		upgraderField = UPGRADER_2
	}
	default: {
		// Error... can only upgrade to level 2 and 3... so far! ;-)
		newLevelIsOK = false
	}
}

if (newLevelIsOK) {
	if (cs_get_user_money(id) - g_COST(sentryLevel) < 0) {
		ChatColor(id,"^1[^4CSDM^1]^3Not Enough Money To Upgrade Sentry. (^4Need %d $^3)", g_COST(sentryLevel))
		return
	}

	cs_set_user_money(id, cs_get_user_money(id) - g_COST(sentryLevel))

	new Float:mins[3], Float:maxs[3]
	mins[0] = -16.0
	mins[1] = -16.0
	mins[2] = 0.0
	maxs[0] = 16.0
	maxs[1] = 16.0
	maxs[2] = 48.0 // 4.0
	entity_set_size(sentry, mins, maxs)
	emit_sound(sentry, CHAN_AUTO, "sentries/turrset.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	entity_set_int(sentry, SENTRY_INT_LEVEL, sentryLevel)
	entity_set_float(sentry, EV_FL_health, g_HEALTHS[sentryLevel])
	entity_set_float(entity_get_edict(sentry, SENTRY_ENT_BASE), EV_FL_health, g_HEALTHS[0])
	SetSentryPeople(sentry, upgraderField, id)

	if (id != GetSentryPeople(sentry, OWNER)) {
		new upgraderName[32]
		get_user_name(id, upgraderName, 31)
		ChatColor(GetSentryPeople(sentry, OWNER), "^1[^4CSDM^1] ^4%s ^3Upgraded Your Sentry To ^4%d ^3Level.", upgraderName, sentryLevel + 1)
	}
}
}

stock userviewhitpoint(index, Float:hitorigin[3]) {
if (!is_user_connected(index)) {
	// Error
	log_amx("ERROR in plugin - %d is not a valid player index", index)
	return 0
}
new Float:origin[3], Float:pos[3], Float:v_angle[3], Float:vec[3], Float:f_dest[3]

entity_get_vector(index, EV_VEC_origin, origin)
entity_get_vector(index, EV_VEC_view_ofs, pos)

pos[0] += origin[0]
pos[1] += origin[1]
pos[2] += origin[2]

entity_get_vector(index, EV_VEC_v_angle, v_angle)

engfunc(EngFunc_AngleVectors, v_angle, vec, 0, 0)

f_dest[0] = pos[0] + vec[0] * 9999
f_dest[1] = pos[1] + vec[1] * 9999
f_dest[2] = pos[2] + vec[2] * 9999

return trace_line(index, pos, f_dest, hitorigin)
}
stock entityviewhitpoint(index, Float:origin[3], Float:hitorigin[3]) {
if (!is_valid_ent(index)) {
	// Error
	log_amx("ERROR in plugin - %d is not a valid entity index", index)
	return 0
}
new Float:angle[3], Float:vec[3], Float:f_dest[3]

//entity_get_vector(index, EV_VEC_origin, origin)
/*
entity_get_vector(index, EV_VEC_view_ofs, pos)

pos[0] += origin[0]
pos[1] += origin[1]
pos[2] += origin[2]
*/

entity_get_vector(index, EV_VEC_angles, angle)

engfunc(EngFunc_AngleVectors, angle, vec, 0, 0)

f_dest[0] = origin[0] + vec[0] * 9999
f_dest[1] = origin[1] + vec[1] * 9999
f_dest[2] = origin[2] + vec[2] * 9999

return trace_line(index, origin, f_dest, hitorigin)
}

public newround_event(id) {
//Shaman: Disallow building and enable it after some time
g_allowBuild= false
set_task(get_pcvar_float(sentry_wait), "enablesentrybur")

//g_inBuilding[id - 1] = false

#if !defined SENTRIES_SURVIVE_ROUNDS
while(GetSentryCount(id) > 0)
	sentry_detonate_by_owner(id, true)
#endif

if (!g_resetArmouryThisRound && g_hasArmouries) {
	ResetArmoury()
	g_resetArmouryThisRound = true
}

return PLUGIN_CONTINUE
}

public endround_event() {
if (!g_hasArmouries)
	return PLUGIN_CONTINUE

set_task(4.0, "ResetArmouryFalse")

return PLUGIN_CONTINUE
}

public ResetArmouryFalse() {
//client_print(0, print_chat, "Setting g_resetArmouryThisRound to false!")
g_resetArmouryThisRound = false
}

public client_putinserver(id) {
if (is_user_bot(id)) {
	new parm[1]
	parm[0] = id
	botbuildsrandomly(parm)

}
else
	set_task(15.0, "dispInfo", id)

return PLUGIN_CONTINUE
}

public dispInfo(id)
{
ChatColor(id,"^1[^4CSDM^1] ^4Welcome To The CSDM | Sentry Gun | Dispenser | LaserMine | SHOP Server By TSM - Mr.Pro.")
}

public check_say(id){
new said[32]
read_args(said, 31)

if (equali(said, "^"sentryhelp^"") || equali(said, "^"/sentryhelpos^"")) {
	const SIZE = MAXHTMLSIZE
	new msg[SIZE + 1], len = 0
        len += format(msg[len], SIZE - len, "<html><body>")
	len += format(msg[len], SIZE - len, "<p>Sentry & Lasermine.<br/>")
	len += format(msg[len], SIZE - len, "Build A Sentry: sentry_build. Set A LaserMine: +setlaser.<br/>")
	len += format(msg[len], SIZE - len, "You Can Bind For Keys Also.</p>")

	show_motd(id, msg, "Sentry guns help")
}
else if (containi(said, "sentr") != -1) {
	dispInfo(id)
}

return PLUGIN_CONTINUE
}

public plugin_modules() {
require_module("engine")
require_module("fun")
require_module("cstrike")
require_module("fakemeta")
}

new trail_spr, explode_spr
public plugin_precache() {
trail_spr=precache_model("sprites/shockwave.spr")
explode_spr=precache_model("sprites/fexplo.spr")
// Sentries below
precache_model(MODEL_SENTRYGUN_BASE_TR)
precache_model(MODEL_SENTRYGUN_LEVEL1_TR)
precache_model(MODEL_SENTRYGUN_LEVEL2_TR)
precache_model(MODEL_SENTRYGUN_LEVEL3_TR)

precache_model(MODEL_SENTRYGUN_BASE_CT)
precache_model(MODEL_SENTRYGUN_LEVEL1_CT)
precache_model(MODEL_SENTRYGUN_LEVEL2_CT)
precache_model(MODEL_SENTRYGUN_LEVEL3_CT)

g_sModelIndexFireball = precache_model("sprites/zerogxplode.spr") // explosion

precache_sound("debris/bustmetal1.wav") // metal, computer breaking
precache_sound("debris/bustmetal2.wav") // metal, computer breaking
precache_sound("debris/metal1.wav") // metal breaking (needed for comp also?!)
//	precache_sound("debris/metal2.wav") // metal breaking
precache_sound("debris/metal3.wav") // metal breaking (needed for comp also?!)
//	precache_model("models/metalplategibs.mdl") // metal breaking
precache_model("models/computergibs.mdl") // computer breaking

precache_sound("sentries/asscan1.wav")
precache_sound("sentries/asscan2.wav")
precache_sound("sentries/asscan3.wav")
precache_sound("sentries/asscan4.wav")
precache_sound("sentries/turridle.wav")
precache_sound("sentries/turrset.wav")
precache_sound("sentries/turrspot.wav")
precache_sound("sentries/building.wav")

precache_sound("weapons/m249-1.wav")
}


stock spambits(to, bits) {
new buffer[512], len = 0
for (new i = 31; i >= 0; i--) {
	len += format(buffer[len], 511 - len, "%d", bits & (1<<i) ? 1 : 0)
}
client_print(to, print_chat, buffer)
server_print(buffer)
}

public forward_traceline_post(Float:start[3], Float:end[3], noMonsters, player) {
if (is_user_bot(player) || player < 1 || player > g_MAXPLAYERS)
	return FMRES_IGNORED

if (!is_user_alive(player))
	return FMRES_IGNORED

SetStatusTrigger(player, false)

new hitEnt = get_tr(TR_pHit)
if (hitEnt <= g_MAXPLAYERS)
	return FMRES_IGNORED

new classname[11], sentry = 0, base = 0
entity_get_string(hitEnt, EV_SZ_classname, classname, 10)
if (equal(classname, "sentrybase")) {
	base = hitEnt
	sentry = entity_get_edict(hitEnt, BASE_ENT_SENTRY)
}
else if (equal(classname, "sentry")) {
	sentry = hitEnt
	base = entity_get_edict(sentry, SENTRY_ENT_BASE)
}
if (!sentry || !base || entity_get_int(sentry, SENTRY_INT_FIRE) == SENTRY_FIREMODE_NUTS)
	return FMRES_IGNORED
new Float:health = entity_get_float(sentry, EV_FL_health)
if (health <= 0)
	return FMRES_IGNORED
new Float:basehealth = entity_get_float(base, EV_FL_health)
if (basehealth <= 0)
	return FMRES_IGNORED
new team = entity_get_int(sentry, SENTRY_INT_TEAM)
if (team != get_user_team(player))
	return FMRES_IGNORED

// Display health
new level = entity_get_int(sentry, SENTRY_INT_LEVEL)
new upgradeInfo[128]
if (PlayerCanUpgradeSentry(player, sentry))
	format(upgradeInfo, 127, "^n(Tap To Upgrade %d For $%d)", level + 2, g_COST(level + 1))
else if (level < SENTRY_LEVEL_3)
	format(upgradeInfo, 127, "^n(Repair Price: %d$)", g_COST(level + 1))
else
	upgradeInfo = ""

new OwnName[33]
get_user_name ( GetSentryPeople ( sentry, OWNER ), OwnName, 32 )
new tempStatusBuffer[256]
format(tempStatusBuffer, 255, "Owner: %s^nHP Towers: %d/%d^nHP Legs: %d/%d^nLevel: %d%s",OwnName, floatround(health), floatround(g_HEALTHS[level]), floatround(basehealth), floatround(g_HEALTHS[0]), level + 1, upgradeInfo)

SetStatusTrigger(player, true)
if (!task_exists(TASKID_SENTRYSTATUS + player) || !equal(tempStatusBuffer, g_sentryStatusBuffer[player - 1])) {
	// may still exist if !equal was true, so we remove previous task. This happens when sentry is being fired upon, player gets enough money to upgrade or sentry
	// suddenly is upgradeable because another teammate upgraded it or something. This should make for instant updates to message without risking sending a lot of messages
	// just in case data updated, now we only send more often if data changed often enough.
	//client_print(player, print_chat, "Starting to send: %s", tempStatusBuffer)
	remove_task(TASKID_SENTRYSTATUS + player)

	g_sentryStatusBuffer[player - 1] = tempStatusBuffer
	new parms[2]
	parms[0] = player
	parms[1] = team
	set_task(0.0, "displaysentrystatus", TASKID_SENTRYSTATUS + player, parms, 2)
}

return FMRES_IGNORED
}

// Counting level, team, money and DEFINES
bool:PlayerCanUpgradeSentry(player, sentry) {
new level = entity_get_int(sentry, SENTRY_INT_LEVEL)
switch(level) {
	case SENTRY_LEVEL_1: {
		/*#if defined DISALLOW_OWN_UPGRADES
		if (player == GetSentryPeople(sentry, OWNER))
			return false
		#endif*/
		return get_user_team(player) == entity_get_int(sentry, SENTRY_INT_TEAM) && cs_get_user_money(player) >= g_COST(level + 1)
	}
	case SENTRY_LEVEL_2: {
		/*#if defined DISALLOW_TWO_UPGRADES
		if (player == GetSentryPeople(sentry, UPGRADER_1))
			return false
		#endif*/
		return get_user_team(player) == entity_get_int(sentry, SENTRY_INT_TEAM) && cs_get_user_money(player) >= g_COST(level + 1)
	}
}

return false
}

public displaysentrystatus(parms[2]) {
// parm 0 = player
// parm 1 = team
if (!GetStatusTrigger(parms[0]))
	return

set_hudmessage(parms[1] == 1 ? 150 : 0, 0, parms[1] == 2 ? 150 : 0, -1.0, 0.35, 0, 0.0, STATUSINFOTIME + 0.1, 0.0, 0.0, 2) // STATUSINFOTIME + 0.1 = overlapping a little..
show_hudmessage(parms[0], g_sentryStatusBuffer[parms[0] - 1])

set_task(STATUSINFOTIME, "displaysentrystatus", TASKID_SENTRYSTATUS + parms[0], parms, 2)
}


ResetArmoury() {
// Find all armoury_entity:s, restore their initial origins
new entity = 0, Float:NULLVELOCITY[3] = {0.0, 0.0, 0.0}, Float:origin[3]
while ((entity = find_ent_by_class(entity, "armoury_entity"))) {
	// Reset speed in case it's flying around...
	entity_set_vector(entity, EV_VEC_velocity, NULLVELOCITY)

	// Get origin and set it.
	entity_get_vector(entity, EV_VEC_vuser1, origin)
	entity_set_origin(entity, origin)
}
}

public InitArmoury() {
// Find all armoury_entity:s, store their initial origins
new entity = 0, Float:origin[3], counter = 0
while ((entity = find_ent_by_class(entity, "armoury_entity"))) {
	entity_get_vector(entity, EV_VEC_origin, origin)
	entity_set_vector(entity, EV_VEC_vuser1, origin)
	counter++
}
if (counter > 0)
	g_hasArmouries = true
}

stock getnumbers(number, wordnumbers[], length) {
if (number < 0) {
	format(wordnumbers, length, "error")
	return
}

new numberstr[20]
num_to_str(number, numberstr, 19)
new stlen = strlen(numberstr), bool:getzero = false, bool:jumpnext = false
if (stlen == 1)
	getzero = true

do {
	if (jumpnext)
		jumpnext = false
	else if (numberstr[0] != '0') {
		switch (stlen) {
			case 9: {
				if (getsingledigit(numberstr[0], wordnumbers, length))
					format(wordnumbers, length, "%s hundred%s", wordnumbers, numberstr[1] == '0' && numberstr[2] == '0' ? " million" : "")
			}
			case 8: {
				jumpnext = gettens(wordnumbers, length, numberstr)
				if (jumpnext)
					format(wordnumbers, length, "%s million", wordnumbers)
			}
			case 7: {
				getsingledigit(numberstr[0], wordnumbers, length)
				format(wordnumbers, length, "%s million", wordnumbers)
			}
			case 6: {
				if (getsingledigit(numberstr[0], wordnumbers, length))
					format(wordnumbers, length, "%s hundred%s", wordnumbers, numberstr[1] == '0' && numberstr[2] == '0' ? " thousand" : "")
			}
			case 5: {
				jumpnext = gettens(wordnumbers, length, numberstr)
				if (numberstr[0] == '1' || numberstr[1] == '0')
					format(wordnumbers, length, "%s thousand", wordnumbers)
			}
			case 4: {
				getsingledigit(numberstr[0], wordnumbers, length)
				format(wordnumbers, length, "%s thousand", wordnumbers)
			}
			case 3: {
				getsingledigit(numberstr[0], wordnumbers, length)
				format(wordnumbers, length, "%s hundred", wordnumbers)
			}
			case 2: jumpnext = gettens(wordnumbers, length, numberstr)
			case 1: {
				getsingledigit(numberstr[0], wordnumbers, length, getzero)
				break // could've trimmed, but of no use here
			}
			default: {
				format(wordnumbers, length, "%s TOO LONG", wordnumbers)
				break
			}
		}
	}

	jghg_trim(numberstr, length, 1)
	stlen = strlen(numberstr)
}
while (stlen > 0)

// Trim a char from left if first char is a space (very likely)
if (wordnumbers[0] == ' ')
	jghg_trim(wordnumbers, length, 1)
}

// Returns true if next char should be jumped
stock bool:gettens(wordnumbers[], length, numberstr[]) {
new digitstr[11], bool:dont = false, bool:jumpnext = false
switch (numberstr[0]) {
	case '1': {
		jumpnext = true
		switch (numberstr[1]) {
			case '0': digitstr = "10"
			case '1': digitstr = "11"
			case '2': digitstr = "12"
			case '3': digitstr = "13"
			case '4': digitstr = "14"
			case '5': digitstr = "15"
			case '6': digitstr = "16"
			case '7': digitstr = "17"
			case '8': digitstr = "18"
			case '9': digitstr = "19"
			default: digitstr = "TEENSERROR"
		}
	}
	case '2': digitstr = "2"
	case '3': digitstr = "3"
	case '4': digitstr = "4"
	case '5': digitstr = "5"
	case '6': digitstr = "6"
	case '7': digitstr = "7"
	case '8': digitstr = "8"
	case '9': digitstr = "9"
	case '0': dont = true // do nothing
	default : digitstr = "TENSERROR"
}
if (!dont)
	format(wordnumbers, length, "%s %s", wordnumbers, digitstr)

return jumpnext
}

// Returns true when sets, else false
stock getsingledigit(digit[], numbers[], length, bool:getzero = false) {
new digitstr[11]
switch (digit[0]) {
	case '1': digitstr = "1"
	case '2': digitstr = "2"
	case '3': digitstr = "3"
	case '4': digitstr = "4"
	case '5': digitstr = "5"
	case '6': digitstr = "6"
	case '7': digitstr = "7"
	case '8': digitstr = "8"
	case '9': digitstr = "9"
	case '0': {
		if (getzero)
			digitstr = "0"
		else
			return false
	}
	default : digitstr = "digiterror"
}
format(numbers, length, "%s %s", numbers, digitstr)

return true
}

stock jghg_trim(stringtotrim[], len, charstotrim, bool:fromleft = true) {
if (charstotrim <= 0)
	return

if (fromleft) {
	new maxlen = strlen(stringtotrim)
	if (charstotrim > maxlen)
		charstotrim = maxlen

	format(stringtotrim, len, "%s", stringtotrim[charstotrim])
}
else {
	new maxlen = strlen(stringtotrim) - charstotrim
	if (maxlen < 0)
		maxlen = 0

	format(stringtotrim, maxlen, "%s", stringtotrim)
}
}


BotBuild(bot, Float:closestTime = 0.1, Float:longestTime = 5.0) {
// This function should only be used to build sentries at objective related targets.
// So as to not try to build all the time if recently started a build task when touched a objective related target
if (task_exists(bot))
	return

new teamSentriesNear = GetStuffInVicinity(bot, BOT_MAXSENTRIESDISTANCE, true, "sentry") + GetStuffInVicinity(bot, BOT_MAXSENTRIESDISTANCE, true, "sentrybase")
if (teamSentriesNear >= BOT_MAXSENTRIESNEAR) {
	new name[32]
	get_user_name(bot, name, 31)
	//client_print(0, print_chat, "There are already %d sentries near me, I won't build here, %s says. (objective)", teamSentriesNear, name)
	return
}

new Float:ltime = random_float(closestTime, longestTime)
set_task(ltime, "sentry_build", bot)
//server_print("Bot task %d set to %f seconds", bot, ltime)

/*new tempname[32]
get_user_name(bot, tempname, 31)
client_print(0, print_chat, "Bot %s will build a sentry in %f seconds...", tempname, ltime)*/
}
public sentry_build_randomlybybot(taskid_and_id) {
//Shaman: Check if the player is allowed to build
if(!g_allowBuild)
	return

if (!is_user_alive(taskid_and_id - TASKID_BOTBUILDRANDOMLY))
	return

// Now finally do a short check if there already are enough (2-3 sentries) in this vicinity... then don't build.
new teamSentriesNear = GetStuffInVicinity(taskid_and_id - TASKID_BOTBUILDRANDOMLY, BOT_MAXSENTRIESDISTANCE, true, "sentry") + GetStuffInVicinity(taskid_and_id - TASKID_BOTBUILDRANDOMLY, BOT_MAXSENTRIESDISTANCE, true, "sentrybase")
if (teamSentriesNear >= BOT_MAXSENTRIESNEAR) {
	//new name[32]
	//get_user_name(taskid_and_id - TASKID_BOTBUILDRANDOMLY, name, 31)
	//client_print(0, print_chat, "There are already %d sentries near me, I won't build here, %s says. (random)", teamSentriesNear, name)
	return
}

sentry_build(taskid_and_id - TASKID_BOTBUILDRANDOMLY)
}

GetStuffInVicinity(entity, const Float:RADIUS, bool:followTeam, STUFF[]) {
new classname[32], sentryTeam, nrOfStuffNear = 0
entity_get_string(entity, EV_SZ_classname, classname, 31)
if (followTeam) {
	if (equal(classname, "player"))
		sentryTeam = get_user_team(entity)
	else if (equal(classname, "sentry"))
		sentryTeam = entity_get_int(entity, SENTRY_INT_TEAM)
}

if (followTeam) {
	if (equal(STUFF, "sentry")) {
		for (new i = 0; i < g_sentriesNum; i++) {
			if (g_sentries[i] == entity || (followTeam && entity_get_int(g_sentries[i], SENTRY_INT_TEAM) != sentryTeam) || entity_range(g_sentries[i], entity) > RADIUS)
				continue

			nrOfStuffNear++
		}
	}
	else if (equal(STUFF, "sentrybase")) {
		new ent = 0
		while ((ent = find_ent_by_class(ent, STUFF))) {
			// Don't count if:
			// If follow team then if team is not same
			// If ent is the same as what we're searching from, which is entity
			// Don't count a base if it has a head, we consider sentry+base only as one item (a sentry)
			// Or if out of range
			if ((followTeam && entity_get_int(ent, BASE_INT_TEAM) != sentryTeam)
			|| ent == entity
			|| entity_get_edict(ent, BASE_ENT_SENTRY) != 0
			|| entity_range(ent, entity) > RADIUS)
				continue

			nrOfStuffNear++
		}
	}
}

//client_print(0, print_chat, "Found %d sentries within %f distance of entity %d...", nrOfSentriesNear, RADIUS, entity)
return nrOfStuffNear
}

BotBuildRandomly(bot, Float:closestTime = 0.1, Float:longestTime = 5.0) {
// This function is used to stark tasks that will build sentries randomly regardless of map objectives and its targets.
new Float:ltime = random_float(closestTime, longestTime)
set_task(ltime, "sentry_build_randomlybybot", TASKID_BOTBUILDRANDOMLY + bot)

new tempname[32]
get_user_name(bot, tempname, 31)
//client_print(0, print_chat, "Bot %s will build a random sentry in %f seconds...", tempname, ltime)
//server_print("Bot %s will build a random sentry in %f seconds...", tempname, ltime)
}

public playerreachedtarget(target, bot) {
if (!is_user_bot(bot) || GetSentryCount(bot) >= MAXPLAYERSENTRIES || entity_get_int(bot, EV_INT_bInDuck) || cs_get_user_vip(bot) || get_systime() < g_lastObjectiveBuild[bot - 1] + BOT_OBJECTIVEWAIT)
	return PLUGIN_CONTINUE

//client_print(bot, print_chat, "You touched bombtarget %d!", bombtarget)
BotBuild(bot)
g_lastObjectiveBuild[bot - 1] = get_systime()

return PLUGIN_CONTINUE
}

public create_rocket(ent_sentry, Float:sentryOrigin[3], Float:AimOrigin[3])
{	
	new ent=fm_create_entity("info_target")
	
	if(!ent) return

	set_pev(ent, pev_classname, "SGRocket")	

	set_pev(ent, pev_origin, sentryOrigin)
	
	fm_entity_set_model(ent,"models/grenade.mdl")

	set_pev(ent, pev_solid, SOLID_NOT)
	set_pev(ent, pev_movetype, MOVETYPE_FLY)

	fm_entity_set_size(ent,Float:{0.0, 0.0, 0.0},Float:{0.0, 0.0, 0.0})
	
	new Float:Velo[3]
	Velo[0]=AimOrigin[0]-sentryOrigin[0]
	Velo[1]=AimOrigin[1]-sentryOrigin[1]
	Velo[2]=AimOrigin[2]-sentryOrigin[2]
	
	xs_vec_normalize(Velo, Velo)
	xs_vec_mul_scalar(Velo, 1000.0, Velo)
	
	set_pev(ent, pev_velocity, Velo)
	
	set_pev(ent, pev_euser1, ent_sentry)
	
	set_pev(ent, pev_effects, pev(ent, pev_effects)|EF_LIGHT)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW)
	write_short(ent)
	write_short(trail_spr)
	write_byte(25)
	write_byte(3)
	write_byte(55)
	write_byte(255)
	write_byte(55)
	write_byte(250)
	message_end()
	
	set_pev(ent, pev_nextthink, get_gametime() + 0.25)
}

public think_sgrocket(ent)
{
	set_pev(ent, pev_solid, SOLID_BBOX)
}

public touch_sgrocket(ent, id)
{
	new Float:Origin[3]

	pev(ent, pev_origin, Origin)
	
	set_pev(ent, pev_movetype, MOVETYPE_NONE)
	set_pev(ent, pev_solid, SOLID_NOT)	
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, Origin[0])
	engfunc(EngFunc_WriteCoord, Origin[1])
	engfunc(EngFunc_WriteCoord, Origin[2]+90.0)
	write_short(explode_spr)
	write_byte(random_num(18,21))
	write_byte(random_num(20,22))
	write_byte(0)
	message_end()	
	
	new victim=FM_NULLENT, Float:vOrigin[3], Float:temp, attacker, Float:damage, Float:radius

	new sentry=pev(ent, pev_euser1)
	
	if(!is_valid_ent(sentry)){
		engfunc(EngFunc_RemoveEntity, ent)
		return
	}
	attacker=GetSentryPeople(sentry, OWNER)
	
	radius=210.0
	while((victim=fm_find_ent_in_sphere(victim, Origin, radius))!=0)
	{	
		if(pev(victim, pev_takedamage)!=DAMAGE_NO&&pev(victim, pev_solid)!=SOLID_NOT)
		{
			damage=300.0
			
			if(1<=victim<=32)
			{
				if(is_user_alive(victim)&&get_user_team(victim) != entity_get_int(sentry, SENTRY_INT_TEAM))
				{
					pev(victim, pev_origin, vOrigin)
					
					temp=vector_distance(Origin, vOrigin)
					
					//xs_vec_normalize(vOrigin, vOrigin)
					//xs_vec_mul_scalar(vOrigin, KNOCKBACK, vOrigin)
					//xs_vec_neg(vOrigin, vOrigin)
					
					//vOrigin[2]+=KNOCKBACK
					
					//set_pev(victim, pev_velocity, vOrigin)
		
					if(temp<1.0)temp=1.0
		
					if(temp>radius)temp=radius
						
					damage-=(damage/radius)*temp	
					
					if(damage<10.0)damage=10.0		

					ExecuteHamB(Ham_TakeDamage, victim, ent, attacker, damage, DMG_BULLET|DMG_NEVERGIB)
				}
			}
			//else
			//	ExecuteHamB(Ham_TakeDamage, victim, ent, attacker, damage, DMG_BULLET|DMG_NEVERGIB)
		}
	}
	
	
	engfunc(EngFunc_RemoveEntity, ent)
}

public playertouchedweaponbox(weaponbox, bot) {
if (!is_user_bot(bot) || GetSentryCount(bot) >= MAXPLAYERSENTRIES || cs_get_user_team(bot) != CS_TEAM_CT)
	return PLUGIN_CONTINUE

new model[22]
entity_get_string(weaponbox, EV_SZ_model, model, 21)
if (!equal(model, "models/w_backpack.mdl"))
	return PLUGIN_CONTINUE

// A ct will build near a dropped bomb
BotBuild(bot, 0.0, 2.0)

return PLUGIN_CONTINUE
}

public playerreachedhostagerescue(target, bot) {
if (!is_user_bot(bot) || GetSentryCount(bot) >= MAXPLAYERSENTRIES) //  || cs_get_user_team(bot) != CS_TEAM_T
	return PLUGIN_CONTINUE

// ~5% chance that a ct will build a sentry here, a t always builds
if (cs_get_user_team(bot) == CS_TEAM_CT) {
	if (random_num(0, 99) < 95)
		return PLUGIN_CONTINUE
}

BotBuild(bot)

//client_print(bot, print_chat, "You touched bombtarget %d!", bombtarget)

return PLUGIN_CONTINUE
}

public playertouchedhostage(hostage, bot) {
if (!is_user_bot(bot) || GetSentryCount(bot) >= MAXPLAYERSENTRIES || cs_get_user_team(bot) != CS_TEAM_T)
	return PLUGIN_CONTINUE

// Build a sentry close to a hostage
BotBuild(bot)

//client_print(bot, print_chat, "You touched bombtarget %d!", bombtarget)

return PLUGIN_CONTINUE
}


public playertouchedsentry(sentry, player) {
if (PlayerCanUpgradeSentry(player, sentry))
	sentry_upgrade(player, sentry)

//client_print(bot, print_chat, "You touched a sentry %d!", sentry)

return PLUGIN_CONTINUE
}

public botbuildsrandomly(parm[1]) {
if (!is_user_connected(parm[0])) {
	//server_print("********* %d is no longer in server!", parm[0])
	return
}

new Float:ltime = random_float(BOT_WAITTIME_MIN, BOT_WAITTIME_MAX)
new Float:ltime2 = ltime + random_float(BOT_NEXT_MIN, BOT_NEXT_MAX)
BotBuildRandomly(parm[0], ltime, ltime2)

set_task(ltime2, "botbuildsrandomly", 0, parm, 1)
}

#if defined DEBUG
public botbuild_fn(id, level, cid) {
if (!cmd_access(id, level, cid, 1))
	return PLUGIN_HANDLED

new asked = 0
for(new i = 1; i <= g_MAXPLAYERS; i++) {
	if (!is_user_connected(i) || !is_user_bot(i) || !is_user_alive(i))
		continue

	sentry_build(i)
	asked++
}
console_print(id, "Asked %d bots to build sentries (not counting money etc)", asked)

return PLUGIN_HANDLED
}
#endif

g_COST(i)
{
switch(i)
{
	case 0: return COST_INIT
	case 1: return COST_UP
	case 2: return COST_UPTWO
}
return 0;
}

public plugin_init() {
register_plugin(PLUGINNAME, VERSION, AUTHOR)

register_clcmd("sentry_build", "createsentryhere" ,0, "- build a sentry gun where you are")
register_clcmd("sentry_menu", "menumain", 0, "- displays Sentry menu")
register_clcmd("say", "check_say")
register_clcmd("say_team", "check_say")

#if defined DEBUG
register_concmd("0botbuild", "botbuild_fn", ADMIN_CFG, "- force bots to build right where they are (debug)")
#endif

//register_cvar("pend_inc", "30")
//register_cvar("radar_increment", "4.56")
//register_cvar("spycamoffset", "24.0")

sentry_max = register_cvar("sentry_max", "4");
sentryvip_max = register_cvar("sentryvip_max", "6");
sentry_cost1 = register_cvar("sentry_cost1", "5000");
sentry_cost2 = register_cvar("sentry_cost2", "1000");
sentry_cost3 = register_cvar("sentry_cost3", "3000");
sentry_team = register_cvar("sentry_team", "0"); // who can put guns (0 = all) (1 = terrorists) (2 = counters)
sentry_wait = register_cvar("sentry_wait", "1"); // Cannon build delay at the start of the round.

register_event("ResetHUD", "newround_event", "b")
register_event("SendAudio", "endround_event", "a", "2&%!MRAD_terwin", "2&%!MRAD_ctwin", "2&%!MRAD_rounddraw")
register_event("TextMsg", "endround_event", "a", "2&#Game_C", "2&#Game_w")
register_event("TextMsg", "endround_event", "a", "2&#Game_will_restart_in")
//Shaman: For destroying sentries after team change
register_event( "TeamInfo", "jointeam_event", "a")

register_forward(FM_TraceLine, "forward_traceline_post", 1)

//new bool:foundSomething = false
if (find_ent_by_class(0, "func_bomb_target")) {
	register_touch("func_bomb_target", "player", "playerreachedtarget")
	register_touch("weaponbox", "player", "playertouchedweaponbox")
	//foundSomething = true
}
if (find_ent_by_class(0, "func_hostage_rescue")) {
	register_touch("func_hostage_rescue", "player", "playerreachedhostagerescue")
	//foundSomething = true
}
if (find_ent_by_class(0, "func_vip_safetyzone")) {
	register_touch("func_vip_safetyzone", "player", "playerreachedtarget")
	//foundSomething = true
}
if (find_ent_by_class(0, "hostage_entity")) {
	register_touch("hostage_entity", "player", "playertouchedhostage")
	//foundSomething = true
}

register_touch("sentry", "player", "playertouchedsentry")
RegisterHam(Ham_TakeDamage, "func_breakable", "func_DamageSentry")

g_menuId = register_menuid("\ySentry Menu^n\yBy \rTSM - Mr.Pro")
register_menucmd(g_menuId, 1023, "menumain_handle")

register_message(23, "message_tempentity") // <-- works for 0.16 as well
//register_think("sentry", "think_sentry") // <-- only 0.20+ can do this
register_think("sentrybase", "think_sentrybase")

//register_touch("SGRocket", "*", "touch_sgrocket")
//register_think("SGRocket", "think_sgrocket")

g_msgDamage = get_user_msgid("Damage")
g_msgDeathMsg = get_user_msgid("DeathMsg")
g_msgScoreInfo = get_user_msgid("ScoreInfo")
g_msgHostagePos = get_user_msgid("HostagePos")
g_msgHostageK = get_user_msgid("HostageK")

g_MAXPLAYERS = get_global_int(GL_maxClients)
//g_MAXENTITIES = get_global_int(GL_maxEntities)
g_ONEEIGHTYTHROUGHPI = 180.0 / PI

// Add menu item to menufront
#if defined AddMenuItem
AddMenuItem("Sentry guns", "sentry_menu", ADMIN_RCON, PLUGINNAME)
#endif

// InitArmoury saves the location of all onground weapons. Later we restore them to these origins when a newround begin.
set_task(5.0, "InitArmoury")
}
#define is_user_valid(%1) (1 <= %1 <= get_maxplayers())

public func_DamageSentry(victim, inflictor, attacker, Float:damage, damagebits)
{
	if ( !is_user_valid( attacker ) ) return HAM_IGNORED
	
	static sz_classname[32]
	entity_get_string(victim, EV_SZ_classname, sz_classname, charsmax(sz_classname))
	
	if( equal(sz_classname, "sentry") )
	{
		if (entity_get_int(victim, SENTRY_INT_TEAM) == get_user_team(attacker))
			return HAM_SUPERCEDE
	}
	else if( equal(sz_classname, "sentrybase") )
	{
		if (entity_get_int(victim, BASE_INT_TEAM) == get_user_team(attacker))
			return HAM_SUPERCEDE
	}
	
	return HAM_IGNORED
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