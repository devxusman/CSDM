#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#define DMG_GRENADE      (1 << 24)

new NoDamage;
new NoKill;


public plugin_init()
{
    register_plugin("No Grenade Self-Kill/Damage", "1.0", "Dores");
    
    NoDamage = register_cvar("amx_no_self_nade_damage", "1");
    NoKill = register_cvar("amx_no_self_nade_kill", "1");
    
    RegisterHam(Ham_TakeDamage, "player", "PrePlayerDamaged");
}

public PrePlayerDamaged(id, inflictor, attacker, Float:damage, damagebit)
{
    static noDamage;
    static noKill;
    if (     !inflictor
    ||      id != attacker
    ||      !(damagebit & DMG_GRENADE)
    ||      ( !(noDamage = get_pcvar_num(NoDamage)) && !(noKill = get_pcvar_num(NoKill)) )      )
        return;
    
    if (noDamage)
        SetHamParamFloat(4, 0.0);
    
    else if (noKill)
    {
        static Float:health;
        pev(id, pev_health, health);
        
        // the damage passed through this forward isn't accurate, but o well...
        if (health <= damage)
        {
            SetHamParamFloat(4, 0.0);
            set_pev(id, pev_health, 1.0);
        }
    }
} 