#include <amxmodx>
#include <colorchat>
#include <cstrike>
#include <fakemeta>
#include <fun>
#include <hamsandwich>

#define DMG_HE (1<<24)
#define IsPlayer(%1) (1<=%1<=maxPlayers)

forward amxbans_admin_connect(id);

new Array:g_Array, CsArmorType:armortype, bool:g_FreezeTime, bool:g_Vip[33], gRound=0,
g_Hudmsg, ioid, maxPlayers, skoki[33];

new const g_Langcmd[][]={"say /vips","say_team /vips","say /vipy","say_team /vipy"};
new const g_Prefix[] = "VIP Chat";

public plugin_init(){				
	register_plugin("VIP Ultimate", "12.3.0.2", "TSM - Mr.Pro");
	RegisterHam(Ham_Spawn, "player", "SpawnedEventPre", 1);
	RegisterHam(get_player_resetmaxspeed_func(), "player", "fw_Player_ResetMaxSpeed", 1);
	register_logevent("logevent_round_start", 2, "1=Round_Start");
	register_event("HLTV", "event_new_round", "a", "1=0", "2=0");
	register_forward(FM_CmdStart, "CmdStartPre");
	register_logevent("GameCommencing", 2, "1=Game_Commencing");
	RegisterHam(Ham_TakeDamage, "player", "takeDamage", 0);
	register_event("DeathMsg", "DeathMsg", "a");
	register_message(get_user_msgid("ScoreAttrib"), "VipStatus");
	g_Array=ArrayCreate(64,32);
	for(new i;i<sizeof g_Langcmd;i++){
		register_clcmd(g_Langcmd[i], "ShowVips");
	}
	register_clcmd("say /vip", "ShowMotd");
	set_task(30.0, "ShowAdv",.flags = "b");
	g_Hudmsg=CreateHudSyncObj();
	register_event("Damage", "damage", "b", "2!0", "3=0", "4!0");
	register_clcmd("say_team", "VipChat");
}
public client_authorized_vip(id){
	g_Vip[id]=true;
	new g_Name[64];
	get_user_name(id,g_Name,charsmax(g_Name));
	
	new g_Size = ArraySize(g_Array);
	new szName[64];
	
	for(new i = 0; i < g_Size; i++){
		ArrayGetString(g_Array, i, szName, charsmax(szName));
		
		if(equal(g_Name, szName)){
			return 0;
		}
	}
	ArrayPushString(g_Array,g_Name);
	
	return PLUGIN_CONTINUE;
}
public client_disconnected(id){
	if(g_Vip[id]){
		client_disconnect_vip(id);
	}
}
public client_disconnect_vip(id){
	g_Vip[id]=false;
	new Name[64];
	get_user_name(id,Name,charsmax(Name));
	
	new g_Size = ArraySize(g_Array);
	new g_Name[64];
	
	for(new i = 0; i < g_Size; i++){
		ArrayGetString(g_Array, i, g_Name, charsmax(g_Name));
		
		if(equal(g_Name,Name)){
			ArrayDeleteItem(g_Array,i);
			break;
		}
	}
}
public SpawnedEventPre(id){
	if(g_Vip[id]){
		if(is_user_alive(id)){
			SpawnedEventPreVip(id);
		}
	}
}
public SpawnedEventPreVip(id){
	set_user_gravity(id, 650.0/800.0);
	set_user_footsteps(id,1);
	skoki[id]=1;
	set_user_rendering(id, kRenderFxNone, 0,0,0, kRenderTransAlpha, 75);
	set_user_health(id, get_user_health(id)+50);
	cs_set_user_armor(id, min(cs_get_user_armor(id,armortype)+100, 300), armortype);
	new henum=(user_has_weapon(id,CSW_HEGRENADE)?cs_get_user_bpammo(id,CSW_HEGRENADE):0);
	give_item(id, "weapon_hegrenade");
	++henum;
	new sgnum=(user_has_weapon(id,CSW_SMOKEGRENADE)?cs_get_user_bpammo(id,CSW_SMOKEGRENADE):0);
	give_item(id, "weapon_smokegrenade");
	++sgnum;
	new g_Model[64];
	formatex(g_Model,charsmax(g_Model),"%s",get_user_team(id) == 1 ? "CSDM_VIPTT" : "CSDM_VIPCT");
	cs_set_user_model(id,g_Model);
	if(gRound>=2){
		cs_set_user_money(id, min(cs_get_user_money(id)+1000, 1000000), 1);
	}
}
Ham:get_player_resetmaxspeed_func(){
	#if defined Ham_CS_Player_ResetMaxSpeed
	return IsHamValid(Ham_CS_Player_ResetMaxSpeed)?Ham_CS_Player_ResetMaxSpeed:Ham_Item_PreFrame;
	#else
	return Ham_Item_PreFrame;
	#endif
}
public fw_Player_ResetMaxSpeed(id){
	if(g_Vip[id]){
		if(is_user_alive(id)){
			fw_Player_ResetMaxSpeedVip(id);
		}
	}
}
public logevent_round_start(){
	g_FreezeTime=false;
}
public event_new_round(){
	g_FreezeTime=true;
	++gRound;
}
public fw_Player_ResetMaxSpeedVip(id){
	if(!g_FreezeTime){
		set_user_maxspeed(id,get_user_maxspeed(id) + 50);
	}
}
public CmdStartPre(id, uc_handle){
	if(g_Vip[id]){
		if(is_user_alive(id)){
			CmdStartPreVip(id, uc_handle);
		}
	}
}
public CmdStartPreVip(id, uc_handle){
	new flags = pev(id, pev_flags);
	if((get_uc(uc_handle, UC_Buttons) & IN_JUMP) && !(flags & FL_ONGROUND) && !(pev(id, pev_oldbuttons) & IN_JUMP) && skoki[id]>0){
		--skoki[id];
		new Float:velocity[3];
		pev(id, pev_velocity,velocity);
		velocity[2] = random_float(265.0,285.0);
		set_pev(id,pev_velocity,velocity);
	} else if(flags & FL_ONGROUND && skoki[id]!=-1){
		skoki[id] = 1;
	}
}
public GameCommencing(){
	gRound=0;
}
public plugin_cfg(){
	maxPlayers=get_maxplayers();
}
public takeDamage(this, idinflictor, idattacker, Float:damage, damagebits){
	if(((IsPlayer(idattacker) && is_user_connected(idattacker) && g_Vip[idattacker] && (ioid=idattacker)) ||
	(ioid=pev(idinflictor, pev_owner) && IsPlayer(ioid) && is_user_connected(ioid) && g_Vip[ioid]))){
		damage+=10;
		if(damagebits & DMG_BULLET){
			if(get_user_weapon(ioid)==CSW_GLOCK18){
				if(get_user_team(ioid)==1){
					damage+=10;
				}
			}
			if(get_user_weapon(ioid)==CSW_USP){
				if(get_user_team(ioid)==2){
					damage+=10;
				}
			}
			if(get_user_weapon(ioid)==CSW_P228){
				damage+=10;
			}
			if(get_user_weapon(ioid)==CSW_DEAGLE){
				damage+=10;
			}
			if(get_user_weapon(ioid)==CSW_ELITE){
				if(get_user_team(ioid)==1){
					damage+=10;
				}
			}
			if(get_user_weapon(ioid)==CSW_FIVESEVEN){
				if(get_user_team(ioid)==2){
					damage+=10;
				}
			}
			if(get_user_weapon(ioid)==CSW_M3){
				damage+=10;
			}
			if(get_user_weapon(ioid)==CSW_XM1014){
				damage+=10;
			}
			if(get_user_weapon(ioid)==CSW_MAC10){
				if(get_user_team(ioid)==1){
					damage+=10;
				}
			}
			if(get_user_weapon(ioid)==CSW_TMP){
				if(get_user_team(ioid)==2){
					damage+=10;
				}
			}
			if(get_user_weapon(ioid)==CSW_MP5NAVY){
				damage+=10;
			}
			if(get_user_weapon(ioid)==CSW_UMP45){
				damage+=10;
			}
			if(get_user_weapon(ioid)==CSW_P90){
				damage+=10;
			}
			if(get_user_weapon(ioid)==CSW_GALI){
				if(get_user_team(ioid)==1){
					damage+=10;
				}
			}
			if(get_user_weapon(ioid)==CSW_FAMAS){
				if(get_user_team(ioid)==2){
					damage+=10;
				}
			}
			if(get_user_weapon(ioid)==CSW_AK47){
				if(get_user_team(ioid)==1){
					damage+=10;
				}
			}
			if(get_user_weapon(ioid)==CSW_M4A1){
				if(get_user_team(ioid)==2){
					damage+=10;
				}
			}
			if(get_user_weapon(ioid)==CSW_SG552){
				if(get_user_team(ioid)==1){
					damage+=10;
				}
			}
			if(get_user_weapon(ioid)==CSW_AUG){
				if(get_user_team(ioid)==2){
					damage+=10;
				}
			}
			if(get_user_weapon(ioid)==CSW_SCOUT){
				damage+=10;
			}
			if(get_user_weapon(ioid)==CSW_AWP){
				damage+=10;
			}
			if(get_user_weapon(ioid)==CSW_G3SG1){
				if(get_user_team(ioid)==1){
					damage+=10;
				}
			}
			if(get_user_weapon(ioid)==CSW_SG550){
				if(get_user_team(ioid)==2){
					damage+=10;
				}
			}
			if(get_user_weapon(ioid)==CSW_M249){
				damage+=10;
			}
		}
		if(damagebits & DMG_BLAST){
			if(get_user_team(ioid)==1){
				new classname[32];
				pev(idinflictor, pev_classname, classname, 31);
				if(equali(classname,"weapon_c4")){
					damage+=10;
				}
			}
		}
	}
	
	SetHamParamFloat(4, damage);
	return HAM_HANDLED;
}
public DeathMsg(){
	new killer=read_data(1);
	new victim=read_data(2);
	
	if(is_user_alive(killer) && g_Vip[killer] && get_user_team(killer) != get_user_team(victim)){
		DeathMsgVip(killer,victim,read_data(3));
	}
}
public DeathMsgVip(kid,vid,hs){
	set_user_health(kid, min(get_user_health(kid)+(hs?15:10),500));
	cs_set_user_money(kid, cs_get_user_money(kid)+(hs?1000:700));
}
public VipStatus(){
	new id=get_msg_arg_int(1);
	if(is_user_alive(id) && g_Vip[id]){
		set_msg_arg_int(2, ARG_BYTE, get_msg_arg_int(2)|4);
	}
}
public ShowVips(id){
	new g_Name[64],g_Message[192];
	
	new g_Size=ArraySize(g_Array);
	
	for(new i = 0; i < g_Size; i++){
		ArrayGetString(g_Array, i, g_Name, charsmax(g_Name));
		
		add(g_Message, charsmax(g_Message), g_Name);
		
		if(i == g_Size - 1){
			add(g_Message, charsmax(g_Message), ".");
		}
		else{
			add(g_Message, charsmax(g_Message), ", ");
		}
	}
	ColorChat(id,GREEN,"^x04VIPS Online: ^x04%s", g_Message);
	return PLUGIN_CONTINUE;
}
public client_infochanged(id){
	if(g_Vip[id]){
		new szName[64];
		get_user_info(id,"name",szName,charsmax(szName));
		
		new Name[64];
		get_user_name(id,Name,charsmax(Name));
		
		if(!equal(szName,Name)){
			ArrayPushString(g_Array,szName);
			
			new g_Size=ArraySize(g_Array);
			new g_Name[64];
			for(new i = 0; i < g_Size; i++){
				ArrayGetString(g_Array, i, g_Name, charsmax(g_Name));
				
				if(equal(g_Name,Name)){
					ArrayDeleteItem(g_Array,i);
					break;
				}
			}
		}
	}
}
public plugin_end(){
	ArrayDestroy(g_Array);
}
public ShowMotd(id){
	show_motd(id, "vip.txt", "Informacje o vipie");
}
public ShowAdv(){
	ColorChat(0, NORMAL, "^x04[VIP]^x03 To See CSDM VIP Privileges Type ^x04/vip ^x03In Chat.");
}
public damage(id){
	new attacker=get_user_attacker(id);
	new damage=read_data(2);
	
	if(g_Vip[id]){
		set_hudmessage(255, 0, 0, 0.45, 0.50, 2, 0.1, 4.0, 0.1, 0.1, -1);
		ShowSyncHudMsg(id, g_Hudmsg, "%i^n", damage);
	}
	if(is_user_connected(attacker) && g_Vip[attacker]){
		set_hudmessage(0, 100, 200, -1.0, 0.55, 2, 0.1, 4.0, 0.02, 0.02, -1);
		ShowSyncHudMsg(attacker, g_Hudmsg, "%i^n", damage);
	}
}
public VipChat(id){
	if(g_Vip[id]){
		new g_Msg[256],
		g_Text[256];
		
		read_args(g_Msg,charsmax(g_Msg));
		remove_quotes(g_Msg);
		
		if(g_Msg[0] == '*' && g_Msg[1]){
			new g_Name[64];
			get_user_name(id,g_Name,charsmax(g_Name));
			
			formatex(g_Text,charsmax(g_Text),"^x04(%s) ^x03%s : ^x04%s",g_Prefix, g_Name, g_Msg[1]);
			
			for(new i=1;i<33;i++){
				if(is_user_connected(i) && g_Vip[i])
				ColorChat(i, GREEN, "%s", g_Text);
			}
			return PLUGIN_HANDLED_MAIN;
		}
	}
	return PLUGIN_CONTINUE;
}
public plugin_precache(){
	precache_model("models/player/CSDM_VIPCT/CSDM_VIPCT.mdl");
	precache_model("models/player/CSDM_VIPTT/CSDM_VIPTT.mdl");
}