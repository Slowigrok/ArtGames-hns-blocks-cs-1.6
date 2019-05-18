native add_user_immune( iPlayer );
native remove_user_immune( iPlayer );

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <hamsandwich>
#include <engine>
#include <fakemeta>
#include <regex>
#include <nvault_util>
#include <nvault>

new g_vault;
new g_hVault;

#pragma semicolon 1

#define PLUGIN "ArtGamesMod"
#define VERSION "1.3"
#define AUTHOR "slavok1717"
#define PREFIX "^03[^04ArtGamesMod^03]"

#define XTRA_OFS_PLAYER            5
#define m_flNextAttack            83
#define m_afButtonPressed        246
#define m_iFOV                   363

//music
#define PITCH_NORM 100
#define ATTN_NORM 0.80
#define CHAN_STREAM 5

const MAX_CLIENTS = 32;

new iDiName;
new g_first_time[32];

enum _:RankData
{
	Rank_Name[ 32 ],
	Rank_Time,
	Rank_Point
};

enum _:g_iWeapCount
{
	AWP,
	SCOUT,
	DEAGLE,
	FIVESEVEN,
	TWO_BULLETS,
	HE_GRENADE,
	SMOKE_GRENADE
};

new const g_iWeapons[g_iWeapCount][] =
{
	"Awp",
	"Scout",
	"Deagle",
	"Five-Seven",
	"Chance on 2 bullets",
	"HE Grenade",
	"Frost Grenade"
};

new const g_iFirstWCost[g_iWeapCount] =
{
	100,
	250,
	300,
	200,
	150,
	200, //Cost of first level of HE Grenade
	300 //Cost of first level of FROST grenade
};

new const g_iWeapShort[g_iWeapCount][] =
{
	"%",
	"%",
	"%",
	"%",
	"%",
	"%",
	"%"
}
;
new const g_iWeapMaxVal[g_iWeapCount] =
{
	3,
	7,
	10,
	15,
	75,
	80,
	80
};

new g_iWeapMaxLevel[g_iWeapCount] =
{
	3,
	2,
	2,
	3,
	3,
	4,
	4
};

new g_iWeapClass[g_iWeapCount] =
{
	CSW_AWP,
	CSW_SCOUT,
	CSW_DEAGLE,
	CSW_FIVESEVEN,
	CSW_FIVESEVEN,
	CSW_HEGRENADE,
	CSW_SMOKEGRENADE
};

new g_iWeapName[g_iWeapCount][] =
{
	"weapon_awp",
	"weapon_scout",
	"weapon_deagle",
	"weapon_fiveseven",
	"weapon_fiveseven",
	"weapon_hegrenade",
	"weapon_smokegrenade"
};

enum _:g_iItemCount
{
	HEALTH,
	ARMOR,
	RESPAWN_CHANCE,
	FALL_DMG_REDUCE,
	AUTO_HEALTH,
	EXTRA_DAMAGE,
	MEGA_W_SHANSE,
	LARGE_AP,
	JOKES_TIME,
	JOKES_CHANCE,
	NO_FOOTSTEPS,
	NO_FLASH,
	NO_PAIN,
	ANTI_FROSTNADE
};

new const g_iItems[g_iItemCount][] =
{
	"Extra Health",
	"Extra Armor",
	"Respawn Chance",
	"Fall Damage Reducer",
	"Auto Health",
	"Extra Damage",
	"Mega Weapon Chance",
	"Chance Large Points",
	"Extra Jokes Time",
	"Extra Jokes Chance",
	"No Footsteps",
	"No Flash",
	"No Pain Shock",
	"Anti-Frostnade"
};

new const g_iFirstCost[g_iItemCount] =
{
	250, 
	100, 
	400,
	200,
	150,
	150,
	400,
	300,
	100,
	250,
	800,
	1000,
	1500,
	2000
};

new const g_iItemShort[g_iItemCount][] =
{
	" HP",
	" AP",
	"%",
	"%",
	" HP",
	"%",
	"%",
	"%",
	"x",
	"%",
	"CT Only",
	"CT Only",
	"CT & T",
	"CT & T"
};

new const g_iItemMaxVal[g_iItemCount] =
{
	100,
	200,
	40,
	50,
	50,
	35,
	10,
	30,
	5,
	75,
	1,
	1,
	1,
	1
};

new const g_iItemMaxLevel[g_iItemCount] =
{
	5,
	5,
	4,
	5,
	5,
	5,
	2,
	3,
	5,
	3,
	1,
	1,
	1,
	1
};

enum _:g_iKnifesCount
{
	/*SWAP,
	NINJA,
	FAST,
	FLASH,
	POISON,
	PUSH,
	TITAN,
	FIRE,
	FROST,
	THUNDER,
	VAMPIRE,
	REFLECT,*/
	STANDART
};

new const g_iKnifesModel_v[g_iKnifesCount][] =
{
	/*"models/ArtGames/v1/Another/knifes/v_swap.mdl",
	"models/ArtGames/v1/Another/knifes/v_ninja.mdl",
	"models/ArtGames/v1/Another/knifes/v_fast.mdl",
	"models/ArtGames/v1/Another/knifes/v_flash.mdl",
	"models/ArtGames/v1/Another/knifes/v_poison.mdl",
	"models/ArtGames/v1/Another/knifes/v_push.mdl",
	"models/ArtGames/v1/Another/knifes/v_titan.mdl",
	"models/ArtGames/v1/Another/knifes/v_fire.mdl",
	"models/ArtGames/v1/Another/knifes/v_frost.mdl",
	"models/ArtGames/v1/Another/knifes/v_thunder.mdl",
	"models/ArtGames/v1/Another/knifes/v_vampire.mdl",
	"models/ArtGames/v1/Another/knifes/v_reflect.mdl",*/
	"models/ArtGames/v2/Another/knifes/v_standart.mdl"
};

new const g_iKnifesModel_p[g_iKnifesCount][] =
{
	/*"models/ArtGames/v1/Another/knifes/p_swap.mdl",
	"models/ArtGames/v1/Another/knifes/p_ninja.mdl",
	"models/ArtGames/v1/Another/knifes/p_fast.mdl",
	"models/ArtGames/v1/Another/knifes/p_flash.mdl",
	"models/ArtGames/v1/Another/knifes/p_poison.mdl",
	"models/ArtGames/v1/Another/knifes/p_push.mdl",
	"models/ArtGames/v1/Another/knifes/p_titan.mdl",
	"models/ArtGames/v1/Another/knifes/p_fire.mdl",
	"models/ArtGames/v1/Another/knifes/p_frost.mdl",
	"models/ArtGames/v1/Another/knifes/p_thunder.mdl",
	"models/ArtGames/v1/Another/knifes/p_vampire.mdl",
	"models/ArtGames/v1/Another/knifes/p_reflect.mdl",*/
	"models/ArtGames/v2/Another/knifes/p_standart.mdl"
};

#define MAX_TOP 15

new g_iPoint[MAX_CLIENTS + 1];
new g_iTotal[MAX_CLIENTS + 1];

new g_iTimeOffset[MAX_CLIENTS + 1];
	
new g_iItemLevel[MAX_CLIENTS + 1][g_iItemCount];
new g_iWeapLevel[MAX_CLIENTS + 1][g_iWeapCount];

new g_iAuthID[33][36];
new bool:g_iRevivedOnce[32];
new Float:g_gametime;
new Float:g_gametime2;
new grenade[32];
new bool:g_reseted[33];
new bool:g_roulette[33];
new bool:g_track[33];
new bool:g_track_enemy;
new g_msgScreenFade;
new g_sync_check_data;
new last;
new g_Admin[33];
new g_Vip[33];
new g_LoggedIn[32];
new plugin_on;

new Regex:g_SteamID_pattern;
new g_regex_return;

//clients
new g_first_client;
new g_max_clients;

//True Steam, Yes - no, Register - Yes - no.
new bool:Registr[33];
new login[33][36], pass[33][36];
new bool:g_iAuthStatus[33];

new info_menu[33];

//music
new const error[] =        	"ArtGames/v2/pointmod/error.wav";
new const respawn[] =      	"ArtGames/v2/pointmod/respawn.wav";
new const level_up[] =   	"ArtGames/v2/pointmod/level_up.wav";
new const point_block[] =   "ArtGames/v2/pointmod/point_block.wav";
new const point_win[] =   	"ArtGames/v2/pointmod/points_win.wav";
new const point_lose[] =    "ArtGames/v2/pointmod/points_lose.wav";
new const up_sell[] =   	"ArtGames/v2/pointmod/points_sell.wav";

public plugin_precache()
{
	precache_sound(error);
	precache_sound(respawn);
	precache_sound(level_up);
	precache_sound(point_block);
	precache_sound(point_win);
	precache_sound(point_lose);
	precache_sound(up_sell);
	
	for(new k = 0; k < g_iKnifesCount; k++)
	{
		precache_model(g_iKnifesModel_v[k]);
		precache_model(g_iKnifesModel_p[k]);
	}
	
	return PLUGIN_CONTINUE;
}

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	//Register Spawn
	RegisterHam( Ham_Spawn, "player", "FwdPlayerSpawn", 1 );
	
	//Open MainMenu
	new command[]			= "Point_StartMenu";
	new command2[]			= "ResetMenu";
	
	register_clcmd( "say /agm", command );
	register_clcmd( "say /pm", command );
	register_clcmd( "say /xp", command );
	register_clcmd( "say /points", "ShowPoints");
	register_clcmd( "say /total", "ShowTotal");
	register_clcmd( "say_team /agm", command );
	register_clcmd( "say_team /pm", command );
	register_clcmd( "say_team /xp", command );
		
	register_clcmd( "say /reset", command2 );
	register_clcmd( "say_team /reset", command2 );
	
	register_clcmd("___enter_you_login","RegistrUserLogin",-1);
	register_clcmd("___enter_you_password","RegistrUserPassword",-1);
	
	register_clcmd("___enter_the_number","RandomForPlayer",-1);
	register_clcmd("___print_you_value","GivePointsIPlayer",-1);
	
	//Register Death
	register_event( "DeathMsg", "Event_DeathMsg", "a" );
	
	//Register Round Start
	register_logevent( "eRound_start", 2, "1=Round_Start" );
	
	//Register Round End
	register_logevent( "eRound_end", 2, "1=Round_End" );
	
	//Register Kill
	RegisterHam(Ham_Killed, "player", "FwdPlayerDeath", 1);
	
	//Register Take Damage
	RegisterHam(Ham_TakeDamage, "player", "FwdPlayerTakeDMG");
	RegisterHam(Ham_TakeDamage, "player", "FwdPlayerTakeDMGPAIN", 1);
	
	register_event("CurWeapon", "CurWeapon", "be", "1=1");
	
	//Get user screenfade
	g_msgScreenFade = get_user_msgid("ScreenFade");
	
	//Register ScreenFade
	register_event("ScreenFade", "eventFlash", "be", "4=255", "5=255", "6=255", "7>199");
	
	//Registers two different TextMSG
	register_event("TextMsg", "fire_in_the_hole", "b", "2&#Game_radio", "4&#Fire_in_the_hole");
	register_event("TextMsg", "fire_in_the_hole2", "b", "3&#Game_radio", "5&#Fire_in_the_hole");
	
	//Register when someone/something throws grenade
	register_event("99", "grenade_throw2", "b");
	
	//Register Commands
	register_concmd("agm_give_point", "CmdGivePoint", ADMIN_LEVEL_B, "<nick, #userid, authid> <amount of points> <1 - points, 2 - total, 3 all points>");
	register_concmd("agm_remove_point", "CmdRemovePoint", ADMIN_LEVEL_B, "<nick, #userid, authid> <amount of points> <1 - points, 2 - total, 3 all points>");
	register_concmd("agm_reset_point", "ResetPoints", ADMIN_LEVEL_B, "<nick, #userid, authid>");
	register_concmd("agm_change_upgrade", "ResetLevelUpgrade", ADMIN_LEVEL_B, "<nick, #userid, authid> <number> <level> <1 - item, any - weapon>");
	
	plugin_on = register_cvar("pointmod_on", "1");
	
	//Open nvault
	g_vault = nvault_open("mm_save");
	g_hVault = nvault_open("mm_save_top15");
	
	new err[2];
	g_SteamID_pattern = regex_compile("^^STEAM_0:(0|1):\d+$", g_regex_return, err, sizeof(err) - 1);
	
	g_first_client = 1;
	g_max_clients = get_maxplayers();
}

public plugin_end()
{
	nvault_close(g_vault);
	nvault_close(g_hVault);
}

public plugin_natives()
{
	register_library("ArtGamesMod");
	
	register_native("pm_level_extra_time", "_level_extra_time");
	register_native("pm_level_weapon_chance", "_level_weapon_chance");
	register_native("pm_level_autohealth", "_level_autohealth");
	register_native("pm_get_point", "_get_point");
	register_native("pm_set_point", "_set_point");
	register_native("pm_add_user_point", "pm_add_user_point");
	register_native("pm_add_user_point_new", "pm_add_user_point_new");
	register_native("pm_add_user_point_jump", "pm_add_user_point_jump");
	register_native("pm_time_shop_points", "pm_time_shop_points");
	register_native("pm_get_user_admin", "_get_user_admin");
	register_native("pm_get_health_level", "_get_health_level");
	register_native("pm_save", "_save");
	register_native("pm_load", "_load");
	register_native("pm_first_time", "_first_time");
	register_native("pm_has_user_nofrost", "_has_user_nofrost");
}

public client_putinserver(id)
{
	login[id] = "unknown";
	pass[id] = "unknown";
	
	g_Vip[id] =		bool:access(id, ADMIN_LEVEL_C);
	
	if(g_Vip[id])
	{
		if(g_iWeapLevel[id][HE_GRENADE] < g_iWeapMaxLevel[HE_GRENADE] / 2)
			g_iWeapLevel[id][HE_GRENADE] = g_iWeapMaxLevel[HE_GRENADE] / 2;
			
		if(g_iWeapLevel[id][SMOKE_GRENADE] < g_iWeapMaxLevel[SMOKE_GRENADE] / 2)
			g_iWeapLevel[id][SMOKE_GRENADE] = g_iWeapMaxLevel[SMOKE_GRENADE] / 2;
			
		if(g_iItemLevel[id][LARGE_AP] < g_iItemMaxLevel[LARGE_AP])
			g_iItemLevel[id][LARGE_AP] = g_iItemMaxLevel[LARGE_AP];
		
		Save(id);
	}
}

public _level_extra_time(iPlugin, iParams)
{
	new id = get_param(1);
	
	if(random_num(1, 100) <= g_iItemMaxVal[JOKES_CHANCE] * g_iItemLevel[id][JOKES_CHANCE] / g_iItemMaxLevel[JOKES_CHANCE])
	{
		return g_iItemMaxVal[JOKES_TIME] * g_iItemLevel[id][JOKES_TIME] / g_iItemMaxLevel[JOKES_TIME];
	}
	
	return 0;
}

public _level_weapon_chance(iPlugin, iParams)
{
	new id = get_param(1);
	return g_iItemMaxVal[MEGA_W_SHANSE] * g_iItemLevel[id][MEGA_W_SHANSE] / g_iItemMaxLevel[MEGA_W_SHANSE];
}

public _level_autohealth(iPlugin, iParams)
{
	new id = get_param(1);
	return g_iItemMaxVal[AUTO_HEALTH] * g_iItemLevel[id][AUTO_HEALTH] / g_iItemMaxLevel[AUTO_HEALTH];
}

public _has_user_nofrost(iPlugin, iParams)
{
	new client = get_param(1);
	if(g_iItemLevel[client][ANTI_FROSTNADE] != 0)
	{
		return true;
	}
	else{
		return false;
	}
	return PLUGIN_CONTINUE;	
}

public _get_health_level(iPlugin, iParams)
{
	return g_iItemLevel[get_param(1)][HEALTH];
}

public _first_time(iPlugin, iParams)
{
	return g_first_time[get_param(1)];
}

public _save(iPlugin, iParams)
{
	Save(get_param(1));
	SaveData(get_param(1));
}

public _load(iPlugin, iParams)
{
	Load(get_param(1));
	LoadData(get_param(1));
}

public _set_point(iPlugin, iParams)
{		
	new iPlayer = get_param(1);
	if( !iPlayer )
		return PLUGIN_CONTINUE;
	
	g_iPoint[iPlayer] = max(0, get_param(2));
	return g_iPoint[iPlayer];
}

public pm_add_user_point(iPlugin, iParams)
{	
	new iPlayer = get_param(1);
	if( !iPlayer )
		return PLUGIN_CONTINUE;
	
	if(get_pcvar_num(plugin_on) != 1)
		return PLUGIN_HANDLED;
		
	if(!Registr[iPlayer] && !g_iAuthStatus[iPlayer])
	{
		Print(iPlayer, "^03Вам требуется^04 зарегистрироваться в плагине^03, чтобы^04 получать поинты^03!");
		return PLUGIN_HANDLED;
	}
	
	if(get_playersnum() >= 4)
	{
		g_iPoint[iPlayer] += max(0, get_param(2));
		
		emit_sound(iPlayer, CHAN_STATIC, point_block, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
		Print(iPlayer, "^03Вы получили ^04%d поинтов^03 за то, что ^04убили противника стоя у него на голове^03!",max(0, get_param(2)));

		Save(iPlayer);
		SaveData(iPlayer);
	
		return PLUGIN_HANDLED;
	}
	else
	{
		new iPlayer = get_param(1);
		if( !iPlayer )
			return PLUGIN_CONTINUE;
			
		Print(iPlayer, "^03На сервере требуется более^04 3 игроков^03, чтобы^04 получать поинты^03!");
	
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_HANDLED;
}

public pm_add_user_point_new(iPlugin, iParams)
{	
	new iPlayer = get_param(1);
	if( !iPlayer )
		return PLUGIN_CONTINUE;
	
	if(get_pcvar_num(plugin_on) != 1)
		return PLUGIN_HANDLED;
	
	if(!Registr[iPlayer] && !g_iAuthStatus[iPlayer])
	{
		Print(iPlayer, "^03Вам требуется^04 зарегистрироваться в плагине^03, чтобы^04 получать поинты^03!");
		return PLUGIN_HANDLED;
	}
	
	if(random_num(1, 100) <= g_iItemMaxVal[LARGE_AP] * g_iItemLevel[iPlayer][LARGE_AP] / g_iItemMaxLevel[LARGE_AP])
	{
		g_iPoint[iPlayer] += max(0, get_param(2))*2;
		g_iTotal[iPlayer] += max(0, get_param(2))*2;
	
		emit_sound(iPlayer, CHAN_STATIC, point_block, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
		Print(iPlayer, "^03Вы получили ^04%d поинтов^03 за то, что ^04добрались до блока опыта^03!",max(0, get_param(2)));
		Print(iPlayer, "^03Вы получили ^04%d дополнительных поинтов^03 (%d%% шанс)!!!", max(0, get_param(2)), g_iItemMaxVal[LARGE_AP] * g_iItemLevel[iPlayer][LARGE_AP] / g_iItemMaxLevel[LARGE_AP]);
		
		new name_s[32];
		get_user_name(iPlayer, name_s, 31);
		
		for(new i = 1; i <= get_playersnum(); i++)
			if(iPlayer != i)
				Print(i, "^03Игрок %s счастливчик! Он получил в 2 раза больше поинтов!", name_s);
	}
	else
	{
		g_iPoint[iPlayer] += max(0, get_param(2));
		g_iTotal[iPlayer] += max(0, get_param(2));
	
		emit_sound(iPlayer, CHAN_STATIC, point_block, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
		Print(iPlayer, "^03Вы получили ^04%d поинтов^03 за то, что ^04добрались до блока опыта^03!",max(0, get_param(2)));
	}
	
	Save(iPlayer);
	SaveData(iPlayer);
	
	return PLUGIN_HANDLED;
}

public pm_add_user_point_jump(iPlugin, iParams)
{
	new iPlayer = get_param(1);
	if( !iPlayer )
		return PLUGIN_CONTINUE;
			
	if(get_pcvar_num(plugin_on) != 1)
	 return PLUGIN_HANDLED;
	 
	if(get_playersnum() >= 4 && g_iAuthStatus[iPlayer] || get_playersnum() >= 4 && Registr[iPlayer])
	{
		g_iPoint[iPlayer] += max(0, get_param(2));
		
		emit_sound(iPlayer, CHAN_STATIC, point_block, 1.0, ATTN_NORM, 0, PITCH_NORM);
		
		Save(iPlayer);
		SaveData(iPlayer);
	
		return PLUGIN_HANDLED;
	}
	else if(!g_iAuthStatus[iPlayer] && !Registr[iPlayer])
		Print(iPlayer, "^03You want^04 registered in the plugin^03, to^04 receive any points^03!");
	
	return PLUGIN_HANDLED;
}

public pm_time_shop_points(iPlugin, iParams)
{
	new iPlayer = get_param(1);
	if( !iPlayer )
		return PLUGIN_CONTINUE;
		
	if(get_pcvar_num(plugin_on) != 1)
	 return PLUGIN_HANDLED;
	
	if(get_playersnum() >= 4 && g_iAuthStatus[iPlayer] || get_playersnum() >= 4 && Registr[iPlayer])
	{
		g_iPoint[iPlayer] += max(0, get_param(2));
		
		emit_sound(iPlayer, CHAN_STATIC, point_block, 1.0, ATTN_NORM, 0, PITCH_NORM);
		
		for(new i = 1; i <= get_playersnum(); i++)
		{
			if(i == iPlayer)
				Print(iPlayer, "^03Вы получили ^04%d поинтов^03 за то, что ^04играете на сервере уже %d минут^03!!!", max(0, get_param(2)), max(0, get_param(3)));
			else
			{
				new name[32];
				get_user_name(iPlayer, name, 31);
				Print(i, "^03%s получил ^04%d поинтов^03 за то, что ^04играет на сервере уже %d минут^03!!!", name, max(0, get_param(2)), max(0, get_param(3)));
			}
		}
		
		Save(iPlayer);
		SaveData(iPlayer);
		
		return PLUGIN_HANDLED;
	}
	else if(!g_iAuthStatus[iPlayer] && !Registr[iPlayer])
		Print(iPlayer, "^03Вам требуется^04 зарегистрироваться в плагине^03, чтобы^04 получать поинты^03!");
	
	return PLUGIN_HANDLED;
}

public _get_point(iPlugin, iParams)
{
	return g_iPoint[get_param(1)];
}

public _set_user_status(iPlugin, iParams)
{
	new iPlayer = get_param(1);
	if( !iPlayer )
		return PLUGIN_CONTINUE;
		
	g_LoggedIn[iPlayer] = max(0, get_param(2));
	return g_LoggedIn[iPlayer];
}

public _get_user_status(iPlugin, iParams)
{
	return g_LoggedIn[get_param(1)];
}

public _get_user_admin(iPlugin, iParams)
{
	return g_Admin[get_param(1)];
}

public client_authorized(client)
{
	login[client][0] = 0;
	pass[client][0] = 0;
	
	if( !is_user_bot(client) && !is_user_hltv(client) )
	{
		/* is this still called in LAN, non-steam, etc? */
		get_user_authid(client, g_iAuthID[client], sizeof(g_iAuthID[]) - 1);
		
		if( !client_valid_authid(g_iAuthID[client]) )
		{
			g_iAuthID[client][0] = 0;
			g_iAuthStatus[client] = false;
		}
		else
		{
			g_iAuthStatus[client] = true;
			
			Load(client);
			LoadData(client);
		}
	}
	
	if ( access(client, ADMIN_LEVEL_B) )
		g_Admin[client] = true;
}

client_valid_authid(authid[])
{
	return (regex_match_c(authid, g_SteamID_pattern, g_regex_return) > 0);
}

public client_disconnect(client)
{
	Save(client);
	SaveData(client);
	
	g_iAuthID[client][0] = 0;
	g_iAuthStatus[client] = false;
	g_first_time[client] = 0;
	g_iRevivedOnce[client] = false;
	
	Registr[client] = false;
}

public ShowPoints ( iPlayer )
{
	if(get_pcvar_num(plugin_on) == 1)
	 Print(iPlayer, "^03У вас ^04%i поинтов!", g_iPoint[iPlayer]);
	else
     Print(iPlayer, "^03Плагин временно отключен администратором.");
}

public ShowTotal ( iPlayer )
{
	if(get_pcvar_num(plugin_on) == 1)
	 Print(iPlayer, "^03У вас всего ^04%i поинтов!", g_iTotal[iPlayer]);
	else
	 Print(iPlayer, "^03Плагин временно отключен администратором.");
}

Save(client)
{
	if(!g_iAuthStatus[client] && !Registr[client]) return;
	
	static data[292], len;
	
	if(Registr[client])
	{
		new password[36];
		formatex(password, 35, "%s", pass[client]);
		replace_all(password, 35, "^"", "");
		
		len = formatex(data, sizeof(data) - 1, " %s", password);
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_iPoint[client]);
	}
	else
		len = formatex(data, sizeof(data) - 1, " %i", g_iPoint[client]);
	
	len += formatex(data[len], sizeof(data) - len - 1, " %i", g_iTotal[client]);
	
	for( new iItem = 0; iItem < g_iItemCount; iItem++ )
	{
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_iItemLevel[client][iItem]);
	}
	
	for( new iWeap = 0; iWeap < g_iWeapCount; iWeap++ )
	{
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_iWeapLevel[client][iWeap]);
	}
	
	if(!Registr[client])
	{
		nvault_set(g_vault, g_iAuthID[ client ], data);
	}
	else
	{
		new key[38];
		formatex(key, 37, "#%s#", login[client]);
		replace_all(key, 37, "^"", "");
		nvault_set(g_vault, key, data);
	}
}

Load(client)
{
	if(!g_iAuthStatus[client] && !Registr[client]) return;
	
	static data[256], timestamp;
	
	new key[38];
	
	if(!Registr[client])
	{
		formatex(key, 37, "%s", g_iAuthID[client]);
	}
	else
	{
		formatex(key, 37, "#%s#", login[client]);
		replace_all(key, 37, "^"", "");
	}
	
	if( nvault_lookup(g_vault, key, data, sizeof(data) - 1, timestamp) )
	{
		ParseLoadData(client, data);
		return;
	}
	else
	{
		NewUser(client);
	}
}

ParseLoadData(client, data[256])
{
	static num[64];
	
	if(Registr[client])
	{
		strbreak(data, num, sizeof(num) - 1, data, sizeof(data) - 1);
		
		new pass_load[36], pass_client[36];
		format(pass_load, 35, "%s", num);
		format(pass_client, 35, "%s", pass[client]);
		replace_all(pass_client, 35, "^"", "");
		
		if(!equal(pass_client, pass_load))
		{
			Registr[client] = false;
			return PLUGIN_HANDLED;
		}
	}
	
	strbreak(data, num, sizeof(num) - 1, data, sizeof(data) - 1);
	
	if(Registr[client])
		g_iPoint[client] = clamp(str_to_num(num));
	else
		g_iPoint[client] = str_to_num(num);
	
	strbreak(data, num, sizeof(num) - 1, data, sizeof(data) - 1);
	g_iTotal[client] = clamp(str_to_num(num));
	
	for( new iItem = 0; iItem < g_iItemCount; iItem++ )
	{
		strbreak(data, num, sizeof(num) - 1, data, sizeof(data) - 1);
		g_iItemLevel[client][iItem] = clamp(str_to_num(num), 0, g_iItemMaxLevel[iItem]);
	}
	
	for( new iWeap = 0; iWeap < g_iWeapCount; iWeap++ )
	{
		strbreak(data, num, sizeof(num) - 1, data, sizeof(data) - 1);
		g_iWeapLevel[client][iWeap] = clamp(str_to_num(num), 0, g_iWeapMaxLevel[iWeap]);
	}
	
	return PLUGIN_CONTINUE;
}

SaveData( iPlayer )
{
	if(!g_iAuthStatus[iPlayer] && !Registr[iPlayer]) return;
	
	new iTime = get_user_time( iPlayer ) - g_iTimeOffset[ iPlayer ];
	
	new szSteamID[ 35 ];
	get_user_authid( iPlayer, szSteamID, charsmax( szSteamID ) );
	
	new szData[ 164 ];
	nvault_get( g_hVault, szSteamID, szData, charsmax( szData ) );
	
	new iOldTime;
	ReadVaultData( szData, charsmax( szData ), iOldTime );
	
	new iTotalTime = iOldTime + iTime;
	
	new szName[ 32 ];
	get_user_name( iPlayer, szName, charsmax( szName ) );
	
	formatex( szData, charsmax( szData ), " %d,%i,%s", iTotalTime, g_iTotal[ iPlayer ], szName );
	
	if(!Registr[iPlayer])
	{
		nvault_set(g_hVault, szSteamID, szData);
	}
	else
	{
		new key[38];
		formatex(key, 37, "#%s#", login[iPlayer]);
		replace_all(key, 37, "^"", "");
		nvault_set(g_hVault, key, szData);
	}
	
	g_iTimeOffset[ iPlayer ] += iTime;
}

LoadData(client)
{
	if(!g_iAuthStatus[client] && !Registr[client]) return PLUGIN_HANDLED;
	
	static data[256], timestamp;
	
	new key[38];
	
	if(!Registr[client])
	{
		formatex(key, 37, "%s", g_iAuthID[client]);
	}
	else
	{
		formatex(key, 37, "#%s#", login[client]);
		replace_all(key, 37, "^"", "");
	}
	
	if( nvault_lookup(g_hVault, key, data, sizeof(data) - 1, timestamp) )
	{
		new szData[ 128 ];
		nvault_get( g_hVault, key, szData, charsmax( szData ) );
	
		new iTime;
		ReadVaultData( szData, charsmax( szData ), iTime, g_iTotal[ client ] );
		
		return iTime;
	}
	else
	{
		NewUser(client);
	}
	
	return PLUGIN_CONTINUE;
}

NewUser(client)
{
	g_first_time[client] = 1;
	
	g_iPoint[client] = 1000;
	g_iTotal[client] = 1000;
	
	for( new iItem = 0; iItem < g_iItemCount; iItem++ )
	{
		g_iItemLevel[client][iItem] = 0;
	}
	for( new iWeap = 0; iWeap < g_iWeapCount; iWeap++ )
	{
		g_iWeapLevel[client][iWeap] = 0;
	}
}

public FwdPlayerTakeDMG(iPlayer, inflictor, attacker, Float:damage, damagebits)
{
	if(get_pcvar_num(plugin_on) != 1)
	 return PLUGIN_HANDLED;
	 
	//If player is alive and the damage is done by falling
	if(is_user_alive(iPlayer) && (damagebits & DMG_FALL) )
	{
		new percent = g_iItemMaxVal[FALL_DMG_REDUCE] * g_iItemLevel[iPlayer][FALL_DMG_REDUCE] / g_iItemMaxLevel[FALL_DMG_REDUCE];
		SetHamParamFloat(4, damage * (1.0 - (float(percent) / 100.0)));
	}
	
	if(( 1 <= attacker <= get_maxplayers() && iPlayer != attacker ))
	{
		new Float:fMultiplier = float(g_iItemMaxVal[EXTRA_DAMAGE] * g_iItemLevel[attacker][EXTRA_DAMAGE] / g_iItemMaxLevel[EXTRA_DAMAGE]);
		SetHamParamFloat(4, damage + (damage / 100 * fMultiplier));
	}
		
	return HAM_IGNORED;
}

public FwdPlayerTakeDMGPAIN(iPlayer, inflictor, attacker, Float:damage, damagebits)
{
	if( g_iItemLevel[iPlayer][NO_PAIN] >= 1 )
	{
		set_pdata_float(iPlayer, 108, 1.0);
	}
	
	return HAM_HANDLED;
}

public FwdPlayerDeath(iPlayer, Killer, Shouldgib)
{
	if(get_pcvar_num(plugin_on) != 1)
	 return PLUGIN_HANDLED;
	 
	//If the player hasnt already been respawned
	if( !g_iRevivedOnce[iPlayer] )
	{
		//If player is either ct or t
		new CsTeams:team = cs_get_user_team(iPlayer);
		if( team == CS_TEAM_T || team == CS_TEAM_CT )
		{
			//Percentage Calculation
			new iPercent = g_iItemMaxVal[RESPAWN_CHANCE] * g_iItemLevel[iPlayer][RESPAWN_CHANCE] / g_iItemMaxLevel[RESPAWN_CHANCE];
			
			//Percentage Usage
			if( random_num(1, 100) <= iPercent )
			{
				//Set respwan in 1 second
				set_task(1.0, "Task_Respawn", iPlayer);
			}
		}
	}
	
	return PLUGIN_CONTINUE;
}

public CurWeapon(id)
{
	new Weapon = read_data(2);
	
	if(Weapon == CSW_KNIFE)
	{
		entity_set_string(id, EV_SZ_viewmodel, g_iKnifesModel_v[STANDART]);
		entity_set_string(id, EV_SZ_weaponmodel, g_iKnifesModel_p[STANDART]);
	}
}

public Task_Respawn(iPlayer)
{
	if(get_pcvar_num(plugin_on) != 1)
	 return PLUGIN_HANDLED;
	 
	//Respawn Player
	ExecuteHamB(Ham_CS_RoundRespawn, iPlayer);
	
	new szName[33]; get_user_name(iPlayer, szName, charsmax(szName));
	new iPercent = g_iItemMaxVal[RESPAWN_CHANCE] * g_iItemLevel[iPlayer][RESPAWN_CHANCE] / g_iItemMaxLevel[RESPAWN_CHANCE];

	set_hudmessage(255, 0, 0, -1.0, -1.0, 0, 6.0, 12.0);
	show_hudmessage(0,"^03Игрок ^04%s ^03воскрешен!", szName);

	//Print to the player that he/she got respawned
	Print(iPlayer, "^03Вас воскресили! (%d%% шанс)", iPercent);
	
	emit_sound(iPlayer, CHAN_STATIC, respawn, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	//Disable respawn until next round
	g_iRevivedOnce[iPlayer] = true;
	
	return PLUGIN_CONTINUE;
}

public eRound_start()
{
	//Bunc of variables
	new iPlayers[32], iNum, iPid;
	
	//Get all players
	get_players( iPlayers, iNum, "a" );
	
	//Browse through all players
	for( new i; i < iNum; i++ )
	{
		iPid = iPlayers[i];
		
		//Enable respawn
		g_iRevivedOnce[iPid] = false;
	}
}

public eRound_end()
{	
	if(get_pcvar_num(plugin_on) != 1)
	 return PLUGIN_HANDLED;
	 
	for( new i = g_first_client; i <= g_max_clients; i++ )
	{
		if(g_iAuthStatus[i] && get_user_team(i) == 1 && is_user_alive(i) || Registr[i] && get_user_team(i) == 1 && is_user_alive(i))
		{
			if(get_playersnum() >= 4)
			{
				g_iPoint[i] += 5;
				
				Print(i, "^03Вы получили^04 5 поинтов^03 за то, что вы ^04выжили в этом раунде^03!");
			
				emit_sound(i, CHAN_STATIC, point_win, 1.0, ATTN_NORM, 0, PITCH_NORM);
			
				Save(i);
				SaveData(i);
			}
			else
			{
				Print(i, "^03На сервере требуется более^04 3 игроков^03, чтобы^04 получать поинты^03!");
			}
		}
		else if(!Registr[i] && !g_iAuthStatus[i])
			Print(i, "^03Вам требуется^04 зарегистрироваться в плагине^03, чтобы^04 получать поинты^03!");
	}
	
	return PLUGIN_HANDLED;
}

public Event_DeathMsg()
{
	if(get_pcvar_num(plugin_on) != 1)
	 return PLUGIN_HANDLED;
	
	new killer = read_data(1);
	new victim = read_data(2);
	
	if( (g_first_client <= killer <= g_max_clients) && victim != killer )
	{
		if( g_iAuthStatus[killer] || Registr[killer] )
		{
			if(get_playersnum() >= 4)
			{
				// regular kill
				new pm = 2;
				static skill[33];
				skill = "^03!";
				
				if( read_data(3) )
				{
					// headshot kill
					pm += 1;
				
					skill = " в голову^03!";
				}
				else
				{
					static weapon[20];
					read_data(4, weapon, sizeof(weapon) - 1);
					
					if( contain(weapon, "grenade") >= 0 )
					{
						// grenade kill (or frostnade)
						pm += 2;
					
						skill = " с гранаты^03!";
					}
				}
			
				if(g_Vip[killer])
				{
					pm += 1;
				}
			
				g_iPoint[killer] += pm;
				
				Print(killer, "^03Вы получили ^04%i points^03 за ^04убийство противника%s", pm, skill);
				
				Save(killer);
				SaveData(killer);
			}
			else
			{
				Print(killer, "^03На сервере требуется более^04 3 игроков^03, чтобы^04 получать поинты^03!");
			}
		}
		else
		{
			Print(killer, "^03Вам требуется^04 зарегистрироваться в плагине^03, чтобы^04 получать поинты^03!");
			Print(victim, "^03Вам требуется^04 зарегистрироваться в плагине^03, чтобы^04 получать поинты^03!");
		}
	}
	else if( g_iAuthStatus[victim] || Registr[victim])
	{	
		if(get_playersnum() >= 4)
		{
			emit_sound(victim, CHAN_STATIC, point_lose, 1.0, ATTN_NORM, 0, PITCH_NORM);
		}
		else
		{
			emit_sound(victim, CHAN_STATIC, point_lose, 1.0, ATTN_NORM, 0, PITCH_NORM);
			Print(victim, "^03На сервере требуется более^04 3 игроков^03, чтобы^04 получать поинты^03!");
		}
	}
	else
		Print(victim, "^03Вам требуется^04 зарегистрироваться в плагине^03, чтобы^04 получать поинты^03!");
	
	return PLUGIN_HANDLED;
}

public ResetMenu(client)
{
	if(get_pcvar_num(plugin_on) != 1)
	{
		Print(client, "^03Плагин временно отключен администратором.");
		return PLUGIN_HANDLED;
	}
	
	g_first_time[client] = 1;

	g_iPoint[client] = 1000;
	g_iTotal[client] = 1000;
	
	for( new iItem = 0; iItem < g_iItemCount; iItem++ )
	{
		g_iItemLevel[client][iItem] = 0;
	}
	for( new iWeap = 0; iWeap < g_iWeapCount; iWeap++ )
	{
		g_iWeapLevel[client][iWeap] = 0;
	}
	
	Print(client, "You removed all you points and upgrades!");
	
	Save(client);
	SaveData(client);
	
	return PLUGIN_HANDLED;
}

public Point_StartMenu(iPlayer)
{
	if(!g_iAuthStatus[iPlayer] && !Registr[iPlayer])
	{	
		show_motd(iPlayer,"AGM/registration_rus.txt","Registration information");
		ShowRegistrMenuEng(iPlayer);
		return PLUGIN_HANDLED;
	}
	
	new title[96]; 
	format(title, 95, "\r[ArtGamesMod] \w- \yMain Menu^n^n\yYou Art Points: \r%i^n\yYou Total Points: \r%i", g_iPoint[iPlayer], g_iTotal[iPlayer]);
	
	//Create the menu
	new menu = menu_create(title, "StartMenu_Handle");
	
	//Create Items Menu

	menu_additem(menu, "\wTotal Top", "1", 0);
	menu_additem(menu, "\wInformation^n", "2", 0);
	
	menu_additem(menu, "\rUpgrades Menu", "3", 0);
	menu_additem(menu, "\rWeapons Menu", "4", 0);
	menu_additem(menu, "\rUpgrades Returns^n", "8", 0);
	
	menu_additem(menu, "\yTransfer Points", "5", 0);
	menu_additem(menu, "\yRussian Roulette^n", "6", 0);
	
	menu_additem(menu, "\rRegistration/Entrance", "7", 0);
	
	menu_addblank(menu, 1);
	menu_additem(menu, "\wExit", "0", 0);
	
	menu_setprop(menu, MPROP_PERPAGE, 0);
	
	//Display the menu
	menu_display(iPlayer, menu, 0);
	
	return PLUGIN_CONTINUE;
}

public StartMenu_Handle(iPlayer, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	if(get_pcvar_num(plugin_on) != 1)
	{
		Print(iPlayer, "^03Плагин временно отключен администратором.");
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
			TopPoint(iPlayer);
			Point_StartMenu(iPlayer);
		}
		case 2:
		{
			Info_Menu(iPlayer);
		}
		case 3:
		{
			Point_MainMenu(iPlayer);
		}
		case 4:
		{
			Point_GrenadeMenu(iPlayer);
		}
		case 5:
		{
			Point_TransferMenu(iPlayer);
		}
		case 6:
		{
			if(get_playersnum() >= 4 && !g_roulette[iPlayer])
			{
				Point_RandomMenu(iPlayer);
			
				Print(iPlayer, "^04Введите ставку - максимум 50 art поинтов.");
			}
			else if(g_roulette[iPlayer])
			{
				Print(iPlayer, "^04Вы уже играли в рулетку в этом раунде!");
			}
			else
			{
				Print(iPlayer, "^03Вы не можете играть в рулетку так, как на сервере меньше 4 игроков!");
			}
		}
		case 7:
		{
			ShowRegistr_MenuEng(iPlayer);
		}
		case 8: 
		{
			Print(iPlayer, "Это меню позволяет ^4продать ^3купленные улучшения");
			ShowReturnMenu(iPlayer);
		}
		case 0: return PLUGIN_HANDLED;
	}
	
	return PLUGIN_HANDLED;
}

public ShowRegistr_MenuEng(id)
{
	new title[170];
	formatex(title, 169, "\w- Registration Menu:");
	
	new menu = menu_create(title, "HandleRegistr_MenuEng");
	
	menu_additem(menu, "\y-Enter the account!", "1", 0);
	menu_additem(menu, "\r-Register now!", "2", 0);
	menu_additem(menu, "\w-What for registration?!^n", "3", 0);
		
	menu_display(id, menu, 0);
}

public HandleRegistr_MenuEng(iPlayer, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		Point_StartMenu(iPlayer);
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
			ShowExtranceEng(iPlayer);
		}
		case 2:
		{
			ShowRegistrMenuEng(iPlayer);
		}
		case 3:
		{
			show_motd(iPlayer,"AGM/registration.txt","Registration information");
			ShowRegistr_MenuEng(iPlayer);
		}
	}
	
	return PLUGIN_HANDLED;
}
public ShowRegistrMenuEng(id)
{
	new menu = menu_create("Registration in the system:", "HandleRegistrMenuEng");
	
	new glogin[36];
	formatex(glogin, 35, "Your Login: %s", login[id]);
	
	new password[36];
	formatex(password, 35, "Your Password: %s", pass[id]);
	
	menu_additem(menu, glogin, "1", 0);
	menu_additem(menu, password, "2", 0);
	menu_additem(menu, "Accept^n", "3", 0);
		
	menu_display(id, menu, 0);
}

public HandleRegistrMenuEng(iPlayer, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		ShowRegistr_MenuEng(iPlayer);
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
			info_menu[iPlayer] = 1;
			client_cmd(iPlayer, "messagemode ___enter_you_login");
		}
		case 2:
		{
			info_menu[iPlayer] = 1;
			client_cmd(iPlayer, "messagemode ___enter_you_password");
		}
		case 3:
		{
			static data[256], timestamp;
			
			new key[36];
			formatex(key, 35, "%s", login[iPlayer]);
			replace_all(key, 35, "^"", "");
			
			if(!nvault_lookup(g_vault, key, data, sizeof(data) - 1, timestamp))
			{
				Registr[iPlayer] = true;
					
				NewUser(iPlayer);
				Save(iPlayer);
					
				Print(iPlayer, "Вы успешно зарегистрировались!");
						
				nvault_close(g_vault);
				nvault_close(g_hVault);
				
				g_vault = nvault_open("agm_save");
				g_hVault = nvault_open("agm_save_top");
				
				return PLUGIN_HANDLED;
			}
			else
			{
				ShowRegistrMenuEng(iPlayer);
				
				Print(iPlayer, "Этот логин уже используется!");
			}
		}
	}
	
	return PLUGIN_HANDLED;
}

public RegistrUserLogin(client)
{
	static arg[36];
	read_args(arg, charsmax(arg));
	
	formatex(login[client], 35, "%s", arg);
	
	if(info_menu[client] == 1)
		ShowRegistrMenuEng(client);
	else if(info_menu[client] == 2)
		ShowExtranceEng(client);
	
	return PLUGIN_HANDLED;
}

public RegistrUserPassword(client)
{
	static arg[36];
	read_args(arg, charsmax(arg));
	
	formatex(pass[client], 35, "%s", arg);
	
	if(info_menu[client] == 1)
		ShowRegistrMenuEng(client);
	else if(info_menu[client] == 2)
		ShowExtranceEng(client);
	
	return PLUGIN_HANDLED;
}

public ShowExtranceEng(id)
{
	new menu = menu_create("The entrance to the account:", "HandleExtranceEng");
	
	new glogin[36];
	formatex(glogin, 35, "Your Login: %s", login[id]);
	
	new password[36];
	formatex(password, 35, "Your Password: %s", pass[id]);
	
	menu_additem(menu, glogin, "1", 0);
	menu_additem(menu, password, "2", 0);
	menu_additem(menu, "\wAccept!^n", "3", 0);
	
	menu_display(id, menu, 0);
}

public HandleExtranceEng(iPlayer, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		Point_StartMenu(iPlayer);
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
			info_menu[iPlayer] = 2;
			client_cmd(iPlayer, "messagemode ___enter_you_login");
		}
		case 2:
		{
			info_menu[iPlayer] = 2;
			client_cmd(iPlayer, "messagemode ___enter_you_password");
		}
		case 3:
		{
			static data[256], timestamp;
			new key[36];
			formatex(key, 35, "#%s#", login[iPlayer]);
			replace_all(key, 35, "^"", "");
			
			if(nvault_lookup(g_vault, key, data, sizeof(data) - 1, timestamp))
			{
				Registr[iPlayer] = true;
				
				Load(iPlayer);
				LoadData(iPlayer);
				
				if(!Registr[iPlayer])
				{
					Print(iPlayer, "Неверный пароль!");
					
					ShowExtranceEng(iPlayer);
					return PLUGIN_HANDLED;
				}
				
				Print(iPlayer, "Вы успешно вошли в акаунт!");
						
				return PLUGIN_HANDLED;
			}
			else
			{
				ShowExtranceEng(iPlayer);
				
				Print(iPlayer, "Такого логина и пароля не найдено...");
			}
		}
	}
	
	return PLUGIN_HANDLED;
}

public Info_Menu(iPlayer)
{
	new menu = menu_create("\r[ArtGames Mod]^n\w- \ySelect information", "InfoMenu_Handle");
	
	//Create Items Menu
	menu_additem(menu, "\wUpgrades", "1", 0);
	menu_additem(menu, "\wPlugin", "2", 0);
	menu_additem(menu, "\wPlayers", "3", 0);

	//Display the menu
	menu_display(iPlayer, menu, 0);
}

public InfoMenu_Handle(iPlayer, menu, item)
{
	if(get_pcvar_num(plugin_on) != 1)
	{
		Print(iPlayer, "^03Плагин временно отключен администратором.");
		return PLUGIN_HANDLED;
	}
	
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		Point_StartMenu(iPlayer);
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
			Info(iPlayer);
		}
		case 2:
		{
			Plugin_Info(iPlayer);
		}
		case 3:
		{
			Point_PlayerMenu(iPlayer);
		}
	}
	
	return PLUGIN_HANDLED;
}
public Info(iPlayer)
{
	show_motd(iPlayer,"AGM/upgrades.txt","Upgrades information");
	Info_Menu(iPlayer);
	
	return PLUGIN_HANDLED;
}

public Plugin_Info(iPlayer)
{
	show_motd(iPlayer,"AGM/plugin.txt","Plugin information");
	Info_Menu(iPlayer);
	
	return PLUGIN_HANDLED;
}
	
public Point_PlayerMenu(iPlayer)
{
	new title[170]; formatex(title, sizeof(title) - 1, "\r[ArtGamesMod] \w- \yPlayer Info^n^n\wChoose The Player");
	new menu = menu_create(title, "Point_PlayerHandle");
	
	new players[32], pnum, tempid;
	new szName[32], szTempid[10];
    
	get_players(players, pnum);
	
	for( new i; i<pnum; i++ )
	{
		tempid = players[i];
		
		get_user_name(tempid, szName, 31);
		num_to_str(tempid, szTempid, 9);
		
		menu_additem(menu, szName, szTempid, 0);
	}
	
	menu_display(iPlayer, menu, 0);
}

public Point_PlayerHandle(iPlayer, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		Info_Menu(iPlayer);
		return PLUGIN_HANDLED;
	}
	
	new data[6], iName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	
	new tempid = str_to_num(data);
	new tempname[32]; get_user_name(tempid, tempname, 31);
	
	static motd[2500];
	new len = formatex(motd, sizeof(motd) - 1,	"<html>");
	len += format(motd[len], sizeof(motd) - len - 1,	"<body style=^"background-color:#030303; color:#FFFFFF^">");
	len += format(motd[len], sizeof(motd) - len - 1,	"Name: %s.<br><br>", tempname);
	len += format(motd[len], sizeof(motd) - len - 1,	"Points: %i.<br><br>", g_iPoint[tempid]);
	len += format(motd[len], sizeof(motd) - len - 1, "Total Points: %i.<br><br>", g_iTotal[tempid]);
	len += format(motd[len], sizeof(motd) - len - 1,	"<b>Weapon Upgrades</b>:<br>");
	for( new iWeap = 0; iWeap < g_iWeapCount; iWeap++ )
	{
		if( g_iWeapClass[iWeap] != 2 )
		{
			len += format(motd[len], sizeof(motd) - len - 1,	"%s  -  Level: %i/%i <br>", g_iWeapons[iWeap], g_iWeapLevel[tempid][iWeap], g_iWeapMaxLevel[iWeap]);
		}
	}
	
	len += format(motd[len], sizeof(motd) - len - 1,	"<br><br><b>Upgrades:</b><br>");
	for( new iItem = 0; iItem < g_iItemCount; iItem++ )
	{
		len += format(motd[len], sizeof(motd) - len - 1,	"%s  -  Level: %i/%i <br>", g_iItems[iItem], g_iItemLevel[tempid][iItem], g_iItemMaxLevel[iItem]);
	}
	len += format(motd[len], sizeof(motd) - len - 1,	"</p>");
	len += format(motd[len], sizeof(motd) - len - 1,	"</body>");
	len += format(motd[len], sizeof(motd) - len - 1,	"</html>");
	
	show_motd(iPlayer, motd, "Player info");
	
	menu_destroy(menu);
	Info_Menu(iPlayer);
	
	return PLUGIN_HANDLED;
}

public Point_RandomMenu(iPlayer)
{
	client_cmd(iPlayer, "messagemode ___enter_the_number");
	
	return PLUGIN_HANDLED;
}
public RandomForPlayer(iPlayer, menu, item)
{
	static arg[33];
	read_argv(1, arg, charsmax(arg));
	
	if ( !strlen(arg) )
	{
		Print(iPlayer, "You can't set a transferred art points blank! Please type a new value.");
		
		client_cmd(iPlayer,"messagemode ___enter_the_number");
		return PLUGIN_HANDLED;
	}
	else if ( !IsStrFloat(arg) )
	{
		Print(iPlayer, "You can't use letters in a transferred art points! Please type a new value.");
		
		client_cmd(iPlayer,"messagemode ___enter_the_number");
		return PLUGIN_HANDLED;
	}
	
	new check = str_to_num(arg);
	if(check <= 0)
	{
		Print(iPlayer, "^3Введенное значение должно быть больше^4 0^3!");
		
		client_cmd(iPlayer,"messagemode ___enter_the_number");
		return PLUGIN_HANDLED;
	}
	else if(check > g_iPoint[iPlayer])
	{
		Print(iPlayer, "^03У вас нету^04 %i art поинтов^03!", check);
		
		client_cmd(iPlayer,"messagemode ___enter_the_number");
		return PLUGIN_HANDLED;
	}
	
	new g_iPointGive = str_to_num(arg);
	
	if(random_num(0,100) <= 40)
	{
		g_iPoint[iPlayer] += g_iPointGive;
		
		Print(iPlayer, "^03Поздравляю! Вы выиграли ^04%i art поинтов^03!", g_iPointGive);
	}
	else
	{
		g_iPoint[iPlayer] -= g_iPointGive;
		
		Print(iPlayer, "^03Вы проиграли ^04%i art поинтов^03!", g_iPointGive);
	}
	
	Save(iPlayer);
	
	g_roulette[iPlayer] = true;
		
	return PLUGIN_HANDLED;
}
public Point_TransferMenu(iPlayer)
{	
	if(get_playersnum() <= 1)
	{
		Print(iPlayer, "Вы 1 на сервере!");
		return PLUGIN_HANDLED;
	}
	
	new title[170]; formatex(title, sizeof(title) - 1, "\r[ArtGamesMod] \w- \yTransfer Menu^n^n\wChoose The Player^n\yYour Art Points: \r%i^n", g_iPoint[iPlayer]);
	new menu = menu_create(title, "TransferMenu_Handle");
	
	new players[32], pnum, tempid;
	new szName[32], szTempid[10];
    
	get_players(players, pnum);
	
	for( new i; i<pnum; i++ )
	{
		tempid = players[i];
		
		if(iPlayer != tempid)
		{
			get_user_name(tempid, szName, 31);
			num_to_str(tempid, szTempid, 9);
		
			menu_additem(menu, szName, szTempid, 0);
		}
	}
	
	menu_display(iPlayer, menu, 0);
	
	return PLUGIN_HANDLED;
}

public TransferMenu_Handle(iPlayer, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		Point_StartMenu(iPlayer);
		return PLUGIN_HANDLED;
	}
	
	new data[6], iName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	
	new iName3[33];
	iDiName = str_to_num(data);
	get_user_name(iDiName, iName3, 31);
	
	Print(iPlayer, "^03Вы выбрали ^04%s!", iName3);
	Print(iPlayer, "^03Введите число передаваемых ему art поинтов.");
	client_cmd(iPlayer, "messagemode ___print_you_value");
	
	return PLUGIN_HANDLED;
}

public GivePointsIPlayer(iPlayer)
{
	static arg[33];
	read_argv(1, arg, charsmax(arg));
	
	if ( !strlen(arg) )
	{
		Print(iPlayer, "You can't set a transferred art points blank! Please type a new value.");
		
		client_cmd(iPlayer,"messagemode ___print_you_value");
		return PLUGIN_HANDLED;
	}
	else if ( !IsStrFloat(arg) )
	{
		Print(iPlayer, "You can't use letters in a transferred art points! Please type a new value.");
		
		client_cmd(iPlayer,"messagemode ___print_you_value");
		return PLUGIN_HANDLED;
	}
	new check = str_to_num(arg);
	if(check <= 0)
	{
		Print(iPlayer, "^3Введенное значение должно быть больше^4 0^3 и меньше^4 99999^3!");
		
		client_cmd(iPlayer,"messagemode ___print_you_value");
		return PLUGIN_HANDLED;
	}
	else if(check > g_iPoint[iPlayer])
	{
		Print(iPlayer, "^03У вас нету^04 %i art поинтов^03!", check);
		
		client_cmd(iPlayer,"messagemode ___print_you_value");
		return PLUGIN_HANDLED;
	}
	
	new iName[32];
	new iName2[32];
	new g_iPointGive = str_to_num(arg);
	
	get_user_name(iPlayer, iName, 31);
	get_user_name(iDiName, iName2, 31);
	
	g_iPoint[iPlayer] -= str_to_num(arg);
	g_iPoint[iDiName] += str_to_num(arg);
	
	Print(iPlayer,"^03Вы успешно передали ^04%i art поинтов^03 игроку ^04%s^03!!!", g_iPointGive, iName2);
	Print(iDiName,"^03Игрок ^04%s ^03успешно передал вам ^04%i art поинтов^03!!!", iName, g_iPointGive);
	
	Save(iPlayer);
	Save(iDiName);
	
	return PLUGIN_HANDLED;
}

//Extra Menu End
public Point_GrenadeMenu(iPlayer)
{
	//Menu Title
	new title[170]; formatex(title, sizeof(title) - 1, "\r[ArtGamesMod] \w- \yGrenade Menu^n\yYour Art Points: \r%i", g_iPoint[iPlayer]);
	
	//Create the menu
	new menu = menu_create(title, "GrenadeMenu_Handle");
	new iNumber[5], iCost, szOption[80], Amount, Level, Level2;
	
	
	//Browse through all menu items
	for( new iWeap = 0; iWeap < g_iWeapCount; iWeap++ )
	{
		//Bunch of variables
		num_to_str(iWeap, iNumber, 4);
		Level = g_iWeapLevel[iPlayer][iWeap];
		Level2 = g_iWeapLevel[iPlayer][iWeap] + 1;
		iCost = g_iFirstWCost[iWeap] * (1 << (Level2 - 1));
		Amount = g_iWeapMaxVal[iWeap] * g_iWeapLevel[iPlayer][iWeap] / g_iWeapMaxLevel[iWeap];
		
		//If the player already have maxlevel
		if( g_iWeapLevel[iPlayer][iWeap] >= g_iWeapMaxLevel[iWeap] )
		{
			if( g_iWeapClass[iWeap] == CSW_SMOKEGRENADE )
			{
				formatex(szOption, 79, "\y%s: \wLevel \d%i/%i \r(%i%s) (CT Only)", g_iWeapons[iWeap], Level, g_iWeapMaxLevel[iWeap], Amount, g_iWeapShort[iWeap]);
			}
			else
			{
				formatex(szOption, 79, "\y%s: \wLevel \d%i/%i \r(%i%s)", g_iWeapons[iWeap], Level, g_iWeapMaxLevel[iWeap], Amount, g_iWeapShort[iWeap]);
			}
		}
		//If the player cant afford the item
		else if( g_iPoint[iPlayer] < iCost )
		{
			if( g_iWeapClass[iWeap] == CSW_SMOKEGRENADE )
			{
				formatex(szOption, 79, "\d%s: \wLevel %i/%i \r(%i%s) (CT Only) \y%i Points", g_iWeapons[iWeap], Level, g_iWeapMaxLevel[iWeap], Amount, g_iWeapShort[iWeap], iCost);
			}
			else
			{
				formatex(szOption, 79, "\d%s: \wLevel %i/%i \r(%i%s) \y%i Poitns", g_iWeapons[iWeap], Level, g_iWeapMaxLevel[iWeap], Amount, g_iWeapShort[iWeap], iCost);
			}
		}
		//If the player has not maxed out the item
		else if( g_iWeapLevel[iPlayer][iWeap] < g_iWeapMaxLevel[iWeap] )
		{
			if( g_iWeapClass[iWeap] == CSW_SMOKEGRENADE )
			{
				formatex(szOption, 79, "\r%s: \wLevel %i/%i \r(%i%s) (CT Only) \y%i Points", g_iWeapons[iWeap], Level, g_iWeapMaxLevel[iWeap], Amount, g_iWeapShort[iWeap], iCost);
			}
			else
			{
				formatex(szOption, 79, "\r%s: \wLevel %i/%i \r(%i%s) \y%i Points", g_iWeapons[iWeap], Level, g_iWeapMaxLevel[iWeap], Amount, g_iWeapShort[iWeap], iCost);
			}
		}
		
		//Add all the menu items
		if( g_iWeapClass[iWeap] == 2 )
		{
			menu_addblank(menu, 0);
		}
		else
		{
			menu_additem(menu, szOption, iNumber);
		}
	}
	
	//Display the menu
	menu_display(iPlayer, menu, 0);
}

public GrenadeMenu_Handle(iPlayer, menu, item)
{
	//Get the menu data
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		Point_StartMenu(iPlayer);
		return PLUGIN_HANDLED;
	}
	
	//Bunc of variables
	new data[6], iName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	
	new iWeap = str_to_num( data ), iCost, Level;
	Level = g_iWeapLevel[iPlayer][iWeap] + 1;
	iCost = g_iFirstWCost[iWeap] * (1 << (Level - 1));
	
	//If player has maxed out the item
	if( g_iWeapLevel[iPlayer][iWeap] == g_iWeapMaxLevel[iWeap] )
	{
		Print(iPlayer, "^x04%s ^03прокачен до максимума!", g_iWeapons[iWeap]);
		
		emit_sound(iPlayer, CHAN_STATIC, error, 1.0, ATTN_NORM, 0, PITCH_NORM);
	}
	//If the player cant afford the item
	else if( g_iPoint[iPlayer] < iCost )
	{
		Print(iPlayer, "^x03У вас недостаточно поинтов для того чтобы прокачать ^04%s ^03Уровень: ^04%i", g_iWeapons[iWeap], Level);
		
		emit_sound(iPlayer, CHAN_STATIC, error, 1.0, ATTN_NORM, 0, PITCH_NORM);
	}
	//Take Point, Print and give level
	else
	{
		//Take Point
		g_iPoint[iPlayer] -= iCost;
		
		//Give a level
		g_iWeapLevel[iPlayer][iWeap] += 1;
		
		//Print out to the player that he/she bought an item with corresponding level
		Print(iPlayer, "^x03Вы прокачали ^04%s ^03Уровень: ^04%i", g_iWeapons[iWeap], Level);
		
		emit_sound(iPlayer, CHAN_STATIC, level_up, 1.0, ATTN_NORM, 0, PITCH_NORM);
		
		Save(iPlayer);
	}
	
	Point_GrenadeMenu(iPlayer);
	return PLUGIN_HANDLED;
}

public Point_MainMenu(iPlayer)
{
	//Menu Title
	new title[70]; formatex(title, sizeof(title) - 1, "\r[ArtGames Mod] \w- \yUpgade Menu^n\yYour Points: \r%i", g_iPoint[iPlayer]);
	
	//Create the menu
	new menu = menu_create(title, "MainMenu_Handle");
	new iNumber[5], iCost, szOption[80], Amount, Level, Level2, text_jt[5];
	
	
	//Browse through all menu items
	for( new iItem = 0; iItem < g_iItemCount; iItem++ )
	{	
		//Bunch of variables
		num_to_str(iItem, iNumber, 4);
		Level = g_iItemLevel[iPlayer][iItem];
		Level2 = g_iItemLevel[iPlayer][iItem] + 1;
		iCost = g_iFirstCost[iItem] * (1 << (Level2 - 1));
		Amount = g_iItemMaxVal[iItem] * g_iItemLevel[iPlayer][iItem] / g_iItemMaxLevel[iItem];
		format(text_jt, 4, "1.%d", Amount);
					
		//If the player already have maxlevel
		if( g_iItemLevel[iPlayer][iItem] >= g_iItemMaxLevel[iItem] )
		{
			if( iItem == NO_FOOTSTEPS || iItem == NO_FLASH || iItem == NO_PAIN)
			{
				formatex(szOption, 79, "\y%s: \dLevel %i/%i \r(%s)", g_iItems[iItem], Level, g_iItemMaxLevel[iItem], g_iItemShort[iItem]);
			}
			else
			{
				if(iItem == JOKES_TIME)
				{
					formatex(szOption, 79, "\y%s: \dLevel %i/%i \r(%s%s)", g_iItems[iItem], Level, g_iItemMaxLevel[iItem], text_jt, g_iItemShort[iItem]);
				}
				else
				{
					formatex(szOption, 79, "\y%s: \dLevel %i/%i \r(%i%s)", g_iItems[iItem], Level, g_iItemMaxLevel[iItem], Amount, g_iItemShort[iItem]);
				}
			}
		}
		//If the player cant afford the item
		else if( g_iPoint[iPlayer] < iCost )
		{
			if( iItem == NO_FOOTSTEPS || iItem == NO_FLASH || iItem == NO_PAIN)
			{
				formatex(szOption, 79, "\d%s: \wLevel %i/%i \r(%s) \y%i Point", g_iItems[iItem], Level, g_iItemMaxLevel[iItem], g_iItemShort[iItem], iCost);
			}
			else
			{
				if(iItem == JOKES_TIME)
				{
					formatex(szOption, 79, "\d%s: \wLevel %i/%i \r(%s%s) \y%i Point", g_iItems[iItem], Level, g_iItemMaxLevel[iItem], text_jt, g_iItemShort[iItem], iCost);
				}
				else
				{
					formatex(szOption, 79, "\d%s: \wLevel %i/%i \r(%i%s) \y%i Point", g_iItems[iItem], Level, g_iItemMaxLevel[iItem], Amount, g_iItemShort[iItem], iCost);
				}
			}
		}
		//If the player has not maxed out the item
		else if( g_iItemLevel[iPlayer][iItem] < g_iItemMaxLevel[iItem] )
		{
			if( iItem == NO_FOOTSTEPS || iItem == NO_FLASH || iItem == NO_PAIN)
			{
				formatex(szOption, 79, "\r%s: \wLevel %i/%i \r(%s) \y%i Point", g_iItems[iItem], Level, g_iItemMaxLevel[iItem], g_iItemShort[iItem], iCost);
			}
			else
			{
				if(iItem == JOKES_TIME)
				{
					formatex(szOption, 79, "\r%s: \wLevel %i/%i \r(%s%s) \y%i Point", g_iItems[iItem], Level, g_iItemMaxLevel[iItem], text_jt, g_iItemShort[iItem], iCost);
				}
				else
				{
					formatex(szOption, 79, "\r%s: \wLevel %i/%i \r(%i%s) \y%i Point", g_iItems[iItem], Level, g_iItemMaxLevel[iItem], Amount, g_iItemShort[iItem], iCost);
				}
			}
		}
		
		//Add all the menu items
		menu_additem(menu, szOption, iNumber);
	}
	
	//Display the menu
	menu_display(iPlayer, menu, 0);
	
	return PLUGIN_HANDLED;
}

public MainMenu_Handle(iPlayer, menu, item)
{
	//Get the menu data
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		Point_StartMenu(iPlayer);
		return PLUGIN_HANDLED;
	}
	
	//Bunc of variables
	new data[6], iName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	
	new iItem = str_to_num( data ), iCost, Level;
	Level = g_iItemLevel[iPlayer][iItem] + 1;
	iCost = g_iFirstCost[iItem] * (1 << (Level - 1));
	
	//If player has maxed out the item
	if( g_iItemLevel[iPlayer][iItem] == g_iItemMaxLevel[iItem] )
	{
		Print(iPlayer, "^x04%s ^03максимального уровня!", g_iItems[iItem]);
		
		emit_sound(iPlayer, CHAN_STATIC, error, 1.0, ATTN_NORM, 0, PITCH_NORM);
	}
	//If the player cant afford the item
	else if( g_iPoint[iPlayer] < iCost )
	{
		Print(iPlayer, "^x03Вам нехватает поинтов чтобы прокачать ^04%s ^03Уровень: ^04%i", g_iItems[iItem], Level);
		
		emit_sound(iPlayer, CHAN_STATIC, error, 1.0, ATTN_NORM, 0, PITCH_NORM);
	}
	//Take Point, Print and give level
	else
	{
		//Take Point
		g_iPoint[iPlayer] -= iCost;
		
		//Give a level
		g_iItemLevel[iPlayer][iItem] += 1;
		
		//Print out to the player that he/she bought an item with corresponding level
		Print(iPlayer, "^x03Вы прокачали ^04%s ^03Уровень: ^04%i", g_iItems[iItem], Level);
		
		emit_sound(iPlayer, CHAN_STATIC, level_up, 1.0, ATTN_NORM, 0, PITCH_NORM);
		
		Save(iPlayer);
	}
	
	Point_MainMenu(iPlayer);
	return PLUGIN_HANDLED;
}

public ShowReturnMenu(iPlayer)
{
	if(get_pcvar_num(plugin_on) != 1)
		return PLUGIN_HANDLED;
		
	new title[70]; formatex(title, sizeof(title) - 1, "\r[ArtGames Mod] \w- \yUpgade Return Menu^n\yYour Points: \r%i", g_iPoint[iPlayer]);
	new menu = menu_create(title, "ReturnMenu_Handle");
	
	new szOption[80], iNumber[6], text_jt[5], Amount, Level, iCost, vip_player;
	
	for( new iItem = 0; iItem < g_iItemCount; iItem++ )
	{
		vip_player = 0;
		num_to_str(iItem, iNumber, 5);
		Level = g_iItemLevel[iPlayer][iItem];
		iCost = g_iFirstCost[iItem] * (1 << (Level)) / 4;
		Amount = g_iItemMaxVal[iItem] * g_iItemLevel[iPlayer][iItem] / g_iItemMaxLevel[iItem];
		format(text_jt, 4, "1.%d", Amount);
		
		if( g_iItemLevel[iPlayer][iItem] <= 0 )
		{
			if( iItem == NO_FOOTSTEPS || iItem == NO_FLASH || iItem == NO_PAIN)
			{
				formatex(szOption, 79, "\d%s: \wLevel %i/%i \r(%s)", g_iItems[iItem], Level, g_iItemMaxLevel[iItem], g_iItemShort[iItem]);
			}
			else
			{
				if(iItem == JOKES_TIME)
				{
					formatex(szOption, 79, "\d%s: \wLevel %i/%i \r(%s%s)", g_iItems[iItem], Level, g_iItemMaxLevel[iItem], text_jt, g_iItemShort[iItem]);
				}
				else
				{
					formatex(szOption, 79, "\d%s: \wLevel %i/%i \r(%i%s)", g_iItems[iItem], Level, g_iItemMaxLevel[iItem], Amount, g_iItemShort[iItem]);
				}
			}
		}
		else if( g_iItemLevel[iPlayer][iItem] <= g_iItemMaxLevel[iItem] )
		{
			if( iItem == NO_FOOTSTEPS || iItem == NO_FLASH || iItem == NO_PAIN)
			{
				formatex(szOption, 79, "\y%s: \wLevel %i/%i \r(%s) \y%i Point", g_iItems[iItem], Level, g_iItemMaxLevel[iItem], g_iItemShort[iItem], iCost);
			}
			else
			{
				if(iItem == JOKES_TIME)
				{
					formatex(szOption, 79, "\y%s: \wLevel %i/%i \r(%s%s) \y%i Point", g_iItems[iItem], Level, g_iItemMaxLevel[iItem], text_jt, g_iItemShort[iItem], iCost);
				}
				else
				{
					formatex(szOption, 79, "\y%s: \wLevel %i/%i \r(%i%s) \y%i Point", g_iItems[iItem], Level, g_iItemMaxLevel[iItem], Amount, g_iItemShort[iItem], iCost);
				}
			}
		}
		
		if(g_Vip[iPlayer])
			if(iItem == LARGE_AP)
				vip_player = 1;
				
		if(vip_player != 1)
			menu_additem(menu, szOption, iNumber);
	}
	
	for( new iWeap = 0; iWeap < g_iWeapCount; iWeap++ )
	{
		vip_player = 0;
		num_to_str(iWeap + 200, iNumber, 5);
		Level = g_iWeapLevel[iPlayer][iWeap];
		iCost = g_iFirstWCost[iWeap] * (1 << (Level)) / 4;
		Amount = g_iWeapMaxVal[iWeap] * g_iWeapLevel[iPlayer][iWeap] / g_iWeapMaxLevel[iWeap];
		
		if( g_iWeapLevel[iPlayer][iWeap] <= 0 )
		{
			if( g_iWeapClass[iWeap] == CSW_SMOKEGRENADE )
			{
				formatex(szOption, 79, "\d%s: \wLevel %i/%i \r(%i%s) (CT Only)", g_iWeapons[iWeap], Level, g_iWeapMaxLevel[iWeap], Amount, g_iWeapShort[iWeap]);
			}
			else
			{
				formatex(szOption, 79, "\d%s: \wLevel %i/%i \r(%i%s)", g_iWeapons[iWeap], Level, g_iWeapMaxLevel[iWeap], Amount, g_iWeapShort[iWeap]);
			}
		}
		else if( g_iWeapLevel[iPlayer][iWeap] <= g_iWeapMaxLevel[iWeap] )
		{
			if( g_iWeapClass[iWeap] == CSW_SMOKEGRENADE )
			{
				formatex(szOption, 79, "\y%s: \wLevel %i/%i \r(%i%s) (CT Only) \y%i Points", g_iWeapons[iWeap], Level, g_iWeapMaxLevel[iWeap], Amount, g_iWeapShort[iWeap], iCost);
			}
			else
			{
				formatex(szOption, 79, "\y%s: \wLevel %i/%i \r(%i%s) \y%i Points", g_iWeapons[iWeap], Level, g_iWeapMaxLevel[iWeap], Amount, g_iWeapShort[iWeap], iCost);
			}
		}
		
		if( g_iWeapClass[iWeap] == 2 )
		{
			menu_addblank(menu, 0);
		}
		else
		{
			if(g_Vip[iPlayer])
				if(g_iWeapClass[iWeap] == CSW_SMOKEGRENADE || g_iWeapClass[iWeap] == CSW_HEGRENADE)
					vip_player = 1;
					
			if(vip_player != 1)
				menu_additem(menu, szOption, iNumber);
		}
	}
	
	menu_display(iPlayer, menu, 0);
	
	return PLUGIN_HANDLED;
}

public ReturnMenu_Handle(iPlayer, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		Point_StartMenu(iPlayer);
		return PLUGIN_HANDLED;
	}
	
	new data[6], iName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	
	new iItem = str_to_num( data ), iCost, Level;
	
	if(iItem < 200)
	{
		Level = g_iItemLevel[iPlayer][iItem];
		iCost = g_iFirstCost[iItem] * (1 << (Level)) / 4;
	
		if( g_iItemLevel[iPlayer][iItem] <= 0 )
		{
			Print(iPlayer, "^x03Текущий уровень ^04%s^3: ^04%i", g_iItems[iItem], Level);
		
			emit_sound(iPlayer, CHAN_STATIC, error, 1.0, ATTN_NORM, 0, PITCH_NORM);
		}
		else
		{
			g_iPoint[iPlayer] += iCost;
		
			g_iItemLevel[iPlayer][iItem] -= 1;
		
			Print(iPlayer, "^x03Вы продали ^04%s^3 за %d поинтов!", g_iItems[iItem], iCost);
			Print(iPlayer, "^x03Текущий уровень улучшения ^04%s: ^3%d!", g_iItems[iItem], Level - 1);
		
			emit_sound(iPlayer, CHAN_STATIC, up_sell, 1.0, ATTN_NORM, 0, PITCH_NORM);
		
			Save(iPlayer);
		}
	}
	else
	{
		new iWeap = iItem - 200;
		Level = g_iWeapLevel[iPlayer][iWeap];
		iCost = g_iFirstWCost[iWeap] * (1 << (Level)) / 4;
	
		if( g_iWeapLevel[iPlayer][iWeap] <= 0 )
		{
			Print(iPlayer, "^x03Текущий уровень ^04%s^3: ^04%i", g_iWeapons[iWeap], Level);
		
			emit_sound(iPlayer, CHAN_STATIC, error, 1.0, ATTN_NORM, 0, PITCH_NORM);
		}
		else
		{
			g_iPoint[iPlayer] += iCost;
		
			g_iWeapLevel[iPlayer][iWeap] -= 1;
		
			Print(iPlayer, "^x03Вы продали ^04%s^3 за %d поинтов!", g_iWeapons[iWeap], iCost);
			Print(iPlayer, "^x03Текущий уровень улучшения ^04%s: ^3%d!", g_iWeapons[iWeap], Level - 1);
		
			emit_sound(iPlayer, CHAN_STATIC, up_sell, 1.0, ATTN_NORM, 0, PITCH_NORM);
		
			Save(iPlayer);
		}
	}
	
	ShowReturnMenu(iPlayer);
	return PLUGIN_HANDLED;
}

public FwdPlayerSpawn(iPlayer)
{
	if(get_pcvar_num(plugin_on) != 1)
		return PLUGIN_HANDLED;
	
	//If player is alive when spawned
	if( is_user_alive(iPlayer) )
	{

			//If player has bought extra health
			if( g_iItemLevel[iPlayer][HEALTH] >= 1 )
			{
				//Set health to its self and add the extra health
				set_user_health(iPlayer, get_user_health(iPlayer) + g_iItemMaxVal[HEALTH] * g_iItemLevel[iPlayer][HEALTH] / g_iItemMaxLevel[HEALTH]);
			}
			//If player has bought extra armor
			if( g_iItemLevel[iPlayer][ARMOR] >= 1 )
			{
				//Set armor to its self and add the extra armor
				set_user_armor(iPlayer, g_iItemMaxVal[ARMOR] * g_iItemLevel[iPlayer][ARMOR] / g_iItemMaxLevel[ARMOR]);
			}
			//If player has bought no footsteps
			if( g_iItemLevel[iPlayer][NO_FOOTSTEPS] >= 1 )
			{
				set_user_footsteps(iPlayer, 1);
			}
			
			//If player has bought Antifrost nade
			if( g_iItemLevel[iPlayer][ANTI_FROSTNADE] >= 1 )
			{
				add_user_immune(iPlayer);
			}
			else
			{
				remove_user_immune(iPlayer);
			}

			//Give weapons, the check if the player bought is in the function
			remove_task(iPlayer);
			set_task(10.0, "Set_Weapons", iPlayer);
	}
	
	if ( !is_user_alive(iPlayer) ) return HAM_IGNORED;
	
	if ( !g_reseted[iPlayer] )
	{
		ResetPlayer(iPlayer);
	}
	
	g_reseted[iPlayer] =	false;
	
	return HAM_IGNORED;
}

public calc_value(const level, const max_level, const max_value)
{
	return (max_value * level / max_level);
}

public Set_Weapons(iPlayer)
{
	if(get_pcvar_num(plugin_on) != 1)
		return PLUGIN_HANDLED;
		
	//Browse through all menu items
	new iNumber[5], bool: GiveWeapon;
	for( new iWeap = 0; iWeap < g_iWeapCount; iWeap++ )
	{
		//Bunch of variables
		num_to_str(iWeap, iNumber, 4);
		{
			static percent;
			percent = calc_value(g_iWeapLevel[iPlayer][iWeap], g_iWeapMaxLevel[iWeap], g_iWeapMaxVal[iWeap]);
			
			if(is_user_connected(iPlayer))
			{
				if( percent > 0 && (percent == 100 || random_num(1, 100) <= percent ) )
				{
					if( iWeap == AWP && !user_has_weapon(iPlayer, g_iWeapClass[AWP]) && !GiveWeapon)
					{	
						cs_set_weapon_ammo(give_item(iPlayer, g_iWeapName[AWP]), 1);
						Print(iPlayer, "^x03Вы получили Awp ^x04[%i%% шанс].", percent);
						
						GiveWeapon = true;
					}
					if( iWeap == SCOUT && !user_has_weapon(iPlayer, g_iWeapClass[SCOUT]) && !GiveWeapon)
					{	
						cs_set_weapon_ammo(give_item(iPlayer, g_iWeapName[SCOUT]), 1);
						Print(iPlayer, "^x03Вы получили Scout ^x04[%i%%% шанс].", percent);
						
						GiveWeapon = true;
					}
					if( iWeap == DEAGLE && !user_has_weapon(iPlayer, g_iWeapClass[DEAGLE]) && !GiveWeapon)
					{
						cs_set_weapon_ammo(give_item(iPlayer, g_iWeapName[DEAGLE]), 1);
						Print(iPlayer, "^x03Вы получили Deagle ^x04[%i%%% шанс].", percent);
						
						GiveWeapon = true;
					}
					if( iWeap == FIVESEVEN && !user_has_weapon(iPlayer, g_iWeapClass[FIVESEVEN]) && !GiveWeapon)
					{
						if(random_num(1, 100) <= g_iWeapMaxVal[TWO_BULLETS] * g_iWeapLevel[iPlayer][TWO_BULLETS] / g_iWeapMaxLevel[TWO_BULLETS])
						{
							cs_set_weapon_ammo(give_item(iPlayer, g_iWeapName[FIVESEVEN]), 2);
							Print(iPlayer, "^x03Вы получили Five-Seven с 2-мя патронами ^x04[%i%%% шанс].", percent);
						}
						else
						{
							cs_set_weapon_ammo(give_item(iPlayer, g_iWeapName[FIVESEVEN]), 1);
							Print(iPlayer, "^x03Вы получили Five-Seven ^x04[%i%%% шанс].", percent);
						}
						
						GiveWeapon = true;
					}
					
					if( iWeap == HE_GRENADE && !user_has_weapon(iPlayer, g_iWeapClass[HE_GRENADE]) )
					{	
						give_item(iPlayer, g_iWeapName[HE_GRENADE]);
						Print(iPlayer, "^x03Вы получили HE grenade ^x04[%i%%% шанс].", percent);
					}
					if(cs_get_user_team(iPlayer) == CS_TEAM_CT && iWeap == SMOKE_GRENADE && !user_has_weapon(iPlayer, g_iWeapClass[SMOKE_GRENADE]) )
					{	
						give_item(iPlayer, g_iWeapName[SMOKE_GRENADE]);
						Print(iPlayer, "^x03Вы получили Frost grenade ^x04[%i%%% шанс].", percent);
					}
				}
			}
		}
	}
	return PLUGIN_HANDLED;
}

//The following functions are used to give and remove, dont touch!
public CmdGivePoint(iPlayer, level, cid)
{
	if( !cmd_access(iPlayer, level, cid, 3) ) return PLUGIN_HANDLED;
	
	static arg[35];
	read_argv(1, arg, sizeof(arg) - 1);
	
	new target = cmd_target(iPlayer, arg, CMDTARGET_NO_BOTS);
	if( !target ) return PLUGIN_HANDLED;
	
	read_argv(2, arg, sizeof(arg) - 1);
	new POINT = str_to_num(arg);
	
	if( POINT <= 0 )
	{
		console_print(iPlayer, "Not enough points!");
		if( POINT < 0 )
		{
			console_print(iPlayer, "Use pm_removepoint instead!");
		}
		return PLUGIN_HANDLED;
	}
	
	if( POINT > 99999 )
	{
		console_print(iPlayer, "To much Points!");
		return PLUGIN_HANDLED;
	}
	
	read_argv(3, arg, sizeof(arg) - 1);
	new Type = str_to_num(arg);
	
	if(Type < 1 || Type > 3)
	{
		return PLUGIN_CONTINUE;
	}
	else if(Type == 1)
	{	
		g_iPoint[target] += POINT;
	}
	else if(Type == 2)
	{	
		g_iTotal[target] += POINT;
	}
	else if(Type == 3)
	{	
		g_iPoint[target] += POINT;
		g_iTotal[target] += POINT;
	}
	
	static name[2][32];
	get_user_name(iPlayer, name[0], sizeof(name[]) - 1);
	get_user_name(target, name[1], sizeof(name[]) - 1);
	
	client_print(iPlayer, print_console, "%s You gave %s %i Points!", PREFIX, name[1], POINT);
	
	static steamid[2][35];
	get_user_authid(iPlayer, steamid[0], sizeof(steamid[]) - 1);
	get_user_authid(target, steamid[1], sizeof(steamid[]) - 1);
	
	log_amx("%s (%s) gave %i Points to %s (%s)", name[0], steamid[0], POINT, name[1], steamid[1]);
	
	Save(target);
	SaveData(target);
	
	return PLUGIN_HANDLED;
}

public CmdRemovePoint(iPlayer, level, cid)
{
	if ( !cmd_access(iPlayer, level, cid, 3) ) return PLUGIN_HANDLED;
	
	static arg[35];
	read_argv(1, arg, sizeof(arg) - 1);
	
	new target = cmd_target(iPlayer, arg, CMDTARGET_NO_BOTS|CMDTARGET_ALLOW_SELF);
	if( !target ) return PLUGIN_HANDLED;
	
	read_argv(2, arg, sizeof(arg) - 1);
	new Point = str_to_num(arg);
	
	if ( Point <= 0 ) return PLUGIN_HANDLED;
	
	read_argv(3, arg, sizeof(arg) - 1);
	new Type = str_to_num(arg);
	
	if(Type < 1 || Type > 3)
	{
		return PLUGIN_CONTINUE;
	}
	else if(Type == 1)
	{	
		g_iPoint[target] -= Point;
	}
	else if(Type == 2)
	{	
		g_iTotal[target] -= Point;
	}
	else if(Type == 3)
	{	
		g_iPoint[target] -= Point;
		g_iTotal[target] -= Point;
	}
	
	new t_name[60];
	get_user_name(target, t_name, 59);

	client_print(iPlayer, print_console, "%s You removed %i Points from %s!", PREFIX, Point, t_name);
	
	Save(target);
	SaveData(target);
	
	return PLUGIN_HANDLED;
}

public ResetPoints(iPlayer, level, cid)
{
	if ( !cmd_access(iPlayer, level, cid, 1) ) return PLUGIN_HANDLED;
	
	static arg[35];
	read_argv(1, arg, sizeof(arg) - 1);
	
	new target = cmd_target(iPlayer, arg, CMDTARGET_NO_BOTS|CMDTARGET_ALLOW_SELF);
	if( !target ) return PLUGIN_HANDLED;
	
	new t_name[60];
	get_user_name(target, t_name, 59);
	
	NewUser(target);
	
	client_print(iPlayer, print_console, "You removed all points  and upgrades from %s!", t_name);
	
	Save(target);
	SaveData(target);
	
	return PLUGIN_HANDLED;
}

public ResetLevelUpgrade(iPlayer, level, cid)
{
	if ( !cmd_access(iPlayer, level, cid, 4) ) return PLUGIN_HANDLED;
	
	static arg[35];
	read_argv(1, arg, sizeof(arg) - 1);
	
	new target = cmd_target(iPlayer, arg, CMDTARGET_NO_BOTS|CMDTARGET_ALLOW_SELF);
	if( !target ) return PLUGIN_HANDLED;
	
	read_argv(2, arg, sizeof(arg) - 1);
	new upgrade = str_to_num(arg);
	
	read_argv(3, arg, sizeof(arg) - 1);
	new level = str_to_num(arg);
	
	read_argv(4, arg, sizeof(arg) - 1);
	new Type = str_to_num(arg);
	
	if(Type == 1)
		g_iItemLevel[target][upgrade] = level;
	else
		g_iWeapLevel[target][upgrade] = level;
	
	
	new t_name[60];
	get_user_name(target, t_name, 59);
	
	client_print(iPlayer, print_console, "You changed upgrade the player %s!", t_name);
	
	Save(target);
	
	return PLUGIN_HANDLED;
}

public bad_fix2() {
	new Float:gametime = get_gametime();
	if(gametime - g_gametime2 > 2.5)
		for(new i = 0; i < 32; i++)
			grenade[i] = 0;
}

public eventFlash( id ) 
{
	if(get_pcvar_num(plugin_on) != 1)
	 return PLUGIN_HANDLED;
		
	new Float:gametime = get_gametime();
	if(gametime != g_gametime) { 
		g_gametime = gametime;
		for(new i = 0; i < 33; i++) 
			g_track[i] = false;
		g_track_enemy = false;
	}    
	if(g_iItemLevel[id][NO_FLASH] >= 1) {
		g_track_enemy = true;

		message_begin(MSG_ONE, g_msgScreenFade, {0,0,0}, id);
		write_short(1);
		write_short(1);
		write_short(1);
		write_byte(0);
		write_byte(0);
		write_byte(0);
		write_byte(255);
		message_end();
	}
	
	return PLUGIN_CONTINUE;
}

public flash_delay() {
	if(g_track_enemy == false) {
		for(new i = 0; i < 33; i++) {
			if(g_track[i] == true && is_user_connected(i)) {
				message_begin(MSG_ONE, g_msgScreenFade, {0,0,0}, i) ;
				write_short(1);
				write_short(1);
				write_short(1);
				write_byte(0);
				write_byte(0);
				write_byte(0);
				write_byte(255);
				message_end();
			}
		}
	}
}

public grenade_throw2() 
{
	if(get_pcvar_num(plugin_on) != 1)
	 return PLUGIN_HANDLED;
	 
	if(g_sync_check_data == 0)
		return PLUGIN_CONTINUE;
	g_sync_check_data--;
	if(read_datanum() < 2)
		return PLUGIN_HANDLED_MAIN;

	if(read_data(1) == 11 && (read_data(2) == 0 || read_data(2) == 1))
		add_grenade_owner(last);

	return PLUGIN_CONTINUE;
}

public fire_in_the_hole() 
{
	if(get_pcvar_num(plugin_on) != 1)
	 return PLUGIN_HANDLED;
	 
	new name[32];
	read_data(3, name, 31);
	new temp_last = get_user_index(name);
	new junk;
	if((temp_last == 0) || (!is_user_connected(temp_last)))
		return PLUGIN_CONTINUE;
	if(get_user_weapon(temp_last,junk,junk) == CSW_FLASHBANG) {
		last = temp_last;
		g_sync_check_data = 2; 
	}
	return PLUGIN_CONTINUE;
}

public fire_in_the_hole2() 
{
	if(get_pcvar_num(plugin_on) != 1)
	 return PLUGIN_HANDLED;
	 
	new name[32];
	read_data(4, name, 31);
	new temp_last = get_user_index(name);
	new junk;
	if((temp_last == 0) || (!is_user_connected(temp_last)))
		return PLUGIN_CONTINUE;
	if(get_user_weapon(temp_last,junk,junk) == CSW_FLASHBANG) {    
		last = temp_last;
		g_sync_check_data = 2;
	}
	return PLUGIN_CONTINUE;
}

public add_grenade_owner(owner)
{
	new Float:gametime = get_gametime();
	g_gametime2 = gametime;
	for(new i = 0; i < 32; i++)
	{
		if(grenade[i] == 0)
		{
			grenade[i] = owner;
			return;
		}
	}
}

// from XxAvalanchexX "Flashbang Dynamic Light"
public fw_emitsound(entity,channel,const sample[],Float:volume,Float:attenuation,fFlags,pitch) {
	if(!equali(sample,"weapons/flashbang-1.wav") && !equali(sample,"weapons/flashbang-2.wav"))
		return FMRES_IGNORED;

	new Float:gametime = get_gametime();

	//in case no one got flashed, the sound happens after all the flashes, same game time
	if(gametime != g_gametime) {
		return FMRES_IGNORED;
	}
	return FMRES_IGNORED;
}
// NoFlash Blinding - End

Print(iPlayer, const sMsg[], any:...) 
{
	static i; i = iPlayer ? iPlayer : get_Player();
	if ( !i ) return;
	
	new sMessage[256];
	new len = formatex(sMessage, sizeof(sMessage) - 1, "^x04%s ", PREFIX);
	vformat(sMessage[len], sizeof(sMessage) - 1 - len, sMsg, 3);
	sMessage[192] = '^0';
		
	if(is_user_connected(iPlayer))
	{
		static msgid_SayText;
		if ( !msgid_SayText ) msgid_SayText = get_user_msgid("SayText");
	
		new const team_Names[][] =
		{
			"",
			"TERRORIST",
			"CT",
			"SPECTATOR"
		};
		
		new sTeam = get_user_team(i);
	
		team_Info(i, iPlayer, team_Names[0]);
		
		message_begin(iPlayer ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, msgid_SayText, _, iPlayer);
		write_byte(i);
		write_string(sMessage);
		message_end();
		
		team_Info(i, iPlayer, team_Names[sTeam]);
	}
}

team_Info(receiver, sender, sTeam[])
{
	static msgid_TeamInfo;
	if ( !msgid_TeamInfo ) msgid_TeamInfo = get_user_msgid("TeamInfo");
	
	message_begin(sender ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, msgid_TeamInfo, _, sender);
	write_byte(receiver);
	write_string(sTeam);
	message_end();
}

get_Player()
{
	for ( new iPlayer = 1; iPlayer <= get_maxplayers(); iPlayer++ )
	{
		return iPlayer;
	}
	
	return 0;
}

/////////////// START OF TOP 15 ///////////////

public TopPoint( iPlayer )
{
	new iPlayers[ 32 ], iNum;
	get_players( iPlayers, iNum );
		
	for( new i = 0; i < iNum; i++ )
	{
		Save( iPlayers[ i ] );
	}
		
	new Array:aRankData = ArrayCreate( RankData );

	new hVault = nvault_util_open("mm_save_top15");
	new iKeys = nvault_util_count( hVault );
		
	new eRankData[ RankData ];
	
	new iPos, szKey[ 32 ], szData[ 128 ], iTimeStamp;
		
	for( new i = 0; i < iKeys; i++ )
	{
		iPos = nvault_util_read( hVault, iPos, szKey, charsmax( szKey ), szData, charsmax( szData ), iTimeStamp );
		
		ReadVaultData( szData, charsmax( szData ), eRankData[ Rank_Time ], eRankData[ Rank_Point ], eRankData[ Rank_Name ], charsmax( eRankData[ Rank_Name ] ) );
			
		ArrayPushArray( aRankData, eRankData );
	}
		
	nvault_util_close( hVault );
		
	ArraySort( aRankData, "SortRanks" );
		
	new iTotal = ArraySize( aRankData );
		
	if( iTotal > MAX_TOP )
	{
		iTotal = MAX_TOP;
	}
		
	new html_motd [ 2500 ], len;
	if( !len )
	{
		len = formatex ( html_motd [ len ], charsmax ( html_motd ) - len, "<STYLE>body{background:#808080;color:#000000;font-family:sand-serif}table{width:100%%;font-size:16px}</STYLE><table cellpadding=2 cellspacing=0 border=0>" );
		len += formatex ( html_motd [ len ], charsmax ( html_motd ) - len, "<center><img src=^"http://i44.tinypic.com/w97052.png^"></center></img>");
		len += formatex ( html_motd [ len ], charsmax ( html_motd ) - len, "<tr align=center bgcolor=%52697B><th width=8%% align=left><font color=white>Rank: <th width=8%% align=left><font color=white>Name: <th width=8%% align=left><font color=white>Total Points:" );
	}
		
	for( new i = 0; i < iTotal; i++ )
	{
		ArrayGetArray( aRankData, i, eRankData );
			
		copy( szData, charsmax( szData ), eRankData[ Rank_Name ] );
		replace_all( szData, charsmax( szData ), "&", "&amp;" );
		replace_all( szData, charsmax( szData ), "<", "&lt;" );
		replace_all( szData, charsmax( szData ), ">", "&gt;" );
			
		LimitMOTDString( szData, 15 );
			
		TimeToString( eRankData[ Rank_Time ], szKey, charsmax( szKey ), true );
			
		len += formatex(html_motd [ len ], charsmax(html_motd)-len, "<tr><td>%i.</td><td>%s</td><td>%i</td></tr>", (i + 1), szData, eRankData[ Rank_Point ], szKey );
	}
		
	ArrayDestroy( aRankData );
	show_motd( iPlayer, html_motd, "Top Points" );
}

LimitMOTDString(string[], maxchars)
{
	new i, c, l;
	while( ( c = string[ i ] ) )
	{
		if( c == '&' )
		{
			while( string[ i ] != ';' )
			{
				i++;
			}
		}
		
		if( ++i > maxchars )
		{
			break;
		}
		
		l = i;
	}
	
	string[ l ] = EOS;
}


ReadVaultData( szData[ ], iDataMaxLen, &iTime = 0, &iPoint = 0, szName[ ] = "", iNameMaxLen = 0 )
{
	new szTime[ 11 ], szPoint[ 11 ];
	strtok( szData, szTime, charsmax( szTime ), szData, iDataMaxLen, ',' );
	strtok( szData, szPoint, charsmax( szPoint ), szName, iNameMaxLen, ',' );
	
	iTime = str_to_num( szTime );
	iPoint = str_to_num( szPoint );
}

public SortRanks( Array:aArray, iIndex1, iIndex2, iData[ ], iDataSize )
{
	new eRankData1[ RankData ], eRankData2[ RankData ];
	ArrayGetArray( aArray, iIndex1, eRankData1 );
	ArrayGetArray( aArray, iIndex2, eRankData2 );
	
	if( eRankData1[ Rank_Point ] > eRankData2[ Rank_Point ] )
	{
		return -1;
	}
	if( eRankData1[ Rank_Point ] < eRankData2[ Rank_Point ] )
	{
		return 1;
	}
	
	if( eRankData1[ Rank_Time ] > eRankData2[ Rank_Time ] )
	{
		return -1;
	}
	if( eRankData1[ Rank_Time ] < eRankData2[ Rank_Time ] )
	{
		return 1;
	}
	
	return 0;
}

TimeToString( iTime, szString[ ], iMaxLen, bool:bAbbrev = false )
{
	new iSeconds = iTime % 60; iTime /= 60;
	new iMinutes = iTime % 60; iTime /= 60;
	new iHours = iTime % 24; iTime /= 24;
	new iDays = iTime;
	
	new iLen;
	
	if( iDays )
	{
		iLen += bAbbrev ? formatex( szString, iMaxLen, "%d%c", iDays, 'd' ) : formatex( szString, iMaxLen, "%d day%s", iDays, ( iDays == 1 ) ? "" : "s" );
	}
	if( iHours )
	{
		iLen += bAbbrev ? formatex( szString[ iLen ], iMaxLen - iLen, "%s%d%c", iLen ? " " : "", iHours, 'h' ) : formatex( szString[ iLen ], iMaxLen - iLen, "%s%d hour%s", iLen ? ", " : "", iHours, ( iHours == 1 ) ? "" : "s" );
	}
	if( iMinutes )
	{
		iLen += bAbbrev ? formatex( szString[ iLen ], iMaxLen - iLen, "%s%d%c", iLen ? " " : "", iMinutes, 'm' ) : formatex( szString[ iLen ], iMaxLen - iLen, "%s%d minute%s", iLen ? ", " : "", iMinutes, ( iMinutes == 1 ) ? "" : "s" );
	}
	if( iSeconds )
	{
		iLen += bAbbrev ? formatex( szString[ iLen ], iMaxLen - iLen, "%s%d%c", iLen ? " " : "", iSeconds, 's' ) : formatex( szString[ iLen ], iMaxLen - iLen, "%s%d second%s", iLen ? ", " : "", iSeconds, ( iSeconds == 1 ) ? "" : "s" );
	}
	
	if( !iLen )
	{
		iLen = copy( szString, iMaxLen, "< 1 minute" );
	}
	
	szString[ iLen ] = EOS;
	
	return iLen;
}
	
bool:IsStrFloat(string[])
{
	new len = strlen(string);
	for ( new i = 0; i < len; i++ )
	{
		switch ( string[i] )
		{
			case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '-':	continue;
			default:							return false;
		}
	}
	
	return true;
}

ResetPlayer(iPlayer)
{
	g_roulette[iPlayer] = false;
	
	g_reseted[iPlayer] = true;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
