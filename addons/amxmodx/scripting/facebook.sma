#include <amxmodx>
#include <cstrike>
#include <fun>

// ColorChat Included
enum CC_Colors
{
	YELLOW = 1,	// 1; Yellow;		^x01;	default
	GREEN,		// 2; Green;		^x04
	TEAM_COLOR,	// 3; Red, Blue, Grey;	^x03;	teamcolor(t;ct;spec)
	GREY,		// 4; Grey;		Spectator Color
	RED,		// 5; Red;		Terrorist Color
	BLUE,		// 6; Blue;	Counter-Terrorist Color
}

new CC_TeamName[][] =
{
	"",
	"TERRORIST",
	"CT",
	"SPECTATOR"
};

public ColorChat(id, CC_Colors:type, const msg[], {Float,Sql,Result,_}:...)
{
	if (get_playersnum() < 1)
	{
		return;
	}
	static CC_message[256];
	switch(type)
	{
		case YELLOW:
		{
			CC_message[0] = 0x01;
		}
		case GREEN:
		{
			CC_message[0] = 0x04;
		}
		default:
		{
			CC_message[0] = 0x03;
		}
	}
	vformat(CC_message[1], 251, msg, 4);
	CC_message[192] = '^0';
	new CC_team, CC_ColorChange, index, MSG_Type;
	if (!id)
	{
		index = CC_FindPlayer();
		MSG_Type = MSG_ALL;
	}
	else
	{
		MSG_Type = MSG_ONE;
		index = id;
	}
	CC_team = get_user_team(index);
	CC_ColorChange = CC_ColorSelection(index, MSG_Type, type);
	CC_ShowColorMessage(index, MSG_Type, CC_message);
	if (CC_ColorChange)
	{
		CC_TeamInfo(index, MSG_Type, CC_TeamName[CC_team]);
	}
}

CC_ShowColorMessage(index, type, message[])
{
	static CC_SayText;
	if (!CC_SayText)
	{
		CC_SayText = get_user_msgid("SayText");
	}
	message_begin(type, CC_SayText, _, index);
	write_byte(index);
	write_string(message);
	message_end();
}

CC_TeamInfo(index, type, team[])
{
	static CC_TeamInfo;
	if (!CC_TeamInfo)
	{
		CC_TeamInfo = get_user_msgid("TeamInfo");
	}
	message_begin(type, CC_TeamInfo, _, index);
	write_byte(index);
	write_string(team);
	message_end();
	return 1;
}

CC_ColorSelection(index, type, CC_Colors:Type)
{
	switch(Type)
	{
		case RED:
		{
			return CC_TeamInfo(index, type, CC_TeamName[1]);
		}
		case BLUE:
		{
			return CC_TeamInfo(index, type, CC_TeamName[2]);
		}
		case GREY:
		{
			return CC_TeamInfo(index, type, CC_TeamName[0]);
		}
	}
	return 0;
}

CC_FindPlayer()
{
	new index = -1;
	while(index <= get_maxplayers())
	{
		if (is_user_connected(++index))
		{
			return index;
		}
	}
	return -1;
}

public plugin_init()
{
	register_plugin("Facebook", "1.0", "TSM - Mr.Pro");
	register_clcmd("say /facebook", "facebooksite");
	register_clcmd("say /fb", "facebooksite");
	register_clcmd("say_team /facebook", "facebooksite");
	register_clcmd("say_team /fb", "facebooksite");
}

public facebooksite(id)
{
	
	ColorChat(id, GREEN, "[^3CSDM^4]=>^3 Facebook of^4 TSM - Mr.Pro^3 facebook :^4 https://www.facebook.com/cs.pro.usman");
}
