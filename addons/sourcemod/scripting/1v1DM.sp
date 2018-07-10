#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "boomix"
#define PLUGIN_VERSION "1.31"

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>
#include <clientprefs>


//File includes
#include "1v1dm/1v1_Globals.sp"
#include "1v1dm/1v1_Functions.sp"
#include "1v1dm/1v1_Configs.sp"
#include "1v1dm/1v1_Cvars.sp"
#include "1v1dm/1v1_Cookies.sp"
#include "1v1dm/1v1_WeaponMenu.sp"
#include "1v1dm/1v1_HideRadar.sp"
#include "1v1dm/1v1_Spawns.sp"
#include "1v1dm/1v1_Players2.sp"
#include "1v1dm/1v1_PlayerFirstJoin.sp"
#include "1v1dm/1v1_HideBlood.sp"
#include "1v1dm/1v1_KillSound.sp"
#include "1v1dm/1v1_AWPDuel.sp"
#include "1v1dm/1v1_KillFeed.sp"
#include "1v1dm/1v1_ShowDamage.sp"
#include "1v1dm/1v1_FlashbangDuel.sp"
#include "1v1dm/1v1_Challenge.sp"

#pragma newdecls required

EngineVersion g_Game;

public Plugin myinfo = 
{
	name = "1v1 deathmatch (duels)",
	author = PLUGIN_AUTHOR,
	description = "1v1 deathmatch for CS:GO (duels)",
	version = PLUGIN_VERSION,
	url = "http://identy.lv"
};

public void OnPluginStart()
{
	g_Game = GetEngineVersion();
	if(g_Game != Engine_CSGO)
		SetFailState("This plugin is for CS:GO only.");	

	
	//** COMMANDS **//
	RegConsoleCmd("sm_guns", 		CMD_Weapons, 	"Opens up menu with avalible weapons");
	RegConsoleCmd("sm_weapons", 	CMD_Weapons, 	"Opens up menu with avalible weapons 2");
	RegConsoleCmd("sm_menu", 		CMD_Weapons, 	"Opens up menu with avalible weapons 3");
	RegConsoleCmd("sm_weapon", 		CMD_Weapons, 	"Opens up menu with avalible weapons 4");
	RegConsoleCmd("sm_lobby", 		CMD_Lobby, 		"Teleports player to lobby");
	
	//** CHALLANGE **//
	RegConsoleCmd("sm_challenge", 	CMD_Challenge, 	"Challenge other player/friend");
	RegConsoleCmd("sm_challange", 	CMD_Challenge, 	"Challenge other player/friend");
	RegConsoleCmd("sm_chal", 		CMD_Challenge, 	"Challenge other player/friend 2");
	RegConsoleCmd("sm_c", 			CMD_Challenge, 	"Challenge other player/friend 3");
	RegConsoleCmd("sm_duel", 		CMD_Challenge, 	"Challenge other player/friend 4");
	RegConsoleCmd("sm_duels", 		CMD_Challenge, 	"Challenge other player/friend 4");
	RegConsoleCmd("sm_accept", 		CMD_Accept,		"Accept challange command");
	RegConsoleCmd("sm_deny", 		CMD_Deny, 		"Deny challange command");
	RegConsoleCmd("sm_stop", 		CMD_Deny, 		"Stop challange that your inside now");
	RegConsoleCmd("sm_end", 		CMD_Deny, 		"Stop challange that your inside now 2");
	
	//Dev
	RegConsoleCmd("sm_status", 		CMD_Status);

	//Command without ! and /
	AddCommandListener(CMD_Say, "say");
	AddCommandListener(CMD_Say, "say_team");

	RegAdminCmd("sm_spawn", CMD_Spawn, ADMFLAG_BAN);

	OnPluginStartFunc();
	
	HookEvent("round_start", 		Event_RoundStart);
	HookEvent("round_poststart", 	Event_OnRoundPostStart);
	HookEvent("player_spawn", 		Event_OnPlayerSpawn);
	HookEvent("player_team", 		Event_OnPlayerTeam);
	HookEvent("player_death", 		Event_OnPlayerDeath, 	EventHookMode_Pre);
	HookEvent("player_team", 		Event_OnPlayerTeam2, 	EventHookMode_Pre);
	HookEvent("player_hurt", 		Event_PlayerHurt, 		EventHookMode_Pre);
	
	//Command listners
	AddCommandListener(BlockKill, 		"kill");
	AddCommandListener(BlockKill, 		"explode");
	AddCommandListener(Event_JoinTeam, 	"jointeam");
	
	//Blood thing
	AddTempEntHook("World Decal", TE_OnWorldDecal);
	
	
	g_offsCollisionGroup 	= FindSendPropInfo("CBaseEntity", "m_CollisionGroup");
	LoadTranslations("1v1DM.phrases");

}

public Action CMD_Lobby(int client, int args)
{
	if(i_PlayerArena[client] != LOBBY)
	{
		if(!IsInRightTeam(client))
			ChangeClientTeam(client, CS_TEAM_CT);
		
		if(!IsPlayerAlive(client))
			CS_RespawnPlayer(client);
			
		if(i_PlayerArena[client] != LOBBY && i_PlayerArena[client] != -1)
			KillDamageTimer(i_PlayerArena[client]);
			
		
		int opponent = i_PlayerEnemy[client];
		if(opponent > 0)
		{
			if(IsClientInGame(opponent) && IsInRightTeam(opponent))
			{
				i_PrevEnemy[opponent] = -1;
				b_ArenaFree[i_PlayerArena[opponent]] = true;
				TeleportToLobby(opponent, true, true);
			}
		}
		
		
		TeleportToLobby(client, false);
		
		CMD_Deny(client, 0);
		
		g_PrimaryWeapon[client] = "";
		g_SecondaryWeapon[client] = "";
		b_FirstWeaponSelect[client] = true;
		b_HideMainWeaponMenu[client] = true;
		
		KillSearchTimer(client);
		
		ShowPrimaryWeaponMenu(client);
	}
	
	return Plugin_Handled;
}

public Action CMD_Status(int client, int args)
{
	if(IsClientInGame(client))
	{
		char waiting[10];
		if(b_WaitingForEnemy[client])
			waiting = "true";
		else
			waiting = "false";
			
		char search[10];
		if(SearchTmr[client] == null)
			search = "off";
		else
			search = "on";
			
		int showPlayer = 0;
		if(i_PlayerEnemy[client] > 0)
			showPlayer = i_PlayerEnemy[client];
		
		ReplyToCommand(client, "%sSTATUS: Waiting for enemy: %s | Enemy right now: %N | Arena: %i (LOBBY: %i) | Search tmr: %s", PREFIX, waiting, showPlayer, i_PlayerArena[client], LOBBY, search);
	
	}
	return Plugin_Handled;
}


public Action CMD_Say(int client, const char[] command, int argc)
{
	if(client > 0)
	{
		char message[128];
		GetCmdArgString(message, sizeof(message));
		ReplaceString(message, sizeof(message), "\"", "");
		
		//Guns
		if(StrEqual(message, "guns") || StrEqual(message, ".guns") )
		{
			CMD_Weapons(client, 1);
			return Plugin_Handled;
		}
		
		//Lobby
		if(StrEqual(message, "lobby") || StrEqual(message, ".lobby") )
		{
			CMD_Lobby(client, 1);
			return Plugin_Handled;
		}
	}
	
	return Plugin_Continue;
}

public Action CMD_Spawn(int client, int args)
{
	
	char arena[10];
	float org[3], ang[3];
	GetCmdArg(1, arena, sizeof(arena));
	//hud_message(client, arena);
	
	
	GetArenaSpawn(StringToInt(arena), GetClientTeam(client), org, ang);
	TeleportEntity(client, org, ang, NULL_VECTOR);
}

public Action Event_OnPlayerTeam2(Handle event, const char[] name, bool dontBroadcast)
{
	return (Plugin_Handled);
}

void hud_message(int client, char message[500]) 
{
	Format(message, sizeof(message), "%s\n%s", message, g_CustomRoundName[client]);
	
	int ent = !IsValidEntity(iTextEntity[client]) ? CreateEntityByName("game_text") : iTextEntity[client];
 	
 	iTextEntity[client] = ent;
 	
	DispatchKeyValue(ent, "channel", "1");
	DispatchKeyValue(ent, "color", "255 255 255");
	DispatchKeyValue(ent, "color2", "0 0 0");
	DispatchKeyValue(ent, "effect", "0");
	DispatchKeyValue(ent, "fxtime", "0.25"); 		
	DispatchKeyValue(ent, "holdtime", "3.0");
	DispatchKeyValue(ent, "message", message);
	DispatchKeyValue(ent, "x", "0.10");
	DispatchKeyValue(ent, "y", "0.155"); 		
	DispatchSpawn(ent);
	SetVariantString("!activator");
	AcceptEntityInput(ent, "display", client); 
	
	//CreateTimer(2.0, KillEntity, ent);
}  

public Action BlockKill(int client, const char[] command, int args)
{
	return Plugin_Handled;
}  

public Action Event_JoinTeam(int client, const char[] command, int arg)
{
	if(IsPlayerAlive(client))
		return Plugin_Handled;	
	else
		return Plugin_Continue;
}
