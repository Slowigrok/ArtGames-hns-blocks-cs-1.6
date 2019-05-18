native pm_add_user_point(id, xvar);

#include <amxmodx>
#include <fakemeta>
#include <cstrike>

#define PLUGIN_VERSION "1.4"

// JUMPING
#define MINIMUM_FALL_SPEED 300
#define MAXIMUM_DAMAGE_FROM_JUMP 70.0

//STANDING
#define DAMAGE 5.0
#define DELAY 0.1

new amx_headsplash;
new Float:falling_speed[33];
new Float:damage_after[33][33];
new sprite_blood;
new sprite_bloodspray;

public plugin_init()
{
	register_plugin("Head Splash", PLUGIN_VERSION, "potatis_invalido"); // Register the plugin.
	amx_headsplash = register_cvar("amx_headsplash", "1"); // Register the on/off cvar.
	register_forward(FM_Touch, "forward_touch"); // Register the "touch" forward.
	register_forward(FM_PlayerPreThink, "forward_PlayerPreThink"); // TY Alka!
}

public plugin_precache()
{
	sprite_blood = precache_model("sprites/blood.spr");
	sprite_bloodspray = precache_model("sprites/bloodspray.spr");
}

public forward_touch(toucher, touched) // This function is called every time a player touches another player.
{
	// NOTE: The toucher is the player standing/falling on top of the other (touched) player's head.
	if(!is_user_alive(toucher) || !is_user_alive(touched)) // The touching players can't be dead.
		return;
	
	if(!get_pcvar_num(amx_headsplash)) // If the plugin is disabled, stop messing with things.
		return;
	
	if(falling_speed[touched]) // Check if the touched player is falling. If he/she is, don't continue.
		return;
	
	if(get_user_team(toucher) == get_user_team(touched) && !get_cvar_num("mp_friendlyfire")) // If the touchers are in the same team and friendly fire is off, don't continue.
		return;
	
	new touched_origin[3], toucher_origin[3];
	get_user_origin(touched, touched_origin); // Get the origins of the players so it's possible to check if the toucher is standing on the touched's head.
	get_user_origin(toucher, toucher_origin);
	
	new Float:toucher_minsize[3], Float:touched_minsize[3];
	pev(toucher,pev_mins,toucher_minsize);
	pev(touched,pev_mins,touched_minsize); // If touche*_minsize is equal to -18.0, touche* is crouching.
	
	if(touched_minsize[2] != -18.0) // If the touched player IS NOT crouching, check if the toucher is on his/her head.
	{
		if(!(toucher_origin[2] == touched_origin[2]+72 && toucher_minsize[2] != -18.0) && !(toucher_origin[2] == touched_origin[2]+54 && toucher_minsize[2] == -18.0))
		{
			return;
		}
	}
	else // If the touched player is crouching, check if the toucher is on his/her head
	{
		if(!(toucher_origin[2] == touched_origin[2]+68 && toucher_minsize[2] != -18.0) && !(toucher_origin[2] == touched_origin[2]+50 && toucher_minsize[2] == -18.0))
		{
			return;
		}
	}
	
	if(falling_speed[toucher] >= MINIMUM_FALL_SPEED) // If the toucher is falling in the required speed or faster, then landing on top of the touched's head, do some damage to the touched. MUHAHAHAHAHA!!!
	{
		new Float:damage = ((falling_speed[toucher] - MINIMUM_FALL_SPEED + 30) * (falling_speed[toucher] - MINIMUM_FALL_SPEED + 30)) / 1300;
		if(damage > MAXIMUM_DAMAGE_FROM_JUMP) // Make shure that the touched player don't take too much damage.
			damage = MAXIMUM_DAMAGE_FROM_JUMP;
		damage_player(touched, toucher, damage); // Damage or kill the touched player.
		damage_after[toucher][touched] = 0.0; // Reset.
	}
	if(is_user_alive(touched) && damage_after[toucher][touched] <= get_gametime()) // This makes shure that you won't get damaged every frame you have some one on your head. It also makes shure that players won't get damaged faster on fast servers than laggy servers.
	{
		damage_after[toucher][touched] = get_gametime() + DELAY;
		damage_player(touched, toucher, DAMAGE); // Damage or kill the touched player.
	}
}

public forward_PlayerPreThink(id) // This is called every time before a player "thinks". A player thinks many times per second.
{
	//falling_speed[id] = entity_get_float(id, EV_FL_flFallVelocity); // Store the falling speed of the soon to be "thinking" player.
	pev(id, pev_flFallVelocity, falling_speed[id])
}

public damage_player(pwned, pwnzor, Float:damage) // Damages or kills a player. Home made HAX
{
	new health = get_user_health(pwned);
	if(get_user_team(pwned) == get_user_team(pwnzor)) // If both players are in the same team, reduce the damage.
		damage /= 1.4;
	new CsArmorType:armortype;
	cs_get_user_armor(pwned, armortype);
	if(armortype == CS_ARMOR_VESTHELM)
		damage *= 0.7;
	if(health >  damage)
	{
		new pwned_origin[3];
		get_user_origin(pwned, pwned_origin);
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY); // BLOOOOOOOOOOOD!!
		write_byte(TE_BLOODSPRITE);
		write_coord(pwned_origin[0]+8);
		write_coord(pwned_origin[1]);
		write_coord(pwned_origin[2]+26);
		write_short(sprite_bloodspray);
		write_short(sprite_blood);
		write_byte(248);
		write_byte(4);
		message_end();
		
		new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "trigger_hurt"));
		if(!ent)
			return;
		new value[16];
		float_to_str(damage * 2, value, sizeof value - 1);
		set_kvd(0, KV_ClassName, "trigger_hurt");
		set_kvd(0, KV_KeyName, "dmg");
		set_kvd(0, KV_Value, value);
		set_kvd(0, KV_fHandled, 0);
		dllfunc(DLLFunc_KeyValue, ent, 0);
		num_to_str(DMG_GENERIC, value, sizeof value - 1);
		set_kvd(0, KV_ClassName, "trigger_hurt");
		set_kvd(0, KV_KeyName, "damagetype");
		set_kvd(0, KV_Value, value);
		set_kvd(0, KV_fHandled, 0);
		dllfunc(DLLFunc_KeyValue, ent, 0);
		set_kvd(0, KV_ClassName, "trigger_hurt");
		set_kvd(0, KV_KeyName, "origin");
		set_kvd(0, KV_Value, "8192 8192 8192");
		set_kvd(0, KV_fHandled, 0);
		dllfunc(DLLFunc_KeyValue, ent, 0);
		dllfunc(DLLFunc_Spawn, ent);
		set_pev(ent, pev_classname, "head_splash");
		dllfunc(DLLFunc_Touch, ent, pwned);
		engfunc(EngFunc_RemoveEntity, ent);
	}
	else
	{
		new pwned_origin[3];
		get_user_origin(pwned, pwned_origin);
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY); // BLOOOOOOOOOOOD!!
		write_byte(TE_BLOODSPRITE);
		write_coord(pwned_origin[0]+8);
		write_coord(pwned_origin[1]);
		write_coord(pwned_origin[2]+26);
		write_short(sprite_bloodspray);
		write_short(sprite_blood);
		write_byte(248);
		write_byte(12);
		message_end();
		
		set_pev(pwned, pev_frags, float(get_user_frags(pwned) + 1));
		user_silentkill(pwned);
		make_deathmsg(pwnzor, pwned, 1, "his/her feet :)");
		if(get_user_team(pwnzor) != get_user_team(pwned)) // If it was a team kill, the pwnzor's money should get reduced instead of increased.
		{
			set_pev(pwnzor, pev_frags, float(get_user_frags(pwnzor) + 1));
			cs_set_user_money(pwnzor, cs_get_user_money(pwnzor) + 300);
			
			new xvar = 7;
			pm_add_user_point(pwnzor, xvar);
		}
		else
		{
			set_pev(pwnzor, pev_frags, float(get_user_frags(pwnzor) - 1));
			cs_set_user_money(pwnzor, cs_get_user_money(pwnzor) - 300);
		}
		
		message_begin(MSG_ALL, get_user_msgid("ScoreInfo")); // Fixes the scoreboard.
		write_byte(pwnzor);
		write_short(get_user_frags(pwnzor));
		write_short(cs_get_user_deaths(pwnzor));
		write_short(0);
		write_short(get_user_team(pwnzor));
		message_end();
		
		message_begin(MSG_ALL, get_user_msgid("ScoreInfo"));
		write_byte(pwned);
		write_short(get_user_frags(pwned));
		write_short(cs_get_user_deaths(pwned));
		write_short(0);
		write_short(get_user_team(pwned));
		message_end();
		set_pev(pwned, pev_frags, float(get_user_frags(pwned) - 1));
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
