//All the fuctions :]

public void OnPluginStartFunc()
{
	//WeaponMenu_PluginStart();
	Cookies_OnPluginStart();
	Configs_OnPluginStartFunc();
}

public void OnMapStart()
{
	g_RoundRestartDelayCvar = FindCvarAndLogError("mp_round_restart_delay");
	WeaponMenu_MapStart();
	Spawns_MapStart();
	Cvars_MapStart();
}


public void OnConfigsExecuted() 
{
	Cvars_OnConfigsExecuted();
}

public Action Event_RoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	g_roundStartedTime = GetTime();
	b_NullOnce = true;
	
	return Plugin_Continue;
}

public Action Event_OnRoundPostStart(Event event, const char[] name, bool dontBroadcast) 
{
	SetCvar("mp_autoteambalance",				"0"); 
	SetCvar("mp_ignore_round_win_conditions", 	"1");
	g_Timelimit = FindCvarAndLogError("mp_timelimit");
	GameRules_SetProp("m_iRoundTime", g_Timelimit.IntValue * 60, 4, 0, true);
	
	return Plugin_Continue;	
}

public void OnClientPutInServer(int client)
{
	//Kick bots
	if(IsFakeClient(client))
		ServerCommand("bot_kick");
	
	WeaponMenu_OnClientPutInServer(client);
	Players_OnClientPutInServer(client);
	PlayerFirstJoin_OnClientPutInServer(client);
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	Cookies_OnClientPutInServer(client);
	ShowDamage_OnClientPutInServer(client);
	Challenge_OnClientPutInServer(client);
}


public void OnClientDisconnect(int client)
{
	Players_OnClientDisconnect(client);
	Challenge_OnClientDisconnect(client);
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action Event_OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	HideRadar_OnPlayerSpawn(client);
	//Players2_OnPlayerSpawn(client);
	
	return Plugin_Continue;
}

public Action Event_OnPlayerTeam(Event event, const char[] name, bool dontBroadcast) 
{
	int client 	= GetClientOfUserId(event.GetInt("userid"));
	int team 	= event.GetInt("team");
	if(!IsFakeClient(client))
	{
		//Players_OnPlayerTeam(client);
		Cookies_OnPlayerTeam(client);
		PlayersFirstJoin_OnPlayerTeam(client, team);
		SetEventBroadcast(event, true);
		
		//Possibly bug fix?
		if(i_PlayerEnemy[client] > 0 && IsClientInGame(i_PlayerEnemy[client]) && i_PlayerEnemy[i_PlayerEnemy[client]] == client)
		{
			TeleportToLobby(i_PlayerEnemy[client], true, true);
			TeleportToLobby(client, true);
		}
	}
	
	return Plugin_Continue;
}

public Action Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
	//int client 		= GetClientOfUserId(event.GetInt("userid"));
	int attacker 	= GetClientOfUserId(event.GetInt("attacker"));
	int damage 		= event.GetInt("dmg_health");
	
	ShowDamage_PlayerHurt(attacker, damage);
	
	return Plugin_Continue;
}

public Action Event_OnPlayerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	int client 		= GetClientOfUserId(event.GetInt("userid"));
	int attacker 	= GetClientOfUserId(event.GetInt("attacker"));
	Players_OnPlayerDeath(client, attacker);
	KillSound_OnPlayerDeath(attacker);
	ShowDamage_OnPlayerDeath(client, attacker);
	
	//Hide killfeed
	bool headshot 	= GetEventBool(event, "headshot", false);
	char sWeapon[128];
	GetEventString(event, "weapon", sWeapon, 128);
	int penetrated = event.GetInt("penetrated");
	
	KillFeed_PlayerDeath(client, attacker, sWeapon, headshot, penetrated);
	
	if(g_ShowKillFeedCvar.IntValue == 0)
		SetEventBroadcast(event, true);
	
	return Plugin_Continue;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Stop timer in that arena (afk timer?)
	if(IsClientInGame(victim) && attacker > 0)
		KillDamageTimer(i_PlayerArena[victim]);
	
	//Stop damage in lobby
	if(i_PlayerArena[victim] == LOBBY || i_PlayerArena[attacker] == LOBBY)
		return Plugin_Handled;
		
	//Stop damage if your not damaging your enemy
	if(i_PlayerEnemy[victim] != attacker && attacker > 0 || i_PlayerEnemy[attacker] != victim && attacker > 0)
		return Plugin_Handled;
	
	return Plugin_Continue;
}


public void OnGameFrame()
{
	if(b_NullOnce)
	{
		if(GetTotalRoundTime() == GetCurrentRoundTime())
		{
			b_NullOnce = false;
			SetCvar("mp_ignore_round_win_conditions", "0");
			CreateTimer(1.0, EndRound, _, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public Action EndRound(Handle tmr, any client)
{
	float delay = g_RoundRestartDelayCvar.FloatValue;
	CS_TerminateRound(delay, CSRoundEnd_TerroristWin);
	
	
	
	return Plugin_Continue;
}

public int GetTotalRoundTime() 
{
	return GameRules_GetProp("m_iRoundTime");
}

public int GetCurrentRoundTime() 
{
	static Handle h_freezeTime = null;
	
	if(h_freezeTime == null)
		h_freezeTime = FindConVar("mp_freezetime");
	
	int freezeTime = GetConVarInt(h_freezeTime);
	return (GetTime() - g_roundStartedTime) - freezeTime;
}

stock ConVar FindCvarAndLogError(const char[] name) {
    ConVar c = FindConVar(name);
    if (c == null) {
        LogError("ConVar \"%s\" could not be found");
    }
    return c;
}