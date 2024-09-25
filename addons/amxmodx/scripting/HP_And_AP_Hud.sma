#include <amxmodx>
#include <engine>
#include <dhudmessage>

enum UserStats
{
	USER_HP = 0,
	USER_AP
}

new bool:g_b_user_hp_hud_blink[33], g_i_user_cache_stats[33][UserStats]
public plugin_init() {
	register_plugin("Real-Like HP/AP HUD", "2.4", "VeCo")
	
	register_event("Health","Event_Health","b")
	register_event("Battery","Event_Battery","b")
	
	new ent = create_entity("info_target")
	entity_set_string(ent,EV_SZ_classname,"env_hud")
	entity_set_float(ent,EV_FL_nextthink,get_gametime() + 0.5)
	
	register_think("env_hud","env_hud_think")
}

public Event_Health(id) g_i_user_cache_stats[id][USER_HP] = get_user_health(id)
public Event_Battery(id) g_i_user_cache_stats[id][USER_AP] = get_user_armor(id)

public env_hud_think(ent)
{
	entity_set_float(ent,EV_FL_nextthink,get_gametime() + 0.5)
	
	static i_players[32],i_num, id
	get_players(i_players,i_num,"a")
	
	static i_health,i_armor
	
	for(--i_num ; i_num >= 0 ; i_num--)
	{
		id = i_players[i_num]
		
		i_health = g_i_user_cache_stats[id][USER_HP]
		i_armor = g_i_user_cache_stats[id][USER_AP]
		
		set_dhudmessage(255, 255, 255, 0.01, 0.92, 0, 0.0, 0.5, 0.0, 0.0)
		show_dhudmessage(id, "HP:           AP:")
		
		if(i_health > 30 || !g_b_user_hp_hud_blink[id])
		{
			g_b_user_hp_hud_blink[id] = true
			set_dhudmessage(255, 170, 0, 0.01, 0.92, 0, 0.0, 0.5, 0.0, 0.0)
		} else {
			if(i_health <= 10) g_b_user_hp_hud_blink[id] = false
			set_dhudmessage(255, 0, 0, 0.01, 0.92, 0, 0.0, 0.5, 0.0, 0.0)
		}
		show_dhudmessage(id, "     %i",i_health)
		
		if(i_armor > 30)
		{
			set_dhudmessage(255, 170, 0, 0.01, 0.92, 0, 0.0, 0.5, 0.0, 0.0)
		} else {
			set_dhudmessage(255, 0, 0, 0.01, 0.92, 0, 0.0, 0.5, 0.0, 0.0)
		}
		show_dhudmessage(id, "                     %i",i_armor)
	}
}
