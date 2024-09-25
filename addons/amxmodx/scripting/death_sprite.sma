#include <amxmodx>
#include <fakemeta>

#define PLUGIN "Death Sprite"
#define VERSION "1.0"
#define AUTHOR "DarkGL"

#define write_coord_f(%1) engfunc(EngFunc_WriteCoord,%1)

new const szSprite[] = "sprites/skull.spr"

new pSprite;

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_event("DeathMsg", "DeathMsg", "a")
}

public plugin_precache(){
	pSprite = precache_model(szSprite)
}

public DeathMsg()
{   
	new vid = read_data(2)
	new kid = read_data(1)
	
	if(!is_user_connected(vid) || vid == kid || !is_user_connected(kid))	 return ;
	
	new Float:fOrigin[3];
	pev(vid,pev_origin,fOrigin);
	
	fOrigin[2] += 35.0;
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY )
	write_byte(TE_SPRITE)
	write_coord_f(fOrigin[0])
	write_coord_f(fOrigin[1])
	write_coord_f(fOrigin[2])
	write_short(pSprite) 
	write_byte(10) 
	write_byte(255)
	message_end()
	
}
