#include <amxmodx>

#include <fakemeta>

#include <fun> 

#include <engine> 

#include <hamsandwich>


#define PLUGIN    "[CSDM] knife menu"

#define VERSION    "1.5"

#define AUTHOR    "TSM - Mr.Pro"


#define VIP ADMIN_RESERVATION

#define ADMIN ADMIN_BAN

#define MANAGER ADMIN_LEVEL_A

#define OWNER ADMIN_RCON

#define MAXPLAYERS 32

#define ID_FBURN1	(taskid - 100)

#define ID_FBURN2	(taskid - 100)

#define ID_FBURN3	(taskid - 100)

#define ID_FBURN4	(taskid - 100)

#define ID_FBURN5	(taskid - 100)

#define ID_FBURN6	(taskid - 100)

#define ID_FBURN7	(taskid - 100)



new			g_burning1[33],
			g_burning2[33],
            g_burning3[33],
            g_burning4[33],
            g_burning5[33],
            g_burning6[33],
            g_burning7[33],
			g_sprite1,
			g_sprite2,
            g_sprite3,
            g_sprite4,
            g_sprite5,
            g_sprite6,
            g_sprite7
   


new combat_v_model[] = "models/CSDM_KnifeMenu/v_combat_knife.mdl"

new combat_p_model[] = "models/CSDM_KnifeMenu/p_combat_knife.mdl"



new strong_v_model[] = "models/CSDM_KnifeMenu/v_strong_knife.mdl"

new strong_p_model[] = "models/CSDM_KnifeMenu/p_strong_knife.mdl"



new axe_v_model[] = "models/CSDM_KnifeMenu/v_axe_knife.mdl"	

new axe_p_model[] = "models/CSDM_KnifeMenu/p_axe_knife.mdl"	



new katana_v_model[] = "models/CSDM_KnifeMenu/v_warhammer.mdl"	

new katana_p_model[] = "models/CSDM_KnifeMenu/p_warhammer.mdl"



new hammer_v_model[] = "models/CSDM_KnifeMenu/v_warhammer_storm.mdl"	

new hammer_p_model[] = "models/CSDM_KnifeMenu/p_warhammer_storm.mdl"	



new thanatos_v_model[] = "models/CSDM_KnifeMenu/v_warhammer_ice.mdl"	

new thanatos_p_model[] = "models/CSDM_KnifeMenu/p_warhammer_ice.mdl"



new boss_v_model[] = "models/CSDM_KnifeMenu/v_boss_hammer.mdl"	

new boss_p_model[] = "models/CSDM_KnifeMenu/p_boss_hammer.mdl"



const m_pPlayer = 41 

const m_flNextPrimaryAttack = 46 

const m_flNextSecondaryAttack = 47 

const m_flTimeWeaponIdle = 48 



new g_hasSpeed[33], SayText

new bool:g_WasShowed[MAXPLAYERS + 1]

new g_knife_combat[33], cvar_knife_combat_jump, cvar_knife_combat_spd, cvar_knife_combat_dmg, cvar_knife_combat_knock, cvar_knife_combat_spd_attack2

new g_knife_strong[33], cvar_knife_strong_jump, cvar_knife_strong_spd, cvar_knife_strong_dmg, cvar_knife_strong_knock, cvar_knife_strong_spd_attack2

new g_knife_axe[33], cvar_knife_axe_jump, cvar_knife_axe_spd, cvar_knife_axe_dmg, cvar_knife_axe_knock, cvar_knife_axe_spd_attack2

new g_knife_katana[33], cvar_knife_katana_jump, cvar_knife_katana_spd, cvar_knife_katana_dmg, cvar_knife_katana_knock, cvar_knife_katana_spd_attack2

new g_knife_hammer[33], cvar_knife_hammer_jump, cvar_knife_hammer_spd, cvar_knife_hammer_dmg, cvar_knife_hammer_knock, cvar_hammer_spd_attack2

new g_knife_thanatos[33], cvar_knife_thanatos_jump, cvar_knife_thanatos_spd, cvar_knife_thanatos_dmg, cvar_knife_thanatos_knock, cvar_thanatos_spd_attack2

new g_knife_boss[33], cvar_knife_boss_jump, cvar_knife_boss_spd, cvar_knife_boss_dmg, cvar_knife_boss_knock, cvar_boss_spd_attack2


new const g_sound_knife[] = { "items/gunpickup2.wav" }



new const combat_sounds[][] =

{

	"CSDM_KnifeMenu/cabret_deploy.wav",

	"CSDM_KnifeMenu/cabret_hit.wav"	,

	"CSDM_KnifeMenu/cabret_hit.wav"	,

	"CSDM_KnifeMenu/cabret_hitwall.wav",

	"CSDM_KnifeMenu/cabret_slash.wav",

	"CSDM_KnifeMenu/cabret_stab.wav"

}



new const strong_sounds[][] =

{

	"CSDM_KnifeMenu/katana_deploy.wav",

	"CSDM_KnifeMenu/katana_hit.wav",

	"CSDM_KnifeMenu/katana_hit.wav",

	"CSDM_KnifeMenu/katana_hitwall.wav",

	"CSDM_KnifeMenu/katana_slash.wav",

	"CSDM_KnifeMenu/katana_stab.wav"

}



new const axe_sounds[][] =

{

	"CSDM_KnifeMenu/thanatos_deploy.wav",

	"CSDM_KnifeMenu/thanatos_hit.wav",

	"CSDM_KnifeMenu/thanatos_hit.wav",

	"CSDM_KnifeMenu/thanatos_hitwall.wav",

	"CSDM_KnifeMenu/thanatos_slash.wav",

	"CSDM_KnifeMenu/thanatos_stab.wav"

}



new const katana_sounds[][] =

{

	"CSDM_KnifeMenu/hammer_deploy.wav",

	"CSDM_KnifeMenu/hammer_hit.wav",

	"CSDM_KnifeMenu/hammer_hit.wav",

	"CSDM_KnifeMenu/hammer_hitwall.wav",

	"CSDM_KnifeMenu/hammer_slash.wav",

	"CSDM_KnifeMenu/hammer_stab.wav"

}



new const hammer_sounds[][] =

{

	"CSDM_KnifeMenu/warhammer_deploy.wav",

	"CSDM_KnifeMenu/warhammer_hit.wav",

	"CSDM_KnifeMenu/warhammer_hit.wav",

	"CSDM_KnifeMenu/warhammer_hitwall.wav",

	"CSDM_KnifeMenu/warhammer_slash.wav",

	"CSDM_KnifeMenu/warhammer_stab.wav"

}



new const thanatos_sounds[][] =

{

	"CSDM_KnifeMenu/warhammer_deploy.wav",

	"CSDM_KnifeMenu/warhammer_hit.wav",

	"CSDM_KnifeMenu/warhammer_hit.wav",

	"CSDM_KnifeMenu/warhammer_hitwall.wav",

	"CSDM_KnifeMenu/warhammer_slash.wav",

	"CSDM_KnifeMenu/warhammer_stab.wav"

}


new const boss_sounds[][] =

{

	"CSDM_KnifeMenu/warhammer_deploy.wav",

	"CSDM_KnifeMenu/warhammer_hit.wav",

	"CSDM_KnifeMenu/warhammer_hit.wav",

	"CSDM_KnifeMenu/warhammer_hitwall.wav",

	"CSDM_KnifeMenu/warhammer_slash.wav",

	"CSDM_KnifeMenu/warhammer_stab.wav"

}


public plugin_init()

{

	register_plugin(PLUGIN , VERSION , AUTHOR);

	register_cvar("csdm_addon_knife", VERSION, FCVAR_SERVER);

    SayText = get_user_msgid("SayText")   



 	register_clcmd("say /knife","knife_menu",ADMIN_ALL,"knife_menu")

 	register_clcmd("csdm_knifemenu","knife_menu",ADMIN_ALL,"knife_menu")

	register_clcmd("combat", "give_combat")

	register_clcmd("strong", "give_strong")

	register_clcmd("axe", "give_axe")

	register_clcmd("katana", "give_katana")

	register_clcmd("hammer", "give_hammer")

	register_clcmd("thanatos", "give_thanatos")

    register_clcmd("boss", "give_boss")

	register_event("CurWeapon","checkWeapon","be","1=1");

	register_event("Damage" , "event_Damage" , "b" , "2>0");



	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink");

    register_forward(FM_EmitSound, "CEntity__EmitSound");



	register_message(get_user_msgid("DeathMsg"), "message_DeathMsg");



	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage");

    RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "fw_Knife_SecondaryAttack_Post", 1) 



	cvar_knife_combat_jump= register_cvar("csdm_knife_combat_jump", "270.0");

	cvar_knife_combat_spd = register_cvar("csdm_knife_combat_spd", "310.0");

	cvar_knife_combat_dmg = register_cvar("csdm_knife_combat_dmg" , "4.0");

	cvar_knife_combat_knock = register_cvar("csdm_knife_combat_knock" , "6.0");

	cvar_knife_combat_spd_attack2 = register_cvar("csdm_knife_combat_spd_attack2" , "1.2");



	cvar_knife_strong_jump= register_cvar("csdm_knife_strong_jump", "265.0");

	cvar_knife_strong_spd = register_cvar("csdm_knife_strong_spd", "255.0");

	cvar_knife_strong_dmg = register_cvar("csdm_knife_strong_dmg" , "12.0");

	cvar_knife_strong_knock = register_cvar("csdm_knife_strong_knock" , "7.0");

	cvar_knife_strong_spd_attack2 = register_cvar("csdm_knife_strong_spd_attack2" , "1.6");



	cvar_knife_axe_jump= register_cvar("csdm_knife_axe_jump", "350.0");

	cvar_knife_axe_spd = register_cvar("csdm_knife_axe_spd", "250.0");

	cvar_knife_axe_dmg = register_cvar("csdm_knife_axe_dmg" , "5.0");

	cvar_knife_axe_knock = register_cvar("csdm_knife_axe_knock" , "6.0");

	cvar_knife_axe_spd_attack2 = register_cvar("csdm_knife_axe_spd_attack2" , "1.4");



	cvar_knife_katana_jump= register_cvar("csdm_knife_katana_jump", "355.0");

	cvar_knife_katana_spd = register_cvar("csdm_knife_katana_spd", "265.0");

	cvar_knife_katana_dmg = register_cvar("csdm_knife_katana_dmg" , "5.0");

	cvar_knife_katana_knock = register_cvar("csdm_knife_katana_knock" , "15.0");

	cvar_knife_katana_spd_attack2 = register_cvar("csdm_knife_katana_spd_attack2" , "1.2");



	cvar_knife_hammer_jump= register_cvar("csdm_knife_hammer_jump", "360.0");

	cvar_knife_hammer_spd= register_cvar("csdm_knife_hammer_spd", "315.0");

	cvar_knife_hammer_dmg = register_cvar("csdm_knife_hammer_dmg" , "15.0");

	cvar_knife_hammer_knock = register_cvar("csdm_knife_hammer_knock" , "20.0");

	cvar_hammer_spd_attack2 = register_cvar("csdm_knife_hammer_spd_attack2" , "1.8");



	cvar_knife_thanatos_jump= register_cvar("csdm_knife_thanatos_jump", "365.0");

	cvar_knife_thanatos_spd= register_cvar("csdm_knife_thanatos_spd", "320.0");

	cvar_knife_thanatos_dmg = register_cvar("csdm_knife_thanatos_dmg" , "17.0");

	cvar_knife_thanatos_knock = register_cvar("csdm_knife_thanatos_knock" , "25.0");

	cvar_thanatos_spd_attack2 = register_cvar("csdm_knife_thanatos_spd_attack2" , "1.8");


    cvar_knife_boss_jump= register_cvar("csdm_knife_boss_jump", "370.0");

 	cvar_knife_boss_spd= register_cvar("csdm_knife_boss_spd", "350.0");

	cvar_knife_boss_dmg = register_cvar("csdm_knife_boss_dmg" , "20.0");

	cvar_knife_boss_knock = register_cvar("csdm_knife_boss_knock" , "30.0");

	cvar_boss_spd_attack2 = register_cvar("csdm_knife_boss_spd_attack2" , "2.0");

    register_event("HLTV", "event_round_start", "a", "1=0", "2=0")

}  

public client_connect(id)

{

	g_knife_combat[id] = false

	g_knife_strong[id] = false

	g_knife_axe[id] = false

	g_knife_katana[id] = false

	g_knife_hammer[id] = false

	g_knife_thanatos[id] = false

	g_knife_boss[id] = false

	g_hasSpeed[id] = false

}



public client_disconnect(id)

{

	g_knife_combat[id] = false

	g_knife_strong[id] = false

	g_knife_axe[id] = false

	g_knife_katana[id] = false

	g_knife_hammer[id] = false

	g_knife_thanatos[id] = false

	g_knife_boss[id] = false

	g_hasSpeed[id] = false

}



public plugin_precache()

{

	precache_model(combat_v_model)

	precache_model(combat_p_model)

	precache_model(strong_v_model)

	precache_model(strong_p_model)

	precache_model(axe_v_model)

	precache_model(axe_p_model)

	precache_model(katana_v_model)

	precache_model(katana_p_model)

	precache_model(hammer_v_model)

	precache_model(hammer_p_model)

	precache_model(thanatos_p_model)

	precache_model(thanatos_v_model)

    precache_model(boss_p_model)

	precache_model(boss_v_model)


	precache_sound(g_sound_knife)



	for(new i = 0; i < sizeof combat_sounds; i++)

		precache_sound(combat_sounds[i])



	for(new i = 0; i < sizeof strong_sounds; i++)

		precache_sound(strong_sounds[i])



	for(new i = 0; i < sizeof axe_sounds; i++)

		precache_sound(axe_sounds[i])  



	for(new i = 0; i < sizeof katana_sounds; i++)

		precache_sound(katana_sounds[i])



	for(new i = 0; i < sizeof hammer_sounds; i++)

		precache_sound(hammer_sounds[i])



	for(new i = 0; i < sizeof thanatos_sounds; i++)

		precache_sound(thanatos_sounds[i])


        for(new i = 0; i < sizeof boss_sounds; i++)

		precache_sound(boss_sounds[i])


        g_sprite1 = precache_model("sprites/CSDM_KnifeMenu/1.spr")
	
	    g_sprite2 = precache_model("sprites/CSDM_KnifeMenu/2.spr")

        g_sprite3 = precache_model("sprites/CSDM_KnifeMenu/3.spr")

        g_sprite4 = precache_model("sprites/CSDM_KnifeMenu/4.spr")

        g_sprite5 = precache_model("sprites/CSDM_KnifeMenu/5.spr")

        g_sprite6 = precache_model("sprites/CSDM_KnifeMenu/6.spr") 

        g_sprite7 = precache_model("sprites/CSDM_KnifeMenu/7.spr") 


}



public event_round_start(id)

{

    	for (new i; i < MAXPLAYERS + 1; i++)

        	g_WasShowed[i] = false

}



public knife_menu(id)

{


	if(is_user_alive(id))

	{

		my_menu(id)

	}



	return PLUGIN_HANDLED

}



public my_menu(id)

{

	new menu = menu_create("\w|\r**\yCSDM | Sentry | LaserMine | Dispenser | SHOP\r**\w|^n\w|\r**\w[CSDM] \rNEW Knife \yMenu\r**\w|^n\w|\r**\wBy \yTSM - Mr.Pro :D\r**\w|^n", "menu_handler");

	menu_additem(menu, "\r|\wCombat \dKnife\r| \w[\wSpeed]", "1", 0);

	menu_additem(menu, "\r|\wStrong \dKnife\r| \w[\wDamage]", "2", 0);

	menu_additem(menu, "\r|\wAxe \dKnife\r| \w[\wJump]^n", "3", 0);


        if(get_user_flags(id) & VIP)
	menu_additem(menu, "\r|\wWar \dHammer\r| \r[\w VIP \yx2\r]", "4", 0);

        else
        menu_additem(menu, "\r|\wWar \dHammer\r| \r[\wVIP \yCost - 3x boost\r]", "4", 0);
 
        if(get_user_flags(id) & ADMIN)
	menu_additem(menu, "\r|\wStorm \dHammer\r| \r[\wADMIN \yx4\r]", "5", 0);

        else
        menu_additem(menu, "\r|\wStorm \dHammer\r| \r[\wADMIN \yCost - 5x boost\r]", "5", 0);

        if(get_user_flags(id) & MANAGER)
	menu_additem(menu, "\r|\wIce \dHammer\r| \r[\wManaGeR \yx6\r]^n", "6", 0);

        else
        menu_additem(menu, "\r|\wIce \dHammer\r| \r[\wManaGeR \yCost - 15 Euro\r]", "6", 0);   

        if(get_user_flags(id) & OWNER)
	menu_additem(menu, "\r|\wBoss \dHammer\r| \r[\wOWNER \yFull Skill \r]", "7", 0);
        
        else
        menu_additem(menu, "\r|\wBoss \dHammer\r| \r[\wOWNER \yCost - 25 Euro\r]", "7", 0);   
 
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);

    

	menu_display(id, menu, 0);    

} 



public menu_handler(id, menu, item)

{

	if( item == MENU_EXIT )

	{

       		menu_destroy(menu);

        	return PLUGIN_HANDLED;    

	}

    

	new data[7], iName[64];

	new access, callback;

    

	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);

    

	new key = str_to_num(data);

    

	switch(key)

	{

        	case 1:

        	{

			give_combat(id)

			menu_destroy(menu);

			return PLUGIN_HANDLED

		}

		case 2:

		{

			give_strong(id)

			menu_destroy(menu);

			return PLUGIN_HANDLED

		}

		case 3:

		{

			give_axe(id)

			menu_destroy(menu);

			return PLUGIN_HANDLED

		}

		case 4:

		{

			give_katana(id)

			menu_destroy(menu);

			return PLUGIN_HANDLED

		}

		case 5:

		{

			give_hammer(id)

			menu_destroy(menu);

			return PLUGIN_HANDLED

		}

		case 6:

		{

			give_thanatos(id)

			menu_destroy(menu);

			return PLUGIN_HANDLED

		}

                case 7:

		{

			give_boss(id)

			menu_destroy(menu);

			return PLUGIN_HANDLED

		}

	}

	menu_destroy(menu);

	return PLUGIN_HANDLED

}



public give_combat(id)

{

	g_knife_combat[id] = true	

	g_knife_strong[id] = false

	g_knife_axe[id] = false	

	g_knife_katana[id] = false	

	g_knife_hammer[id] = false

	g_knife_thanatos[id] = false

    g_knife_boss[id] = false

	g_hasSpeed[id] =  true

	g_WasShowed[id] = true



	engfunc(EngFunc_EmitSound, id, CHAN_BODY, g_sound_knife, 1.0, ATTN_NORM, 0, PITCH_NORM)

}



public give_strong(id)

{

	g_knife_combat[id] = false	

	g_knife_strong[id] = true	

	g_knife_axe[id] = false

	g_knife_katana[id] = false	

	g_knife_hammer[id] = false

	g_knife_thanatos[id] = false

    g_knife_boss[id] = false

	g_hasSpeed[id] = true

	g_WasShowed[id] = true



	engfunc(EngFunc_EmitSound, id, CHAN_BODY, g_sound_knife, 1.0, ATTN_NORM, 0, PITCH_NORM)

}



public give_axe(id)

{

	g_knife_combat[id] = false	

	g_knife_strong[id] = false	

	g_knife_axe[id] = true

	g_knife_katana[id] = false	

	g_knife_hammer[id] = false

	g_knife_thanatos[id] = false
        
    g_knife_boss[id] = false

	g_hasSpeed[id] = true

	g_WasShowed[id] = true



	engfunc(EngFunc_EmitSound, id, CHAN_BODY, g_sound_knife, 1.0, ATTN_NORM, 0, PITCH_NORM)

}



public give_katana(id)


	if (get_user_flags(id) & VIP)

{

	g_knife_combat[id] = false	

	g_knife_strong[id] = false	

	g_knife_axe[id] = false

	g_knife_katana[id] = true	

	g_knife_hammer[id] = false

	g_knife_thanatos[id] = false

	g_knife_boss[id] = false

	g_hasSpeed[id] = true

	g_WasShowed[id] = true



	engfunc(EngFunc_EmitSound, id, CHAN_BODY, g_sound_knife, 1.0, ATTN_NORM, 0, PITCH_NORM)

}





public give_hammer(id)



	if (get_user_flags(id) & ADMIN)

	{

		g_knife_combat[id] = false	

		g_knife_strong[id] = false	

		g_knife_axe[id] = false

		g_knife_katana[id] = false

		g_knife_hammer[id] = true

		g_knife_thanatos[id] = false

        g_knife_boss[id] = false

		g_hasSpeed[id] =  true

		g_WasShowed[id] = true



		engfunc(EngFunc_EmitSound, id, CHAN_BODY, g_sound_knife, 1.0, ATTN_NORM, 0, PITCH_NORM)

	}



public give_thanatos(id)


	if (get_user_flags(id) & MANAGER)

	{

		g_knife_combat[id] = false	

		g_knife_strong[id] = false	

		g_knife_axe[id] = false

		g_knife_katana[id] = false

		g_knife_hammer[id] = false

		g_knife_thanatos[id] = true

        g_knife_boss[id] = false

		g_hasSpeed[id] =  true

		g_WasShowed[id] = true



		engfunc(EngFunc_EmitSound, id, CHAN_BODY, g_sound_knife, 1.0, ATTN_NORM, 0, PITCH_NORM)

	}


public give_boss(id)


       if (get_user_flags(id) & OWNER)

       {

		g_knife_combat[id] = false	

		g_knife_strong[id] = false	

		g_knife_axe[id] = false

		g_knife_katana[id] = false

		g_knife_hammer[id] = false

		g_knife_thanatos[id] = false

		g_knife_boss[id] = true
 
		g_hasSpeed[id] =  true

		g_WasShowed[id] = true



		engfunc(EngFunc_EmitSound, id, CHAN_BODY, g_sound_knife, 1.0, ATTN_NORM, 0, PITCH_NORM)
       }
	
public checkWeapon(id)

{

	new plrWeapId

    

	plrWeapId = get_user_weapon(id)

    

	if (plrWeapId == CSW_KNIFE && (g_knife_combat[id] || g_knife_strong[id] || g_knife_axe[id] || g_knife_katana[id] || g_knife_hammer[id]|| g_knife_thanatos[id] || g_knife_boss[id]))

	{

		checkModel(id)

	}

}



public checkModel(id)

{   

	if (g_knife_combat[id])

	{

		set_pev(id, pev_viewmodel2, combat_v_model)

		set_pev(id, pev_weaponmodel2, combat_p_model)

	}



	if (g_knife_strong[id])

	{

		set_pev(id, pev_viewmodel2, strong_v_model)

		set_pev(id, pev_weaponmodel2, strong_p_model)

	}



	if (g_knife_axe[id])

	{

		set_pev(id, pev_viewmodel2, axe_v_model)

		set_pev(id, pev_weaponmodel2, axe_p_model)

	}



	if (g_knife_katana[id])

	{

		set_pev(id, pev_viewmodel2, katana_v_model)

		set_pev(id, pev_weaponmodel2, katana_p_model)

	}



	if (g_knife_hammer[id])

	{

		set_pev(id, pev_viewmodel2, hammer_v_model)

		set_pev(id, pev_weaponmodel2, hammer_p_model)

	}

	if (g_knife_thanatos[id])

	{

		set_pev(id, pev_viewmodel2, thanatos_v_model)

		set_pev(id, pev_weaponmodel2, thanatos_p_model)

	}

        if (g_knife_boss[id])

	{

		set_pev(id, pev_viewmodel2, boss_v_model)

		set_pev(id, pev_weaponmodel2, boss_p_model)

	}

	return PLUGIN_HANDLED

}


public CEntity__EmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch)

{

    if (!is_user_connected(id)) 

        return HAM_IGNORED
    

    if (sample[8] == 'k' && sample[9] == 'n' && sample[10] == 'i')

    {

        if (sample[14] == 'd') 

        {

            if(g_knife_combat[id])

                emit_sound(id, channel, combat_sounds[0], volume, attn, flags, pitch)

            if(g_knife_strong[id])

                emit_sound(id, channel, strong_sounds[0], volume, attn, flags, pitch)

            if(g_knife_axe[id])

                emit_sound(id, channel, axe_sounds[0], volume, attn, flags, pitch)

            if(g_knife_katana[id])

                emit_sound(id, channel, katana_sounds[0], volume, attn, flags, pitch)

            if(g_knife_hammer[id])

                emit_sound(id, channel, hammer_sounds[0], volume, attn, flags, pitch)

            if(g_knife_thanatos[id])

                emit_sound(id, channel, thanatos_sounds[0], volume, attn, flags, pitch)

            if(g_knife_boss[id])

                emit_sound(id, channel, boss_sounds[0], volume, attn, flags, pitch)

        }

        else if (sample[14] == 'h')

        {

            if (sample[17] == 'w') 

            {

                if(g_knife_combat[id])

                    emit_sound(id, channel, combat_sounds[3], volume, attn, flags, pitch)

                if(g_knife_strong[id])

                    emit_sound(id, channel, strong_sounds[3], volume, attn, flags, pitch)

                if(g_knife_axe[id])

                    emit_sound(id, channel, axe_sounds[3], volume, attn, flags, pitch)

                if(g_knife_katana[id] )

                    emit_sound(id, channel, katana_sounds[3], volume, attn, flags, pitch)

                if(g_knife_hammer[id])

                    emit_sound(id, channel, hammer_sounds[3], volume, attn, flags, pitch)

                if(g_knife_thanatos[id])

                    emit_sound(id, channel, thanatos_sounds[3], volume, attn, flags, pitch)

                if(g_knife_boss[id])

                    emit_sound(id, channel, boss_sounds[3], volume, attn, flags, pitch)


            }

            else

            {

                if(g_knife_combat[id])

                    emit_sound(id, channel, combat_sounds[random_num(1,2)], volume, attn, flags, pitch)

                if(g_knife_strong[id])

                    emit_sound(id, channel, strong_sounds[random_num(1,2)], volume, attn, flags, pitch)

                if(g_knife_axe[id])

                    emit_sound(id, channel, axe_sounds[random_num(1,2)], volume, attn, flags, pitch)

                if(g_knife_katana[id])

                    emit_sound(id, channel, katana_sounds[random_num(1,2)], volume, attn, flags, pitch)

                if(g_knife_hammer[id])

                    emit_sound(id, channel, hammer_sounds[random_num(1,2)], volume, attn, flags, pitch)

                if(g_knife_thanatos[id])

                    emit_sound(id, channel, thanatos_sounds[random_num(1,2)], volume, attn, flags, pitch)

                if(g_knife_boss[id])

                    emit_sound(id, channel, boss_sounds[random_num(1,2)], volume, attn, flags, pitch)


            }

        }

        else

        {

            if (sample[15] == 'l') 

            {

                if(g_knife_combat[id])

                    emit_sound(id, channel, combat_sounds[4], volume, attn, flags, pitch)

                if(g_knife_strong[id])

                    emit_sound(id, channel, strong_sounds[4], volume, attn, flags, pitch)

                if(g_knife_axe[id])

                    emit_sound(id, channel, axe_sounds[4], volume, attn, flags, pitch)

                if(g_knife_katana[id])

                    emit_sound(id, channel, katana_sounds[4], volume, attn, flags, pitch)

                if(g_knife_hammer[id])

                    emit_sound(id, channel, hammer_sounds[4], volume, attn, flags, pitch)

                if(g_knife_thanatos[id])

                    emit_sound(id, channel, thanatos_sounds[4], volume, attn, flags, pitch)

                if(g_knife_boss[id])

                    emit_sound(id, channel, boss_sounds[4], volume, attn, flags, pitch)

            }

            else 

            {

                if(g_knife_combat[id])

                    emit_sound(id, channel, combat_sounds[5], volume, attn, flags, pitch)

                if(g_knife_strong[id] )

                    emit_sound(id, channel, strong_sounds[5], volume, attn, flags, pitch)

                if(g_knife_axe[id] )

                    emit_sound(id, channel, axe_sounds[5], volume, attn, flags, pitch)

                if(g_knife_katana[id])

                    emit_sound(id, channel, katana_sounds[5], volume, attn, flags, pitch)

                if(g_knife_hammer[id])

                    emit_sound(id, channel, hammer_sounds[5], volume, attn, flags, pitch)

                if(g_knife_thanatos[id])

                    emit_sound(id, channel, thanatos_sounds[5], volume, attn, flags, pitch)

                if(g_knife_boss[id])

                    emit_sound(id, channel, boss_sounds[5], volume, attn, flags, pitch)


            }

        }

        return HAM_SUPERCEDE

    }

    return HAM_IGNORED

}



public message_DeathMsg(msg_id, msg_dest, id)

{

	static szTruncatedWeapon[33], iattacker, ivictim

	

	get_msg_arg_string(4, szTruncatedWeapon, charsmax(szTruncatedWeapon))

	

	iattacker = get_msg_arg_int(1)

	ivictim = get_msg_arg_int(2)

	

	if(!is_user_connected(iattacker) || iattacker == ivictim)

	{

		if(equal(szTruncatedWeapon, "knife") && get_user_weapon(iattacker) == CSW_KNIFE)

		{

			if(g_knife_combat[iattacker])

				set_msg_arg_string(4, "Combat knife")

		}

	

		if(equal(szTruncatedWeapon, "knife") && get_user_weapon(iattacker) == CSW_KNIFE)

		{

			if(g_knife_strong[iattacker])

				set_msg_arg_string(4, "Strong knife")

		}



		if(equal(szTruncatedWeapon, "knife") && get_user_weapon(iattacker) == CSW_KNIFE)

		{

			if(g_knife_axe[iattacker])

				set_msg_arg_string(4, "Axe knife")

		}



		if(equal(szTruncatedWeapon, "knife") && get_user_weapon(iattacker) == CSW_KNIFE)

		{

			if(g_knife_katana[iattacker])

				set_msg_arg_string(4, "Katana knife")

		}



		if(equal(szTruncatedWeapon, "knife") && get_user_weapon(iattacker) == CSW_KNIFE)

		{

			if(g_knife_hammer[iattacker])

				set_msg_arg_string(4, "Ice knife")

		}

		if(equal(szTruncatedWeapon, "knife") && get_user_weapon(iattacker) == CSW_KNIFE)

		{

			if(g_knife_thanatos[iattacker])

				set_msg_arg_string(4, "Scythe knife")

		}

                if(equal(szTruncatedWeapon, "knife") && get_user_weapon(iattacker) == CSW_KNIFE)

		{

			if(g_knife_boss[iattacker])

				set_msg_arg_string(4, "Fire knife")

		}

	}

	return PLUGIN_CONTINUE

}



stock print_col_chat(const id, const input[], any:...)  

{  

	new count = 1, players[32];  

    	static msg[191];  

    	vformat(msg, 190, input, 3);  

    	replace_all(msg, 190, "!g", "^4"); // Green Color  

    	replace_all(msg, 190, "!y", "^1"); // Default Color 

    	replace_all(msg, 190, "!t", "^3"); // Team Color  

    	if (id) players[0] = id; else get_players(players, count, "ch");  

    	{  

        	for ( new i = 0; i < count; i++ )  

        	{  

            		if ( is_user_connected(players[i]) )  

            		{  

                		message_begin(MSG_ONE_UNRELIABLE, SayText, _, players[i]);  

                		write_byte(players[i]);  

                		write_string(msg);  

                		message_end();  

            		}  

        	}  

    	}  

}   



public fw_PlayerPreThink(id)

{

	if(!is_user_alive(id))

		return FMRES_IGNORED



	new temp[2], weapon = get_user_weapon(id, temp[0], temp[1])



	if (weapon == CSW_KNIFE && g_knife_combat[id])

	{

		g_hasSpeed[id] = true

		set_pev(id, pev_maxspeed, get_pcvar_float(cvar_knife_combat_spd))

	}



	if(weapon == CSW_KNIFE && g_knife_combat[id])        

		if ((pev(id, pev_button) & IN_JUMP) && !(pev(id, pev_oldbuttons) & IN_JUMP))

		{

			new flags = pev(id, pev_flags)

			new waterlvl = pev(id, pev_waterlevel)

			

			if (!(flags & FL_ONGROUND))

				return FMRES_IGNORED



			if (flags & FL_WATERJUMP)

				return FMRES_IGNORED



			if (waterlvl > 1)

				return FMRES_IGNORED

			

			new Float:fVelocity[3]

			pev(id, pev_velocity, fVelocity)

			

			fVelocity[2] += get_pcvar_num(cvar_knife_combat_jump)

			

			set_pev(id, pev_velocity, fVelocity)

			set_pev(id, pev_gaitsequence, 6)

		}

	if (weapon == CSW_KNIFE && g_knife_strong[id])

	{

		g_hasSpeed[id] = true

		set_pev(id, pev_maxspeed, get_pcvar_float(cvar_knife_strong_spd))



		if ((pev(id, pev_button) & IN_JUMP) && !(pev(id, pev_oldbuttons) & IN_JUMP))

		{

			new flags = pev(id, pev_flags)

			new waterlvl = pev(id, pev_waterlevel)

			

			if (!(flags & FL_ONGROUND))

				return FMRES_IGNORED



			if (flags & FL_WATERJUMP)

				return FMRES_IGNORED



			if (waterlvl > 1)

				return FMRES_IGNORED

			

			new Float:fVelocity[3]

			pev(id, pev_velocity, fVelocity)

			

			fVelocity[2] += get_pcvar_num(cvar_knife_strong_jump)

			

			set_pev(id, pev_velocity, fVelocity)

			set_pev(id, pev_gaitsequence, 6)

		}

	}

	if (weapon == CSW_KNIFE && g_knife_axe[id])

	{

		g_hasSpeed[id] = true

		set_pev(id, pev_maxspeed, get_pcvar_float(cvar_knife_axe_spd))



		if ((pev(id, pev_button) & IN_JUMP) && !(pev(id, pev_oldbuttons) & IN_JUMP))

		{

			new flags = pev(id, pev_flags)

			new waterlvl = pev(id, pev_waterlevel)

			

			if (!(flags & FL_ONGROUND))

				return FMRES_IGNORED



			if (flags & FL_WATERJUMP)

				return FMRES_IGNORED



			if (waterlvl > 1)

				return FMRES_IGNORED

			

			new Float:fVelocity[3]

			pev(id, pev_velocity, fVelocity)

			

			fVelocity[2] += get_pcvar_num(cvar_knife_axe_jump)

			

			set_pev(id, pev_velocity, fVelocity)

			set_pev(id, pev_gaitsequence, 6)

		}

	}

	if (weapon == CSW_KNIFE && g_knife_katana[id])

	{

		g_hasSpeed[id] = true

		set_pev(id, pev_maxspeed, get_pcvar_float(cvar_knife_katana_spd))



		if ((pev(id, pev_button) & IN_JUMP) && !(pev(id, pev_oldbuttons) & IN_JUMP))

		{

			new flags = pev(id, pev_flags)

			new waterlvl = pev(id, pev_waterlevel)

			

			if (!(flags & FL_ONGROUND))

				return FMRES_IGNORED



			if (flags & FL_WATERJUMP)

				return FMRES_IGNORED



			if (waterlvl > 1)

				return FMRES_IGNORED

			

			new Float:fVelocity[3]

			pev(id, pev_velocity, fVelocity)

			

			fVelocity[2] += get_pcvar_num(cvar_knife_katana_jump)

			

			set_pev(id, pev_velocity, fVelocity)

			set_pev(id, pev_gaitsequence, 6)

		}

	}

	if (weapon == CSW_KNIFE && g_knife_hammer[id])

	{

		g_hasSpeed[id] = true

		set_pev(id, pev_maxspeed, get_pcvar_float(cvar_knife_hammer_spd))



		if ((pev(id, pev_button) & IN_JUMP) && !(pev(id, pev_oldbuttons) & IN_JUMP))

		{

			new flags = pev(id, pev_flags)

			new waterlvl = pev(id, pev_waterlevel)

			

			if (!(flags & FL_ONGROUND))

				return FMRES_IGNORED



			if (flags & FL_WATERJUMP)

				return FMRES_IGNORED



			if (waterlvl > 1)

				return FMRES_IGNORED

			

			new Float:fVelocity[3]

			pev(id, pev_velocity, fVelocity)

			

			fVelocity[2] += get_pcvar_num(cvar_knife_hammer_jump)

			

			set_pev(id, pev_velocity, fVelocity)

			set_pev(id, pev_gaitsequence, 6)

		}

	}

	if (weapon == CSW_KNIFE && g_knife_thanatos[id])

	{

		g_hasSpeed[id] = true

		set_pev(id, pev_maxspeed, get_pcvar_float(cvar_knife_thanatos_spd))



		if ((pev(id, pev_button) & IN_JUMP) && !(pev(id, pev_oldbuttons) & IN_JUMP))

		{

			new flags = pev(id, pev_flags)

			new waterlvl = pev(id, pev_waterlevel)

			

			if (!(flags & FL_ONGROUND))

				return FMRES_IGNORED



			if (flags & FL_WATERJUMP)

				return FMRES_IGNORED



			if (waterlvl > 1)

				return FMRES_IGNORED

			

			new Float:fVelocity[3]

			pev(id, pev_velocity, fVelocity)

			

			fVelocity[2] += get_pcvar_num(cvar_knife_thanatos_jump)

			

			set_pev(id, pev_velocity, fVelocity)

			set_pev(id, pev_gaitsequence, 6)

		}

	}


        if (weapon == CSW_KNIFE && g_knife_boss[id])

	{

		g_hasSpeed[id] = true

		set_pev(id, pev_maxspeed, get_pcvar_float(cvar_knife_boss_spd))



		if ((pev(id, pev_button) & IN_JUMP) && !(pev(id, pev_oldbuttons) & IN_JUMP))

		{

			new flags = pev(id, pev_flags)

			new waterlvl = pev(id, pev_waterlevel)

			

			if (!(flags & FL_ONGROUND))

				return FMRES_IGNORED



			if (flags & FL_WATERJUMP)

				return FMRES_IGNORED



			if (waterlvl > 1)

				return FMRES_IGNORED

			

			new Float:fVelocity[3]

			pev(id, pev_velocity, fVelocity)

			

			fVelocity[2] += get_pcvar_num(cvar_knife_boss_jump)

			

			set_pev(id, pev_velocity, fVelocity)

			set_pev(id, pev_gaitsequence, 6)

		}

	}

	return FMRES_IGNORED

}  



public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)

{

	if(!is_user_connected(attacker))

		return HAM_IGNORED



	new weapon = get_user_weapon(attacker)



	if (weapon == CSW_KNIFE && g_knife_combat[attacker])

	{	

		SetHamParamFloat(4, damage * get_pcvar_float(cvar_knife_combat_dmg))

	}

	if (weapon == CSW_KNIFE && g_knife_strong[attacker])

	{	

		SetHamParamFloat(4, damage * get_pcvar_float(cvar_knife_strong_dmg))

	}

	if (weapon == CSW_KNIFE && g_knife_axe[attacker])

	{	

		SetHamParamFloat(4, damage * get_pcvar_float(cvar_knife_axe_dmg))

	}

	if (weapon == CSW_KNIFE && g_knife_katana[attacker])

	{	

		SetHamParamFloat(4, damage * get_pcvar_float(cvar_knife_katana_dmg))

	}

		

	if (weapon == CSW_KNIFE && g_knife_hammer[attacker])

	{	 

		SetHamParamFloat(4, damage * get_pcvar_float(cvar_knife_hammer_dmg))

	}

	

	if (weapon == CSW_KNIFE && g_knife_thanatos[attacker])

	{	 

		SetHamParamFloat(4, damage * get_pcvar_float(cvar_knife_thanatos_dmg))

	}


        if (weapon == CSW_KNIFE && g_knife_boss[attacker])

	{	 

		SetHamParamFloat(4, damage * get_pcvar_float(cvar_knife_boss_dmg))

	}

        if (weapon == CSW_KNIFE && g_knife_combat[attacker])
	{
		if(!task_exists(victim + 100))
		{
			g_burning1[victim] += 5
			
			set_task(0.1, "Burning1", victim + 100, _, _, "b")
		}
	}


	if (weapon == CSW_KNIFE && g_knife_strong[attacker])
	{
		if(!task_exists(victim + 100))
		{
			g_burning2[victim] += 6
			
			set_task(0.1, "Burning2", victim + 100, _, _, "b")
		}
	}

        
        if (weapon == CSW_KNIFE && g_knife_axe[attacker])
	{
		if(!task_exists(victim + 100))
		{
			g_burning3[victim] += 4
			
			set_task(0.1, "Burning3", victim + 100, _, _, "b")
		}
	}


	if (weapon == CSW_KNIFE && g_knife_katana[attacker])
	{
		if(!task_exists(victim + 100))
		{
			g_burning4[victim] += 7
			
			set_task(0.1, "Burning4", victim + 100, _, _, "b")
		}
	}


        if (weapon == CSW_KNIFE && g_knife_hammer[attacker])
	{
		if(!task_exists(victim + 100))
		{
			g_burning5[victim] += 8
			
			set_task(0.1, "Burning5", victim + 100, _, _, "b")
		}
	}


	if (weapon == CSW_KNIFE && g_knife_thanatos[attacker])
	{
		if(!task_exists(victim + 100))
		{
			g_burning6[victim] += 9
			
			set_task(0.1, "Burning6", victim + 100, _, _, "b")
		}
	}


        if (weapon == CSW_KNIFE && g_knife_boss[attacker])
	{
		if(!task_exists(victim + 100))
		{
			g_burning7[victim] += 11
			
			set_task(0.1, "Burning7", victim + 100, _, _, "b")
		}
	}


	return HAM_IGNORED

}



public fw_Knife_SecondaryAttack_Post(knife) 

{     

    	static id 

    	id = get_pdata_cbase(knife, m_pPlayer, 4) 
    

    	if(is_user_connected(id) && g_knife_combat[id]) 

    	{ 

        	static Float:flRate 

        	flRate = get_pcvar_float(cvar_knife_combat_spd_attack2) 

         

        	set_pdata_float(knife, m_flNextPrimaryAttack, flRate, 4) 

        	set_pdata_float(knife, m_flNextSecondaryAttack, flRate, 4) 

        	set_pdata_float(knife, m_flTimeWeaponIdle, flRate, 4) 

    	} 

 

    	if(is_user_connected(id) && g_knife_strong[id]) 

    	{ 

        	static Float:flRate 

        	flRate = get_pcvar_float(cvar_knife_strong_spd_attack2) 

        	 

        	set_pdata_float(knife, m_flNextPrimaryAttack, flRate, 4) 

        	set_pdata_float(knife, m_flNextSecondaryAttack, flRate, 4) 

        	set_pdata_float(knife, m_flTimeWeaponIdle, flRate, 4) 

    	} 



    	if(is_user_connected(id) && g_knife_axe[id]) 

    	{ 

        	static Float:flRate 

        	flRate = get_pcvar_float(cvar_knife_axe_spd_attack2) 

        		 

        	set_pdata_float(knife, m_flNextPrimaryAttack, flRate, 4) 

        	set_pdata_float(knife, m_flNextSecondaryAttack, flRate, 4) 

        	set_pdata_float(knife, m_flTimeWeaponIdle, flRate, 4) 

    	} 



    	if(is_user_connected(id) && g_knife_katana[id]) 

    	{ 

        	static Float:flRate 

        	flRate = get_pcvar_float(cvar_knife_katana_spd_attack2) 

        		 

        	set_pdata_float(knife, m_flNextPrimaryAttack, flRate, 4) 

        	set_pdata_float(knife, m_flNextSecondaryAttack, flRate, 4) 

        	set_pdata_float(knife, m_flTimeWeaponIdle, flRate, 4) 

    	} 



    	if(is_user_connected(id) && g_knife_hammer[id]) 

    	{ 

        	static Float:flRate 

        	flRate = get_pcvar_float(cvar_hammer_spd_attack2) 

        	 

        	set_pdata_float(knife, m_flNextPrimaryAttack, flRate, 4) 

        	set_pdata_float(knife, m_flNextSecondaryAttack, flRate, 4) 

        	set_pdata_float(knife, m_flTimeWeaponIdle, flRate, 4) 

    	} 	

	

	if(is_user_connected(id) && g_knife_thanatos[id]) 

    	{ 

        	static Float:flRate 

        	flRate = get_pcvar_float(cvar_thanatos_spd_attack2) 

        	 

        	set_pdata_float(knife, m_flNextPrimaryAttack, flRate, 4) 

        	set_pdata_float(knife, m_flNextSecondaryAttack, flRate, 4) 

        	set_pdata_float(knife, m_flTimeWeaponIdle, flRate, 4) 

    	} 	


        if(is_user_connected(id) && g_knife_boss[id]) 

    	{ 

        	static Float:flRate 

        	flRate = get_pcvar_float(cvar_boss_spd_attack2) 

        	 

        	set_pdata_float(knife, m_flNextPrimaryAttack, flRate, 4) 

        	set_pdata_float(knife, m_flNextSecondaryAttack, flRate, 4) 

        	set_pdata_float(knife, m_flTimeWeaponIdle, flRate, 4) 

    	} 	

      return HAM_IGNORED 

} 



public Burning1(taskid)

{

	static origin[3], flags

	get_user_origin(ID_FBURN1, origin)

	flags = pev(ID_FBURN1, pev_flags)

	if ((flags & FL_INWATER) || g_burning1[ID_FBURN1] < 1 || !is_user_alive(ID_FBURN1))

	{

		remove_task(taskid)

		return

	}

	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)

	write_byte(TE_SPRITE)

	write_coord(origin[0]+random_num(-5, 5))

	write_coord(origin[1]+random_num(-5, 5))

	write_coord(origin[2]+random_num(-10, 10))

	write_short(g_sprite1)

	write_byte(2) 

	write_byte(200)

	message_end()
	

	g_burning1[ID_FBURN1]--

}



public Burning2(taskid)

{

	static origin[3], flags

	get_user_origin(ID_FBURN2, origin)

	flags = pev(ID_FBURN2, pev_flags)

	if ((flags & FL_INWATER) || g_burning2[ID_FBURN2] < 1 || !is_user_alive(ID_FBURN2))

	{

		remove_task(taskid)

		return

	}

	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)

	write_byte(TE_SPRITE)

	write_coord(origin[0]+random_num(-5, 5))

	write_coord(origin[1]+random_num(-5, 5))

	write_coord(origin[2]+random_num(-10, 10))

	write_short(g_sprite2)

	write_byte(2) 

	write_byte(200)

	message_end()
	

	g_burning2[ID_FBURN2]--

}



public Burning3(taskid)

{

	static origin[3], flags

	get_user_origin(ID_FBURN3, origin)

	flags = pev(ID_FBURN3, pev_flags)

	if ((flags & FL_INWATER) || g_burning3[ID_FBURN3] < 1 || !is_user_alive(ID_FBURN3))

	{

		remove_task(taskid)

		return

	}

	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)

	write_byte(TE_SPRITE)

	write_coord(origin[0]+random_num(-5, 5))

	write_coord(origin[1]+random_num(-5, 5))

	write_coord(origin[2]+random_num(-10, 10))

	write_short(g_sprite3)

	write_byte(2) 

	write_byte(200)

	message_end()
	

	g_burning3[ID_FBURN3]--

}



public Burning4(taskid)

{

	static origin[3], flags

	get_user_origin(ID_FBURN4, origin)

	flags = pev(ID_FBURN1, pev_flags)

	if ((flags & FL_INWATER) || g_burning4[ID_FBURN4] < 1 || !is_user_alive(ID_FBURN4))

	{

		remove_task(taskid)

		return

	}

	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)

	write_byte(TE_SPRITE)

	write_coord(origin[0]+random_num(-5, 5))

	write_coord(origin[1]+random_num(-5, 5))

	write_coord(origin[2]+random_num(-10, 10))

	write_short(g_sprite4)

	write_byte(2) 

	write_byte(200)

	message_end()
	

	g_burning4[ID_FBURN1]--

}



public Burning5(taskid)

{

	static origin[3], flags

	get_user_origin(ID_FBURN5, origin)

	flags = pev(ID_FBURN5, pev_flags)

	if ((flags & FL_INWATER) || g_burning5[ID_FBURN5] < 1 || !is_user_alive(ID_FBURN5))

	{

		remove_task(taskid)

		return

	}

	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)

	write_byte(TE_SPRITE)

	write_coord(origin[0]+random_num(-5, 5))

	write_coord(origin[1]+random_num(-5, 5))

	write_coord(origin[2]+random_num(-10, 10))

	write_short(g_sprite5)

	write_byte(2) 

	write_byte(200)

	message_end()
	

	g_burning5[ID_FBURN5]--


}



public Burning6(taskid)

{

	static origin[3], flags

	get_user_origin(ID_FBURN6, origin)

	flags = pev(ID_FBURN6, pev_flags)

	if ((flags & FL_INWATER) || g_burning6[ID_FBURN6] < 1 || !is_user_alive(ID_FBURN6))

	{

		remove_task(taskid)

		return

	}

	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)

	write_byte(TE_SPRITE)

	write_coord(origin[0]+random_num(-5, 5))

	write_coord(origin[1]+random_num(-5, 5))

	write_coord(origin[2]+random_num(-10, 10))

	write_short(g_sprite6)

	write_byte(2) 

	write_byte(200)

	message_end()
	

	g_burning6[ID_FBURN6]--

}


public Burning7(taskid)

{

	static origin[3], flags

	get_user_origin(ID_FBURN7, origin)

	flags = pev(ID_FBURN7, pev_flags)

	if ((flags & FL_INWATER) || g_burning7[ID_FBURN7] < 1 || !is_user_alive(ID_FBURN7))

	{

		remove_task(taskid)

		return

	}

	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)

	write_byte(TE_SPRITE)

	write_coord(origin[0]+random_num(-5, 5))

	write_coord(origin[1]+random_num(-5, 5))

	write_coord(origin[2]+random_num(-10, 10))

	write_short(g_sprite7)

	write_byte(2) 

	write_byte(200)

	message_end()
	
	g_burning7[ID_FBURN7]--
}


public event_Damage(id)

{

	new weapon , attacker = get_user_attacker(id , weapon);



	if(!is_user_alive(attacker))

		return PLUGIN_CONTINUE;



	if(weapon == CSW_KNIFE && g_knife_combat[attacker])

	{

		new Float:vec[3];

		new Float:oldvelo[3];

		get_user_velocity(id, oldvelo);

		create_velocity_vector(id , attacker , vec);

		vec[0] += oldvelo[0];

		vec[1] += oldvelo[1];

		set_user_velocity(id , vec);

	}



	if(weapon == CSW_KNIFE && g_knife_strong[attacker])

	{

		new Float:vec[3];

		new Float:oldvelo[3];

		get_user_velocity(id, oldvelo);

		create_velocity_vector(id , attacker , vec);

		vec[0] += oldvelo[0];

		vec[1] += oldvelo[1];

		set_user_velocity(id , vec);

	}



	if(weapon == CSW_KNIFE && g_knife_axe[attacker])

	{

		new Float:vec[3];

		new Float:oldvelo[3];

		get_user_velocity(id, oldvelo);

		create_velocity_vector(id , attacker , vec);

		vec[0] += oldvelo[0];

		vec[1] += oldvelo[1];

		set_user_velocity(id , vec);

	}



	if(weapon == CSW_KNIFE && g_knife_katana[attacker])

	{

		new Float:vec[3];

		new Float:oldvelo[3];

		get_user_velocity(id, oldvelo);

		create_velocity_vector(id , attacker , vec);

		vec[0] += oldvelo[0];

		vec[1] += oldvelo[1];

		set_user_velocity(id , vec);

	}



	if(weapon == CSW_KNIFE && g_knife_hammer[attacker])

	{

		new Float:vec[3];

		new Float:oldvelo[3];

		get_user_velocity(id, oldvelo);

		create_velocity_vector(id , attacker , vec);

		vec[0] += oldvelo[0];

		vec[1] += oldvelo[1];

		set_user_velocity(id , vec);

	}

	

	if(weapon == CSW_KNIFE && g_knife_thanatos[attacker])

	{

		new Float:vec[3];

		new Float:oldvelo[3];

		get_user_velocity(id, oldvelo);

		create_velocity_vector(id , attacker , vec);

		vec[0] += oldvelo[0];

		vec[1] += oldvelo[1];

		set_user_velocity(id , vec);

	}


        if(weapon == CSW_KNIFE && g_knife_boss[attacker])

	{

		new Float:vec[3];

		new Float:oldvelo[3];

		get_user_velocity(id, oldvelo);

		create_velocity_vector(id , attacker , vec);

		vec[0] += oldvelo[0];

		vec[1] += oldvelo[1];

		set_user_velocity(id , vec);

	}

	return PLUGIN_CONTINUE;

}


stock create_velocity_vector(victim,attacker,Float:velocity[3])

{

	if(!is_user_alive(attacker))

		return 0;



	new Float:vicorigin[3];

	new Float:attorigin[3];

	entity_get_vector(victim   , EV_VEC_origin , vicorigin);

	entity_get_vector(attacker , EV_VEC_origin , attorigin);



	new Float:origin2[3]

	origin2[0] = vicorigin[0] - attorigin[0];

	origin2[1] = vicorigin[1] - attorigin[1];



	new Float:largestnum = 0.0;



	if(floatabs(origin2[0])>largestnum) largestnum = floatabs(origin2[0]);

	if(floatabs(origin2[1])>largestnum) largestnum = floatabs(origin2[1]);



	origin2[0] /= largestnum;

	origin2[1] /= largestnum;



	if (g_knife_combat[attacker])

	{

		velocity[0] = ( origin2[0] * (get_pcvar_float(cvar_knife_combat_knock) * 3000) ) / get_entity_distance(victim , attacker);

		velocity[1] = ( origin2[1] * (get_pcvar_float(cvar_knife_combat_knock) * 3000) ) / get_entity_distance(victim , attacker);

	}



	if (g_knife_strong[attacker])

	{

		velocity[0] = ( origin2[0] * (get_pcvar_float(cvar_knife_strong_knock) * 3000) ) / get_entity_distance(victim , attacker);

		velocity[1] = ( origin2[1] * (get_pcvar_float(cvar_knife_strong_knock) * 3000) ) / get_entity_distance(victim , attacker);

	}



	if (g_knife_axe[attacker])

	{

		velocity[0] = ( origin2[0] * (get_pcvar_float(cvar_knife_axe_knock) * 3000) ) / get_entity_distance(victim , attacker);

		velocity[1] = ( origin2[1] * (get_pcvar_float(cvar_knife_axe_knock) * 3000) ) / get_entity_distance(victim , attacker);

	}



	if (g_knife_katana[attacker])

	{

		velocity[0] = ( origin2[0] * (get_pcvar_float(cvar_knife_katana_knock) * 3000) ) / get_entity_distance(victim , attacker);

		velocity[1] = ( origin2[1] * (get_pcvar_float(cvar_knife_katana_knock) * 3000) ) / get_entity_distance(victim , attacker);

	}



	if (g_knife_hammer[attacker])

	{

		velocity[0] = ( origin2[0] * (get_pcvar_float(cvar_knife_hammer_knock) * 3000) ) / get_entity_distance(victim , attacker);

		velocity[1] = ( origin2[1] * (get_pcvar_float(cvar_knife_hammer_knock) * 3000) ) / get_entity_distance(victim , attacker);

	}



	if (g_knife_thanatos[attacker])

	{

		velocity[0] = ( origin2[0] * (get_pcvar_float(cvar_knife_thanatos_knock) * 3000) ) / get_entity_distance(victim , attacker);

		velocity[1] = ( origin2[1] * (get_pcvar_float(cvar_knife_thanatos_knock) * 3000) ) / get_entity_distance(victim , attacker);

	}


        if (g_knife_boss[attacker])

	{

		velocity[0] = ( origin2[0] * (get_pcvar_float(cvar_knife_boss_knock) * 3000) ) / get_entity_distance(victim , attacker);

		velocity[1] = ( origin2[1] * (get_pcvar_float(cvar_knife_boss_knock) * 3000) ) / get_entity_distance(victim , attacker);

	}

	if(velocity[0] <= 20.0 || velocity[1] <= 20.0)

		velocity[2] = random_float(200.0 , 275.0);



	return 1;

}



public client_putinserver(id)

{

	switch(random_num(0, 0))

	{

		case 0:

		{

			g_knife_combat[id] = true

			g_hasSpeed[id] = true

		}



	}

}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
