native add_user_immune(iPlayer);
native remove_user_immune(iPlayer);

native get_state_from_frostnades(id); // 2 - in frost, 1 - in chill, 0 - nope.

native freeze_player(id, nadeTeam, Float:time, Float:variance);
native chill_player(id, nadeTeam, Float:time, Float:variance);

native sgcm_in_stealth(id);
native sgcm_reset_maxspeed(id);

native sgcm_set_stealth_message(id, Float:time);
native sgcm_set_boots_message(id, Float:time);
native sgcm_get_blockmaker_info(id, viewer, g_iLevel, g_iPoint, g_iTotal, exp, knife, Float:k_cooldown, bool:stucked);

#define ADMINS_FLAGS 		"abcdefijmu"
#define VIPS_FLAGS 			"bioqrst"
#define ADM_VIPS_FLAGS		"abcdefijmoqrstu"
#define RIGHTS_TIME			2592000

#define FROST_RADIUS		280.0

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <hamsandwich>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <regex>
#include <nvault_util>
#include <nvault>

new bool:first_round = true;
new bool:get_in[33];
new get_in_count[33];
new menutype[33];
new accounttype[33];
new user_password[33][48];
new user_tries[33];

new b_stealth[33];
new b_boots[33];
new b_should_no_pain[33];

new user_is_ranked_vip[33];

new user_admin_days[33];
new user_vip_days[33];

new g_vault;
new g_hVault;
new g_keys_vault;

//#pragma semicolon 1

new Float:f_round_time;
new f_cvar_round_time;
new Float:f_cvar_data_round_time;

#define PLUGIN "ScreamPoints"
#define VERSION "1.4"
#define AUTHOR "-"
#define PREFIX "^04[ScreamGaming]^3"

//music
#define PITCH_NORM 100
#define ATTN_NORM 0.80
#define CHAN_STREAM 5

const MAX_CLIENTS = 32;

new iDiName;
new bool:g_stucked[33];

enum _:RankData
{
	Rank_Pass[48],
	Rank_Time,
	Rank_Point,
	Rank_Rounds,
	Rank_Kills,
	Rank_Deaths,
	Rank_Suicides,
	Rank_Survives,
	Rank_VIP,
	Rank_Name[36]
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

new const g_iWFirstCost[g_iWeapCount] =
{
	250,
	400,
	300,
	200,
	750,
	500, //Cost of first level of HE Grenade
	750 //Cost of first level of FROST grenade
};


new const g_iWStepCost[g_iWeapCount] =
{
	250, 
	400, 
	500,
	200,
	350,
	450,
	600
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
	3,
	10,
	15,
	36,
	36,
	36
};

new g_iWeapMaxLevel[g_iWeapCount] =
{
	3,
	3,
	2,
	3,
	3,
	3,
	3
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

new const g_iWFirstLevel[g_iWeapCount] =
{
	5,
	10,
	5,
	5,
	15,
	15,
	15
};

new const g_iWStepLevel[g_iWeapCount] =
{
	5,
	10,
	7,
	5,
	5,
	10,
	10
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

new const g_iItemsPrefix[3][] =
{
	"bangs",
	"nades",
	"knives"
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
	"Anti-Flash",
	"No Pain Shock",
	"Anti-Frost"
};

new const g_iFirstCost[g_iItemCount] =
{
	500, 
	350, 
	3000,
	250,
	1000, 	//5
	1000,
	10000, 	// MegaWeapChance
	5000,
	800,
	750,	//10
	12000,
	17500,
	25000,
	25000
};

new const g_iStepCost[g_iItemCount] =
{
	1000, 
	350, 
	4000,
	250,
	1000,	//5
	1500,
	1, // MegaWeapChance
	2500,
	800,
	1000,	//10
	1,
	17500,
	1,
	25000
};

new const g_iItemShort[g_iItemCount][] =
{
	" HP",
	" AP",
	"% Chance",
	"%",
	" HP",
	"%",
	"% Chance",
	"% Chance",
	"s",
	"% Chance",
	"Yes",
	"Anti-Flash",
	"Yes",
	"Anti-Frost"
};

new const g_iItemMaxVal[g_iItemCount] =
{
	100,
	200,
	30,
	45,
	50,		//5
	35,
	0,		//MWC
	30,
	5,
	20,		//10
	1,
	2,
	1,
	2
};

new const g_iItemMaxLevel[g_iItemCount] =
{
	5,
	5,
	3,
	9,
	5,		//5
	5,
	1,		//MWC
	3,
	5,
	4,		//10
	1,
	2,
	1,
	2
};

new const g_iItemFirstLevel[g_iItemCount] =
{
	1,
	10,
	30,
	5,
	15,
	15,
	45,
	5,
	15,
	20,
	35,
	35,
	40,
	55
};

new const g_iItemStepLevel[g_iItemCount] =
{
	20,
	5,
	20,
	5,
	15,
	15,
	45,
	10,
	10,
	10,
	35,
	35,
	40,
	20
};

// ************************ Knives are started here ************************

enum _:g_iKnivesCount
{
	SWAP,
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
	REFLECT,
	STANDART
};

new Float:k_cooldown[32];
new g_iNextRoundKnife[33];
new g_iPreNextRoundKnife[33];
new g_iKnifeLevel[33][g_iKnivesCount];

new const g_iKnifeFirstCost[g_iKnivesCount] =
{
	500, 
	350, 
	3000,
	250,
	1000, 	// 5
	1000,
	10000, 	// 7
	5000,
	800,
	750,	// 10
	12000,
	17500,
	25000
};

new const g_iKnifeStepCost[g_iKnivesCount] =
{
	1000, 
	350, 
	4000,
	250,
	1000,	//5
	1500,
	1, 		// 7
	2500,
	800,
	1000,	//10
	1,
	17500,
	25000
};

/*new const g_iKnifeMaxVal[g_iKnivesCount] =
{
	100,
	200,
	30,
	45,
	50,		//5
	35,
	0,		//7
	30,
	5,
	20,		//10
	1,
	2,
	1
};*/

new const g_iKnifeMaxLevel[g_iKnivesCount] =
{
	5,
	3,
	3,
	3,
	3,
	3,
	3,
	3,
	3,
	3,
	3,
	3,
	3
};

new const g_iKnifeFirstLevel[g_iKnivesCount] =
{
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1
};

new const g_iKnifeStepLevel[g_iKnivesCount] =
{
	1,
	5,
	20,
	5,
	15,
	15,
	45,
	10,
	10,
	10,
	35,
	35,
	40
};

new const g_iKnives[g_iKnivesCount][] =
{
	"Swap Knife", 		// got it
	"Ninja Knife",		// got it
	"Fast Blade",		// got it
	"Flash Blade",		// got it
	"Poison Sting",		// got it
	"Push Blade",		// almost got it
	"Titan Blade",		// -
	"Fire Knife",		// -
	"Frost Knife",		// in progress
	"Thunder Knife",	// got it
	"Vampire Blade",	// -
	"Reflect Blade",	// -
	"Standart Knife"	// got it
};

new const g_iKnifeCoolDown[g_iKnivesCount] [] =
{
	"1.0", //240
	"1.0", 
	"1.0",
	"1.0",
	"1.0",
	"1.0",
	"1.0",
	"1.0",
	"1.0",
	"1.0", //300
	"1.0",
	"1.0",
	"1.0"
}

new const g_iKnivesModel_v[g_iKnivesCount][] =
{
	"models/ArtGames/v1/Another/knives/v_swap.mdl",
	"models/ArtGames/v1/Another/knives/v_ninja.mdl",
	"models/ArtGames/v1/Another/knives/v_fast.mdl",
	"models/ArtGames/v1/Another/knives/v_flash.mdl",
	"models/ArtGames/v1/Another/knives/v_poison.mdl",
	"models/ArtGames/v1/Another/knives/v_push.mdl",
	"models/ArtGames/v1/Another/knives/v_titan.mdl",
	"models/ArtGames/v1/Another/knives/v_fire.mdl",
	"models/ArtGames/v1/Another/knives/v_frost.mdl",
	"models/ArtGames/v1/Another/knives/v_thunder.mdl",
	"models/ArtGames/v1/Another/knives/v_vampire.mdl",
	"models/ArtGames/v1/Another/knives/v_reflect.mdl",
	"models/ArtGames/v1/Another/knives/v_standart.mdl"
};

new const g_iKnivesModel_p[g_iKnivesCount][] =
{
	"models/ArtGames/v1/Another/knives/p_swap.mdl",
	"models/ArtGames/v1/Another/knives/p_ninja.mdl",
	"models/ArtGames/v1/Another/knives/p_fast.mdl",
	"models/ArtGames/v1/Another/knives/p_flash.mdl",
	"models/ArtGames/v1/Another/knives/p_poison.mdl",
	"models/ArtGames/v1/Another/knives/p_push.mdl",
	"models/ArtGames/v1/Another/knives/p_titan.mdl",
	"models/ArtGames/v1/Another/knives/p_fire.mdl",
	"models/ArtGames/v1/Another/knives/p_frost.mdl",
	"models/ArtGames/v1/Another/knives/p_thunder.mdl",
	"models/ArtGames/v1/Another/knives/p_vampire.mdl",
	"models/ArtGames/v1/Another/knives/p_reflect.mdl",
	"models/ArtGames/v1/Another/knives/p_standart.mdl"
};

///////////////////////////////////////////////// KNIVES ACTIONS AND PARAMS /////////////////////////////////////////////////////////

new thrown_grenade[33];
new swapRadius[5] = { 300, 525, 750, 950, 1200 };

new iray_ninjaAlpha[3] = { 90, 55, 25 };
new Float:f_ninjaStealthTime[3] = { 2.5, 5.5, 10.0 };

new i_fastAvoidPercents[3] = { 10, 20, 35 };
new Float:f_fastBootsTime[3] = { 3.5, 7.0, 12.0 };
new Float:fray_fastSpeed[4] = { 0.0, 5.0, 10.0, 15.0 };

new Float:f_flashed[33];

new i_flashWaveLife[3] = { 0, 1, 2 };
new i_flashLightRadius[3] = { 200, 250, 300 };
new Float:f_flash_time[3] = { 4.5, 8.5, 12.5};

new i_frostWaveLife[3] = { 0, 1, 2 };
new i_frostFrostRadius[3] = { 125, 175, 225 };
new i_frostLightRadius[3] = { 200, 250, 300 };

new Float:f_frost_time[3] = { 3.0, 5.0, 7.5};
new Float:f_frostVariance[3] = { 0.5, 1.5, 2.5 };

new Float:f_chill_time[3] = { 2.5, 3.5, 4.5};
new Float:f_chillVariance[3] = { 0.5, 1.5, 2.5 };

new i_pushWaveLife[3] = { 0, 1, 2 };
new i_pushLightRadius[3] = { 200, 250, 300 };
new i_pushStrange[3] = { 550, 850, 1250 };

new i_poisoned[33];
new i_poison_attacker[33];
new Float:f_poisoned_dmg[33];

new i_poison_time[3] = { 100, 200, 300 };
new Float:f_poison_dmg[3] = { 1.0, 2.0, 3.0 };

new thunderRadius[3] = { 500, 1000, 1500 };
new Float:thunderMinDMG[3] = { 30.0, 50.0, 75.0 }; 
new Float:thunderMaxDMG[3] = { 70.0, 110.0, 165.0 };

///////////////////////////////////////////////// KNIVES ACTIONS AND PARAMS /////////////////////////////////////////////////////////

new const gszExperienceTable[102] =
{ 
	// Say /pm - до 100
	0, 100,    300,    600,    1000,   1500,   2100,   2800,   3600,   4500,   5500,  	//
	6600,   7800,   9100,   10500,  12000,  13600,  15300,  17100,  19000,  21000,  	// 
	23100,  25300,  27600,  30000,  32500,  35100,  37800,  40600,  43500,  46500,  	// 
	49600,  52800,  56100,  59500,  63000,  66600,  70300,  74100,  78000,  82000,  	// 
	86100,  90300,  94600,  99000,  103500, 108100, 112800, 117600, 122500, 127500, 	// 
	132600, 137800, 143100, 148500, 154000, 159600, 165300, 171100, 177000, 183000,		// 
	189100, 195300, 201600, 208000, 214500, 221100, 227800, 234800, 241500, 248500, 	// 
	255600, 262800, 270100, 277500, 285000, 292600, 300300, 308100, 316000, 324000, 	// 
	332100, 340300, 348600, 357000, 365500, 374100, 382800, 391600, 400500, 409500, 	// 
	418600, 427800, 437100, 446500, 456000, 465600, 475300, 485100, 495000, 512000, 750000  	//
};

new const gszExperienceName[13][32] =
{
	"[Say /pm]",             // до 100
	"[Новичок]",             // до 5500
	"[Любитель]",            // в 5500
	"[Профессионал]",        // в 21000
	"[Задрот]",              // в 46500
	"[Нагибатор]",           // в 82000
	"[Задротище]",           // в 127500
	"[Читор]",               // в 183000
	"[Перун]",               // в 248500
	"[Святой]",              // в 324000
	"[Терминатор]",          // в 409500
	"[Скиллотрах]",          // в 512000
	"[Отец Сервера]"         // в 750000
};

new const szCostTable[11] =
{
	1,
	2,
	4,
	7,
	11,
	16,
	22,
	29,
	37,
	46,
	1
};

/*new msg[33], grenade_counter;
new roundGrenades[1024];
new bool: round_end;*/

#define MAX_TOP 15

//for chat **********//

new TeamInfo;
new SayText;

new isAlive;
//new player_id;

new s_Msg[128];
new s_Name[32];
new Message[256];

//**********//

new VIP_NAME[32];
new Float:VIP_GO_TIME;
new VIP_CHECK_TIME = 2592000; //60*60*24*30
	
new g_iPoint[MAX_CLIENTS + 1];
new g_iTotal[MAX_CLIENTS + 1];
new g_iLevel[MAX_CLIENTS + 1];
new g_iRankPoint[MAX_CLIENTS + 1];

new g_iChoose[MAX_CLIENTS + 1];

#define MAX_STATS 6
new g_iStats[MAX_CLIENTS + 1][MAX_STATS];
// 0 - р, 1 - к, 2 - см, 3 - суицид, 4 - затащил, 5 - п

new pm_Name[MAX_CLIENTS + 1][32];

new g_iTime[MAX_CLIENTS + 1];
new g_iTimeOffset[MAX_CLIENTS + 1];
	
new g_iItemLevel[MAX_CLIENTS + 1][g_iItemCount];
new g_iWeapLevel[MAX_CLIENTS + 1][g_iWeapCount];

new g_iAuthID[33][36];
new bool:g_iRevivedOnce[32];
new Float:g_gametime;
new bool:g_reseted[33];
new bool:g_roulette[33];
new bool:g_track[33];
new bool:g_track_enemy;
new g_msgScreenFade;

// ACCESS //*****
new g_Vip[33];
new g_admin[33];

// CVARS!!!!!!!
new agm_status;
new players_num;
new agm_kills_points;
new agm_deaths_points;
new agm_suicides_points;

new Regex:g_SteamID_pattern;
new g_regex_return;

//clients
new g_first_client;
new g_max_clients;

new bool:g_iAuthStatus[33];

new lightning, g_smoke, spr_blast;

//music

new const error[] =        			"ScreamGaming/v2/points/i_error_buy.wav";
new const respawn[] =      			"ScreamGaming/v2/points/i_respawn.wav";
new const item_level_up[] = 		"ScreamGaming/v2/points/i_lvl_up.wav";
new const item_sell[] = 			"ScreamGaming/v2/points/i_sell.wav";
new const point_block[] =   		"ScreamGaming/v2/points/p_survive.wav";
new const p_lvl_up[] =   			"ScreamGaming/v2/points/p_lvl_up.wav";
new const p_suicide[] =   			"ScreamGaming/v2/points/p_suicide.wav";

new const k_im_poisoned[] = 		"ScreamGaming/v2/points/k_poisoned.wav";
new const k_spell_swap[] =   		"ScreamGaming/v2/points/k_spell_swap.wav";
new const k_spell_ninja[] = 		"ScreamGaming/v2/effect/stealth.wav";	
new const k_spell_fast[] = 			"ScreamGaming/v2/effect/bootsofspeed.wav";
new const k_spell_thunder[] =    	"ambience/thunder_clap.wav";
new const k_spell_thunder_2[] =   	"ScreamGaming/v2/points/k_spell_thunder.wav";

public plugin_precache()
{
	precache_sound("warcraft3/frostnova.wav"); // grenade explodes
	
	precache_sound(error);
	precache_sound(respawn);
	precache_sound(item_level_up);
	precache_sound(item_sell);
	precache_sound(point_block);
	precache_sound(p_lvl_up);
	precache_sound(p_suicide);
	
	precache_sound(k_im_poisoned);
	precache_sound(k_spell_swap);
	precache_sound(k_spell_ninja);
	precache_sound(k_spell_fast);
	precache_sound(k_spell_thunder);
	precache_sound(k_spell_thunder_2);
	
	for(new k = 0; k < g_iKnivesCount; k++)
	{
		precache_model(g_iKnivesModel_v[k]);
		precache_model(g_iKnivesModel_p[k]);
	}
	
	lightning = precache_model("sprites/lgtning.spr");
	g_smoke = precache_model("sprites/steam1.spr");
	
	spr_blast = precache_model("sprites/shockwave.spr");
	
	return PLUGIN_CONTINUE;
}

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_clcmd( "say /rvt", "rvt" );
	register_clcmd( "say_team /rvt", "rvt" );
	register_clcmd( "say /rankviptime", "rvt" );
	register_clcmd( "say_team /rankviptime", "rvt" );
	register_clcmd( "say /settings", "AuthAccChangeMenu" );
	register_clcmd( "say_team /settings", "AuthAccChangeMenu" );
	register_clcmd( "say /buy", "BuyMenuShow" );
	register_clcmd( "say_team /buy", "BuyMenuShow" );
	register_clcmd( "say /force_check_vip", "ForceCheckVIP" );
	register_clcmd( "say_team /force_check_vip", "ForceCheckVIP" );
	
	register_clcmd( "+skill", "do_action" );
	
	register_message(get_user_msgid("ShowMenu"), "message_ShowMenu");
	register_message(get_user_msgid("VGUIMenu"), "message_VGUIMenu");
	
	//Register Spawn
	RegisterHam( Ham_Spawn, "player", "FwdPlayerSpawn", 1 );
	
	//Open MainMenu
	new command[]			= "Point_StartMenu";
	new command2[]			= "ResetMenu";
	
	register_clcmd( "say /agm", command );
	register_clcmd( "say /pm", command );
	register_clcmd( "say /xp", command );
	register_clcmd( "say_team /agm", command );
	register_clcmd( "say_team /pm", command );
	register_clcmd( "say_team /xp", command );
	
	register_clcmd( "say", "CmdSay");
	register_clcmd( "say_team", "CmdSayTeam");
	
	register_clcmd( "say /top", "TopPoint", -1);
	register_clcmd( "say /top15", "TopPoint", -1);
	
	register_clcmd( "say_team /top", "TopPoint", -1);
	register_clcmd( "say_team /top15", "TopPoint", -1);
	
	register_clcmd( "say /reset", command2 );
	register_clcmd( "say_team /reset", command2 );
	
	register_clcmd("___enter_the_number", "RandomForPlayer", -1);
	register_clcmd("___print_you_value", "GivePointsIPlayer", -1);
	
	register_clcmd("_write_your_password", "PasswordChecker", -1);
	register_clcmd("_choose_your_password", "NewPasswordChecker", -1);
	register_clcmd("_print_your_password", "ChangePasswordChecker", -1);
	register_clcmd("_rechoose_your_password", "ReChangePasswordChecker", -1);
	register_clcmd("_type_activation_code", "TriedActivate", -1);
	register_clcmd("_type_new_activation_code", "TriedAddActivation", -1);
	
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
	register_event("Damage", "event_redDamageScreen", "b", "2>0")
	
	register_event("CurWeapon", "CurWeapon", "be", "1=1");
	
	//Get user screenfade
	g_msgScreenFade = get_user_msgid("ScreenFade");
	
	//Register ScreenFade
	register_event("ScreenFade", "eventFlash", "be", "4=255", "5=255", "6=255", "7>199");
	
	//Register when someone/something throws grenade
	//register_event("99", "grenade_throw2", "b");
	
	//Register Commands
	register_concmd("agm_give_point", "CmdGivePoint", ADMIN_LEVEL_D, "<nick, #userid, authid> <amount of points> <1 - ap, 2 - gp, 3 exp>");
	register_concmd("agm_remove_point", "CmdRemovePoint", ADMIN_LEVEL_D, "<nick, #userid, authid> <amount of points> <1 - ap, 2 - gp, 3 exp>");
	register_concmd("agm_reset_point", "ResetPoints", ADMIN_LEVEL_D, "<nick, #userid, authid>");
	register_concmd("agm_change_upgrade", "ResetLevelUpgrade", ADMIN_LEVEL_D, "<nick, #userid, authid> <number> <level> <1 - item, any - weapon>");
	
	agm_status = register_cvar("agm_status", "4");
	agm_kills_points = register_cvar("agm_kills_points", "5");
	agm_deaths_points = register_cvar("agm_deaths_points", "1");
	agm_suicides_points = register_cvar("agm_suicides_points", "2");
	players_num = register_cvar("agm_pnum", "4");
	
	new err[2];
	g_SteamID_pattern = regex_compile("^^STEAM_0:(0|1):\d+$", g_regex_return, err, sizeof(err) - 1);
	
	g_first_client = 1;
	g_max_clients = get_maxplayers();
	
	SayText = get_user_msgid("SayText");
	TeamInfo = get_user_msgid("TeamInfo");
	
	g_vault = nvault_open("agm_save");
	g_hVault = nvault_open("agm_save_top");
	g_keys_vault = nvault_open("agm_pay_keys");
	
	if (!dir_exists("mode") || !file_exists("mode/Rank_VIP.txt")) 
	{
		mkdir("mode");
		VIP_GO_TIME = VIP_CHECK_TIME * 1.0;
		
		new time_to_vip[32];
		format(time_to_vip, 31, "%f", VIP_GO_TIME);
		
		write_file("mode/Rank_VIP.txt", time_to_vip, 0);
		formatex(VIP_NAME, charsmax(VIP_NAME), "x");
	}
	else
	{
		new time[64], len;
		read_file("mode/Rank_VIP.txt", 0, time, charsmax(time), len);
		VIP_GO_TIME = str_to_float(time);
		
		CheckVipName();
	}
	
	set_task( VIP_GO_TIME, "CheckVip", 0, _, _, "a", 1);
	set_task( 0.1, "ShowMessage", 0, _, _, "b");
	
	usersChecker();
}

public plugin_cfg(){
	f_cvar_round_time = register_cvar("mp_roundtime", "3.0");
	f_cvar_data_round_time = get_pcvar_float(f_cvar_round_time);
}

public ForceCheckVIP(id){
	if(!(get_user_flags(id) & ADMIN_LEVEL_D)){
		return PLUGIN_CONTINUE;
	}
	
	CheckVip();
	return PLUGIN_HANDLED;
}

public usersChecker(){
	nvault_close(g_vault);
	g_vault = nvault_open("agm_save");
	nvault_close(g_hVault);
	g_hVault = nvault_open("agm_save_top");

	new hVault = nvault_util_open("agm_save_top");
	new iKeys = nvault_util_count( hVault );
	
	new iPos, szKey[ 32 ], szData[256], iTimeStamp;
	new time_data[256], time_reader[64], user_pass[48];
	new vip_days, admin_days, lowest_time_a, lowest_time_v;
	
	for( new i = 0; i < iKeys; i++ )
	{
		iPos = nvault_util_read( hVault, iPos, szKey, charsmax( szKey ), szData, charsmax( szData ), iTimeStamp );
		
		if(nvault_get(g_vault, szKey, szData, charsmax(szData))){
			strbreak(szData, time_reader, sizeof(time_reader) - 1, szData, sizeof(szData) - 1);
			format(user_pass, charsmax(user_pass), "%s", time_reader);
			format(time_data, charsmax(time_data), "%s", time_reader);
			
			for( new c = 0; c < g_iItemCount + g_iWeapCount + g_iKnivesCount + 4; c++ )
			{
				strbreak(szData, time_reader, sizeof(time_reader) - 1, szData, sizeof(szData) - 1);
				format(time_data, charsmax(time_data), "%s %s", time_data, time_reader);
			}
			
			strbreak(szData, time_reader, sizeof(time_reader) - 1, szData, sizeof(szData) - 1);
			admin_days = str_to_num(time_reader);
			if(admin_days - floatround(get_gametime()) <= 0){ admin_days = 0; }
			else{ if(admin_days < lowest_time_a || lowest_time_a == 0){ lowest_time_a = admin_days - floatround(get_gametime()); } }
			format(time_data, charsmax(time_data), " %s %i", time_data, admin_days);
			
			strbreak(szData, time_reader, sizeof(time_reader) - 1, szData, sizeof(szData) - 1);
			vip_days = str_to_num(time_reader);
			if(vip_days - floatround(get_gametime()) <= 0){ vip_days = 0; }
			else{ if(vip_days < lowest_time_v || lowest_time_v == 0){ lowest_time_v = vip_days - floatround(get_gametime()); } }
			format(time_data, charsmax(time_data), "%s %i", time_data, vip_days);
			
			nvault_set(g_vault, szKey, time_data);
		}else log_to_file("AGM_log.txt", "Error! USER DOESN`T EXISTS! [usersChecker]");
		
		for(new i = 1; i <= g_max_clients; i++){
			if(equal(user_password[i], user_pass) && is_user_connected(i)){
				if(admin_days <= 0 && user_admin_days[i] > 0){
					user_admin_days[i] = 0;
					Print(i, "^4Время вашей админки истекло! ^3Хотите продлить её? Напишите в чат ^4/buy^3.");
					CheckAccess(i);
				}
				
				if(vip_days <= 0 && user_vip_days[i] > 0){
					user_vip_days[i] = 0;
					Print(i, "^4Время вашего VIP-статуса истекло! ^3Хотите продлить? Напишите в чат ^4/buy^3.");
					CheckAccess(i);
				}
			}
		}
	}
	
	nvault_util_close(hVault);
	
	nvault_close(g_vault);
	g_vault = nvault_open("agm_save");
	nvault_close(g_hVault);
	g_hVault = nvault_open("agm_save_top");
	
	if(lowest_time_a > 0 && (lowest_time_a <= lowest_time_v || lowest_time_v == 0)){
		set_task(lowest_time_a * 1.0, "usersChecker", 7774553613, _, _, "a", 1);
	}
	else if(lowest_time_v > 0){
		set_task(lowest_time_v * 1.0, "usersChecker", 7774553613, _, _, "a", 1);
	}
}

public plugin_end()
{
	new time_to_vip[32];
	format(time_to_vip, 31, "%f", VIP_GO_TIME - get_gametime());
	write_file("mode/Rank_VIP.txt", time_to_vip, 0);
	usersCheckerEnd();
}

public usersCheckerEnd(){
	nvault_close(g_vault);
	g_vault = nvault_open("agm_save");
	nvault_close(g_hVault);
	g_hVault = nvault_open("agm_save_top");

	new hVault = nvault_util_open("agm_save_top");
	new iKeys = nvault_util_count( hVault );
	
	new iPos, szKey[ 32 ], szData[256], iTimeStamp;
	new time_data[256], time_reader[64], user_pass[48];
	new vip_days, admin_days;
	
	for( new i = 0; i < iKeys; i++ )
	{
		iPos = nvault_util_read( hVault, iPos, szKey, charsmax( szKey ), szData, charsmax( szData ), iTimeStamp );
		
		if(nvault_get(g_vault, szKey, szData, charsmax(szData))){
			strbreak(szData, time_reader, sizeof(time_reader) - 1, szData, sizeof(szData) - 1);
			format(user_pass, charsmax(user_pass), "%s", time_reader);
			format(time_data, charsmax(time_data), "%s", time_reader);
			
			for( new c = 0; c < g_iItemCount + g_iWeapCount + g_iKnivesCount + 4; c++ )
			{
				strbreak(szData, time_reader, sizeof(time_reader) - 1, szData, sizeof(szData) - 1);
				format(time_data, charsmax(time_data), "%s %s", time_data, time_reader);
			}
			
			strbreak(szData, time_reader, sizeof(time_reader) - 1, szData, sizeof(szData) - 1);
			admin_days = str_to_num(time_reader);
			admin_days -= floatround(get_gametime());
			if(admin_days <= 0){ admin_days = 0; }
			format(time_data, charsmax(time_data), " %s %i", time_data, admin_days);
			
			strbreak(szData, time_reader, sizeof(time_reader) - 1, szData, sizeof(szData) - 1);
			vip_days = str_to_num(time_reader);
			vip_days -= floatround(get_gametime());
			if(vip_days <= 0){ vip_days = 0; }
			format(time_data, charsmax(time_data), "%s %i", time_data, vip_days);
			
			nvault_set(g_vault, szKey, time_data);
		}else log_to_file("AGM_log.txt", "Error! USER DOESN`T EXISTS! [usersCheckerEnd]");
	}
	
	nvault_util_close(hVault);
	nvault_close(g_vault);
	nvault_close(g_hVault);
	nvault_close(g_keys_vault);
}

public do_action(id)
{
	if(get_pcvar_num(agm_status) != 1 || k_cooldown[id] >= get_gametime())
		return PLUGIN_HANDLED;
	
	if(g_iKnifeLevel[id][g_iNextRoundKnife[id]] <= 0 || !is_user_alive(id)){
		return PLUGIN_HANDLED;
	}
	
	switch(g_iNextRoundKnife[id])
	{
		case SWAP:
		{
			new target, bool:is_grenade, body;
			
			new Float:distance = get_user_aiming(id, target, body);
			
			if(!(1 <= target <= 32)){
				if(!pev_valid(thrown_grenade[id])){
					return PLUGIN_HANDLED;
				}else{
					is_grenade = true;
					target = thrown_grenade[id];
				}
			}
			
			if(g_iKnifeLevel[id][g_iNextRoundKnife[id]] < 5 && is_grenade)
			{
				Print(id, "Чтобы меняться местами ^4с гранатами^3, необходимо прокачать ^4Swap Knife^3 до^4 5 уровня^3!");
				return PLUGIN_HANDLED;
			}
			
			new Float:p_origin[3], Float:t_origin[3];
			entity_get_vector(id, EV_VEC_origin, p_origin);
			entity_get_vector(target, EV_VEC_origin, t_origin);
			
			if(is_grenade){
				distance = get_distance_f(p_origin, t_origin);
				t_origin[2] += 35;
				p_origin[2] -= 35;
			}
			
			if(distance > swapRadius[g_iKnifeLevel[id][g_iNextRoundKnife[id]]-1] * 1.0)
			{
				Print(id, "Расстояние ^4больше допустимого^3! Максимально возможное расстояние на ^4%d ^3уровне: ^4%d^3!", g_iKnifeLevel[id][g_iNextRoundKnife[id]], swapRadius[g_iKnifeLevel[id][g_iNextRoundKnife[id]]-1]);
				return PLUGIN_HANDLED;
			}
			
			entity_set_vector(target, EV_VEC_origin, p_origin);
			entity_set_vector(id, EV_VEC_origin, t_origin);
			
			g_stucked[id] = true;
			
			if(1 <= target <= g_max_clients){
				new name[36]; get_user_name(target, name, charsmax(name));
				Print(id, "Вы поменялись местами с ^4%s^3 с помощью ^4Swap Knife^3!", name);
				get_user_name(id, name, charsmax(name));
				Print(target, "^4%s ^3поменялся с вами местами с помощью ^4Swap Knife^3!", name);
			}
			else
				Print(id, "Вы поменялись местами с ^4гранатой^3 с помощью ^4Swap Knife^3!");
			
			emit_sound(id, CHAN_STATIC, k_spell_swap, 1.0, ATTN_NORM, 0, PITCH_NORM);
			k_cooldown[id] = get_gametime() + str_to_float(g_iKnifeCoolDown[SWAP]);
		}
		
		case THUNDER:
		{
			new origin[3]; new body; new target; new origin_top[3];
			new Float: distance = get_user_aiming(id, target, body);
			
			if(!(1 <= target <= 32))
				return PLUGIN_HANDLED;
			
			if(distance > thunderRadius[g_iKnifeLevel[id][g_iNextRoundKnife[id]]-1])
			{
				Print(id, "Расстояние ^4больше допустимого^3! Максимально возможное расстояние на ^4%d ^3уровне: ^4%d^3!", g_iKnifeLevel[id][g_iNextRoundKnife[id]], thunderRadius[g_iKnifeLevel[id][g_iNextRoundKnife[id]]-1]);
				return PLUGIN_HANDLED;
			}
			
			get_user_origin(target, origin);
			
			origin[2] -= 25;
			
			origin_top[0] += 150;
			origin_top[1] += 150;
			origin_top[2] += 800;
			
			new Float: min_dps = thunderMinDMG[g_iKnifeLevel[id][g_iNextRoundKnife[id]]-1];
			new Float: max_dps = thunderMaxDMG[g_iKnifeLevel[id][g_iNextRoundKnife[id]]-1];
			if(get_user_health(id)*1.0 >= min_dps + (max_dps - min_dps)/2){
				fakedamage(target, "Damage Thunder", random_float(min_dps, max_dps), DMG_CRUSH);
			}
			else{
				fakedamage(target, "Damage Thunder", max_dps, DMG_CRUSH);
			}
			
			if(!is_user_alive(target)){
				Thunder(origin_top, origin, 255, 35, 35);
				emit_sound(0, CHAN_ITEM, k_spell_thunder_2, 1.0, ATTN_NORM, 0, PITCH_NORM );
			}
			else{
				Thunder(origin_top, origin, 95, 95, 255);
				emit_sound(0, CHAN_ITEM, k_spell_thunder, 1.0, ATTN_NORM, 0, PITCH_NORM );
			}
			
			Smoke(origin, 15, 10);
			
			k_cooldown[id] = get_gametime() + str_to_float(g_iKnifeCoolDown[THUNDER]);
		}
		case NINJA:
		{
			b_stealth[id] = true;
			set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 0);
			emit_sound(id, CHAN_STATIC, k_spell_ninja, 1.0, ATTN_NORM, 0, PITCH_NORM);
			set_task(f_ninjaStealthTime[g_iKnifeLevel[id][NINJA]-1], "ff_remove_stealth", 192144256 + id);
			sgcm_set_stealth_message(id, f_ninjaStealthTime[g_iKnifeLevel[id][NINJA]-1]);
			k_cooldown[id] = get_gametime() + f_ninjaStealthTime[g_iKnifeLevel[id][NINJA]-1] + str_to_float(g_iKnifeCoolDown[NINJA]);
		}
		case FAST:
		{
			b_boots[id] = true;
			entity_set_float(id, EV_FL_maxspeed, 400.0);
			emit_sound(id, CHAN_STATIC, k_spell_fast, 1.0, ATTN_NORM, 0, PITCH_NORM);
			set_task(f_fastBootsTime[g_iKnifeLevel[id][FAST]-1], "ff_remove_boots", 192154256 + id);
			sgcm_set_boots_message(id, f_fastBootsTime[g_iKnifeLevel[id][FAST]-1]);
			k_cooldown[id] = get_gametime() + f_fastBootsTime[g_iKnifeLevel[id][FAST]-1] + str_to_float(g_iKnifeCoolDown[FAST]);
		}
		case FLASH:
		{
			new rgb[3];
			rgb[0] = 255;
			rgb[1] = 255;
			rgb[2] = 255;
			
			create_blast(id, rgb, i_flashWaveLife[g_iKnifeLevel[id][FLASH]-1], i_flashLightRadius[g_iKnifeLevel[id][FLASH]-1]);
			
			new Float:target_dist[3], Float:id_dist[3], Float:distance;
			
			pev(id, pev_origin, id_dist);
			id_dist[2] -= 5.0;
			
			new name[36]; get_user_name(id, name, charsmax(name));
			
			for(new i = 1; i <= g_max_clients; i++)
			{
				if(!is_user_alive(i) || i == id || cs_get_user_team(i) == cs_get_user_team(id)) continue;
				
				pev(i, pev_origin, target_dist);
				distance = vector_distance(id_dist, target_dist);
				
				if(distance > i_flashLightRadius[g_iKnifeLevel[id][FLASH]-1]) continue;
				
				if(f_flashed[i] < 0.1)
					f_flashed[i] = (1.0 - distance / i_flashLightRadius[g_iKnifeLevel[id][FLASH]-1]) * f_flash_time[g_iKnifeLevel[id][FLASH]-1];
				else
					f_flashed[i] += (1.0 - distance / i_flashLightRadius[g_iKnifeLevel[id][FLASH]-1]) * f_flash_time[g_iKnifeLevel[id][FLASH]-1];
				
				Print(i, "^4%s ослепил вас ^3с помощью ^4Flash Knife^3!", name);
			}
			
			k_cooldown[id] = get_gametime() + str_to_float(g_iKnifeCoolDown[FLASH]);
		}
		case PUSH:
		{
			new rgb[3];
			rgb[0] = 255;
			rgb[1] = 255;
			rgb[2] = 0;
			
			create_blast(id, rgb, i_pushWaveLife[g_iKnifeLevel[id][PUSH]-1], i_pushLightRadius[g_iKnifeLevel[id][PUSH]-1]);
			
			new Float:target_dist[3], Float:id_dist[3], Float:distance;
			
			pev(id, pev_origin, id_dist);
			id_dist[2] -= 5.0;
			
			new name[36]; get_user_name(id, name, charsmax(name));
			
			for(new i = 1; i <= g_max_clients; i++)
			{
				if(!is_user_alive(i) || i == id) continue; //|| cs_get_user_team(i) == cs_get_user_team(id)) continue;
				
				pev(i, pev_origin, target_dist);
				distance = vector_distance(id_dist, target_dist);
				if(distance > i_pushLightRadius[g_iKnifeLevel[id][PUSH]-1]) continue;
				
				new Float:player_vel[3];
				velocity_by_aim(i, -1 * floatround((1.0 - distance / i_pushLightRadius[g_iKnifeLevel[id][PUSH]-1]) * i_pushStrange[g_iKnifeLevel[id][PUSH]-1]), player_vel);
				player_vel[2] += 150.0;
				entity_set_vector(i, EV_VEC_velocity, player_vel);
				Print(i, "^4%s оттолкнул вас ^3с помощью ^4Push Knife^3!", name);
			}
			
			k_cooldown[id] = get_gametime() + str_to_float(g_iKnifeCoolDown[PUSH]);
		}
		case FROST:
		{
			new rgb[3];
			rgb[0] = 0;
			rgb[1] = 206;
			rgb[2] = 209;
			
			create_blast(id, rgb, i_frostWaveLife[g_iKnifeLevel[id][FROST]-1], i_frostLightRadius[g_iKnifeLevel[id][FROST]-1]);
			emit_sound(id, CHAN_BODY, "warcraft3/frostnova.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			
			new Float:target_dist[3], Float:id_dist[3], Float:distance;
			
			pev(id, pev_origin, id_dist);
			id_dist[2] -= 5.0;
			
			new name[36]; get_user_name(id, name, charsmax(name));
			
			for(new i = 1; i <= g_max_clients; i++)
			{
				if(!is_user_alive(i) || i == id || cs_get_user_team(i) == cs_get_user_team(id)) continue;
				
				pev(i, pev_origin, target_dist);
				distance = vector_distance(id_dist, target_dist);
				
				if(distance > i_frostLightRadius[g_iKnifeLevel[id][FROST]-1]) continue;
				
				if(distance <= i_frostFrostRadius[g_iKnifeLevel[id][FROST]-1]){
					freeze_player(i, pev(i, pev_team), f_frost_time[g_iKnifeLevel[id][FROST]-1], f_frostVariance[g_iKnifeLevel[id][FROST]-1]);
					//chill_player(i, pev(i, pev_team), f_frost_time[g_iKnifeLevel[id][FROST]-1] + f_chill_time[g_iKnifeLevel[id][FROST]-1], f_chillVariance[g_iKnifeLevel[id][FROST]-1]);
				}else{
					chill_player(i, pev(i, pev_team), f_chill_time[g_iKnifeLevel[id][FROST]-1], f_chillVariance[g_iKnifeLevel[id][FROST]-1]);
				}
				
				Print(i, "^4%s заморозил вас ^3с помощью ^4Frost Knife^3!", name);
			}
			
			k_cooldown[id] = get_gametime() + str_to_float(g_iKnifeCoolDown[FROST]);
		}
	}
	
	return PLUGIN_HANDLED;
}

public ff_remove_boots(taskid){
	new id = taskid - 192154256;
	b_boots[id] = false;
	sgcm_reset_maxspeed(id);
}

public ff_remove_stealth(taskid){
	new id = taskid - 192144256;
	b_stealth[id] = false;
}

Thunder( ivec1[ 3 ], ivec2[ 3 ] , red, green, blue)
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY ); 
	write_byte( TE_BEAMPOINTS ); 
	write_coord( ivec1[ 0 ] ); 
	write_coord( ivec1[ 1 ] ); 
	write_coord( ivec1[ 2 ] ); 
	write_coord( ivec2[ 0 ] ); 
	write_coord( ivec2[ 1 ] ); 
	write_coord( ivec2[ 2 ] ); 
	write_short( lightning ); 
	write_byte( 1 );
	write_byte( 5 );
	write_byte( 7 );
	write_byte( 35 );
	write_byte( 50 );
	write_byte( red ); 
	write_byte( green );
	write_byte( blue );
	write_byte( 100 );
	write_byte( 200 );
	message_end();
	
	message_begin( MSG_PVS, SVC_TEMPENTITY, ivec2 ); 
	write_byte( TE_SPARKS ); 
	write_coord( ivec2[ 0 ]  ); 
	write_coord( ivec2[ 1 ]); 
	write_coord( ivec2[ 2 ] ); 
	message_end();
}

Smoke( iorigin[ 3 ], scale, framerate )
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_SMOKE );
	write_coord( iorigin[ 0 ] );
	write_coord( iorigin[ 1 ] );
	write_coord( iorigin[ 2 ] );
	write_short( g_smoke );
	write_byte( scale );
	write_byte( framerate );
	message_end();
}

/*Blood( ivec1[ 3 ] )
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY ); 
	write_byte( TE_LAVASPLASH ); 
	write_coord( ivec1[ 0 ] ); 
	write_coord( ivec1[ 1 ] ); 
	write_coord( ivec1[ 2 ] ); 
	message_end(); 
}*/

public ShowMessage()
{
	new params[5], Float:cooldown, time_id, viewer;
	
	for(new id = 1; id <= 32; id++)
	{	
		if(!is_user_connected(id) || !get_in[id])
			continue;
		
		viewer = id;
		time_id = pev(id, pev_iuser2);
		if(time_id == 0 || is_user_alive(id)) time_id = id;
		
		params[0] = g_iLevel[time_id];
		params[1] = g_iPoint[time_id];
		params[2] = g_iTotal[time_id];
		
		if(params[0] != 101){
			params[3] = gszExperienceTable[g_iLevel[time_id]+1];
		}else{
			params[3] = 0;
		}
		
		params[4] = g_iNextRoundKnife[time_id];
		cooldown = k_cooldown[time_id];
		
		new bool:stucked = g_stucked[id];
		if(stucked){ g_stucked[id] = false; }
		
		if(g_iNextRoundKnife[id] == NINJA && g_iKnifeLevel[id][NINJA] > 0 && get_pcvar_num(agm_status) == 1 && !sgcm_in_stealth(id) && !b_stealth[id] && get_state_from_frostnades(id) == 0){
			new Float:f_time = get_gametime() - f_round_time;
			f_time = (f_cvar_data_round_time * 60.0 - f_time) / (f_cvar_data_round_time * 60.0 / 100.0) * 2.55 + iray_ninjaAlpha[g_iKnifeLevel[id][NINJA]-1];
			
			if(f_time < 255.0){
				if(f_time < 0.0) f_time = 0.0;
				set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, floatround(f_time));
			}
		}
		
		if(get_pcvar_num(agm_status) == 1){
			for(new i = 1; i <= g_max_clients; i++){
				if(!is_user_alive(i)){ continue; }
				
				if(f_flashed[i] >= 0.1){
					f_flashed[i] -= 0.1;
					
					message_begin(MSG_ONE, g_msgScreenFade, {0,0,0}, i);
					write_short(4096);    // Duration
					write_short(4096);    // Hold time
					write_short(4096);    // Fade type
					write_byte(255);
					write_byte(255);
					write_byte(255);
					write_byte(255);   		// Alpha
					message_end();
				}
				
				if(i_poisoned[i] > 0){
					if(i_poisoned[i] % 10 == 0){
						ExecuteHamB(Ham_TakeDamage, i, 0, i_poison_attacker[i]+1, f_poisoned_dmg[i], (1<<24));
						
						if(f_flashed[i] < 0.1){
							message_begin(MSG_ONE, g_msgScreenFade, {0,0,0}, i);
							write_short(i_poisoned[i] - 10 == 0 ? 2048 : 4096);    // Duration
							write_short(i_poisoned[i] - 10 == 0 ? 2048 : 4096);    // Hold time
							write_short(i_poisoned[i] - 10 == 0 ? 2048 : 4096);    // Fade type
							write_byte(0);
							write_byte(200);
							write_byte(0);
							write_byte(65);    // Alpha
							message_end();
						}
					}
					
					i_poisoned[i]--;
				}else{ f_poisoned_dmg[i] = 0.0; }
			}
		}
		
		sgcm_get_blockmaker_info(time_id, viewer, params[0], params[1], params[2], params[3], params[4], cooldown, stucked);
	}
	
	return PLUGIN_HANDLED;
}

public rvt(id)
{
	if(!get_in[id]) return PLUGIN_HANDLED;
	
	new time_to_vip[64];
	new time[64]; format(time, 63, "%f", VIP_GO_TIME - get_gametime());
	TimeToString( str_to_num(time), time_to_vip, charsmax(time_to_vip), true );
	
	Print(id, "До обновления рангового VIP осталось %s.", time_to_vip);
	
	if(!equal(VIP_NAME, "x"))
		Print(id, "Текущий ранговый VIP: ^4%s^3.", VIP_NAME);
	else
		Print(id, "Текущий ранговый VIP: ^4не установлен^3.");
	
	return PLUGIN_CONTINUE;
}

public CheckVip()
{
	VIP_GO_TIME = VIP_CHECK_TIME * 1.0;
	
	new time_to_vip[32];
	format(time_to_vip, 31, "%f", VIP_GO_TIME);
	
	write_file("mode/Rank_VIP.txt", time_to_vip, 0);
	
	for(new i = 1; i <= g_max_clients; i++){
		if(is_user_connected(i)){
			Save(i);
			SaveData(i);
		}
	}
	
	nvault_close(g_vault);
	g_vault = nvault_open("agm_save");
	nvault_close(g_hVault);
	g_hVault = nvault_open("agm_save_top");
	
	new Array:aRankData = ArrayCreate( RankData );

	new hVault = nvault_util_open("agm_save_top");
	new iKeys = nvault_util_count( hVault );
	
	new eRankData[ RankData ];
	
	new iPos, szKey[ 32 ], szData[256], iTimeStamp;
		
	for( new i = 0; i < iKeys; i++ )
	{
		iPos = nvault_util_read( hVault, iPos, szKey, charsmax( szKey ), szData, charsmax( szData ), iTimeStamp );
		
		ReadVaultData( szData, charsmax( szData ), eRankData[Rank_Pass], charsmax(eRankData[Rank_Pass]), eRankData[Rank_Time], eRankData[Rank_Point], eRankData[Rank_Rounds], eRankData[Rank_Kills], eRankData[Rank_Deaths], eRankData[Rank_Suicides], eRankData[Rank_Survives], eRankData[Rank_VIP], eRankData[Rank_Name], charsmax(eRankData[Rank_Name]));
		
		if(eRankData[Rank_VIP] > 0)
		{
		 	formatex(szData, sizeof(szData) - 1, " %s %i %i %i %i %i %i %i 0 %s", eRankData[Rank_Pass], eRankData[Rank_Time], eRankData[Rank_Point], eRankData[Rank_Rounds], eRankData[Rank_Kills], eRankData[Rank_Deaths], eRankData[Rank_Suicides], eRankData[Rank_Survives], eRankData[Rank_Name]);
			nvault_set(g_hVault, szKey, szData);
		}
		
		ArrayPushArray( aRankData, eRankData );
	}
	
	ArraySort( aRankData, "SortRanks" );
	ArrayGetArray( aRankData, 0, eRankData );
	
	formatex(szData, sizeof(szData) - 1, " %s %i %i %i %i %i %i %i 1 %s", eRankData[Rank_Pass],  eRankData[Rank_Time], eRankData[Rank_Point], eRankData[Rank_Rounds], eRankData[Rank_Kills], eRankData[Rank_Deaths], eRankData[Rank_Suicides], eRankData[Rank_Survives], eRankData[Rank_Name]);
	nvault_set(g_hVault, szKey, szData);
	
	new vip_days = 0; new time_reader[64]; new time_data[256];
	
	if(nvault_get(g_vault, szKey, szData, charsmax(szData))){
		strbreak(szData, time_reader, sizeof(time_reader) - 1, szData, sizeof(szData) - 1);
		format(time_data, charsmax(time_data), " %s", time_reader);
		
		for( new c = 0; c < g_iItemCount + g_iWeapCount + g_iKnivesCount + 5; c++ )
		{
			strbreak(szData, time_reader, sizeof(time_reader) - 1, szData, sizeof(szData) - 1);
			format(time_data, charsmax(time_data), "%s %s", time_data, time_reader);
		}

		strbreak(szData, time_reader, sizeof(time_reader) - 1, szData, sizeof(szData) - 1);
		vip_days = str_to_num(time_reader) + VIP_CHECK_TIME;
		format(time_data, charsmax(time_data), " %s %i", time_data, vip_days);
		nvault_set(g_vault, szKey, time_data);
	}else log_to_file("AGM_log.txt", "Error! VIP DOESN`T EXISTS!");
	
	nvault_util_close(hVault);
	
	for(new i = 1; i <= g_max_clients; i++){
		if(!is_user_connected(i)) continue;
		
		Print(i, "На сервере обновился ранговый VIP! Им стал ^4%s^3!", eRankData[ Rank_Name ]);
		Print(i, "^4%s ^3набрал ^4%i Rank Points ^3среди ^4%i ^3игроков!", eRankData[ Rank_Name ], eRankData[ Rank_Point ], iKeys);
		
		if(equal(user_password[i], eRankData[Rank_Pass])){
			if(user_vip_days[i] - floatround(get_gametime()) > 0)
				Print(i, "Вы стали ^4ранговым VIP ^3в этом месяца, ^4VIP-статус ^3продлен ^4на 30 дней^3!");
			else
				Print(i, "Вы стали ^4ранговым VIP ^3в этом месяца и получили ^4VIP-статус ^4на^4 30 дней^3!");
			
			if(user_vip_days[i] <= 0)
				user_vip_days[i] += (VIP_CHECK_TIME + floatround(get_gametime()));
			else
				user_vip_days[i] += VIP_CHECK_TIME;
				
			user_is_ranked_vip[i] = 1;
			CheckRV(i);
			CheckAccess(i);
		}
	}
	
	ArrayDestroy(aRankData);
	
	for(new i = 1; i <= g_max_clients; i++){
		if(!is_user_connected(i)) continue;
		
		Save(i);
		SaveData(i);
	}
	
	CheckVipName();
	
	nvault_close(g_vault);
	g_vault = nvault_open("agm_save");
	nvault_close(g_hVault);
	g_hVault = nvault_open("agm_save_top");
}

public CheckVipName()
{
	new Array:aRankData = ArrayCreate( RankData );

	new hVault = nvault_util_open("agm_save_top");
	new iKeys = nvault_util_count( hVault );
	
	new eRankData[ RankData ];
	
	new iPos, szKey[ 32 ], szData[256], iTimeStamp, has_VIP = false;
		
	for( new i = 0; i < iKeys; i++ )
	{
		iPos = nvault_util_read( hVault, iPos, szKey, charsmax( szKey ), szData, charsmax( szData ), iTimeStamp );
		
		ReadVaultData( szData, charsmax( szData ), eRankData[Rank_Pass], charsmax(eRankData[Rank_Pass]), eRankData[Rank_Time], eRankData[Rank_Point], eRankData[Rank_Rounds], eRankData[Rank_Kills], eRankData[Rank_Deaths], eRankData[Rank_Suicides], eRankData[Rank_Survives], eRankData[Rank_VIP], eRankData[Rank_Name], charsmax(eRankData[Rank_Name]));
		
		if(eRankData[Rank_VIP] > 0){
		 	formatex(VIP_NAME, charsmax(VIP_NAME), eRankData[Rank_Name]);
			has_VIP = true;
			break;
		}
		
		ArrayPushArray( aRankData, eRankData );
	}
	
	nvault_util_close(hVault);
	ArrayDestroy(aRankData);
	
	if(!has_VIP){
		 formatex(VIP_NAME, charsmax(VIP_NAME), "не определен");
	}
}

public plugin_natives()
{
	register_library("ScreamPoints");
	
	register_native("pm_level_extra_time", "_level_extra_time");
	register_native("pm_level_weapon_chance", "_level_weapon_chance");
	register_native("pm_level_autohealth", "_level_autohealth");
	register_native("pm_add_user_point", "pm_add_user_point");
	register_native("pm_add_user_point_new", "pm_add_user_point_new");
	register_native("pm_add_user_point_jump", "pm_add_user_point_jump");
	register_native("pm_get_health_level", "_get_health_level");
	register_native("pm_has_user_nofrost", "_has_user_nofrost");
	register_native("sgpm_do_not_frost_me", "_sgpm_do_not_frost_me", 1);
	register_native("sgpm_fast_knife_speed", "_sgpm_fast_knife_speed", 1);
	register_native("sgpm_boots_is_activated", "_sgpm_boots_is_activated", 1);
	register_native("sgpm_stop_poison_dmg", "_sgpm_stop_poison_dmg", 1);
} 

public _sgpm_stop_poison_dmg(id){
	i_poisoned[id] = 0;
	f_poisoned_dmg[id] = 0.0;
}

public _sgpm_boots_is_activated(id){
	return b_boots[id];
}

public Float:_sgpm_fast_knife_speed(id){
	if(g_iNextRoundKnife[id] == FAST){
		return fray_fastSpeed[g_iKnifeLevel[id][FAST]];
	}
	
	return 0.0;
}

public _sgpm_do_not_frost_me(id){
	if(g_iNextRoundKnife[id] == NINJA && get_pcvar_num(agm_status) == 1 && !sgcm_in_stealth(id)){
		return true;
	}
	
	return false;
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

public pm_add_user_point(iPlugin, iParams)
{	
	new iPlayer = get_param(1);
	if(!iPlayer)
	{
		return PLUGIN_CONTINUE;
	}
	
	if(get_pcvar_num(agm_status) != 0)
	{
		g_iRankPoint[iPlayer] += max(0, get_param(2));
		g_iStats[iPlayer][1]++;
	}
	else
	{
		return PLUGIN_HANDLED;
	}
	
	if(get_pcvar_num(agm_status) <= 4 && get_pcvar_num(agm_status) >= 3){
		return PLUGIN_HANDLED;
	}
	
	if(get_playersnum() >= get_pcvar_num(players_num)){
		g_iPoint[iPlayer] += max(0, get_param(2));
		g_iTotal[iPlayer] += max(0, get_param(2));
		
		if(!g_Vip[iPlayer])
		{
			Print(iPlayer, "^03Вы получили ^04%d points^03 за то, что ^04убили противника стоя у него на голове^03!", max(0, get_param(2)));
		}
		else
		{
			g_iPoint[iPlayer] += 3;
			g_iTotal[iPlayer] += 3;
			
			Print(iPlayer, "^03Вы получили ^04%d+3 points^03 за то, что ^04убили противника стоя у него на голове^03!", max(0, get_param(2)));
		}
		
		CheckLevel(iPlayer, 1);
		
		return PLUGIN_HANDLED;
	}
	else
	{
		new iPlayer = get_param(1);
		if( !iPlayer )
			return PLUGIN_CONTINUE;
			
		Print(iPlayer, "^03На сервере требуется ^04%d и более игроков^03, чтобы^04 получать points^03!", get_pcvar_num(players_num));
	
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_HANDLED;
}

public pm_add_user_point_new(iPlugin, iParams)
{	
	new iPlayer = get_param(1);
	if(!iPlayer)
	{
		return PLUGIN_CONTINUE;
	}
	
	if(get_pcvar_num(agm_status) == 0 || get_pcvar_num(agm_status) <= 4 && get_pcvar_num(agm_status) >= 3)
	{
		return PLUGIN_HANDLED;
	}
	
	new pm = max(0, get_param(2));
	if(random_num(1, 100) <= g_iItemMaxVal[LARGE_AP] * g_iItemLevel[iPlayer][LARGE_AP] / g_iItemMaxLevel[LARGE_AP])
	{
		Print(iPlayer, "^03Вы получили ^04%d points^03 за то, что ^04добрались до Pointbock^03!", pm);
		Print(iPlayer, "^03Вы получили ^04%d дополнительных points^03 (%d%% шанс)!!!", pm, g_iItemMaxVal[LARGE_AP] * g_iItemLevel[iPlayer][LARGE_AP] / g_iItemMaxLevel[LARGE_AP]);
		
		new name_s[32];
		get_user_name(iPlayer, name_s, 31);
		
		for(new i = 1; i <= g_max_clients; i++)
			if(iPlayer != i)
				Print(i, "^03Игрок %s счастливчик! Он получил в 2 раза больше points!", name_s);
				
		pm*=2;
	}
	else
	{
		Print(iPlayer, "^03Вы получили ^04%d points^03 за то, что ^04добрались до Pointbock^03!", pm);
	}
	
	g_iPoint[iPlayer] += pm;
	g_iTotal[iPlayer] += pm;
	
	CheckLevel(iPlayer, 2);
	
	return PLUGIN_HANDLED;
}

public pm_add_user_point_jump(iPlugin, iParams)
{
	new iPlayer = get_param(1);
	if(!iPlayer)
	{
		return PLUGIN_CONTINUE;
	}
			
	if(get_pcvar_num(agm_status) != 0)
	{
		g_iRankPoint[iPlayer] += max(0, get_param(2));
	}
	else
	{
		return PLUGIN_HANDLED;
	}
	
	if(get_pcvar_num(agm_status) <= 4 && get_pcvar_num(agm_status) >= 3){
		return PLUGIN_HANDLED;
	}
	 
	if(get_playersnum() >= get_pcvar_num(players_num))
	{
		g_iPoint[iPlayer] += max(0, get_param(2));
		g_iTotal[iPlayer] += max(0, get_param(2));
		
		CheckLevel(iPlayer, 3);
	}
	
	return PLUGIN_HANDLED;
}

public client_putinserver(client)
{
	if( !is_user_bot(client) && !is_user_hltv(client) )
	{
		get_user_authid(client, g_iAuthID[client], sizeof(g_iAuthID[]) - 1);
		
		if(!client_valid_authid(g_iAuthID[client]))
			g_iAuthStatus[client] = false;
		else g_iAuthStatus[client] = true;
		
		g_iTimeOffset[client] = 0;
		
		get_in[client] = false;
		get_in_count[client] = 0;
		menutype[client] = 1;
		accounttype[client] = 0;
		user_tries[client] = 0;
		user_admin_days[client] = 0;
		user_vip_days[client] = 0;
		
		formatex(user_password[client], 47, "");
		
		set_task(0.1, "AuthorizationForm", client);
		
		new params[1]; params[0] = client;
		set_task(1.0, "AuthorizationFormTask", 4312341235 + client, params, 1, "b");
	}
}

public AuthorizationFormTask(params[], taskid){
	new client = params[0];
	get_in_count[client]++;
	
	if(get_in[client]){
		if(task_exists(taskid)){
			remove_task(taskid);
			return PLUGIN_HANDLED;
		}
	}
	
	if(!get_in[client] && get_in_count[client] >= 180){
		if(task_exists(taskid)){
			remove_task(taskid);
		}
		
		new name[36]; get_user_name(client, name, charsmax(name));
		server_cmd("kick %s ^"You`ve lost your time, don`t be afk.^"", name);
		
		for(new i = 1; i <= g_max_clients; i++){
			if(i != client){
				Print(i, "^3Игрок ^4%s ^3был кикнут! Причина: истекло время на авторизацию.", name);
			}
		}
		
		return PLUGIN_HANDLED;
	}
	
	AuthorizationForm(client);
	return PLUGIN_HANDLED;
}

public AuthorizationForm(client){
	message_begin(MSG_ONE, g_msgScreenFade, {0,0,0}, client);
	write_short(4096);    // Duration
	write_short(4096);    // Hold time
	write_short(4096);    // Fade type
	write_byte(0);
	write_byte(0);
	write_byte(0);
	write_byte(255);    // Alpha
	message_end();
	
	switch(menutype[client]){
		case 1:
		{
			AuthMainMenu(client);
		}
		case 2:
		{
			AuthAccTypeMenu(client);
		}
		case 3:
		{
			AuthAccChangeMenu(client);
		}
		case 4:
		{
			BuyMenuShow(client);
		}
	}
	
	return PLUGIN_HANDLED;
}

public AuthMainMenu(client){
	new title[64]; formatex(title, charsmax(title), "Log in before playing:^n^n\wTimeleft: \r%d", 180 - get_in_count[client]);
	new menu = menu_create(title, "AuthMainMenuHandle");
	menu_additem(menu, "Create new account (in the 1st time)", "1", 0);
	menu_additem(menu, "Enter the password (logging in)", "2", 0);
	menu_additem(menu, "Change old account`s settings^n", "3", 0);
	menu_additem(menu, "\yWhat is it? \rRead Russian Info!", "4", 0);
	menu_setprop(menu, MPROP_PERPAGE, 0);
	menu_display(client, menu, 0);
}

public AuthMainMenuHandle(id, menu, item){
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	new data[7], iName[64];
	new access, callback;
	
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	
	new key = str_to_num(data);
	
	switch(key){
		case 1:
		{
			menutype[id] = 2;
		}
		case 2:
		{
			client_cmd(id,"messagemode _write_your_password");
		}
		case 3:
		{
			client_cmd(id,"messagemode _print_your_password");
			Print(id, "^4Введите старый пароль^3, чтобы зайти в настройки своего аккаунта^3.");
		}
		case 4:
		{
			show_motd(id, "mode/registration.txt", "Registration information");
		}
	}
	
	AuthorizationForm(id);
	return PLUGIN_HANDLED;
}

public AuthAccTypeMenu(client){
	new title[128]; formatex(title, charsmax(title), "Creating new account:^n^n\wTimeleft: \r%d^n^n\wChoose the \raccount type\w:", 180 - get_in_count[client]);
	new menu = menu_create(title, "AuthAccMenuHandle");
	menu_additem(menu, "\rNickname \w+ password", "1", 0);
	menu_additem(menu, "\rSteam ID + \wpassword^n", "2", 0);
	menu_additem(menu, "\yWhat is it? \wRead \rinfo \where!^n", "3", 0);
	menu_additem(menu, "Back to the \rmain menu", "4", 0);
	menu_setprop(menu, MPROP_PERPAGE, 0);
	menu_display(client, menu, 0);
}

public AuthAccMenuHandle(id, menu, item){
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	new data[7], iName[64];
	new access, callback;
	
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	
	new key = str_to_num(data);
	
	switch(key){
		case 1:
		{
			accounttype[id] = 1;
			client_cmd(id,"messagemode _choose_your_password");
		}
		case 2:
		{
			if(g_iAuthStatus[id]){
				accounttype[id] = 2;
				client_cmd(id,"messagemode _choose_your_password");
			}else{
				Print(id, "^4Ошибка! ^3Вам ^4запрещено создавать аккаунт ^3по ^4SteamID^3, создайте аккаунт по нику!");
			}
		}
		case 3:
		{
			show_motd(id, "mode/registration.txt", "Registration information");
		}
		case 4:
		{
			menutype[id] = 1;
		}
	}
	
	AuthorizationForm(id);
	return PLUGIN_HANDLED;
}

public AuthAccChangeMenu(client){
	if(menutype[client] != 3 && !get_in[client]) return PLUGIN_HANDLED;

	new title[192]; new text_time[32];
	if(!get_in[client])
		format(title, charsmax(title), "Account settings:^n^n\wTimeleft: \r%d:", 180 - get_in_count[client]);
	else
		format(title, charsmax(title), "Account settings \d(ingame)\w:");
		
	if(user_admin_days[client] - floatround(get_gametime()) > 0 || user_vip_days[client] - floatround(get_gametime()) > 0){
		format(title, charsmax(title), "%s^n", title);
		
		if(user_admin_days[client] - floatround(get_gametime()) > 0){
			TimeToString(user_admin_days[client] - floatround(get_gametime()), text_time, charsmax(text_time), true);
			replace_all(text_time, charsmax(text_time), "^3", "");
			replace_all(text_time, charsmax(text_time), "^4", "");
			format(title, charsmax(title), "%s^n\wYou`re admin: \r%s", title, text_time);
		}else format(title, charsmax(title), "%s^n\wYou are \rnot admin\w!", title);
		
		if(user_vip_days[client] - floatround(get_gametime()) > 0){
			TimeToString(user_vip_days[client] - floatround(get_gametime()), text_time, charsmax(text_time), true);
			replace_all(text_time, charsmax(text_time), "^3", "");
			replace_all(text_time, charsmax(text_time), "^4", "");
			format(title, charsmax(title), "%s^n\wYou`re VIP: \r%s", title, text_time);
		}else format(title, charsmax(title), "%s^n\wYou are not \rVIP\w!", title);
	}else{
		format(title, charsmax(title), "%s^n^n\wYou are \rnot admin\w!", title);
		format(title, charsmax(title), "%s^n\wYou are not \rVIP\w!", title);
	}
	
	new menu = menu_create(title, "AuthAccChangeHandle");
	menu_additem(menu, "\rNickname \w+ password \d(account type)", "1", 0);
	menu_additem(menu, "\rSteam ID \w+ password \d(account type)^n", "2", 0);
	menu_additem(menu, "\rChange the password^n", "3", 0);
	menu_additem(menu, "\wOpen \rbuy menu^n", "4", 0);
	
	if(!get_in[client])
		menu_additem(menu, "Back to the \rmain menu", "5", 0);
	else
		menu_additem(menu, "\rClose menu", "5", 0);
	
	menu_setprop(menu, MPROP_PERPAGE, 0);
	menu_display(client, menu, 0);
	return PLUGIN_HANDLED;
}

public AuthAccChangeHandle(id, menu, item){
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	new data[7], iName[64];
	new access, callback;
	
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	
	new key = str_to_num(data);
	
	switch(key){
		case 1:
		{
			if(accounttype[id] == 1){
				Print(id, "^3Вход на сервер итак выполняется по ^4нику^3 и паролю!");
				if(!get_in[id]) AuthorizationForm(id);
				else AuthAccChangeMenu(id);
				return PLUGIN_HANDLED;
			}
			
			if(nvault_get(g_vault, g_iAuthID[id], data, sizeof(data) - 1)){
				nvault_remove(g_vault, g_iAuthID[id]);
			}
			
			if(nvault_get(g_hVault, g_iAuthID[id], data, sizeof(data) - 1)){
				nvault_remove(g_hVault, g_iAuthID[id]);
			}
			
			accounttype[id] = 1;
			
			Save(id);
			SaveData(id);
			
			Print(id, "^4Успешно! ^3Теперь вход на сервер выполняется по ^4нику^3 и паролю!");
		}
		case 2:
		{
			if(accounttype[id] == 2){
				Print(id, "^3Вход на сервер итак выполняется по ^4SteamID^3 и паролю!");
				if(!get_in[id]) AuthorizationForm(id);
				else AuthAccChangeMenu(id);
				return PLUGIN_HANDLED;
			}
			
			if(g_iAuthStatus[id]){
				new name[36]; get_user_name(id, name, charsmax(name));
				
				if(nvault_get(g_vault, name, data, sizeof(data) - 1)){
					nvault_remove(g_vault, name);
				}
			
				if(nvault_get(g_hVault, name, data, sizeof(data) - 1)){
					nvault_remove(g_hVault, name);
				}
				
				accounttype[id] = 2;
				
				Save(id);
				SaveData(id);
				
				Print(id, "^4Успешно! ^3Теперь вход на сервер выполняется по ^4SteamID^3 и паролю!");
			}else{
				Print(id, "^4Ошибка! ^3Вам ^4запрещено создавать аккаунт ^3по ^4SteamID^3, создайте аккаунт по нику!");
			}
		}
		case 3:
		{
			client_cmd(id,"messagemode _rechoose_your_password");
			Print(id, "^3Введите новый пароль! Старые данные моментально изменятся.");
		}
		case 4:
		{
			if(!get_in[id])
				menutype[id] = 4;
			else
			{
				BuyMenuShow(id);
				return PLUGIN_HANDLED;
			}
		}
		case 5:
		{
			if(!get_in[id])
				menutype[id] = 1;
			else
				return PLUGIN_HANDLED;
		}
	}
	
	if(!get_in[id]) AuthorizationForm(id);
	else AuthAccChangeMenu(id);
	
	return PLUGIN_HANDLED;
}

public BuyMenuShow(id){
	if(menutype[id] != 4 && !get_in[id]) return PLUGIN_HANDLED;

	new title[128]; 
	if(!get_in[id])
		formatex(title, charsmax(title), "Buy Menu:^n^n\wTimeleft: \r%d:", 180 - get_in_count[id]);
	else
		formatex(title, charsmax(title), "Buy Menu \d(ingame)\w:");
		
	new menu = menu_create(title, "BuyMenuHandle");
	
	menu_additem(menu, "Admin & VIP info", "1", 0);
	menu_additem(menu, "\yHow to buy?", "2", 0);
	menu_additem(menu, "\rActivate key", "3", 0);
	
	if(get_user_flags(id) & ADMIN_LEVEL_D)
		menu_additem(menu, "\rAdd key^n", "4", ADMIN_LEVEL_D);
	else
		menu_additem(menu, "Add key^n", "4", ADMIN_LEVEL_D);
		
	menu_additem(menu, "Open the \rsettings", "5", 0);
	
	if(get_in[id])
		menu_additem(menu, "\rClose menu", "6", 0);
	else
		menu_additem(menu, "Back to the \rmain menu", "6", 0);
	
	menu_setprop(menu, MPROP_PERPAGE, 0);
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public BuyMenuHandle(id, menu, item){
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	new data[7], iName[64];
	new access, callback;
	
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	
	new key = str_to_num(data);
	
	switch(key){
		case 1: show_motd(id, "mode/info_rights.txt", "Administrator`s information");
		case 2: show_motd(id, "mode/info_buy.txt", "How to buy something?");
		case 3:
		{
			Print(id, "^3Вы можете ошибиться не более^4 3 раз^3! Затем последует бан на^4 3 дня без разбана ^3досрочно!");
			client_cmd(id, "messagemode _type_activation_code");
		}
		case 4:
		{
			client_cmd(id, "messagemode _type_new_activation_code");
		}
		case 5: 
		{
			if(!get_in[id]){
				menutype[id] = 3;
			}
			
			AuthAccChangeMenu(id);
			return PLUGIN_HANDLED;
		}
		case 6:
		{
			if(!get_in[id]){
				menutype[id] = 1;
				AuthMainMenu(id);
			}
			
			return PLUGIN_HANDLED;
		}
	}
	
	BuyMenuShow(id);
	return PLUGIN_HANDLED;
}

public PasswordChecker(id){
	read_argv(1, user_password[id], 47);
	remove_quotes(user_password[id]);
	
	if(equal(user_password[id][0], "")){
		Print(id, "Вы обязательно должны ввести пароль!");
		return 1;
	}
	
	if(symbols_correct(id))
		Load(id);
	else
		Print(id, "Запрещено использовать спец. символы и пробелы!");
	
	return 1;
}

public ChangePasswordChecker(id){
	read_argv(1, user_password[id], 47);
	remove_quotes(user_password[id]);
	
	if(equal(user_password[id][0], "")){
		Print(id, "Вы обязательно должны ввести пароль!");
		return 1;
	}
	
	if(symbols_correct(id)){
		new name[36]; get_user_name(id, name, charsmax(name));
		
		menutype[id] = 3;
		Load(id);
	}else Print(id, "Запрещено использовать спец. символы и пробелы!");
	
	return 1;
}

public NewPasswordChecker(id){
	read_argv(1, user_password[id], 47);
	remove_quotes(user_password[id]);
	
	if(equal(user_password[id][0], "")){
		Print(id, "Вы обязательно должны ввести пароль!");
		return 1;
	}
	
	if(!symbols_correct(id)){
		Print(id, "Запрещено использовать спец. символы и пробелы!");
		return 1;
	}
	
	new name[36]; get_user_name(id, name, charsmax(name));
	
	static data[256];
	if(nvault_get(g_vault, name, data, sizeof(data) - 1) || nvault_get(g_vault, g_iAuthID[id], data, sizeof(data) - 1)
		|| nvault_get(g_hVault, name, data, sizeof(data) - 1) || nvault_get(g_hVault, g_iAuthID[id], data, sizeof(data) - 1)){
		Print(id, "^3Похожий аккаунт ^4уже существует^3. ^4Забыли пароль^3? ^4Пишите на ^3sg-cs.hol.es^4.");
		AuthorizationForm(id);
	}else{
		set_autojoin(id);
		get_in[id] = true;
		NewUser(id);
		NewUserTop(id);
		Print(id, "^3Новый ^4аккаунт создан^3. Повторный ^4вход ^3возможен ^4по нику и паролю^3.");
	}
	
	return 1;
}

public ReChangePasswordChecker(id){
	read_argv(1, user_password[id], 47);
	remove_quotes(user_password[id]);
	
	if(equal(user_password[id][0], "")){
		Print(id, "Вы обязательно должны ввести пароль!");
		return 1;
	}
	
	if(!symbols_correct(id)){
		Print(id, "Запрещено использовать спец. символы и пробелы!");
		return 1;
	}
	
	static data[256]; new name[36]; get_user_name(id, name, charsmax(name));
	
	if(nvault_get(g_vault, name, data, sizeof(data) - 1)){
		nvault_remove(g_vault, name);
	}
	
	if(nvault_get(g_hVault, name, data, sizeof(data) - 1)){
		nvault_remove(g_hVault, name);
	}
	
	if(nvault_get(g_vault, g_iAuthID[id], data, sizeof(data) - 1)){
		nvault_remove(g_vault, g_iAuthID[id]);
	}
	
	if(nvault_get(g_hVault, g_iAuthID[id], data, sizeof(data) - 1)){
		nvault_remove(g_hVault, g_iAuthID[id]);
	}
	
	Save(id);
	SaveData(id);
	
	menutype[id] = 1;
	
	if(!get_in[id])
		AuthorizationForm(id);
	else
		AuthAccChangeMenu(id);
	
	Print(id, "^4Успешно! ^3Теперь вы можете войти на сервер, используя ^4новый пароль^3!");
	return 1;
}

public TriedActivate(id){
	new key_field[70]; new name[36];
	get_user_name(id, name, charsmax(name));
	read_argv(1, key_field, charsmax(key_field));
	remove_quotes(key_field);
	
	static data[8];
	if(nvault_get(g_keys_vault, key_field, data, charsmax(data))){
		new text[24]; user_tries[id] = 0;
		
		switch(str_to_num(data)){
			case 1:{
				formatex(text, charsmax(text), "админом");
				
				if(user_admin_days[id] - floatround(get_gametime()) <= 0)
					user_admin_days[id] += RIGHTS_TIME + floatround(get_gametime());
				else
					user_admin_days[id] += RIGHTS_TIME;
					
				set_user_flags(id, read_flags(ADMINS_FLAGS));
			}
			case 2:{
				formatex(text, charsmax(text), "VIP");
				
				if(user_vip_days[id] - floatround(get_gametime()) <= 0)
					user_vip_days[id] += RIGHTS_TIME + floatround(get_gametime());
				else
					user_vip_days[id] += RIGHTS_TIME;
					
				set_user_flags(id, read_flags(VIPS_FLAGS));
			}
			case 3:{
				formatex(text, charsmax(text), "админом и VIP");
				
				if(user_admin_days[id] - floatround(get_gametime()) <= 0)
					user_admin_days[id] += RIGHTS_TIME + floatround(get_gametime());
				else
					user_admin_days[id] += RIGHTS_TIME;
				
				if(user_vip_days[id] - floatround(get_gametime()) <= 0)
					user_vip_days[id] += RIGHTS_TIME + floatround(get_gametime());
				else
					user_vip_days[id] += RIGHTS_TIME;
				
				set_user_flags(id, read_flags(ADM_VIPS_FLAGS));
			}
			default:{
				Print(id, "Неполадки на стороне сервера. Свяжитесь с нами! Сайт: ^4sg-cs.hol.es^3, skype: ^4slavoookk^3.");
				return PLUGIN_HANDLED;
			}
		}
		
		Save(id);
		SaveData(id);
		
		for(new i = 1; i <= g_max_clients; i++){
			Print(i, "^4%s ^3стал ^4%s ^3на нашем сервере! Поздравляем!", name, text);
		}
		
		CheckRV(id);
		CheckAccess(id);
		
		if(task_exists(7774553613))
			remove_task(7774553613);
		
		usersChecker();
		nvault_remove(g_keys_vault, key_field);
	}
	else{
		user_tries[id]++;
		
		if(user_tries[id] < 3){
			Print(id, "Неверный ключ. Осталось попыток:^4 %d^3.", 3 - user_tries[id]);
		}else{
			for(new i = 1; i <= g_max_clients; i++){
				Print(i, "^4%s ^3забанен на^4 3 дня^3. ^4Причина^3: ^4подбор ключей активации^3.", name);
			}
			
			server_cmd("amx_ban ^"%s^" 4320 ^"You`ve tried to hack our system.^"", name);
		}
	}
	
	return PLUGIN_HANDLED;
}

public TriedAddActivation(id){
	new key_field[70]; new type_field[8];
	read_argv(1, key_field, charsmax(key_field));
	remove_quotes(key_field);
	
	if(equal(key_field, "auto")){
		Print(id, "Auto doesn`t work, but it will be soon.");
		return PLUGIN_HANDLED;
	}
	
	strbreak(key_field, key_field, charsmax(key_field), type_field, charsmax(type_field));
	
	if(str_to_num(type_field) <= 0 || str_to_num(type_field) > 3){
		Print(id, "Неверный тип ключа. 1 - for admins, 2 - for VIPs, 3 - all.");
		return PLUGIN_HANDLED;
	}
	
	static data[8];
	if(nvault_get(g_keys_vault, key_field, data, charsmax(data))){
		Print(id, "Такой ключ уже был добавлен раньше! Мб стоит использовать auto?");
		return PLUGIN_HANDLED;
	}else{
		formatex(data, charsmax(data), " %s", type_field);
		nvault_set(g_keys_vault, key_field, data);
		Print(id, "Новый код активации ^4успешно добавлен и записан ^3в консоль.");
		client_print(id, print_console, "You`ve just added new key (type: %s): %s", type_field, key_field);
		nvault_close(g_keys_vault);
		g_keys_vault = nvault_open("agm_pay_keys");
	}
	
	return PLUGIN_HANDLED;
}

public message_ShowMenu(msg, something, id){
	static sMenuCode[24];
	get_msg_arg_string(4, sMenuCode, charsmax(sMenuCode));
	
	if(equal(sMenuCode, "#Team_Select") || equal(sMenuCode, "#Team_Select_Spect")
	|| equal(sMenuCode, "#IG_Team_Select") || equal(sMenuCode, "#IG_Team_Select_Spect")){
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

public message_VGUIMenu(msg, something, id){
	return PLUGIN_HANDLED;
}

public set_autojoin(id)
{
	new tt_count, ct_count, j_team = random_num(1, 2);
	for(new i = 1; i <= g_max_clients; i++){
		if(!is_user_connected(i)) continue;
		
		if(get_user_team(i) == 1){
			tt_count++;
		}
		else if(get_user_team(i) == 2){
			ct_count++;
		}
	}
	
	if(tt_count > ct_count){
		j_team = 2;
	}else if(ct_count > tt_count){
		j_team = 1;
	}	
	
	new j_team_text[2]; 
	formatex(j_team_text, charsmax(j_team_text), "%d", j_team);
	engclient_cmd(id, "jointeam", j_team_text);
	engclient_cmd(id, "joinclass", "5");
	
	if(j_team == 2){
		cs_set_user_team(id, CS_TEAM_CT);
	}else if(j_team == 1){
		cs_set_user_team(id, CS_TEAM_T);
	}
	CheckAccess(id);
	show_menu(id, 0, "^n", 1);
}

public CheckRV(client)
{
	new time_to_text[32]; new who[2];
	if(user_admin_days[client] - floatround(get_gametime()) > 0){
		TimeToString(user_admin_days[client] - floatround(get_gametime()), time_to_text, charsmax(time_to_text), true);
		Print(client, "Ваша админка истекает через: %s.", time_to_text);
		who[0] = 1;
	}
	
	if(user_vip_days[client] - floatround(get_gametime()) > 0){
		TimeToString(user_vip_days[client] - floatround(get_gametime()), time_to_text, charsmax(time_to_text), true);
		Print(client, "Ваш VIP-статус истекает через: %s.", time_to_text);
		who[1] = 1;
	}
	
	if(who[0] && who[1]){
		set_user_flags(client, read_flags(ADM_VIPS_FLAGS));
	}else if(who[0]){
		set_user_flags(client, read_flags(ADMINS_FLAGS));
	}else if(who[1]){
		set_user_flags(client, read_flags(VIPS_FLAGS));
	}
}

public CheckAccess(client){
	g_Vip[client] =	bool:access(client, ADMIN_LEVEL_G);
	g_admin[client] = bool:access(client, ADMIN_LEVEL_A);
}

client_valid_authid(authid[])
{
	return (regex_match_c(authid, g_SteamID_pattern, g_regex_return) > 0);
}

public client_disconnect(client)
{
	if(task_exists(192144256 + client)){
		remove_task(192144256 + client);
	}
	
	if(task_exists(4312341235 + client)){
		remove_task(4312341235 + client);
	}
	
	if(get_in[client]){
		Save(client);
		SaveData(client);
	}
	
	i_poisoned[client] = 0;
	f_poisoned_dmg[client] = 0.0;
	i_poison_attacker[client] = 0;
	f_flashed[client] = 0.0;
	
	b_should_no_pain[client] = false;
	b_stealth[client] = false;
	b_boots[client] = false;
	g_stucked[client] = false;
	
	get_in[client] = false;
	g_iAuthID[client][0] = 0;
	g_iAuthStatus[client] = false;
	g_iRevivedOnce[client] = false;
	g_iNextRoundKnife[client] = g_iKnivesCount - 1;
}

Save(client)
{
	if(g_vault == INVALID_HANDLE)
		return PLUGIN_HANDLED;
	
	static data[256], len; new data_index[36];
	
	if(accounttype[client] == 1){
		get_user_name(client, data_index, charsmax(data_index));
	}else if(accounttype[client] == 2 && g_iAuthStatus[client]){
		formatex(data_index, charsmax(data_index), g_iAuthID[client]);
	}else{
		return PLUGIN_HANDLED;
	}
	
	replace_all(data_index, charsmax(data_index), " ", "=a$(z#<)");
	
	len = formatex(data, sizeof(data) - 1, " %s %i", user_password[client], g_iPoint[client]);
	len += formatex(data[len], sizeof(data) - len - 1, " %i", g_iTotal[client]);
	len += formatex(data[len], sizeof(data) - len - 1, " %i", g_iLevel[client]);
	
	for( new iItem = 0; iItem < g_iItemCount; iItem++ )
	{
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_iItemLevel[client][iItem]);
	}
	
	for( new iWeap = 0; iWeap < g_iWeapCount; iWeap++ )
	{
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_iWeapLevel[client][iWeap]);
	}
	
	for( new iKnife = 0; iKnife < g_iKnivesCount; iKnife++ )
	{
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_iKnifeLevel[client][iKnife]);
	}
	
	len += formatex(data[len], sizeof(data) - len - 1, " %i", g_iNextRoundKnife[client]);
	len += formatex(data[len], sizeof(data) - len - 1, " %i", user_admin_days[client]);
	len += formatex(data[len], sizeof(data) - len - 1, " %i", user_vip_days[client]);
	
	nvault_set(g_vault, data_index, data);
	
	nvault_close(g_vault);
	g_vault = nvault_open("agm_save");
	
	return PLUGIN_HANDLED;
}

SaveData(iPlayer)
{
	if(g_hVault == INVALID_HANDLE)
		return PLUGIN_HANDLED;
	
	new szName[32]; new data_index[36];
	get_user_name( iPlayer, szName, charsmax(szName));
	
	if(accounttype[iPlayer] == 1){
		formatex(data_index, charsmax(data_index), szName);
	}else if(accounttype[iPlayer] == 2 && g_iAuthStatus[iPlayer]){
		formatex(data_index, charsmax(data_index), g_iAuthID[iPlayer]);
	}else{
		return PLUGIN_HANDLED;
	}
	
	replace_all(data_index, charsmax(data_index), " ", "=a$(z#<)");
	
	new iTime = get_user_time(iPlayer) - g_iTimeOffset[iPlayer];
	new iTotalTime = g_iTime[iPlayer] + iTime;
	
	new data[256];
	
	formatex(data, sizeof(data) - 1, " %s %i %i %i %i %i %i %i %i %s", user_password[iPlayer], iTotalTime, g_iRankPoint[iPlayer], g_iStats[iPlayer][0], g_iStats[iPlayer][1], g_iStats[iPlayer][2], g_iStats[iPlayer][3], g_iStats[iPlayer][4], user_is_ranked_vip[iPlayer], szName);
	
	nvault_set(g_hVault, data_index, data);
	g_iTimeOffset[iPlayer] += iTime;
	
	nvault_close(g_hVault);
	g_hVault = nvault_open("agm_save_top");
	
	return PLUGIN_HANDLED;
}

Load(client)
{
	if(g_vault == INVALID_HANDLE || g_hVault == INVALID_HANDLE){
		Print(client, "^3Проблемы на стороне сервера, отпишитесь на ^4sg-cs.hol.es^3!");
		AuthorizationForm(client);
		return PLUGIN_HANDLED;
	}
	
	if(equal(user_password[client], "")){
		Print(client, "^3Авторизация ^4не выполнена^3! Неверные данные!");
		AuthorizationForm(client);
		return PLUGIN_HANDLED;
	}
	
	static data[256]; static left_data[36], right_data[208]; 
	new bool:error = false; new name[64]; 
	get_user_name(client, name, charsmax(name));
	replace_all(name, charsmax(name), " ", "=a$(z#<)");
	
	if(nvault_get(g_vault, name, data, sizeof(data) - 1))
	{
		strbreak(data, left_data, sizeof(left_data) - 1, data, sizeof(data) - 1);
		
		if(equal(user_password[client], left_data)){
			accounttype[client] = 1;
			get_in[client] = true;
			StartLoad(client, data);
		}else{
			get_in[client] = false;
		}
	}
	else if(nvault_get(g_vault, g_iAuthID[client], data, sizeof(data) - 1)){
		strbreak(data, left_data, sizeof(left_data) - 1, data, sizeof(data) - 1);
		
		if(equal(user_password[client], left_data)){
			accounttype[client] = 2;
			get_in[client] = true;
			StartLoad(client, data);
		}else{
			get_in[client] = false;
		}
	}
	else{
		error = true;
	}
	
	if(nvault_get(g_hVault, name, data, sizeof(data) - 1))
	{ 
		strbreak(data, left_data, sizeof(left_data) - 1, right_data, sizeof(right_data) - 1);
		
		if(equal(user_password[client], left_data) && accounttype[client] == 1){
			get_in[client] = true;
			ReadVaultData(data, charsmax(data), user_password[client], 47, g_iTime[client], g_iRankPoint[client], g_iStats[client][0], g_iStats[client][1], g_iStats[client][2], g_iStats[client][3], g_iStats[client][4], user_is_ranked_vip[client]);
		}else{
			get_in[client] = false;
		}
	}
	else if(nvault_get(g_hVault, g_iAuthID[client], data, sizeof(data) - 1))
	{ 
		strbreak(data, left_data, sizeof(left_data) - 1, right_data, sizeof(right_data) - 1);
		
		if(equal(user_password[client], left_data) && accounttype[client] == 2){
			get_in[client] = true;
			ReadVaultData(data, charsmax(data), user_password[client], 47, g_iTime[client], g_iRankPoint[client], g_iStats[client][0], g_iStats[client][1], g_iStats[client][2], g_iStats[client][3], g_iStats[client][4], user_is_ranked_vip[client]);
		}else{
			get_in[client] = false;
		}
	}
	else{
		error = true;
	}
	
	if(get_in[client] && !error && menutype[client] == 1){
		CheckRV(client);
		set_autojoin(client);
		k_cooldown[client] = 0.0;
		Print(client, "^4Вы успешно авторизовались ^3под своим аккаунтом!");
	}else if(menutype[client] == 3){
		if(!get_in[client]){
			menutype[client] = 1;
			Print(client, "^3Вход в настройки ^4не выполнен^3! Неверные данные!");
		}else CheckRV(client);
		
		get_in[client] = false;
		AuthorizationForm(client);
	}
	else{
		Print(client, "^3Авторизация ^4не выполнена^3! Неверные данные!");
		AuthorizationForm(client);
	}
	
	return PLUGIN_HANDLED;
}

StartLoad(client, data[256])
{
	static num[64];
	
	strbreak(data, num, sizeof(num) - 1, data, sizeof(data) - 1);
	g_iPoint[client] = str_to_num(num);
	
	strbreak(data, num, sizeof(num) - 1, data, sizeof(data) - 1);
	g_iTotal[client] = str_to_num(num);
	
	strbreak(data, num, sizeof(num) - 1, data, sizeof(data) - 1);
	g_iLevel[client] = str_to_num(num);
	
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
	
	for( new iKnife = 0; iKnife < g_iKnivesCount; iKnife++ )
	{
		strbreak(data, num, sizeof(num) - 1, data, sizeof(data) - 1);
		g_iKnifeLevel[client][iKnife] = clamp(str_to_num(num), 0, g_iKnifeMaxLevel[iKnife]);
	}
	
	strbreak(data, num, sizeof(num) - 1, data, sizeof(data) - 1);
	g_iNextRoundKnife[client] = str_to_num(num);
	g_iPreNextRoundKnife[client] = str_to_num(num);
	
	strbreak(data, num, sizeof(num) - 1, data, sizeof(data) - 1);
	user_admin_days[client] = str_to_num(num);
	
	strbreak(data, num, sizeof(num) - 1, data, sizeof(data) - 1);
	user_vip_days[client] = str_to_num(num);
	
	CheckChatName(client);
	
	return PLUGIN_CONTINUE;
}

ReadVaultData( data[], dataMaxLen = 0, userPass[] = "", userPassLen = 0, &iTime = 0, &iPoint = 0, &Rounds = 0, &Kills = 0, &Deaths = 0, &Suicides = 0, &Survives = 0, &IsRankedVIP = 0, szName[ ] = "", iNameMaxLen = 0 )
{
	new num[64];
	
	strbreak(data, userPass, userPassLen, data, dataMaxLen);
	
	strbreak(data, num, sizeof(num) - 1, data, dataMaxLen);
	iTime = str_to_num(num);
	
	strbreak(data, num, sizeof(num) - 1, data, dataMaxLen);
	iPoint = str_to_num(num);
	
	strbreak(data, num, sizeof(num) - 1, data, dataMaxLen);
	Rounds = str_to_num(num);
	
	strbreak(data, num, sizeof(num) - 1, data, dataMaxLen);
	Kills = str_to_num(num);
	
	strbreak(data, num, sizeof(num) - 1, data, dataMaxLen);
	Deaths = str_to_num(num);
	
	strbreak(data, num, sizeof(num) - 1, data, dataMaxLen);
	Suicides = str_to_num(num);
	
	strbreak(data, num, sizeof(num) - 1, data, dataMaxLen);
	Survives = str_to_num(num);
	
	strbreak(data, num, sizeof(num) - 1, szName, iNameMaxLen);
	IsRankedVIP = str_to_num(num);
}

public CheckChatName(client)
{
	if(g_iLevel[client] <= 0)
	{
		format(pm_Name[client], 31, gszExperienceName[0]);
	}
	else if(g_iLevel[client] < 10)
	{
		format(pm_Name[client], 31, gszExperienceName[1]);
	}
	else if(g_iLevel[client] < 20)
	{
		format(pm_Name[client], 31, gszExperienceName[2]);
	}
	else if(g_iLevel[client] < 30)
	{
		format(pm_Name[client], 31, gszExperienceName[3]);
	}
	else if(g_iLevel[client] < 40)
	{
		format(pm_Name[client], 31, gszExperienceName[4]);
	}
	else if(g_iLevel[client] < 50)
	{
		format(pm_Name[client], 31, gszExperienceName[5]);
	}
	else if(g_iLevel[client] < 60)
	{
		format(pm_Name[client], 31, gszExperienceName[6]);
	}
	else if(g_iLevel[client] < 70)
	{
		format(pm_Name[client], 31, gszExperienceName[7]);
	}
	else if(g_iLevel[client] < 80)
	{
		format(pm_Name[client], 31, gszExperienceName[8]);
	}
	else if(g_iLevel[client] < 90)
	{
		format(pm_Name[client], 31, gszExperienceName[9]);
	}
	else if(g_iLevel[client] < 100)
	{
		format(pm_Name[client], 31, gszExperienceName[10]);
	}
	else if(g_iLevel[client] < 101)
	{
		format(pm_Name[client], 31, gszExperienceName[11]);
	}
	else if(g_iLevel[client] >= 101)
	{
		format(pm_Name[client], 31, gszExperienceName[12]);
	}
}

NewUser(client)
{
	if(!get_in[client] && accounttype[client] > 0)
		return PLUGIN_HANDLED;

	g_iNextRoundKnife[client] = g_iKnivesCount - 1;
	
	g_iLevel[client] = 0;
	g_iPoint[client] = 0;
	g_iTotal[client] = 0;
	
	for( new iItem = 0; iItem < g_iItemCount; iItem++ )
	{
		g_iItemLevel[client][iItem] = 0;
	}
	for( new iWeap = 0; iWeap < g_iWeapCount; iWeap++ )
	{
		g_iWeapLevel[client][iWeap] = 0;
	}
	
	format(pm_Name[client], 31, gszExperienceName[0]);
	
	nvault_close(g_vault);
	g_vault = nvault_open("agm_save");
	
	return PLUGIN_HANDLED;
}

NewUserTop(client)
{
	if(!get_in[client] && accounttype[client] > 0)
		return PLUGIN_HANDLED;

	g_iRankPoint[client] = 0;
	
	for( new Stats = 0; Stats < MAX_STATS; Stats++ )
	{
		g_iStats[client][Stats] = 0;
	}
	
	nvault_close(g_hVault);
	g_hVault = nvault_open("agm_save_top");
	
	return PLUGIN_HANDLED;
}

public FwdPlayerTakeDMG(iPlayer, inflictor, attacker, Float:damage, damagebits)
{
	if(get_pcvar_num(agm_status) == 0 || get_pcvar_num(agm_status) <= 4 && get_pcvar_num(agm_status) >= 3)
	{
		return HAM_IGNORED;
	}
	 
	//If player is alive and the damage is done by falling
	if(is_user_alive(iPlayer) && (damagebits & DMG_FALL) )
	{
		new percent = g_iItemMaxVal[FALL_DMG_REDUCE] * g_iItemLevel[iPlayer][FALL_DMG_REDUCE] / g_iItemMaxLevel[FALL_DMG_REDUCE];
		SetHamParamFloat(4, damage * (1.0 - (float(percent) / 100.0)));
	}
	
	if( ( 1 <= attacker <= g_max_clients && iPlayer != attacker ) )
	{
		new Float:fMultiplier = float(g_iItemMaxVal[EXTRA_DAMAGE] * g_iItemLevel[iPlayer][EXTRA_DAMAGE] / g_iItemMaxLevel[EXTRA_DAMAGE]);
		SetHamParamFloat(4, damage + (damage / 100 * fMultiplier));
		
		if(get_pcvar_num(agm_status) == 1){
			if(g_iNextRoundKnife[iPlayer] == FAST && g_iKnifeLevel[iPlayer][FAST] > 0){
				if((damagebits & DMG_SLASH) || (damagebits & DMG_BULLET)){
					if(random_num(1, 100) <= i_fastAvoidPercents[g_iKnifeLevel[iPlayer][FAST]-1]){
						SetHamParamFloat(4, 0.0);
						b_should_no_pain[iPlayer] = true;
					}
				}
			}
			
			if(g_iNextRoundKnife[attacker] == POISON && g_iKnifeLevel[attacker][POISON] > 0){
				//iPlayer = attacker; for test on yourself
				i_poison_attacker[iPlayer] = attacker;
				i_poisoned[iPlayer] = i_poison_time[g_iKnifeLevel[attacker][POISON]-1] + 10;
				f_poisoned_dmg[iPlayer] += f_poison_dmg[g_iKnifeLevel[attacker][POISON]-1];
				emit_sound(iPlayer, CHAN_STATIC, k_im_poisoned, 1.0, ATTN_NORM, 0, PITCH_NORM);
			}
		}
	}
	
	return HAM_IGNORED;
}

public FwdPlayerTakeDMGPAIN(iPlayer, inflictor, attacker, Float:damage, damagebits)
{
	if(get_pcvar_num(agm_status) == 0 || get_pcvar_num(agm_status) <= 4 && get_pcvar_num(agm_status) >= 3)
	{
		return HAM_IGNORED;
	}
	
	if(b_should_no_pain[iPlayer]){
		b_should_no_pain[iPlayer] = false;
		set_pdata_float(iPlayer, 108, 1.0);
		
		static name[32]; get_user_name(attacker, name, charsmax(name));
		Print(iPlayer, "Вы ^4уклонились ^3от ^4атаки ^3%s с помощью^4 Fast Knife^3! ^4[%d%% ^3шанс^4]", name, i_fastAvoidPercents[g_iKnifeLevel[iPlayer][FAST]-1]); 
		get_user_name(iPlayer, name, charsmax(name));
		Print(attacker, "%s ^4уклонился ^3от вашей ^4атаки ^3с помощью^4 Fast Knife^3!", name);
	}
	
	if( g_iItemLevel[iPlayer][NO_PAIN] >= 1 )
	{
		set_pdata_float(iPlayer, 108, 1.0);
	}
	
	return HAM_IGNORED;
}

public event_redDamageScreen(id){
	if(i_poisoned[id] <= 0 && f_flashed[id] < 0.1){
		message_begin(MSG_ONE, g_msgScreenFade, {0,0,0}, id);
		write_short(4096);    // Duration
		write_short(4096);    // Hold time
		write_short(4096);    // Fade type
		write_byte(200);
		write_byte(0);
		write_byte(0);
		write_byte(65);    // Alpha
		message_end();
	}

	return PLUGIN_HANDLED;
}

public FwdPlayerDeath(iPlayer, Killer, Shouldgib)
{
	if(get_pcvar_num(agm_status) == 0 || get_pcvar_num(agm_status) <= 4 && get_pcvar_num(agm_status) >= 3)
	{
		return PLUGIN_HANDLED;
	}
	 
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
		entity_set_string(id, EV_SZ_viewmodel, g_iKnivesModel_v[STANDART]);
		entity_set_string(id, EV_SZ_weaponmodel, g_iKnivesModel_p[STANDART]);
	}
}

public Task_Respawn(iPlayer)
{
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
	f_round_time = get_gametime();
	
	for( new id = 1; id <= g_max_clients; id++ )
	{
		if(!is_user_connected(id)) continue;
		
		g_iRevivedOnce[id] = false;
		
		f_flashed[id] = 0.0;
		
		i_poisoned[id] = 0;
		f_poisoned_dmg[id] = 0.0;
		
		if(get_pcvar_num(agm_status) == 1){
			if(g_iPreNextRoundKnife[id] != g_iNextRoundKnife[id]){
				g_iNextRoundKnife[id] = g_iPreNextRoundKnife[id];
			}
			
			if(g_iNextRoundKnife[id] == NINJA && g_iKnifeLevel[id][NINJA] > 2){
				set_user_footsteps(id, 1);
			}else{
				set_user_footsteps(id, 0);
			}
		}else{
			if(get_user_team(id) == 1){
				set_user_footsteps(id, 1);
			}
		}
	}
}

public eRound_end()
{	
	if(get_pcvar_num(agm_status) == 0)
	{
		return PLUGIN_HANDLED;
	}
	else if(get_playersnum() <= get_pcvar_num(players_num))
	{
		Print(0, "^03На сервере требуется^04 %d и более игроков^03, чтобы^04 получать points^03!", get_pcvar_num(players_num));
		return PLUGIN_HANDLED;
	}else if(first_round){
		first_round = false;
		return PLUGIN_HANDLED;
	}
	
	new bool: classic = false;
	
	if(get_pcvar_num(agm_status) <= 4 && get_pcvar_num(agm_status) >= 3)
	{
		classic = true;
	}
	
	new bool:tt_win = false;
	
	for( new i = g_first_client; i <= g_max_clients; i++ ){
		if(get_user_team(i) == 1 && is_user_alive(i))
		{
			tt_win = true;
			break;
		}
	}
	
	for( new i = g_first_client; i <= g_max_clients; i++ ){
		if(get_user_team(i) == 1)
		{
			if(is_user_alive(i))
			{
				new round_end_pm = 12, vip_pm = 3;
				
				g_iRankPoint[i] += round_end_pm;
				g_iStats[i][4]++;
				
				if(!classic)
				{
					if(g_Vip[i])
					{
						round_end_pm += vip_pm;
					}
					
					g_iPoint[i] += round_end_pm;
					g_iTotal[i] += round_end_pm;
					
					CheckLevel(i, 4);
				}
				
				if(g_Vip[i] && !classic)
				{
					Print(i, "^03Вы получили^04 %d+%d points^03 за то, что вы ^04выжили в этом раунде^03!", round_end_pm - vip_pm, vip_pm);
				}
				else
				{
					Print(i, "^03Вы получили^04 %d points^03 за то, что вы ^04выжили в этом раунде^03!", round_end_pm);
				}
			}
			else if(tt_win)
			{
				new round_end_pm = 1, vip_pm = 1;
				
				g_iRankPoint[i] += round_end_pm;
				
				if(!classic)
				{
					if(g_Vip[i])
					{
						round_end_pm += vip_pm;
					}
					
					g_iPoint[i] += round_end_pm;
					g_iTotal[i] += round_end_pm;
					
					CheckLevel(i, 4);
				}
				
				if(g_Vip[i] && !classic)
				{
					Print(i, "^03Вы получили^04 %d+%d points^03 за то, что ваша команда ^04победила в этом раунде^03!", round_end_pm - vip_pm, vip_pm);
				}
				else
				{
					Print(i, "^03Вы получили^04 %d point^03 за то, что ваша команда ^4победила в этом раунде^03!", round_end_pm);
				}
			}
		}
		else if(get_user_team(i) == 2 && !tt_win)
		{
			if(is_user_alive(i))
			{
				new round_end_pm = 3, vip_pm = 2;
				
				g_iRankPoint[i] += round_end_pm;
				
				if(!classic)
				{
					if(g_Vip[i])
					{
						round_end_pm += vip_pm;
					}
					
					g_iPoint[i] += round_end_pm;
					g_iTotal[i] += round_end_pm;
					
					CheckLevel(i, 4);
				}
				
				if(g_Vip[i] && !classic)
				{
					Print(i, "^03Вы получили^04 %d+%d points^03 за то, что вы ^04победили в этом раунде^03!", round_end_pm - vip_pm, vip_pm);
				}
				else
				{
					Print(i, "^03Вы получили^04 %d points^03 за то, что вы ^4победили в этом раунде^03!", round_end_pm);
				}
			}
			else
			{
				new round_end_pm = 2, vip_pm = 1;
				
				g_iRankPoint[i] += round_end_pm;
				
				if(!classic)
				{
					if(g_Vip[i])
					{
						round_end_pm += vip_pm;
					}
					
					g_iPoint[i] += round_end_pm;
					g_iTotal[i] += round_end_pm;
					
					CheckLevel(i, 4);
				}
				
				if(g_Vip[i] && !classic)
				{
					Print(i, "^03Вы получили^04 %d+%d points^03 за то, что ваша команда ^04победила в этом раунде^03!", round_end_pm - vip_pm, vip_pm);
				}
				else
				{
					Print(i, "^03Вы получили^04 %d points^03 за то, что ваша команда ^4победила в этом раунде^03!", round_end_pm);
				}
			}
		}
		
		g_iStats[i][0]++;
	}
	
	return PLUGIN_HANDLED;
}

public Event_DeathMsg()
{
	if(get_pcvar_num(agm_status) == 0)
	{
		return PLUGIN_HANDLED;
	}
	
	new killer = read_data(1);
	new victim = read_data(2);
	
	new bool: classic = false;
	
	if(get_pcvar_num(agm_status) <= 4 && get_pcvar_num(agm_status) >= 3)
	{
		classic = true;
	}
	
	if( (g_first_client <= killer <= g_max_clients) && victim != killer )
	{
		if(get_playersnum() >= get_pcvar_num(players_num))
		{
			new pm_kill = get_pcvar_num(agm_kills_points);
			new pm_death = get_pcvar_num(agm_deaths_points);
			new pm_vip = 2, bool: text = false;
			
			static skill[33];
			skill = "^03!";
				
			if( read_data(3) )
			{
				pm_kill += 1;
				skill = " в голову^03!";
			}
			else
			{
				static weapon[20];
				read_data(4, weapon, sizeof(weapon) - 1);
					
				if( contain(weapon, "grenade") >= 0 )
				{
					pm_kill += 2;
					skill = " с гранаты^03!";
				}
			}
			
			g_iRankPoint[killer] += pm_kill;
			g_iStats[killer][1]++;
				
			if(g_iRankPoint[victim] >= pm_death)
			{
				g_iRankPoint[victim] -= pm_death;
				
				if(!g_Vip[victim]){
					text = true;
					Print(victim, "^03Вы потеряли ^04%d point^03 за ^4смерть от руки противника^3!", pm_death);
				}
			}
			
			g_iStats[victim][2]++;
			
			if(g_Vip[killer])
			{
				pm_kill += pm_vip;
			}
				
			if(!classic)
			{
				g_iPoint[killer] += pm_kill;
				g_iTotal[killer] += pm_kill;
					
				if(g_iPoint[victim] >= pm_death && !g_Vip[victim])
				{
					g_iPoint[victim] -= pm_death;
						
					if(!text)
						Print(victim, "^03Вы потеряли ^04%d point^03 за ^4смерть от руки противника^3!", pm_death);
				}
					
				CheckLevel(killer, 5);
			}
				
			if(g_Vip[killer] && !classic)
			{
				Print(killer, "^03Вы получили ^04%d+%d points^03 за ^04убийство противника%s", pm_kill-pm_vip, pm_vip, skill);
			}
			else
			{
				Print(killer, "^03Вы получили ^04%d points^03 за ^04убийство противника%s", pm_kill, skill);
			}
		}
	}
	else
	{	
		if(get_playersnum() >= get_pcvar_num(players_num))
		{
			new pm_death = get_pcvar_num(agm_suicides_points);
			new bool: text = false;
			
			if(!classic)
			{
				text = true;
				
				if(g_Vip[victim]){
					pm_death-=1;
					Print(victim, "^03Вы потеряли ^04%d-1 points^03 за ^4самоубийство^3!", pm_death+1);
				}else{
					Print(victim, "^03Вы потеряли ^04%d points^03 за ^4самоубийство^3!", pm_death);
				}
				
				if(g_iPoint[victim] >= pm_death)
				{
					g_iPoint[victim] -= pm_death;
				}
			}
			
			if(g_iRankPoint[victim] >= pm_death)
			{
				g_iRankPoint[victim] -= pm_death;
				
				if(!text)
					Print(victim, "^03Вы потеряли ^04%d points^03 за ^4самоубийство^3!", pm_death);
			}
			g_iStats[victim][3]++;
		}
		
		emit_sound(victim, CHAN_STATIC, p_suicide, 1.0, ATTN_NORM, 0, PITCH_NORM);
	}
	
	return PLUGIN_HANDLED;
}

public CheckLevel(client, music)
{
	if(get_pcvar_num(agm_status) == 0 || get_pcvar_num(agm_status) == 3 || get_pcvar_num(agm_status) == 4)
		return PLUGIN_CONTINUE;
	
	if(g_iLevel[client] != 101)
	{
		if(g_iTotal[client] >= gszExperienceTable[g_iLevel[client]+1])
		{
			new name[36]; 
			get_user_name(client, name, charsmax(name));
		
			g_iLevel[client]++;
		
			CheckChatName(client);
		
			for(new i = 1; i <= g_max_clients; i++)
			{
				if(client == i)
					Print(i, "Вы достигли^4 %d уровня^3, набрав ^4%d points^3!", g_iLevel[client], gszExperienceTable[g_iLevel[client]]);
				else
					Print(i, "^4%s ^3достиг ^4%d уровня^3, набрав ^4%d points^3!!", name, g_iLevel[client], gszExperienceTable[g_iLevel[client]]);
			}
		
			if(music != 0)
				music = 6;
			
			CheckLevel(client, 0);
		}
	}
	
	//if(music == 1)
	//emit_sound(client, CHAN_STATIC, point_win, 1.0, ATTN_NORM, 0, PITCH_NORM);  //headsplash
	
	if(music == 2 || music == 4)
		emit_sound(client, CHAN_STATIC, point_block, 1.0, ATTN_NORM, 0, PITCH_NORM);  //pointblock
		
	//else if(music == 3)
	//emit_sound(client, CHAN_STATIC, point_win, 1.0, ATTN_NORM, 0, PITCH_NORM);  //jumps
	//else if(music == 4)
	//emit_sound(client, CHAN_STATIC, point_block, 1.0, ATTN_NORM, 0, PITCH_NORM);  //survive
	//else if(music == 5)
	//emit_sound(client, CHAN_STATIC, point_win, 1.0, ATTN_NORM, 0, PITCH_NORM);  //kill
	
	else if(music == 6)
		emit_sound(client, CHAN_STATIC, p_lvl_up, 1.0, ATTN_NORM, 0, PITCH_NORM);	//lvl+up
	
	return PLUGIN_CONTINUE;
}

public ResetMenu(client)
{
	if(menutype[client] != 3 && !get_in[client]) return PLUGIN_HANDLED;
	
	if(get_pcvar_num(agm_status) == 0 || get_pcvar_num(agm_status) <= 4 && get_pcvar_num(agm_status) >= 3)
	{
		Print(client, "^03Плагин временно отключен");
		return PLUGIN_HANDLED;
	}
	
	g_iLevel[client] = 0;
	g_iPoint[client] = 0;
	g_iTotal[client] = 0;
	g_iRankPoint[client] = 0;
	
	for( new Stats = 0; Stats < g_iItemCount; Stats++ )
	{
		g_iStats[client][Stats]++;
	}
	for( new iItem = 0; iItem < g_iItemCount; iItem++ )
	{
		g_iItemLevel[client][iItem] = 0;
	}
	for( new iWeap = 0; iWeap < g_iWeapCount; iWeap++ )
	{
		g_iWeapLevel[client][iWeap] = 0;
	}
	
	Print(client, "You`ve removed all your points, upgrades and cleaned rankstats!");
	
	Save(client);
	SaveData(client);
	
	return PLUGIN_HANDLED;
}

public Point_StartMenu(iPlayer)
{
	if(menutype[iPlayer] != 3 && !get_in[iPlayer]) return PLUGIN_HANDLED;
	
	if(get_pcvar_num(agm_status) >= 3 && get_pcvar_num(agm_status) <= 4)
	{
		Print(iPlayer, "Сейчас на сервере выбран режим игры ^4без Scream Points^3!");
		return PLUGIN_HANDLED;
	}
	
	//Create the menu
	new menu = menu_create("\r[ScreamPoints] \w- \yMain Menu", "StartMenu_Handle");
	
	//Create Items Menu
	menu_additem(menu, "\wTotal Top", "1", 0);
	menu_additem(menu, "\wInformation^n", "2", 0);
	menu_additem(menu, "\rUpgrades Menu", "3", 0);
	menu_additem(menu, "\rWeapons Menu", "4", 0);
	
	new number_knife[48];
	
	if(get_pcvar_num(agm_status) != 1)
		formatex(number_knife, charsmax(number_knife), "\dKnives Menu^n");
	else
		formatex(number_knife, charsmax(number_knife), "\rKnives Menu^n");
	
	menu_additem(menu, number_knife, "5", 0);
	
	menu_additem(menu, "\yTransfer Points", "6", 0);
	menu_additem(menu, "\yRussian Roulette^n", "7", 0);
	
	if(get_pcvar_num(agm_status) != 1)
		formatex(number_knife, charsmax(number_knife), "\dCurrent: %s", g_iKnives[g_iNextRoundKnife[iPlayer]]);
	else
		formatex(number_knife, charsmax(number_knife), "\wCurrent: \r%s", g_iKnives[g_iNextRoundKnife[iPlayer]]);
		
	menu_additem(menu, number_knife, "8", 0);
	
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
			Point_ShopMenu_U(iPlayer);
		}
		case 4:
		{
			Point_ShopMenu_W(iPlayer);
		}
		case 5:
		{
			if(get_pcvar_num(agm_status) != 1)
			{
				Print(iPlayer, "^03На сервере выбран режим ^4без ножей^3!");
				Point_StartMenu(iPlayer);
			}
			else{
				Point_ShopMenu_K(iPlayer);
			}
		}
		case 6:
		{
			Point_TransferMenu(iPlayer);
		}
		case 7:
		{
			if(get_playersnum() >= get_pcvar_num(players_num) && !g_roulette[iPlayer])
			{
				Point_RandomMenu(iPlayer);
				Print(iPlayer, "^04Введите ставку - максимум 10000 points.");
			}
			else if(g_roulette[iPlayer])
			{
				Print(iPlayer, "^04Вы уже играли в рулетку в этом раунде!");
			}
			else
			{
				Print(iPlayer, "^03Вы не можете играть в рулетку, так как на сервере меньше %d игроков!", get_pcvar_num(players_num));
			}
		}
		case 8:
		{
			if(get_pcvar_num(agm_status) != 1)
			{
				Print(iPlayer, "^03На сервере выбран режим ^4без ножей^3!");
				Point_StartMenu(iPlayer);
			}
			else{
				Point_SelectKnifeMenu(iPlayer);
			}
		}
		case 0: return PLUGIN_HANDLED;
	}
	
	return PLUGIN_HANDLED;
}

public Info_Menu(iPlayer)
{
	new menu = menu_create("\r[ScreamPoints]\w- \ySelect information", "InfoMenu_Handle");
	
	//Create Items Menu
	menu_additem(menu, "\wUpgrades", "1", 0);
	menu_additem(menu, "\wPlugin", "2", 0);
	menu_additem(menu, "\wPlayers", "3", 0);

	//Display the menu
	menu_display(iPlayer, menu, 0);
}

public InfoMenu_Handle(iPlayer, menu, item)
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
	show_motd(iPlayer,"mode/upgrades.txt","Upgrades information");
	Info_Menu(iPlayer);
	
	return PLUGIN_HANDLED;
}

public Plugin_Info(iPlayer)
{
	show_motd(iPlayer,"mode/plugin.txt","Plugin information");
	Info_Menu(iPlayer);
	
	return PLUGIN_HANDLED;
}
	
public Point_PlayerMenu(iPlayer)
{
	new title[170]; formatex(title, sizeof(title) - 1, "\r[ScreamPoints] \w- \yPlayer Info^n^n\wChoose The Player");
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
	new tempname[36]; get_user_name(tempid, tempname, charsmax(tempname));
	
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
public RandomForPlayer(iPlayer)
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
		Print(iPlayer, "^03У вас нету^04 %i points^03!", check);
		
		client_cmd(iPlayer,"messagemode ___enter_the_number");
		return PLUGIN_HANDLED;
	}
	
	new g_iPointGive = str_to_num(arg);
	
	if(random_num(0,100) <= 40)
	{
		g_iPoint[iPlayer] += g_iPointGive;
		
		Print(iPlayer, "^03Поздравляю! Вы выиграли ^04%i points^03!", g_iPointGive);
	}
	else
	{
		g_iPoint[iPlayer] -= g_iPointGive;
		
		Print(iPlayer, "^03Вы проиграли ^04%i points^03!", g_iPointGive);
	}
	
	g_roulette[iPlayer] = true;
		
	return PLUGIN_HANDLED;
}
public Point_TransferMenu(iPlayer)
{	
	if(get_playersnum() <= 1){
		Print(iPlayer, "Сейчас на сервере нету игроков, которым можно передать points.");
		Point_StartMenu(iPlayer);
		return PLUGIN_HANDLED;
	}
	
	new title[170]; formatex(title, sizeof(title) - 1, "\r[ScreamPoints] \w- \yTransfer Menu^n^n\wChoose The Player^n\yYour Art Points: \r%i^n", g_iPoint[iPlayer]);
	new menu = menu_create(title, "TransferMenu_Handle");
	
	new players[32], pnum, tempid, valid_id = 0;
	new szName[32], szTempid[10];
    
	get_players(players, pnum);
	
	for( new i; i<pnum; i++ )
	{
		tempid = players[i];
		
		if(iPlayer != tempid)
		{
			valid_id++;
			
			get_user_name(tempid, szName, 31);
			num_to_str(tempid, szTempid, 9);
		
			menu_additem(menu, szName, szTempid, 0);
		}
	}
	
	if(valid_id <= 0)
	{
		Print(iPlayer, "Сейчас на сервере нету игроков, которым можно передать points.");
		Point_StartMenu(iPlayer);
		return PLUGIN_HANDLED;
	}
	else
	{
		menu_display(iPlayer, menu, 0);
	}
	
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
	Print(iPlayer, "^03Введите число передаваемых points.");
	client_cmd(iPlayer, "messagemode ___print_you_value");
	
	return PLUGIN_HANDLED;
}

public GivePointsIPlayer(iPlayer)
{
	static arg[33];
	read_argv(1, arg, charsmax(arg));
	
	if ( !strlen(arg) )
	{
		Print(iPlayer, "You can't set a transferred points blank! Please type a new value.");
		
		client_cmd(iPlayer,"messagemode ___print_you_value");
		return PLUGIN_HANDLED;
	}
	else if ( !IsStrFloat(arg) )
	{
		Print(iPlayer, "You can't use letters in a transferred points! Please type a new value.");
		
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
		Print(iPlayer, "^03У вас нету^04 %i points^03!", check);
		
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
	
	Print(iPlayer,"^03Вы успешно передали ^04%i points^03 игроку ^04%s^03!!!", g_iPointGive, iName2);
	Print(iDiName,"^03Игрок ^04%s ^03успешно передал вам ^04%i points^03!!!", iName, g_iPointGive);
	
	return PLUGIN_HANDLED;
}

public Point_ShopMenu_U(iPlayer)
{
	new title[70]; formatex(title, sizeof(title) - 1, "\r[ScreamPoints] \w- \yUpgades Menu");
	
	new menu = menu_create(title, "ShopMenu_U_Handle");
	
	new iNumber[5], szOption[80], iCost;
	
	for( new iItem = 0; iItem < g_iItemCount; iItem++ )
	{
		num_to_str(iItem, iNumber, 4);
		
		if(g_iItemLevel[iPlayer][iItem] > 0)
		{
			iCost = (g_iFirstCost[iItem] / g_iStepCost[iItem] + szCostTable[g_iItemLevel[iPlayer][iItem]]-1) * g_iStepCost[iItem];
		}
		else
		{
			iCost = g_iFirstCost[iItem];
		}
		
		new g_iNeedLvl = 0;
	
		if(g_iItemLevel[iPlayer][iItem] > 0)
		{
			if(g_iItemFirstLevel[iItem] == 1)
			{
				g_iNeedLvl = g_iItemStepLevel[iItem] * g_iItemLevel[iPlayer][iItem];
			}
			else
			{
				g_iNeedLvl = g_iItemFirstLevel[iItem] + g_iItemStepLevel[iItem] * g_iItemLevel[iPlayer][iItem];
			}
		}
		else
		{
			g_iNeedLvl = g_iItemFirstLevel[iItem];
		}
		
		//If the player already have maxlevel
		if( g_iItemLevel[iPlayer][iItem] >= g_iItemMaxLevel[iItem] )
		{
			formatex(szOption, charsmax(szOption), "\y%s", g_iItems[iItem]);
		}
		else if( g_iPoint[iPlayer] < iCost || g_iLevel[iPlayer] < g_iNeedLvl)
		{
			formatex(szOption, charsmax(szOption), "\d%s", g_iItems[iItem]);
		}
		else
		{
			formatex(szOption, charsmax(szOption), "\w%s", g_iItems[iItem]);
		}
		
		//Add all the menu items
		menu_additem(menu, szOption, iNumber);
	}
	
	//Display the menu
	menu_display(iPlayer, menu, 0);
	
	return PLUGIN_HANDLED;
}

public ShopMenu_U_Handle(iPlayer, menu, item)
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
	
	new key = str_to_num(data);
	g_iChoose[iPlayer] = key;
	ShowBuyMenu_U(iPlayer);
	
	return PLUGIN_HANDLED;
}

public ShowBuyMenu_U(iPlayer)
{	
	new iItem = g_iChoose[iPlayer];
	new Amount = g_iItemMaxVal[iItem] / g_iItemMaxLevel[iItem];
	
	new g_iPrefix[32]; new g_iStatusPrefix[24];
	
	if(iItem == NO_FLASH || iItem == ANTI_FROSTNADE || iItem == NO_FOOTSTEPS || iItem == NO_PAIN)
	{
		if(iItem == NO_FLASH && g_iItemLevel[iPlayer][iItem] == 1)
		{
			formatex(g_iStatusPrefix, charsmax(g_iStatusPrefix), "%s", g_iItemsPrefix[0]);
		}
		else if(iItem == NO_FLASH && g_iItemLevel[iPlayer][iItem] == 2)
		{
			formatex(g_iStatusPrefix, charsmax(g_iStatusPrefix), "%s & bangs", g_iItemsPrefix[2]);
		}
		else if(iItem == ANTI_FROSTNADE && g_iItemLevel[iPlayer][iItem] == 1)
		{
			formatex(g_iStatusPrefix, charsmax(g_iStatusPrefix), "%s", g_iItemsPrefix[1]);
		}
		else if(iItem == ANTI_FROSTNADE && g_iItemLevel[iPlayer][iItem] == 2)
		{
			formatex(g_iStatusPrefix, charsmax(g_iStatusPrefix), "%s & nades", g_iItemsPrefix[2]);
		}
		
		if(!(g_iItemLevel[iPlayer][iItem] == 0))
		{
			formatex(g_iPrefix, charsmax(g_iPrefix), "[%s%s]", g_iItemShort[iItem], g_iStatusPrefix);
		}
	}
	else if(!(g_iItemLevel[iPlayer][iItem] == 0))
	{
		formatex(g_iPrefix, charsmax(g_iPrefix), "[%d%s%s]", Amount*g_iItemLevel[iPlayer][iItem], g_iItemShort[iItem], g_iStatusPrefix);
	}
	
	new g_iNeedLvl = 0;
	
	if(g_iItemLevel[iPlayer][iItem] > 0)
	{
		if(g_iItemFirstLevel[iItem] == 1)
		{
			g_iNeedLvl = g_iItemStepLevel[iItem] * g_iItemLevel[iPlayer][iItem];
		}
		else
		{
			g_iNeedLvl = g_iItemFirstLevel[iItem] + g_iItemStepLevel[iItem] * g_iItemLevel[iPlayer][iItem];
		}
	}
	else
	{
		g_iNeedLvl = g_iItemFirstLevel[iItem];
	}
	
	new title[192]; formatex(title, sizeof(title) - 1, "\r[ScreamPoints] \w- \yBuy Upgrades Menu: \r%d\y/\r%d^n^n[%s] %s^n^n\yYour lvl: \r%i\y/\r%i^n\yItem`s lvl: \r%i\y/\r%i^n\yYour Points: \r%i", g_iChoose[iPlayer]+1, g_iItemCount, g_iItems[iItem], g_iPrefix, g_iLevel[iPlayer], g_iNeedLvl, g_iItemLevel[iPlayer][iItem], g_iItemMaxLevel[iItem], g_iPoint[iPlayer]);
	
	new Float:iCost, szOption[64];
	
	iCost=1.0*g_iFirstCost[iItem] / g_iStepCost[iItem];
	iCost+=szCostTable[g_iItemLevel[iPlayer][iItem]]-1;
	iCost*=g_iStepCost[iItem];
	
	new menu = menu_create(title, "BuyMenu_Handle_U");
	
	new g_iSellPrefix[24];
	
	if(iItem == NO_FLASH || iItem == ANTI_FROSTNADE)
	{
		if(iItem == NO_FLASH && g_iItemLevel[iPlayer][iItem] == 0)
		{
			formatex(g_iStatusPrefix, charsmax(g_iStatusPrefix), "%s", g_iItemsPrefix[0]);
		}
		else if(iItem == NO_FLASH && g_iItemLevel[iPlayer][iItem] == 1)
		{
			formatex(g_iStatusPrefix, charsmax(g_iStatusPrefix), "%s", g_iItemsPrefix[2]);
			formatex(g_iSellPrefix, charsmax(g_iSellPrefix), "%s%s", g_iItemShort[iItem], g_iItemsPrefix[0]);
		}
		else if(iItem == ANTI_FROSTNADE && g_iItemLevel[iPlayer][iItem] == 0)
		{
			formatex(g_iStatusPrefix, charsmax(g_iStatusPrefix), "%s", g_iItemsPrefix[1]);
		}
		else if(iItem == ANTI_FROSTNADE && g_iItemLevel[iPlayer][iItem] == 1)
		{
			formatex(g_iStatusPrefix, charsmax(g_iStatusPrefix), "%s", g_iItemsPrefix[2]);
			formatex(g_iSellPrefix, charsmax(g_iSellPrefix), "%s%s", g_iItemShort[iItem], g_iItemsPrefix[1]);
		}
		else
			formatex(g_iSellPrefix, charsmax(g_iSellPrefix), "%s%s", g_iItemShort[iItem], g_iItemsPrefix[2]);
		
		formatex(g_iPrefix, charsmax(g_iPrefix), "%s%s", g_iItemShort[iItem], g_iStatusPrefix);
	}
	else if(iItem == NO_FOOTSTEPS || iItem == NO_PAIN)
	{
		formatex(g_iPrefix, charsmax(g_iPrefix), "%s", g_iItems[iItem]);
	}
	else
	{
		formatex(g_iPrefix, charsmax(g_iPrefix), "%d%s%s", Amount, g_iItemShort[iItem], g_iStatusPrefix);
	}
	
	if(g_iItemLevel[iPlayer][iItem] != g_iItemMaxLevel[iItem])
	{
		new iCost_txt[16]; format(iCost_txt, charsmax(iCost_txt), "%f", iCost);
		
		if(g_iPoint[iPlayer] < str_to_num(iCost_txt) || g_iLevel[iPlayer] < g_iNeedLvl)
		{
			formatex(szOption, charsmax(szOption), "\dBuy %s (Cost: %d)", g_iPrefix, str_to_num(iCost_txt));
		}
		else
		{
			formatex(szOption, charsmax(szOption), "\yBuy %s (Cost: %d)", g_iPrefix, str_to_num(iCost_txt));
		}
	}
	else
	{
		formatex(szOption, charsmax(szOption), "\dYou can`t buy.");
	}
	menu_additem(menu, szOption, "1");
	
	if(g_iItemLevel[iPlayer][iItem] > 0)
	{
		iCost=1.0*g_iFirstCost[iItem] / g_iStepCost[iItem];
		iCost+=szCostTable[g_iItemLevel[iPlayer][iItem]-1]-1;
		iCost*=g_iStepCost[iItem];
		iCost/= 2;
		
		new iCost_txt[16]; format(iCost_txt, charsmax(iCost_txt), "%f", iCost);
		
		replace_all(g_iPrefix, charsmax(g_iPrefix), " & nades", "");
		replace_all(g_iPrefix, charsmax(g_iPrefix), " & bangs", "");
		
		if(iItem == NO_FLASH || iItem == ANTI_FROSTNADE)
			formatex(szOption, charsmax(szOption), "\ySell %s (Cost: %d)", g_iSellPrefix, str_to_num(iCost_txt));
		else
			formatex(szOption, charsmax(szOption), "\ySell %s (Cost: %d)", g_iPrefix, str_to_num(iCost_txt));
	}
	else
	{
		formatex(szOption, charsmax(szOption), "\dYou can`t sell.");
	}
	
	menu_additem(menu, szOption, "2");
	menu_additem(menu, "Read Information", "3");
	
	if(g_iChoose[iPlayer] >= g_iItemCount-1)
	{
		menu_additem(menu, "\dNext", "4");
	}
	else
	{
		menu_additem(menu, "Next", "4");
	}
	
	if(g_iChoose[iPlayer] <= 0)
	{
		menu_additem(menu, "\dBack", "5");
	}
	else
	{
		menu_additem(menu, "Back", "5");
	}
	
	menu_display(iPlayer, menu, 0);
	
	return PLUGIN_HANDLED;
}

public BuyMenu_Handle_U(iPlayer, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		Point_ShopMenu_U(iPlayer);
		return PLUGIN_HANDLED;
	}
	
	new data[6], iName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	
	new key = str_to_num(data);
	
	switch(key)
	{
		case 1:
		{
			new iItem = g_iChoose[iPlayer], Level = g_iItemLevel[iPlayer][iItem];
			
			new g_iNeedLvl = 0;
	
			if(g_iItemLevel[iPlayer][iItem] > 0)
			{
				if(g_iItemFirstLevel[iItem] == 1)
				{
					g_iNeedLvl = g_iItemStepLevel[iItem] * g_iItemLevel[iPlayer][iItem];
				}
				else
				{
					g_iNeedLvl = g_iItemFirstLevel[iItem] + g_iItemStepLevel[iItem] * g_iItemLevel[iPlayer][iItem];
				}
			}
			else
			{
				g_iNeedLvl = g_iItemFirstLevel[iItem];
			}
			
			new Float:iCost;
			
			iCost=1.0*g_iFirstCost[iItem] / g_iStepCost[iItem];
			iCost+=szCostTable[g_iItemLevel[iPlayer][iItem]]-1;
			iCost*=g_iStepCost[iItem];
			
			new iCost_txt[16]; format(iCost_txt, charsmax(iCost_txt), "%f", iCost);
			
			if( g_iItemLevel[iPlayer][iItem] == g_iItemMaxLevel[iItem] )
			{
				Print(iPlayer, "^x04%s ^03максимального уровня!", g_iItems[iItem]);
				emit_sound(iPlayer, CHAN_STATIC, error, 1.0, ATTN_NORM, 0, PITCH_NORM);
			}
			else if(g_iLevel[iPlayer] < g_iNeedLvl)
			{
				Print(iPlayer, "^x03Вы должны быть более высокого уровня, чтобы прокачать ^04%s^03. Уровень: ^04%i^03.", g_iItems[iItem], Level+1);
				emit_sound(iPlayer, CHAN_STATIC, error, 1.0, ATTN_NORM, 0, PITCH_NORM);
			}
			//If the player cant afford the item
			else if( g_iPoint[iPlayer] < str_to_num(iCost_txt) )
			{
				Print(iPlayer, "^x03Вам нехватает points, чтобы прокачать ^04%s^03. Уровень: ^04%i^03.", g_iItems[iItem], Level+1);
				emit_sound(iPlayer, CHAN_STATIC, error, 1.0, ATTN_NORM, 0, PITCH_NORM);
			}
			//Take Point, Print and give level
			else
			{
				//Take Point
				g_iPoint[iPlayer] -= str_to_num(iCost_txt);
				//Give a level
				g_iItemLevel[iPlayer][iItem] += 1;
				//Print out to the player that he/she bought an item with corresponding level
				Print(iPlayer, "^x03Вы прокачали ^04%s^03. Текущий уровень: ^04%i^03.", g_iItems[iItem], Level+1);
				emit_sound(iPlayer, CHAN_STATIC, item_level_up, 1.0, ATTN_NORM, 0, PITCH_NORM);
			}
		}
		case 2:
		{
			new iItem = g_iChoose[iPlayer], Level = g_iItemLevel[iPlayer][iItem];
			
			if( g_iItemLevel[iPlayer][iItem] <= 0 )
			{
				Print(iPlayer, "^x04%s ^03не прокачен! Вы не можете его продать!", g_iItems[iItem]);
				emit_sound(iPlayer, CHAN_STATIC, error, 1.0, ATTN_NORM, 0, PITCH_NORM);
			}
			else
			{
				new Float:iCost=1.0*g_iFirstCost[iItem] / g_iStepCost[iItem];
				iCost+=szCostTable[g_iItemLevel[iPlayer][iItem]-1]-1;
				iCost*=g_iStepCost[iItem];
				iCost/= 2;
				
				new iCost_txt[16]; format(iCost_txt, charsmax(iCost_txt), "%f", iCost);
			
				//Take Point
				g_iPoint[iPlayer] += str_to_num(iCost_txt);
				//Give a level
				g_iItemLevel[iPlayer][iItem] -= 1;
				//Print out to the player that he/she bought an item with corresponding level
				Print(iPlayer, "^x03Вы продали ^04%s^03. Текущий уровень: ^04%i^03.", g_iItems[iItem], Level-1);
				emit_sound(iPlayer, CHAN_STATIC, item_sell, 1.0, ATTN_NORM, 0, PITCH_NORM);
			}
		}
		case 3:
		{
			show_motd(iPlayer,"mode/upgrades.txt","Upgrades information");
		}
		case 4:
		{
			if(g_iChoose[iPlayer] < g_iItemCount-1)
			{
				g_iChoose[iPlayer]++;
			}
		}
		case 5:
		{
			if(g_iChoose[iPlayer] > 0)
			{
				g_iChoose[iPlayer]--;
			}
		}
	}
	
	ShowBuyMenu_U(iPlayer);
	return PLUGIN_HANDLED;
}

public Point_ShopMenu_W(iPlayer)
{
	new title[70]; formatex(title, sizeof(title) - 1, "\r[ScreamPoints] \w- \yWeapons Menu");
	
	new menu = menu_create(title, "ShopMenu_W_Handle");
	
	new iNumber[5], szOption[80], iCost;
	
	for( new iWeap = 0; iWeap < g_iWeapCount; iWeap++ )
	{
		num_to_str(iWeap, iNumber, 4);
		
		if(g_iWeapLevel[iPlayer][iWeap] > 0)
		{
			iCost = (g_iWFirstCost[iWeap] / g_iWStepCost[iWeap] + szCostTable[g_iWeapLevel[iPlayer][iWeap]]-1) * g_iWStepCost[iWeap];
		}
		else
		{
			iCost = g_iWFirstCost[iWeap];
		}
		
		new g_iNeedLvl = 0;
	
		if(g_iWeapLevel[iPlayer][iWeap] > 0)
		{
			if(g_iWFirstCost[iWeap] == 1)
			{
				g_iNeedLvl = g_iWStepLevel[iWeap] * g_iWeapLevel[iPlayer][iWeap];
			}
			else
			{
				g_iNeedLvl = g_iWFirstLevel[iWeap] + g_iWStepLevel[iWeap] * g_iWeapLevel[iPlayer][iWeap];
			}
		}
		else
		{
			g_iNeedLvl = g_iWFirstLevel[iWeap];
		}
		
		//If the player already have maxlevel
		if( g_iWeapLevel[iPlayer][iWeap] >= g_iWeapMaxLevel[iWeap] )
		{
			formatex(szOption, charsmax(szOption), "\y%s", g_iWeapons[iWeap]);
		}
		else if( g_iPoint[iPlayer] < iCost || g_iLevel[iPlayer] < g_iNeedLvl)
		{
			formatex(szOption, charsmax(szOption), "\d%s", g_iWeapons[iWeap]);
		}
		else
		{
			formatex(szOption, charsmax(szOption), "\w%s", g_iWeapons[iWeap]);
		}
		
		//Add all the menu items
		menu_additem(menu, szOption, iNumber);
	}
	
	//Display the menu
	menu_display(iPlayer, menu, 0);
	
	return PLUGIN_HANDLED;
}

public ShopMenu_W_Handle(iPlayer, menu, item)
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
	
	new key = str_to_num(data);
	g_iChoose[iPlayer] = key;
	ShowBuyMenu_W(iPlayer);
	
	return PLUGIN_HANDLED;
}

public ShowBuyMenu_W(iPlayer)
{	
	new iWeap = g_iChoose[iPlayer];
	new Amount = g_iWeapMaxVal[iWeap] / g_iWeapMaxLevel[iWeap];
	
	new g_iPrefix[32]; 
	
	formatex(g_iPrefix, charsmax(g_iPrefix), "[%d%s]", Amount*g_iWeapLevel[iPlayer][iWeap], g_iWeapShort[iWeap]);
	
	new g_iNeedLvl = 0;
	
	if(g_iWeapLevel[iPlayer][iWeap] > 0)
	{
		if(g_iWFirstLevel[iWeap] == 1)
		{
			g_iNeedLvl = g_iWStepLevel[iWeap] * g_iWeapLevel[iPlayer][iWeap];
		}
		else
		{
			g_iNeedLvl = g_iWFirstLevel[iWeap] + g_iWStepLevel[iWeap] * g_iWeapLevel[iPlayer][iWeap];
		}
	}
	else
	{
		g_iNeedLvl = g_iWFirstLevel[iWeap];
	}
	
	new title[192]; formatex(title, sizeof(title) - 1, "\r[ScreamPoints] \w- \yBuy Weapons Menu: \r%d\y/\r%d^n^n[%s] %s^n^n\yYour lvl: \r%i\y/\r%i^n\yItem`s lvl: \r%i\y/\r%i^n\yYour Points: \r%i", g_iChoose[iPlayer]+1, g_iWeapCount, g_iWeapons[iWeap], g_iPrefix, g_iLevel[iPlayer], g_iNeedLvl, g_iWeapLevel[iPlayer][iWeap], g_iWeapMaxLevel[iWeap], g_iPoint[iPlayer]);
	
	new Float:iCost, szOption[64];
	
	iCost=1.0*g_iWFirstCost[iWeap] / g_iWStepCost[iWeap];
	iCost+=szCostTable[g_iWeapLevel[iPlayer][iWeap]]-1;
	iCost*=g_iWStepCost[iWeap];
	
	new menu = menu_create(title, "BuyMenu_Handle_W");
	
	formatex(g_iPrefix, charsmax(g_iPrefix), "%d%s", Amount, g_iWeapShort[iWeap]);
	
	if(g_iWeapLevel[iPlayer][iWeap] != g_iWeapMaxLevel[iWeap])
	{
		new iCost_txt[16]; format(iCost_txt, charsmax(iCost_txt), "%f", iCost);
		
		if(g_iPoint[iPlayer] < str_to_num(iCost_txt) || g_iLevel[iPlayer] < g_iNeedLvl)
		{
			formatex(szOption, charsmax(szOption), "\dBuy %s (Cost: %d)", g_iPrefix, str_to_num(iCost_txt));
		}
		else
		{
			formatex(szOption, charsmax(szOption), "\yBuy %s (Cost: %d)", g_iPrefix, str_to_num(iCost_txt));
		}
	}
	else
	{
		formatex(szOption, charsmax(szOption), "\dYou can`t buy.");
	}
	menu_additem(menu, szOption, "1");
	
	if(g_iWeapLevel[iPlayer][iWeap] > 0)
	{
		iCost=1.0*g_iWFirstCost[iWeap] / g_iWStepCost[iWeap];
		iCost+=szCostTable[g_iWeapLevel[iPlayer][iWeap]-1]-1;
		iCost*=g_iWStepCost[iWeap];
		iCost/= 2;
		
		new iCost_txt[16]; format(iCost_txt, charsmax(iCost_txt), "%f", iCost);
		formatex(szOption, charsmax(szOption), "\ySell %s (Cost: %d)", g_iPrefix, str_to_num(iCost_txt));
	}
	else
	{
		formatex(szOption, charsmax(szOption), "\dYou can`t sell.");
	}
	
	menu_additem(menu, szOption, "2");
	menu_additem(menu, "Read Information", "3");
	
	if(g_iChoose[iPlayer] >= g_iWeapCount-1)
	{
		menu_additem(menu, "\dNext", "4");
	}
	else
	{
		menu_additem(menu, "Next", "4");
	}
	
	if(g_iChoose[iPlayer] <= 0)
	{
		menu_additem(menu, "\dBack", "5");
	}
	else
	{
		menu_additem(menu, "Back", "5");
	}
	
	menu_display(iPlayer, menu, 0);
	
	return PLUGIN_HANDLED;
}

public BuyMenu_Handle_W(iPlayer, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		Point_ShopMenu_W(iPlayer);
		return PLUGIN_HANDLED;
	}
	
	new data[6], iName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	
	new key = str_to_num(data);
	
	switch(key)
	{
		case 1:
		{
			new iWeap = g_iChoose[iPlayer], Level = g_iWeapLevel[iPlayer][iWeap];
			
			new g_iNeedLvl = 0;
	
			if(g_iWeapLevel[iPlayer][iWeap] > 0)
			{
				if(g_iWFirstLevel[iWeap] == 1)
				{
					g_iNeedLvl = g_iWStepLevel[iWeap] * g_iWeapLevel[iPlayer][iWeap];
				}
				else
				{
					g_iNeedLvl = g_iWFirstLevel[iWeap] + g_iWStepLevel[iWeap] * g_iWeapLevel[iPlayer][iWeap];
				}
			}
			else
			{
				g_iNeedLvl = g_iWFirstLevel[iWeap];
			}
			
			new Float:iCost;
			
			iCost=1.0*g_iWFirstCost[iWeap] / g_iWStepCost[iWeap];
			iCost+=szCostTable[g_iWeapLevel[iPlayer][iWeap]]-1;
			iCost*=g_iWStepCost[iWeap];
			
			new iCost_txt[16]; format(iCost_txt, charsmax(iCost_txt), "%f", iCost);
			
			if( g_iWeapLevel[iPlayer][iWeap] == g_iWeapMaxLevel[iWeap] )
			{
				Print(iPlayer, "^x04%s ^03максимального уровня!", g_iWeapons[iWeap]);
				emit_sound(iPlayer, CHAN_STATIC, error, 1.0, ATTN_NORM, 0, PITCH_NORM);
			}
			else if(g_iLevel[iPlayer] < g_iNeedLvl)
			{
				Print(iPlayer, "^x03Вы должны быть более высокого уровня, чтобы прокачать ^04%s^03. Уровень: ^04%i^03.", g_iWeapons[iWeap], Level+1);
				emit_sound(iPlayer, CHAN_STATIC, error, 1.0, ATTN_NORM, 0, PITCH_NORM);
			}
			//If the player cant afford the item
			else if( g_iPoint[iPlayer] < str_to_num(iCost_txt) )
			{
				Print(iPlayer, "^x03Вам нехватает points, чтобы прокачать ^04%s^03. Уровень: ^04%i^03.", g_iWeapons[iWeap], Level+1);
				emit_sound(iPlayer, CHAN_STATIC, error, 1.0, ATTN_NORM, 0, PITCH_NORM);
			}
			//Take Point, Print and give level
			else
			{
				//Take Point
				g_iPoint[iPlayer] -= str_to_num(iCost_txt);
				//Give a level
				g_iWeapLevel[iPlayer][iWeap] += 1;
				//Print out to the player that he/she bought an item with corresponding level
				Print(iPlayer, "^x03Вы прокачали ^04%s^03. Текущий уровень: ^04%i^03.", g_iWeapons[iWeap], Level+1);
				emit_sound(iPlayer, CHAN_STATIC, item_level_up, 1.0, ATTN_NORM, 0, PITCH_NORM);
			}
		}
		case 2:
		{
			new iWeap = g_iChoose[iPlayer], Level = g_iWeapLevel[iPlayer][iWeap];
			
			if( g_iWeapLevel[iPlayer][iWeap] <= 0 )
			{
				Print(iPlayer, "^x04%s ^03не прокачен! Вы не можете его продать!", g_iWeapons[iWeap]);
				emit_sound(iPlayer, CHAN_STATIC, error, 1.0, ATTN_NORM, 0, PITCH_NORM);
			}
			else
			{
				new Float:iCost=1.0*g_iWFirstCost[iWeap] / g_iWStepCost[iWeap];
				iCost+=szCostTable[g_iWeapLevel[iPlayer][iWeap]-1]-1;
				iCost*=g_iWStepCost[iWeap];
				iCost/= 2;
				
				new iCost_txt[16]; format(iCost_txt, charsmax(iCost_txt), "%f", iCost);
			
				//Take Point
				g_iPoint[iPlayer] += str_to_num(iCost_txt);
				//Give a level
				g_iWeapLevel[iPlayer][iWeap] -= 1;
				//Print out to the player that he/she bought an item with corresponding level
				Print(iPlayer, "^x03Вы продали ^04%s^03. Текущий уровень: ^04%i^03.", g_iWeapons[iWeap], Level-1);
				emit_sound(iPlayer, CHAN_STATIC, item_sell, 1.0, ATTN_NORM, 0, PITCH_NORM);
			}
		}
		case 3:
		{
			show_motd(iPlayer,"mode/weapons.txt","Weapons information");
		}
		case 4:
		{
			if(g_iChoose[iPlayer] < g_iWeapCount-1)
			{
				g_iChoose[iPlayer]++;
			}
		}
		case 5:
		{
			if(g_iChoose[iPlayer] > 0)
			{
				g_iChoose[iPlayer]--;
			}
		}
	}
	
	ShowBuyMenu_W(iPlayer);
	return PLUGIN_HANDLED;
}

public Point_ShopMenu_K(iPlayer)
{
	new title[70]; formatex(title, sizeof(title) - 1, "\r[ScreamPoints] \w- \yKnives Menu");
	
	new menu = menu_create(title, "ShopMenu_K_Handle");
	
	new iNumber[5], szOption[80], iCost;
	
	for( new iKnife = 0; iKnife < g_iKnivesCount-1; iKnife++ )
	{
		num_to_str(iKnife, iNumber, 4);
		
		if(g_iKnifeLevel[iPlayer][iKnife] > 0)
		{
			iCost = (g_iKnifeFirstCost[iKnife] / g_iKnifeStepCost[iKnife] + szCostTable[g_iKnifeLevel[iPlayer][iKnife]]-1) * g_iKnifeStepCost[iKnife];
		}
		else
		{
			iCost = g_iKnifeFirstCost[iKnife];
		}
		
		new g_iNeedLvl = 0;
	
		if(g_iKnifeLevel[iPlayer][iKnife] > 0)
		{
			if(g_iKnifeFirstCost[iKnife] == 1)
			{
				g_iNeedLvl = g_iKnifeStepLevel[iKnife] * g_iKnifeLevel[iPlayer][iKnife];
			}
			else
			{
				g_iNeedLvl = g_iKnifeFirstLevel[iKnife] + g_iKnifeStepLevel[iKnife] * g_iKnifeLevel[iPlayer][iKnife];
			}
		}
		else
		{
			g_iNeedLvl = g_iKnifeFirstLevel[iKnife];
		}
		
		//If the player already have maxlevel
		if( g_iKnifeLevel[iPlayer][iKnife] >= g_iKnifeMaxLevel[iKnife] )
		{
			formatex(szOption, charsmax(szOption), "\y%s", g_iKnives[iKnife]);
		}
		else if( g_iPoint[iPlayer] < iCost || g_iLevel[iPlayer] < g_iNeedLvl)
		{
			formatex(szOption, charsmax(szOption), "\d%s", g_iKnives[iKnife]);
		}
		else
		{
			formatex(szOption, charsmax(szOption), "\w%s", g_iKnives[iKnife]);
		}
		
		//Add all the menu items
		menu_additem(menu, szOption, iNumber);
	}
	
	//Display the menu
	menu_display(iPlayer, menu, 0);
	
	return PLUGIN_HANDLED;
}

public ShopMenu_K_Handle(iPlayer, menu, item)
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
	
	new key = str_to_num(data);
	g_iChoose[iPlayer] = key;
	ShowBuyMenu_K(iPlayer);
	
	return PLUGIN_HANDLED;
}

public ShowBuyMenu_K(iPlayer)
{	
	new iKnife = g_iChoose[iPlayer];
	
	new g_iNeedLvl = 0;
	
	if(g_iKnifeLevel[iPlayer][iKnife] > 0)
	{
		if(g_iKnifeFirstLevel[iKnife] == 1)
		{
			g_iNeedLvl = g_iKnifeStepLevel[iKnife] * g_iKnifeLevel[iPlayer][iKnife];
		}
		else
		{
			g_iNeedLvl = g_iKnifeFirstLevel[iKnife] + g_iKnifeStepLevel[iKnife] * g_iKnifeLevel[iPlayer][iKnife];
		}
	}
	else
	{
		g_iNeedLvl = g_iKnifeFirstLevel[iKnife];
	}
	
	new title[192]; formatex(title, sizeof(title) - 1, "\r[ScreamPoints] \w- \yBuy Knives Menu: \r%d\y/\r%d^n^n[%s]^n^n\yYour lvl: \r%i\y/\r%i^n\yItem`s lvl: \r%i\y/\r%i^n\yYour Points: \r%i", g_iChoose[iPlayer]+1, g_iKnivesCount-1, g_iKnives[iKnife], g_iLevel[iPlayer], g_iNeedLvl, g_iKnifeLevel[iPlayer][iKnife], g_iKnifeMaxLevel[iKnife], g_iPoint[iPlayer]);
	
	new Float:iCost, szOption[64];
	
	iCost=1.0*g_iKnifeFirstCost[iKnife] / g_iKnifeStepCost[iKnife];
	iCost+=szCostTable[g_iKnifeLevel[iPlayer][iKnife]]-1;
	iCost*=g_iKnifeStepCost[iKnife];
	
	new menu = menu_create(title, "BuyMenu_Handle_K");
	
	if(g_iKnifeLevel[iPlayer][iKnife] != g_iKnifeMaxLevel[iKnife])
	{
		new iCost_txt[16]; format(iCost_txt, charsmax(iCost_txt), "%f", iCost);
		
		if(g_iPoint[iPlayer] < str_to_num(iCost_txt) || g_iLevel[iPlayer] < g_iNeedLvl)
		{
			if(g_iKnifeLevel[iPlayer][iKnife] != 0)
			{
				formatex(szOption, charsmax(szOption), "\dUpdate knife (Cost: %d)", str_to_num(iCost_txt));
			}
			else
			{
				formatex(szOption, charsmax(szOption), "\dBuy knife (Cost: %d)", str_to_num(iCost_txt));
			}
		}
		else
		{
			if(g_iKnifeLevel[iPlayer][iKnife] != 0)
			{
				formatex(szOption, charsmax(szOption), "\yUpdate knife (Cost: %d)", str_to_num(iCost_txt));
			}
			else
			{
				formatex(szOption, charsmax(szOption), "\yBuy knife (Cost: %d)", str_to_num(iCost_txt));
			}
		}
	}
	else
	{
		formatex(szOption, charsmax(szOption), "\dYou can`t buy.");
	}
	menu_additem(menu, szOption, "1");
	
	if(g_iKnifeLevel[iPlayer][iKnife] > 0)
	{
		iCost=1.0*g_iKnifeFirstCost[iKnife] / g_iKnifeStepCost[iKnife];
		iCost+=szCostTable[g_iKnifeLevel[iPlayer][iKnife]-1]-1;
		iCost*=g_iKnifeStepCost[iKnife];
		iCost/= 2;
		
		new iCost_txt[16]; format(iCost_txt, charsmax(iCost_txt), "%f", iCost);
		
		if(g_iKnifeLevel[iPlayer][iKnife] != 1)
		{
			formatex(szOption, charsmax(szOption), "\ySell update (Cost: %d)", str_to_num(iCost_txt));
		}
		else
		{
			formatex(szOption, charsmax(szOption), "\ySell knife (Cost: %d)", str_to_num(iCost_txt));
		}
	}
	else
	{
		formatex(szOption, charsmax(szOption), "\dYou can`t sell.");
	}
	
	menu_additem(menu, szOption, "2");
	menu_additem(menu, "Read Information", "3");
	
	if(g_iChoose[iPlayer] >= g_iKnivesCount-2)
	{
		menu_additem(menu, "\dNext", "4");
	}
	else
	{
		menu_additem(menu, "Next", "4");
	}
	
	if(g_iChoose[iPlayer] <= 0)
	{
		menu_additem(menu, "\dBack", "5");
	}
	else
	{
		menu_additem(menu, "Back", "5");
	}
	
	menu_display(iPlayer, menu, 0);
	
	return PLUGIN_HANDLED;
}

public BuyMenu_Handle_K(iPlayer, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		Point_ShopMenu_K(iPlayer);
		return PLUGIN_HANDLED;
	}
	
	new data[6], iName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	
	new key = str_to_num(data);
	
	switch(key)
	{
		case 1:
		{
			new iKnife = g_iChoose[iPlayer], Level = g_iKnifeLevel[iPlayer][iKnife];
			
			new g_iNeedLvl = 0;
	
			if(g_iKnifeLevel[iPlayer][iKnife] > 0)
			{
				if(g_iKnifeFirstLevel[iKnife] == 1)
				{
					g_iNeedLvl = g_iKnifeStepLevel[iKnife] * g_iKnifeLevel[iPlayer][iKnife];
				}
				else
				{
					g_iNeedLvl = g_iKnifeFirstLevel[iKnife] + g_iKnifeStepLevel[iKnife] * g_iKnifeLevel[iPlayer][iKnife];
				}
			}
			else
			{
				g_iNeedLvl = g_iKnifeFirstLevel[iKnife];
			}
			
			new Float:iCost;
			
			iCost=1.0*g_iKnifeFirstCost[iKnife] / g_iKnifeStepCost[iKnife];
			iCost+=szCostTable[g_iKnifeLevel[iPlayer][iKnife]]-1;
			iCost*=g_iKnifeStepCost[iKnife];
			
			new iCost_txt[16]; format(iCost_txt, charsmax(iCost_txt), "%f", iCost);
			
			if( g_iKnifeLevel[iPlayer][iKnife] == g_iKnifeMaxLevel[iKnife] )
			{
				Print(iPlayer, "^x04%s ^03максимального уровня!", g_iKnives[iKnife]);
				emit_sound(iPlayer, CHAN_STATIC, error, 1.0, ATTN_NORM, 0, PITCH_NORM);
			}
			else if(g_iLevel[iPlayer] < g_iNeedLvl)
			{
				if(g_iKnifeLevel[iPlayer][iKnife] != 0)
				{
					Print(iPlayer, "^x03Вы должны быть более высокого уровня, чтобы прокачать ^04%s^03. Уровень: ^04%i^03.", g_iKnives[iKnife], Level+1);
				}
				else
				{
					Print(iPlayer, "^x03Вы должны быть более высокого уровня, чтобы купить ^04%s^03. Уровень: ^04%i^03.", g_iKnives[iKnife], Level+1);
				}
				
				emit_sound(iPlayer, CHAN_STATIC, error, 1.0, ATTN_NORM, 0, PITCH_NORM);
			}
			//If the player cant afford the item
			else if( g_iPoint[iPlayer] < str_to_num(iCost_txt) )
			{
				if(g_iKnifeLevel[iPlayer][iKnife] != 0)
				{
					Print(iPlayer, "^x03Вам нехватает points, чтобы прокачать ^04%s^03. Уровень: ^04%i^03.", g_iKnives[iKnife], Level+1);
				}
				else
				{
					Print(iPlayer, "^x03Вам нехватает points, чтобы купить ^04%s^03. Уровень: ^04%i^03.", g_iKnives[iKnife], Level+1);
				}
				emit_sound(iPlayer, CHAN_STATIC, error, 1.0, ATTN_NORM, 0, PITCH_NORM);
			}
			//Take Point, Print and give level
			else
			{
				//Take Point
				g_iPoint[iPlayer] -= str_to_num(iCost_txt);
				//Give a level
				g_iKnifeLevel[iPlayer][iKnife] += 1;
				//Print out to the player that he/she bought an item with corresponding level
				if(g_iKnifeLevel[iPlayer][iKnife] != 1)
				{
					Print(iPlayer, "^x03Вы прокачали ^04%s^03. Текущий уровень: ^04%i^03.", g_iKnives[iKnife], Level+1);
				}
				else
				{
					Print(iPlayer, "^x03Вы приобрели ^04%s^03. Текущий уровень: ^04%i^03.", g_iKnives[iKnife], Level+1);
				}
				if(iKnife == FAST){	sgcm_reset_maxspeed(iPlayer); }
				emit_sound(iPlayer, CHAN_STATIC, item_level_up, 1.0, ATTN_NORM, 0, PITCH_NORM);
			}
		}
		case 2:
		{
			new iKnife = g_iChoose[iPlayer], Level = g_iKnifeLevel[iPlayer][iKnife];
			
			if( g_iKnifeLevel[iPlayer][iKnife] <= 0 )
			{
				Print(iPlayer, "У вас отсутствует ^x04%s^3! Вы не можете его продать!", g_iKnives[iKnife]);
				emit_sound(iPlayer, CHAN_STATIC, error, 1.0, ATTN_NORM, 0, PITCH_NORM);
			}
			else
			{
				new Float:iCost=1.0*g_iKnifeFirstCost[iKnife] / g_iKnifeStepCost[iKnife];
				iCost+=szCostTable[g_iKnifeLevel[iPlayer][iKnife]-1]-1;
				iCost*=g_iKnifeStepCost[iKnife];
				iCost/= 2;
				
				new iCost_txt[16]; format(iCost_txt, charsmax(iCost_txt), "%f", iCost);
			
				//Take Point
				g_iPoint[iPlayer] += str_to_num(iCost_txt);
				//Give a level
				g_iKnifeLevel[iPlayer][iKnife] -= 1;
				//Print out to the player that he/she bought an item with corresponding level
				if(!(g_iKnifeLevel[iPlayer][iKnife] != 0))
				{
					Print(iPlayer, "^x03Вы только что продали ^04%s^03.", g_iKnives[iKnife]);
					g_iPreNextRoundKnife[iPlayer] = STANDART;
				}
				else
				{
					Print(iPlayer, "^x03Вы продали улучшение ^04%s^03. Текущий уровень: ^04%i^03.", g_iKnives[iKnife], Level-1);
				}
				
				emit_sound(iPlayer, CHAN_STATIC, item_sell, 1.0, ATTN_NORM, 0, PITCH_NORM);
			}
		}
		case 3:
		{
			show_motd(iPlayer,"mode/knives.txt","Knives information");
		}
		case 4:
		{
			if(g_iChoose[iPlayer] < g_iKnivesCount-2)
			{
				g_iChoose[iPlayer]++;
			}
		}
		case 5:
		{
			if(g_iChoose[iPlayer] > 0)
			{
				g_iChoose[iPlayer]--;
			}
		}
	}
	
	ShowBuyMenu_K(iPlayer);
	return PLUGIN_HANDLED;
}

public Point_SelectKnifeMenu(id)
{
	new title[128]; formatex(title, charsmax(title), "\r[ScreamPoints]\w - \ySelect Knife Menu^n^n\wCurrent: \y%s\w   	", g_iKnives[g_iNextRoundKnife[id]]);
	new menu = menu_create(title, "Handle_SKM");
	new menu_key[8];
	
	for( new iKnife = 0; iKnife < g_iKnivesCount; iKnife++ )
	{
		if(g_iKnifeLevel[id][iKnife] != 0)
			formatex(title, 127, "\w%s \y[\r%i\y/\r%i\y]", g_iKnives[iKnife], g_iKnifeLevel[id][iKnife], g_iKnifeMaxLevel[iKnife]);
		else
			formatex(title, 127, "\d%s [%i/%i]", g_iKnives[iKnife], g_iKnifeLevel[id][iKnife], g_iKnifeMaxLevel[iKnife]);
		
		formatex(menu_key, 7, "%i", iKnife);
		menu_additem(menu, title, menu_key);
	}
	
	//menu_setprop(menu, MPROP_PERPAGE, 0);
	menu_display(id, menu, 0);
	
	return PLUGIN_HANDLED;
}

public Handle_SKM(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		Point_StartMenu(id);
		return PLUGIN_HANDLED;
	}
	
	new data[6], iName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	
	new key = str_to_num(data);
	
	if(g_iKnifeLevel[id][key] != 0)
	{
		Print(id, "^4Успешно! ^3На следующем раунде вы будете с ^4%s^3!", g_iKnives[key]);
		g_iPreNextRoundKnife[id] = key;
	}
	else
	{
		Print(id, "^3Вы не приобрели ^4%s^3!", g_iKnives[key]);
		Point_SelectKnifeMenu(id);
	}
	
	return PLUGIN_HANDLED;
}

/*******************************************************************************************/

public FwdPlayerSpawn(iPlayer)
{
	if(get_pcvar_num(agm_status) == 0)
	{
		return PLUGIN_HANDLED;
	}
	
	if(get_pcvar_num(agm_status) <= 4 && get_pcvar_num(agm_status) >= 3)
	{
		remove_task(iPlayer);
		set_task(10.0, "Set_Weapons", iPlayer);
		return PLUGIN_HANDLED;
	}
	
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
	if(get_pcvar_num(agm_status) == 0)
		return PLUGIN_HANDLED;
	
	if(get_pcvar_num(agm_status) > 2)
	{
		Set_WeaponsClassic(iPlayer);
		return PLUGIN_HANDLED;
	}
	
	//Browse through all menu items
	new iNumber[5], bool: GiveWeapon;
	for( new iWeap = 0; iWeap < g_iWeapCount; iWeap++ )
	{
		//Bunch of variables
		num_to_str(iWeap, iNumber, 4);
		{
			static percent;
			percent = calc_value(g_iWeapLevel[iPlayer][iWeap], g_iWeapMaxLevel[iWeap], g_iWeapMaxVal[iWeap]);
			
			//new Chance = g_iWeapLevel[iPlayer][iWeap] * g_iWeapMaxVal[iWeap];
			//new randonnumb = random_num(1, 100);
			
			if(is_user_connected(iPlayer) && (cs_get_user_team(iPlayer) == CS_TEAM_T || cs_get_user_team(iPlayer) == CS_TEAM_CT))
			{
				if( percent > 0 && (percent == 100 || random_num(1, 100) <= percent ) )
				{
					if( iWeap == AWP && !user_has_weapon(iPlayer, g_iWeapClass[AWP]) && !GiveWeapon)
					{	
						give_item(iPlayer, g_iWeapName[AWP]);
						cs_set_weapon_ammo(find_ent_by_owner(-1, g_iWeapName[AWP], iPlayer), 1);
						Print(iPlayer, "^x03Вы получили Awp ^x04[%i%% шанс].", percent);
						
						GiveWeapon = true;
					}
					if( iWeap == SCOUT && !user_has_weapon(iPlayer, g_iWeapClass[SCOUT]) && !GiveWeapon)
					{	
						give_item(iPlayer, g_iWeapName[SCOUT]);
						cs_set_weapon_ammo(find_ent_by_owner(-1, g_iWeapName[SCOUT], iPlayer), 1);
						Print(iPlayer, "^x03Вы получили Scout ^x04[%i%% шанс].", percent);
						
						GiveWeapon = true;
					}
					if( iWeap == DEAGLE && !user_has_weapon(iPlayer, g_iWeapClass[DEAGLE]) && !GiveWeapon)
					{	
						give_item(iPlayer, g_iWeapName[DEAGLE]);
						cs_set_weapon_ammo(find_ent_by_owner(-1, g_iWeapName[DEAGLE], iPlayer), 1);
						Print(iPlayer, "^x03Вы получили Deagle ^x04[%i%% шанс].", percent);
						
						GiveWeapon = true;
					}
					if( iWeap == FIVESEVEN && !user_has_weapon(iPlayer, g_iWeapClass[FIVESEVEN]) && !GiveWeapon)
					{	
						give_item(iPlayer, g_iWeapName[FIVESEVEN]);
						
						if(random_num(1, 100) <= g_iWeapMaxVal[TWO_BULLETS] * g_iWeapLevel[iPlayer][TWO_BULLETS] / g_iWeapMaxLevel[TWO_BULLETS])
						{
							cs_set_weapon_ammo(find_ent_by_owner(-1, g_iWeapName[FIVESEVEN], iPlayer), 2);
							Print(iPlayer, "^x03Вы получили Five-Seven с 2-мя патронами ^x04[%i%% шанс].", percent);
						}
						else
						{
							cs_set_weapon_ammo(find_ent_by_owner(-1, g_iWeapName[FIVESEVEN], iPlayer), 1);
							Print(iPlayer, "^x03Вы получили Five-Seven ^x04[%i%% шанс].", percent);
						}
						
						GiveWeapon = true;
					}
					
					if( iWeap == HE_GRENADE && !user_has_weapon(iPlayer, g_iWeapClass[HE_GRENADE]) )
					{	
						give_item(iPlayer, g_iWeapName[HE_GRENADE]);
						Print(iPlayer, "^x03Вы получили HE grenade ^x04[%i%% шанс].", percent);
					}
					if(cs_get_user_team(iPlayer) == CS_TEAM_CT && iWeap == SMOKE_GRENADE && !user_has_weapon(iPlayer, g_iWeapClass[SMOKE_GRENADE]) )
					{	
						give_item(iPlayer, g_iWeapName[SMOKE_GRENADE]);
						Print(iPlayer, "^x03Вы получили Frost grenade ^x04[%i%% шанс].", percent);
					}
				}
			}
		}
	}
	
	return PLUGIN_HANDLED;
}

public Set_WeaponsClassic(iPlayer)
{
	new what_is_the_mode = 4;
	
	if(get_pcvar_num(agm_status) == 3){
		what_is_the_mode = 3;
	}
	
	new bool: HavePrimary = false;
	new bool: HaveSecondary = false;
	new bullets = random_num(1,2);
	
	if(is_user_connected(iPlayer) && (cs_get_user_team(iPlayer) == CS_TEAM_T || cs_get_user_team(iPlayer) == CS_TEAM_CT))
	{
		if(what_is_the_mode == 3 && cs_get_user_team(iPlayer) == CS_TEAM_CT || what_is_the_mode == 4){
			if(random_num(1, 100) <= 1)
			{
				give_item(iPlayer, g_iWeapName[AWP]);
				cs_set_weapon_ammo(find_ent_by_owner(-1, g_iWeapName[AWP], iPlayer), bullets);
				Print(iPlayer, "^x03Вы получили Awp ^x04[1%% шанс].");
				HavePrimary = true;
			}
			if(random_num(1, 100) <= 2 && !HavePrimary)
			{
				give_item(iPlayer, g_iWeapName[SCOUT]);
				cs_set_weapon_ammo(find_ent_by_owner(-1, g_iWeapName[SCOUT], iPlayer), bullets);
				Print(iPlayer, "^x03Вы получили Scout ^x04[2%% шанс].");
			}
			if(random_num(1, 100) <= 5)
			{
				give_item(iPlayer, g_iWeapName[DEAGLE]);
				cs_set_weapon_ammo(find_ent_by_owner(-1, g_iWeapName[DEAGLE], iPlayer), bullets);
				Print(iPlayer, "^x03Вы получили Deagle ^x04[5%% шанс].");
				HaveSecondary = true;
			}
			if(random_num(1, 100) <= 7 && !HaveSecondary)
			{
				give_item(iPlayer, g_iWeapName[FIVESEVEN]);
				cs_set_weapon_ammo(find_ent_by_owner(-1, g_iWeapName[FIVESEVEN], iPlayer), 2);
				Print(iPlayer, "^x03Вы получили Five-Seven с 2-мя патронами ^x04[7%% шанс].");
			}
		}
		
		if(get_user_flags(iPlayer) & ADMIN_LEVEL_E){
			new percent = 20; if(what_is_the_mode == 3) percent += 15;
				
			if(!user_has_weapon(iPlayer, g_iWeapClass[HE_GRENADE]) && random_num(1, 100) <= percent)
			{	
				give_item(iPlayer, g_iWeapName[HE_GRENADE]);
				Print(iPlayer, "^x03Вы получили HE grenade ^x04[%d%% шанс].", percent);
			}
			
			percent-= 10;
				
			if(!user_has_weapon(iPlayer, g_iWeapClass[SMOKE_GRENADE]) && cs_get_user_team(iPlayer) == CS_TEAM_CT && random_num(1, 100) <= percent)
			{	
				give_item(iPlayer, g_iWeapName[SMOKE_GRENADE]);
				Print(iPlayer, "^x03Вы получили Frostnade ^x04[%d%% шанс].", percent);
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
	
	return PLUGIN_HANDLED;
}

public eventFlash( id ) 
{
	if(get_pcvar_num(agm_status) == 0 || get_pcvar_num(agm_status) <= 4 && get_pcvar_num(agm_status) >= 3)
	{
		return PLUGIN_HANDLED;
	}
	
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

public grenade_throw(id, gid, wid){
	thrown_grenade[id] = gid;
}

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

/////////////// START OF TOP 15 AND RANK SYSTEM AND..... HOOK SAY!!! ///////////////

public CmdSay(id)
{
	if(menutype[id] != 3 && !get_in[id]){
		Print(id, "Вам нельзя писать в чат. Сначала ^4войдите ^3или ^4зарегистрируйтесь^3.");
		return PLUGIN_HANDLED;
	}
	
	if(is_user_hltv(id) || is_user_bot(id))
		return PLUGIN_CONTINUE;

	read_args(s_Msg, 63);
	remove_quotes(s_Msg);
	
	replace_all(s_Msg, 191, "%s", "");
	
	new bool:return_h = true;
	
	if(contain(s_Msg, "/rankstats") != -1 || contain(s_Msg, "/time") != -1 || contain(s_Msg, "/rank") != -1 && contain(s_Msg, "/rankv") == -1)
	{
		new name[36]; strtok(s_Msg, s_Msg, charsmax(s_Msg), name, charsmax(name), ' ');
		new next_id = cmd_target(id, name, CMDTARGET_NO_BOTS);
		
		if(!next_id)
		{
			next_id = id;
		}
		
		if(next_id != id)
		{
			return_h = false;
		}
		
		if(contain(s_Msg, "/rankstats") != -1)
		{
			CmdRankStats(id, next_id);
		}
		else if(contain(s_Msg, "/rank") != -1)
		{
			CmdRank(id, next_id);
		}
		else if(contain(s_Msg, "/time") != -1)
		{
			CmdTime(id, next_id);
		}
	}
	else
		return_h = false;
	
	if(return_h)
	{
		return PLUGIN_HANDLED;
	}
	
	if(s_Msg[0] == '/' || s_Msg[0] == '@' || s_Msg[0] == '!')
		return PLUGIN_CONTINUE;
	
	new StrName[64], Alive[32];
	get_user_name(id, s_Name, 31);
	format(StrName, 63, "%s %s", pm_Name[id], s_Name);
	
	if(is_user_alive(id))
	{
		isAlive = 1;
		format(Alive, 31, "^x01");
	}
	else
	{
		isAlive = 0;
		format(Alive, 31, "^x01*DEAD* ");
	}
	
	static color[10];
	new p_Name[92], p_Message[128];
	
	get_user_team(id, color, 9);
	
	format(p_Name, 91, "%s^x03%s", Alive, StrName);
	format(p_Message, 127, "%s", s_Msg);
	
	format(Message, 221, "%s ^x01: %s", p_Name, p_Message);
	
	//player_id = id;
	
	SendMessageAll(color);

	return PLUGIN_HANDLED;
}

public CmdSayTeam(id)
{
	if(menutype[id] != 3 && !get_in[id]){
		Print(id, "Вам нельзя писать в чат. Сначала ^4войдите ^3или ^4зарегистрируйтесь^3.");
		return PLUGIN_HANDLED;
	}
	
	if(is_user_hltv(id) || is_user_bot(id))
		return PLUGIN_CONTINUE;

	read_args(s_Msg, 63);
	remove_quotes(s_Msg);
	
	replace_all(s_Msg, 191, "%s", "");
	
	new bool: return_h = true;
	
	if(contain(s_Msg, "/rankstats") != -1 || contain(s_Msg, "/time") != -1 || contain(s_Msg, "/rank") != -1 && contain(s_Msg, "/rankv") == -1)
	{
		new name[36]; strtok(s_Msg, s_Msg, charsmax(s_Msg), name, charsmax(name), ' ');
		new next_id = cmd_target(id, name, CMDTARGET_NO_BOTS);
		
		if(!next_id)
		{
			next_id = id;
		}
		
		if(next_id != id)
		{
			return_h = false;
		}
		
		if(contain(s_Msg, "/rankstats") != -1)
		{
			CmdRankStats(id, next_id);
		}
		else if(contain(s_Msg, "/rank") != -1)
		{
			CmdRank(id, next_id);
		}
		else if(contain(s_Msg, "/time") != -1)
		{
			CmdTime(id, next_id);
		}
	}
	else
		return_h = false;
	
	if(return_h)
	{
		return PLUGIN_HANDLED;
	}
	
	if(s_Msg[0] == '/' || s_Msg[0] == '@' || s_Msg[0] == '!')
		return PLUGIN_CONTINUE;
	
	new StrTeam = get_user_team(id); new p_Team[32];
	
	switch(StrTeam)
	{
		case 1:
		{
			format(p_Team, 31, "(Terrorist)");
		}
		case 2:
		{
			format(p_Team, 31, "(Counter-Terrorist)", LANG_PLAYER, "CT_CT");
		}
		case 3:
		{
			format(p_Team, 31, "(Spectator)");
		}
	}
	
	new StrName[64], Alive[32];
	get_user_name(id, s_Name, 31);
	format(StrName, 63, "%s %s", pm_Name[id], s_Name);
	
	if(is_user_alive(id))
	{
		isAlive = 1;
		format(Alive, 31, "^x01");
	}
	else
	{
		isAlive = 0;
		format(Alive, 31, "^x01*DEAD* ");
	}
	
	static color[10];
	new p_Name[128], p_Message[164];
	
	get_user_team(id, color, 9);
	
	format(p_Name, 127, "%s%s ^x03%s", Alive, p_Team, StrName);
	format(p_Message, 163, "%s", s_Msg);
	
	format(Message, 255, "%s ^x01: %s", p_Name, p_Message);
	
	//player_id = id;
	
	SendTeamMessage(color, isAlive, StrTeam);

	return PLUGIN_HANDLED;
}

public SendMessageAll(color[])
{
	new TeamName[10];
	
	for(new player = 0; player < get_maxplayers(); player++)
	{
		if(!is_user_connected(player))// || chat_blocks(player, player_id))
		{
			continue;
		}

		console_print(player, "%s : %s", s_Name, s_Msg);
		get_user_team(player, TeamName, 9);
		ChangeTeamInfo(player, color);
		WriteMessage(player, Message);
		ChangeTeamInfo(player, TeamName);
	}
}

public SendTeamMessage(color[], alive, playerTeam)
{
	new TeamName[10];
	
	for (new player = 0; player < get_maxplayers(); player++)
	{
		if (!is_user_connected(player)) // || chat_blocks(player, player_id))
		{
			continue;
		}
		
		if(get_user_team(player) == playerTeam || g_admin[player])
		{
			if (alive && is_user_alive(player) || g_admin[player])
			{
				console_print(player, "%s : %s", s_Name, s_Msg);
				get_user_team(player, TeamName, 9);
				ChangeTeamInfo(player, color);
				WriteMessage(player, Message);
				ChangeTeamInfo(player, TeamName);
			}
		}
	}
}

public ChangeTeamInfo (player, team[])
{
	message_begin(MSG_ONE, TeamInfo, _, player);
	write_byte(player);
	write_string(team);
	message_end();
}


public WriteMessage (player, message[])
{
	message_begin(MSG_ONE, SayText, _, player);
	write_byte (player);
	write_string (message);
	message_end();
}

public CmdTime(iPlayer, target)
{
	new TotalTimeUser[32];
	new TotalTime = 0;
	
	if(target == iPlayer)
	{
		TotalTime = g_iTime[iPlayer] - g_iTimeOffset[iPlayer] + get_user_time(iPlayer);
		
		TimeToString( TotalTime, TotalTimeUser, charsmax(TotalTimeUser), true );
		Print(iPlayer, "You played on our server ^4%i ^3Rounds. Total Time: %s.", g_iStats[iPlayer][0], TotalTimeUser);
	}
	else
	{
		TotalTime = g_iTime[target] - g_iTimeOffset[target] + get_user_time(target);
		
		TimeToString( TotalTime, TotalTimeUser, charsmax(TotalTimeUser), true );
		new name[36]; get_user_name(target, name, charsmax(name));
		
		Print(iPlayer, "%s played on our server ^4%i ^3Rounds. Total Time: %s.", name, g_iStats[target][0], TotalTimeUser);
	}
}

public CmdRank(iPlayer, target)
{
	new iPlayers[32], iNum;
	get_players(iPlayers,iNum);
		
	for( new i = 0; i < iNum; i++ )
	{
		SaveData(iPlayers[i]);
	}
	
	nvault_close(g_hVault);
	g_hVault = nvault_open("agm_save_top");
		
	new Array:aRankData = ArrayCreate( RankData );

	new hVault = nvault_util_open("agm_save_top");
	new iKeys = nvault_util_count( hVault );
		
	new eRankData[ RankData ];
	
	new iPos, szKey[ 32 ], szData[256], iTimeStamp;
		
	for( new i = 0; i < iKeys; i++ )
	{
		iPos = nvault_util_read( hVault, iPos, szKey, charsmax( szKey ), szData, charsmax( szData ), iTimeStamp );
		
		ReadVaultData( szData, charsmax( szData ), eRankData[Rank_Pass], charsmax(eRankData[Rank_Pass]), eRankData[Rank_Time], eRankData[Rank_Point], eRankData[Rank_Rounds], eRankData[Rank_Kills], eRankData[Rank_Deaths], eRankData[Rank_Suicides], eRankData[Rank_Survives], eRankData[Rank_VIP], eRankData[Rank_Name], charsmax(eRankData[Rank_Name]));
		ArrayPushArray( aRankData, eRankData );
	}
		
	nvault_util_close( hVault );
		
	ArraySort( aRankData, "SortRanks" );
	
	new name[36];
	new bool: another_info = false;
	
	if(target != iPlayer)
	{
		get_user_name(target, name, charsmax(name));
		another_info = true;
	}
	else
	{
		get_user_name(iPlayer, name, charsmax(name));
	}
	
	for( new i = 0; i < iKeys; i++ )
	{
		ArrayGetArray( aRankData, i, eRankData );
		
		replace_all( eRankData[ Rank_Name ], charsmax( eRankData[ Rank_Name ] ), "&", "&amp;" );
		replace_all( eRankData[ Rank_Name ], charsmax( eRankData[ Rank_Name ] ), "<", "&lt;" );
		replace_all( eRankData[ Rank_Name ], charsmax( eRankData[ Rank_Name ] ), ">", "&gt;" );
		
		if(equal(eRankData[Rank_Name], name))
		{
			if(!another_info)
			{
				Print(iPlayer, "Your place ^4%i ^3of ^4%i ^3with ^4%i ^3RankPoints!", (i + 1), iKeys, eRankData[ Rank_Point ]);
			}
			else
			{
				Print(iPlayer, "%s`s place ^4%i ^3of ^4%i ^3with ^4%i ^3RankPoints!", name, (i + 1), iKeys, eRankData[ Rank_Point ]);
			}
			
			break;
		}
	}
		
	ArrayDestroy(aRankData);
}

public CmdRankStats(iPlayer, target)
{	
	new Float:K_D = 0.0;
	
	if(target == iPlayer)
	{
		if(g_iStats[iPlayer][2] + g_iStats[iPlayer][3] > 0)
		{
			K_D = 1.0 * g_iStats[iPlayer][1] / (g_iStats[iPlayer][2] + g_iStats[iPlayer][3]);
		}
		
		Print(iPlayer, "Your kills: ^4%i^3, deaths: ^4%i^3 (suicides: ^4%i^3).", g_iStats[iPlayer][1], g_iStats[iPlayer][2], g_iStats[iPlayer][3]);
		Print(iPlayer, "Your survives: ^4%i^3, K/D - %.2f, total of RankPoints: ^4%i^3.", g_iStats[iPlayer][4], K_D, g_iRankPoint[iPlayer]);
	}
	else
	{
		new name[36]; get_user_name(target, name, charsmax(name));
		
		if(g_iStats[target][2] + g_iStats[target][3] > 0)
		{
			K_D = 1.0 * g_iStats[target][1] / (g_iStats[target][2] + g_iStats[target][3]);
		}
		
		Print(iPlayer, "%s`s kills: ^4%i^3, deaths: ^4%i^3 (suicides: ^4%i^3).", name, g_iStats[target][1], g_iStats[target][2], g_iStats[target][3]);
		Print(iPlayer, "%s`s survives: ^4%i^3, K/D - %.2f, total of RankPoints: ^4%i^3.", name, g_iStats[target][4], K_D, g_iRankPoint[target]);
	}
}

public TopPoint(iPlayer)
{
	if(menutype[iPlayer] != 3 && !get_in[iPlayer]) return PLUGIN_HANDLED;
	
	new iPlayers[ 32 ], iNum;
	get_players( iPlayers, iNum );
		
	for( new i = 0; i < iNum; i++ )
	{
		SaveData( iPlayers[ i ] );
	}
	
	nvault_close(g_hVault);
	g_hVault = nvault_open("agm_save_top");
	
	new Array:aRankData = ArrayCreate( RankData );

	new hVault = nvault_util_open("agm_save_top");
	new iKeys = nvault_util_count( hVault );
		
	new eRankData[ RankData ];
	
	new iPos, szKey[ 32 ], szData[256], iTimeStamp;
		
	for( new i = 0; i < iKeys; i++ )
	{
		iPos = nvault_util_read( hVault, iPos, szKey, charsmax( szKey ), szData, charsmax( szData ), iTimeStamp );
		
		ReadVaultData( szData, charsmax( szData ), eRankData[Rank_Pass], charsmax(eRankData[Rank_Pass]), eRankData[Rank_Time], eRankData[Rank_Point], eRankData[Rank_Rounds], eRankData[Rank_Kills], eRankData[Rank_Deaths], eRankData[Rank_Suicides], eRankData[Rank_Survives], eRankData[Rank_VIP], eRankData[Rank_Name], charsmax(eRankData[Rank_Name]));
		ArrayPushArray( aRankData, eRankData );
	}
		
	nvault_util_close( hVault );
		
	ArraySort( aRankData, "SortRanks" );
		
	new iTotal = ArraySize( aRankData );
		
	if( iTotal > MAX_TOP )
	{
		iTotal = MAX_TOP;
	}
		
	new html_motd [2500], len;
	if( !len )
	{
		len = formatex ( html_motd [ len ], charsmax ( html_motd ) - len, "<html><style type = ^"text/css^">body{background:#000000;font-family:Comic Sans MS;font-weight:bold;}");
		len += formatex ( html_motd [ len ], charsmax ( html_motd ) - len, "h1{color:#00b2ee;font-size:large;}h2{color:#00FF00;font-size:medium;}td{color:#FFFFFF;font-size:small;}");
		len += formatex ( html_motd [ len ], charsmax ( html_motd ) - len, "table{width:100%%;font-size:16px}</style>");
		
		len += formatex ( html_motd [ len ], charsmax ( html_motd ) - len, "<body><div align=^"center^"><h1>Top of RankPoints by slavok1717</h1></div><table cellpadding=2 cellspacing=0 border=0>");
		len += formatex ( html_motd [ len ], charsmax ( html_motd ) - len, "<tr align=^"center^"><td><h2>Rank: </h2></td><td><h2>Names: </h2></td><td><h2>Kills: </h2></td><td><h2>Deaths: </h2></td><td><h2>Suicides: </h2></td><td><h2>Survives: </h2></td><td><h2>RankPoints: </h2></td>");
	}
		
	for( new i = 0; i < iTotal; i++ )
	{
		ArrayGetArray( aRankData, i, eRankData );
			
		copy( szData, charsmax( szData ), eRankData[ Rank_Name ] );
		replace_all( szData, charsmax( szData ), "&", "&amp;" );
		replace_all( szData, charsmax( szData ), "<", "&lt;" );
		replace_all( szData, charsmax( szData ), ">", "&gt;" );
			
		LimitMOTDString( szData, 32 );
			
		TimeToString( eRankData[ Rank_Time ], szKey, charsmax( szKey ), true );
		
		len += formatex(html_motd [ len ], charsmax(html_motd)-len, "<tr align=^"center^"><td>%i.</td><td>%s</td><td>%i</td><td>%i</td><td>%i</td><td>%i</td><<td>%i</td></tr>", (i + 1), szData, eRankData[Rank_Kills], eRankData[Rank_Deaths], eRankData[Rank_Suicides], eRankData[Rank_Survives], eRankData[Rank_Point]);
	}
	
	len += formatex ( html_motd [ len ], charsmax ( html_motd ) - len, "</table></body></html>");
	
	ArrayDestroy(aRankData);
	show_motd( iPlayer, html_motd, "Top15 of RankPoints" );
	return PLUGIN_HANDLED;
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
		iLen += bAbbrev ? formatex( szString, iMaxLen, "^04%d^03%c", iDays, 'd' ) : formatex( szString, iMaxLen, "^04%d^03 day%s", iDays, ( iDays == 1 ) ? "" : "s" );
	}
	if( iHours )
	{
		iLen += bAbbrev ? formatex( szString[ iLen ], iMaxLen - iLen, "%s^04%d^03%c", iLen ? " " : "", iHours, 'h' ) : formatex( szString[ iLen ], iMaxLen - iLen, "%s^04%d^03 hour%s", iLen ? ", " : "", iHours, ( iHours == 1 ) ? "" : "s" );
	}
	if( iMinutes )
	{
		iLen += bAbbrev ? formatex( szString[ iLen ], iMaxLen - iLen, "%s^04%d^03%c", iLen ? " " : "", iMinutes, 'm' ) : formatex( szString[ iLen ], iMaxLen - iLen, "%s^04%d^03 minute%s", iLen ? ", " : "", iMinutes, ( iMinutes == 1 ) ? "" : "s" );
	}
	if( iSeconds )
	{
		iLen += bAbbrev ? formatex( szString[ iLen ], iMaxLen - iLen, "%s^04%d^03%c", iLen ? " " : "", iSeconds, 's' ) : formatex( szString[ iLen ], iMaxLen - iLen, "%s^04%d^03 second%s", iLen ? ", " : "", iSeconds, ( iSeconds == 1 ) ? "" : "s" );
	}
	
	if( !iLen )
	{
		iLen = copy( szString, iMaxLen, "^4неизвестно");
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


//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------


/*new params; new Float:f_params;
	new Float: v_params[3]; new string_info[200];
	
	entity_get_string(gid, EV_SZ_classname, string_info, charsmax(string_info));
	new ent = create_entity(string_info);
	
	for(new i = EV_SZ_globalname; i <= EV_SZ_weaponmodel; i++)
	{
		entity_get_string(gid, i, string_info, charsmax(string_info));
		entity_set_string(ent, i, string_info);
	}
	
	for(new i = EV_INT_gamestate; i <= EV_INT_deadflag; i++)
	{
		if(i == EV_INT_solid)
			entity_set_int(ent, EV_INT_solid, SOLID_NOT);
		
		params = entity_get_int(gid, i);
		entity_set_int(ent, i, params);
	}
	
	for(new i = EV_FL_impacttime ; i <= EV_FL_fuser4; i++)
	{
		f_params = entity_get_float(gid, i);
		entity_set_float(ent, i, f_params);
	}
	
	for(new i = EV_VEC_origin ; i <= EV_VEC_vuser4; i++)
	{
		entity_get_vector(gid, i, v_params);
		entity_set_vector(ent, i, v_params);
	}
	
	for(new i = EV_ENT_chain; i <= EV_ENT_euser4; i++)
	{
		if(i == EV_ENT_pContainingEntity)
			continue;

		params = entity_get_edict(gid, i);
		entity_set_edict(ent, i, params);
		
		if(i == EV_ENT_enemy)
			client_print(0, print_chat, "enemy = %d", params);
		
		if(i == EV_ENT_owner)
		{
			entity_set_edict(ent, i, 0);
			params = entity_get_edict(ent, i);
			client_print(0, print_chat, "owner = %d", params);
		}
	}
	
	for(new i = EV_BYTE_controller1; i <= EV_BYTE_blending2; i++)
	{
		params = entity_get_byte(gid, i);
		entity_set_byte(ent, i, params);
	}
	
	new pd;
	pd=get_pdata_int(gid,4,0);
	set_pdata_int(ent,4,pd,0);
	pd=get_pdata_int(gid,5,1);
	set_pdata_int(ent,5,pd,1);
		
	if(is_linux_server())
	{
		pd=get_pdata_int(gid,5,0);
		set_pdata_int(ent,5,pd,0);
		pd=get_pdata_int(gid,7,0);
		set_pdata_int(ent,7,pd,0);
	}
	
	entity_set_int(gid, EV_INT_flags, FL_KILLME);
	set_task(0.2, "grenadeSolid", ent, _, _, "a", 1);
	
	return PLUGIN_HANDLED;
}*/

public pre_create_blast(params[], taskid){
	new rgb[3]; rgb[0] = params[0];
	rgb[1] = params[1]; rgb[2] = params[2];
	create_blast(taskid-4968753, rgb, params[3], params[4]);
}

public create_blast(index, rgb[3], wave_life, light_radius)
{
	new origin[3];
	get_user_origin(index, origin);
	
	// smallest ring
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(TE_BEAMCYLINDER);
	write_coord(origin[0]); // x
	write_coord(origin[1]); // y
	write_coord(origin[2]-5); // z
	write_coord(origin[0]); // x axis
	write_coord(origin[1]); // y axis
	write_coord(origin[2] + 385); // z axis
	write_short(spr_blast); // sprite
	write_byte(0); // start frame
	write_byte(0); // framerate
	write_byte(wave_life*2+4); // life
	write_byte(35); // width
	write_byte(0); // noise
	write_byte(rgb[0]); // red
	write_byte(rgb[1]); // green
	write_byte(rgb[2]); // blue
	write_byte(100); // brightness
	write_byte(0); // speed
	message_end();

	// medium ring
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(TE_BEAMCYLINDER);
	write_coord(origin[0]); // x
	write_coord(origin[1]); // y
	write_coord(origin[2]-5); // z
	write_coord(origin[0]); // x axis
	write_coord(origin[1]); // y axis
	write_coord(origin[2] + 470); // z axis
	write_short(spr_blast); // sprite
	write_byte(0); // start frame
	write_byte(0); // framerate
	write_byte(wave_life*2+4); // life
	write_byte(35); // width
	write_byte(0); // noise
	write_byte(rgb[0]); // red
	write_byte(rgb[1]); // green
	write_byte(rgb[2]); // blue
	write_byte(100); // brightness
	write_byte(0); // speed
	message_end();

	// largest ring
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(TE_BEAMCYLINDER);
	write_coord(origin[0]); // x
	write_coord(origin[1]); // y
	write_coord(origin[2]-5); // z
	write_coord(origin[0]); // x axis
	write_coord(origin[1]); // y axis
	write_coord(origin[2] + 555); // z axis
	write_short(spr_blast); // sprite
	write_byte(0); // start frame
	write_byte(0); // framerate
	write_byte(wave_life*2+4); // life
	write_byte(35); // width
	write_byte(0); // noise
	write_byte(rgb[0]); // red
	write_byte(rgb[1]); // green
	write_byte(rgb[2]); // blue
	write_byte(100); // brightness
	write_byte(0); // speed
	message_end();

	// light effect
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(TE_DLIGHT);
	write_coord(origin[0]); // x
	write_coord(origin[1]); // y
	write_coord(origin[2]-5); // z
	write_byte(light_radius/5); // radius
	write_byte(rgb[0]); // r
	write_byte(rgb[1]); // g
	write_byte(rgb[2]); // b
	write_byte(wave_life*2+2); // life
	write_byte(60); // decay rate
	message_end();
	
	if(wave_life > 0){
		wave_life--;
		new params[5];
		params[0] = rgb[0];
		params[1] = rgb[1];
		params[2] = rgb[2];
		params[3] = wave_life;
		params[4] = light_radius;
		set_task(0.2, "pre_create_blast", 4968753+index, params, 5, "a", 1);
	}
}

stock bool:symbols_correct(id){
	for(new i = 0; i < 48; i++){
		if(equal(user_password[id][i], "@") || equal(user_password[id][i], "^^") || equal(user_password[id][i], "~") || 
		equal(user_password[id][i], "`") || equal(user_password[id][i], "!") || equal(user_password[id][i], "$") || 
		equal(user_password[id][i], "%") || equal(user_password[id][i], ";") || equal(user_password[id][i], " ") || 
		equal(user_password[id][i], ":") || equal(user_password[id][i], "&") || equal(user_password[id][i], "|") || 
		equal(user_password[id][i], "?") || equal(user_password[id][i], "'")) return false;
	}
	
	return true;
}