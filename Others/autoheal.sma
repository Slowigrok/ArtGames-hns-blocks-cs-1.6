native pm_level_autohealth(id)

#include <amxmodx>
#include <fakemeta>

// Copyright
#define PLUGIN "HP Autoheal"
#define VERSION "1.4"
#define AUTHOR "-"

// Defines
#define TASKID 100
#define SOUND1 "misc/hp/1.wav"

// Cvars
new hp_regtime,hp_showdmg

// Misc
new maxhp[33];
new plrHeal[33];

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar("AcidoX", "Autoheal 1.4", FCVAR_SERVER)
	register_event("Damage", "damage", "b", "2>0")
	
	register_event("ResetHUD", "ResetHUD", "abe");
	
	hp_regtime = register_cvar("hp_regtime", "0.5")
	hp_showdmg = register_cvar("hp_showdmg", "1")
}

public ResetHUD(id)
{
	if (is_user_connected(id) && is_user_alive(id))
	{	
		set_task(0.01, "MaXReGHp",id);
	}
}
public MaXReGHp(id)
{
	if(is_user_alive(id))
	{
		maxhp[id] = get_user_health(id);
	}
}
public damage(id)
{
	new dmg = read_data(2)
	
	if(read_data(4) != 0 || read_data(5) != 0 || read_data(6) != 0) return
	
	if((get_pcvar_num(hp_showdmg) == 1) && dmg < maxhp[id]) {
	new msg[32]
	formatex(msg, 31, "Damage: %i", dmg)
	set_hudmessage(255, 0, 0, 0.05, 0.9, 0, 2.0, 2.0, 0.2)
	show_hudmessage(id, msg)
}
	plrHeal[id] += dmg
	
	if(!task_exists(TASKID + id)) set_task(get_pcvar_float(hp_regtime), "tsk_heal", id + TASKID)
}


public tsk_heal(id)
{
	id -= TASKID
	
	if(plrHeal[id] == 0) return
	if(!is_user_alive(id))
	{
		plrHeal[id] = 0
		return
	}
	new hp_reg2 = pm_level_autohealth(id);
	new hp = pev(id, pev_health)
	
	plrHeal[id] > hp_reg2 ? (plrHeal[id] = hp_reg2) : 0
	
	if(hp + plrHeal[id] > maxhp[id])
	{
		plrHeal[id] = 0
		return
	}

	set_pev(id, pev_health, float(hp + plrHeal[id]))
	plrHeal[id] = 0
	
	return
}

public plugin_precache() 
{
		precache_sound(SOUND1)
}

public plugin_cfg() 
{
	new cfg[128]
	format(cfg, 127, "%s/autoheal.cfg", cfg)
	if (file_exists(cfg))
	{
		server_exec()
		server_cmd("exec %s", cfg)
	}
}

