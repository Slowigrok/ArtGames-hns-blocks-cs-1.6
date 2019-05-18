native chat_blocks(player, player_id)

#include <amxmodx>
#include <amxmisc>

#define VIP_FLAG VIP_FLAG_ALL
#define ACCESS_FLAG VIP_FLAG_ALL

new isAlive
new StrTeam
new maxPlayers
new TeamInfo
new SayText
new player_id

//chat
new Message[512]
new s_Name[128]
new steam_id[36]
new p_Message[256]
new p_Name[256]
new s_Msg[192]
new StrName[64]
new Alive[32]
new TeamName[10]
new p_Team[32]

new bool:g_vip[33];
new bool:g_admin[33];

public plugin_init() 
{
	register_plugin("VipPlugin", "1.2", "slavok1717");
	register_event("ResetHUD", "ResetHUD", "be")
	
	maxPlayers = get_maxplayers();
	 
	register_clcmd("say", "hook_say")
	register_clcmd("say_team", "hook_say_team")
	register_clcmd("say /vips", "ShowVipsOnline");
	register_clcmd("say /admins", "ShowAdminsOnline");
	
	SayText = get_user_msgid("SayText")
	TeamInfo = get_user_msgid("TeamInfo")
}

public client_putinserver(id)
{
	g_vip[id] =	bool:access(id, ADMIN_LEVEL_H);
	g_admin[id] =	bool:access(id, ADMIN_LEVEL_A);
}

public hook_say(id)
{
	if(is_user_hltv(id) || is_user_bot(id))
	{
		return PLUGIN_CONTINUE
	}
	read_args(s_Msg, 191)
	remove_quotes(s_Msg)
	
	replace_all(s_Msg, 191, "%s", "");
	
	if(s_Msg[0] == '/' || s_Msg[0] == '@' || s_Msg[0] == '!')
		return PLUGIN_CONTINUE;
	
	get_user_name(id, s_Name, 31)
	get_user_authid(id, steam_id, 35)
	
	if(get_user_flags(id) & ADMIN_LEVEL_B)
	{
		format(StrName, 63, "[Главный Админ] %s", s_Name)
	}
	else if(equal(steam_id, "STEAM_0:1:49882402"))
	{
		format(StrName, 63, "[Папа Серж] %s", s_Name)
	}
	else if(g_admin[id])
	{
		format(StrName, 63, "[Администратор] %s", s_Name)
	}
	else if(g_vip[id] && !g_admin[id])
	{
		format(StrName, 63, "[Vip] %s", s_Name)
	}
	else if(equal(s_Name, "WoodPeker"))
	{
		format(StrName, 63, "[Задрот] %s", s_Name)
	}
	else
	{
		format(StrName, 63, "%s", s_Name)
	}
	if(is_user_alive(id))
	{
		isAlive = 1
		format(Alive, 31, "^x01")
	}
	else
	{
		isAlive = 0
		format(Alive, 31, "^x01*DEAD* ")
	}
	static color[10]
	if(g_vip[id] || g_admin[id])
	{
		get_user_team(id, color, 9)
		format(p_Name, 255, "%s^x03%s", Alive, StrName)
		format(p_Message, 255, "^x04%s", s_Msg)
	}
	else
	{
		get_user_team(id, color, 9)
		format(p_Name, 255, "%s^x03%s", Alive, StrName)
		format(p_Message, 255, "%s", s_Msg)
	}
	
	format(Message, 512, "%s ^x01: %s", p_Name, p_Message)
	
	player_id = id;
	
	SendMessageAll(color)

	return PLUGIN_HANDLED
}

public hook_say_team(id)
{
	if(is_user_hltv(id) || is_user_bot(id))
	{
		return PLUGIN_CONTINUE
	}
	read_args(s_Msg, 191)
	remove_quotes(s_Msg)
	
	replace_all(s_Msg, 191, "%s", "");
	
	if(s_Msg[0] == '/' || s_Msg[0] == '@' || s_Msg[0] == '!')
		return PLUGIN_CONTINUE;
	
	StrTeam = get_user_team(id)
	switch(StrTeam)
	{
		case 1:
		{
			format(p_Team, 31, "(Terrorist)")
		}
		case 2:
		{
			format(p_Team, 31, "(Counter-Terrorist)", LANG_PLAYER, "CT_CT")
		}
		case 3:
		{
			format(p_Team, 31, "(Spectator)")
		}
	}
	get_user_name(id, s_Name, 31)
	get_user_authid(id, steam_id, 35)
	
	if(get_user_flags(id) & ADMIN_LEVEL_B)
	{
		format(StrName, 63, "[Главный Админ] %s", s_Name)
	}
	else if(equal(steam_id, "STEAM_0:1:49882402"))
	{
		format(StrName, 63, "[Папа Серж] %s", s_Name)
	}
	else if(g_admin[id])
	{
		format(StrName, 63, "[Администратор] %s", s_Name)
	}
	else if(g_vip[id] && !g_admin[id])
	{
		format(StrName, 63, "[Vip] %s", s_Name)
	}
	else if(equal(s_Name, "WoodPeker"))
	{
		format(StrName, 63, "[Задрот] %s", s_Name)
	}
	else
	{
		format(StrName, 63, "%s", s_Name)
	}
	if(is_user_alive(id))
	{
		isAlive = 1
		format(Alive, 31, "^x01")
	}
	else
	{
		isAlive = 0
		format(Alive, 31, "^x01*DEAD* ")
	}
	static color[10]
	if(g_vip[id] || g_admin[id])
	{
		get_user_team(id, color, 9)
		format(p_Name, 255, "%s%s ^x03%s", Alive, p_Team, StrName)
		format(p_Message, 255, "^x04%s", s_Msg)
	}
	else
	{
		get_user_team(id, color, 9)
		format(p_Name, 255, "%s%s ^x03%s", Alive, p_Team, StrName)
		format(p_Message, 255, "%s", s_Msg)
	}
	
	format(Message, 511, "%s ^x01: %s", p_Name, p_Message)
	
	player_id = id;
	
	SendTeamMessage(color, isAlive, StrTeam)

	return PLUGIN_HANDLED
}

public SendMessageAll(color[])
{
	for(new player = 0; player < get_maxplayers(); player++)
	{
		if(!is_user_connected(player) || chat_blocks(player, player_id))
		{
			continue
		}
		
		console_print(player, "%s : %s", s_Name, s_Msg)
		get_user_team(player, TeamName, 9)
		ChangeTeamInfo(player, color)
		WriteMessage(player, Message)
		ChangeTeamInfo(player, TeamName)
	}
}

public SendTeamMessage(color[], alive, playerTeam)
{
	for (new player = 0; player < get_maxplayers(); player++)
	{
		if (!is_user_connected(player) || chat_blocks(player, player_id))
		{
			continue
		}
		
		if(get_user_team(player) == playerTeam || g_admin[player])
		{
			if (alive && is_user_alive(player) || g_admin[player])
			{
				console_print(player, "%s : %s", s_Name, s_Msg)
				get_user_team(player, TeamName, 9)
				ChangeTeamInfo(player, color)
				WriteMessage(player, Message)
				ChangeTeamInfo(player, TeamName)
			}
		}
	}
}

public ChangeTeamInfo (player, team[])
{
	message_begin(MSG_ONE, TeamInfo, _, player)
	write_byte(player)
	write_string(team)
	message_end()
}


public WriteMessage (player, message[])
{
	message_begin(MSG_ONE, SayText, _, player)
	write_byte (player)
	write_string (message)
	message_end()
}

public ShowAdminsOnline(id)
{
	new message[256], name[32], count = 0;
	new len = format(message, charsmax(message), "^04Admins Online^03: ");
	
	for (new player = 1; player <= maxPlayers; ++player)
	{
		if (is_user_connected(player) && g_admin[player])
		{
			get_user_name(player, name, charsmax(name));
			
			if (count && len)
			{
				len += format(message[len], 255 - len, "^03, ");
			}
			
			len += format(message[len], 255 - len, "^04%s", name);
			
			++count;
		}
	}
	
	if (len)
	{
		if (!count)
		{
			len += format(message[len], 255 - len, "^03No admins online.");
		}
		
		len += format(message[len], 255 - len, ". ^03Skype main admin - ^04slavoookk^03.");
		
		Print(id, "%s", message);
	}
}

public ShowVipsOnline(id)
{
	new message[256], name[32], count = 0;
	new len = format(message, charsmax(message), "^04Vips Online^03: ");
	
	for (new player = 1; player <= maxPlayers; ++player)
	{
		if (is_user_connected(player) && g_vip[player])
		{
			get_user_name(player, name, charsmax(name));
			
			if (count && len)
			{
				len += format(message[len], 255 - len, "^03, ");
			}
			
			len += format(message[len], 255 - len, "^04%s", name);
			
			++count;
		}
	}
	
	if (len)
	{
		if (!count)
		{
			len += format(message[len], 255 - len, "^03No vips online.");
		}
		
		len += format(message[len], 255 - len, ". ^03Skype main admin - ^04slavoookk^03.");
		
		Print(id, "%s", message);
	}
}

public ResetHUD(id)
{
	set_task(0.5, "VIP", id + 6910)
}

public VIP(TaskID)
{
	new id = TaskID - 6910
	
	if(g_vip[id])
	{
		message_begin(MSG_ALL, get_user_msgid("ScoreAttrib"))
		write_byte(id)
		write_byte(4)
		message_end()
	}
}

Print(iPlayer, const sMsg[], any:...) 
{
	static i; i = iPlayer ? iPlayer : get_Player();
	if ( !i ) return;
	
	new sMessage[256];
	new len = formatex(sMessage, sizeof(sMessage) - 1, "");
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

