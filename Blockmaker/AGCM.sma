native pm_add_user_point_new(id, xvar);
native pm_level_weapon_chance(id);
native pm_level_extra_time(id);
native Float:sgpm_fast_knife_speed(id);
native sgpm_boots_is_activated(id);
native sgpm_stop_poison_dmg(id);

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <fun>
#include <sockets>
#include <sqlite>

#pragma semicolon 1

#define PLUGIN_NAME				"ScreamGaming [CM]"
#define PLUGIN_VERSION				"4.7"
#define PLUGIN_AUTHOR				"-"
#define PLUGIN_PREFIX				"AG"
#define MAX_ENT 					960

#define max_portal_entities	100
#define maxframe_entrance 	89

new const g_sprite_teleport_start[] =		"sprites/ArtGames/v2/tp_go.spr";
new const g_sprite_teleport_destination[] =	"sprites/ArtGames/v2/tp_bb.spr";

new const g_sound_teleport[]	= "ArtGames/v2/effect/teleport.wav";

new const g_blank[] =				"";
new const g_a[] =				"a";
new const g_b[] =				"b";

new const g_block_classname[] =			"CM_Block";
new const g_start_classname[] =			"CM_TeleportStart";
new const g_destination_classname[] =		"CM_TeleportDestination";
new const g_light_classname[] =			"CM_Light";

new const g_model_platform[] =			"models/ArtGames/v2/Normal/platform.mdl";
new const g_model_bunnyhop[] =			"models/ArtGames/v2/Normal/bunnyhop.mdl";
new const g_model_bunnyhop_damage[] =		"models/ArtGames/v2/Normal/bunnyhop_damage.mdl";
new const g_model_damage[] =			"models/ArtGames/v2/Normal/damage.mdl";
new const g_model_healer[] =			"models/ArtGames/v2/Normal/health.mdl";
new const g_model_no_fall_damage[] =		"models/ArtGames/v2/Normal/nofalldamage.mdl";
new const g_model_ice[] =			"models/ArtGames/v2/Normal/ice.mdl";
new const g_model_trampoline[] =			"models/ArtGames/v2/Normal/trampoline.mdl";
new const g_model_speed_boost[] =		"models/ArtGames/v2/Normal/speedboost.mdl";
new const g_model_death[] =			"models/ArtGames/v2/Normal/death.mdl";
new const g_model_low_gravity[] =		"models/ArtGames/v2/Normal/lowgravity.mdl";
new const g_model_slap[] =			"models/ArtGames/v2/Normal/slap.mdl";
new const g_model_honey[] =			"models/ArtGames/v2/Normal/honey.mdl";
new const g_model_ct_barrier[] =			"models/ArtGames/v2/Normal/ct_barrier.mdl";
new const g_model_t_barrier[] =			"models/ArtGames/v2/Normal/t_barrier.mdl";
new const g_model_admin_barrier[] =		"models/ArtGames/v2/Normal/vip_barrier.mdl";
new const g_model_no_slow_down_bunnyhop[] =	"models/ArtGames/v2/Normal/no_slow_down_bunnyhop.mdl";
new const g_model_delayed_bunnyhop[] =		"models/ArtGames/v2/Normal/delay_bunnyhop.mdl";
new const g_model_invincibility[] =		"models/ArtGames/v2/Normal/invincibility.mdl";
new const g_model_stealth[] =			"models/ArtGames/v2/Normal/stealth.mdl";
new const g_model_boots_of_speed[] =		"models/ArtGames/v2/Normal/bootsofspeed.mdl";
new const g_model_camouflage[] =			"models/ArtGames/v2/Normal/comuflage.mdl";
new const g_model_granata[] =			"models/ArtGames/v2/Normal/nades.mdl";
new const g_model_weapon[] =			"models/ArtGames/v2/Normal/weapon.mdl";
new const g_model_music[] =			"models/ArtGames/v2/Normal/music.mdl";
new const g_model_double_duck[] =		"models/ArtGames/v2/Normal/double_duck.mdl";
new const g_model_blind_trap[] =			"models/ArtGames/v2/Normal/blind_trap.mdl";
new const g_model_earthquake[] =			"models/ArtGames/v2/Normal/earthquake.mdl";
new const g_model_magic_carpet[] =		"models/ArtGames/v2/Normal/magic_carpet.mdl";
new const g_model_point_block_O_O[] =		"models/ArtGames/v2/Normal/points.mdl";
new const g_model_weapon_chance[] =		"models/ArtGames/v2/Normal/weapon_shanse.mdl";
new const g_model_random_block[] =		"models/ArtGames/v2/Normal/random.mdl";

new const g_sprite_light[] =			"sprites/ArtGames/v2/light.spr";

new const gszStealthSound[] = 			"ScreamGaming/v2/effect/stealth.wav";	
new const gszBootsOfSpeedSound[] = 		"ScreamGaming/v2/effect/bootsofspeed.wav";
new const gszCAMOUFLAGEhSound[] = 		"ScreamGaming/v2/effect/camouflage.wav";
new const gszInvincibilitySound[] = 	"ScreamGaming/v2/effect/invincibility.wav";
new const gszHealthSound[] = 			"ScreamGaming/v2/effect/health.wav";

new const gsz1[] =        	"ScreamGaming/v1/music/Sound_1.wav";
new const gsz2[] =       	"ScreamGaming/v1/music/Sound_2.wav";
new const gsz3[] =        	"ScreamGaming/v1/music/Sound_3.wav";
new const gsz4[] =        	"ScreamGaming/v1/music/Sound_4.wav";
new const gsz5[] =        	"ScreamGaming/v1/music/Sound_5.wav";
new const gsz6[] =        	"ScreamGaming/v1/music/Sound_6.wav";
new const gsz7[] =        	"ScreamGaming/v1/music/Sound_7.wav";
new const gsz8[] =        	"ScreamGaming/v1/music/Sound_8.wav";
new const gsz9[] =        	"ScreamGaming/v1/music/Sound_9.wav";
new const gsz10[] =      	"ScreamGaming/v1/music/Sound_10.wav";
new const gsz11[] =      	"ScreamGaming/v1/music/Sound_11.wav";
new const gsz12[] =      	"ScreamGaming/v1/music/Sound_12.wav";
new const gsz13[] =      	"ScreamGaming/v1/music/Sound_13.wav";
new const gsz14[] =      	"ScreamGaming/v1/music/Sound_14.wav";
new const gsz15[] =      	"ScreamGaming/v1/music/Sound_15.wav";
new const gsz16[] =      	"ScreamGaming/v1/music/Sound_16.wav";
new const gsz17[] =      	"ScreamGaming/v1/music/Sound_17.wav";

new id_Sprites[2];

new g_sprite_beam;
new gszCamouflageOldModel[33][32];

static BlocksProperty[33][6][5];
new bool:ChanceUsed[33]; // weapon chance
new bool:HeUsed[33], bool:FlashUsed[33], bool:SmokeUsed[33], bool:AllGrenadesUsed[33];

enum ( <<= 1 )
{
	B1 = 1,
	B2,
	B3,
	B4,
	B5,
	B6,
	B7,
	B8,
	B9,
	B0
};

enum
{
	K1,
	K2,
	K3,
	K4,
	K5,
	K6,
	K7,
	K8,
	K9,
	K0
};

enum
{
	CHOICE_DELETE,
	CHOICE_LOAD
};

enum
{
	X,
	Y,
	Z
};

//1 - 4 	FOR ENTITIES
//5 - end 	FOR PLAYERS
enum ( += 1000 )
{
	TASK_SPRITE, 		//OR TASK_MUSIC FOR PLAYERS
	TASK_SOLID,
	TASK_SOLID_NOT,
	TASK_MOVEBACK,
	TASK_ICE,			//OR TASK_ROTATE FOR ENTITIES
	TASK_HONEY,
	TASK_NOSLOWDOWN,
	TASK_INVINCIBLE,
	TASK_STEALTH,
	TASK_BOOTSOFSPEED,
	TASK_CAMOUFLAGE
};

new g_file[96];
new this_save[32];
new need_load[33][32];

new g_GameMode = 0; // 1/2/3/4/5 - knives/pointmod/weapon/classic/test
new c_GameMode[33];
new pre_GameMode[33][3];
new prefix_GameMode[5][3];
new index_menu[33];

new counter = 0;

new chooser_b[33];
new choose_b[10] = 0;
new all_choose = 0;
new buildname_menu[5][10][32];
new buildname_tests[20][32];
new modesname[5][32];
new b_count[5] = 0;
new first_round = 0;

new g_keys_main_menu;
new g_keys_block_menu;
new g_keys_block_selection_menu;
new g_keys_properties_menu;
new g_keys_move_menu;
new g_keys_teleport_menu;
new g_keys_light_menu;
new g_keys_light_properties_menu;
new g_keys_options_menu;
new g_keys_choice_menu;
new g_keys_commands_menu;
new gRenderMenuKeys;
new g_keys_weapons_menu, g_keys_weapons_menu2, g_keys_weapons_menu3;
new g_keys_extra_menu;
new g_keys_movement_menu;
new g_keys_rotate_menu;
new g_keys_skip_menu;

new g_main_menu[256];
new g_block_menu[256];
new g_move_menu[256];
new g_teleport_menu[256];
new g_light_menu[128];
new g_light_properties_menu[256];
new g_options_menu[256];
new g_choice_menu[128];
new g_commands_menu[256];
new gRenderMenu[256];
new g_weapons_menu[256], g_weapons_menu2[256], g_weapons_menu3[256];
new g_extra_menu[256];
new g_movement_menu[256];
new g_rotate_menu[256];
new g_skip_menu[256];

new g_viewmodel[33][32];

new gmsgScreenFade;

new bool:GoVote=true;
new bool:GoVoteStart=true;

new bool:g_connected[33];
new bool:g_alive[33];
new bool:g_gived_access[33];
new bool:g_snapping[33];
new bool:g_viewing_properties_menu[33];
new bool:g_viewing_light_properties_menu[33];
new bool:g_viewing_commands_menu[33];
new bool:g_no_fall_damage[33];
new bool:g_ice[33];
new bool:g_low_gravity[33];
new bool:g_no_slow_down[33];
new bool:g_has_hud_text[33];
new bool:g_block_status[33];
new bool:g_noclip[33];
new bool:g_godmode[33];
new bool:g_all_godmode;
new bool:g_has_checkpoint[33];
new bool:g_checkpoint_duck[33];
new bool:g_reseted[33];

new g_selected_block_size[33];
new g_choice_option[33];
new g_block_selection_page[33];
new g_weapons_page[33];
new g_teleport_start[33];
new g_grabbed[33];
new g_grouped_blocks[33][256];
new g_group_count[33];
new g_property_info[33][2];
new g_light_property_info[33][2];
new g_slap_times[33];
new g_honey[33];
new g_boots_of_speed[33];

new Float:g_grid_size[33];
new Float:g_snapping_gap[33];
new Float:g_grab_offset[33][3];
new Float:g_grab_length[33];
new Float:g_next_damage_time[33];
new Float:g_next_heal_time[33];
new Float:g_invincibility_time_out[33];
new Float:g_invincibility_next_use[33];
new Float:g_stealth_time_out[33];
new Float:g_stealth_next_use[33];
new Float:g_CAMOUFLAGE_time_out[33];
new Float:g_CAMOUFLAGE_next_use[33];
new Float:g_boots_of_speed_time_out[33];
new Float:g_boots_of_speed_next_use[33];
new Float:g_music_next_use[33];
new Float:g_user_in_music[33];
new Float:g_pb_next_use[33];
new Float:g_weapon_chance_next_use[33];
new Float:g_random_next_use[33];
new Float:g_set_velocity[33][3];
new Float:g_checkpoint_position[33][3];

new g_weapons_text_mess[33];
new Float:g_weapons_mess_time[33];
new Float:g_weapon_chance_next_use_mess[33];
new Float:g_greandes_mess_time_all[33];
new Float:g_greandes_mess_time_he[33];
new Float:g_greandes_mess_time_fn[33];
new Float:g_greandes_mess_time_fb[33];
new Float:g_invincibility_next_use_mess[33];
new Float:g_stealth_next_use_mess[33];
new Float:g_CAMOUFLAGE_next_use_mess[33];
new Float:g_boots_of_speed_next_use_mess[33];
new Float:g_pb_next_use_mess[33];
new Float:g_pb_next_use_mess_nope[33];
new Float:g_random_next_use_mess[33];

new Float:g_should_show_skip_time_mess[33];
new g_should_show_skip_time_ent[33];

new Float:g_should_show_rotate_time_mess[33];
new g_should_show_rotate_time_ent[33];

//Movement menu
new MovementType[33];
new g_Distance[33];
new b_Distance[MAX_ENT];

new Float:g_origin[MAX_ENT][3];
new Float:g_Axis[33][3], Float:Velocity[MAX_ENT][3]; 

//Carpets
new Float:origin_carpet[MAX_ENT][3];

// Render Menu
new Transperancy[MAX_ENT];
new Color_Red_RM[33], Color_Green_RM[33], Color_Blue_RM[33];
new Transperancy_RM[33], gRenderInfo[33], gTyp[33];
new Float:user_rotate_time[33], Float:ent_rotate_time[MAX_ENT], Float:ent_rotate_time_start[MAX_ENT];
new Float:user_skip_time[33], Float:ent_skip_time[MAX_ENT], Float:ent_skip_time_start[MAX_ENT];
// Render Group
new gRenderFx[MAX_ENT], Float:gRenderColor[MAX_ENT][3], gRenderMode[MAX_ENT], Float:gRenderAmt[MAX_ENT];
//SolidNot-Solid
new gRenderFx_Solid[MAX_ENT], Float:gRenderColor_Solid[MAX_ENT][3], gRenderMode_Solid[MAX_ENT], Float:gRenderAmt_Solid[MAX_ENT];

new g_max_players;

new b_all_count = 0;
new g_voted[33];
new g_count_voted = 0;
new g_before_counter = 0;
new Float: g_vote_progress;

new g_checker_stuck[33] = 0;

new bool:change_world = false;
new change_value_build[32];
new building_name_for_mess[32];

enum
{
	PLATFORM,
	BUNNYHOP,
	DAMAGE,
	HEALER,
	NO_FALL_DAMAGE,
	ICE,
	TRAMPOLINE,
	SPEED_BOOST,
	DEATH,
	LOW_GRAVITY,
	SLAP,
	HONEY,
	CT_BARRIER,
	T_BARRIER,
	VIP_BARRIER,
	NO_SLOW_DOWN_BUNNYHOP,
	DELAYED_BUNNYHOP,
	BUNNYHOP_D,
	INVINCIBILITY,
	STEALTH,
	BOOTS_OF_SPEED,
	CAMOUFLAGE,
	GRANATA,
	WEAPON,
	WEAPON_CHANCE,
	MUSIC,
	DOUBLE_DUCK,
	BLIND_TRAP,
	EARTHQUAKE,
	CARPET,
	POINT_BLOCK,
	RANDOM,
	
	TOTAL_BLOCKS
};

enum
{
	TELEPORT_START,
	TELEPORT_DESTINATION
};

enum
{
	NORMAL,
	TINY,
	LARGE,
	POLE
};

enum
{
	NORMAL,
	GLOWSHELL,
	TRANSCOLOR,
	TRANSALPHA,
	TRANSWHITE,
	GLOWALPHA,
	HOLOGRAM,
	FADEFAST
};

new g_selected_block_type[TOTAL_BLOCKS];
new g_render[TOTAL_BLOCKS];
new g_red[TOTAL_BLOCKS];
new g_green[TOTAL_BLOCKS];
new g_blue[TOTAL_BLOCKS];
new g_alpha[TOTAL_BLOCKS];
new WeaponUsed[27][33];

new const g_block_names[TOTAL_BLOCKS][] =
{
	"Platform",
	"Bunnyhop",
	"Damage",
	"Healer",
	"No Fall Damage",
	"Ice",
	"Trampoline",
	"Speed Boost",
	"Death",
	"Low Gravity",
	"Slap",
	"Honey",
	"CT Barrier",
	"T Barrier",
	"Vip Barrier",
	"No Slow Down Bunnyhop",
	"Delayed Bunnyhop",
	"Bunnyhop Damage",
	"Invincibility",
	"Stealth",
	"Boots of Speed",
	"Camouflage",
	"Nades",
	"Weapon",
	"Weapon chance",
	"Music",
	"Double Duck",
	"Blind Trap",
	"Earthquake",
	"Magic Carpet",
	"Point Block",
	"Random Block"
};

new const g_property1_name[TOTAL_BLOCKS][] =
{
	"",
	"No Fall Damage",
	"Damage Per Interval",
	"Healer Per Interval",
	"",
	"",
	"Upward Speed",
	"Forward Speed",
	"",
	"Gravity",
	"Hardness",
	"Speed In Honey",
	"Barrier type",
	"Barrier type",
	"Barrier type",
	"No Fall Damage",
	"Delay Before Dissapear",
	"No Fall Damage",
	"Invincibility Time",
	"Stealth Time",
	"Boots Of Speed Time",
	"Duration",
	"Nades Type",
	"Weapon",
	"Next use",
	"",
	"",
	"Type",
	"Type",
	"Magic Carpet",
	"Points",
	"Transformation Time"
};

new const g_property1_default_value[TOTAL_BLOCKS][] =
{
	"",
	"0",
	"5",
	"1",
	"",
	"",
	"500",
	"1000",
	"",
	"200",
	"2",
	"75",
	"1",
	"1",
	"1",
	"0",
	"1",
	"0",
	"10",
	"10",
	"10",
	"15",
	"1",
	"p228",
	"60",
	"",
	"",
	"1",
	"1",
	"1",
	"10",
	"10"
};

new const g_property2_name[TOTAL_BLOCKS][] =
{
	"",
	"",
	"Interval Between Damage",
	"Interval Between Heals",
	"",
	"",
	"",
	"Upward Speed",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"Damage Per Interval",
	"Next use",
	"Next use",
	"Next use",
	"Next use",
	"Count",
	"Bullets",
	"",
	"Next use",
	"",
	"",
	"",
	"Respawn",
	"Next use",
	"Next use"
};

new const g_property2_default_value[TOTAL_BLOCKS][] =
{
	"",
	"",
	"0.5",
	"0.5",
	"",
	"",
	"",
	"200",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"5",
	"60",
	"60",
	"60",
	"60",
	"1",
	"1",
	"",
	"20",
	"",
	"",
	"",
	"0",
	"60",
	"60"
};

new const g_property3_name[TOTAL_BLOCKS][] =
{
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"Speed",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"Max height",
	"",
	""
};

new const g_property3_default_value[TOTAL_BLOCKS][] =
{
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"400",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"1200",
	"",
	""
};

new const g_property4_name[TOTAL_BLOCKS][] =
{
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"Fly Speed",
	"On Top Only",
	"On Top Only"
};

new const g_property4_default_value[TOTAL_BLOCKS][] =
{
	"1",
	"0",
	"1",
	"1",
	"1",
	"1",
	"0",
	"0",
	"1",
	"1",
	"1",
	"1",
	"0",
	"0",
	"0",
	"0",
	"0",
	"0",
	"1",
	"1",
	"1",
	"1",
	"1",
	"1",
	"1",
	"1",
	"1",
	"1",
	"1",
	"25",
	"1",
	"1"
};

new const g_block_save_ids[TOTAL_BLOCKS] =
{
	'A',
	'B',
	'C',
	'D',
	'E',
	'F',
	'G',
	'H',
	'I',
	'J',
	'K',
	'L',
	'M',
	'N',
	'W',
	'P',
	'Q',
	'6',
	'R',
	'S',
	'T',
	'U',
	'V',
	'Y',
	'8',
	'2',
	'3',
	'1',
	'4',
	'5',
	'7',
	'9'
};

new g_block_models[TOTAL_BLOCKS][256];

new maxar[33];
new maxhp[33];

new pointblock_players_cvar, agm_status;

new g_block_selection_pages_max;

new const g_iKnives[13][] =
{
	"Swap Knife",
	"Ninja Knife",
	"Fast Blade",
	"Flash Blade",
	"Poison Sting",
	"Push Blade",
	"Titan Blade",
	"Fire Knife",
	"Frost Knife",
	"Thunder Knife",
	"Vampire Blade",
	"Reflect Blade",
	"Standart Knife"
};

new const Float:size[][3] = {
	{0.0, 0.0, 1.0}, {0.0, 0.0, -1.0}, {0.0, 1.0, 0.0}, {0.0, -1.0, 0.0}, {1.0, 0.0, 0.0}, {-1.0, 0.0, 0.0}, {-1.0, 1.0, 1.0}, {1.0, 1.0, 1.0}, {1.0, -1.0, 1.0}, {1.0, 1.0, -1.0}, {-1.0, -1.0, 1.0}, {1.0, -1.0, -1.0}, {-1.0, 1.0, -1.0}, {-1.0, -1.0, -1.0},
	{0.0, 0.0, 2.0}, {0.0, 0.0, -2.0}, {0.0, 2.0, 0.0}, {0.0, -2.0, 0.0}, {2.0, 0.0, 0.0}, {-2.0, 0.0, 0.0}, {-2.0, 2.0, 2.0}, {2.0, 2.0, 2.0}, {2.0, -2.0, 2.0}, {2.0, 2.0, -2.0}, {-2.0, -2.0, 2.0}, {2.0, -2.0, -2.0}, {-2.0, 2.0, -2.0}, {-2.0, -2.0, -2.0},
	{0.0, 0.0, 3.0}, {0.0, 0.0, -3.0}, {0.0, 3.0, 0.0}, {0.0, -3.0, 0.0}, {3.0, 0.0, 0.0}, {-3.0, 0.0, 0.0}, {-3.0, 3.0, 3.0}, {3.0, 3.0, 3.0}, {3.0, -3.0, 3.0}, {3.0, 3.0, -3.0}, {-3.0, -3.0, 3.0}, {3.0, -3.0, -3.0}, {-3.0, 3.0, -3.0}, {-3.0, -3.0, -3.0},
	{0.0, 0.0, 4.0}, {0.0, 0.0, -4.0}, {0.0, 4.0, 0.0}, {0.0, -4.0, 0.0}, {4.0, 0.0, 0.0}, {-4.0, 0.0, 0.0}, {-4.0, 4.0, 4.0}, {4.0, 4.0, 4.0}, {4.0, -4.0, 4.0}, {4.0, 4.0, -4.0}, {-4.0, -4.0, 4.0}, {4.0, -4.0, -4.0}, {-4.0, 4.0, -4.0}, {-4.0, -4.0, -4.0},
	{0.0, 0.0, 5.0}, {0.0, 0.0, -5.0}, {0.0, 5.0, 0.0}, {0.0, -5.0, 0.0}, {5.0, 0.0, 0.0}, {-5.0, 0.0, 0.0}, {-5.0, 5.0, 5.0}, {5.0, 5.0, 5.0}, {5.0, -5.0, 5.0}, {5.0, 5.0, -5.0}, {-5.0, -5.0, 5.0}, {5.0, -5.0, -5.0}, {-5.0, 5.0, -5.0}, {-5.0, -5.0, -5.0}
};

public plugin_precache()
{
	g_block_models[PLATFORM] =		g_model_platform;
	g_block_models[BUNNYHOP] =		g_model_bunnyhop;
	g_block_models[BUNNYHOP_D] =		g_model_bunnyhop_damage;
	g_block_models[DAMAGE] =			g_model_damage;
	g_block_models[HEALER] =			g_model_healer;
	g_block_models[NO_FALL_DAMAGE] =		g_model_no_fall_damage;
	g_block_models[ICE] =			g_model_ice;
	g_block_models[TRAMPOLINE] =		g_model_trampoline;
	g_block_models[SPEED_BOOST] =		g_model_speed_boost;
	g_block_models[DEATH] =			g_model_death;
	g_block_models[LOW_GRAVITY] =		g_model_low_gravity;
	g_block_models[SLAP] =			g_model_slap;
	g_block_models[HONEY] =			g_model_honey;
	g_block_models[CT_BARRIER] =		g_model_ct_barrier;
	g_block_models[T_BARRIER] =		g_model_t_barrier;
	g_block_models[VIP_BARRIER] =		g_model_admin_barrier;
	g_block_models[NO_SLOW_DOWN_BUNNYHOP] =	g_model_no_slow_down_bunnyhop;
	g_block_models[DELAYED_BUNNYHOP] =	g_model_delayed_bunnyhop;
	g_block_models[INVINCIBILITY] =		g_model_invincibility;
	g_block_models[STEALTH] =		g_model_stealth;
	g_block_models[BOOTS_OF_SPEED] =	g_model_boots_of_speed;
	g_block_models[WEAPON] =		g_model_weapon;
	g_block_models[WEAPON_CHANCE] =		g_model_weapon_chance;
	g_block_models[GRANATA] =		g_model_granata;
	g_block_models[CAMOUFLAGE] =		g_model_camouflage;
	g_block_models[MUSIC] =			g_model_music;
	g_block_models[DOUBLE_DUCK] =		g_model_double_duck;
	g_block_models[BLIND_TRAP] =		g_model_blind_trap;
	g_block_models[EARTHQUAKE] =		g_model_earthquake;
	g_block_models[CARPET] =		g_model_magic_carpet;
	g_block_models[POINT_BLOCK] =		g_model_point_block_O_O;
	g_block_models[RANDOM] =		g_model_random_block;
	
	SetupBlockRendering(INVINCIBILITY, GLOWSHELL, 255, 255, 255, 16);
	
	new block_model[256];
	for ( new i = 0; i < TOTAL_BLOCKS; ++i )
	{
		precache_model(g_block_models[i]);
		
		SetBlockModelName(block_model, g_block_models[i], "Small");
		precache_model(block_model);
		
		SetBlockModelName(block_model, g_block_models[i], "Large");
		precache_model(block_model);
		
		SetBlockModelName(block_model, g_block_models[i], "Pole");
		precache_model(block_model);
	}
	
	id_Sprites[0] = precache_model("sprites/ArtGames/v2/health.spr");
	id_Sprites[1] = precache_model("sprites/shockwave.spr");
	
	precache_model(g_sprite_light);
	
	precache_model(g_sprite_teleport_start);
	precache_model(g_sprite_teleport_destination);
	
	g_sprite_beam = precache_model("sprites/zbeam4.spr");
	
	precache_sound(g_sound_teleport);
	precache_sound(gszStealthSound);
	precache_sound(gszHealthSound);
	precache_sound(gszCAMOUFLAGEhSound);
	precache_sound(gszInvincibilitySound);
	precache_sound(gszBootsOfSpeedSound);
	
	precache_sound(gsz1);
	precache_sound(gsz2);
	precache_sound(gsz3);
	precache_sound(gsz4);
	precache_sound(gsz5);
	precache_sound(gsz6);
	precache_sound(gsz7);
	precache_sound(gsz8);
	precache_sound(gsz9);
	precache_sound(gsz10);
	precache_sound(gsz11);
	precache_sound(gsz12);
	precache_sound(gsz13);
	precache_sound(gsz14);
	precache_sound(gsz15);
	precache_sound(gsz16);
	precache_sound(gsz17);
	
	return PLUGIN_CONTINUE;
}

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	
	register_clcmd("say /bm", "CmdMainMenu", -1, g_blank);
	register_clcmd("say_team /bm", "CmdMainMenu", -1, g_blank);
	
	register_clcmd("+bmGrab", "CmdGrab", -1, g_blank);
	register_clcmd("-bmGrab", "CmdRelease", -1, g_blank);
	
	register_clcmd("BCM_SetRendering",	"SetRenderingBlock",	-1);
	register_clcmd("BCM_SetProperty",	"SetPropertyBlock",	-1);
	register_clcmd("BCM_SetLightProperty",	"SetPropertyLight",	-1);
	register_clcmd("BCM_Revive",		"RevivePlayer",		-1);
	register_clcmd("BCM_GiveAccess",	"GiveAccess",		-1);
	register_clcmd("Set_Movement",		"SetMovement",		-1);
	register_clcmd("Set_SkipTime",		"SetSkip",		-1);
	register_clcmd("Set_RotateTime",	"SetRotateTime",	-1);
	
	register_clcmd("___enter_savename","SaveName", -1);
	register_clcmd("___enter_loadname","LoadName", -1);
	
	register_clcmd("say /vote", "TrynnaStartTheVote", -1, g_blank);
	register_clcmd("say_team /vote", "TrynnaStartTheVote", -1, g_blank);
	
	register_clcmd("say /stop_vote", "CmdUserSayVote", -1, g_blank);
	register_clcmd("say_team /stop_vote", "CmdUserSayVote", -1, g_blank);
	
	register_event("ResetHUD", "ResetHUD", "abe");
	
	CreateMenus();
	
	register_menucmd(register_menuid("BcmMainMenu"),		g_keys_main_menu,		"HandleMainMenu");
	register_menucmd(register_menuid("BcmBlockMenu"),		g_keys_block_menu,		"HandleBlockMenu");
	register_menucmd(register_menuid("BcmBlockSelectionMenu"),	g_keys_block_selection_menu,	"HandleBlockSelectionMenu");
	register_menucmd(register_menuid("BcmPropertiesMenu"),		g_keys_properties_menu,		"HandlePropertiesMenu");
	register_menucmd(register_menuid("BcmMoveMenu"),		g_keys_move_menu,		"HandleMoveMenu");
	register_menucmd(register_menuid("BcmTeleportMenu"),		g_keys_teleport_menu,		"HandleTeleportMenu");
	register_menucmd(register_menuid("BcmLightMenu"),		g_keys_light_menu,		"HandleLightMenu");
	register_menucmd(register_menuid("BcmLightPropertiesMenu"),	g_keys_light_properties_menu,	"HandleLightPropertiesMenu");
	register_menucmd(register_menuid("BcmOptionsMenu"),		g_keys_options_menu,		"HandleOptionsMenu");
	register_menucmd(register_menuid("BcmChoiceMenu"),		g_keys_choice_menu,		"HandleChoiceMenu");
	register_menucmd(register_menuid("BcmCommandsMenu"),		g_keys_commands_menu,		"HandleCommandsMenu");
	register_menucmd(register_menuid("bmRenderMenu"), 		gRenderMenuKeys, 		"HandleRenderMenu");
	register_menucmd(register_menuid("BcmWeaponsMenu"),		g_keys_weapons_menu,		"HandleWeaponsMenu");
	register_menucmd(register_menuid("BcmExtraMenu"),		g_keys_extra_menu,		"HandleExtraMenu");
	register_menucmd(register_menuid("BcmSkipMenu"),		g_keys_skip_menu,		"HandleSkipMenu");
	register_menucmd(register_menuid("BcmMovementMenu"),		g_keys_movement_menu,		"HandleMovementMenu");
	register_menucmd(register_menuid("BcmRotateMenu"),		g_keys_rotate_menu,		"HandleRotateMenu");
	
	RegisterHam(Ham_Spawn, "player", "FwdPlayerSpawn", 1);
	RegisterHam(Ham_Killed, "player", "FwdPlayerKilled", 1);
	
	//Register Round Start
	register_logevent("eRound_start", 2, "1=Round_Start");
	
	register_forward(FM_CmdStart, "FwdCmdStart");
	
	register_think(g_light_classname, "LightThink");
	register_think(g_block_classname, "MovementBlock");
	
	register_event("CurWeapon",	"EventCurWeapon", "be");
	
	register_message(get_user_msgid("StatusValue"),	"MsgStatusValue");
	
	g_max_players =		get_maxplayers();
	
	new dir[64];
	get_datadir(dir, charsmax(dir));
	
	new folder[64];
	formatex(folder, charsmax(folder), "/%s", PLUGIN_PREFIX);
	
	add(dir, charsmax(dir), folder);
	if ( !dir_exists(dir) ) mkdir(dir);
	
	new map[32];
	get_mapname(map, charsmax(map));
	formatex(g_file, charsmax(g_file), "%s/%s", dir, map);
	
	formatex(this_save, charsmax(this_save), "#DONTHAVE");
	
	formatex(prefix_GameMode[0], 2, "k_");
	formatex(prefix_GameMode[1], 2, "p_");
	formatex(prefix_GameMode[2], 2, "w_");
	formatex(prefix_GameMode[3], 2, "c_");
	formatex(prefix_GameMode[4], 2, "t_");
	
	pointblock_players_cvar = register_cvar("agm_pnum", "4");
	agm_status = register_cvar("agm_status", "4");
}

public plugin_natives()
{
	register_library("ScreamGamingCM");
	register_native("sgcm_get_blockmaker_info", "native_sgcm_get_blockmaker_info", 1);
	register_native("sgcm_in_stealth", "native_sgcm_in_stealth", 1);
	register_native("sgcm_set_stealth_message", "native_sgcm_set_stealth_message", 1);
	register_native("sgcm_set_boots_message", "native_sgcm_set_boots_message", 1);
	register_native("sgcm_reset_maxspeed", "native_sgcm_reset_maxspeed", 1);
}

public native_sgcm_reset_maxspeed(id){
	if(g_alive[id])	ResetMaxspeed(id);
}

public native_sgcm_set_boots_message(id, Float:time){
	g_boots_of_speed_time_out[id] = get_gametime() + time;
	
	if(g_boots_of_speed_next_use[id] - get_gametime() > 0.0)
		g_boots_of_speed_next_use[id] += time;
	else g_boots_of_speed_next_use[id] = get_gametime() + time;
}

public native_sgcm_set_stealth_message(id, Float:time){
	g_stealth_time_out[id] = get_gametime() + time;
	
	if(g_stealth_next_use[id] - get_gametime() > 0.0)
		g_stealth_next_use[id] += time;
	else g_stealth_next_use[id] = get_gametime() + time;
}

public native_sgcm_in_stealth(id){
	if(g_stealth_time_out[id] - get_gametime() >= 0.0){
		return true;
	}
	
	return false;
}

public native_sgcm_get_blockmaker_info(id, viewer, g_iLevel, g_iPoint, g_iTotal, exp, knife, Float:k_cooldown, bool:stucked){
	if(stucked){ g_checker_stuck[id] = 100; }
	checkstuck(id);
	
	new message[512], mini_prefix[8];
	
	if(id != viewer){
		new name[36]; get_user_name(id, name, charsmax(name));
		format(message, charsmax(message), "Spectating for %s:^n^n", name);
	}else{
		formatex(mini_prefix, charsmax(mini_prefix), "Your ");
	}
	
	switch(get_pcvar_num(agm_status)){
		case 1: format(message, charsmax(message), "%sGame mode: Knives^n", message);
		case 2: format(message, charsmax(message), "%sGame mode: Points^n", message);
		case 3: format(message, charsmax(message), "%sGame mode: Weapons^n", message);
		case 4:	format(message, charsmax(message), "%sGame mode: Classic^n", message);
		default: format(message, charsmax(message), "%sGame mode: Off^n", message);
	}
	
	format(message, charsmax(message), "%sBuilding: %s^n", message, building_name_for_mess);
	
	if(get_pcvar_num(agm_status) == 2 || get_pcvar_num(agm_status) == 1){
		if(g_iLevel != 101){
			format(message, charsmax(message), "%s^n%sLevel: %i of 101^n%sActive Points: %i^n%sTotal Points: %i of %i^n", message, mini_prefix, g_iLevel, mini_prefix, g_iPoint, mini_prefix, g_iTotal, exp);
		}else{
			format(message, charsmax(message), "%s^n%sLevel: %i of 101^n%sActive Points: %i^n%sTotal Points: %i^n", message, mini_prefix, g_iLevel, mini_prefix, g_iPoint, mini_prefix, g_iTotal);
		}
	}
	
	if(get_pcvar_num(agm_status) == 1){
		new cooldown[5];
		
		if(k_cooldown - get_gametime() >= 0.0){
			formatex(cooldown, 4, "%0.1fs", k_cooldown - get_gametime());
		}else{
			formatex(cooldown, 4, "NO");
		}
		
		format(message, charsmax(message), "%s^nCurrent Knife: %s^nCooldown: %s^n", message, g_iKnives[knife], cooldown);
	}
	
	new Float:timeleft_invincibility 			=	g_invincibility_time_out[id] - get_gametime();
	new Float:timeleft_stealth					=	g_stealth_time_out[id] - get_gametime();
	new Float:timeleft_CAMOUFLAGE				=	g_CAMOUFLAGE_time_out[id] - get_gametime();
	new Float:timeleft_boots_of_speed 			=	g_boots_of_speed_time_out[id] - get_gametime();
	new Float:timeleft_music_play 				=	g_music_next_use[id] - get_gametime();
	
	new text[50], bool:add_empty_string;
	
	if(timeleft_invincibility >= 0.0){
		format(text, charsmax(text), "^nInvincible works: %.1f", timeleft_invincibility);
		add(message, charsmax(message), text);
		add_empty_string = true;
	}
	
	if(timeleft_stealth >= 0.0){
		format(text, charsmax(text), "^nStealth works: %.1f", timeleft_stealth);
		add(message, charsmax(message), text);
		add_empty_string = true;
	}
	
	if(timeleft_CAMOUFLAGE >= 0.0){
		format(text, charsmax(text), "^nCamouflage works: %.1f", timeleft_CAMOUFLAGE);
		add(message, charsmax(message), text);
		add_empty_string = true;
	}
	
	if(timeleft_boots_of_speed >= 0.0){
		format(text, charsmax(text), "^nBoots work: %.1f", timeleft_boots_of_speed);
		add(message, charsmax(message), text);
		add_empty_string = true;
	}
	
	if(timeleft_music_play >= 0.0){
		format(text, charsmax(text), "^nMusic plays: %.1f", timeleft_music_play);
		add(message, charsmax(message), text);
		add_empty_string = true;
	}
	
	if(add_empty_string){
		add(message, charsmax(message), "^n");
		add_empty_string = false;
	}
	
	if(g_should_show_skip_time_mess[id] - get_gametime() >= 0.0 && (task_exists(TASK_SOLID_NOT + g_should_show_skip_time_ent[id])) && ent_skip_time_start[g_should_show_skip_time_ent[id]] > 0.0){
		if(!(ent_skip_time_start[g_should_show_skip_time_ent[id]] - get_gametime() <= 0.1)){
			format(text, charsmax(text), "^nSkip time: %.1f", ent_skip_time_start[g_should_show_skip_time_ent[id]] - get_gametime());
		}else{
			format(text, charsmax(text), "^nSkip time: right now");
		}
		add(message, charsmax(message), text);
		add_empty_string = true;
	}
	
	
	if(g_should_show_rotate_time_mess[id] - get_gametime() >= 0.0 && (task_exists(TASK_ICE + g_should_show_rotate_time_ent[id])) && ent_rotate_time_start[g_should_show_rotate_time_ent[id]] > 0.0){
		if(!(ent_rotate_time_start[g_should_show_rotate_time_ent[id]] - get_gametime() <= 0.1)){
			format(text, charsmax(text), "^nRotate Time: %.1f", ent_rotate_time_start[g_should_show_rotate_time_ent[id]] - get_gametime());
		}else{
			format(text, charsmax(text), "^nRotate Time: right now");
		}
		add(message, charsmax(message), text);
		add_empty_string = true;
	}
	
	if(add_empty_string){
		add(message, charsmax(message), "^n");
		add_empty_string = false;
	}
	
	if(g_invincibility_next_use_mess[id] - get_gametime() >= 0.0 && timeleft_invincibility < 0 && g_invincibility_next_use[id] - get_gametime() >= 0.0){
		format(text, charsmax(text), "^nInvincible cooldown: %.1f", g_invincibility_next_use[id] - get_gametime());
		add(message, charsmax(message), text);
		add_empty_string = true;
	}
	
	if(g_stealth_next_use_mess[id] - get_gametime() >= 0.0 && timeleft_stealth < 0 && g_stealth_next_use[id] - get_gametime() >= 0.0){
		format(text, charsmax(text), "^nStealth cooldown: %.1f", g_stealth_next_use[id] - get_gametime());
		add(message, charsmax(message), text);
		add_empty_string = true;
	}
	
	if(g_CAMOUFLAGE_next_use_mess[id] - get_gametime() >= 0.0 && timeleft_CAMOUFLAGE < 0 && g_CAMOUFLAGE_next_use[id] - get_gametime() >= 0.0){
		format(text, charsmax(text), "^nCamouflage cooldown: %.1f", g_CAMOUFLAGE_next_use[id] - get_gametime());
		add(message, charsmax(message), text);
		add_empty_string = true;
	}
	
	if(g_boots_of_speed_next_use_mess[id] - get_gametime() >= 0.0 && timeleft_boots_of_speed < 0 && g_boots_of_speed_next_use[id] - get_gametime() >= 0.0){
		format(text, charsmax(text), "^nBoots cooldown: %.1f", g_boots_of_speed_next_use[id] - get_gametime());
		add(message, charsmax(message), text);
		add_empty_string = true;
	}
	
	if(g_weapon_chance_next_use_mess[id] - get_gametime() >= 0.0 && g_weapon_chance_next_use[id] >= 0.0){
		format(text, charsmax(text), "^nWeapon chance cooldown: %.1f", g_weapon_chance_next_use[id] - get_gametime());
		add(message, charsmax(message), text);
		add_empty_string = true;
	}
	
	if(g_pb_next_use_mess[id] - get_gametime() >= 0.0 && g_pb_next_use[id] >= 0.0){
		format(text, charsmax(text), "^nPoint Block cooldown: %.1f", g_pb_next_use[id] - get_gametime());
		add(message, charsmax(message), text);
		add_empty_string = true;
	}
	
	if(g_random_next_use_mess[id] - get_gametime() >= 0.0 && g_random_next_use[id] >= 0.0){
		format(text, charsmax(text), "^nRandom block cooldown: %.1f", g_random_next_use[id] - get_gametime());
		add(message, charsmax(message), text);
		add_empty_string = true;
	}
	
	if(add_empty_string){
		add(message, charsmax(message), "^n");
		add_empty_string = false;
	}
	
	if(g_weapons_mess_time[id] - get_gametime() >= 0.0){
		format(text, charsmax(text), "^nWeapon block %s^nNext use: next round", g_weapons_text_mess);
		add(message, charsmax(message), text);
		add_empty_string = true;
	}
	
	if(add_empty_string){
		add(message, charsmax(message), "^n");
		add_empty_string = false;
	}
	
	if(g_greandes_mess_time_he[id] - get_gametime() >= 0.0){
		format(text, charsmax(text), "^nWeapon block (hegrenades)^nNext use: next round");
		add(message, charsmax(message), text);
		add_empty_string = true;
	}
	
	if(add_empty_string){
		add(message, charsmax(message), "^n");
		add_empty_string = false;
	}
	
	if(g_greandes_mess_time_fn[id] - get_gametime() >= 0.0){
		format(text, charsmax(text), "^nWeapon block (frostnades)^nNext use: next round");
		add(message, charsmax(message), text);
		add_empty_string = true;
	}
	
	if(add_empty_string){
		add(message, charsmax(message), "^n");
		add_empty_string = false;
	}
	
	if(g_greandes_mess_time_fb[id] - get_gametime() >= 0.0){
		format(text, charsmax(text), "^nWeapon block (flashbangs)^nNext use: next round");
		add(message, charsmax(message), text);
		add_empty_string = true;
	}
	
	if(add_empty_string){
		add(message, charsmax(message), "^n");
		add_empty_string = false;
	}
	
	if(g_greandes_mess_time_all[id] - get_gametime() >= 0.0){
		format(text, charsmax(text), "^nWeapon block (all grenades)^nNext use: next round");
		add(message, charsmax(message), text);
		add_empty_string = true;
	}
	
	if(add_empty_string){
		add(message, charsmax(message), "^n");
		add_empty_string = false;
	}
	
	if(g_pb_next_use_mess_nope[id] - get_gametime() >= 0.0 && get_pcvar_num(pointblock_players_cvar) >= 4){
		format(text, charsmax(text), "^nPoint Block: need %d players!", get_pcvar_num(pointblock_players_cvar));
		add(message, charsmax(message), text);
	}
	
	if(viewer != id || !is_user_alive(id)){
		set_hudmessage(0, 20, 255, 0.7, 0.17, 0, 0.0, 1.0, 0.0, 0.0, 1);
	}else{
		set_hudmessage(0, 20, 255, 0.7, 0.03, 0, 0.0, 1.0, 0.0, 0.0, 1);
	}
	
	show_hudmessage(viewer, message);
	
	return PLUGIN_CONTINUE;
}

public eRound_start()
{
	if(GoVote){
		set_task(25.0, "ChooseGameMode_pre", 0, _, _, "a", 1);
		g_vote_progress = get_gametime() + 900.0;
		GoVote=false;
	}
	
	if(change_world){
		change_world = false;
		LoadBlocks(0);
	}
	
	for(new i = 33; i <= MAX_ENT; i++)
	{
		if(IsBlock(i))
		{
			if(ent_skip_time[i] > 0.0 && task_exists(TASK_SOLID_NOT + i))
			{
				remove_task(TASK_SOLID_NOT + i);
				ent_skip_time_start[i] = 0.0;
			}
			
			static block_type;
			block_type = entity_get_int(i, EV_INT_body);
			
			if(block_type == CARPET)
				entity_set_origin(i, origin_carpet[i]);
		}
	}
}

public CmdUserSayVote(id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_D))
		return PLUGIN_HANDLED;
		
	if(GoVoteStart)
	{
		GoVoteStart = false;
		BCM_Print(id, "You`ve cancelled the vote!");
	}
	else
	{
		GoVoteStart = true;
		g_vote_progress = 0.0;
		BCM_Print(id, "You`ve activated the vote!");
	}
	
	return PLUGIN_HANDLED;
}

public TrynnaStartTheVote(id){
	new modes_count = 0;
	
	for(new i = 0; i <= 3; i++)
		if(b_count[i] >= 1)
			modes_count++;
	
	if(modes_count < 1 || b_all_count <= 1){
		BCM_Print(id, "^4Нельзя начать голосование^3. На карте больше ^4нет построек^3.");
		return PLUGIN_HANDLED;
	}
	
	if(g_vote_progress - get_gametime() > 0.0){
		new minutes = floatround(g_vote_progress - get_gametime()) / 60;
		new seconds = floatround(g_vote_progress - get_gametime()) % 60;
		BCM_Print(id, "Голосование можно будет начать через:^4 %d^3m,^4 %d^3s!", minutes, seconds);
		return PLUGIN_HANDLED;
	}
	
	if(g_voted[id]){
		BCM_Print(id, "^4Вы уже голосовали ^3за смену ^4режима и построек^3 на карте.");
		return PLUGIN_HANDLED;
	}
	
	g_voted[id] = true;
	g_count_voted++;
	new p_count = 0;
	
	for(new i = 1; i <= g_max_players; i++){
		if(g_connected[i]) p_count++;
	}
	
	new Float:g_winner_count = (p_count * 1.0) * 0.65;
	
	new name[36]; get_user_name(id, name, charsmax(name));
	for(new i = 1; i <= g_max_players; i++){
		BCM_Print(i, "^4%s ^3хочет начать голосование за изменение ^4режима игры и постройки^3.", name);
	}
	
	if(g_count_voted * 1.0 >= g_winner_count){
		client_cmd(0, "spk ^"get red(e80) ninety(s45) to check(e20) use bay(s18) mass(e42) cap(s50)^"");
		
		g_before_counter = 5;
		set_task(2.5, "StartVoteCount", _, _, _, "a", 1);
		
		g_count_voted = 0;
		g_vote_progress = get_gametime() + 900.0;
		
		for(new i = 1; i <= g_max_players; i++){
			g_voted[i] = false;
			BCM_Print(i, "Голосование за изменение ^4режима игры и постройки^3 начинается...");
		}
	}else{
		new votes_left = floatround(g_winner_count) - g_count_voted;
		if(votes_left <= 0) votes_left = 1;
		BCM_Print(id, "Необходимо ещё^4 %d /vote^3, чтобы начать голосование за изменение ^4режима и постройки^3.", votes_left);
	}
	
	return PLUGIN_CONTINUE;
}

public StartVoteCount(){
	set_hudmessage(0, 222, 50, -1.0, 0.13, 0, 1.0, 0.94, 0.0, 0.0, -1);
	show_hudmessage(0, "Голосование начнется через: %d...", g_before_counter);
	
	new word[6];
	num_to_word(g_before_counter, word, 5);
	client_cmd(0, "spk ^"fvox/%s^"", word);
	
	g_before_counter--;
	
	if(g_before_counter == 0){
		for(new i = 0; i <= 9; i++)
		{
			choose_b[i] = 0;
		}
		
		counter = 16;
		all_choose = 0;
		
		for(new users = 1; users <= g_max_players; users++)
		{
			if(is_user_connected(users))
			{
				chooser_b[users] = 0;
			}
		}
		
		set_task(1.0, "ChooseGameMode_start", 0, _, _, "b");
	}else{
		set_task(1.0, "StartVoteCount", _, _, _, "a", 1);
	}
}

public ChooseGameMode_pre(g)
{
	if(get_playersnum() < 1)
	{
		log_to_file("AGCM_information.txt", "[Choose Modes] Server is clean(without players)!");
		return PLUGIN_HANDLED;
	}
	
	if(!GoVoteStart)
	{
		for(new v = 1; v <= g_max_players; v++)
		{
			BCM_Print(v, "Vote has cancel by administrator!");
		}
		return PLUGIN_HANDLED;
	}
	
	counter = 16;
	
	new modes_count = 0, first_count = 0;
	
	for(new i = 0; i <= 3; i++)
	{
		if(b_count[i] >= 1)
		{
			if(modes_count == 0)
			{
				first_count = i;
			}
			
			modes_count++;
		}
	}
	
	if(modes_count > 1)
	{
		client_cmd(0, "spk ^"get red(e80) ninety(s45) to check(e20) use bay(s18) mass(e42) cap(s50)^"");
		
		g_before_counter = 5;
		set_task(2.5, "StartVoteCount", _, _, _, "a", 1);
		
		g_count_voted = 0;
		g_vote_progress = get_gametime() + 900.0;
		
		for(new i = 1; i <= g_max_players; i++){
			g_voted[i] = false;
		}
	}
	else if(modes_count == 1)
	{
		g_GameMode = first_count;
		
		for(new q = 1; q <= get_maxplayers(); q++)
		{	
			BCM_Print(q, "На сервере выбран режим игры: %s!", modesname[first_count]);
		}
		
		change_world = true;
		set_task(10.0, "ChooseBuilds_pre", 0);
	}
	else
	{
		for(new q = 1; q <= get_maxplayers(); q++)
		{
			BCM_Print(q, "На сервере выбран режим игры: Classic!");
		}
	}
	
	return PLUGIN_HANDLED;
}

public ChooseGameMode_start(g)
{
	if(get_playersnum() <= 0){
		return PLUGIN_HANDLED;
	}
	
	if(counter == 16){
		client_cmd(0, "spk Gman/Gman_Choose2");
	}
	
	if(counter <= 0)
	{
		remove_task(g);
		show_menu(0, 0, "^n", 1);
		ResultChooseGameMode(g);
		return PLUGIN_HANDLED;
	}
	
	counter--;
	
	for(new id = 1; id <= g_max_players; id++)
	{
		if(is_user_connected(id))
		{
			ChooseGameMode(id);
		}
	}
	
	return PLUGIN_HANDLED;
}

public ChooseGameMode(id)
{
	new i = 0, k = 0, choosers = 0;
	new title[64], modename[32], temp_id[10];
	
	if(counter > 5)
	{
		formatex(title, 63, "Choose GameMode^n^n\wTime: \r%d   ", counter-5);
	}
	else
	{
		formatex(title, 63, "Choose GameMode^n^n\yVote complited!   ");
	}
	
	new menu = menu_create(title, "ChooseGameMode_Handle");
	
	while(i <= 3)
	{	
		i++;
		
		if(b_count[i-1] <= 0)
		{
			continue;
		}
		
		num_to_str(i, temp_id, 9);
		
		if(all_choose != 0)
		{
			choosers = 100 * choose_b[i-1] / all_choose;
		}
		
		if(chooser_b[id] != 0)
		{
			format(modename, 31, "\d%s(%d%%)", modesname[i-1], choosers);
		}
		else
		{
			format(modename, 31, "%s(%d%%)", modesname[i-1], choosers);
		}
		
		menu_additem(menu,  modename, temp_id, 0);
		
		k++;
	}
	
	menu_addblank(menu, 0);
	
	if(chooser_b[id] != 0 && k > 1)
	{
		menu_additem(menu,  "\dRandom GameMode", "0", 0);
	}
	else if(k > 1)
	{
		menu_additem(menu,  "\yRandom GameMode", "0", 0);
	}
	
	if (k != 0)
	{
		menu_setprop(menu, MPROP_PERPAGE, 0);
		
		if(1 <= get_user_team(id) <= 2)
			menu_display(id, menu, 0);
	}
	
	return PLUGIN_HANDLED;
}

public ChooseGameMode_Handle(id, menu, item)
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
	
	new keys[4] = 0, c = 0;
	for(new i = 1; i <= 4; i++)
	{
		if(b_count[i-1] >= 1)
		{
			keys[i-1] = i;
			c++;
		}
	}
	
	if(chooser_b[id] == 0 && counter > 5)
	{
		if(key == 0)
		{
			key = random_num(1, c);
			
			new c_count = 0, d_count = 0;
		
			while(c_count < 4)
			{
				if(keys[c_count] != 0)
				{
					d_count++;
				
					if(d_count == key)
					{
						key = c_count + 1;
						continue;
					}
				}
			
				c_count++;
			}
		}
		
		chooser_b[id] = keys[key-1];
		choose_b[keys[key-1]-1]++;
		all_choose++;
		
		new name[32];
		get_user_name(id, name, 31);
		
		for(new i = 1; i <= g_max_players; i++)
		{
			BCM_Print(i, "%s проголосовал за %s!", name, modesname[keys[key-1]-1]);
		}
		
		ChooseGameMode(id);
	}
	else if(chooser_b[id] > 0 && counter > 5)
	{
		BCM_Print(id, "Ошибка! Вы уже проголосовали за %s!", modesname[chooser_b[id]-1]);
		ChooseGameMode(id);
	}
	else if(counter <= 5)
	{
		BCM_Print(id, "Ошибка! Голосование уже завершено!");
		ChooseGameMode(id);
	}
	
	return PLUGIN_HANDLED;
}

public ResultChooseGameMode(id)
{
	new max = 0;
	
	for(new k = 1; k <= 4; k++)
	{
		if(choose_b[k-1] > max)
		{
			max = choose_b[k-1];
		}
	}
	
	new i = 0, c_i = 0;
	new name_mode[4][32];
	
	while(c_i < 4)
	{
		if(choose_b[c_i] == max && b_count[c_i] > 0)
		{
			formatex(name_mode[i], 31, modesname[c_i]);
			i++;
		}
			
		c_i++;
	}
	
	
	new random_number = 0;
	
	if(i != 1)
	{
		random_number = random_num(0, i-1);
	}
	
	for(new q = 1; q <= get_maxplayers(); q++)
	{
		BCM_Print(q, "Голосование завершено! Выбран режим игры: %s!", name_mode[random_number]);
	}
	
	log_to_file("AGCM_information.txt", "[Choose Modes] Peoples choose mode: %s!", name_mode[random_number]);
	
	if(equal(name_mode[random_number], "Knives"))
	{
		random_number = 0;
	}
	else if(equal(name_mode[random_number], "Points"))
	{
		random_number = 1;
	}
	else if(equal(name_mode[random_number], "Weapons"))
	{
		random_number = 2;
	}
	else if(equal(name_mode[random_number], "Classic"))
	{	random_number = 3;
	
	}
	
	g_GameMode = random_number;
	change_world = true;
	
	set_task(5.0, "ChooseBuilds_pre", 0);
}

public ChooseBuilds_pre(g)
{
	if(b_count[g_GameMode] <= 1)
	{
		if(b_count[g_GameMode] == 1)
		{
			server_cmd("sv_restart 1");
			formatex(change_value_build, charsmax(change_value_build), buildname_menu[g_GameMode][0]);
			log_to_file("AGCM_information.txt", "[Choose Builds] Number of builds = 1, %s downloaded!", buildname_menu[g_GameMode][0]);
		}
		else
		{
			g_GameMode = 3;
			change_world = false;
			set_pcvar_num(agm_status, 4);
			log_to_file("AGCM_information.txt", "[Choose Builds] Number of builds = 0");
		}
		return PLUGIN_HANDLED;
	}
	
	if(get_playersnum() < 1)
	{
		g_GameMode = 3;
		change_world = false;
		set_pcvar_num(agm_status, 4);
		log_to_file("AGCM_information.txt", "[Choose Builds] Server is clean(without players)!");
		return PLUGIN_HANDLED;
	}
	
	for(new i = 0; i <= 9; i++)
	{
		choose_b[i] = 0;
	}
	
	counter = 16;
	all_choose = 0;
	
	for(new users = 1; users <= g_max_players; users++)
	{
		if(is_user_connected(users))
		{
			chooser_b[users] = 0;
		}
	}
	
	set_task(1.0, "ChooseBuilds_start", g, _, _, "b");
	
	return PLUGIN_HANDLED;
}
public ChooseBuilds_start(g)
{
	if(get_playersnum() <= 0){
		return PLUGIN_HANDLED;
	}
	
	if(counter == 16){
		client_cmd(0, "spk Gman/Gman_Choose2");
	}
	
	if(counter <= 0)
	{
		remove_task(g);
		show_menu(0, 0, "^n", 1);
		ResultChooseBuilds(g);
		return PLUGIN_HANDLED;
	}
	
	counter--;
	
	for(new id = 1; id <= g_max_players; id++){
		if(is_user_connected(id)){
			ChooseBuilds(id);
		}
	}
	
	return PLUGIN_HANDLED;
}
public ChooseBuilds(id)
{
	new i = 1, choosers = 0;
	new title[64], buildname[32], temp_id[10];
	
	if(counter > 5)
	{
		formatex(title, 63, "Choose Build^n^n\wTime: \r%d   ", counter-5);
	}
	else
	{
		formatex(title, 63, "Choose Build^n^n\yVote complited!   ");
	}
	
	new menu = menu_create(title, "ChooseBuilds_Handle");
	
	while(i <= b_count[g_GameMode])
	{
		num_to_str(i, temp_id, 9);
		
		if(all_choose != 0)
		{
			choosers = 100 * choose_b[i-1] / all_choose;
		}
		
		if(chooser_b[id] != 0)
		{
			format(buildname, 31, "\d%s(%d%%)", buildname_menu[g_GameMode][i-1], choosers);
		}
		else
		{
			format(buildname, 31, "%s(%d%%)", buildname_menu[g_GameMode][i-1], choosers);
		}
		
		menu_additem(menu,  buildname, temp_id, 0);
		i++;
	}
	
	menu_addblank(menu, 0);
	
	if(chooser_b[id] != 0)
	{
		menu_additem(menu,  "\dRandom build", "0", 0);
	}
	else
	{
		menu_additem(menu,  "\yRandom build", "0", 0);
	}
			
	if (i != 1)
	{
		menu_setprop(menu, MPROP_PERPAGE, 0);
		
		if(1 <= get_user_team(id) <= 2)
			menu_display(id, menu, 0);
	}
	
	return PLUGIN_HANDLED;
}

public ChooseBuilds_Handle(id, menu, item)
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
	
	if(chooser_b[id] == 0 && counter > 5)
	{
		if(key == 0)
		{
			key = random_num(1, b_count[g_GameMode]);
		}
		chooser_b[id] = key;
		choose_b[key-1]++;
		all_choose++;
		
		new name[32];
		get_user_name(id, name, 31);
		
		for(new i = 1; i <= g_max_players; i++){
			BCM_Print(i, "%s проголосовал за %s!", name, buildname_menu[g_GameMode][key-1]);
		}
		
		ChooseBuilds(id);
	}
	else if(counter < 5)
	{
		BCM_Print(id, "Ошибка! Голосование уже завершено!");
		ChooseBuilds(id);
	}
	else
	{
		BCM_Print(id, "Ошибка! Вы уже проголосовали за %s!", buildname_menu[g_GameMode][chooser_b[id]-1]);
		ChooseBuilds(id);
	}
	
	return PLUGIN_HANDLED;
}

public ResultChooseBuilds(id)
{
	new max = 0;
	
	for(new k = 1; k < 10; k++)
	{
		if(choose_b[k-1] > max)
		{
			max = choose_b[k-1];
		}
	}
	
	new i = 0, c_i = 1;
	new name_builds[10][32];
	
	while(c_i <= b_count[g_GameMode])
	{
		if(choose_b[c_i-1] == max)
		{
			formatex(name_builds[i], 31, buildname_menu[g_GameMode][c_i-1]);
			i++;
		}
			
		c_i++;
	}
	
	new random_number = 0;
	
	if(i != 1)
	{
		random_number = random_num(0, i-1);
	}
	
	for(new q = 1; q <= get_maxplayers(); q++)
	{
		BCM_Print(q, "Голосование завершено! Победила постройка: %s!", name_builds[random_number]);
	}
	
	log_to_file("AGCM_information.txt", "[Choose Builds] Peoples choose build: %s!", name_builds[random_number]);
	
	replace_all(name_builds[random_number], 31, ".AG", "");
	formatex(change_value_build, charsmax(change_value_build), name_builds[random_number]);
	server_cmd("sv_restart 1");
}

public ResetHUD(id)
{
	if (is_user_connected(id) && is_user_alive(id))
	{	
		set_task(0.01, "MHP", id);
		set_task(0.01, "MAR", id);
	}
}
public MHP(id)
{
	if(is_user_alive(id))
	{
		maxhp[id] = get_user_health(id);
	}
}
public MAR(id)
{
	if(is_user_alive(id))
	{
		maxar[id] = get_user_armor(id);
	}
}
public plugin_cfg()
{
	LoadBlocks_cfg();
}

public LoadBlocks_cfg()
{
	new key = 0;
	new buildname[32];
	new g_file_dir = open_dir(g_file, buildname, 31);
	
	if(first_round != 0)
	{
		b_count[0] = 0;
		b_count[1] = 0;
		b_count[2] = 0;
		b_count[3] = 0;
		b_count[4] = 0;
	}
	
	if(g_file_dir)
	{
		while(next_file(g_file_dir, buildname, 31))
		{
			if((contain(buildname, PLUGIN_PREFIX)!=-1))
			{
				replace_all(buildname, 31, ".AG", "");
				
				if(equal(buildname[0], "k_", 2) && b_count[0] != 9)
				{
					replace(buildname, 31, "k_", "");
					format(buildname_menu[0][b_count[0]], 31, buildname);
					b_count[0]++;
				}
				else if(equal(buildname[0], "p_", 2) && b_count[1] != 9)
				{
					replace(buildname, 31, "p_", "");
					format(buildname_menu[1][b_count[1]], 31, buildname);
					b_count[1]++;
				}
				else if(equal(buildname[0], "w_", 2) && b_count[2] != 9)
				{
					replace(buildname, 31, "w_", "");
					format(buildname_menu[2][b_count[2]], 31, buildname);
					b_count[2]++;
				}
				else if(equal(buildname[0], "c_", 2) && b_count[3] != 9)
				{
					replace(buildname, 31, "c_", "");
					format(buildname_menu[3][b_count[3]], 31, buildname);
					b_count[3]++;
				}
				else if(b_count[4] != 20)
				{
					replace(buildname, 31, "t_", "");
					format(buildname_tests[b_count[4]], 31, buildname);
					b_count[4]++;
				}
			}
		}
		
		if(first_round == 0)
		{
			if(b_count[3] > 1)
			{
				key = random_num(0, b_count[3]-1);
			}
			else if(b_count[3] == 1)
			{
				key = 0;
			}
			else
			{
				log_to_file("AGCM_information.txt", "[Start`s Config] Classic`s builds are not found!");
				close_dir(g_file_dir);
				return PLUGIN_HANDLED;
			}
		}
	}
	
	close_dir(g_file_dir);
	
	if(first_round == 0)
	{
		formatex(change_value_build, charsmax(change_value_build), buildname_menu[3][key]);
		change_world = false;
		g_GameMode = 3;
		LoadBlocks(0);
	
		log_to_file("AGCM_information.txt", "[Start`s Config] All normal! %s downloaded successfully!", buildname_menu[3][key]);
		log_to_file("AGCM_information.txt", "[Start`s Config] Buildcounter: K=%d, P=%d, W=%d, C=%d, TEST=%d!", b_count[0], b_count[1], b_count[2], b_count[3], b_count[4]);
	
		first_round = 1;
	}
	
	b_all_count = b_count[0] + b_count[1] + b_count[2] + b_count[3];
	
	formatex(modesname[0], 31, "Knives");
	formatex(modesname[1], 31, "Points");
	formatex(modesname[2], 31, "Weapons");
	formatex(modesname[3], 31, "Classic");
	formatex(modesname[4], 31, "Test");
	
	return PLUGIN_HANDLED;
}
public client_putinserver(id)
{
	chooser_b[id] = 0;

	g_connected[id] =			bool:!is_user_hltv(id);
	g_alive[id] =				false;
	
	g_gived_access[id] =			false;
	
	g_viewing_properties_menu[id] =		false;
	g_viewing_light_properties_menu[id] =	false;
	g_viewing_commands_menu[id] =		false;
	
	g_snapping[id] =			true;
	
	g_grid_size[id] =			1.0;
	g_snapping_gap[id] =			0.0;

	g_group_count[id] =			0;
	
	g_noclip[id] =				false;
	g_godmode[id] =				false;
	
	g_has_checkpoint[id] =			false;
	g_checkpoint_duck[id] =			false;
	
	g_reseted[id] =				false;
	
	//Colors and Transperancy
	gTyp[id] =				TRANSALPHA;
	Transperancy_RM[id] =			255;
	
	g_weapons_page[id] = 1;
	user_skip_time[id] = 1337.0;
	
	ResetPlayer(id);
}

public client_disconnect(id)
{
	if(chooser_b[id] != 0)
	{
		choose_b[chooser_b[id]-1]--;
		chooser_b[id] = 0;
		all_choose--;
	}
	
	if(g_voted[id]){
		g_count_voted--;
		g_voted[id] = 			false;
	}
	
	g_connected[id] =		false;
	g_alive[id] =			false;
	
	ClearGroup(id);
	
	if ( g_grabbed[id] )
	{
		if ( is_valid_ent(g_grabbed[id]) )
		{
			entity_set_int(g_grabbed[id], EV_INT_iuser2, 0);
		}
		
		g_grabbed[id] =			0;
	}
	
	g_checker_stuck[id] = 0;
}

CreateMenus()
{
	g_block_selection_pages_max = floatround((float(TOTAL_BLOCKS) / 8.0), floatround_ceil);
	
	new size = charsmax(g_weapons_menu);
	add(g_weapons_menu, size, "\r[%s] \y%s \rv%s^n^n");
	add(g_weapons_menu, size, "\r1. \wp228^n");
	add(g_weapons_menu, size, "\r2. \wScout^n");
	add(g_weapons_menu, size, "\r3. \wXm1014^n");
	add(g_weapons_menu, size, "\r4. \wMac10^n");
	add(g_weapons_menu, size, "\r5. \wAug^n");
	add(g_weapons_menu, size, "\r6. \wElite^n");
	add(g_weapons_menu, size, "\r7. \wFiveseven^n");
	add(g_weapons_menu, size, "\r8. \wUmp45^n^n");
	add(g_weapons_menu, size, "\r9. \wMore^n");
	add(g_weapons_menu, size, "\r0. \wClose");
	g_keys_weapons_menu =		B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9 | B0;
	
	size = charsmax(g_weapons_menu2);
	add(g_weapons_menu2, size, "\r[%s] \y%s \rv%s^n^n");
	add(g_weapons_menu2, size, "\r1. \wsg550^n");
	add(g_weapons_menu2, size, "\r2. \wgalil^n");
	add(g_weapons_menu2, size, "\r3. \wfamas^n");
	add(g_weapons_menu2, size, "\r4. \wusp^n");
	add(g_weapons_menu2, size, "\r5. \wglock^n");
	add(g_weapons_menu2, size, "\r6. \wawp^n");
	add(g_weapons_menu2, size, "\r7. \wmp5^n");
	add(g_weapons_menu2, size, "\r8. \wm249^n^n");
	add(g_weapons_menu2, size, "\r9. \wMore^n");
	add(g_weapons_menu2, size, "\r0. \wBack");
	g_keys_weapons_menu2 =		B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9 | B0;
	
	size = charsmax(g_weapons_menu3);
	add(g_weapons_menu3, size, "\r[%s] \y%s \rv%s^n^n");
	add(g_weapons_menu3, size, "\r1. \wm3^n");
	add(g_weapons_menu3, size, "\r2. \wm4a1^n");
	add(g_weapons_menu3, size, "\r3. \wtmp^n");
	add(g_weapons_menu3, size, "\r4. \wg3sg1^n");
	add(g_weapons_menu3, size, "\r5. \wdeagle^n");
	add(g_weapons_menu3, size, "\r6. \wsg552^n");
	add(g_weapons_menu3, size, "\r7. \wak47^n");
	add(g_weapons_menu3, size, "\r8. \wp90^n^n");
	add(g_weapons_menu3, size, "\r9. \wHelp^n");
	add(g_weapons_menu3, size, "\r0. \wBack");
	g_keys_weapons_menu3 =		B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9 | B0;
	
	size = charsmax(g_main_menu);
	add(g_main_menu, size, "\r[%s] \y%s \rv%s ^n^n\yby \rslavok1717^n^n");
	add(g_main_menu, size, "\r1. \wBlocks Menu^n");
	add(g_main_menu, size, "\r2. \wTeleports Menu^n");
	add(g_main_menu, size, "\r3. \wLights Menu^n");
	add(g_main_menu, size, "\r4. \wOptions Menu^n");
	add(g_main_menu, size, "\r5. \wCommands Menu^n^n");
	add(g_main_menu, size, "%s6. %sNoclip: %s^n");
	add(g_main_menu, size, "%s7. %sGodmode: %s^n^n");
	add(g_main_menu, size, "\r8. \yExtra Menu^n^n");
	add(g_main_menu, size, "\r9. \wHelp^n");
	add(g_main_menu, size, "\r0. \wClose");
	g_keys_main_menu =		B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9 | B0;
	
	size = charsmax(g_block_menu);
	add(g_block_menu, size, "\r[%s] \yBlock Menu^n^n");
	add(g_block_menu, size, "\r1. \wBlock Type: \y%s^n");
	add(g_block_menu, size, "\r2. \wBlock Size: \y%s^n^n");
	add(g_block_menu, size, "%s3. %sCreate^n");
	add(g_block_menu, size, "%s4. %sConvert^n");
	add(g_block_menu, size, "%s5. %sDelete^n");
	add(g_block_menu, size, "%s6. %sRotate^n");
	add(g_block_menu, size, "%s7. %sSet Properties^n");
	add(g_block_menu, size, "%s8. %sMove^n^n");
	add(g_block_menu, size, "\r0. \wBack");
	g_keys_block_menu =		B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B0;
	g_keys_block_selection_menu =	B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9 | B0;
	g_keys_properties_menu =	B1 | B2 | B3 | B4 | B0;
	
	size = charsmax(g_move_menu);
	add(g_move_menu, size, "\r[%s] \yMove Menu^n^n");
	add(g_move_menu, size, "\r1. \wGrid Size: \y%.1f^n^n");
	add(g_move_menu, size, "\r2. \wZ\y+^n");
	add(g_move_menu, size, "\r3. \wZ\r-^n");
	add(g_move_menu, size, "\r4. \wX\y+^n");
	add(g_move_menu, size, "\r5. \wX\r-^n");
	add(g_move_menu, size, "\r6. \wY\y+^n");
	add(g_move_menu, size, "\r7. \wY\r-^n^n^n");
	add(g_move_menu, size, "\r0. \wBack");
	g_keys_move_menu =		B1 | B2 | B3 | B4 | B5 | B6 | B7 | B0;
	
	size = charsmax(g_teleport_menu);
	add(g_teleport_menu, size, "\r[%s] \yTeleport Menu^n^n");
	add(g_teleport_menu, size, "%s1. %sCreate Start^n");
	add(g_teleport_menu, size, "%s2. %sCreate Destination^n^n");
	add(g_teleport_menu, size, "%s3. %sDelete Teleport^n^n");
	add(g_teleport_menu, size, "%s4. %sSwap Start/Destination^n^n");
	add(g_teleport_menu, size, "%s5. %sShow Path^n^n^n");
	add(g_teleport_menu, size, "\r0. \wBack");
	g_keys_teleport_menu =		B1 | B2 | B3 | B4 | B5 | B0;
	
	size = charsmax(g_light_menu);
	add(g_light_menu, size, "\r[%s] \yLight Menu^n^n");
	add(g_light_menu, size, "%s1. %sCreate Light^n");
	add(g_light_menu, size, "%s2. %sDelete Light^n^n");
	add(g_light_menu, size, "%s3. %sSet Properties^n^n^n^n^n^n^n");
	add(g_light_menu, size, "\r0. \wBack");
	g_keys_light_menu =		B1 | B2 | B3 | B0;
	
	size = charsmax(g_light_properties_menu);
	add(g_light_properties_menu, size, "\r[%s] \ySet Properties^n^n");
	add(g_light_properties_menu, size, "\r1. \wRadius: \y%s^n");
	add(g_light_properties_menu, size, "\r2. \wColor Red: \y%s^n");
	add(g_light_properties_menu, size, "\r3. \wColor Green: \y%s^n");
	add(g_light_properties_menu, size, "\r4. \wColor Blue: \y%s^n^n^n^n^n^n^n");
	add(g_light_properties_menu, size, "\r0. \wBack");
	g_keys_light_properties_menu =	B1 | B2 | B3 | B4 | B0;
	
	size = charsmax(g_options_menu);
	add(g_options_menu, size, "\r[%s] \yOptions Menu^n^n");
	add(g_options_menu, size, "%s1. %sSnapping: %s^n");
	add(g_options_menu, size, "%s2. %sSnapping Gap: \y%.1f^n^n");
	add(g_options_menu, size, "%s3. %sAdd to Group^n");
	add(g_options_menu, size, "%s4. %sClear Group^n^n");
	add(g_options_menu, size, "%s5. %sDelete All^n");
	add(g_options_menu, size, "%s6. %sSave^n");
	add(g_options_menu, size, "%s7. %sLoad^n^n^n^n^n");
	add(g_options_menu, size, "\r0. \wBack");
	g_keys_options_menu =		B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9 | B0;
	
	size = charsmax(g_choice_menu);
	add(g_choice_menu, size, "\y%s^n^n");
	add(g_choice_menu, size, "\r1. \wYes^n");
	add(g_choice_menu, size, "\r2. \wNo^n^n^n^n^n^n^n^n^n");
	g_keys_choice_menu =		B1 | B2;
	
	size = charsmax(g_commands_menu);
	add(g_commands_menu, size, "\r[%s] \yCommands Menu^n^n");
	add(g_commands_menu, size, "%s1. %sSave Checkpoint^n");
	add(g_commands_menu, size, "%s2. %sLoad Checkpoint^n^n");
	add(g_commands_menu, size, "%s3. %sRevive Yourself^n");
	add(g_commands_menu, size, "%s4. %sRevive Player^n");
	add(g_commands_menu, size, "%s5. %sRevive Everyone^n^n");
	add(g_commands_menu, size, "%s6. %s%s Godmode %s Everyone^n");
	add(g_commands_menu, size, "%s7. %sGive Access to %s^n^n");
	add(g_commands_menu, size, "\r0. \wBack");
	g_keys_commands_menu =		B1 | B2 | B3 | B4 | B5 | B6 | B7 | B0;
	
	size = charsmax(g_extra_menu);
	add(g_extra_menu, size, "\rExtra Menu^n^n");
	add(g_extra_menu, size, "\r1. \yRendering Menu^n");
	add(g_extra_menu, size, "\r2. \yMovement Menu^n");
	add(g_extra_menu, size, "\r3. \yRotate Menu^n");
	add(g_extra_menu, size, "\r4. \ySkip Menu^n^n^n^n^n^n");
	add(g_extra_menu, size, "\r0. \wBack");
	g_keys_extra_menu = B1 | B2 | B3 | B4 | B0;
	
	size = charsmax(gRenderMenu);
	add(gRenderMenu, size, "\rRendering Menu^n^n");
	add(gRenderMenu, size, "%s1. %sApply Render^n");
	add(gRenderMenu, size, "%s2. %sType Render: \r%s^n");
	add(gRenderMenu, size, "%s3. %sTransparency: \r%d^n");
	add(gRenderMenu, size, "%s4. %sRed: \r%d^n");
	add(gRenderMenu, size, "%s5. %sGreen: \r%d^n");
	add(gRenderMenu, size, "%s6. %sBlue: \r%d^n^n^n");
	add(gRenderMenu, size, "\r0. \wBack");
	gRenderMenuKeys = B1 | B2 | B3 | B4| B5 | B6 | B0;
	
	size = charsmax(g_movement_menu);
	add(g_movement_menu, size, "\rMovement Menu^n^n");
	add(g_movement_menu, size, "\r1. \rApply Movement^n");
	add(g_movement_menu, size, "\r2. \wDistance: \r%d^n");
	add(g_movement_menu, size, "\r3. \wAxis z: \r%d^n");
	add(g_movement_menu, size, "\r4. \wAxis x: \r%d^n");
	add(g_movement_menu, size, "\r5. \wAxis y: \r%d^n^n^n^n^n");
	add(g_movement_menu, size, "\r0. \wBack");
	g_keys_movement_menu = B1 | B2 | B3 | B4 | B5 | B0;
	
	size = charsmax(g_rotate_menu);
	add(g_rotate_menu, size, "\rRotate Menu^n^n");
	add(g_rotate_menu, size, "\r1. \wApply Rotate^n");
	add(g_rotate_menu, size, "\r2. \wDelete Rotate^n");
	add(g_rotate_menu, size, "\r3. \wTime Rotate: \r%.1f^n^n^n^n^n^n^n");
	add(g_rotate_menu, size, "\r0. \wBack");
	g_keys_rotate_menu = B1 | B2 | B3 | B0;
	
	size = charsmax(g_skip_menu);
	add(g_skip_menu, size, "\rSkip Menu^n^n");
	add(g_skip_menu, size, "\r1. \wApply Skip^n");
	add(g_skip_menu, size, "\r2. \wDelete Skip^n");
	add(g_skip_menu, size, "\r3. \wTime Skip: \r%s^n^n^n^n^n^n^n");
	add(g_skip_menu, size, "\r0. \wBack");
	g_keys_skip_menu = B1 | B2 | B3 | B0;
}

SetupBlockRendering(block_type, render_type, red, green, blue, alpha)
{
	g_render[block_type] =		render_type;
	g_red[block_type] =		red;
	g_green[block_type] =		green;
	g_blue[block_type] =		blue;
	g_alpha[block_type] =		alpha;
}

SetBlockModelName(model_target[256], model_source[256], const new_name[])
{
	model_target = model_source;
	replace(model_target, charsmax(model_target), "Normal", new_name);
}

public FwdPlayerSpawn(id)
{
	if ( !is_user_alive(id) ) return HAM_IGNORED;
	
	g_alive[id] =			true;
	
	if ( g_noclip[id] )		set_user_noclip(id, 1);
	if ( g_godmode[id] )		set_user_godmode(id, 1);
	
	if ( g_all_godmode )
	{
		for ( new i = 1; i <= g_max_players; i++ )
		{
			if ( !g_alive[i]
			|| (get_user_flags(i) & ADMIN_LEVEL_D)
			|| g_gived_access[i] ) continue;
			
			entity_set_float(i, EV_FL_takedamage, DAMAGE_NO);
		}
	}
	
	if ( g_viewing_commands_menu[id] ) ShowCommandsMenu(id);
	
	if ( !g_reseted[id] )
	{
		ResetPlayer(id);
	}
	
	g_reseted[id] =			false;
	
	return HAM_IGNORED;
}

public FwdPlayerKilled(id)
{
	g_alive[id] = bool:is_user_alive(id);
	
	ResetPlayer(id);
	
	if ( g_viewing_commands_menu[id] ) ShowCommandsMenu(id);
}

public FwdCmdStart(id, handle)
{
	if ( !g_connected[id] ) return FMRES_IGNORED;
	
	static buttons, oldbuttons;
	buttons =	get_uc(handle, UC_Buttons);
	oldbuttons =	entity_get_int(id, EV_INT_oldbuttons);
	
	if ( g_alive[id]
	&& ( buttons & IN_USE )
	&& !( oldbuttons & IN_USE ))
	{
		static ent, body;
		get_user_aiming(id, ent, body, 9999);
		
		if ( IsBlock(ent) )
		{
			static block_type;
			block_type = entity_get_int(ent, EV_INT_body);
			
			static property[14];
			
			static message[512], len;
			len = format(message, charsmax(message), "%s^nType: %s", PLUGIN_NAME, g_block_names[block_type]);
			
			if ( g_property1_name[block_type][0] )
			{
				GetProperty(ent, 1, property);
				
				if ( ( block_type == BUNNYHOP
				|| block_type == NO_SLOW_DOWN_BUNNYHOP
				|| block_type == BUNNYHOP_D )
				&& property[0] == '1' )
				{
					len += format(message[len], charsmax(message) - len, "^n%s", g_property1_name[block_type]);
				}
				else if ( block_type == CARPET )
				{
					len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property1_name[block_type], property[0] == '6' ? "All" : property[0] == '5' ? "No Vips" : property[0] == '4' ? "Only Vips" : property[0] == '3' ? "Counter-Terrorists" : property[0] == '2' ? "Terrorists" : "Off");
				}
				else if ( block_type == POINT_BLOCK )
				{
					len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property1_name[block_type], property[0]);
				}
				else if ( block_type == SLAP )
				{
					len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property1_name[block_type], property[0] == '3' ? "High" : property[0] == '2' ? "Medium" : "Low");
				}
				else if ( block_type == CT_BARRIER )
				{
					len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property1_name[block_type], property[0] == '3' ? "No_CT_and_Vips" : property[0] == '2' ? "Only_T_and_Vips" : "Normal");
				}
				else if ( block_type == T_BARRIER )
				{
					len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property1_name[block_type], property[0] == '3' ? "No_T_and_Vips" : property[0] == '2' ? "Only_CT_and_Vips" : "Normal");
				}
				else if ( block_type == VIP_BARRIER )
				{
					len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property1_name[block_type], property[0] == '2' ? "No Vips" : "Vips only");
				}
				else if ( block_type == GRANATA )
				{
					len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property1_name[block_type], property[0] == '4' ? "All Grenades" : property[0] == '3' ? "Flashbang" : property[0] == '2' ? "Smokegrenade" : "Hegrenade");
				}
				else if(block_type == WEAPON)
				{
					len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property1_name[block_type], property[0]);
				}
				else if(block_type == BLIND_TRAP)
				{
					len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property1_name[block_type], property[0] == '2' ? "No Flashed Vips" : "Flashed all");
				}
				else if(block_type == EARTHQUAKE)
				{
					len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property1_name[block_type], property[0] == '2' ? "No Earthquake Vips" : "Earthquake all");
				}
				else if ( block_type != BUNNYHOP
				&& block_type != BUNNYHOP_D 
				&& block_type != NO_SLOW_DOWN_BUNNYHOP )
				{
					len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property1_name[block_type], property);
				}
			}
			
			if ( g_property2_name[block_type][0] )
			{
				GetProperty(ent, 2, property);
				
				if (block_type == POINT_BLOCK)
				{
					len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property2_name[block_type], property);
				}
				else if (block_type == CARPET)
				{
					len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property2_name[block_type], property[0] == '0' ? "No" : property);
				}
				else
				{	
					len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property2_name[block_type], property);
				}
			}
			
			if ( g_property3_name[block_type][0] )
			{
				GetProperty(ent, 3, property);
				
				len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property3_name[block_type], property);
			}
			
			if ( g_property4_name[block_type][0] )
			{
				GetProperty(ent, 4, property);
				
				if(block_type != CARPET){
					len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property4_name[block_type], property[0] == '1' ? "Yes" : "No");
				}else{
					len += format(message[len], charsmax(message) - len, "^n%s: %d", g_property4_name[block_type], str_to_num(property));
				}
			}
			
			if(ent_skip_time[ent] != 1337.0 && ent_skip_time[ent] > 0.0)
			{
				len += format(message[len], charsmax(message) - len, "^nSkip Time: %.1f", ent_skip_time[ent]);
			}else if(ent_skip_time[ent] == 1337.0){
				len += format(message[len], charsmax(message) - len, "^nSkip Time: instantly");
			}
			
			if(ent_rotate_time[ent] > 0.0)
			{
				len += format(message[len], charsmax(message) - len, "^nRotate Time: %.1f", ent_rotate_time[ent]);
			}
			
			if(Transperancy[ent] < 255)
			{
				len += format(message[len], charsmax(message) - len, "^n^nTransperancy: %d", Transperancy[ent]);
			}
			
			set_hudmessage(0, 127, 255, 0.45, 0.03, 0, 0.0, 1.0, 0.25, 0.25, 2);
			show_hudmessage(id, message);
		}
		else if ( IsLight(ent) )
		{
			static property1[5], property2[5], property3[5], property4[5];
			
			GetProperty(ent, 1, property1);
			GetProperty(ent, 2, property2);
			GetProperty(ent, 3, property3);
			GetProperty(ent, 4, property4);
			
			set_hudmessage(0, 127, 255, 0.45, 0.03, 0, 0.0, 1.0, 0.25, 0.25, 2);
			show_hudmessage(id, "%s^nType: Light^nRadius: %s^nColor Red: %s^nColor Green: %s^nColor Blue: %s", PLUGIN_NAME, property1, property2, property3, property4);
		}
	}
	
	if ( !g_grabbed[id] ) return FMRES_IGNORED;
	
	if ( ( buttons & IN_JUMP )
	&& !( oldbuttons & IN_JUMP ) ) if ( g_grab_length[id] > 72.0 ) g_grab_length[id] -= 16.0;
	
	if ( ( buttons & IN_DUCK )
	&& !( oldbuttons & IN_DUCK ) ) g_grab_length[id] += 16.0;
	
	if ( ( buttons & IN_ATTACK )
	&& !( oldbuttons & IN_ATTACK ) ) CmdAttack(id);
	
	if ( ( buttons & IN_ATTACK2 )
	&& !( oldbuttons & IN_ATTACK2 ) ) CmdAttack2(id);
	
	if ( ( buttons & IN_RELOAD )
	&& !( oldbuttons & IN_RELOAD ) )
	{
		CmdRotate(id);
		set_uc(handle, UC_Buttons, buttons & ~IN_RELOAD);
	}
	
	if ( !is_valid_ent(g_grabbed[id]) )
	{
		CmdRelease(id);
		return FMRES_IGNORED;
	}
	
	if ( !IsBlockInGroup(id, g_grabbed[id])
	|| g_group_count[id] < 1 )
	{
		MoveGrabbedEntity(id);
		return FMRES_IGNORED;
	}
	
	static block;
	static Float:move_to[3];
	static Float:offset[3];
	static Float:origin[3];
	
	MoveGrabbedEntity(id, move_to);
	
	for ( new i = 0; i <= g_group_count[id]; ++i )
	{
		block = g_grouped_blocks[id][i];
		
		if ( !IsBlockInGroup(id, block) ) continue;
		
		entity_get_vector(block, EV_VEC_vuser1, offset);
		
		origin[0] = move_to[0] - offset[0];
		origin[1] = move_to[1] - offset[1];
		origin[2] = move_to[2] - offset[2];
		
		MoveEntity(id, block, origin, false);
	}
	
	return FMRES_IGNORED;
}

public EventCurWeapon(id)
{
	static block, property[5];
	new Float:gametime = get_gametime();
	new Float:time_out = g_boots_of_speed_time_out[id] - gametime;
	
	if(g_honey[id]){
		block = g_honey[id];
		GetProperty(block, 1, property);
		entity_set_float(id, EV_FL_maxspeed, str_to_float(property));
	}else if (time_out >= 0.0){
		GetProperty(block, 3, property);
		entity_set_float(id, EV_FL_maxspeed, str_to_float(property));
	}else if(sgpm_boots_is_activated(id) || g_ice[id]){
		entity_set_float(id, EV_FL_maxspeed, 400.0);
	}else{
		ResetMaxspeed(id);
	}
}

public pfn_touch(ent, id){
	if(!( 1 <= id <= g_max_players )
	|| !IsBlock(ent)) return PLUGIN_CONTINUE;
	
	new block_type = entity_get_int(ent, EV_INT_body);
	new flags =		entity_get_int(id, EV_INT_flags);
	new groundentity =	entity_get_edict(id, EV_ENT_groundentity);
	
	static property[5];
	GetProperty(ent, 4, property);
	
	if ( property[0] == '0'
	|| ( ( !property[0]
		|| property[0] == '1'
		|| property[0] == '/')
	&& flags & FL_ONGROUND 
	&& groundentity == ent ) || block_type == CARPET )
	{
		if(ent_skip_time[ent] > 0.0 && ent_skip_time[ent] != 1337){
			g_should_show_skip_time_mess[id] = get_gametime() + 0.1;
			g_should_show_skip_time_ent[id] = ent;
			
			if(!task_exists(TASK_SOLID_NOT + ent) && !task_exists(TASK_SOLID + ent)){
				ent_skip_time_start[ent] = get_gametime() + ent_skip_time[ent];
				set_task(ent_skip_time[ent], "TaskSolidNot", TASK_SOLID_NOT + ent);
			}
		}else if(ent_skip_time[ent] == 1337){
			ent_skip_time_start[ent] = 0.0;
			TaskSolidNot(TASK_SOLID_NOT + ent);
		}
		
		if(ent_rotate_time[ent] > 0.0){
			g_should_show_rotate_time_mess[id] = get_gametime() + 0.1;
			g_should_show_rotate_time_ent[id] = ent;
		}
		
		switch ( block_type )
		{
			case PLATFORM:				return PLUGIN_CONTINUE;
			case BUNNYHOP_D:			ActionBhopD(id, ent);
			case DAMAGE:				ActionDamage(id, ent);
			case HEALER:				ActionHeal(id, ent);
			case TRAMPOLINE:			ActionTrampoline(id, ent);
			case SPEED_BOOST:			ActionSpeedBoost(id, ent);
			case DEATH:
			{
				if ( !get_user_godmode(id) )
				{
					fakedamage(id, "The Block of Death", 10000.0, DMG_GENERIC);
				}
			}
			case SLAP:
			{
				GetProperty(ent, 1, property);
				g_slap_times[id] = str_to_num(property) * 2;
			}
			case LOW_GRAVITY:			ActionLowGravity(id, ent);
			case HONEY:					ActionHoney(id, ent);
			case CT_BARRIER:			ActionCTBarrier(id, ent);
			case T_BARRIER:				ActionTBarrier(id, ent);
			case VIP_BARRIER:			ActionABarrier(id, ent);
			case DELAYED_BUNNYHOP:		ActionDelayedBhop(ent);
			case STEALTH:				ActionStealth(id, ent);
			case INVINCIBILITY:			ActionInvincibility(id, ent);
			case BOOTS_OF_SPEED:		ActionBootsOfSpeed(id, ent);
			case CAMOUFLAGE:			ActionCamouflage(id,ent);
			case WEAPON:				ActionWeapon(id,ent);
			case WEAPON_CHANCE:			ActionWeapon_chance(id, ent);
			case GRANATA:				ActionGranata(id, ent);
			case MUSIC:					ActionMusic(id, ent);
			case DOUBLE_DUCK:			ActionDuck(id);
			case BLIND_TRAP:			ActionBlindTrap(id, ent);
			case EARTHQUAKE:			ActionEarthquake(id, ent);
			case CARPET:				ActionMagicCarpet(id, ent);
			case POINT_BLOCK:			ActionPointBlock(id, ent);
			case RANDOM:				ActionRandomBlock(id, ent);
			case BUNNYHOP:
			{
				ActionBhop(ent);
				
				GetProperty(ent, 1, property);
				if ( property[0] == '1' )
				{
					g_no_fall_damage[id] = true;
				}
			}
			case NO_FALL_DAMAGE:			g_no_fall_damage[id] = true;
			case ICE:						ActionIce(id);
			case NO_SLOW_DOWN_BUNNYHOP:
			{
				ActionBhop(ent);
				ActionNoSlowDown(id);
				
				GetProperty(ent, 1, property);
				if ( property[0] == '1' )
				{
					g_no_fall_damage[id] = true;
				}
			}
		}
	}
	
	return PLUGIN_CONTINUE;
}

public server_frame()
{
	static ent, entinsphere;
	static Float:origin[3];
	
	for ( new id = 1; id <= g_max_players; ++id )
	{
		if ( !g_alive[id] ) continue;
		
		if ( g_ice[id] || g_no_slow_down[id] )
		{
			entity_set_float(id, EV_FL_fuser2, 0.0);
		}
		
		if ( g_set_velocity[id][0] != 0.0
		|| g_set_velocity[id][1] != 0.0
		|| g_set_velocity[id][2] != 0.0 )
		{
			entity_set_vector(id, EV_VEC_velocity, g_set_velocity[id]);
			
			g_set_velocity[id][0] = 0.0;
			g_set_velocity[id][1] = 0.0;
			g_set_velocity[id][2] = 0.0;
		}
		
		if ( g_low_gravity[id] )
		{
			if ( entity_get_int(id, EV_INT_flags) & FL_ONGROUND )
			{
				entity_set_float(id, EV_FL_gravity, 1.0);
				g_low_gravity[id] = false;
			}
		}
		
		while ( g_slap_times[id] )
		{
			user_slap(id, 0);
			g_slap_times[id]--;
		}
		
		entity_get_vector(id, EV_VEC_origin, origin); 
		entinsphere = -1;
		
		while ( ( entinsphere = find_ent_in_sphere(entinsphere, origin, 20.00) ) ){
			if (1 <= entinsphere <= g_max_players && g_alive[entinsphere] && entinsphere != id && get_user_team(id) == get_user_team(entinsphere)){
				g_checker_stuck[id] = 0;
				g_checker_stuck[entinsphere] = 0;
			}
		}
	}
	
	while ( ( ent = find_ent_by_class(ent, g_start_classname) ) )
	{
		if ( get_gametime() >= entity_get_float(ent, EV_FL_ltime) )
		{
			entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
		}
		
		entity_get_vector(ent, EV_VEC_origin, origin);
		
		entinsphere = -1;
		while ( ( entinsphere = find_ent_in_sphere(entinsphere, origin, 50.0) ) )
		{
			static classname[32];
			entity_get_string(entinsphere, EV_SZ_classname, classname, charsmax(classname));
			
			if ( 1 <= entinsphere <= g_max_players && g_alive[entinsphere] || equal(classname, "grenade"))
			{
				entity_set_int(ent, EV_INT_solid, SOLID_NOT);
				entity_set_float(ent, EV_FL_ltime, get_gametime() + 2.0);
				
				new teleport_end = entity_get_int(ent, EV_INT_iuser1);
				entity_set_int(teleport_end, EV_INT_solid, SOLID_NOT);
				entity_set_float(teleport_end, EV_FL_ltime, get_gametime() + 2.0);
				
				ActionTeleport(entinsphere, ent);
			}
		}
	}
	
	static bool:ent_near;
	ent_near = false;
	
	while ( ( ent = find_ent_by_class(ent, g_destination_classname) ) )
	{
		if ( get_gametime() >= entity_get_float(ent, EV_FL_ltime) )
		{
			entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
		}
		
		entity_get_vector(ent, EV_VEC_origin, origin);
		
		entinsphere = -1;
		while ( ( entinsphere = find_ent_in_sphere(entinsphere, origin, 64.0) ) )
		{
			static classname[32];
			entity_get_string(entinsphere, EV_SZ_classname, classname, charsmax(classname));
			
			if ( 1 <= entinsphere <= g_max_players && g_alive[entinsphere]
			|| equal(classname, "grenade") )
			{
				ent_near = true;
				break;
			}
		}
		
		if ( ent_near )
		{
			if ( !entity_get_int(ent, EV_INT_iuser2) )
			{
				entity_set_int(ent, EV_INT_solid, SOLID_NOT);
				entity_set_float(ent, EV_FL_ltime, get_gametime() + 1.0);
			}
		}
	}
}

public client_PostThink(id)
{
	if ( !g_alive[id] ) return PLUGIN_CONTINUE;
	
	if ( g_no_fall_damage[id] )
	{
		entity_set_int(id,  EV_INT_watertype, -3);
		g_no_fall_damage[id] = false;
	}
	
	return PLUGIN_CONTINUE;
}

ActionGranata(id,ent) 
{
	new CsTeams:playerTeam = cs_get_user_team(id);
	if(is_user_alive(id) && playerTeam == CS_TEAM_T)
	{
		static property[5];
		GetProperty(ent, 1, property);
		switch ( property[0] )
		{
			case '1':
			{
				if(!HeUsed [id])
				{
					if ( cs_get_user_bpammo(id, CSW_HEGRENADE) > 0 )
					{
						return PLUGIN_HANDLED;
					}
					
					GetProperty(ent, 2, property);
					new counter_n = str_to_num(property);
					
					give_item(id, "weapon_hegrenade");
					cs_set_user_bpammo(id, CSW_HEGRENADE, counter_n);
					
					HeUsed[id] = true;
					
					BCM_Print(id, "^3You got a ^4HE Grenades^3!");
				}
				else if (HeUsed[id])
				{
					g_greandes_mess_time_he[id] = get_gametime() + 0.1;
				}
			}
			case '2':
			{
				if(!SmokeUsed[id])
				{
					if ( cs_get_user_bpammo(id, CSW_SMOKEGRENADE) > 0 )
					{
						return PLUGIN_HANDLED;
					}
					
					GetProperty(ent, 2, property);
					new counter_n = str_to_num(property);
					
					give_item(id, "weapon_smokegrenade");
					cs_set_user_bpammo(id, CSW_SMOKEGRENADE, counter_n);
					
					SmokeUsed[id] = true;
					
					BCM_Print(id, "^3You got a ^4Smoke Grenades^3!");
				}
				else{
					g_greandes_mess_time_fn[id] = get_gametime() + 0.1;
				}
			}
			case '3':
			{
				if(!FlashUsed[id])
				{
					if ( cs_get_user_bpammo(id, CSW_FLASHBANG) > 0 )
					{
						return PLUGIN_HANDLED;
					}
					
					GetProperty(ent, 2, property);
					new counter_n = str_to_num(property);
					
					give_item(id, "weapon_flashbang");
					cs_set_user_bpammo(id, CSW_FLASHBANG, counter_n);
					
					FlashUsed[id] = true;
					
					BCM_Print(id, "^3You got a ^4Flash Grenades^3!");
				}
				else{
					g_greandes_mess_time_fb[id] = get_gametime() + 0.1;
				}
			}
			case '4':
			{
				if(!AllGrenadesUsed[id])
				{
					if ( cs_get_user_bpammo(id, CSW_HEGRENADE) > 0 )
					{
						return PLUGIN_HANDLED;
					}
					if ( cs_get_user_bpammo(id, CSW_FLASHBANG) > 0 )
					{
						return PLUGIN_HANDLED;
					}
					if ( cs_get_user_bpammo(id, CSW_SMOKEGRENADE) > 0 )
					{
						return PLUGIN_HANDLED;
					}
					
					GetProperty(ent, 2, property);
					new counter_n = str_to_num(property);
					
					give_item(id, "weapon_hegrenade");
					cs_set_user_bpammo(id, CSW_HEGRENADE, counter_n);
					give_item(id, "weapon_flashbang");
					cs_set_user_bpammo(id, CSW_FLASHBANG, counter_n);
					give_item(id, "weapon_smokegrenade");
					cs_set_user_bpammo(id, CSW_SMOKEGRENADE, counter_n);
					
					AllGrenadesUsed[id] = true;
					
					BCM_Print(id, "^3You got an ^4All Grenades^3!");
				}
				else{
					g_greandes_mess_time_all[id] = get_gametime() + 0.1;
				}
			}
		}	
	}
	
	return PLUGIN_HANDLED;
}


ActionBhop(ent)
{
	if ( task_exists(TASK_SOLID_NOT + ent)
	|| task_exists(TASK_SOLID + ent) ) return PLUGIN_HANDLED;
	
	set_task(0.1, "TaskSolidNot", TASK_SOLID_NOT + ent);
	
	return PLUGIN_HANDLED;
}

ActionWeapon(id, ent){
	if(is_user_alive(id) && is_user_connected(id) && get_user_team(id) == 1)
	{
		new property[12];
		new weapon = GetProperty(ent, 1, property);
		new szWeapon[32];
		format(szWeapon, 31, "weapon_%s", weapon);
		replace_all(szWeapon, 31, "", "");
		new Weapons[32], Num;
			
		new equal_f[12];
		GetProperty(ent, 1, equal_f);
		
		g_weapons_mess_time[id] = get_gametime() + 0.1;
		
		if(equal(equal_f, "p228") && WeaponUsed[0][id]){
			format(g_weapons_text_mess[id], 11, "(p228)");
			return PLUGIN_CONTINUE;
		}
		else if(equal(equal_f, "scout") && WeaponUsed[1][id]){
			format(g_weapons_text_mess[id], 11, "(scout)");
			return PLUGIN_CONTINUE;
		}
		else if(equal(equal_f, "xm1014") && WeaponUsed[2][id]){
			format(g_weapons_text_mess[id], 11, "(xm1014)");
			return PLUGIN_CONTINUE;
		}
		else if(equal(equal_f, "mac10") && WeaponUsed[3][id]){
			format(g_weapons_text_mess[id], 11, "(mac10)");
			return PLUGIN_CONTINUE;
		}
		else if(equal(equal_f, "aug") && WeaponUsed[4][id]){
			format(g_weapons_text_mess[id], 11, "(aug)");
			return PLUGIN_CONTINUE;
		}
		else if(equal(equal_f, "elite") && WeaponUsed[5][id]){
			format(g_weapons_text_mess[id], 11, "(elite)");
			return PLUGIN_CONTINUE;
		}
		else if(equal(equal_f, "fiveseven") && WeaponUsed[6][id]){
			format(g_weapons_text_mess[id], 11, "(fiveseven)");
			return PLUGIN_CONTINUE;
		}
		else if(equal(equal_f, "ump45") && WeaponUsed[7][id]){
			format(g_weapons_text_mess[id], 11, "(ump45)");
			return PLUGIN_CONTINUE;
		}
		else if(equal(equal_f, "sg550") && WeaponUsed[8][id]){
			format(g_weapons_text_mess[id], 11, "(sg550)");
			return PLUGIN_CONTINUE;
		}
		else if(equal(equal_f, "galil") && WeaponUsed[9][id]){
			format(g_weapons_text_mess[id], 11, "(galil)");
			return PLUGIN_CONTINUE;
		}
		else if(equal(equal_f, "famas") && WeaponUsed[10][id]){
			format(g_weapons_text_mess[id], 11, "(famas)");
			return PLUGIN_CONTINUE;
		}
		else if(equal(equal_f, "usp") && WeaponUsed[11][id]){
			format(g_weapons_text_mess[id], 11, "(usp)");
			return PLUGIN_CONTINUE;
		}
		else if(equal(equal_f, "glock18") && WeaponUsed[12][id]){
			format(g_weapons_text_mess[id], 11, "(glock18)");
			return PLUGIN_CONTINUE;
		}
		else if(equal(equal_f, "awp") && WeaponUsed[13][id]){
			format(g_weapons_text_mess[id], 11, "(awp)");
			return PLUGIN_CONTINUE;
		}
		else if(equal(equal_f, "mp5navy") && WeaponUsed[14][id]){
			format(g_weapons_text_mess[id], 11, "(mp5navy)");
			return PLUGIN_CONTINUE;
		}
		else if(equal(equal_f, "m249") && WeaponUsed[15][id]){
			format(g_weapons_text_mess[id], 11, "(m249)");
			return PLUGIN_CONTINUE;
		}
		else if(equal(equal_f, "m3") && WeaponUsed[16][id]){
			format(g_weapons_text_mess[id], 11, "(m3)");
			return PLUGIN_CONTINUE;
		}
		else if(equal(equal_f, "m4a1") && WeaponUsed[17][id]){
			format(g_weapons_text_mess[id], 11, "(m4a1)");
			return PLUGIN_CONTINUE;
		}
		else if(equal(equal_f, "tmp") && WeaponUsed[18][id]){
			format(g_weapons_text_mess[id], 11, "(tmp)");
			return PLUGIN_CONTINUE;
		}
		else if(equal(equal_f, "g3sg1") && WeaponUsed[19][id]){
			format(g_weapons_text_mess[id], 11, "(g3sg1)");
			return PLUGIN_CONTINUE;
		}
		else if(equal(equal_f, "deagle") && WeaponUsed[20][id]){
			format(g_weapons_text_mess[id], 11, "(deagle)");
			return PLUGIN_CONTINUE;
		}
		else if(equal(equal_f, "sg552") && WeaponUsed[21][id]){
			format(g_weapons_text_mess[id], 11, "(sg552)");
			return PLUGIN_CONTINUE;
		}
		else if(equal(equal_f, "ak47") && WeaponUsed[22][id]){
			format(g_weapons_text_mess[id], 11, "(ak47)");
			return PLUGIN_CONTINUE;
		}
		else if(equal(equal_f, "p90") && WeaponUsed[23][id]){
			format(g_weapons_text_mess[id], 11, "(p90)");
			return PLUGIN_CONTINUE;
		}
				
		if (!(get_user_weapons(id, Weapons, Num)&(1<<get_weaponid(szWeapon))))
		{	
			g_weapons_mess_time[id] = 0.0;
			
			give_item(id, szWeapon);
			GetProperty(ent, 2, property);
			new bullets = str_to_num(property);
			cs_set_weapon_ammo(find_ent_by_owner(-1, szWeapon, id), bullets);
			
			if(equal(equal_f, "p228")) WeaponUsed[0][id] = true;
			else if(equal(equal_f, "scout")) WeaponUsed[1][id] = true;
			else if(equal(equal_f, "xm1014")) WeaponUsed[2][id] = true;
			else if(equal(equal_f, "mac10")) WeaponUsed[3][id] = true;
			else if(equal(equal_f, "aug")) WeaponUsed[4][id] = true;
			else if(equal(equal_f, "elite")) WeaponUsed[5][id] = true;
			else if(equal(equal_f, "fiveseven")) WeaponUsed[6][id] = true;
			else if(equal(equal_f, "ump45")) WeaponUsed[7][id] = true;
			else if(equal(equal_f, "sg550")) WeaponUsed[8][id] = true;
			else if(equal(equal_f, "galil")) WeaponUsed[9][id] = true;
			else if(equal(equal_f, "famas")) WeaponUsed[10][id] = true;
			else if(equal(equal_f, "usp")) WeaponUsed[11][id] = true;
			else if(equal(equal_f, "glock18")) WeaponUsed[12][id] = true;
			else if(equal(equal_f, "awp")) WeaponUsed[13][id] = true;
			else if(equal(equal_f, "mp5navy")) WeaponUsed[14][id] = true;
			else if(equal(equal_f, "m249")) WeaponUsed[15][id] = true;
			else if(equal(equal_f, "m3")) WeaponUsed[16][id] = true;
			else if(equal(equal_f, "m4a1")) WeaponUsed[17][id] = true;
			else if(equal(equal_f, "tmp")) WeaponUsed[18][id] = true;
			else if(equal(equal_f, "g3sg1")) WeaponUsed[19][id] = true;
			else if(equal(equal_f, "deagle")) WeaponUsed[20][id] = true;
			else if(equal(equal_f, "sg552")) WeaponUsed[21][id] = true;
			else if(equal(equal_f, "ak47")) WeaponUsed[22][id] = true;
			else if(equal(equal_f, "p90")) WeaponUsed[23][id] = true;
			
			GetProperty(ent, 1, property);
			
			BCM_Print(id, "^3You got a ^4%s^3 with ^4%d^3 bullet(s)!", property , bullets);
		}
	}
	
	return PLUGIN_CONTINUE;
}

ActionWeapon_chance(id,ent)
{
	if(is_user_alive(id) && is_user_connected(id) && get_user_team(id) == 1)
	{
		new Float:gametime = get_gametime();
		if ( !( gametime >= g_weapon_chance_next_use[id] ) ){
			g_weapon_chance_next_use_mess[id] = get_gametime() + 0.1;
			return PLUGIN_HANDLED;
		}
		
		new procents;
		static property[5];
		static weapon[32];
		static weapon2[32];
		static CSWweapon;
	
		new random_bullets, item_chance = pm_level_weapon_chance(id);
	
		if(random_num(1,4) <= 3)
		{
			random_bullets = 1;
		}
		else
		{
			random_bullets = 2;
		}
		
		if(random_num(1,100) <= 3 + item_chance && !ChanceUsed[id] && !WeaponUsed[13][id])
		{
			procents = 3;
			weapon = "awp";
			CSWweapon = CSW_AWP;
			ChanceUsed[id] = true;
			
			WeaponUsed[13][id] = true;
		}
		if(random_num(1,100) <= 5 + item_chance && !ChanceUsed[id] && !WeaponUsed[1][id])
		{
			procents = 5;
			weapon = "scout";
			CSWweapon = CSW_SCOUT;
			ChanceUsed[id] = true;
			
			WeaponUsed[1][id] = true;
		}
		if(random_num(1,100) <= 10 + item_chance && !ChanceUsed[id] && !WeaponUsed[15][id])
		{
			procents = 10;
			weapon = "m249";
			CSWweapon = CSW_M249;
			ChanceUsed[id] = true;
			
			WeaponUsed[15][id] = true;
		}
		if(random_num(1,100) <= 15 + item_chance && !ChanceUsed[id] && !WeaponUsed[17][id])
		{
			procents = 15;
			weapon = "m4a1";
			CSWweapon = CSW_M4A1;
			ChanceUsed[id] = true;
			
			WeaponUsed[17][id] = true;
		}
		if(random_num(1,100) <= 15 + item_chance && !ChanceUsed[id] && !WeaponUsed[22][id])
		{
			procents = 15;
			weapon = "ak47";
			CSWweapon = CSW_AK47;
			ChanceUsed[id] = true;
			
			WeaponUsed[22][id] = true;
		}
		if(random_num(1,100) <= 16 + item_chance && !ChanceUsed[id] && !WeaponUsed[16][id]) 
		{
			procents = 16;
			weapon = "m3";
			CSWweapon = CSW_M3;
			ChanceUsed[id] = true;
			
			WeaponUsed[16][id] = true;
		}
		if(random_num(1,100) <= 16 + item_chance && !ChanceUsed[id] && !WeaponUsed[10][id])
		{
			procents = 16;
			weapon = "famas";
			CSWweapon = CSW_FAMAS;
			ChanceUsed[id] = true;
			
			WeaponUsed[10][id] = true;
		}
		if(random_num(1,100) <= 16 + item_chance && !ChanceUsed[id] && !WeaponUsed[9][id])
		{
			procents = 16;
			weapon = "galil";
			CSWweapon = CSW_GALIL;
			ChanceUsed[id] = true;
			
			WeaponUsed[9][id] = true;
		}
		if(random_num(1,100) <= 17 + item_chance && !ChanceUsed[id] && !WeaponUsed[4][id])
		{
			procents = 17;
			weapon = "aug";
			CSWweapon = CSW_AUG;
			ChanceUsed[id] = true;
			
			WeaponUsed[4][id] = true;
		}
		if(random_num(1,100) <= 18 + item_chance && !ChanceUsed[id] && !WeaponUsed[23][id])
		{
			procents = 18;
			weapon = "p90";
			CSWweapon = CSW_P90;
			ChanceUsed[id] = true;
			
			WeaponUsed[23][id] = true;
		}
		if(random_num(1,100) <= 20 + item_chance && !ChanceUsed[id] && !WeaponUsed[20][id])
		{
			procents = 20;
			weapon = "deagle";
			CSWweapon = CSW_DEAGLE;
			ChanceUsed[id] = true;
			
			WeaponUsed[20][id] = true;
		}
		if(random_num(1,100) <= 22 + item_chance && !ChanceUsed[id] && !WeaponUsed[6][id])
		{
			procents = 22;
			weapon = "fiveseven";
			CSWweapon = CSW_FIVESEVEN;
			ChanceUsed[id] = true;
			
			WeaponUsed[6][id] = true;
		}
		if(random_num(1,100) <= 24 + item_chance && !ChanceUsed[id] && !WeaponUsed[11][id])
		{
			procents = 24;
			weapon = "usp";
			CSWweapon = CSW_USP;
			ChanceUsed[id] = true;
			
			WeaponUsed[11][id] = true;
		}
		if(random_num(1,100) <= 25 + item_chance && !ChanceUsed[id] && !WeaponUsed[12][id])
		{
			procents = 25;
			weapon = "glock18";
			CSWweapon = CSW_GLOCK18;
			ChanceUsed[id] = true;
			
			WeaponUsed[12][id] = true;
		}
		if(random_num(1,100) <= 30 + item_chance && !ChanceUsed[id] && !WeaponUsed[5][id])
		{
			procents = 30;
			weapon = "elite";
			CSWweapon = CSW_ELITE;
			ChanceUsed[id] = true;
			
			WeaponUsed[5][id] = true;
		}
		if(random_num(1,100) <= 35 + item_chance && !ChanceUsed[id] && !WeaponUsed[0][id])
		{
			procents = 35;
			weapon = "p228";
			CSWweapon = CSW_P228;
			ChanceUsed[id] = true;
			
			WeaponUsed[0][id] = true;
		}
	
		format(weapon2, 31, "weapon_%s", weapon);
	
		if(ChanceUsed[id])
		{
			if( !user_has_weapon(id, CSWweapon) )
			{
				give_item(id, weapon2);
			}
	
			new weapon_id = find_ent_by_owner(-1, weapon2, id);
		
			if(weapon_id)
			{
				cs_set_weapon_ammo(weapon_id, random_bullets);
			}
			
			cs_set_user_bpammo(id, CSWweapon, 0);
			
			if(item_chance == 0)
				BCM_Print(id, "^3You recieved a ^4%s^3 with ^4%d^3 bullet(s)! (^4%d^3%% chance)", weapon, random_bullets, procents);
			else
				BCM_Print(id, "^3You recieved a ^4%s^3 with ^4%d^3 bullet(s)! (^4%d^3%% + ^4%d^3%% chance)", weapon, random_bullets, procents, item_chance);
		}
		else
		{
			BCM_Print(id, "^3You received nothing...");
		}
		
		GetProperty(ent, 1, property);
		g_weapon_chance_next_use[id] = gametime + str_to_float(property);
	
		ChanceUsed[id] = false;
	}
	
	return PLUGIN_HANDLED;
}

ActionBhopD(id, ent)
{
	new Float:gametime = get_gametime();
	if ( !( gametime >= g_next_damage_time[id] )
	|| get_user_health(id) <= 0
	|| get_user_godmode(id) )
	{
		ActionBhop(ent);
		return PLUGIN_HANDLED;
	}
	
	static property[5];
	
	GetProperty(ent, 1, property);
	if ( property[0] == '1' )
	{
			g_no_fall_damage[id] = true;
	}
	
	GetProperty(ent, 2, property);
	fakedamage(id, "Damage Block2", str_to_float(property), DMG_CRUSH);
	
	g_next_damage_time[id] = halflife_time() + 0.5;
	
	if ( task_exists(TASK_SOLID_NOT + ent)
	|| task_exists(TASK_SOLID + ent) ) return PLUGIN_HANDLED;
	
	set_task(0.1, "TaskSolidNot", TASK_SOLID_NOT + ent);
	
	return PLUGIN_HANDLED;
}


ActionDamage(id, ent)
{
	new Float:gametime = get_gametime();
	if ( !( gametime >= g_next_damage_time[id] )
	|| get_user_godmode(id) ) return PLUGIN_HANDLED;
	
	static property[5];
	GetProperty(ent, 1, property);
	fakedamage(id, "Damage Block", str_to_float(property), DMG_CRUSH);
	
	GetProperty(ent, 2, property);
	g_next_damage_time[id] = gametime + str_to_float(property);
	
	return PLUGIN_HANDLED;
}

ActionHeal(id, ent)
{
	new Float:gametime = get_gametime();
	if ( !( gametime >= g_next_heal_time[id] ) ) return PLUGIN_HANDLED;
	
	new health = get_user_health(id);
	if ( health >= maxhp[id]) return PLUGIN_HANDLED;
	
	static property[5];
	
	GetProperty(ent, 1, property);
	health += str_to_num(property);
	set_user_health(id, min(maxhp[id], health));
	sgpm_stop_poison_dmg(id);
	
	GetProperty(ent, 2, property);
	g_next_heal_time[id] = gametime + str_to_float(property);
	
	new origin[3]; 
	get_user_origin(id, origin, 0);
	
	for(new i = 1; i <= g_max_players; i++){
		if(i != id && g_connected[i]){
			message_begin(MSG_ONE,SVC_TEMPENTITY,origin,i);
			write_byte(TE_SPRITE);//говорим что хотим создать, в данном случае спрайт
			write_coord(origin[0]);//х - координата
			write_coord(origin[1]);//у - координата
			write_coord(origin[2]);//z - координата
			write_short(id_Sprites[0]);// id спрайта
			write_byte(10); //масштаб
			write_byte(200);//яркость
			message_end();
		}
	}
	
	emit_sound(id, CHAN_STATIC, gszHealthSound, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	return PLUGIN_HANDLED;
}

ActionIce(id)
{
	if ( !g_ice[id] )
	{
		entity_set_float(id, EV_FL_friction, 0.15);
		entity_set_float(id, EV_FL_maxspeed, 400.0);
		
		g_ice[id] = true;
	}
	
	new task_id = TASK_ICE + id;
	if ( task_exists(task_id) ) remove_task(task_id);
	
	set_task(0.1, "TaskNotOnIce", task_id);
}

ActionTrampoline(id, ent)
{
	static property1[5];
	GetProperty(ent, 1, property1);
	
	entity_get_vector(id, EV_VEC_velocity, g_set_velocity[id]);
	
	g_set_velocity[id][2] = str_to_float(property1);
	
	entity_set_int(id, EV_INT_gaitsequence, 6);
	
	g_no_fall_damage[id] = true;
}

ActionSpeedBoost(id, ent)
{
	static property[5];
	
	GetProperty(ent, 1, property);
	velocity_by_aim(id, str_to_num(property), g_set_velocity[id]);
	
	GetProperty(ent, 2, property);
	g_set_velocity[id][2] = str_to_float(property);
	
	entity_set_int(id, EV_INT_gaitsequence, 6);
}

ActionLowGravity(id, ent)
{
	if ( g_low_gravity[id] ) return PLUGIN_HANDLED;
	
	static property1[5];
	GetProperty(ent, 1, property1);
	
	entity_set_float(id, EV_FL_gravity, str_to_float(property1) / 800);
	
	g_low_gravity[id] = true;
	
	return PLUGIN_HANDLED;
}

ActionHoney(id, ent)
{
	if ( g_honey[id] != ent )
	{
		static property1[5];
		GetProperty(ent, 1, property1);
		
		new Float:speed = str_to_float(property1);
		entity_set_float(id, EV_FL_maxspeed, speed == 0 ? -1.0 : speed);
		
		g_honey[id] = ent;
	}
	
	new task_id = TASK_HONEY + id;
	if ( task_exists(task_id) )
	{
		remove_task(task_id);
	}
	else
	{
		static Float:velocity[3];
		entity_get_vector(id, EV_VEC_velocity, velocity);
		
		velocity[0] /= 2.0;
		velocity[1] /= 2.0;
		
		entity_set_vector(id, EV_VEC_velocity, velocity);
	}
	
	set_task(0.1, "TaskNotInHoney", task_id);
}

ActionCTBarrier(id, ent)
{
	static property[5];
	GetProperty(ent, 1, property);
	new CsTeams:playerTeam = cs_get_user_team(id);
	switch ( property[0] )
	{
		case '1'://Normal
		{
			if(playerTeam == CS_TEAM_CT)
			{
				return;
			}
			if(playerTeam == CS_TEAM_T)
			{
				if ( task_exists(TASK_SOLID_NOT + ent)
				|| task_exists(TASK_SOLID + ent) ) return;
			
				TaskSolidNot(TASK_SOLID_NOT + ent);
			}
		}
		case '2': // Team vips only
		{
			if(playerTeam == CS_TEAM_CT && !(get_user_flags(id) & ADMIN_LEVEL_C))
			{
				return;
			}
			if(get_user_flags(id) & ADMIN_LEVEL_C)
			{
				if ( task_exists(TASK_SOLID_NOT + ent)
				|| task_exists(TASK_SOLID + ent) ) return;
			
				TaskSolidNot(TASK_SOLID_NOT + ent);
			}
			if(playerTeam == CS_TEAM_T)
			{
				if ( task_exists(TASK_SOLID_NOT + ent)
				|| task_exists(TASK_SOLID + ent) ) return;
			
				TaskSolidNot(TASK_SOLID_NOT + ent);
			}
		}
		case '3':
		{
			if(playerTeam == CS_TEAM_CT )
			{
				return;
			}
			if(get_user_flags(id) & ADMIN_LEVEL_C)
			{
				return;
			}
			if(playerTeam == CS_TEAM_T)
			{
				if ( task_exists(TASK_SOLID_NOT + ent)
				|| task_exists(TASK_SOLID + ent) ) return;
			
				TaskSolidNot(TASK_SOLID_NOT + ent);
			}
		}
	}
}

ActionTBarrier(id, ent)
{
	static property[5];
	GetProperty(ent, 1, property);
	new CsTeams:playerTeam = cs_get_user_team(id);
	switch ( property[0] )
	{
		case '1'://Normal
		{
			if(playerTeam == CS_TEAM_T)
			{
				return;
			}
			if(playerTeam == CS_TEAM_CT)
			{
				if ( task_exists(TASK_SOLID_NOT + ent)
				|| task_exists(TASK_SOLID + ent) ) return;
			
				TaskSolidNot(TASK_SOLID_NOT + ent);
			}
		}
		case '2': // Team vips only
		{
			if(playerTeam == CS_TEAM_T && !(get_user_flags(id) & ADMIN_LEVEL_C))
			{
				return;
			}
			if(get_user_flags(id) & ADMIN_LEVEL_C)
			{
				if ( task_exists(TASK_SOLID_NOT + ent)
				|| task_exists(TASK_SOLID + ent) ) return;
			
				TaskSolidNot(TASK_SOLID_NOT + ent);
			}
			if(playerTeam == CS_TEAM_CT)
			{
				if ( task_exists(TASK_SOLID_NOT + ent)
				|| task_exists(TASK_SOLID + ent) ) return;
			
				TaskSolidNot(TASK_SOLID_NOT + ent);
			}
		}
		case '3':
		{
			if(playerTeam == CS_TEAM_T )
			{
				return;
			}
			if(get_user_flags(id) & ADMIN_LEVEL_C)
			{
				return;
			}
			if(playerTeam == CS_TEAM_CT)
			{
				if ( task_exists(TASK_SOLID_NOT + ent)
				|| task_exists(TASK_SOLID + ent) ) return;
			
				TaskSolidNot(TASK_SOLID_NOT + ent);
			}
		}
	}
}

ActionABarrier(id, ent)
{
	static property[5];
	GetProperty(ent, 1, property);
	switch ( property[0] )
	{
		case '1'://No vips
		{
			if(get_user_flags(id) & ADMIN_LEVEL_C)
			{
				if ( task_exists(TASK_SOLID_NOT + ent)
				|| task_exists(TASK_SOLID + ent) ) return;
			
				TaskSolidNot(TASK_SOLID_NOT + ent);
			}
			else
			{
				return;
			}
		}
		case '2': // Team vips only
		{
			if(get_user_flags(id) & ADMIN_LEVEL_C)
			{
				return;
			}
			else
			{
				if ( task_exists(TASK_SOLID_NOT + ent)
				|| task_exists(TASK_SOLID + ent) ) return;
			
				TaskSolidNot(TASK_SOLID_NOT + ent);
			}	
		}
	}
}

ActionNoSlowDown(id)
{
	g_no_slow_down[id] = true;
	
	new task_id = TASK_NOSLOWDOWN + id;
	if ( task_exists(task_id) ) remove_task(task_id);
	
	set_task(0.1, "TaskSlowDown", task_id);
}

ActionDelayedBhop(ent)
{
	if ( task_exists(TASK_SOLID_NOT + ent)
	|| task_exists(TASK_SOLID + ent) ) return PLUGIN_HANDLED;
	
	static property1[5];
	GetProperty(ent, 1, property1);
	
	set_task(str_to_float(property1), "TaskSolidNot", TASK_SOLID_NOT + ent);
	
	return PLUGIN_HANDLED;
}

ActionInvincibility(id, ent)
{
	new Float:gametime = get_gametime();
	if ( !( gametime >= g_invincibility_next_use[id] ) ){
		g_invincibility_next_use_mess[id] = get_gametime() + 0.1;
		return PLUGIN_HANDLED;
	}
	
	static property[5];
	
	entity_set_float(id, EV_FL_takedamage, DAMAGE_NO);
	
	if ( gametime >= g_invincibility_time_out[id] )
	{
		set_user_rendering(id, kRenderFxGlowShell, 255, 255, 255, kRenderNormal, 16);
		
	}
	
	static Float:time_out;
	GetProperty(ent, 1, property);
	time_out = str_to_float(property);
	
	new extra_time = pm_level_extra_time(id);
	
	if(extra_time != 0)
	{
		time_out *= extra_time * 0.1 + 1;
		BCM_Print(id, "Вы будете неуязвимы дополнительные %d секунд(ы)", extra_time);
	}
	
	set_task(time_out, "TaskRemoveInvincibility", TASK_INVINCIBLE + id, g_blank, 0, g_a, 1);
	
	GetProperty(ent, 2, property);
	emit_sound(id, CHAN_STATIC, gszInvincibilitySound, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	g_invincibility_time_out[id] = gametime + time_out;
	g_invincibility_next_use[id] = gametime + time_out + str_to_float(property);
	
	return PLUGIN_HANDLED;
}
ActionCamouflage(id,ent)
{
	new Float:gametime = get_gametime();
	if ( !( gametime >= g_CAMOUFLAGE_next_use[id] ) ){
		g_CAMOUFLAGE_next_use_mess[id] = get_gametime() + 0.1;
		return PLUGIN_HANDLED;
	}
	
	static property[5];
	
	new szModel[32];
	new team;
	cs_get_user_model(id, szModel, 32);
	team = get_user_team(id);
	gszCamouflageOldModel[id] = szModel;
	if (team == 1)		//TERRORIST
	{
		new random_model = random_num(1, 4);
		
		switch( random_model )
		{
			case 1:
			{	
				cs_set_user_model(id, "gsg9");
			}
			case 2:
			{	
				cs_set_user_model(id, "urban");
			}
			case 3:
			{	
				cs_set_user_model(id, "sas");
			}
			case 4:
			{	
				cs_set_user_model(id, "gign");
			}
		}
	}
	else
	{
		new random_model = random_num(1, 4);
		
		switch( random_model )
		{
			case 1:
			{	
				cs_set_user_model(id, "terror");
			}
			case 2:
			{	
				cs_set_user_model(id, "leet");
			}
			case 3:
			{	
				cs_set_user_model(id, "arctic");
			}
			case 4:
			{	
				cs_set_user_model(id, "guerilla");
			}
		}
	}
	static Float:time_out;
	GetProperty(ent, 1, property);
	time_out = str_to_float(property);
	
	new extra_time = pm_level_extra_time(id);
	
	if(extra_time != 0)
	{
		time_out *= extra_time * 0.1 + 1;
		BCM_Print(id, "Вы будете замаскированы дополнительные %d секунд(ы)", extra_time);
	}
	
	set_task(time_out, "taskCamouflageRemove", TASK_CAMOUFLAGE + id, g_blank, 0, g_a, 1);
	
	GetProperty(ent, 2, property);
	emit_sound(id, CHAN_STATIC, gszCAMOUFLAGEhSound, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	g_CAMOUFLAGE_time_out[id] = gametime + time_out;
	g_CAMOUFLAGE_next_use[id] = gametime + time_out + str_to_float(property);
	
	return PLUGIN_HANDLED;
}
ActionStealth(id, ent)
{
	new Float:gametime = get_gametime();
	if ( !( gametime >= g_stealth_next_use[id] ) ){
		g_stealth_next_use_mess[id] = get_gametime() + 0.1;
		return PLUGIN_HANDLED;
	}
	
	static property[5];
	
	set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 0);
	
	g_block_status[id] = true;
	
	static Float:time_out;
	GetProperty(ent, 1, property);
	time_out = str_to_float(property);
	
	new extra_time = pm_level_extra_time(id);
	
	if(extra_time != 0)
	{
		time_out *= extra_time * 0.1 + 1;
		BCM_Print(id, "Вы будете невидимы дополнительные %d секунд(ы)", extra_time);
	}
		
	set_task(time_out, "TaskRemoveStealth", TASK_STEALTH + id, g_blank, 0, g_a, 1);
	
	GetProperty(ent, 2, property);
	emit_sound(id, CHAN_STATIC, gszStealthSound, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	g_stealth_time_out[id] = gametime + time_out;
	g_stealth_next_use[id] = gametime + time_out + str_to_float(property);
	
	g_user_in_music[id] = 0.0;
	
	return PLUGIN_HANDLED;
}

ActionBootsOfSpeed(id, ent)
{
	new Float:gametime = get_gametime();
	if ( !( gametime >= g_boots_of_speed_next_use[id] ) ){
		g_boots_of_speed_next_use_mess[id] = get_gametime() + 0.1;
		return PLUGIN_HANDLED;
	}
	
	static property[5];
	
	GetProperty(ent, 3, property);
	entity_set_float(id, EV_FL_maxspeed, str_to_float(property));
	
	g_boots_of_speed[id] = ent;
	
	static Float:time_out;
	GetProperty(ent, 1, property);
	time_out = str_to_float(property);
	
	new extra_time = pm_level_extra_time(id);
	
	if(extra_time != 0)
	{
		time_out *= extra_time * 0.1 + 1;
		BCM_Print(id, "Вы будете быстрым дополнительные %d секунд(ы)", extra_time);
	}
	
	set_task(time_out, "TaskRemoveBootsOfSpeed", TASK_BOOTSOFSPEED + id, g_blank, 0, g_a, 1);
	
	GetProperty(ent, 2, property);
	emit_sound(id, CHAN_STATIC, gszBootsOfSpeedSound, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	g_boots_of_speed_time_out[id] = gametime + time_out;
	g_boots_of_speed_next_use[id] = gametime + time_out + str_to_float(property);
	
	return PLUGIN_HANDLED;
}

ActionMusic(id, ent)
{
	new Float:gametime = get_gametime();
	
	if ( !( gametime >= g_music_next_use[id] ) ){
		return PLUGIN_HANDLED;
	}
	
	static property[5];
	new rand = random_num(0,16);
	
	switch(rand)
	{
		case 0: 
		{
			emit_sound(id, CHAN_STREAM, gsz1, 0.8, ATTN_NORM, 0, PITCH_NORM);
		}
		case 1: 
		{
			emit_sound(id, CHAN_STREAM, gsz2, 0.8, ATTN_NORM, 0, PITCH_NORM);
		}
		case 2: 
		{
			emit_sound(id, CHAN_STREAM, gsz3, 0.8, ATTN_NORM, 0, PITCH_NORM);
		}
		case 3: 
		{
			emit_sound(id, CHAN_STREAM, gsz4, 0.8, ATTN_NORM, 0, PITCH_NORM);
		}
		case 4: 
		{
			emit_sound(id, CHAN_STREAM, gsz5, 0.8, ATTN_NORM, 0, PITCH_NORM);
		}
		case 5: 
		{
			emit_sound(id, CHAN_STREAM, gsz6, 0.8, ATTN_NORM, 0, PITCH_NORM);
		}
		case 6: 
		{
			emit_sound(id, CHAN_STREAM, gsz7, 0.8, ATTN_NORM, 0, PITCH_NORM);
		}
		case 7: 
		{
			emit_sound(id, CHAN_STREAM, gsz8, 0.8, ATTN_NORM, 0, PITCH_NORM);
		}
		case 8: 
		{
			emit_sound(id, CHAN_STREAM, gsz9, 0.8, ATTN_NORM, 0, PITCH_NORM);
		}
		case 9: 
		{
			emit_sound(id, CHAN_STREAM, gsz10, 0.8, ATTN_NORM, 0, PITCH_NORM);
		}
		case 10: 
		{
			emit_sound(id, CHAN_STREAM, gsz11, 0.8, ATTN_NORM, 0, PITCH_NORM);
		}
		case 11: 
		{
			emit_sound(id, CHAN_STREAM, gsz12, 0.8, ATTN_NORM, 0, PITCH_NORM);
		}
		case 12: 
		{
			emit_sound(id, CHAN_STREAM, gsz13, 0.8, ATTN_NORM, 0, PITCH_NORM);
		}
		case 13: 
		{
			emit_sound(id, CHAN_STREAM, gsz14, 0.8, ATTN_NORM, 0, PITCH_NORM);
		}
		case 14: 
		{
			emit_sound(id, CHAN_STREAM, gsz15, 0.8, ATTN_NORM, 0, PITCH_NORM);
		}
		case 15: 
		{
			emit_sound(id, CHAN_STREAM, gsz16, 0.8, ATTN_NORM, 0, PITCH_NORM);
		}
		case 16:
		{
			emit_sound(id, CHAN_STREAM, gsz17, 0.8, ATTN_NORM, 0, PITCH_NORM);
		}
	}
	
	GetProperty(ent, 2, property);
	g_music_next_use[id] = gametime + str_to_float(property) + 0.5;
	g_user_in_music[id] = str_to_float(property);
	
	MusicSpriteGo(id);
	
	return PLUGIN_HANDLED;
}

public MusicSpriteGo(id)
{
	if(g_user_in_music[id] <= 0)
		return PLUGIN_HANDLED;
	
	static origin[3];
	get_user_origin(id, origin);
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMCYLINDER);
	write_coord(origin[0]);
	write_coord(origin[1]);
	write_coord(origin[2]-20);
	write_coord(origin[0]);
	write_coord(origin[1]);
	write_coord(origin[2]+100);
	write_short(id_Sprites[1]);
	write_byte(0);
	write_byte(1);
	write_byte(5);
	write_byte(15);
	write_byte(1);
	write_byte(random_num(0, 255));
	write_byte(random_num(0, 255));
	write_byte(random_num(0, 255));
	write_byte(255);
	write_byte(0);
	message_end();
	
	g_user_in_music[id] -= 0.2;
	
	set_task(0.2, "MusicSpriteGo", TASK_SPRITE + id);
	
	return PLUGIN_HANDLED;
}

ActionDuck(id)
{
	entity_set_int(id, EV_INT_bInDuck, 10);
}

ActionBlindTrap(id, ent)
{
	static property[5];
	GetProperty(ent, 1, property);
	switch ( property[0] )
	{
		case '1': // Flashed all
		{
			gmsgScreenFade = get_user_msgid("ScreenFade");
	
			message_begin(MSG_ONE, gmsgScreenFade, {0,0,0}, id);
			write_short(4096*3);    // Duration
			write_short(4096*3);    // Hold time
			write_short(4096);    // Fade type
			write_byte(0);
			write_byte(0);
			write_byte(0);
			write_byte(255);    // Alpha
			message_end();
		}
		case '2': //No vips
		{
			if(get_user_flags(id) & ADMIN_LEVEL_C)
			{
				return;
			}
			else
			{
				gmsgScreenFade = get_user_msgid("ScreenFade");
	
				message_begin(MSG_ONE, gmsgScreenFade, {0,0,0}, id);
				write_short(4096*3);    // Duration
				write_short(4096*3);    // Hold time
				write_short(4096);    // Fade type
				write_byte(0);
				write_byte(0);
				write_byte(0);
				write_byte(255);    // Alpha
				message_end();
			}
		}
	}
}

ActionEarthquake(id, ent)
{
	static property[5];
	GetProperty(ent, 1, property);
	switch ( property[0] )
	{
		case '1': // Flashed all
		{
			if(is_user_alive(id))
			{
				new g_msgScreenDrug=get_user_msgid("ScreenShake");
				message_begin(MSG_ONE,g_msgScreenDrug, {0,0,0},id);
				write_short(255<<14);
				write_short(10<<14);
				write_short(255<<14);
				message_end();
			}
		}
		case '2': //No vips
		{
			if(get_user_flags(id) & ADMIN_LEVEL_C)
			{
				return;
			}
			else
			{
				if(is_user_alive(id))
				{
					new g_msgScreenDrug=get_user_msgid("ScreenShake");
					message_begin(MSG_ONE,g_msgScreenDrug, {0,0,0},id);
					write_short(255<<14);
					write_short(10<<14);
					write_short(255<<14);
					message_end();
				}
			}
		}
	}
}

ActionMagicCarpet(id, ent)
{
	static property[5];
	GetProperty(ent, 1, property);
	
	switch ( property[0] )
	{
		case '1':
		{
			return;
		}
		case '2':
		{
			if( get_user_team(id) == 1 )
			{
				SetMagicTask(id, ent, property);
			}
		}
		case '3':
		{
			if( get_user_team(id) == 2 )
			{
				SetMagicTask(id, ent, property);
			}
		}
		case '4':
		{
			if(get_user_flags(id) & ADMIN_LEVEL_C)
			{
				SetMagicTask(id, ent, property);
			}
		}
		case '5':
		{
			if(!(get_user_flags(id) & ADMIN_LEVEL_C))
			{
				SetMagicTask(id, ent, property);
			}
		}
		case '6':
		{
			SetMagicTask(id, ent, property);
		}
	}
}

SetMagicTask(id, ent, property[5]){
	new Float:origin[2][3];
	
	pev(id, pev_origin, origin[0]);
	pev(ent, pev_origin, origin[1]);
		
	origin[1][0] = origin[0][0];
	origin[1][1] = origin[0][1];
	
	/* up & down keys */
	GetProperty(ent, 3, property);
	new max_height = str_to_num(property);
	
	if(max_height > 0){
		GetProperty(ent, 4, property);
		new Float:fly_speed = str_to_float(property)*0.1;
	
		if(fly_speed != 0){
			new btn = pev(id, pev_button);
			
			if(btn & IN_RELOAD){
				origin[1][2] -= fly_speed;
				origin[0][2] -= fly_speed;
			}else if(btn & IN_ATTACK2 && origin[1][2] + fly_speed < (max_height * 1.0)){
				origin[1][2] += fly_speed;
				origin[0][2] += fly_speed;
			}
		}
	}
	/* up & down keys */
	
	set_pev(id, pev_origin, origin[0]);
	set_pev(ent, pev_origin, origin[1]);
	set_pev(ent, pev_movetype, MOVETYPE_FLY);
	
	GetProperty(ent, 2, property);
	
	if( str_to_float(property) != 0 )
	{
		new task_id = TASK_MOVEBACK + ent;
		
		if ( !task_exists(task_id) )
		{
			set_task(str_to_float(property), "TaskMoveBack", TASK_MOVEBACK + ent);
		}
	}
}

ActionPointBlock(id, ent)
{
	new Float:gametime = get_gametime();
	
	if (gametime >= g_pb_next_use[id] && get_user_team(id) == 1 && get_playersnum() >= get_pcvar_num(pointblock_players_cvar))
	{
		static property[5];
		GetProperty(ent, 1, property);
		
		new xvar = str_to_num(property);
		pm_add_user_point_new(id, xvar);
		
		GetProperty(ent, 2, property);
		
		g_pb_next_use[id] = gametime + str_to_float(property);
	
		return PLUGIN_HANDLED;
	}
	else if (get_playersnum() >= get_pcvar_num(pointblock_players_cvar)){
		g_pb_next_use_mess[id] = get_gametime() + 0.1;
		return PLUGIN_HANDLED;
	}	
	else if (get_playersnum() < get_pcvar_num(pointblock_players_cvar)){
		g_pb_next_use_mess_nope[id] = get_gametime() + 0.1;
	}
	
	return PLUGIN_HANDLED;
}

public ActionRandomBlock(id, ent)
{
	new Float:gametime = get_gametime();
	if ( !( gametime >= g_random_next_use[id] ) ){
		g_random_next_use_mess[id] = get_gametime() + 0.1;
		return PLUGIN_HANDLED;
	}
	
	format(BlocksProperty[id][0], 4, "Cash");
	format(BlocksProperty[id][1], 4, "Cash");
	format(BlocksProperty[id][2], 4, "Cash");
	format(BlocksProperty[id][3], 4, "Cash");
	
	GetProperty(ent, 1, BlocksProperty[id][4]);
	GetProperty(ent, 2, BlocksProperty[id][5]);
	
	static property[5];
	new block_type;
	
	switch(random_num(1, 28))
	{
		case 1:
		{
			block_type = BUNNYHOP;
			format(BlocksProperty[id][0], 4, "%d", random_num(0, 1));
			format(BlocksProperty[id][3], 4, "OTO");
		}
		case 2:
		{
			block_type = SPEED_BOOST;
			format(BlocksProperty[id][0], 4, "%d", random_num(1, 1000));
			format(BlocksProperty[id][1], 4, "%d", random_num(1, 1000));
			format(BlocksProperty[id][3], 4, "OTO");
		}
		case 3:
		{
			block_type = DEATH;
			format(BlocksProperty[id][3], 4, "OTO");
		}
		case 4:
		{
			block_type = SLAP;
			format(BlocksProperty[id][0], 4, "%d", random_num(1, 3));
			format(BlocksProperty[id][3], 4, "OTO");
		}
		case 5:
		{
			block_type = CT_BARRIER;
			format(BlocksProperty[id][0], 4, "%d", random_num(1, 3));
			format(BlocksProperty[id][3], 4, "OTO");
		}
		case 6:
		{
			block_type = T_BARRIER;
			format(BlocksProperty[id][0], 4, "%d", random_num(1, 3));
			format(BlocksProperty[id][3], 4, "OTO");
		}
		case 7:
		{
			block_type = VIP_BARRIER;
			format(BlocksProperty[id][0], 4, "%d", random_num(1, 2));
			format(BlocksProperty[id][3], 4, "OTO");
		}
		case 8:
		{
			block_type = DELAYED_BUNNYHOP;
			format(BlocksProperty[id][0], 4, "%d", random_num(1, 5));
			format(BlocksProperty[id][3], 4, "OTO");
		}
		case 9:
		{
			block_type = BUNNYHOP_D;
			format(BlocksProperty[id][0], 4, "%d", random_num(0, 1));
			format(BlocksProperty[id][1], 4, "%d", random_num(1, 100));
			format(BlocksProperty[id][3], 4, "OTO");
		}
		case 10:
		{
			block_type = INVINCIBILITY;
			format(BlocksProperty[id][0], 4, "%d", random_num(1, 15));
			format(BlocksProperty[id][1], 4, "%d", random_num(1, 120));
			format(BlocksProperty[id][3], 4, "OTO");
		}
		case 11:
		{
			block_type = STEALTH;
			format(BlocksProperty[id][0], 4, "%d", random_num(1, 15));
			format(BlocksProperty[id][1], 4, "%d", random_num(1, 120));
			format(BlocksProperty[id][3], 4, "OTO");
		}
		case 12:
		{
			block_type = BOOTS_OF_SPEED;
			format(BlocksProperty[id][0], 4, "%d", random_num(1, 15));
			format(BlocksProperty[id][1], 4, "%d", random_num(1, 120));
			format(BlocksProperty[id][2], 4, "%d", random_num(260, 1000));
			format(BlocksProperty[id][3], 4, "OTO");
		}
		case 13:
		{
			block_type = CAMOUFLAGE;
			format(BlocksProperty[id][0], 4, "%d", random_num(1, 15));
			format(BlocksProperty[id][1], 4, "%d", random_num(1, 120));
			format(BlocksProperty[id][3], 4, "OTO");
		}
		case 14:
		{
			block_type = GRANATA;
			format(BlocksProperty[id][0], 4, "%d", random_num(1, 4));
			format(BlocksProperty[id][1], 4, "%d", random_num(1, 2));
			format(BlocksProperty[id][3], 4, "OTO");
		}
		case 15:
		{
			block_type = WEAPON_CHANCE;
			format(BlocksProperty[id][0], 4, "%d", random_num(1, 120));
			format(BlocksProperty[id][3], 4, "OTO");
		}
		case 16:
		{
			block_type = MUSIC;
			format(BlocksProperty[id][3], 4, "OTO");
			
		}
		case 17:
		{
			block_type = BLIND_TRAP;
			format(BlocksProperty[id][0], 4, "%d", random_num(1, 2));
			format(BlocksProperty[id][3], 4, "OTO");
		}
		case 18:
		{
			block_type = EARTHQUAKE;
			format(BlocksProperty[id][0], 4, "%d", random_num(1, 2));
			format(BlocksProperty[id][3], 4, "OTO");
		}
		case 19:
		{
			block_type = POINT_BLOCK;
			format(BlocksProperty[id][0], 4, "%d", random_num(1, 100));
			format(BlocksProperty[id][1], 4, "%d", random_num(1, 180));
			format(BlocksProperty[id][3], 4, "OTO");
		}
		case 20:
		{
			block_type = DAMAGE;
			format(BlocksProperty[id][0], 4, "%d", random_num(1, 100));
			format(BlocksProperty[id][3], 4, "OTO");
		}
		case 21:
		{
			block_type = TRAMPOLINE;
			format(BlocksProperty[id][0], 4, "%d", random_num(1, 1000));
			format(BlocksProperty[id][3], 4, "OTO");
		}
		case 22:
		{
			block_type = HEALER;
			format(BlocksProperty[id][0], 4, "%d", random_num(1, 15));
			format(BlocksProperty[id][1], 4, "%.1f", random_float(0.1, str_to_float(BlocksProperty[id][4])));
			format(BlocksProperty[id][3], 4, "OTO");
		}
		case 23:
		{
			block_type = LOW_GRAVITY;
			format(BlocksProperty[id][0], 4, "%d", random_num(1, 800));
			format(BlocksProperty[id][3], 4, "0");
		}
		case 24:
		{
			block_type = HONEY;
			format(BlocksProperty[id][0], 4, "%d", random_num(1, 100));
			format(BlocksProperty[id][3], 4, "OTO");
		}
		case 25:
		{
			block_type = NO_SLOW_DOWN_BUNNYHOP;
			format(BlocksProperty[id][0], 4, "%d", random_num(0, 1));
			format(BlocksProperty[id][3], 4, "OTO");
		}
		case 26:
		{
			block_type = DOUBLE_DUCK;
			format(BlocksProperty[id][3], 4, "OTO");
		}
		case 27:
		{
			block_type = PLATFORM;
		}
		case 28:
		{
			block_type = ICE;
		}
	}
	
	if(equal(BlocksProperty[id][3], "OTO"))
	{
		GetProperty(ent, 4, BlocksProperty[id][3]);
	}
	
	static Float:time_out;
	GetProperty(ent, 1, property);
	time_out = str_to_float(property);
	
	GetProperty(ent, 2, property);
	g_random_next_use[id] = gametime + time_out + str_to_float(property);
	
	new convert_ent = ConvertBlock(0, ent, block_type, false);
	for(new i = 0; i <= 3; i++)
	{
		if(!equal(BlocksProperty[id][i], "Cash"))
		{
			SetProperty(convert_ent, i+1, BlocksProperty[id][i]);
		}
		else
		{
			continue;
		}
	}
	
	new transfer_items[1];
	transfer_items[0] = id;
	set_task(time_out, "ChangeModel", convert_ent, transfer_items, 1);
	
	return PLUGIN_HANDLED;
}

public ChangeModel(transfer_items[], ent)
{
	new id = transfer_items[0];
	
	if (!is_valid_ent(ent)) return PLUGIN_HANDLED;
	
	new convert_ent = ConvertBlock(0, ent, RANDOM, false);
	
	SetProperty(convert_ent, 1, BlocksProperty[id][4]);
	SetProperty(convert_ent, 2, BlocksProperty[id][5]);
	
	if(!equal(BlocksProperty[id][3], "Cash"))
	{
		SetProperty(convert_ent, 4, BlocksProperty[id][3]);
	}
	
	return PLUGIN_HANDLED;
}

ActionTeleport(id, ent)
{
	new tele = entity_get_int(ent, EV_INT_iuser1);
	if ( !tele ) return PLUGIN_HANDLED;
	
	static Float:tele_origin[3];
	entity_get_vector(tele, EV_VEC_origin, tele_origin);
	
	static classname[32];
	entity_get_string(id, EV_SZ_classname, classname, charsmax(classname));
	
	if(!equal(classname, "grenade"))
	{
		new player = -1;
		do
		{
			player = find_ent_in_sphere(player, tele_origin, 16.0);
		
			if ( !is_user_alive(player)
			|| player == id
			|| cs_get_user_team(id) == cs_get_user_team(player)) continue;
		
			user_kill(player, 1);
		}
		while ( player );
	}
	
	entity_set_vector(id, EV_VEC_origin, tele_origin);
	
	static Float:velocity[3];
	entity_get_vector(id, EV_VEC_velocity, velocity);
	velocity[2] = floatabs(velocity[2]);
	entity_set_vector(id, EV_VEC_velocity, velocity);
	
	emit_sound(id, CHAN_STATIC, g_sound_teleport, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
	
	return PLUGIN_HANDLED;
}

public TaskMoveBack(ent)
{
	ent -= TASK_MOVEBACK;
	
	if ( !is_valid_ent(ent) 
	|| entity_get_int(ent, EV_INT_iuser2) ) return PLUGIN_HANDLED;
	
	new Float:origin[3];
	pev(ent, pev_v_angle, origin);
	
	set_pev(ent, pev_velocity, Float:{0.0, 0.0, 0.0});
	engfunc(EngFunc_SetOrigin, ent, origin);
	
	return PLUGIN_HANDLED;
}	

public TaskSolidNot(ent)
{
	ent -= TASK_SOLID_NOT;
	if( pev_valid( ent ) ) 
	{
		gRenderMode_Solid[ent] = entity_get_int(ent, EV_INT_rendermode);
		gRenderFx_Solid[ent] = entity_get_int(ent, EV_INT_renderfx);
		pev( ent, pev_renderamt, gRenderAmt_Solid[ent] );
		pev( ent, pev_rendercolor, gRenderColor_Solid[ent] );
		
		if ( !is_valid_ent(ent)
		|| entity_get_int(ent, EV_INT_iuser2) ) return PLUGIN_HANDLED;
		
		entity_set_int(ent, EV_INT_solid, SOLID_NOT);
		set_rendering(ent, kRenderFxNone, 255, 255, 255, kRenderTransAdd, 25);
		set_task(1.0, "TaskSolid", TASK_SOLID + ent);
		
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

public TaskSolid(ent)
{
	ent -= TASK_SOLID;
	
	if ( !IsBlock(ent) ) return PLUGIN_HANDLED;
	
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
	
	set_pev(ent, pev_rendermode, gRenderMode_Solid[ent]);
	set_pev(ent, pev_renderfx, gRenderFx_Solid[ent]);
	set_pev(ent, pev_renderamt, gRenderAmt_Solid[ent] );
	set_pev(ent, pev_rendercolor, gRenderColor_Solid[ent] );
	
	if(ent_skip_time_start[ent] != 0.0){
		ent_skip_time_start[ent] = 0.0;
	}
	
	if ( entity_get_int(ent, EV_INT_iuser1) > 0 )
	{
		GroupBlock(0, ent);
	}
	
	return PLUGIN_HANDLED;
}

public TaskNotOnIce(id)
{
	id -= TASK_ICE;
	
	g_ice[id] = false;
	
	if ( !g_alive[id] ) return PLUGIN_HANDLED;
	
	if ( g_boots_of_speed[id] ){
		static block, property3[5];
		block = g_boots_of_speed[id];
		GetProperty(block, 3, property3);
		
		entity_set_float(id, EV_FL_maxspeed, str_to_float(property3));
	}
	else if(sgpm_boots_is_activated(id)){
		entity_set_float(id, EV_FL_maxspeed, 400.0);
	}
	else{
		ResetMaxspeed(id);
	}
	
	entity_set_float(id, EV_FL_friction, 1.0);
	
	return PLUGIN_HANDLED;
}

public TaskNotInHoney(id)
{
	id -= TASK_HONEY;
	
	g_honey[id] = 0;
	
	if ( !g_alive[id] ) return PLUGIN_HANDLED;
	
	if ( g_boots_of_speed[id] ){
		static block, property3[5];
		block = g_boots_of_speed[id];
		GetProperty(block, 3, property3);
		
		entity_set_float(id, EV_FL_maxspeed, str_to_float(property3));
	}
	else if(sgpm_boots_is_activated(id)){
		entity_set_float(id, EV_FL_maxspeed, 400.0);
	}
	else{
		ResetMaxspeed(id);
	}
	
	return PLUGIN_HANDLED;
}

public TaskSlowDown(id)
{
	id -= TASK_NOSLOWDOWN;
	
	g_no_slow_down[id] = false;
}

public TaskRemoveInvincibility(id)
{
	id -= TASK_INVINCIBLE;
	
	if ( !g_alive[id] ) return PLUGIN_HANDLED;
	
	if ( ( (get_user_flags(id) & ADMIN_LEVEL_D) || g_gived_access[id] ) && !g_godmode[id]
	|| ( !(get_user_flags(id) & ADMIN_LEVEL_D) && !g_gived_access[id] ) && !g_all_godmode )
	{
		set_user_godmode(id, 0);
	}
	
	if ( get_gametime() >= g_invincibility_time_out[id] )
	{
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 16);
	}
	
	return PLUGIN_HANDLED;
}

public TaskRemoveStealth(id)
{
	id -= TASK_STEALTH;
	
	if ( g_connected[id] )
	{
		if ( get_gametime() <= g_stealth_time_out[id] )
		{
			set_user_rendering(id, kRenderFxGlowShell, 255, 255, 255, kRenderTransColor, 16);
		}
		else
		{
			set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 255);
		}
	}
	
	g_block_status[id] = false;
}

public TaskRemoveBootsOfSpeed(id)
{
	id -= TASK_BOOTSOFSPEED;
	
	g_boots_of_speed[id] = 0;
	
	if ( !g_alive[id] ) return PLUGIN_HANDLED;
	
	if ( g_ice[id] )
	{
		entity_set_float(id, EV_FL_maxspeed, 400.0);
	}
	else if ( g_honey[id] )
	{
		static block, property1[5];
		block = g_honey[id];
		GetProperty(block, 1, property1);
		
		entity_set_float(id, EV_FL_maxspeed, str_to_float(property1));
	}
	else
	{
		ResetMaxspeed(id);
	}
	
	return PLUGIN_HANDLED;
}

public TaskSpriteNextFrame(params[])
{
	new ent = params[0];
	if ( !is_valid_ent(ent) )
	{
		remove_task(TASK_SPRITE + ent);
		return PLUGIN_HANDLED;
	}
	
	new frames = params[1];
	new Float:current_frame = entity_get_float(ent, EV_FL_frame);
	
	if ( current_frame < 0.0
	|| current_frame >= frames )
	{
		entity_set_float(ent, EV_FL_frame, 1.0);
	}
	else
	{
		entity_set_float(ent, EV_FL_frame, current_frame + 1.0);
	}
	
	return PLUGIN_HANDLED;
}

public MsgStatusValue()
{
	if ( get_msg_arg_int(1) == 2
	&& g_block_status[get_msg_arg_int(2)] )
	{
		set_msg_arg_int(1, get_msg_argtype(1), 1);
		set_msg_arg_int(2, get_msg_argtype(2), 0);
	}
}

public CmdAttack(id)
{
	if ( !IsBlock(g_grabbed[id]) ) return PLUGIN_HANDLED;
	
	if ( IsBlockInGroup(id, g_grabbed[id]) && g_group_count[id] > 1 )
	{
		static block;
		for ( new i = 0; i <= g_group_count[id]; ++i )
		{
			block = g_grouped_blocks[id][i];
			if ( !IsBlockInGroup(id, block) ) continue;
			
			if ( !IsBlockStuck(block) )
			{
				CopyBlock(block);
			}
		}
	}
	else
	{
		if ( IsBlockStuck(g_grabbed[id]) )
		{
			BCM_Print(id, "You cannot copy a block that is in a stuck position!");
			return PLUGIN_HANDLED;
		}
		
		new new_block = CopyBlock(g_grabbed[id]);
		if ( !new_block ) return PLUGIN_HANDLED;
		
		entity_set_int(g_grabbed[id], EV_INT_iuser2, 0);
		entity_set_int(new_block, EV_INT_iuser2, id);
		g_grabbed[id] = new_block;
	}
	
	return PLUGIN_HANDLED;
}

public CmdAttack2(id)
{
	if ( !IsBlock(g_grabbed[id]) )
	{
		DeleteTeleport(id, g_grabbed[id]);
		return PLUGIN_HANDLED;
	}
	
	if ( !IsBlockInGroup(id, g_grabbed[id])
	|| g_group_count[id] < 2 )
	{
		DeleteBlock(g_grabbed[id]);
		return PLUGIN_HANDLED;
	}
	
	static block;
	for ( new i = 0; i <= g_group_count[id]; ++i )
	{
		block = g_grouped_blocks[id][i];
		if ( !is_valid_ent(block)
		|| !IsBlockInGroup(id, block) ) continue;
		
		DeleteBlock(block);
	}
	
	return PLUGIN_HANDLED;
}

public CmdRotate(id)
{		
	if ( !IsBlock(g_grabbed[id]) ) return PLUGIN_HANDLED;
	
	if ( !IsBlockInGroup(id, g_grabbed[id])
	|| g_group_count[id] < 2 )
	{
		RotateBlock(g_grabbed[id]);
		return PLUGIN_HANDLED;
	}
	
	static block;
	for ( new i = 0; i <= g_group_count[id]; ++i )
	{
		block = g_grouped_blocks[id][i];
		if ( !is_valid_ent(block)
		|| !IsBlockInGroup(id, block) ) continue;
		
		RotateBlock(block);
	}
	
	return PLUGIN_HANDLED;
}

public CmdGrab(id)
{
	if ( !(get_user_flags(id) & ADMIN_LEVEL_D) && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static ent, body;
	g_grab_length[id] = get_user_aiming(id, ent, body);
	
	new bool:is_block = IsBlock(ent);
	if ( !is_block && !IsTeleport(ent) && !IsLight(ent) ) return PLUGIN_HANDLED;
	
	new grabber = entity_get_int(ent, EV_INT_iuser2);
	if ( grabber && grabber != id ) return PLUGIN_HANDLED;
	
	if ( !is_block )
	{
		SetGrabbed(id, ent);
		return PLUGIN_HANDLED;
	}
	
	new player = entity_get_int(ent, EV_INT_iuser1);
	if ( player && player != id )
	{
		new player_name[32]; 
		get_user_name(player, player_name, charsmax(player_name));
		
		BCM_Print(id, "^1%s3 currently has this block in their group!", player_name);
		return PLUGIN_HANDLED;
	}
	
	SetGrabbed(id, ent);
	
	if ( g_group_count[id] < 2 ) return PLUGIN_HANDLED;
	
	static Float:grabbed_origin[3];
	
	entity_get_vector(ent, EV_VEC_origin, grabbed_origin);
	
	static block, Float:origin[3], Float:offset[3];
	for ( new i = 0; i <= g_group_count[id]; ++i )
	{
		block = g_grouped_blocks[id][i];
		if ( !is_valid_ent(block) ) continue;
		
		entity_get_vector(block, EV_VEC_origin, origin);
		
		offset[0] = grabbed_origin[0] - origin[0];
		offset[1] = grabbed_origin[1] - origin[1];
		offset[2] = grabbed_origin[2] - origin[2];
		
		entity_set_vector(block, EV_VEC_vuser1, offset);
		entity_set_int(block, EV_INT_iuser2, id);
	}
	
	return PLUGIN_HANDLED;
}

SetGrabbed(id, ent)
{
	entity_get_string(id, EV_SZ_viewmodel, g_viewmodel[id], charsmax(g_viewmodel));
	entity_set_string(id, EV_SZ_viewmodel, g_blank);
	
	static aiming[3], Float:origin[3];
	
	get_user_origin(id, aiming, 3);
	entity_get_vector(ent, EV_VEC_origin, origin);
	
	g_grabbed[id] = ent;
	g_grab_offset[id][0] = origin[0] - aiming[0];
	g_grab_offset[id][1] = origin[1] - aiming[1];
	g_grab_offset[id][2] = origin[2] - aiming[2];
	
	entity_set_int(ent, EV_INT_iuser2, id);
}

public CmdRelease(id)
{
	if ( !(get_user_flags(id) & ADMIN_LEVEL_D) && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	else if ( !g_grabbed[id] )
	{
		return PLUGIN_HANDLED;
	}
	
	if ( IsBlock(g_grabbed[id]) )
	{
		if ( IsBlockInGroup(id, g_grabbed[id]) && g_group_count[id] > 1 )
		{
			static i, block;
			
			new bool:group_is_stuck = true;
			
			for ( i = 0; i <= g_group_count[id]; ++i )
			{
				block = g_grouped_blocks[id][i];
				if ( IsBlockInGroup(id, block) )
				{
					entity_set_int(block, EV_INT_iuser2, 0);
					
					if ( group_is_stuck && !IsBlockStuck(block) )
					{
						group_is_stuck = false;
						break;
					}
				}
			}
			
			if ( group_is_stuck )
			{
				for ( i = 0; i <= g_group_count[id]; ++i )
				{
					block = g_grouped_blocks[id][i];
					if ( IsBlockInGroup(id, block) ) DeleteBlock(block);
				}
				
				BCM_Print(id, "Group deleted because all the blocks were stuck!");
			}
		}
		else
		{
			if ( is_valid_ent(g_grabbed[id]) )
			{
				if ( IsBlockStuck(g_grabbed[id]) )
				{
					new bool:deleted = DeleteBlock(g_grabbed[id]);
					if ( deleted ) BCM_Print(id, "Block deleted because it was stuck!");
				}
				else
				{
					entity_set_int(g_grabbed[id], EV_INT_iuser2, 0);
				}
			}
		}
	}
	else if ( IsTeleport(g_grabbed[id]) )
	{
		entity_set_int(g_grabbed[id], EV_INT_iuser2, 0);
	}
	
	entity_get_string(id, EV_SZ_viewmodel, g_viewmodel[id], charsmax(g_viewmodel));
	entity_set_string(id, EV_SZ_viewmodel, g_blank);
	
	g_grabbed[id] = 0;
	
	return PLUGIN_HANDLED;
}

public CmdMainMenu(id)
{
	if(get_user_flags(id) & ADMIN_LEVEL_D || g_gived_access[id]){
		ShowMainMenu(id);
	}else{
		BCM_Print(id, "You have ^4no access ^3to that command.");
	}
	return PLUGIN_HANDLED;
}

//RENDERING
ShowRenderMenu(id)
{	
	new szMenu[256], szSize[12], col1[3], col2[3];
	
	col1 = (get_user_flags(id) & ADMIN_LEVEL_D) || g_gived_access[id] ? "\r" : "\d";
	col2 = (get_user_flags(id) & ADMIN_LEVEL_D) || g_gived_access[id] ? "\w" : "\d";
	
	switch (gTyp[id])
	{
		case 1: szSize = "GLOWSHELL";
		case 2: szSize = "TRANSCOLOR";
		case 3: szSize = "TRANSALPHA"; 
		case 4: szSize = "TRANSWHITE";
		case 5: szSize = "GLOW&ALPHA";
		case 6: szSize = "HOLOGRAM";
		case 7: szSize = "FADEFAST";
	}
	
	format(szMenu, sizeof(szMenu), gRenderMenu, col1, col2, col1, col2, szSize, col1, col2, Transperancy_RM[id], col1, col2, Color_Red_RM[id], col1, col2, Color_Green_RM[id], col1, col2, Color_Blue_RM[id]);
	
	show_menu(id, gRenderMenuKeys, szMenu, -1, "bmRenderMenu");
}
public HandleRenderMenu(id, num)
{
	
	switch ( num )
	{
		case K1:
		{
			if((get_user_flags(id) & ADMIN_LEVEL_D) || g_gived_access[id])
			{	
				MenuRenderingBlock(id);
			}
		}
		case K2: toggleType(id);
		case K3: 
		{
			gRenderInfo[id] = 1;
			client_cmd(id,"messagemode BCM_SetRendering");
		}
		case K4:
		{
			gRenderInfo[id] = 2;
			client_cmd(id,"messagemode BCM_SetRendering");
		}
		case K5:
		{
			gRenderInfo[id] = 3;
			client_cmd(id,"messagemode BCM_SetRendering");
		}
		case K6:
		{
			gRenderInfo[id] = 4;
			client_cmd(id,"messagemode BCM_SetRendering");
		}
		case K0: ShowExtraMenu(id);
	}
	ShowRenderMenu(id);
	if (num == K0)
		ShowMainMenu(id);
	
	return PLUGIN_HANDLED;
}
public MenuRenderingBlock(id)
{
	new ent, body;
	get_user_aiming(id, ent, body);
	
	if(!IsBlock(ent)) return PLUGIN_HANDLED;
	
	new player = entity_get_int(ent, EV_INT_iuser1);
		
	if (player == id)
	{
		BCM_Print(id, "Block in the your group blocks. Remove the entity from the group and try again action!");
	}
	else if(player)
	{
		static player, name[32];
		player = entity_get_int(ent, EV_INT_iuser1);
		get_user_name(player, name, charsmax(name));
		
		BCM_Print(id, "Block in a group blocks by:^1 %s!", name);
	}
	else
	{
		SetBlockRendering(ent, gTyp[id], Color_Red_RM[id], Color_Green_RM[id], Color_Blue_RM[id], Transperancy_RM[id]);
		
		if(gTyp[id] == GLOWSHELL || gTyp[id] == HOLOGRAM)
		{
			Transperancy[ent] = 255;
		}
		else
		{
			Transperancy[ent] = Transperancy_RM[id];
		}
	}
	
	return PLUGIN_HANDLED;
}

stock fm_set_rendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16) 
{
	new Float:RenderColor[3];
	RenderColor[0] = float(r);
	RenderColor[1] = float(g);
	RenderColor[2] = float(b);
	
	set_pev(entity, pev_renderfx, fx);
	set_pev(entity, pev_rendercolor, RenderColor);
	set_pev(entity, pev_rendermode, render);
	set_pev(entity, pev_renderamt, float(amount));
	
	return 1;
}
toggleType(id)
{
	if (gTyp[id] == GLOWSHELL)
	{
		gTyp[id] = TRANSCOLOR;
		return PLUGIN_HANDLED;
	}	
	else if(gTyp[id] == TRANSCOLOR)
	{
		gTyp[id] = TRANSALPHA;
		return PLUGIN_HANDLED;
	}
	else if(gTyp[id] == TRANSALPHA)
	{
		gTyp[id] = TRANSWHITE;
		return PLUGIN_HANDLED;
	}
	else if(gTyp[id] == TRANSWHITE)
	{
		gTyp[id] = GLOWALPHA;
		return PLUGIN_HANDLED;
	}
	else if(gTyp[id] == GLOWALPHA)
	{
		gTyp[id] = HOLOGRAM;
		return PLUGIN_HANDLED;
	}
	else if(gTyp[id] == HOLOGRAM)
	{
		gTyp[id] = FADEFAST;
		return PLUGIN_HANDLED;
	}
	else if(gTyp[id] == FADEFAST)
	{
		gTyp[id] = GLOWSHELL;
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}
// RENDER

ShowMainMenu(id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_D) && !g_gived_access[id])
	{
		CmdShowInfo(id);
		return PLUGIN_HANDLED;
	}
		
	new menu[256], col1[3], col2[3];
	
	col1 = (get_user_flags(id) & ADMIN_LEVEL_D) || g_gived_access[id] ? "\r" : "\d";
	col2 = (get_user_flags(id) & ADMIN_LEVEL_D) || g_gived_access[id] ? "\w" : "\d";
	
	format(menu, charsmax(menu),\
		g_main_menu,\
		PLUGIN_PREFIX,\
		PLUGIN_NAME,\
		PLUGIN_VERSION,\
		col1,\
		col2,\
		g_noclip[id] ? "\yOn" : "\rOff",\
		col1,\
		col2,\
		g_godmode[id] ? "\yOn" : "\rOff",\
		col1,\
		col2
		);
	
	show_menu(id, g_keys_main_menu, menu, -1, "BcmMainMenu");
	
	return PLUGIN_CONTINUE;
}

ShowWeaponsMenu(id)
{
	new menu[256];
	if(g_weapons_page[id] == 1)
	{
		format(menu, charsmax(menu),\
		g_weapons_menu,\
		PLUGIN_PREFIX,\
		PLUGIN_NAME,\
		PLUGIN_VERSION
		);
		
		show_menu(id, g_keys_weapons_menu, menu, -1, "BcmWeaponsMenu");
	}
	else if(g_weapons_page[id] == 2)
	{
		format(menu, charsmax(menu),\
		g_weapons_menu2,\
		PLUGIN_PREFIX,\
		PLUGIN_NAME,\
		PLUGIN_VERSION
		);
		
		show_menu(id, g_keys_weapons_menu2, menu, -1, "BcmWeaponsMenu");
	}
	else if(g_weapons_page[id] == 3)
	{
		format(menu, charsmax(menu),\
		g_weapons_menu3,\
		PLUGIN_PREFIX,\
		PLUGIN_NAME,\
		PLUGIN_VERSION
		);
		
		show_menu(id, g_keys_weapons_menu3, menu, -1, "BcmWeaponsMenu");
	}
}

ShowBlockMenu(id)
{
	new menu[256], col1[3], col2[3], size[8];
	
	col1 = (get_user_flags(id) & ADMIN_LEVEL_D) || g_gived_access[id] ? "\r" : "\d";
	col2 = (get_user_flags(id) & ADMIN_LEVEL_D) || g_gived_access[id] ? "\w" : "\d";
	
	switch ( g_selected_block_size[id] )
	{
		case TINY:	size = "Tiny";
		case NORMAL:	size = "Normal";
		case LARGE:	size = "Large";
		case POLE:	size = "Pole";
	}
	
	format(menu, charsmax(menu),\
		g_block_menu,\
		PLUGIN_PREFIX,\
		g_block_names[g_selected_block_type[id]],\
		size,\
		col1,\
		col2,\
		col1,\
		col2,\
		col1,\
		col2,\
		col1,\
		col2,\
		col1,\
		col2,\
		col1,\
		col2
		);
	
	show_menu(id, g_keys_block_menu, menu, -1, "BcmBlockMenu");
}

ShowBlockSelectionMenu(id)
{
	new menu[256], title[32], entry[32], num;
	
	format(title, charsmax(title), "\r[%s] \yBlock Selection %d^n^n", PLUGIN_PREFIX, g_block_selection_page[id]);
	add(menu, charsmax(menu), title);
	
	new start_block = ( g_block_selection_page[id] - 1 ) * 8;
	
	for ( new i = start_block; i < start_block + 8; ++i )
	{
		if ( i < TOTAL_BLOCKS )
		{
			num = ( i - start_block ) + 1;
			
			format(entry, charsmax(entry), "\r%d. \w%s^n", num, g_block_names[i]);
		}
		else
		{
			format(entry, charsmax(entry), "^n");
		}
		
		add(menu, charsmax(menu), entry);
	}
	
	if ( g_block_selection_page[id] < g_block_selection_pages_max )
	{
		add(menu, charsmax(menu), "^n\r9. \wMore");
	}
	else
	{
		add(menu, charsmax(menu), "^n");
	}
	
	add(menu, charsmax(menu), "^n\r0. \wBack");
	
	show_menu(id, g_keys_block_selection_menu, menu, -1, "BcmBlockSelectionMenu");
}

ShowPropertiesMenu(id, ent)
{
	new menu[256], title[32], entry[64], property[14], line1[3], line2[3], line3[3], line4[3], num, block_type;
	
	block_type = entity_get_int(ent, EV_INT_body);
	
	format(title, charsmax(title), "\r[%s] \ySet Properties^n^n", PLUGIN_PREFIX);
	add(menu, charsmax(menu), title);
	
	if ( g_property1_name[block_type][0] )
	{
		GetProperty(ent, 1, property);
		
		if ( block_type == BUNNYHOP
		|| block_type == NO_SLOW_DOWN_BUNNYHOP
		|| block_type == BUNNYHOP_D )
		{
			format(entry, charsmax(entry), "\r1. \w%s: %s^n", g_property1_name[block_type], property[0] == '1' ? "\yOn" : "\rOff");
		}
		else if ( block_type == CARPET )
		{
			format(entry, charsmax(entry), "\r1. \w%s: \y%s^n", g_property1_name[block_type], property[0] == '6' ? "All" : property[0] == '5' ? "No Vips" : property[0] == '4' ? "Only Vips" : property[0] == '3' ? "Counter-Terrorists" : property[0] == '2' ? "Terrorists" : "Off");
		}
		else if ( block_type == SLAP )
		{
			format(entry, charsmax(entry), "\r1. \w%s: \y%s^n", g_property1_name[block_type], property[0] == '3' ? "High" : property[0] == '2' ? "Medium" : "Low");
		}
		else if ( block_type == CT_BARRIER )
		{
			format(entry, charsmax(entry), "\r1. \w%s: \y%s^n", g_property1_name[block_type], property[0] == '3' ? "No_CT_and_Vips" : property[0] == '2' ? "Only_T_and_Vips" : "Normal");
		}
		else if ( block_type == T_BARRIER )
		{
			format(entry, charsmax(entry), "\r1. \w%s: \y%s^n", g_property1_name[block_type], property[0] == '3' ? "No_T_and_Vips" : property[0] == '2' ? "Only_CT_and_Vips" : "Normal");
		}
		else if ( block_type == VIP_BARRIER )
		{
			format(entry, charsmax(entry), "\r1. \w%s: \y%s^n", g_property1_name[block_type], property[0] == '2' ? "No Vips" : "Vips only");
		}
		else if ( block_type == GRANATA )
		{
			format(entry, charsmax(entry), "\r1. \w%s: \y%s^n", g_property1_name[block_type], property[0] == '4' ? "All Grenades" : property[0] == '3' ? "Flash Grenade" : property[0] == '2' ? "Frost Grenade" : "HE Grenade");
		}
		else if(block_type == WEAPON)
		{
			g_property_info[id][1] = ent;
			format(entry, charsmax(entry), "\r1. \w%s: \y%s^n", g_property1_name[block_type], property[0]);
		}
		else if ( block_type == BLIND_TRAP )
		{
			format(entry, charsmax(entry), "\r1. \w%s: \y%s^n", g_property1_name[block_type], property[0] == '2' ? "No Flashed Vips" : "Flashed all");
		}
		else if ( block_type == EARTHQUAKE )
		{
			format(entry, charsmax(entry), "\r1. \w%s: \y%s^n", g_property1_name[block_type], property[0] == '2' ? "No Earthquake Vips" : "Earthquake all");
		}
		else
		{
			format(entry, charsmax(entry), "\r1. \w%s: \y%s^n", g_property1_name[block_type], property);
		}
		
		add(menu, charsmax(menu), entry);
	}
	else
	{
		format(line1, charsmax(line1), "^n");
	}
	
	if ( g_property2_name[block_type][0] )
	{
		if ( g_property1_name[block_type][0] )
		{
			num = 2;
		}
		else
		{
			num = 1;
		}
		
		GetProperty(ent, 2, property);
		
		if ( block_type == POINT_BLOCK )
		{
			format(entry, charsmax(entry), "\r%d. \w%s: \y%s^n", num, g_property2_name[block_type], property);
		}
		else if (block_type == CARPET)
		{
			format(entry, charsmax(entry), "\r%d. \w%s: \y%s^n", num, g_property2_name[block_type], property[0] == '0' ? "No" : property);
		}
		else
		{	
			format(entry, charsmax(entry), "\r%d. \w%s: \y%s^n", num, g_property2_name[block_type], property);
		}
		
		add(menu, charsmax(menu), entry);
	}
	else
	{
		format(line2, charsmax(line2), "^n");
	}
	
	if ( g_property3_name[block_type][0] )
	{
		if ( g_property1_name[block_type][0] && g_property2_name[block_type][0] )
		{
			num = 3;
		}
		else if ( g_property1_name[block_type][0]
		|| g_property2_name[block_type][0] )
		{
			num = 2;
		}
		else
		{
			num = 1;
		}
		
		GetProperty(ent, 3, property);
		
		format(entry, charsmax(entry), "\r%d. \w%s: \y%s^n", num, g_property3_name[block_type], property);
		
		add(menu, charsmax(menu), entry);
	}
	else
	{
		format(line3, charsmax(line3), "^n");
	}
	
	if ( g_property4_name[block_type][0] )
	{
		if ( g_property1_name[block_type][0] && g_property2_name[block_type][0] && g_property3_name[block_type][0] )
		{
			num = 4;
		}
		else if ( g_property1_name[block_type][0] && g_property2_name[block_type][0]
		|| g_property1_name[block_type][0] && g_property3_name[block_type][0]
		|| g_property2_name[block_type][0] && g_property3_name[block_type][0] )
		{
			num = 3;
		}
		else if ( g_property1_name[block_type][0]
		|| g_property2_name[block_type][0]
		|| g_property3_name[block_type][0] )
		{
			num = 2;
		}
		else
		{
			num = 1;
		}
		
		GetProperty(ent, 4, property);
		
		if(block_type != CARPET){
			format(entry, charsmax(entry), "\r%d. \w%s: %s^n", num, g_property4_name[block_type], property[0] == '1' ? "\yYes" : "\rNo");
		}else{
			format(entry, charsmax(entry), "\r%d. \w%s: \y%d^n", num, g_property4_name[block_type], str_to_num(property));
		}
		
		add(menu, charsmax(menu), entry);
	}
	else
	{
		format(line4, charsmax(line4), "^n");
	}
	
	g_property_info[id][1] = ent;
	
	add(menu, charsmax(menu), line1);
	add(menu, charsmax(menu), line2);
	add(menu, charsmax(menu), line3);
	add(menu, charsmax(menu), line4);
	add(menu, charsmax(menu), "^n^n^n^n^n^n\r0. \wBack");
	
	show_menu(id, g_keys_properties_menu, menu, -1, "BcmPropertiesMenu");
}

ShowMoveMenu(id)
{
	if ( !(get_user_flags(id) & ADMIN_LEVEL_D) && !g_gived_access[id] )
	{
		ShowBlockMenu(id);
		return PLUGIN_HANDLED;
	}
	
	new menu[256];
	
	format(menu, charsmax(menu), g_move_menu, PLUGIN_PREFIX, g_grid_size[id]);
	
	show_menu(id, g_keys_move_menu, menu, -1, "BcmMoveMenu");
	
	return PLUGIN_HANDLED;
}

ShowTeleportMenu(id)
{
	new menu[256], col1[3], col2[3];
	
	col1 = (get_user_flags(id) & ADMIN_LEVEL_D) || g_gived_access[id] ? "\r" : "\d";
	col2 = (get_user_flags(id) & ADMIN_LEVEL_D) || g_gived_access[id] ? "\w" : "\d";
	
	format(menu, charsmax(menu),\
		g_teleport_menu,\
		PLUGIN_PREFIX,\
		col1,\
		col2,\
		g_teleport_start[id] ? "\r" : "\d",\
		g_teleport_start[id] ? "\w" : "\d",\
		col1,\
		col2,\
		col1,\
		col2,\
		col1,\
		col2
		);
	
	show_menu(id, g_keys_teleport_menu, menu, -1, "BcmTeleportMenu");
}

ShowLightMenu(id)
{
	new menu[256], col1[3], col2[3];
	
	col1 = (get_user_flags(id) & ADMIN_LEVEL_D) || g_gived_access[id] ? "\r" : "\d";
	col2 = (get_user_flags(id) & ADMIN_LEVEL_D) || g_gived_access[id] ? "\w" : "\d";
	
	format(menu, charsmax(menu),\
		g_light_menu,\
		PLUGIN_PREFIX,\
		col1,\
		col2,\
		col1,\
		col2,\
		col1,\
		col2
		);
	
	show_menu(id, g_keys_light_menu, menu, -1, "BcmLightMenu");
}

ShowLightPropertiesMenu(id, ent)
{
	new menu[256], radius[5], color_red[5], color_green[5], color_blue[5];
	
	GetProperty(ent, 1, radius);
	GetProperty(ent, 2, color_red);
	GetProperty(ent, 3, color_green);
	GetProperty(ent, 4, color_blue);
	
	format(menu, charsmax(menu),\
		g_light_properties_menu,\
		PLUGIN_PREFIX,\
		radius,\
		color_red,\
		color_green,\
		color_blue
		);
	
	g_light_property_info[id][1] = ent;
	
	show_menu(id, g_keys_light_properties_menu, menu, -1, "BcmLightPropertiesMenu");
}

ShowOptionsMenu(id)
{
	new menu[256], col1[3], col2[3], col3[3], col4[3];
	
	col1 = (get_user_flags(id) & ADMIN_LEVEL_D) || g_gived_access[id] ? "\r" : "\d";
	col2 = (get_user_flags(id) & ADMIN_LEVEL_D) || g_gived_access[id] ? "\w" : "\d";
	col3 = (get_user_flags(id) & ADMIN_LEVEL_D) ? "\r" : "\d";
	col4 = (get_user_flags(id) & ADMIN_LEVEL_D) ? "\w" : "\d";
	
	format(menu, charsmax(menu),\
		g_options_menu,\
		PLUGIN_PREFIX,\
		col1,\
		col2,\
		g_snapping[id] ? "\yOn" : "\rOff",\
		col1,\
		col2,\
		g_snapping_gap[id],\
		col1,\
		col2,\
		col1,\
		col2,\
		col3,\
		col4,\
		col3,\
		col4,\
		col3,\
		col4
		);
	
	show_menu(id, g_keys_options_menu, menu, -1, "BcmOptionsMenu");
}

ShowChoiceMenu(id, choice, const title[96])
{
	new menu[128];
	
	g_choice_option[id] = choice;
	
	format(menu, charsmax(menu), g_choice_menu, title);
	
	show_menu(id, g_keys_choice_menu, menu, -1, "BcmChoiceMenu");
}

ShowCommandsMenu(id)
{
	new menu[256], col1[3], col2[3], col3[3], col4[3], col5[3], col6[3];
	
	col1 = (get_user_flags(id) & ADMIN_LEVEL_D) ? "\r" : "\d";
	col2 = (get_user_flags(id) & ADMIN_LEVEL_D) ? "\w" : "\d";
	col3 = ( (get_user_flags(id) & ADMIN_LEVEL_D) || g_gived_access[id] ) && g_alive[id] ? "\r" : "\d";
	col4 = ( (get_user_flags(id) & ADMIN_LEVEL_D) || g_gived_access[id] ) && g_alive[id] ? "\w" : "\d";
	col5 = (get_user_flags(id) & ADMIN_LEVEL_D) || g_gived_access[id] ? "\r" : "\d";
	col6 = (get_user_flags(id) & ADMIN_LEVEL_D) || g_gived_access[id] ? "\w" : "\d";
	
	format(menu, charsmax(menu),\
		g_commands_menu,\
		PLUGIN_PREFIX,\
		col3,\
		col4,\
		g_alive[id] && g_has_checkpoint[id] ? "\r" : "\d",\
		g_alive[id] && g_has_checkpoint[id] ? "\w" : "\d",\
		( (get_user_flags(id) & ADMIN_LEVEL_D) || g_gived_access[id] ) && !g_alive[id] ? "\r" : "\d",\
		( (get_user_flags(id) & ADMIN_LEVEL_D) || g_gived_access[id] ) && !g_alive[id] ? "\w" : "\d",\
		col5,\
		col6,\
		col1,\
		col2,\
		col1,\
		col2,\
		g_all_godmode ? "Remove" : "Set",\
		g_all_godmode ? "from" : "on",\
		col1,\
		col2,\
		PLUGIN_PREFIX
		);
	
	show_menu(id, g_keys_commands_menu, menu, -1, "BcmCommandsMenu");
}

ShowExtraMenu(id)
{	
	new menu[256];
	format(menu, charsmax(menu), g_extra_menu);
	show_menu(id, g_keys_extra_menu, menu, -1, "BcmExtraMenu");
}
ShowMovementMenu(id)
{	
	new menu[256];
	format(menu, charsmax(menu), g_movement_menu, g_Distance[id], floatround(g_Axis[id][0]), floatround(g_Axis[id][1]), floatround(g_Axis[id][2]));
	show_menu(id, g_keys_movement_menu, menu, -1, "BcmMovementMenu");
}
ShowSkipMenu(id){
	new menu[256];
	if(user_skip_time[id] != 1337){
		new pre_string[16]; formatex(pre_string, charsmax(pre_string), "%.1f", user_skip_time[id]);
		format(menu, charsmax(menu), g_skip_menu, pre_string);
	}else format(menu, charsmax(menu), g_skip_menu, "instantly");
	show_menu(id, g_keys_skip_menu, menu, -1, "BcmSkipMenu");
}
ShowRotateMenu(id)
{	
	new menu[256];
	format(menu, charsmax(menu), g_rotate_menu, user_rotate_time[id]);
	show_menu(id, g_keys_rotate_menu, menu, -1, "BcmRotateMenu");
}

public HandleMainMenu(id, key)
{
	switch ( key )
	{
		case K1: ShowBlockMenu(id);
		case K2: ShowTeleportMenu(id);
		case K3: ShowLightMenu(id);
		case K4: ShowOptionsMenu(id);
		case K5:
		{
			g_viewing_commands_menu[id] = true;
			ShowCommandsMenu(id);
		}
		case K6: ToggleNoclip(id);
		case K7: ToggleGodmode(id);
		case K8: ShowExtraMenu(id);
		case K9: CmdShowInfo(id);
		case K0: return;
	}
	
	if ( key == K6 || key == K7 || key == K9 ) ShowMainMenu(id);
}

public HandleWeaponsMenu(id, key)
{
	new ent = g_property_info[id][1];
	if(g_weapons_page[id] == 1)
	{
		switch ( key )
		{
			case K1: SetProperty(ent, 1, "p228");
			case K2: SetProperty(ent, 1, "scout");
			case K3: SetProperty(ent, 1, "xm1014");
			case K4: SetProperty(ent, 1, "mac10");
			case K5: SetProperty(ent, 1, "aug");
			case K6: SetProperty(ent, 1, "elite");
			case K7: SetProperty(ent, 1, "fiveseven");
			case K8: SetProperty(ent, 1, "ump45");
			case K9: 
			{
				g_weapons_page[id] = 2;
				ShowWeaponsMenu(id);
			}	
			case K0: 
			{
				ShowBlockMenu(id);
			}
		}
	}
	else if(g_weapons_page[id] == 2)
	{
		switch ( key )
		{
			case K1: SetProperty(ent, 1, "sg550");
			case K2: SetProperty(ent, 1, "galil");
			case K3: SetProperty(ent, 1, "famas");
			case K4: SetProperty(ent, 1, "usp");
			case K5: SetProperty(ent, 1, "glock18");
			case K6: SetProperty(ent, 1, "awp");
			case K7: SetProperty(ent, 1, "mp5navy");
			case K8: SetProperty(ent, 1, "m249");
			case K9: 
			{
				g_weapons_page[id] = 3;
				ShowWeaponsMenu(id);
			}
			case K0:
			{
				g_weapons_page[id] = 1;
				ShowWeaponsMenu(id);
			}
		}
	}
	else if(g_weapons_page[id] == 3)
	{
		switch ( key )
		{
			case K1: SetProperty(ent, 1, "m3");
			case K2: SetProperty(ent, 1, "m4a1");
			case K3: SetProperty(ent, 1, "tmp");
			case K4: SetProperty(ent, 1, "g3sg1");
			case K5: SetProperty(ent, 1, "deagle");
			case K6: SetProperty(ent, 1, "sg552");
			case K7: SetProperty(ent, 1, "ak47");
			case K8: SetProperty(ent, 1, "p90");
			case K9: 
			{
				g_weapons_page[id] = 3;
				CmdShowInfo(id);
			}	
			case K0: 
			{
				g_weapons_page[id] = 2;
				ShowWeaponsMenu(id);
			}
		}
	}	
}

public HandleBlockMenu(id, key)
{
	switch ( key )
	{
		case K1:
		{
			g_block_selection_page[id] = 1;
			ShowBlockSelectionMenu(id);
		}
		case K2: ChangeBlockSize(id);
		case K3: CreateBlockAiming(id, g_selected_block_type[id]);
		case K4: ConvertBlockAiming(id, g_selected_block_type[id]);
		case K5: DeleteBlockAiming(id);
		case K6: RotateBlockAiming(id);
		case K7: SetPropertiesBlockAiming(id);
		case K8: ShowMoveMenu(id);
		case K0: ShowMainMenu(id);
	}
	
	if ( key != K1 && key != K7 && key != K8 && key != K0 ) ShowBlockMenu(id);
}

public HandleBlockSelectionMenu(id, key)
{
	switch ( key )
	{
		case K9:
		{
			++g_block_selection_page[id];
			
			if ( g_block_selection_page[id] > g_block_selection_pages_max )
			{
				g_block_selection_page[id] = g_block_selection_pages_max;
			}
			
			ShowBlockSelectionMenu(id);
		}
		case K0:
		{
			--g_block_selection_page[id];
			
			if ( g_block_selection_page[id] < 1 )
			{
				ShowBlockMenu(id);
			}
			else
			{
				ShowBlockSelectionMenu(id);
			}
		}
		default:
		{
			key += ( g_block_selection_page[id] - 1 ) * 8;
			
			if ( key < TOTAL_BLOCKS )
			{
				g_selected_block_type[id] = key;
				ShowBlockMenu(id);
			}
			else
			{
				ShowBlockSelectionMenu(id);
			}
		}
	}
}

public HandlePropertiesMenu(id, key)
{
	new ent = g_property_info[id][1];
	if ( !is_valid_ent(ent) )
	{
		BCM_Print(id, "That block has been deleted!");
		g_viewing_properties_menu[id] = false;
		ShowBlockMenu(id);
		return PLUGIN_HANDLED;
	}
	
	new block_type = entity_get_int(ent, EV_INT_body);
	
	switch ( key )
	{
		case K1:
		{
			if ( g_property1_name[block_type][0] )
			{
				g_property_info[id][0] = 1;
			}
			else if ( g_property2_name[block_type][0] )
			{
				g_property_info[id][0] = 2;
			}
			else if ( g_property3_name[block_type][0] )
			{
				g_property_info[id][0] = 3;
			}
			else
			{
				g_property_info[id][0] = 4;
			}
			
			if ( g_property_info[id][0] == 1
			&& ( block_type == BUNNYHOP
			|| block_type == BUNNYHOP_D
			|| block_type == CARPET
			|| block_type == SLAP
			|| block_type == NO_SLOW_DOWN_BUNNYHOP 
			|| block_type == CT_BARRIER
			|| block_type == T_BARRIER
			|| block_type == VIP_BARRIER
			|| block_type == GRANATA
			|| block_type == BLIND_TRAP
			|| block_type == EARTHQUAKE ) )
			{
				ToggleProperty(id, 1);
			}
			else if(g_property_info[id][0] == 1 && block_type == WEAPON)
			{
				ShowWeaponsMenu(id);
				return PLUGIN_CONTINUE;
			}
			else if ( g_property_info[id][0] == 4 )
			{
				ToggleProperty(id, 4);
			}
			else
			{
				BCM_Print(id, "Type the new property value for the block.%s", g_property_info[id][0] == 3 && block_type != BOOTS_OF_SPEED ? "^1 0^3 and^1 255^3 will turn transparency off." : g_blank);
				client_cmd(id, "messagemode BCM_SetProperty");
			}
		}
		case K2:
		{
			if ( g_property1_name[block_type][0] && g_property2_name[block_type][0]
			|| g_property1_name[block_type][0] && g_property3_name[block_type][0]
			|| g_property1_name[block_type][0] && g_property4_name[block_type][0]
			|| g_property2_name[block_type][0] && g_property3_name[block_type][0]
			|| g_property2_name[block_type][0] && g_property4_name[block_type][0]
			|| g_property3_name[block_type][0] && g_property4_name[block_type][0] )
			{
				if ( g_property1_name[block_type][0] && g_property2_name[block_type][0] )
				{
					g_property_info[id][0] = 2;
				}
				else if ( g_property1_name[block_type][0] && g_property3_name[block_type][0]
				|| g_property2_name[block_type][0] && g_property3_name[block_type][0] )
				{
					g_property_info[id][0] = 3;
				}
				else
				{
					g_property_info[id][0] = 4;
				}
				
				if ( g_property_info[id][0] == 4 )
				{
					ToggleProperty(id, 4);
				}
				else
				{
					BCM_Print(id, "Type the new property value for the block.%s", g_property_info[id][0] == 3 && block_type != BOOTS_OF_SPEED ? "^1 0^3 and^1 255^3 will turn transparency off." : g_blank);
					client_cmd(id, "messagemode BCM_SetProperty");
				}
			}
		}
		case K3:
		{
			if ( g_property1_name[block_type][0] && g_property2_name[block_type][0] && g_property3_name[block_type][0]
			|| g_property1_name[block_type][0] && g_property2_name[block_type][0] && g_property4_name[block_type][0]
			|| g_property1_name[block_type][0] && g_property3_name[block_type][0] && g_property4_name[block_type][0]
			|| g_property2_name[block_type][0] && g_property3_name[block_type][0] && g_property4_name[block_type][0] )
			{
				if ( g_property1_name[block_type][0] && g_property2_name[block_type][0] && g_property3_name[block_type][0] )
				{
					g_property_info[id][0] = 3;
				}
				else
				{
					g_property_info[id][0] = 4;
				}
				
				if ( g_property_info[id][0] == 4 )
				{
					ToggleProperty(id, 4);
				}
				else
				{
					BCM_Print(id, "Type the new property value for the block.%s", g_property_info[id][0] == 3 && block_type != BOOTS_OF_SPEED ? "^1 0^3 and^1 255^3 will turn transparency off." : g_blank);
					client_cmd(id, "messagemode BCM_SetProperty");
				}
			}
		}
		case K4:
		{
			if ( g_property1_name[block_type][0] && g_property2_name[block_type][0] && g_property3_name[block_type][0] && g_property4_name[block_type][0] )
			{
				if( block_type == BLIND_TRAP || block_type == CARPET )
				{
					BCM_Print(id, "Type the new property value for the block");
					client_cmd(id, "messagemode BCM_SetProperty");
					g_property_info[id][0] = 4;
				}
				else
				{
					ToggleProperty(id, 4);
				}
			}
		}
		case K0:
		{
			g_viewing_properties_menu[id] = false;
			ShowBlockMenu(id);
		}
	}
	
	if ( key != K0 ) ShowPropertiesMenu(id, ent);
	
	return PLUGIN_HANDLED;
}

public HandleMoveMenu(id, key)
{
	switch ( key )
	{
		case K1: ToggleGridSize(id);
		case K0: ShowBlockMenu(id);
		default:
		{
			static ent, body;
			get_user_aiming(id, ent, body);
			
			if ( !IsBlock(ent) ) return PLUGIN_HANDLED;
			
			static Float:origin[3];
			
			if ( IsBlockInGroup(id, ent) && g_group_count[id] > 1 )
			{
				static i, block;
				
				new bool:group_is_stuck = true;
				
				for ( i = 0; i <= g_group_count[id]; ++i )
				{
					block = g_grouped_blocks[id][i];
					if ( IsBlockInGroup(id, block) )
					{
						entity_get_vector(block, EV_VEC_origin, origin);
						
						switch ( key )
						{
							case K2: origin[2] += g_grid_size[id];
							case K3: origin[2] -= g_grid_size[id];
							case K4: origin[0] += g_grid_size[id];
							case K5: origin[0] -= g_grid_size[id];
							case K6: origin[1] += g_grid_size[id];
							case K7: origin[1] -= g_grid_size[id];
						}
						
						MoveEntity(id, block, origin, false);
						
						if ( group_is_stuck && !IsBlockStuck(block) )
						{
							group_is_stuck = false;
							break;
						}
					}
				}
				
				if ( group_is_stuck )
				{
					for ( i = 0; i <= g_group_count[id]; ++i )
					{
						block = g_grouped_blocks[id][i];
						if ( IsBlockInGroup(id, block) )
						{
							DeleteBlock(block);
						}
					}
					
					BCM_Print(id, "Group deleted because all the blocks were stuck!");
				}
			}
			else
			{
				entity_get_vector(ent, EV_VEC_origin, origin);
				
				switch ( key )
				{
					case K2: origin[2] += g_grid_size[id];
					case K3: origin[2] -= g_grid_size[id];
					case K4: origin[0] += g_grid_size[id];
					case K5: origin[0] -= g_grid_size[id];
					case K6: origin[1] += g_grid_size[id];
					case K7: origin[1] -= g_grid_size[id];
				}
				
				MoveEntity(id, ent, origin, false);
				
				if ( IsBlockStuck(ent) )
				{
					new bool:deleted = DeleteBlock(ent);
					if ( deleted ) BCM_Print(id, "Block deleted because it was stuck!");
				}
			}
		}
	}
	
	if ( key != K0 ) ShowMoveMenu(id);
	
	return PLUGIN_HANDLED;
}

public HandleTeleportMenu(id, key)
{
	switch ( key )
	{
		case K1: CreateTeleportAiming(id, TELEPORT_START);
		case K2: CreateTeleportAiming(id, TELEPORT_DESTINATION);
		case K3: DeleteTeleportAiming(id);
		case K4: SwapTeleportAiming(id);
		case K5: ShowTeleportPath(id);
		case K0: ShowMainMenu(id);
	}
	
	if ( key != K9 && key != K0 ) ShowTeleportMenu(id);
}

public HandleLightMenu(id, key)
{
	switch ( key )
	{
		case K1: CreateLightAiming(id);
		case K2: DeleteLightAiming(id);
		case K3: SetPropertiesLightAiming(id);
		case K0: ShowMainMenu(id);
	}
	
	if ( key != K3 && key != K0 ) ShowLightMenu(id);
}

public HandleLightPropertiesMenu(id, key)
{
	new ent = g_light_property_info[id][1];
	if ( !is_valid_ent(ent) )
	{
		BCM_Print(id, "That light has been deleted!");
		g_viewing_light_properties_menu[id] = false;
		ShowLightMenu(id);
		return PLUGIN_HANDLED;
	}
	
	switch ( key )
	{
		case K1: g_light_property_info[id][0] = 1;
		case K2: g_light_property_info[id][0] = 2;
		case K3: g_light_property_info[id][0] = 3;
		case K4: g_light_property_info[id][0] = 4;
		case K0:
		{
			g_viewing_light_properties_menu[id] = false;
			ShowLightMenu(id);
		}
	}
	
	if ( key != K0 )
	{
		BCM_Print(id, "Type the new property value for the light.");
		client_cmd(id, "messagemode BCM_SetLightProperty");
		ShowLightPropertiesMenu(id, ent);
	}
	
	return PLUGIN_HANDLED;
}

public HandleOptionsMenu(id, key)
{
	switch ( key )
	{
		case K1: ToggleSnapping(id);
		case K2: ToggleSnappingGap(id);
		case K3: GroupBlockAiming(id);
		case K4: ClearGroup(id);
		case K5:
		{
			ShowChoiceMenu(id, CHOICE_DELETE, "Are you sure you want to delete all blocks and teleports?");
		}
		case K6: 
		{
			index_menu[id] = 0;
			ShowModsMenu(id);
		}
		case K7:
		{
			index_menu[id] = 1;
			ShowModsMenu(id);
		}
		case K0: ShowMainMenu(id);
	}
	
	if ( key != K5 && key != K7 && key != K0 && key != K6) ShowOptionsMenu(id);
}

public HandleChoiceMenu(id, key)
{
	switch ( key )
	{
		case K1:
		{
			switch ( g_choice_option[id] )
			{
				case CHOICE_DELETE:	DeleteAll(id, true);
				case CHOICE_LOAD: LoadBlocks(id);
			}
		}
		case K2: ShowOptionsMenu(id);
	}
	
	ShowOptionsMenu(id);
}

public HandleCommandsMenu(id, key)
{
	switch ( key )
	{
		case K1: CmdSaveCheckpoint(id);
		case K2: CmdLoadCheckpoint(id);
		case K3: CmdReviveYourself(id);
		case K4: CmdRevivePlayer(id);
		case K5: CmdReviveEveryone(id);
		case K6: ToggleAllGodmode(id);
		case K7: CmdGiveAccess(id);
		case K0:
		{
			g_viewing_commands_menu[id] = false;
			ShowMainMenu(id);
		}
	}
	
	if ( key != K0 ) ShowCommandsMenu(id);
}

public HandleExtraMenu(id, key)
{
	switch ( key )
	{
		case K1: ShowRenderMenu(id);
		case K2: ShowMovementMenu(id);
		case K3: ShowRotateMenu(id);
		case K4: ShowSkipMenu(id);
		case K0: ShowMainMenu(id);
	}
}

public HandleSkipMenu(id, key)
{
	switch ( key )
	{
		case K1: 
		{
			new ent, body;
			get_user_aiming(id, ent, body);
			
			if(IsBlock(ent) && user_skip_time[id] > 0.0 || user_skip_time[id] == 1337.0)
			{
				if(ent_rotate_time[ent] > 0.0 && task_exists(TASK_ICE + ent)){
					ent_rotate_time[ent] = 0.0;
					remove_task(TASK_ICE + ent);
				}
				
				new block_type = entity_get_int(ent, EV_INT_body);
				
				if(block_type != BUNNYHOP && block_type != BUNNYHOP_D && block_type != NO_SLOW_DOWN_BUNNYHOP && block_type != DELAYED_BUNNYHOP && block_type != T_BARRIER && block_type != CT_BARRIER && block_type != VIP_BARRIER)
				{
					if(ent_skip_time[ent] > 0.0){
						ent_skip_time[ent] = 0.0;
						if(task_exists(TASK_SOLID_NOT + ent)) remove_task(TASK_SOLID_NOT + ent);
					}
					
					ent_skip_time[ent] = user_skip_time[id];
					
					if(user_skip_time[id] != 1337.0){
						BCM_Print(id, "You`ve added skip-effect to the block for %.1f!", user_skip_time[id]);
					}else{
						BCM_Print(id, "You`ve added instantly skip-effect to the block!");
					}
				}
				else
				{
					BCM_Print(id, "This block is bunnyhop or barrier, retard!");
				}
			}
		}
		case K2: 
		{
			new ent, body;
			get_user_aiming(id, ent, body);
			
			if(IsBlock(ent) && ent_skip_time[ent] > 0.0)
			{
				ent_skip_time[ent] = 0.0;
				if(task_exists(TASK_SOLID_NOT + ent)) remove_task(TASK_SOLID_NOT + ent);
				BCM_Print(id, "You deleted skip-effect from block!");
			}
			else
			{
				BCM_Print(id, "Error! Block doesn`t have skip-effect or doesn`t exist!");
			}
		}
		case K3: client_cmd(id,"messagemode Set_SkipTime");
		case K0:
		{
			ShowExtraMenu(id);
		}
	}
	
	if ( key != K0 ) ShowSkipMenu(id);
}

public HandleMovementMenu(id, key)
{
	switch ( key )
	{
		case K1:
		{
			new ent, body;
			get_user_aiming(id, ent, body);
			if(IsBlock(ent))
			{
				pev(ent, pev_origin, g_origin[ent]);
				set_pev(ent, pev_movetype, MOVETYPE_FLY);
				
				Velocity[ent][0] = g_Axis[id][0];
				Velocity[ent][1] = g_Axis[id][1];
				Velocity[ent][2] = g_Axis[id][2];
				b_Distance[ent] = g_Distance[id];
				
				set_pev(ent, pev_velocity, Velocity);
				set_pev(ent, pev_nextthink, get_gametime() + 0.02);
			}
		}
		case K2:
		{
			MovementType[id] = 1;
			client_cmd(id,"messagemode Set_Movement");
		}
		case K3: 
		{
			MovementType[id] = 2;
			client_cmd(id,"messagemode Set_Movement");
		}
		case K4: 
		{
			MovementType[id] = 3;
			client_cmd(id,"messagemode Set_Movement");
		}
		case K5: 
		{
			MovementType[id] = 4;
			client_cmd(id,"messagemode Set_Movement");
		}
		case K0: ShowExtraMenu(id);
	}
	
	if(key != 0)
		ShowMovementMenu(id);
}

public HandleRotateMenu(id, key)
{
	switch ( key )
	{
		case K1: 
		{
			new ent, body;
			get_user_aiming(id, ent, body);
			
			if(IsBlock(ent) && user_rotate_time[id] > 0)
			{
				if(ent_rotate_time[ent] > 0.0 && task_exists(TASK_ICE + ent)){
					ent_rotate_time[ent] = 0.0;
					remove_task(TASK_ICE + ent);
				}
				
				if(ent_skip_time[ent] > 0.0){
					ent_skip_time[ent] = 0.0;
					if(task_exists(TASK_SOLID_NOT + ent)) remove_task(TASK_SOLID_NOT + ent);
				}
			
				ent_rotate_time[ent] = user_rotate_time[id];
				set_task(ent_rotate_time[ent], "RotateEntity", TASK_ICE + ent, _, _, "b");
				ent_rotate_time_start[ent] = get_gametime() + ent_rotate_time[ent];
				BCM_Print(id, "You`ve added rotate-effect to the block for %.1f!", user_rotate_time[id]);
			}
		}
		case K2: 
		{
			new ent, body;
			get_user_aiming(id, ent, body);
			if(IsBlock(ent) && ent_rotate_time[ent] > 0 && task_exists(TASK_ICE + ent))
			{
				ent_rotate_time[ent] = 0.0;
				remove_task(TASK_ICE + ent);
				
				BCM_Print(id, "You`ve deleted rotate-effect from block!");
			}
			else
			{
				BCM_Print(id, "Error! Block doesn`t have rotate-effect or doesn`t exist!");
			}
		}
		case K3: client_cmd(id,"messagemode Set_RotateTime");
		case K0:
		{
			ShowExtraMenu(id);
		}
	}
	
	if ( key != K0 ) ShowRotateMenu(id);
}

ToggleNoclip(id)
{
	if ( (get_user_flags(id) & ADMIN_LEVEL_D) || g_gived_access[id] )
	{
		set_user_noclip(id, g_noclip[id] ? 0 : 1);
		g_noclip[id] = !g_noclip[id];
		
		new Name[32];
		
		get_user_name(id, Name, 31);
		
		if( (get_user_flags(id) & ADMIN_LEVEL_D) && g_noclip[id] )
		{
			BCM_Print(0, "Admin '%s' On Noclip!!!", Name);
		}
		if( (get_user_flags(id) & ADMIN_LEVEL_D) && !g_noclip[id] )
		{
			BCM_Print(0, "Admin '%s' Off Noclip!!!", Name);
		}
		if( !(get_user_flags(id) & ADMIN_LEVEL_D) && g_gived_access[id] && g_noclip[id]  )
		{
			BCM_Print(0, "Player '%s' On Noclip!!!", Name);
		}
		if( !(get_user_flags(id) & ADMIN_LEVEL_D) && g_gived_access[id] && !g_noclip[id]  )
		{
			BCM_Print(0, "Player '%s' Off Noclip!!!", Name);
		}
	}
}

ToggleGodmode(id)
{
	if ( (get_user_flags(id) & ADMIN_LEVEL_D) || g_gived_access[id] )
	{
		set_user_godmode(id, g_godmode[id] ? 0 : 1);
		g_godmode[id] = !g_godmode[id];
		
		new Name[32];
		
		get_user_name(id, Name, 31);
		
		if( (get_user_flags(id) & ADMIN_LEVEL_D) && g_godmode[id] )
		{
			BCM_Print(0, "Admin '%s' On Godmode!!!", Name);
		}
		if( (get_user_flags(id) & ADMIN_LEVEL_D) && !g_godmode[id] )
		{
			BCM_Print(0, "Admin '%s' Off Godmode!!!", Name);
		}
		if( !(get_user_flags(id) & ADMIN_LEVEL_D) && g_gived_access[id] && g_godmode[id] )
		{
			BCM_Print(0, "Player '%s' On Godmode!!!", Name);
		}
		if( !(get_user_flags(id) & ADMIN_LEVEL_D) && g_gived_access[id] && !g_godmode[id] )
		{
			BCM_Print(0, "Player '%s' Off Godmode!!!", Name);
		}
	}
}

ToggleGridSize(id)
{
	g_grid_size[id] *= 2;
	
	if(g_grid_size[id] > 64)
	{
		g_grid_size[id] = 1.0;
	}
}

ToggleSnapping(id)
{
	if ( (get_user_flags(id) & ADMIN_LEVEL_D) || g_gived_access[id] )
	{
		g_snapping[id] = !g_snapping[id];
	}
}

ToggleSnappingGap(id)
{
	if ( (get_user_flags(id) & ADMIN_LEVEL_D) || g_gived_access[id] )
	{
		g_snapping_gap[id] += 4.0;
		
		if ( g_snapping_gap[id] > 40.0 )
		{
			g_snapping_gap[id] = 0.0;
		}
	}
}

public CmdSaveCheckpoint(id)
{
	if ( !(get_user_flags(id) & ADMIN_LEVEL_D) && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	else if ( !g_alive[id] )
	{
		BCM_Print(id, "You have to be alive to save a checkpoint!");
		return PLUGIN_HANDLED;
	}
	else if ( g_noclip[id] )
	{
		BCM_Print(id, "You can't save a checkpoint while using noclip!");
		return PLUGIN_HANDLED;
	}
	
	static Float:velocity[3];
	get_user_velocity(id, velocity);
	
	new button =	entity_get_int(id, EV_INT_button);
	new flags =	entity_get_int(id, EV_INT_flags);
	
	if ( !( ( velocity[2] >= 0.0 || ( flags & FL_INWATER ) ) && !( button & IN_JUMP ) && velocity[2] <= 0.0 ) )
	{
		BCM_Print(id, "You can't save a checkpoint while moving up or down!");
		return PLUGIN_HANDLED;
	}
	
	if ( flags & FL_DUCKING )	g_checkpoint_duck[id] = true;
	else				g_checkpoint_duck[id] = false;
	
	entity_get_vector(id, EV_VEC_origin, g_checkpoint_position[id]);
	
	BCM_Print(id, "Checkpoint saved!");
	
	if ( !g_has_checkpoint[id] )		g_has_checkpoint[id] = true;
	
	if ( g_viewing_commands_menu[id] )	ShowCommandsMenu(id);
	
	return PLUGIN_HANDLED;
}

public CmdLoadCheckpoint(id)
{
	if ( !(get_user_flags(id) & ADMIN_LEVEL_D) && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	else if ( !g_alive[id] )
	{
		BCM_Print(id, "You have to be alive to load a checkpoint!");
		return PLUGIN_HANDLED;
	}
	else if ( !g_has_checkpoint[id] )
	{
		BCM_Print(id, "You don't have a checkpoint!");
		return PLUGIN_HANDLED;
	}
	
	static Float:origin[3];
	for ( new i = 1; i <= g_max_players; i++ )
	{
		if ( i == id
		|| !g_alive[i] ) continue;
		
		entity_get_vector(id, EV_VEC_origin, origin);
		
		if ( get_distance_f(g_checkpoint_position[id], origin) <= 35.0 )
		{
			if ( cs_get_user_team(i) == cs_get_user_team(id) ) continue;
			
			BCM_Print(id, "Somebody is too close to your checkpoint!");
			return PLUGIN_HANDLED;
		}
	}
	
	entity_set_vector(id, EV_VEC_origin, g_checkpoint_position[id]);
	entity_set_vector(id, EV_VEC_velocity, Float:{ 0.0, 0.0, 0.0 });
	
	if ( g_checkpoint_duck[id] )
	{
		entity_set_int(id, EV_INT_flags, entity_get_int(id, EV_INT_flags) | FL_DUCKING);
	}
	
	return PLUGIN_HANDLED;
}

public CmdReviveYourself(id)
{
	if ( !(get_user_flags(id) & ADMIN_LEVEL_D) && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	else if ( g_alive[id] )
	{
		BCM_Print(id, "You are already alive!");
		return PLUGIN_HANDLED;
	}
	
	ExecuteHam(Ham_CS_RoundRespawn, id);
	BCM_Print(id, "You have revived yourself!");
	
	static name[32];
	get_user_name(id, name, charsmax(name));
	
	for ( new i = 1; i <= g_max_players; i++ )
	{
		if ( !g_connected[i]
		|| i == id ) continue;
		
		BCM_Print(i, "^1%s^3 revived himself!", name);
	}
	
	return PLUGIN_HANDLED;
}

CmdRevivePlayer(id)
{
	if ( !(get_user_flags(id) & ADMIN_LEVEL_D) && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	client_cmd(id, "messagemode BCM_Revive");
	BCM_Print(id, "Type the name of the client that you want to revive.");
	
	return PLUGIN_HANDLED;
}

public RevivePlayer(id)
{
	if ( !(get_user_flags(id) & ADMIN_LEVEL_D) && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static arg[32], target;
	read_argv(1, arg, charsmax(arg));
	
	target = cmd_target(id, arg, CMDTARGET_NO_BOTS);
	if ( !target ) return PLUGIN_HANDLED;
	else if ( id == target )
	{
		CmdReviveYourself(id);
		return PLUGIN_HANDLED;
	}
	
	static target_name[32];
	get_user_name(target, target_name, charsmax(target_name));
	
	if ( (get_user_flags(target) & ADMIN_LEVEL_D)
	|| g_gived_access[target] )
	{
		BCM_Print(id, "^1%s^3 is admin, he can revive himself!", target_name);
		return PLUGIN_HANDLED;
	}
	else if ( g_alive[target] )
	{
		BCM_Print(id, "^1%s^3 is already alive!", target_name);
		return PLUGIN_HANDLED;
	}
	
	ExecuteHam(Ham_CS_RoundRespawn, target);
	
	static admin_name[32];
	get_user_name(id, admin_name, charsmax(admin_name));
	
	BCM_Print(id, "You revived^1 %s^3!", target_name);
	
	for ( new i = 1; i <= g_max_players; i++ )
	{
		if ( !g_connected[i]
		|| i == id
		|| i == target ) continue;
		
		BCM_Print(i, "^1%s^3 revived^1 %s^3!", admin_name, target_name);
	}
	
	BCM_Print(target, "You have been revived by^1 %s^3!", admin_name);
	
	return PLUGIN_HANDLED;
}

CmdReviveEveryone(id)
{
	if ( !(get_user_flags(id) & ADMIN_LEVEL_D) )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	for ( new i = 1; i <= g_max_players; i++ )
	{
		if ( !g_connected[i]
		|| (get_user_flags(i) & ADMIN_LEVEL_D)
		|| g_gived_access[i]
		|| g_alive[i] ) continue;
		
		ExecuteHam(Ham_CS_RoundRespawn, i);
	}
	
	static admin_name[32];
	get_user_name(id, admin_name, charsmax(admin_name));
	
	BCM_Print(0, "^1%s^3 revived everyone!", admin_name);
	
	return PLUGIN_HANDLED;
}

ToggleAllGodmode(id)
{
	if ( !(get_user_flags(id) & ADMIN_LEVEL_D) )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	for ( new i = 1; i <= g_max_players; i++ )
	{
		if ( !g_connected[i] ) continue;
		
		if ( g_alive[i]
		&& !(get_user_flags(i) & ADMIN_LEVEL_D)
		&& !g_gived_access[i] )
		{
			entity_set_float(i, EV_FL_takedamage, g_all_godmode ? DAMAGE_AIM : DAMAGE_NO);
		}
		
		if ( g_viewing_commands_menu[i] ) ShowCommandsMenu(i);
	}
	
	g_all_godmode = !g_all_godmode;
	
	static admin_name[32];
	get_user_name(id, admin_name, charsmax(admin_name));
	
	if ( g_all_godmode )	BCM_Print(0, "^1%s^3 set godmode on everyone!", admin_name);
	else			BCM_Print(0, "^1%s^3 removed godmode from everyone!", admin_name);
	
	return PLUGIN_HANDLED;
}

CmdGiveAccess(id)
{
	if ( !(get_user_flags(id) & ADMIN_LEVEL_D) )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	client_cmd(id, "messagemode BCM_GiveAccess");
	BCM_Print(id, "Type the name of the client that you want to give access to %s.", PLUGIN_PREFIX);
	
	return PLUGIN_HANDLED;
}

public GiveAccess(id)
{
	if ( !(get_user_flags(id) & ADMIN_LEVEL_D) )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static arg[32], target;
	read_argv(1, arg, charsmax(arg));
	
	target = cmd_target(id, arg, CMDTARGET_NO_BOTS);
	if ( !target ) return PLUGIN_HANDLED;
	
	static target_name[32];
	get_user_name(target, target_name, charsmax(target_name));
	
	if ( (get_user_flags(target) & ADMIN_LEVEL_D) || g_gived_access[target] )
	{
		BCM_Print(id, "^1%s^3 already have access to %s!", target_name, PLUGIN_PREFIX);
		return PLUGIN_HANDLED;
	}
	
	g_gived_access[target] = true;
	
	BCM_Print(id, "You gived^1 %s^3 access to %s!", target_name, PLUGIN_PREFIX);
	
	static admin_name[32];
	get_user_name(id, admin_name, charsmax(admin_name));
	
	BCM_Print(target, "^1%s^3 has gived you access to %s! Type^1 /bm^3 to bring up the Main Menu.", admin_name, PLUGIN_PREFIX );
	
	for ( new i = 1; i <= g_max_players; i++ )
	{
		if ( i == id
		|| i == target
		|| !g_connected[i] ) continue;
		
		BCM_Print(i, "^1%s^3 gived^1 %s^3 access to %s!", admin_name, target_name, PLUGIN_PREFIX);
	}
	
	return PLUGIN_HANDLED;
}

public CmdShowInfo(id)
{
	static text[1120], len, title[64];
	
	len += format(text[len], charsmax(text) - len, "<html>");
	
	len += format(text[len], charsmax(text) - len, "<style type = ^"text/css^">");
	
	len += format(text[len], charsmax(text) - len, "body");
	len += format(text[len], charsmax(text) - len, "{");
	len += format(text[len], charsmax(text) - len, 	"background-color:#000000;");
	len += format(text[len], charsmax(text) - len,	"font-family:Comic Sans MS;");
	len += format(text[len], charsmax(text) - len,	"font-weight:bold;");
	len += format(text[len], charsmax(text) - len, "}");
	
	len += format(text[len], charsmax(text) - len, "h1");
	len += format(text[len], charsmax(text) - len, "{");
	len += format(text[len], charsmax(text) - len,	"color:#00FF00;");
	len += format(text[len], charsmax(text) - len,	"font-size:large;");
	len += format(text[len], charsmax(text) - len, "}");
	
	len += format(text[len], charsmax(text) - len, "h2");
	len += format(text[len], charsmax(text) - len, "{");
	len += format(text[len], charsmax(text) - len,	"color:#00FF00;");
	len += format(text[len], charsmax(text) - len,	"font-size:medium;");
	len += format(text[len], charsmax(text) - len, "}");
	
	len += format(text[len], charsmax(text) - len, "h3");
	len += format(text[len], charsmax(text) - len, "{");
	len += format(text[len], charsmax(text) - len,	"color:#0096FF;");
	len += format(text[len], charsmax(text) - len,	"font-size:medium;");
	len += format(text[len], charsmax(text) - len, "}");
	
	len += format(text[len], charsmax(text) - len, "h4");
	len += format(text[len], charsmax(text) - len, "{");
	len += format(text[len], charsmax(text) - len,	"color:#FFFFFF;");
	len += format(text[len], charsmax(text) - len,	"font-size:medium;");
	len += format(text[len], charsmax(text) - len, "}");
	
	len += format(text[len], charsmax(text) - len, "h5");
	len += format(text[len], charsmax(text) - len, "{");
	len += format(text[len], charsmax(text) - len,	"color:#FFFFFF;");
	len += format(text[len], charsmax(text) - len,	"font-size:x-small;");
	len += format(text[len], charsmax(text) - len, "}");
	
	len += format(text[len], charsmax(text) - len, "</style>");
	
	len += format(text[len], charsmax(text) - len, "<body>");
	len += format(text[len], charsmax(text) - len, "<div align = ^"center^">");
	
	len += format(text[len], charsmax(text) - len, "<h1>");
	len += format(text[len], charsmax(text) - len, "%s v%s", PLUGIN_NAME, PLUGIN_VERSION);
	len += format(text[len], charsmax(text) - len, "</h1>");
	
	len += format(text[len], charsmax(text) - len, "<h4>");
	len += format(text[len], charsmax(text) - len, "by slavok1717");
	len += format(text[len], charsmax(text) - len, "</h4>");
	
	len += format(text[len], charsmax(text) - len, "<h1>");
	len += format(text[len], charsmax(text) - len, "Texture Design");
	len += format(text[len], charsmax(text) - len, "</h1>");
	
	len += format(text[len], charsmax(text) - len, "<h4>");
	len += format(text[len], charsmax(text) - len, "by slavok1717");
	len += format(text[len], charsmax(text) - len, "</h4>");
	
	len += format(text[len], charsmax(text) - len, "<h2>");
	len += format(text[len], charsmax(text) - len, "Grabbing Blocks:");
	len += format(text[len], charsmax(text) - len, "</h3>");
	
	len += format(text[len], charsmax(text) - len, "<h5>");
	len += format(text[len], charsmax(text) - len, "Admin CepBepa : slavok1717.<br />", PLUGIN_PREFIX);
	len += format(text[len], charsmax(text) - len, "Eg: <I>Bind F +bmgrab.</I>", PLUGIN_PREFIX);
	len += format(text[len], charsmax(text) - len, "</h5>");
	
	len += format(text[len], charsmax(text) - len, "<h2>");
	len += format(text[len], charsmax(text) - len, "Skype : slavoookk");
	len += format(text[len], charsmax(text) - len, "</h2>");
	
	len += format(text[len], charsmax(text) - len, "<h5>");
	len += format(text[len], charsmax(text) - len, "<I>Nash Site </I>: fv-g.3dn.ru<br />");
	len += format(text[len], charsmax(text) - len, "<I>IP Servera:</I>: 91.218.229.245:27022<br />");	len += format(text[len], charsmax(text) - len, "<I>CepBep Sobral</I>: slavok1717.<br />");
	len += format(text[len], charsmax(text) - len, "<I>Hide N Seek m0d</I>: by Exolent");
	len += format(text[len], charsmax(text) - len, "</h5>");
	
	len += format(text[len], charsmax(text) - len, "<h3>");
	len += format(text[len], charsmax(text) - len, "Press <I>+Use</I> to see what block you are aiming at.<br />");
	len += format(text[len], charsmax(text) - len, "Type /bm to bring up the %s Main Menu.", PLUGIN_PREFIX );
	len += format(text[len], charsmax(text) - len, "</h3>");
	
	len += format(text[len], charsmax(text) - len, "</div>");
	len += format(text[len], charsmax(text) - len, "</body>");
	
	len += format(text[len], charsmax(text) - len, "</html>");
	
	format(title, charsmax(title) - 1, "%s v%s", PLUGIN_NAME, PLUGIN_VERSION);
	show_motd(id, text, title);
	
	return PLUGIN_HANDLED;
}

MoveGrabbedEntity(id, Float:move_to[3] = { 0.0, 0.0, 0.0 })
{
	static aiming[3];
	static look[3];
	static Float:float_aiming[3];
	static Float:float_look[3];
	static Float:direction[3];
	static Float:length;
	
	get_user_origin(id, aiming, 1);
	get_user_origin(id, look, 3);
	IVecFVec(aiming, float_aiming);
	IVecFVec(look, float_look);
	
	direction[0] = float_look[0] - float_aiming[0];
	direction[1] = float_look[1] - float_aiming[1];
	direction[2] = float_look[2] - float_aiming[2];
	length = get_distance_f(float_look, float_aiming);
	
	if ( length == 0.0 ) length = 1.0;
	
	move_to[0] = ( float_aiming[0] + direction[0] * g_grab_length[id] / length ) + g_grab_offset[id][0];
	move_to[1] = ( float_aiming[1] + direction[1] * g_grab_length[id] / length ) + g_grab_offset[id][1];
	move_to[2] = ( float_aiming[2] + direction[2] * g_grab_length[id] / length ) + g_grab_offset[id][2];
	move_to[2] = float(floatround(move_to[2], floatround_floor));
	
	MoveEntity(id, g_grabbed[id], move_to, true);
}

MoveEntity(id, ent, Float:move_to[3], bool:do_snapping)
{
	if ( do_snapping ) DoSnapping(id, ent, move_to);
	
	entity_set_origin(ent, move_to);
	
	static block_type;
	block_type = entity_get_int(ent, EV_INT_body);
	
	if( block_type == CARPET )
	{
		set_pev(ent, pev_v_angle, move_to);
		origin_carpet[ent] = move_to;
	}
}

CreateBlockAiming(const id, const block_type)
{
	if ( !(get_user_flags(id) & ADMIN_LEVEL_D) && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static origin[3];
	static Float:float_origin[3];
	
	get_user_origin(id, origin, 3);
	IVecFVec(origin, float_origin);
	float_origin[2] += 4.0;
	
	CreateBlock(id, block_type, float_origin, Z, g_selected_block_size[id], g_property1_default_value[block_type], g_property2_default_value[block_type], g_property3_default_value[block_type], g_property4_default_value[block_type]);
	
	return PLUGIN_HANDLED;
}

CreateBlock(const id, const block_type, Float:origin[3], const axis, const size, const property1[], const property2[], const property3[], const property4[])
{
	new ent = create_entity("info_target");
	if ( !is_valid_ent(ent) ) return 0;
	
	entity_set_string(ent, EV_SZ_classname, g_block_classname);
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_NONE);
	
	Transperancy[ent] = 255;
	g_origin[ent][0] = 0.0;
	g_origin[ent][1] = 0.0;
	g_origin[ent][2] = 0.0;
	Velocity[ent][0] = 0.0;
	Velocity[ent][1] = 0.0;
	Velocity[ent][2] = 0.0;
	b_Distance[ent] = 0;
	ent_rotate_time[ent] = 0.0;
	ent_skip_time[ent] = 0.0;
	
	switch ( block_type )
	{
		case CARPET:
		{
			set_pev(ent, pev_v_angle, origin); // Original Origin
		}
	}
	
	new block_model[256];
	new Float:size_min[3];
	new Float:size_max[3];
	new Float:angles[3];
	new Float:scale;
	
	switch ( axis )
	{
		case X:
		{
			size_min[0] = -4.0;
			size_min[1] = -32.0;
			size_min[2] = -32.0;
			
			size_max[0] = 4.0;
			size_max[1] = 32.0;
			size_max[2] = 32.0;
			
			if(size == POLE)
			{
				size_min[0] = -32.0;
				size_min[1] = -4.0;
				size_min[2] = -4.0;
			
				size_max[0] = 32.0;
				size_max[1] = 4.0;
				size_max[2] = 4.0;
			}
				
			
			angles[0] = 90.0;
		}
		case Y:
		{
			size_min[0] = -32.0;
			size_min[1] = -4.0;
			size_min[2] = -32.0;
			
			size_max[0] = 32.0;
			size_max[1] = 4.0;
			size_max[2] = 32.0;
			
			if(size == POLE)
			{
				size_min[0] = -4.0;
				size_min[1] = -32.0;
				size_min[2] = -4.0;
			
				size_max[0] = 4.0;
				size_max[1] = 32.0;
				size_max[2] = 4.0;
			}
			
			angles[0] = 90.0;
			angles[2] = 90.0;
		}
		case Z:
		{
			size_min[0] = -32.0;
			size_min[1] = -32.0;
			size_min[2] = -4.0;
			
			size_max[0] = 32.0;
			size_max[1] = 32.0;
			size_max[2] = 4.0;
			
			if(size == POLE)
			{
				size_min[0] = -4.0;
				size_min[1] = -4.0;
				size_min[2] = -32.0;
			
				size_max[0] = 4.0;
				size_max[1] = 4.0;
				size_max[2] = 32.0;
			}
			
			angles[0] = 0.0;
			angles[1] = 0.0;
			angles[2] = 0.0;
		}
	}
	
	switch ( size )
	{
		case TINY:
		{
			SetBlockModelName(block_model, g_block_models[block_type], "Small");
			scale = 0.25;
		}
		case NORMAL:
		{
			block_model = g_block_models[block_type];
			scale = 1.0;
		}
		case LARGE:
		{
			SetBlockModelName(block_model, g_block_models[block_type], "Large");
			scale = 2.0;
		}
		case POLE:
		{
			SetBlockModelName(block_model, g_block_models[block_type], "Pole");
			scale = 1.0;
		}
	}
	
	for ( new i = 0; i < 3; ++i )
	{
		if ( size_min[i] != 4.0 && size_min[i] != -4.0 )
		{
			size_min[i] *= scale;
		}
		
		if ( size_max[i] != 4.0 && size_max[i] != -4.0 )
		{
			size_max[i] *= scale;
		}
	}
	
	entity_set_model(ent, block_model);
	
	SetBlockRendering(ent, g_render[block_type], g_red[block_type], g_green[block_type], g_blue[block_type], g_alpha[block_type]);
	
	entity_set_vector(ent, EV_VEC_angles, angles);
	entity_set_size(ent, size_min, size_max);
	entity_set_int(ent, EV_INT_body, block_type);
	
	if ( 1 <= id <= g_max_players )
	{
		DoSnapping(id, ent, origin);
	}
	
	entity_set_origin(ent, origin);
	
	SetProperty(ent, 1, property1);
	SetProperty(ent, 2, property2);
	SetProperty(ent, 3, property3);
	SetProperty(ent, 4, property4);
	
	if(block_type == CARPET){
		origin_carpet[ent] = origin;
	}
	
	if(id != 0)
	{
		new name[32], MapName[32];
		get_mapname(MapName,31);
		get_user_name(id, name, 31);
		log_amx("[BLOCKMAKER] Player %s created block %s! Mapname: %s", name, g_block_names[block_type], MapName);
	}
	
	return ent;
}

ConvertBlockAiming(id, const convert_to)
{
	if ( !(get_user_flags(id) & ADMIN_LEVEL_D) && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static ent, body;
	get_user_aiming(id, ent, body);
	
	if ( !IsBlock(ent) ) return PLUGIN_HANDLED;
	
	new grabber = entity_get_int(ent, EV_INT_iuser2);
	if ( grabber && grabber != id ) return PLUGIN_HANDLED;
	
	new player = entity_get_int(ent, EV_INT_iuser1);
	if ( player && player != id )
	{
		new player_name[32]; 
		get_user_name(player, player_name, charsmax(player_name));
		
		BCM_Print(id, "^1%s^3 currently has this block in their group!", player_name);
		return PLUGIN_HANDLED;
	}
	
	static new_block;
	if ( IsBlockInGroup(id, ent) && g_group_count[id] > 1 )
	{
		static i, block, block_count;
		
		block_count = 0;
		for ( i = 0; i <= g_group_count[id]; ++i )
		{
			block = g_grouped_blocks[id][i];
			if ( !IsBlockInGroup(id, block) ) continue;
			
			new_block = ConvertBlock(id, block, convert_to, true);
			if ( new_block != 0 )
			{
				g_grouped_blocks[id][i] = new_block;
				
				GroupBlock(id, new_block);
			}
			else
			{
				++block_count;
			}
		}
		
		if ( block_count > 1 )
		{
			BCM_Print(id, "Couldn't convert^1 %d^3 blocks!", block_count);
		}
	}
	else
	{
		new_block = ConvertBlock(id, ent, convert_to, false);
		if ( IsBlockStuck(new_block) )
		{
			new bool:deleted = DeleteBlock(new_block);
			if ( deleted ) BCM_Print(id, "Block deleted because it was stuck!");
		}
	}
	
	return PLUGIN_HANDLED;
}

ConvertBlock(id, ent, const convert_to, const bool:preserve_size)
{
	new axis;
	new block_type;
	new property1[5], property2[5], property3[5], property4[5];
	new Float:origin[3];
	new Float:size_max[3];
	new Float:angles[3];
	
	block_type = entity_get_int(ent, EV_INT_body);
	
	entity_get_vector(ent, EV_VEC_origin, origin);
	entity_get_vector(ent, EV_VEC_maxs, size_max);
	entity_get_vector(ent, EV_VEC_angles, angles);
	
	if (angles[0] == 90.0)
	{
		axis = 0;
	}
	if(angles[0] == 90.0 && angles[2] == 90.0)
	{
		axis = 1;
	}
	if(angles[0] == 0.0)
	{
		axis = 2;
	}
	
	GetProperty(ent, 1, property1);
	GetProperty(ent, 2, property2);
	GetProperty(ent, 3, property3);
	GetProperty(ent, 4, property4);
	
	if ( block_type != convert_to )
	{
		copy(property1, charsmax(property1), g_property1_default_value[convert_to]);
		copy(property2, charsmax(property2), g_property2_default_value[convert_to]);
		copy(property3, charsmax(property3), g_property3_default_value[convert_to]);
		copy(property4, charsmax(property4), g_property4_default_value[convert_to]);
	}
	
	DeleteBlock(ent);
	
	if ( preserve_size )
	{
		static size, Float:max_size;
		
		max_size = size_max[0] + size_max[1] + size_max[2];
		
		if ( max_size > 128.0 )		size = LARGE;
		else if ( max_size > 64.0 )	size = NORMAL;
		else if( max_size > 32.0 ) 	size = POLE;
		else				size = TINY;
		
		return CreateBlock(id, convert_to, origin, axis, size, property1, property2, property3, property4);
	}
	else
	{
		return CreateBlock(id, convert_to, origin, axis, g_selected_block_size[id], property1, property2, property3, property4);
	}
	
	if(id != 0)
	{
		new name[32], MapName[32];
		get_mapname(MapName,31);
		get_user_name(id, name, 31);
		log_amx("[BLOCKMAKER] Player %s converted block %s on %s! Mapname: %s", name, g_block_names[block_type], g_block_names[convert_to], MapName);
	}
	
	return ent;
}

DeleteBlockAiming(id)
{
	if ( !(get_user_flags(id) & ADMIN_LEVEL_D) && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static ent, body;
	get_user_aiming(id, ent, body);
	
	if ( !IsBlock(ent) ) return PLUGIN_HANDLED;
	
	new grabber = entity_get_int(ent, EV_INT_iuser2);
	if ( grabber && grabber != id ) return PLUGIN_HANDLED;
	
	new player = entity_get_int(ent, EV_INT_iuser1);
	if ( player && player != id )
	{
		new player_name[32]; 
		get_user_name(player, player_name, charsmax(player_name));
		
		BCM_Print(id, "^1%s^3 currently has this block in their group!", player_name);
		return PLUGIN_HANDLED;
	}
	
	if ( IsBlockInGroup(id, ent) && g_group_count[id] > 1 )
	{
		static i, block;
		for ( i = 0; i <= g_group_count[id]; ++i )
		{
			block = g_grouped_blocks[id][i];
			if ( !is_valid_ent(block) ) continue;
			
			DeleteBlock(block);
		}
		
		return PLUGIN_HANDLED;
	}
	
	DeleteBlock(ent);
	
	return PLUGIN_HANDLED;
}

bool:DeleteBlock(ent)
{
	if ( !IsBlock(ent) ) return false;
	
	remove_entity(ent);
	return true;
}

RotateBlockAiming(id)
{
	if ( !(get_user_flags(id) & ADMIN_LEVEL_D) && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static ent, body;
	get_user_aiming(id, ent, body);
	
	if ( !IsBlock(ent) ) return PLUGIN_HANDLED;
	
	new grabber = entity_get_int(ent, EV_INT_iuser2);
	if ( grabber && grabber != id ) return PLUGIN_HANDLED;
	
	new player = entity_get_int(ent, EV_INT_iuser1);
	if ( player && player != id )
	{
		static player_name[32]; 
		get_user_name(player, player_name, charsmax(player_name));
		
		BCM_Print(id, "^1%s^3 currently has this block in their group!", player_name);
		return PLUGIN_HANDLED;
	}
	
	if ( IsBlockInGroup(id, ent) && g_group_count[id] > 1 )
	{
		static block;
		for ( new i = 0; i <= g_group_count[id]; ++i )
		{
			block = g_grouped_blocks[id][i];
			if ( IsBlockInGroup(id, block) ) RotateBlock(block);
		}
	}
	else
	{
		RotateBlock(ent);
	}
	
	return PLUGIN_HANDLED;
}

RotateBlock(ent)
{
	if ( !is_valid_ent(ent) ) return false;
	
	static Float:angles[3];
	static Float:size_min[3];
	static Float:size_max[3];
	static Float:temp;
	
	entity_get_vector(ent, EV_VEC_angles, angles);
	entity_get_vector(ent, EV_VEC_mins, size_min);
	entity_get_vector(ent, EV_VEC_maxs, size_max);
	
	if ( angles[0] == 0.0 && angles[2] == 0.0 )
	{
		angles[0] = 90.0;
	}
	else if ( angles[0] == 90.0 && angles[2] == 0.0 )
	{
		angles[0] = 90.0;
		angles[2] = 90.0;
	}
	else
	{
		angles[0] = 0.0;
		angles[1] = 0.0;
		angles[2] = 0.0;
	}
	
	temp = size_min[0];
	size_min[0] = size_min[2];
	size_min[2] = size_min[1];
	size_min[1] = temp;
	
	temp = size_max[0];
	size_max[0] = size_max[2];
	size_max[2] = size_max[1];
	size_max[1] = temp;
	
	entity_set_vector(ent, EV_VEC_angles, angles);
	entity_set_size(ent, size_min, size_max);
	
	return true;
}

public RotateEntity(ent)
{
	ent -= TASK_ICE;
	
	if ( !IsBlock(ent) || ent_rotate_time[ent] <= 0.0) 
	{
		if(task_exists(TASK_ICE + ent))
		{
			remove_task(TASK_ICE + ent);
		}
		
		return PLUGIN_HANDLED;
	}
	
	static Float:angles[3];
	static Float:size_min[3];
	static Float:size_max[3];
	static Float:temp;
	
	entity_get_vector(ent, EV_VEC_angles, angles);
	entity_get_vector(ent, EV_VEC_mins, size_min);
	entity_get_vector(ent, EV_VEC_maxs, size_max);
	
	if ( angles[0] == 0.0 && angles[2] == 0.0 )
	{
		angles[0] = 90.0;
	}
	else if ( angles[0] == 90.0 && angles[2] == 0.0 )
	{
		angles[0] = 90.0;
		angles[2] = 90.0;
	}
	else
	{
		angles[0] = 0.0;
		angles[1] = 0.0;
		angles[2] = 0.0;
	}
	
	temp = size_min[0];
	size_min[0] = size_min[2];
	size_min[2] = size_min[1];
	size_min[1] = temp;
	
	temp = size_max[0];
	size_max[0] = size_max[2];
	size_max[2] = size_max[1];
	size_max[1] = temp;
	
	entity_set_vector(ent, EV_VEC_angles, angles);
	entity_set_size(ent, size_min, size_max);
	
	ent_rotate_time_start[ent] = get_gametime() + ent_rotate_time[ent];
	
	return PLUGIN_HANDLED;
}

ChangeBlockSize(id)
{
	switch ( g_selected_block_size[id] )
	{
		case TINY:	g_selected_block_size[id] = NORMAL;
		case NORMAL:	g_selected_block_size[id] = LARGE;
		case LARGE:	g_selected_block_size[id] = POLE;
		case POLE:	g_selected_block_size[id] = TINY;
	}
}

SetPropertiesBlockAiming(id)
{
	if ( !(get_user_flags(id) & ADMIN_LEVEL_D) && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		ShowBlockMenu(id);
		return PLUGIN_HANDLED;
	}
	
	static ent, body;
	get_user_aiming(id, ent, body);
	
	if ( !IsBlock(ent) )
	{
		ShowBlockMenu(id);
		return PLUGIN_HANDLED;
	}
	
	new block_type = entity_get_int(ent, EV_INT_body);
	
	if ( !g_property1_name[block_type][0]
	&& !g_property2_name[block_type][0]
	&& !g_property3_name[block_type][0]
	&& !g_property4_name[block_type][0] )
	{
		ShowBlockMenu(id);
		return PLUGIN_HANDLED;
	}
	
	g_viewing_properties_menu[id] = true;
	ShowPropertiesMenu(id, ent);
	
	return PLUGIN_HANDLED;
}

public SetPropertyBlock(id)
{
	static arg[5];
	read_argv(1, arg, charsmax(arg));
	
	if ( !strlen(arg) )
	{
		BCM_Print(id, "You can't set a property blank! Please type a new value.");
		client_cmd(id, "messagemode BCM_SetProperty");
		return PLUGIN_HANDLED;
	}
	else if ( !IsStrFloat(arg) )
	{
		BCM_Print(id, "You can't use letters in a property! Please type a new value.");
		client_cmd(id, "messagemode BCM_SetProperty");
		return PLUGIN_HANDLED;
	}
	
	new ent = g_property_info[id][1];
	if ( !is_valid_ent(ent) )
	{
		BCM_Print(id, "That block has been deleted!");
		g_viewing_properties_menu[id] = false;
		ShowBlockMenu(id);
		return PLUGIN_HANDLED;
	}
	
	static block_type;
	static property;
	static Float:property_value;
	
	block_type = entity_get_int(ent, EV_INT_body);
	property = g_property_info[id][0];
	property_value = str_to_float(arg);
	
	switch ( block_type )
	{
			case DAMAGE, HEALER:
			{
				if ( property == 1
				&& !( 1 <= property_value <= 100 ) )
				{
					BCM_Print(id, "The property has to be between^1 1^3 and^1 100^3!");
					return PLUGIN_HANDLED;
				}
				else if ( !( 0.1 <= property_value <= 240 ) )
				{
					BCM_Print(id, "The property has to be between^1 0.1^3 and^1 240^3!");
					return PLUGIN_HANDLED;
				}
			}
			case BUNNYHOP_D:
			{
				if ( property == 2
				&& !( 1 <= property_value <= 100 ) )
				{
					BCM_Print(id, "The property has to be between^1 1^3 and^1 100^3!");
					return PLUGIN_HANDLED;
				}
			}
			case TRAMPOLINE:
			{
				if ( !( 200 <= property_value <= 2000 ) )
				{
					BCM_Print(id, "The property has to be between^1 200^3 and^1 2000^3!");
					return PLUGIN_HANDLED;
				}
			}
			case SPEED_BOOST:
			{
				if ( property == 1
				&& !( 200 <= property_value <= 2000 ) )
				{
					BCM_Print(id, "The property has to be between^1 200^3 and^1 2000^3!");
					return PLUGIN_HANDLED;
				}
				else if ( !( 0 <= property_value <= 2000 ) )
				{
					BCM_Print(id, "The property has to be between^1 0^3 and^1 2000^3!");
					return PLUGIN_HANDLED;
				}
			}
			case LOW_GRAVITY:
			{
				if ( !( 50 <= property_value <= 750 ) )
				{
					BCM_Print(id, "The property has to be between^1 50^3 and^1 750^3!");
					return PLUGIN_HANDLED;
				}
			}
			case HONEY:
			{
				if ( !( 75 <= property_value <= 200
				|| property_value == 0 ) )
				{
					BCM_Print(id, "The property has to be between^1 75^3 and^1 200^3, or^1 0^3!");
					return PLUGIN_HANDLED;
				}
			}
			case DELAYED_BUNNYHOP:
			{
				if ( !( 0.5 <= property_value <= 15 ) )
				{
					BCM_Print(id, "The property has to be between^1 0.5^3 and^1 15^3!");
					return PLUGIN_HANDLED;
				}
			}
			case INVINCIBILITY, STEALTH, BOOTS_OF_SPEED:
			{
				if ( property == 1
				&& !( 0.5 <= property_value <= 240 ) )
				{
					BCM_Print(id, "The property has to be between^1 0.5^3 and^1 240^3!");
					return PLUGIN_HANDLED;
				}
				else if ( property == 2
				&& !( 0 <= property_value <= 240 ) )
				{
					BCM_Print(id, "The property has to be between^1 0^3 and^1 240^3!");
					return PLUGIN_HANDLED;
				}
				else if ( property == 3
				&& block_type == BOOTS_OF_SPEED
				&& !( 260 <= property_value <= 400 ) )
				{
					BCM_Print(id, "The property has to be between^1 260^3 and^1 400^3!");
					return PLUGIN_HANDLED;
				}
			}
	}
	
	static value[5];
	new name[32], MapName[32];
	get_user_name(id, name, 31);
	get_mapname(MapName,31);
	GetProperty(ent, property, value); 
	log_amx("[BLOCKMAKER] Player %s set property %d for block %s with %d on %d! Mapname: %s", name, property, g_block_names[block_type], value, arg, MapName);

	SetProperty(ent, property, arg);
	
	ent = g_property_info[id][1];
	ShowPropertiesMenu(id, ent);
	
	return PLUGIN_HANDLED;
}

ToggleProperty(id, property)
{
	new ent = g_property_info[id][1];
	if ( !is_valid_ent(ent) )
	{
		BCM_Print(id, "That block has been deleted!");
		g_viewing_properties_menu[id] = false;
		ShowBlockMenu(id);
		return PLUGIN_HANDLED;
	}
	
	static property_value[5];
	GetProperty(ent, property, property_value);
	
	new block_type = entity_get_int(ent, EV_INT_body);
	
	if ( block_type == SLAP && property == 1 
	|| block_type == T_BARRIER && property == 1
	|| block_type == CT_BARRIER && property == 1 )
	{
		switch( property_value[0] )
		{
			case '1': copy(property_value, charsmax(property_value), "2");
			case '2': copy(property_value, charsmax(property_value), "3");
			default: copy(property_value, charsmax(property_value), "1");
		}
	}
	
	else if ( block_type == GRANATA && property == 1 )
	{
		switch( property_value[0] )
		{
			case '1': copy(property_value, charsmax(property_value), "2");
			case '2': copy(property_value, charsmax(property_value), "3");
			case '3': copy(property_value, charsmax(property_value), "4");
			default: copy(property_value, charsmax(property_value), "1");
		}
	}
	else if( block_type == CARPET && property == 1 )
	{
		switch( property_value[0] )
		{
			case '1': copy(property_value, charsmax(property_value), "2");
			case '2': copy(property_value, charsmax(property_value), "3");
			case '3': copy(property_value, charsmax(property_value), "4");
			case '4': copy(property_value, charsmax(property_value), "5");
			case '5': copy(property_value, charsmax(property_value), "6");
			default: copy(property_value, charsmax(property_value), "1");
		}
	}
	else if ( block_type == VIP_BARRIER && property == 1 || block_type == BLIND_TRAP && property == 1 || block_type == EARTHQUAKE && property == 1)
	{
		switch( property_value[0] )
		{
			case '1': copy(property_value, charsmax(property_value), "2");
			default: copy(property_value, charsmax(property_value), "1");
		}
	}
	else
	{
		if ( property_value[0] == '0' )		copy(property_value, charsmax(property_value), "1");
		else					copy(property_value, charsmax(property_value), "0");
	}
	
	SetProperty(ent, property, property_value);
	
	for ( new i = 1; i <= g_max_players; i++ )
	{
		if ( g_connected[i] && g_viewing_properties_menu[i] )
		{
			ent = g_property_info[i][1];
			ShowPropertiesMenu(i, ent);
		}
	}
	
	return PLUGIN_HANDLED;
}

GetProperty(ent, property, property_value[])
{
	switch ( property )
	{
		case 1: pev(ent, pev_message, property_value, 16);
		case 2: pev(ent, pev_netname, property_value, 10);
		case 3: pev(ent, pev_viewmodel2, property_value, 10);
		case 4: pev(ent, pev_weaponmodel2, property_value, 10);
	}
	
	return (strlen(property_value) ? 1 : 0);
}

SetProperty(ent, property, const property_value[])
{
	switch ( property )
	{
		case 1: set_pev(ent, pev_message, property_value, 16);
		case 2: set_pev(ent, pev_netname, property_value, 10);
		case 3: set_pev(ent, pev_viewmodel2, property_value, 10);
		case 4: set_pev(ent, pev_weaponmodel2, property_value, 10);
	}

	return 1;
}

CopyBlock(ent)
{
	if ( !is_valid_ent(ent) ) return 0;
	
	new size;
	new axis;
	new property1[5], property2[5], property3[5], property4[5];
	new Float:origin[3];
	new Float:angles[3];
	new Float:size_min[3];
	new Float:size_max[3];
	new Float:max_size;
	
	entity_get_vector(ent, EV_VEC_origin, origin);
	entity_get_vector(ent, EV_VEC_angles, angles);
	entity_get_vector(ent, EV_VEC_mins, size_min);
	entity_get_vector(ent, EV_VEC_maxs, size_max);
	
	max_size = size_max[0] + size_max[1] + size_max[2];
	
	if ( max_size > 128.0 )		size = LARGE;
	else if ( max_size > 64.0 )	size = NORMAL;
	else if ( max_size > 32.0 )	size = POLE;
	else				size = TINY;
	
	for ( new i = 0; i < 3; ++i )
	{
		if ( size_max[i] == 4.0 )
		{
			axis = i;
			break;
		}
	}
	
	GetProperty(ent, 1, property1);
	GetProperty(ent, 2, property2);
	GetProperty(ent, 3, property3);
	GetProperty(ent, 4, property4);
	
	return CreateBlock(0, entity_get_int(ent, EV_INT_body), origin, axis, size, property1, property2, property3, property4);
}

GroupBlockAiming(id)
{
	if ( !(get_user_flags(id) & ADMIN_LEVEL_D) && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static ent, body;
	get_user_aiming(id, ent, body);
	
	if ( !IsBlock(ent) ) return PLUGIN_HANDLED;
	
	new player = entity_get_int(ent, EV_INT_iuser1);
	if ( !player )
	{
		++g_group_count[id];
		g_grouped_blocks[id][g_group_count[id]] = ent;
		GroupBlock(id, ent);
	}
	else if ( player == id )
	{
		UnGroupBlock(ent);
	}
	else
	{
		static player, name[32];
		
		player = entity_get_int(ent, EV_INT_iuser1);
		get_user_name(player, name, charsmax(name));
		
		BCM_Print(id, "Block is already in a group by:^1 %s", name);
	}
	
	return PLUGIN_HANDLED;
}

GroupBlock(id, ent)
{
	if(task_exists(ent + TASK_SOLID))
	{		
		gRenderMode[ent] = gRenderMode_Solid[ent];
		gRenderFx[ent] = gRenderFx_Solid[ent];
		gRenderAmt[ent] = gRenderAmt_Solid[ent];
		gRenderColor[ent][0] = gRenderColor_Solid[ent][0];
		gRenderColor[ent][1] = gRenderColor_Solid[ent][1];
		gRenderColor[ent][2] = gRenderColor_Solid[ent][2];
	}
	else
	{
		gRenderMode[ent] = entity_get_int(ent, EV_INT_rendermode);
		gRenderFx[ent] = entity_get_int(ent, EV_INT_renderfx);
		pev( ent, pev_renderamt, gRenderAmt[ent] );
		pev( ent, pev_rendercolor, gRenderColor[ent] );
	}
	
	if ( !is_valid_ent(ent) ) return PLUGIN_HANDLED;
	
	if ( 1 <= id <= g_max_players )
	{
		entity_set_int(ent, EV_INT_iuser1, id);
	}
	
	set_rendering(ent, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 16);
	
	return PLUGIN_HANDLED;
}

UnGroupBlock(ent)
{
	if ( !IsBlock(ent) ) return PLUGIN_HANDLED;
	
	entity_set_int(ent, EV_INT_iuser1, 0);
	
	set_pev(ent, pev_rendermode, gRenderMode[ent]);
	set_pev(ent, pev_renderfx, gRenderFx[ent]);
	set_pev( ent, pev_renderamt, gRenderAmt[ent] );
	set_pev( ent, pev_rendercolor, gRenderColor[ent] );
	
	return PLUGIN_HANDLED;
}

ClearGroup(id)
{
	if ( !(get_user_flags(id) & ADMIN_LEVEL_D) && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static block;
	static block_count;
	static blocks_deleted;
	
	block_count = 0;
	blocks_deleted = 0;
	for ( new i = 0; i <= g_group_count[id]; ++i )
	{
		block = g_grouped_blocks[id][i];
		if ( IsBlockInGroup(id, block) )
		{
			if ( IsBlockStuck(block) )
			{
				DeleteBlock(block);
				++blocks_deleted;
			}
			else
			{
				UnGroupBlock(block);
				++block_count;
			}
		}
	}
	
	g_group_count[id] = 0;
	
	if ( g_connected[id] )
	{
		if ( blocks_deleted > 0 )
		{
			BCM_Print(id, "Removed^1 %d^3 blocks from group. Deleted^1 %d^3 stuck blocks!", block_count, blocks_deleted);
		}
		else
		{
			BCM_Print(id, "Removed^1 %d^3 blocks from group!", block_count);
		}
	}
	
	return PLUGIN_HANDLED;
}

SetBlockRendering(ent, type, red, green, blue, alpha)
{
	if ( !IsBlock(ent) ) return PLUGIN_HANDLED;
	
	switch ( type )
	{
		case GLOWSHELL: fm_set_rendering(ent, kRenderFxGlowShell, red, green, blue, kRenderNormal, alpha);
		case TRANSCOLOR: fm_set_rendering(ent, kRenderFxGlowShell, red, green, blue, kRenderTransColor, alpha);
		case TRANSALPHA: fm_set_rendering(ent, kRenderFxNone, red, green, blue, kRenderTransColor, alpha);
		case TRANSWHITE: fm_set_rendering(ent, kRenderFxNone, red, green, blue, kRenderTransAdd, alpha);
		case GLOWALPHA: fm_set_rendering(ent, kRenderFxGlowShell, red, green, blue, kRenderTransTexture, alpha);
		case HOLOGRAM: fm_set_rendering(ent, kRenderFxHologram, red, green, blue, kRenderNormal, alpha);
		case FADEFAST: fm_set_rendering(ent, kRenderFxPulseSlowWide, red, green, blue, kRenderTransAlpha, alpha);
		default: fm_set_rendering(ent, kRenderFxNone, red, green, blue, kRenderNormal, alpha);
	}
	
	return PLUGIN_HANDLED;
}

bool:IsBlock(ent)
{
	if ( !is_valid_ent(ent) ) return false;
	
	static classname[32];
	entity_get_string(ent, EV_SZ_classname, classname, charsmax(classname));
	
	if ( equal(classname, g_block_classname) )
	{
		return true;
	}
	
	return false;
}

bool:IsBlockInGroup(id, ent)
{
	if ( !is_valid_ent(ent) ) return false;
	
	new player = entity_get_int(ent, EV_INT_iuser1);
	if ( player == id ) return true;
	
	return false;
}

bool:IsBlockStuck(ent)
{
	if ( !is_valid_ent(ent) ) return false;
	
	new content;
	new Float:origin[3];
	new Float:point[3];
	new Float:size_min[3];
	new Float:size_max[3];
	
	entity_get_vector(ent, EV_VEC_mins, size_min);
	entity_get_vector(ent, EV_VEC_maxs, size_max);
	
	entity_get_vector(ent, EV_VEC_origin, origin);
	
	size_min[0] += 1.0;
	size_min[1] += 1.0;
	size_min[2] += 1.0;
	
	size_max[0] -= 1.0;
	size_max[1] -= 1.0; 
	size_max[2] -= 1.0;
	
	for ( new i = 0; i < 14; ++i )
	{
		point = origin;
		
		switch ( i )
		{
			case 0:
			{
					point[0] += size_max[0];
					point[1] += size_max[1];
					point[2] += size_max[2];
			}
			case 1:
			{
					point[0] += size_min[0];
					point[1] += size_max[1];
					point[2] += size_max[2];
			}
			case 2:
			{
					point[0] += size_max[0];
					point[1] += size_min[1];
					point[2] += size_max[2];
			}
			case 3:
			{
					point[0] += size_min[0];
					point[1] += size_min[1];
					point[2] += size_max[2];
			}
			case 4:
			{
					point[0] += size_max[0];
					point[1] += size_max[1];
					point[2] += size_min[2];
			}
			case 5:
			{
					point[0] += size_min[0];
					point[1] += size_max[1];
					point[2] += size_min[2];
			}
			case 6:
			{
					point[0] += size_max[0];
					point[1] += size_min[1];
					point[2] += size_min[2];
			}
			case 7:
			{
					point[0] += size_min[0];
					point[1] += size_min[1];
					point[2] += size_min[2];
			}
			case 8:		point[0] += size_max[0];
			case 9:		point[0] += size_min[0];
			case 10:	point[1] += size_max[1];
			case 11:	point[1] += size_min[1];
			case 12:	point[2] += size_max[2];
			case 13:	point[2] += size_min[2];
		}
		
		content = point_contents(point);
		if ( content == CONTENTS_EMPTY
		|| !content ) return false;
	}
	
	return true;
}

CreateTeleportAiming(id, teleport_type)
{
	if ( !(get_user_flags(id) & ADMIN_LEVEL_D) && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static origin[3];
	static Float:float_origin[3];
	
	get_user_origin(id, origin, 3);
	IVecFVec(origin, float_origin);
	float_origin[2] += 36.0;
	
	switch ( teleport_type )
	{
		case TELEPORT_START:
		{
			CreateTeleportStart(id, float_origin);
		}
		case TELEPORT_DESTINATION:
		{
			CreateTeleportExit(id, float_origin);
		}
	}
	
	return PLUGIN_HANDLED;
}

CreateTeleportStart(id, Float:origin[3])
{
	if ( g_teleport_start[id] ) remove_entity(g_teleport_start[id]);
			
	new ent = create_you_entity("CM_TeleportStart");
	if(is_valid_ent(ent))
	{
		entity_set_string(ent, EV_SZ_classname, g_start_classname);
		entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
		entity_set_int(ent, EV_INT_movetype, MOVETYPE_NONE);
		entity_set_model(ent, g_sprite_teleport_start);
		entity_set_size(ent, Float:{ -16.0, -16.0, -16.0 }, Float:{ 16.0, 16.0, 16.0 });
		entity_set_origin(ent, origin);
			
		entity_set_int(ent, EV_INT_rendermode, 5);
		entity_set_float(ent, EV_FL_renderamt, 255.0);
			
		static params[2];
		params[0] = ent;
		params[1] = 6;
			
		set_task(0.1, "TaskSpriteNextFrame", TASK_SPRITE + ent, params, 2, g_b);
			
		g_teleport_start[id] = ent;
			
		if(id != 0)
		{
			client_print(id, print_chat, "You created a Teleport Start!");
			ShowTeleportMenu(id);
		}
	}
	
	return PLUGIN_HANDLED;
}

CreateTeleportExit(id, Float:origin[3])
{
	if(!pev_valid(g_teleport_start[id]))
	{
		ShowTeleportMenu(id);
		client_print(id, print_chat, "You must create an Teleport`s Start first!");
		return PLUGIN_HANDLED;
	}
	
	new ent = create_you_entity("CM_TeleportDestination");
	if(is_valid_ent(ent))
	{
		entity_set_string(ent, EV_SZ_classname, g_destination_classname);
		entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
		entity_set_int(ent, EV_INT_movetype, MOVETYPE_NONE);
		entity_set_model(ent, g_sprite_teleport_destination);
		entity_set_size(ent, Float:{ -16.0, -16.0, -16.0 }, Float:{ 16.0, 16.0, 16.0 });
		entity_set_origin(ent, origin);
			
		entity_set_int(ent, EV_INT_rendermode, 5);
		entity_set_float(ent, EV_FL_renderamt, 255.0);
			
		entity_set_int(ent, EV_INT_iuser1, g_teleport_start[id]);
		entity_set_int(g_teleport_start[id], EV_INT_iuser1, ent);
			
		static params[2];
		params[0] = ent;
		params[1] = 4;
			
		set_task(0.1, "TaskSpriteNextFrame", TASK_SPRITE + ent, params, 2, g_b);
			
		g_teleport_start[id] = 0;
			
		if(id != 0)
		{
			client_print(id, print_chat, "You created a Teleport Destination!");
			ShowTeleportMenu(id);
		}
	}
	
	return PLUGIN_HANDLED;
}

DeleteTeleportAiming(id)
{
	if ( !(get_user_flags(id) & ADMIN_LEVEL_D) && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static ent, body;
	get_user_aiming(id, ent, body, 9999);
	
	new bool:deleted = DeleteTeleport(id, ent);
	if ( deleted ) BCM_Print(id, "Teleport deleted!");
	
	return PLUGIN_HANDLED;
}

bool:DeleteTeleport(id, ent)
{
	for ( new i = 0; i < 2; ++i )
	{
		if ( !IsTeleport(ent) ) return false;
		
		new tele = entity_get_int(ent, EV_INT_iuser1);
		
		if ( g_teleport_start[id] == ent
		|| g_teleport_start[id] == tele )
		{
			g_teleport_start[id] = 0;
		}
		
		if ( task_exists(TASK_SPRITE + ent) )
		{
			remove_task(TASK_SPRITE + ent);
		}
		
		if ( task_exists(TASK_SPRITE + tele) )
		{
			remove_task(TASK_SPRITE + tele);
		}
		
		if ( tele ) remove_entity(tele);
		
		remove_entity(ent);
		return true;
	}
	
	return false;
}

SwapTeleportAiming(id)
{
	if ( !(get_user_flags(id) & ADMIN_LEVEL_D) && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static ent, body;
	get_user_aiming(id, ent, body, 9999);
	
	if ( !IsTeleport(ent) ) return PLUGIN_HANDLED;
	
	SwapTeleport(id, ent);
	
	return PLUGIN_HANDLED;
}

SwapTeleport(id, ent)
{
	static Float:origin_ent[3];
	static Float:origin_tele[3];
	
	new tele = entity_get_int(ent, EV_INT_iuser1);
	if ( !is_valid_ent(tele) )
	{
		BCM_Print(id, "Can't swap teleport positions!");
		return PLUGIN_HANDLED;
	}
	
	entity_get_vector(ent, EV_VEC_origin, origin_ent);
	entity_get_vector(tele, EV_VEC_origin, origin_tele);
	
	static classname[32];
	entity_get_string(ent, EV_SZ_classname, classname, charsmax(classname));
	
	DeleteTeleport(id, ent);
	
	if ( equal(classname, g_start_classname) )
	{
		CreateTeleportStart(id, origin_tele);
		CreateTeleportExit(id, origin_ent);
	}
	else if ( equal(classname, g_destination_classname) )
	{
		CreateTeleportStart(id, origin_ent);
		CreateTeleportExit(id, origin_tele);
	}
	
	BCM_Print(id, "Teleports swapped!");
	
	return PLUGIN_HANDLED;
}

ShowTeleportPath(id)
{
	static ent, body;
	get_user_aiming(id, ent, body);
	
	if ( !IsTeleport(ent) ) return PLUGIN_HANDLED;
	
	new tele = entity_get_int(ent, EV_INT_iuser1);
	if ( !tele ) return PLUGIN_HANDLED;
	
	static Float:origin1[3], Float:origin2[3], Float:dist;
	
	entity_get_vector(ent, EV_VEC_origin, origin1);
	entity_get_vector(tele, EV_VEC_origin, origin2);
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMPOINTS);
	write_coord(floatround(origin1[0], floatround_floor));
	write_coord(floatround(origin1[1], floatround_floor));
	write_coord(floatround(origin1[2], floatround_floor));
	write_coord(floatround(origin2[0], floatround_floor));
	write_coord(floatround(origin2[1], floatround_floor));
	write_coord(floatround(origin2[2], floatround_floor));
	write_short(g_sprite_beam);
	write_byte(0);
	write_byte(1);
	write_byte(50);
	write_byte(5);
	write_byte(0);
	write_byte(255);
	write_byte(255);
	write_byte(255);
	write_byte(255);
	write_byte(0);
	message_end();
	
	dist = get_distance_f(origin1, origin2);
	
	BCM_Print(id, "A line has been drawn to show the teleport path. Distance:^1 %f units", dist);
	
	return PLUGIN_HANDLED;
}

bool:IsTeleport(ent)
{
	if ( !is_valid_ent(ent) ) return false;
	
	static classname[32];
	entity_get_string(ent, EV_SZ_classname, classname, charsmax(classname));
	
	if ( equal(classname, g_start_classname)
	|| equal(classname, g_destination_classname) )
	{
		return true;
	}
	
	return false;
}

CreateLightAiming(const id)
{
	if ( !(get_user_flags(id) & ADMIN_LEVEL_D) && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static origin[3];
	static Float:float_origin[3];
	
	get_user_origin(id, origin, 3);
	IVecFVec(origin, float_origin);
	float_origin[2] += 4.0;
	
	CreateLight(float_origin, "25", "255", "255", "255");
	
	return PLUGIN_HANDLED;
}

CreateLight(Float:origin[3], const radius[], const color_red[], const color_green[], const color_blue[])
{
	new ent = create_entity("info_target");
	if ( !is_valid_ent(ent) ) return 0;
	
	entity_set_origin(ent, origin);
	entity_set_model(ent, g_sprite_light);
	entity_set_float(ent, EV_FL_scale, 0.25);
	entity_set_string(ent, EV_SZ_classname, g_light_classname);
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_NONE);
	
	entity_set_size(ent, Float:{ -3.0, -3.0, -6.0 }, Float:{ 3.0, 3.0, 6.0 });
	
	static Float:color[3];
	color[0] = str_to_float(color_red);
	color[1] = str_to_float(color_green);
	color[2] = str_to_float(color_blue);
	
	entity_set_vector(ent, EV_VEC_rendercolor, color);
	
	SetProperty(ent, 1, radius);
	SetProperty(ent, 2, color_red);
	SetProperty(ent, 3, color_green);
	SetProperty(ent, 4, color_blue);
	
	entity_set_float(ent, EV_FL_nextthink, get_gametime() + 0.01);
	
	return ent;
}

DeleteLightAiming(id)
{
	if ( !(get_user_flags(id) & ADMIN_LEVEL_D) && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static ent, body;
	get_user_aiming(id, ent, body);
	
	if ( !IsLight(ent) ) return PLUGIN_HANDLED;
	
	new grabber = entity_get_int(ent, EV_INT_iuser2);
	if ( grabber && grabber != id ) return PLUGIN_HANDLED;
	
	DeleteLight(ent);
	
	return PLUGIN_HANDLED;
}

bool:DeleteLight(ent)
{
	if ( !IsLight(ent) ) return false;
	
	remove_entity(ent);
	
	return true;
}

SetPropertiesLightAiming(id)
{
	if ( !(get_user_flags(id) & ADMIN_LEVEL_D) && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		ShowLightMenu(id);
		return PLUGIN_HANDLED;
	}
	
	static ent, body;
	get_user_aiming(id, ent, body);
	
	if ( !IsLight(ent) )
	{
		ShowLightMenu(id);
		return PLUGIN_HANDLED;
	}
	
	g_viewing_light_properties_menu[id] = true;
	ShowLightPropertiesMenu(id, ent);
	
	return PLUGIN_HANDLED;
}

public SetPropertyLight(id)
{
	static arg[33];
	read_argv(1, arg, charsmax(arg));
	
	if ( !strlen(arg) )
	{
		BCM_Print(id, "You can't set a property blank! Please type a new value.");
		client_cmd(id, "messagemode BCM_SetLightProperty");
		return PLUGIN_HANDLED;
	}
	else if ( !is_str_num(arg) )
	{
		BCM_Print(id, "You can't use letters in a property! Please type a new value.");
		client_cmd(id, "messagemode BCM_SetLightProperty");
		return PLUGIN_HANDLED;
	}
	
	new ent = g_light_property_info[id][1];
	if ( !is_valid_ent(ent) )
	{
		BCM_Print(id, "That light has been deleted!");
		g_viewing_light_properties_menu[id] = false;
		ShowLightMenu(id);
		return PLUGIN_HANDLED;
	}
	
	static property;
	static property_value;
	
	property = g_light_property_info[id][0];
	property_value = str_to_num(arg);
	
	if ( property == 1 )
	{
		if ( !( 1 <= property_value <= 100 ) )
		{
			BCM_Print(id, "The property has to be between^1 1^3 and^1 100^3!");
			return PLUGIN_HANDLED;
		}
	}
	else if ( !( 0 <= property_value <= 255 ) )
	{
		BCM_Print(id, "The property has to be between^1 0^3 and^1 255^3!");
		return PLUGIN_HANDLED;
	}
	
	SetProperty(ent, property, arg);
	
	if ( property != 1 )
	{
		static color_red[5], color_green[5], color_blue[5];
		
		GetProperty(ent, 2, color_red);
		GetProperty(ent, 3, color_green);
		GetProperty(ent, 4, color_blue);
		
		static Float:color[3];
		color[0] = str_to_float(color_red);
		color[1] = str_to_float(color_green);
		color[2] = str_to_float(color_blue);
		
		entity_set_vector(ent, EV_VEC_rendercolor, color);
	}
	
	for ( new i = 1; i <= g_max_players; i++ )
	{
		if ( !g_connected[i]
		|| !g_viewing_light_properties_menu[i] ) continue;
		
		ent = g_light_property_info[i][1];
		ShowLightPropertiesMenu(i, ent);
	}
	
	return PLUGIN_HANDLED;
}

public MovementBlock(ent)
{
	if(is_valid_ent(ent))
	{
		set_pev(ent, pev_velocity, Velocity[ent]);
			
		new Float:fOri[3];
		entity_get_vector(ent, EV_VEC_origin, fOri);

		for(new i = 0 ; i < 3 ; i ++)
		{
			if(Velocity[ent][i])
			{
				if((fOri[i] - 5.5) > (g_origin[ent][i] + b_Distance[ent]) && Velocity[ent][i] >= 0.0 || (fOri[i] + 5.5) < g_origin[ent][i] && Velocity[ent][i] < 0.0)
				{
					Velocity[ent][i] *=  -1.0;
				}
			}
		}
				
		new iPlayers[32], iNum;
		get_players(iPlayers, iNum);
			
		for(new i = 0 ; i < iNum ; i ++)
		{
			new iFlags = pev(iPlayers[i], pev_flags);
				
			if((iFlags & FL_ONGROUND) && pev(iPlayers[i], pev_groundentity) == ent)
			{
				new Float:fOrigin[3];
				entity_get_vector(iPlayers[i], EV_VEC_origin, fOrigin);
						
				fOrigin[2] += 1.0;
				entity_set_vector(iPlayers[i], EV_VEC_origin, fOrigin);
			}
		}
		
		set_pev(ent, pev_nextthink, get_gametime() + 0.02);
	}
}

public LightThink(ent)
{
	static radius[5], color_red[5], color_green[5], color_blue[5];
	
	GetProperty(ent, 1, radius);
	GetProperty(ent, 2, color_red);
	GetProperty(ent, 3, color_green);
	GetProperty(ent, 4, color_blue);
	
	static Float:float_origin[3];
	entity_get_vector(ent, EV_VEC_origin, float_origin);
	
	static origin[3];
	FVecIVec(float_origin, origin);
	
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin, 0);
	write_byte(TE_DLIGHT);
	write_coord(origin[0]);
	write_coord(origin[1]);
	write_coord(origin[2]);
	write_byte(str_to_num(radius));
	write_byte(str_to_num(color_red));
	write_byte(str_to_num(color_green));
	write_byte(str_to_num(color_blue));
	write_byte(1);
	write_byte(1);
	message_end();
	
	entity_set_float(ent, EV_FL_nextthink, get_gametime() + 0.01);
}

bool:IsLight(ent)
{
	if ( !is_valid_ent(ent) ) return false;
	
	static classname[32];
	entity_get_string(ent, EV_SZ_classname, classname, charsmax(classname));
	
	if ( equal(classname, g_light_classname) )
	{
		return true;
	}
	
	return false;
}

DoSnapping(id, ent, Float:move_to[3])
{
	if ( !g_snapping[id] ) return PLUGIN_HANDLED;
	
	new traceline;
	new closest_trace;
	new block_face;
	new Float:snap_size;
	new Float:v_return[3];
	new Float:dist;
	new Float:old_dist;
	new Float:trace_start[3];
	new Float:trace_end[3];
	new Float:size_min[3];
	new Float:size_max[3];
	
	entity_get_vector(ent, EV_VEC_mins, size_min);
	entity_get_vector(ent, EV_VEC_maxs, size_max);
	
	snap_size = g_snapping_gap[id] + 10.0;
	old_dist = 9999.9;
	closest_trace = 0;
	for ( new i = 0; i < 6; ++i )
	{
		trace_start = move_to;
		
		switch ( i )
		{
			case 0: trace_start[0] += size_min[0];
			case 1: trace_start[0] += size_max[0];
			case 2: trace_start[1] += size_min[1];
			case 3: trace_start[1] += size_max[1];
			case 4: trace_start[2] += size_min[2];
			case 5: trace_start[2] += size_max[2];
		}
		
		trace_end = trace_start;
		
		switch ( i )
		{
			case 0: trace_end[0] -= snap_size;
			case 1: trace_end[0] += snap_size;
			case 2: trace_end[1] -= snap_size;
			case 3: trace_end[1] += snap_size;
			case 4: trace_end[2] -= snap_size;
			case 5: trace_end[2] += snap_size;
		}
		
		traceline = trace_line(ent, trace_start, trace_end, v_return);
		if ( IsBlock(traceline)
		&& ( !IsBlockInGroup(id, traceline) || !IsBlockInGroup(id, ent) ) )
		{
			dist = get_distance_f(trace_start, v_return);
			if ( dist < old_dist )
			{
				closest_trace = traceline;
				old_dist = dist;
				
				block_face = i;
			}
		}
	}
	
	if ( !is_valid_ent(closest_trace) ) return PLUGIN_HANDLED;
	
	static Float:trace_origin[3];
	static Float:trace_size_min[3];
	static Float:trace_size_max[3];
	
	entity_get_vector(closest_trace, EV_VEC_origin, trace_origin);
	entity_get_vector(closest_trace, EV_VEC_mins, trace_size_min);
	entity_get_vector(closest_trace, EV_VEC_maxs, trace_size_max);
	
	move_to = trace_origin;
	
	if ( block_face == 0 ) move_to[0] += ( trace_size_max[0] + size_max[0] ) + g_snapping_gap[id];
	if ( block_face == 1 ) move_to[0] += ( trace_size_min[0] + size_min[0] ) - g_snapping_gap[id];
	if ( block_face == 2 ) move_to[1] += ( trace_size_max[1] + size_max[1] ) + g_snapping_gap[id];
	if ( block_face == 3 ) move_to[1] += ( trace_size_min[1] + size_min[1] ) - g_snapping_gap[id];
	if ( block_face == 4 ) move_to[2] += ( trace_size_max[2] + size_max[2] ) + g_snapping_gap[id];
	if ( block_face == 5 ) move_to[2] += ( trace_size_min[2] + size_min[2] ) - g_snapping_gap[id];
	
	return PLUGIN_HANDLED;
}

DeleteAll(id, bool:notify)
{
	static ent, block_count, tele_count, light_count, bool:deleted;
	
	ent = -1;
	block_count = 0;
	while ( ( ent = find_ent_by_class(ent, g_block_classname) ) )
	{
		deleted = DeleteBlock(ent);
		if ( deleted )
		{
			++block_count;
		}
	}
	
	ent = -1;
	tele_count = 0;
	while ( ( ent = find_ent_by_class(ent, g_start_classname) ) )
	{
		deleted = DeleteTeleport(id, ent);
		if ( deleted )
		{
			++tele_count;
		}
	}
	
	ent = -1;
	light_count = 0;
	while ( ( ent = find_ent_by_class(ent, g_light_classname) ) )
	{
		deleted = DeleteLight(ent);
		if ( deleted )
		{
			++light_count;
		}
	}
	
	if ( ( block_count
		|| tele_count
		|| light_count )
	&& notify )
	{
		static name[32];
		get_user_name(id, name, charsmax(name));
		
		for ( new i = 1; i <= g_max_players; ++i )
		{
			g_grabbed[i] = 0;
			g_teleport_start[i] = 0;
			
			if ( !g_connected[i]
			|| !(get_user_flags(i) & ADMIN_LEVEL_D) && !g_gived_access[i] ) continue;
			
			BCM_Print(i, "^1%s^3 deleted^1 %d blocks^3,^1 %d teleports^3 and^1 %d lights^3 from the map!", name, block_count, tele_count, light_count);
		}
	}
	
	return PLUGIN_HANDLED;
}

public SaveBlocksPrepare(id)
{
	new menu = menu_create("Choose Save", "SaveBlocksPrepare_Handle");
	
	if(!equal(this_save, "#DONTHAVE"))
	{
		new Tile[64];
		formatex(Tile, 63, "\wSave: %s^n",this_save);
		
		if(c_GameMode[id] == 0)
		{
			formatex(Tile, 63, "%s^n\yMode\w: \rKnives^n",Tile);
		}
		else if(c_GameMode[id] == 1)
		{
			formatex(Tile, 63, "%s^n\yMode\w: \rPoints^n",Tile);
		}
		else if(c_GameMode[id] == 2)
		{
			formatex(Tile, 63, "%s^n\yMode\w: \rWeapons^n",Tile);
		}
		else if(c_GameMode[id] == 3)
		{
			formatex(Tile, 63, "%s^n\yMode\w: \rClassic^n",Tile);
		}
		else if(c_GameMode[id] == 4)
		{
			formatex(Tile, 63, "%s^n\yMode\w: \rTest^n",Tile);
		}
		
		replace_all(Tile, 63, "^"", "");
		menu_additem(menu, Tile, "1", 0);
	}
	else
	{
		menu_additem(menu, "\dThis Save^n", "1", 0);
	}
	
	menu_additem(menu, "\wCreate New Save", "2", 0);
	menu_additem(menu, "\wReplace Old Save^n", "3", 0);
	
	menu_additem(menu, "\wDelete Saves Menu^n", "4", 0);
	
	menu_display(id, menu, 0);
}

public SaveBlocksPrepare_Handle(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		ShowOptionsMenu(id);
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
			if(!equal(this_save, "#DONTHAVE"))
			{
				SaveBlocksPrepare(id);
				SaveBlocks(id, this_save, pre_GameMode[id]);
			}
			else
			{
				SaveBlocksPrepare(id);
			}
		}
		case 2:
		{
			client_cmd(id, "messagemode ___enter_savename");
			ShowOptionsMenu(id);
		}
		case 3:
		{
			ReplaceOldMenu(id);
		}
		case 4:
		{
			ShowDeleteMenu(id);
		}
	}
	
	return PLUGIN_HANDLED;
}

public SaveName(client)
{
	static arg[32];
	read_args(arg, charsmax(arg));
	
	SaveBlocks(client, arg, pre_GameMode[client]);
	LoadBlocks_cfg();
	
	return PLUGIN_HANDLED;
}

public LoadName(client)
{
	static arg[32];
	read_args(arg, charsmax(arg));
	
	formatex(need_load[client], 31, arg);
	ShowChoiceMenu(client, CHOICE_LOAD, "Loading will delete all blocks and teleports, do you want to continue?");
	
	return PLUGIN_HANDLED;
}

public ReplaceOldMenu(id)
{
	new temp_id[10],  i = 1;
	new menu = menu_create("Choose Build", "ReplaceOldMenu_Handle");
		
	while(i <= b_count[c_GameMode[id]])
	{
		num_to_str(i, temp_id, 9);
		
		if(c_GameMode[id] != 4)
		{
			menu_additem(menu,  buildname_menu[c_GameMode[id]][i-1], temp_id, 0);
		}
		else
		{
			menu_additem(menu,  buildname_tests[i-1], temp_id, 0);
		}
		
		i++;
	}
		
	if (i == 1)
	{
		BCM_Print(id, "This server don`t has save-files!");
	}
	else
	{
		menu_display(id, menu, 0);
	}
}

public ReplaceOldMenu_Handle(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		SaveBlocksPrepare(id);
		return PLUGIN_HANDLED;
	}
	
	new data[7], iName[64];
	new access, callback;
	
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	
	new key = str_to_num(data), i = 1, buildname[32];
	
	while(i <= b_count[c_GameMode[id]])
	{
		if(i == key)
		{
			if(c_GameMode[id] != 4)
			{
				formatex(buildname, 31, "%s", buildname_menu[c_GameMode[id]][i-1]);
			}
			else
			{
				formatex(buildname, 31, "%s", buildname_tests[i-1]);
			}
			
			replace_all(buildname, 31, ".AG", "");
			SaveBlocks(id, buildname, pre_GameMode[id]);
			ShowOptionsMenu(id);
		}
		
		i++;
	}
	
	return PLUGIN_HANDLED;
}

public LoadBlocksPrepare(id)
{
	new menu = menu_create("Choose Load", "LoadBlocksPrepare_Handle");
		
	if(!equal(this_save, "#DONTHAVE"))
	{
		new Tile[64];
		formatex(Tile, 63, "\wSave: %s^n",this_save);
		
		if(c_GameMode[id] == 0)
		{
			formatex(Tile, 63, "%s^n\yMode\w: \rKnives^n",Tile);
		}
		else if(c_GameMode[id] == 1)
		{
			formatex(Tile, 63, "%s^n\yMode\w: \rPoints^n",Tile);
		}
		else if(c_GameMode[id] == 2)
		{
			formatex(Tile, 63, "%s^n\yMode\w: \rWeapons^n",Tile);
		}
		else if(c_GameMode[id] == 3)
		{
			formatex(Tile, 63, "%s^n\yMode\w: \rClassic^n",Tile);
		}
		else if(c_GameMode[id] == 4)
		{
			formatex(Tile, 63, "%s^n\yMode\w: \rTest^n",Tile);
		}
		
		replace_all(Tile, 63, "^"", "");
		menu_additem(menu, Tile, "1", 0);
	}
	else
	{
		menu_additem(menu, "\dThis Load^n", "1", 0);
	}
	
	menu_additem(menu, "\wChoose Load Text", "2", 0);
	menu_additem(menu, "\wChoose Load Menu^n", "3", 0);
	
	menu_additem(menu, "\wDelete Saves Menu^n", "4", 0);
	
	menu_display(id, menu, 0);
}
	

public LoadBlocksPrepare_Handle(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		ShowOptionsMenu(id);
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
			if(!equal(this_save, "#DONTHAVE"))
			{
				formatex(need_load[id], 31, this_save);
				ShowChoiceMenu(id, CHOICE_LOAD, "Loading will delete all blocks and teleports, do you want to continue?");
			}
			else
			{
				LoadBlocksPrepare(id);
			}
		}
		case 2:
		{
			client_cmd(id, "messagemode ___enter_loadname");
			ShowOptionsMenu(id);
		}
		case 3:
		{
			ChooseLoadMenu(id);
		}
		case 4:
		{
			ShowDeleteMenu(id);
		}
	}
	
	return PLUGIN_HANDLED;
}

public ChooseLoadMenu(id)
{
	new temp_id[10],  i = 1;
	
	new menu = menu_create("Choose Build", "ChooseLoadMenu_Handle");
	
	while(i <= b_count[c_GameMode[id]])
	{
		num_to_str(i, temp_id, 9);
		
		if(c_GameMode[id] != 4)
		{
			menu_additem(menu,  buildname_menu[c_GameMode[id]][i-1], temp_id, 0);
		}
		else
		{
			menu_additem(menu,  buildname_tests[i-1], temp_id, 0);
		}
		
		i++;
	}
		
	if (i == 1)
	{
		BCM_Print(id, "This server don`t have load files!");
	}
	else
	{
		menu_display(id, menu, 0);
	}
}

public ChooseLoadMenu_Handle(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		LoadBlocksPrepare(id);
		return PLUGIN_HANDLED;
	}
	
	new data[7], iName[64];
	new access, callback;
	
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	
	new key = str_to_num(data), i = 1, buildname[32];
	
	while(i <= b_count[c_GameMode[id]])
	{
		if(i == key)
		{
			if(c_GameMode[id] != 4)
			{
				formatex(buildname, 31, "%s", buildname_menu[c_GameMode[id]][i-1]);
			}
			else
			{
				formatex(buildname, 31, "%s", buildname_tests[i-1]);
			}
			
			replace_all(buildname, 31, ".AG", "");
			formatex(need_load[id], 31, buildname);
			ShowChoiceMenu(id, CHOICE_LOAD, "Loading will delete all blocks and teleports, do you want to continue?");
		}
			
		i++;
	}
	
	return PLUGIN_HANDLED;
}

public ShowModsMenu(id)
{
	new menu = menu_create("Choose GameMode", "ModsMenu_Handle");

	menu_additem(menu, "Knives", "1", 0);
	menu_additem(menu, "Points", "2", 0);
	menu_additem(menu, "Weapon", "3", 0);
	menu_additem(menu, "Classic", "4", 0);
	menu_additem(menu, "Test", "5", 0);
	
	menu_display(id, menu, 0);
	
	return PLUGIN_HANDLED;
}

public ModsMenu_Handle(id, menu, item)
{
	if( item == MENU_EXIT)
	{
		menu_destroy(menu);
		ShowOptionsMenu(id);
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
			c_GameMode[id] = 0;
		}
		case 2:
		{
			c_GameMode[id] = 1;
		}
		case 3:
		{
			c_GameMode[id] = 2;
		}
		case 4:
		{
			c_GameMode[id] = 3;
		}
		case 5:
		{
			c_GameMode[id] = 4;
		}
	}

	if(index_menu[id] == 0)
	{
		SaveBlocksPrepare(id);
	}
	else if(index_menu[id] == 1)
	{
		LoadBlocksPrepare(id);
	}
	
	return PLUGIN_HANDLED;
}

public ShowDeleteMenu(id)
{
	new temp_id[10],  i = 1;
	
	new menu = menu_create("Choose Save", "DeleteMenu_Handle");
	
	while(i <= b_count[c_GameMode[id]])
	{
		num_to_str(i, temp_id, 9);
		
		if(c_GameMode[id] != 4)
		{
			menu_additem(menu,  buildname_menu[c_GameMode[id]][i-1], temp_id, 0);
		}
		else
		{
			menu_additem(menu,  buildname_tests[i-1], temp_id, 0);
		}
		
		i++;
	}
		
	if (i == 1)
	{
		BCM_Print(id, "This server don`t has save-files!");
	}
	else
	{
		menu_display(id, menu, 0);
	}
	
	return PLUGIN_HANDLED;
}

public DeleteMenu_Handle(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		ShowOptionsMenu(id);
		return PLUGIN_HANDLED;
	}
	
	new data[7], iName[64];
	new access, callback;
	
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	
	new key = str_to_num(data), i = 1, del_name[32];
	
	while(i <= b_count[c_GameMode[id]])
	{
		if(i == key)
		{
			if(c_GameMode[id] != 4)
			{
				formatex(del_name, 31, "%s%s", prefix_GameMode[c_GameMode[id]], buildname_menu[c_GameMode[id]][i-1]);
			}
			else
			{
				formatex(del_name, 31, "%s%s", prefix_GameMode[c_GameMode[id]], buildname_tests[i-1]);
			}
			
			
			new del_file[128];
			
			if(c_GameMode[id] != 4)
			{
				format(del_file, 127, "%s/%s%s.%s", g_file, prefix_GameMode[c_GameMode[id]], buildname_menu[c_GameMode[id]][i-1], PLUGIN_PREFIX);
			}
			else
			{
				format(del_file, 127, "%s/%s%s.%s", g_file, prefix_GameMode[c_GameMode[id]], buildname_tests[i-1], PLUGIN_PREFIX);
			}
			
			new name[32];
			get_user_name(id, name, 31);
			
			new info = delete_file(del_file);
			
			if(info)
			{
				log_to_file("AGCM_information.txt", "[DeleteMenu] %s deleted %s successfully!", name, del_name);
				BCM_Print(id, "You deleted %s successfully!", del_name);
				LoadBlocks_cfg();
			}
			else
			{
				log_to_file("AGCM_information.txt", "[DeleteMenu] Error! %s can`t delete %s!", name, del_name);
				BCM_Print(id, "Error! %s isn't deleted!", del_name);
			}
			
			log_to_file("AGCM_information.txt", "[DeleteMenu] Location: %s.", del_file);
			BCM_Print(id, "Location: %s", del_file);
			
			ShowOptionsMenu(id);
			return PLUGIN_HANDLED;
		}
			
		i++;
	}
	
	return PLUGIN_HANDLED;
}

SaveBlocks(id, save_file[32], prefix[3])
{
	formatex(this_save, charsmax(this_save), save_file);
	
	new ent;
	new file;
	new pre_file[128];
	new data[768];
	new block_count;
	new tele_count;
	new light_count;
	new block_type;
	new size;
	new property1[13], property2[5], property3[5], property4[5];
	new tele;
	new Float:origin[3];
	new Float:angles[3];
	new Float:tele_start[3];
	new Float:tele_end[3];
	new Float:max_size;
	new Float:size_max[3];
	new Float:RGB[3], Float:RenderAmt, RenderFX, RenderMode;
	
	if ( !dir_exists(g_file) ) mkdir(g_file);
	
	format(pre_file, 127, "%s/%s%s.%s", g_file, prefix, save_file, PLUGIN_PREFIX);
	replace_all(pre_file, 127, "^"", "");
	
	file = fopen(pre_file, "wt");
	block_count = 0;
	tele_count = 0;
	
	new group_info[33];
	new bool: render_was = false;
	
	ent = -1;
	while ( ( ent = find_ent_by_class(ent, g_block_classname) ) )
	{
		for(new player = 1; player <= g_max_players; player++){
			if (IsBlockInGroup(player, ent) && g_group_count[player] > 0 && g_connected[player]){
				RenderMode = gRenderMode[ent];
				RenderFX = gRenderFx[ent];
				RenderAmt = gRenderAmt[ent];
				RGB[0] = gRenderColor[ent][0];
				RGB[1] = gRenderColor[ent][1];
				RGB[2] = gRenderColor[ent][2];
				render_was = true;
				group_info[player] = 1;
			}
		}
		
		block_type = entity_get_int(ent, EV_INT_body);
		entity_get_vector(ent, EV_VEC_origin, origin);
		entity_get_vector(ent, EV_VEC_angles, angles);
		entity_get_vector(ent, EV_VEC_maxs, size_max);
		
		//rendering
		if(task_exists(ent + TASK_SOLID) && !render_was)
		{		
			RenderMode = gRenderMode_Solid[ent];
			RenderFX = gRenderFx_Solid[ent];
			RenderAmt = gRenderAmt_Solid[ent];
			RGB[0] = gRenderColor_Solid[ent][0];
			RGB[1] = gRenderColor_Solid[ent][1];
			RGB[2] = gRenderColor_Solid[ent][2];
		}
		else if(!render_was)
		{
			RenderMode = entity_get_int(ent, EV_INT_rendermode);
			RenderFX = entity_get_int(ent, EV_INT_renderfx);
			pev( ent, pev_renderamt, RenderAmt );
			pev( ent, pev_rendercolor, RGB );
		}
		
		GetProperty(ent, 1, property1);
		GetProperty(ent, 2, property2);
		GetProperty(ent, 3, property3);
		GetProperty(ent, 4, property4);
		
		if ( !property1[0] ) copy(property1, charsmax(property1), "/");
		if ( !property2[0] ) copy(property2, charsmax(property2), "/");
		if ( !property3[0] ) copy(property3, charsmax(property3), "/");
		if ( !property4[0] ) copy(property4, charsmax(property4), "/");
		
		max_size = size_max[0] + size_max[1] + size_max[2];
		
		if ( max_size > 128.0 )		size = LARGE;
		else if ( max_size > 64.0 )	size = NORMAL;
		else if ( max_size > 32.0 )	size = POLE;
		else				size = TINY;
		
		formatex(data, charsmax(data), "%c %f %f %f %f %f %f %d %s %s %s %s %d %f %f %f %f %d %d %f %f %f %f %f %f %d %f %f^n",\
		g_block_save_ids[block_type], origin[0], origin[1], origin[2], angles[0],angles[1],angles[2],size,property1,property2,property3,	property4, Transperancy[ent],
		RGB[0],RGB[1],RGB[2],RenderAmt,RenderFX,RenderMode,g_origin[ent][0],g_origin[ent][1],g_origin[ent][2], Velocity[ent][0],Velocity[ent][1], Velocity[ent][2], b_Distance[ent], ent_rotate_time[ent], ent_skip_time[ent]);
				
		fputs(file, data);
		
		for(new player = 1; player <= g_max_players; player++)
		{
			if(group_info[player] == 1 && g_connected[player])
			{
				set_rendering(ent, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 16);
				group_info[player] = 0;
			}
		}
		
		++block_count;
	}
	
	ent = -1;
	while ( ( ent = find_ent_by_class(ent, g_destination_classname) ) )
	{
		tele = entity_get_int(ent, EV_INT_iuser1);
		if ( tele )
		{
			entity_get_vector(tele, EV_VEC_origin, tele_start);
			entity_get_vector(ent, EV_VEC_origin, tele_end);
			
			formatex(data, charsmax(data), "* %f %f %f %f %f %f^n",\
			tele_start[0],\
			tele_start[1],\
			tele_start[2],\
			tele_end[0],\
			tele_end[1],\
			tele_end[2]
			);
			fputs(file, data);
			
			++tele_count;
		}
	}
	
	ent = -1;
	while ( ( ent = find_ent_by_class(ent, g_light_classname) ) )
	{
		entity_get_vector(ent, EV_VEC_origin, origin);
		
		GetProperty(ent, 1, property1);
		GetProperty(ent, 2, property2);
		GetProperty(ent, 3, property3);
		GetProperty(ent, 4, property4);
		
		formatex(data, charsmax(data), "! %f %f %f / / / / %s %s %s %s %s^n",\
		origin[0],\
		origin[1],\
		origin[2],\
		property1,\
		property2,\
		property3,\
		property4
		);
		fputs(file, data);
		
		++light_count;
	}
	
	static name[32];
	get_user_name(id, name, charsmax(name));
	
	for ( new i = 1; i <= g_max_players; ++i )
	{
		if ( g_connected[i]
		&& ( (get_user_flags(i) & ADMIN_LEVEL_D) || g_gived_access[i] ) )
		{
			BCM_Print(i, "^1%s^3 saved^1 %d block%s^3,^1 %d teleport%s^3 and^1 %d light%s^3!", name, block_count, block_count == 1 ? g_blank : "s", tele_count, tele_count == 1 ? g_blank : "s", light_count, light_count == 1 ? g_blank : "s");
			BCM_Print(i, "Total entites on map:^1 %d^3, max entites: ^1%d", entity_count(), get_global_int(GL_maxEntities));
			BCM_Print(i, "Save file dir: %s", pre_file);
		}
	}
	
	fclose(file);
	return PLUGIN_HANDLED;
}

LoadBlocks(id)
{
	if(id != 0){
		formatex(change_value_build, charsmax(change_value_build), need_load[id]);
		g_GameMode = c_GameMode[id];
	}
	
	DeleteAll(id, false);
	set_task(0.5, "ContinueLoadBlocks", id);
}

public ContinueLoadBlocks(id){
	new pre_file[128];
	format(pre_file, 127, "%s/%s%s.%s", g_file, prefix_GameMode[g_GameMode], change_value_build, PLUGIN_PREFIX);
	replace_all(pre_file, 127, "^"", "");
	
	if (!file_exists(pre_file)){
		formatex(building_name_for_mess, charsmax(building_name_for_mess), "No");
		set_pcvar_num(agm_status, 4);
		
		log_to_file("AGCM_information.txt", "[Load`s Config] Couldn't find file:^1 %s", pre_file);
		log_to_file("AGCM_information.txt", "[Load`s Config] Directory: %s - prefix: %s - save_file: %s - p_prefix: %s", g_file, prefix_GameMode[g_GameMode], change_value_build, PLUGIN_PREFIX);
		client_print(id, print_chat, "Couldn't find file:^1 %s", pre_file);
		
		g_GameMode = 3;
		
		return PLUGIN_HANDLED;
	}
	
	
	formatex(building_name_for_mess, charsmax(building_name_for_mess), change_value_build);
	
	set_pcvar_num(agm_status, g_GameMode + 1);
	
	for(new i = 1; i <= g_max_players; i++)
		BCM_Print(i, "Режим игры изменен на:^4 %s^3, выбрана постройка:^4 %s^3.", modesname[g_GameMode], change_value_build);
	
	formatex(this_save, charsmax(this_save), change_value_build);
	
	new file;
	new data[256];
	new block_count;
	new tele_count;
	new light_count;
	new type[2];
	new block_size[17];
	new origin_x[17];
	new origin_y[17];
	new origin_z[17];
	new angel_x[17];
	new angel_y[17];
	new angel_z[17];
	new block_type;
	new axis;
	new size;
	new property1[13], property2[5], property3[5], property4[5];
	new Float:origin[3];
	new Float:angles[3];
	new CreatedEnt;
		
	//rendering
	new EntTransp[5], RotateEntTime[4], SkipEntTime[4];
	new szRGB[3][17], szRenderFX[17], szRenderMode[17], szRenderAmt[17];
	new Float:RGB[3], Float:RenderAmt, RenderFX, RenderMode;
	new sDist[15], sOri[3][15], sVelo[3][15];
	
	file = fopen(pre_file, "rt");
	
	block_count = 0;
	tele_count = 0;
	
	while ( !feof(file) )
	{
		type = g_blank;
		
		fgets(file, data, charsmax(data));
		parse(data, type, charsmax(type), origin_x, charsmax(origin_x), origin_y, charsmax(origin_y), origin_z, charsmax(origin_z), angel_x, charsmax(angel_x), angel_y, charsmax(angel_y), angel_z, charsmax(angel_z),
		block_size, charsmax(block_size), property1, charsmax(property1), property2, charsmax(property2), property3, charsmax(property3), property4, charsmax(property4), EntTransp, charsmax(EntTransp), szRGB[0], 16,szRGB[1], 16, szRGB[2], 16,
		szRenderAmt, 16, szRenderFX, 16, szRenderMode, 16, sOri[0], 14, sOri[1], 14, sOri[2], 14, sVelo[0], 14, sVelo[1], 14, sVelo[2], 14, sDist, 14, RotateEntTime, 3, SkipEntTime, 3);
		
		origin[0] =	str_to_float(origin_x);
		origin[1] =	str_to_float(origin_y);
		origin[2] =	str_to_float(origin_z);
		angles[0] =	str_to_float(angel_x);
		angles[1] =	str_to_float(angel_y);
		angles[2] =	str_to_float(angel_z);
		size =		str_to_num(block_size);
		RGB[0] = str_to_float(szRGB[0]);
		RGB[1] = str_to_float(szRGB[1]);
		RGB[2] = str_to_float(szRGB[2]);
		RenderAmt = str_to_float(szRenderAmt);
		RenderFX = str_to_num(szRenderFX);
		RenderMode = str_to_num(szRenderMode);
		
		if ( strlen(type) > 0 )
		{
			if ( type[0] != '*' )
			{
				if ( angles[0] == 90.0 && angles[1] == 0.0 && angles[2] == 0.0 )
				{
					axis = X;
				}
				else if ( angles[0] == 90.0 && angles[1] == 0.0 && angles[2] == 90.0 )
				{
					axis = Y;
				}
				else
				{
					axis = Z;
				}
			}
			
			switch ( type[0] )
			{
				case 'A': block_type = PLATFORM;
				case 'B': block_type = BUNNYHOP;
				case 'C': block_type = DAMAGE;
				case 'D': block_type = HEALER;
				case 'E': block_type = NO_FALL_DAMAGE;
				case 'F': block_type = ICE;
				case 'G': block_type = TRAMPOLINE;
				case 'H': block_type = SPEED_BOOST;
				case 'I': block_type = DEATH;
				case 'J': block_type = LOW_GRAVITY;
				case 'K': block_type = SLAP;
				case 'L': block_type = HONEY;
				case 'M': block_type = CT_BARRIER;
				case 'N': block_type = T_BARRIER;
				case 'W': block_type = VIP_BARRIER;
				case 'P': block_type = NO_SLOW_DOWN_BUNNYHOP;
				case 'Q': block_type = DELAYED_BUNNYHOP;
				case '6': block_type = BUNNYHOP_D;
				case 'R': block_type = INVINCIBILITY;
				case 'S': block_type = STEALTH;
				case 'T': block_type = BOOTS_OF_SPEED;
				case 'U': block_type = CAMOUFLAGE;
				case 'V': block_type = GRANATA;
				case 'Y': block_type = WEAPON;
				case '2': block_type = MUSIC;
				case '3': block_type = DOUBLE_DUCK;
				case '1': block_type = BLIND_TRAP;
				case '4': block_type = EARTHQUAKE;
				case '5': block_type = CARPET;
				case '7': block_type = POINT_BLOCK;
				case '8': block_type = WEAPON_CHANCE;
				case '9': block_type = RANDOM;
				
				case '*':
				{
					CreateTeleportStart(0, origin);
					CreateTeleportExit(0, angles);
					
					++tele_count;
				}
				case '!':
				{
					CreateLight(origin, property1, property2, property3, property4);
					
					++light_count;
				}
			}
			
			if ( type[0] != '*' && type[0] != '!' )
			{
				CreatedEnt = CreateBlock(0, block_type, origin, axis, size, property1, property2, property3, property4);
				
				if(block_type == CARPET){
					origin_carpet[CreatedEnt] = origin;
				}
				
				set_pev(CreatedEnt, pev_renderfx, RenderFX);
				set_pev(CreatedEnt, pev_rendermode, RenderMode);
				set_pev(CreatedEnt, pev_rendercolor, RGB);
				set_pev(CreatedEnt, pev_renderamt, RenderAmt);
				
				Transperancy[CreatedEnt] = str_to_num(EntTransp);
				
				g_origin[CreatedEnt][0] = str_to_float(sOri[0]);
				g_origin[CreatedEnt][1] = str_to_float(sOri[1]);
				g_origin[CreatedEnt][2] = str_to_float(sOri[2]);
				Velocity[CreatedEnt][0] = str_to_float(sVelo[0]);
				Velocity[CreatedEnt][1] = str_to_float(sVelo[1]);
				Velocity[CreatedEnt][2] = str_to_float(sVelo[2]);
				b_Distance[CreatedEnt] = str_to_num(sDist);
				
				if(b_Distance[CreatedEnt] > 0)
				{
					set_pev(CreatedEnt, pev_movetype, MOVETYPE_FLY);
					set_pev(CreatedEnt, pev_nextthink,  get_gametime() + 0.02);
				}
				
				ent_skip_time[CreatedEnt] = str_to_float(SkipEntTime);
				ent_rotate_time[CreatedEnt] = str_to_float(RotateEntTime);
		
				if(ent_rotate_time[CreatedEnt] > 0.0)
				{
					if(!task_exists(TASK_ICE + CreatedEnt))
					{
						set_task(ent_rotate_time[CreatedEnt], "RotateEntity", TASK_ICE + CreatedEnt, _, _, "b");
					}
				}
				
				++block_count;
			}
		}
	}
	
	fclose(file);
	
	if ( 1 <= id <= g_max_players )
	{
		static name[32];
		get_user_name(id, name, charsmax(name));
		
		for ( new i = 1; i <= g_max_players; ++i )
		{
			if ( !g_connected[i]
			|| !(get_user_flags(i) & ADMIN_LEVEL_D) && !g_gived_access[i] ) continue;
			
			BCM_Print(i, "^1%s^3 loaded^1 %d block%s^3,^1 %d teleport%s^3 and^1 %d light%s^3!", name, block_count, block_count == 1 ? g_blank : "s", tele_count, tele_count == 1 ? g_blank : "s", light_count, light_count == 1 ? g_blank : "s");
			BCM_Print(i, "Total entites on map:^1 %d^3, max entites: ^1%d", entity_count(), get_global_int(GL_maxEntities));
			BCM_Print(i, "Load file dir: %s", pre_file);
		}
	}
	
	return PLUGIN_HANDLED;
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

ResetPlayer(id)
{
	g_no_fall_damage[id] =		false;
	g_ice[id] =			false;
	g_low_gravity[id] =		false;
	g_no_slow_down[id] =		false;
	g_block_status[id] =		false;
	g_has_hud_text[id] =		false;
	
	g_slap_times[id] =		0;
	g_honey[id] =			0;
	g_boots_of_speed[id] =		0;
	g_pb_next_use[id] =               0.0;
	g_next_damage_time[id] =	0.0;
	g_next_heal_time[id] =		0.0;
	g_invincibility_time_out[id] =	0.0;
	g_invincibility_next_use[id] =	0.0;
	g_stealth_time_out[id] =	0.0;
	g_stealth_next_use[id] =	0.0;
	g_music_next_use[id] =		0.0;
	g_weapon_chance_next_use[id] =	0.0;
	g_CAMOUFLAGE_time_out[id] =	0.0;
	g_CAMOUFLAGE_next_use[id] =	0.0;
	g_boots_of_speed_time_out[id] =	0.0;
	g_boots_of_speed_next_use[id] =	0.0;
	g_random_next_use[id] =		0.0;
	
	g_weapons_mess_time[id] = 0.0;
	g_weapon_chance_next_use_mess[id] = 0.0;
	g_greandes_mess_time_all[id] = 0.0;
	g_greandes_mess_time_he[id] = 0.0;
	g_greandes_mess_time_fn[id] = 0.0;
	g_greandes_mess_time_fb[id] = 0.0;
	g_invincibility_next_use_mess[id] = 0.0;
	g_stealth_next_use_mess[id] = 0.0;
	g_CAMOUFLAGE_next_use_mess[id] = 0.0;
	g_boots_of_speed_next_use_mess[id] = 0.0;
	g_pb_next_use_mess[id] = 0.0;
	g_pb_next_use_mess_nope[id] = 0.0;
	g_random_next_use_mess[id] = 0.0;
	
	new task_id = TASK_INVINCIBLE + id;
	if ( task_exists(task_id) )
	{
		TaskRemoveInvincibility(task_id);
		remove_task(task_id);
	}
	
	task_id = TASK_STEALTH + id;
	if ( task_exists(task_id) )
	{
		TaskRemoveStealth(task_id);
		remove_task(task_id);
	}
	
	task_id = TASK_BOOTSOFSPEED + id;
	if ( task_exists(task_id) )
	{
		TaskRemoveBootsOfSpeed(task_id);
		remove_task(task_id);
	}
	task_id = TASK_CAMOUFLAGE + id;
	if ( task_exists(task_id) )
	{
		//TaskRemoveBootsOfSpeed(task_id);
		remove_task(task_id);
		//Zmiana modelu na poprzedni
		cs_set_user_model(id, gszCamouflageOldModel[id]);
	}
	
	for(new k = 0;k<27;k++)
	{
		WeaponUsed[k][id] = false;
	}
	
	HeUsed[id] = false;
	FlashUsed[id] = false;
	SmokeUsed[id] = false;
	AllGrenadesUsed[id] = false;
	ChanceUsed[id] = false;
	
	if(g_connected[id] && g_alive[id])
	{
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 255);
		ResetMaxspeed(id);
	}
	
	g_reseted[id] =			true;
}

ResetMaxspeed(id)
{
	static Float:max_speed;
	switch ( get_user_weapon(id) )
	{
		case CSW_SG550, CSW_AWP, CSW_G3SG1:					max_speed = 210.0;
		case CSW_M249:										max_speed = 220.0;
		case CSW_AK47:										max_speed = 221.0;
		case CSW_M3, CSW_M4A1:								max_speed = 230.0;
		case CSW_SG552:										max_speed = 235.0;
		case CSW_XM1014, CSW_AUG, CSW_GALIL, CSW_FAMAS:		max_speed = 240.0;
		case CSW_P90:										max_speed = 245.0;
		case CSW_SCOUT:										max_speed = 260.0;
		default:											max_speed = 250.0;
	}
	
	if(get_pcvar_num(agm_status) == 1){
		max_speed = max_speed += sgpm_fast_knife_speed(id);
	}
	
	entity_set_float(id, EV_FL_maxspeed, max_speed);
}

BCM_Print(id, const message_fmt[], any:...)
{
	static i; i = id ? id : GetPlayer();
	if ( !i ) return;
	
	static message[256], len;
	len = formatex(message, charsmax(message), "^4[ScreamGaming]^3 ");
	vformat(message[len], charsmax(message) - len, message_fmt, 3);
	message[192] = 0;
	
	if(is_user_connected(i) && (cs_get_user_team(i) == CS_TEAM_CT || cs_get_user_team(i) == CS_TEAM_T))
	{
		static msgid_SayText;
		if ( !msgid_SayText ) msgid_SayText = get_user_msgid("SayText");
	
		static const team_names[][] =
		{
			"",
			"TERRORIST",
			"CT",
			"SPECTATOR"
		};
	
		static team; team = get_user_team(i);
		
		TeamInfo(i, id, team_names[0]);
	
		message_begin(id ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, msgid_SayText, _, id);
		write_byte(i);
		write_string(message);
		message_end();
	
		TeamInfo(i, id, team_names[team]);
	}
}

TeamInfo(receiver, sender, team[])
{
	static msgid_TeamInfo;
	if ( !msgid_TeamInfo ) msgid_TeamInfo = get_user_msgid("TeamInfo");
	
	message_begin(sender ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, msgid_TeamInfo, _, sender);
	write_byte(receiver);
	write_string(team);
	message_end();
}

GetPlayer()
{
	for ( new id = 1; id <= g_max_players; id++ )
	{
		if ( !g_connected[id] ) continue;
		
		return id;
	}
	
	return 0;
}
public taskCamouflageRemove(id)
{
	id -= TASK_CAMOUFLAGE;
	
	//if player is still connected
	if (is_user_connected(id))
	{
		//change back to players old model
		cs_set_user_model(id, gszCamouflageOldModel[id]);
	}
}

public SetRenderingBlock(id)
{
	static arg[5];
	read_argv(1, arg, charsmax(arg));
	
	if ( !strlen(arg) )
	{
		BCM_Print(id, "You can't set a property blank! Please type a new value.");
		client_cmd(id, "messagemode BCM_SetRendering");
		return PLUGIN_HANDLED;
	}
	else if ( !IsStrFloat(arg) )
	{
		BCM_Print(id, "You can't use letters in a property! Please type a new value.");
		client_cmd(id, "messagemode BCM_SetRendering");
		return PLUGIN_HANDLED;
	}
	new check = str_to_num(arg);
	if(check < 0 || check > 255)
	{
		BCM_Print(id, "The property has to be between^1 0^3 and^1 255^3!");
		client_cmd(id, "messagemode BCM_SetRendering");
		return PLUGIN_HANDLED;
	}
	
	if(gRenderInfo[id] == 1)
	{
		Transperancy_RM[id] = str_to_num(arg);
	}
	if(gRenderInfo[id] == 2)
	{
		Color_Red_RM[id] = str_to_num(arg);
	}
	if(gRenderInfo[id] == 3)
	{
		Color_Green_RM[id] = str_to_num(arg);
	}
	if(gRenderInfo[id] == 4)
	{
		Color_Blue_RM[id] = str_to_num(arg);
	}
	
	ShowRenderMenu(id);
	return PLUGIN_HANDLED;
}

public SetSkip(id)
{
	static arg[5];
	read_argv(1, arg, charsmax(arg));
	
	if ( !strlen(arg) )
	{
		BCM_Print(id, "You can't set a property blank! Please type a new value.");
		client_cmd(id, "messagemode Set_SkipTime");
		return PLUGIN_HANDLED;
	}
	else if ( !IsStrFloat(arg) )
	{
		BCM_Print(id, "You can't use letters in a movement number! Please type a new value.");
		client_cmd(id, "messagemode Set_SkipTime");
		return PLUGIN_HANDLED;
	}
	
	new Float:check = str_to_float(arg);
	if(check < 0.0 || check > 1000.0)
	{
		BCM_Print(id, "The property has to be >= 0 and <= 1000!");
		client_cmd(id, "messagemode Set_SkipTime");
		return PLUGIN_HANDLED;
	}
	
	if(check != 0.0){
		user_skip_time[id] = check;
	}else{
		user_skip_time[id] = 1337.0;
	}
	
	ShowSkipMenu(id);
	
	return PLUGIN_HANDLED;
}

public SetMovement(id)
{
	static arg[5];
	read_argv(1, arg, charsmax(arg));
	
	if ( !strlen(arg) )
	{
		BCM_Print(id, "You can't set a property blank! Please type a new value.");
		client_cmd(id, "messagemode Set_Movement");
		return PLUGIN_HANDLED;
	}
	else if ( !IsStrFloat(arg) )
	{
		BCM_Print(id, "You can't use letters in a movement number! Please type a new value.");
		client_cmd(id, "messagemode Set_Movement");
		return PLUGIN_HANDLED;
	}
	
	new check = str_to_num(arg);
	if(check <= 25 && check != 0)
	{
		BCM_Print(id, "The property has to be many^1 25^3!");
		client_cmd(id, "messagemode Set_Movement");
		return PLUGIN_HANDLED;
	}
	
	if(MovementType[id] == 1)
		g_Distance[id] = str_to_num(arg);
	
	if(MovementType[id] == 2)
		g_Axis[id][0] = str_to_float(arg);
	
	if(MovementType[id] == 3)
		g_Axis[id][1] = str_to_float(arg);
	
	if(MovementType[id] == 4)
		g_Axis[id][2] = str_to_float(arg);
	
	ShowMovementMenu(id);
	
	return PLUGIN_HANDLED;
}

public SetRotateTime(id)
{
	static arg[5];
	read_argv(1, arg, charsmax(arg));
	
	if ( !strlen(arg) )
	{
		BCM_Print(id, "You can't set a property blank! Please type a new value.");
		client_cmd(id, "messagemode Set_RotateTime");
		return PLUGIN_HANDLED;
	}
	else if ( !IsStrFloat(arg) )
	{
		BCM_Print(id, "You can't use letters in a rotate time! Please type a new value.");
		client_cmd(id, "messagemode Set_RotateTime");
		return PLUGIN_HANDLED;
	}
	
	new check = str_to_num(arg);
	if(check <= 0 && check > 100)
	{
		BCM_Print(id, "The property has to be between^1 0^3 and 101!");
		client_cmd(id, "messagemode Set_RotateTime");
		return PLUGIN_HANDLED;
	}
	
	user_rotate_time[id] = str_to_float(arg);
	ShowRotateMenu(id);
	return PLUGIN_HANDLED;
}

stock create_you_entity(const classname[])
{
	new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));
	if(pev_valid(ent))
	{
		set_pev(ent, pev_classname, classname);
		return ent;
	}
	return 0;
}

stock set_entity_rendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16) 
{
	static Float:rendercolor[3];
	rendercolor[0] = float(r);
	rendercolor[1] = float(g);
	rendercolor[2] = float(b);

	set_pev(entity, pev_renderfx, fx);
	set_pev(entity, pev_rendercolor, rendercolor);
	set_pev(entity, pev_rendermode, render);
	set_pev(entity, pev_renderamt, float(amount));

	return 1;
}

public checkstuck(player) 
{
	static Float:origin[3];
	static Float:mins[3], hull;
	static Float:vec[3];
	static o;
	if (is_user_connected(player)) 
	{
		if(is_user_alive(player))
		{
			pev(player, pev_origin, origin);
			hull = pev(player, pev_flags) & FL_DUCKING ? HULL_HEAD : HULL_HUMAN;
			if (!is_hull_vacant(origin, hull,player) && !get_user_noclip(player) && !(pev(player,pev_solid) & SOLID_NOT)){
				if(g_checker_stuck[player] > 12){
					g_checker_stuck[player] = 0;
				}else{
					g_checker_stuck[player]++;
					return PLUGIN_CONTINUE;
				}
				
				pev(player, pev_mins, mins);
				vec[2] = origin[2];
				for (o=0; o < sizeof size; ++o)
				{
					vec[0] = origin[0] - mins[0] * size[o][0];
					vec[1] = origin[1] - mins[1] * size[o][1];
					vec[2] = origin[2] - mins[2] * size[o][2];
				
					if (is_hull_vacant(vec, hull,player))
					{
						engfunc(EngFunc_SetOrigin, player, vec);
						set_pev(player,pev_velocity,{0.0,0.0,0.0});
						o = sizeof size;
					}
				}
			}else{
				g_checker_stuck[player] = 0;
			}
		}
	}
	
	return PLUGIN_CONTINUE;
}

stock bool:is_hull_vacant(const Float:origin[3], hull,id) {
	static tr;
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, id, tr);
	if (!get_tr2(tr, TR_StartSolid) || !get_tr2(tr, TR_AllSolid)) //get_tr2(tr, TR_InOpen))
		return true;
	
	return false;
}