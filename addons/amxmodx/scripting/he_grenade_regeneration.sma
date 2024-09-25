#include <amxmodx>
#include <fun>
#include <hamsandwich>
#include <csx>

#define COUNTDOWN_TIME 05
#define HUD_CHANNEL 1

new Countdown[33];

public plugin_init()
{
    register_plugin("HE Grenade Resupply", "1.1", "hleV");
    
    RegisterHam(Ham_Spawn, "player", "OnSpawn", 1);
}

public grenade_throw(id, ent, weap)
{
    if (weap != CSW_HEGRENADE)
        return;
        
    Countdown[id] = COUNTDOWN_TIME - 1;
    
    ShowHudMessage(id, "Next HE grenade in %d", COUNTDOWN_TIME);
    set_task(1.0, "OnResupply", id, _, _, "a", COUNTDOWN_TIME);
}

public OnSpawn(id)
    if (is_user_alive(id) && !user_has_weapon(id, CSW_HEGRENADE))
        give_item(id, "weapon_hegrenade");
        
public OnResupply(id)
{    
    if (!is_user_alive(id) || user_has_weapon(id, CSW_HEGRENADE))
    {
        remove_task(id);
        
        return;
    }
    
    if (Countdown[id])
        ShowHudMessage(id, "Next HE grenade in %d", Countdown[id]--);
    else
    {
        give_item(id, "weapon_hegrenade");
        ShowHudMessage(id, "Enjoy your grenade!");
    }
}
        
ShowHudMessage(id, const text[], countdown = 0)
{
    set_hudmessage(255, 255, 255, 0.10, 0.25, _, _, 1.1, 0.0, 0.0, HUD_CHANNEL);
    
    countdown ? show_hudmessage(id, text, countdown) : show_hudmessage(id, text);
} 