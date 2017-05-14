//DEBUGGER
public Action OnPlayerRunCmd(int client, int &iButtons, int &iImpulse, float fVelocity[3], float fAngles[3], int &iWeapon) 
{
	char we[10];
	if(b_WaitingForEnemy[client])
		we = "true";
	else
		we = "false";
		
	int client2 = 0;
	if(i_PlayerEnemy[client] != -1)
		client2 = i_PlayerEnemy[client];
		
	
	PrintHintText(client, "waiting: %s|arena: %i\n enemy: %N", we, i_PlayerArena[client], client2);

}


void Players_OnClientPutInServer(int client)
{
	b_WaitingForEnemy[client] = false;
	b_FirstTeamJoin[client] = true;
	i_PrevArena[client] = -1;
	i_PlayerArena[client] = LOBBY;
	i_PlayerEnemy[client] = -1;
}

void Players_OnPlayerTeam(int client)
{
	if(b_FirstTeamJoin[client])
	{
		CreateTimer(0.2, FirstJoin, client);
		b_FirstTeamJoin[client] = false;
	}	
}

void Players_OnClientDisconnect(int client)
{

	//If the player is with someone in arena
	if(client > 0)
	{
		if(!b_WaitingForEnemy[client] && i_PlayerArena[client] != LOBBY && !IsFakeClient(client))
		{
			
			int client2 = OnePlayerLeftEvent(client);
			if(client2 > 0){
				if(IsClientInGame(client2)){
						PrintToChat(client2, "%sYour enemy left the game! Finding new enemy", PREFIX);
						//PrintToConsole(client2, "ENEMY DISCONNECTED: %i(%N)", client, client);
					}		
				}
			}
			
	}
}


int OnePlayerLeftEvent(int client)
{
	if(client > 0)
	{
		//Find player with who he was in arena
		int client2 = i_PlayerEnemy[client];
				
		if(client2 == -1)
			return -1;
		
		//Teleport the player to lobby
		TeleportToLobby(client2);
		b_WaitingForEnemy[client2] = true;
			
		//Set arena free
		b_ArenaFree[i_PlayerArena[client]] = true;
		
		return client2;
	}
	
	return -1;
}

public Action FirstJoin(Handle tmr, any client)
{
	if(IsClientInGame(client))
	{
		
		//Respawn player if he is dead
		if(!IsPlayerAlive(client))
			CS_RespawnPlayer(client);
		
		//Teleport to lobby
		float org[3], ang[3];
		GetArenaSpawn(LOBBY, GetClientTeam(client), org, ang);
		TeleportEntity(client, org, ang, NULL_VECTOR);
		
		//Show weapon menu
		ShowPrimaryWeaponMenu(client);	
	}

}

void Players_OnPlayerDeath(int client, int attacker)
{
	if(IsClientInGame(client))
	{
		//Teleport loser to lobby
		//CreateTimer(0.9, RespawnPlayer, client);
		CreateTimer(1.0, LobbyTeleport, client);
	}
	
	if(IsClientInGame(attacker))
	{
		//Create timer to get new enemy for the winner	
		CreateTimer(2.5, PlayerDeathNewEnemy, attacker);
	}
	
}

void TeleportToLobby(int client)
{
	if(client > 0 && IsClientInGame(client))
	{
		float org[3], ang[3];
		GetArenaSpawn(LOBBY, GetClientTeam(client), org, ang);
		TeleportEntity(client, org, ang, NULL_VECTOR);
		i_PlayerArena[client] = LOBBY;
	}
}

public Action RespawnPlayer(Handle tmr, any client)
{
	if(IsClientInGame(client))
		CS_RespawnPlayer(client);
}

public Action LobbyTeleport(Handle tmr, any client)
{
	if(IsClientInGame(client))
	{
		if(!IsPlayerAlive(client))
			CS_RespawnPlayer(client);
		
		TeleportToLobby(client);
		b_WaitingForEnemy[client] = true;
		i_PlayerEnemy[client] = -1;
	}
}

public Action PlayerDeathNewEnemy(Handle tmr, any client)
{
	if(IsClientInGame(client))
	{	

		//Remove him from his old arena (set arena free)
		b_ArenaFree[i_PlayerArena[client]] = true;
		i_PlayerEnemy[client] = -1;
		
		//Try to create their match
		int enemy = FindEnemy(client);
		PrintToConsole(client, "/PlayerDeathNewEnemy/ FOUND ENEMY: %i(%N)", enemy, enemy);
		if(enemy > 0 && !b_WaitingForEnemy[enemy] && i_PlayerArena[enemy] == LOBBY && !b_FirstWeaponSelect[enemy] && i_PlayerEnemy[client] == -1){
			if(IsClientInGame(enemy))
			{
				SetupMatch(client, enemy);
				PrintToConsole(client, "/PlayerDeathNewEnemy/ SETUPMATCH: %i(%N) | %i(%N)", client, client, enemy, enemy);
			}
		} else {
			b_WaitingForEnemy[client] = true;
			TeleportToLobby(client);
		}
		
	}
}

int FindEnemy(int player)
{
	PrintToConsole(player, "--------------------------");
	int clients[MAXPLAYERS + 1];
	int clientCount;
	LoopAllPlayers(i)
		if (b_WaitingForEnemy[i] && i != player && i_PlayerArena[i] == LOBBY && i > 0 && !b_FirstWeaponSelect[i] && i_PlayerEnemy[i] == -1)
			clients[clientCount++] = i;
	
	int newclient = (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount - 1)];
	
	if(!b_WaitingForEnemy[newclient])
		newclient = FindEnemy(player);
	
	b_WaitingForEnemy[newclient] = false;
	return newclient;
}

void SetupMatch(int client, int enemy, int arena = -1)
{
	
	//If there is no arena, generate one
	if(arena == -1)
		arena = GetFreeArena(i_PrevArena[client]);
		
	PrintToConsole(client, "/SetupMatch/ FOUND ARENA %i", arena);
		
	if(arena > 0)
	{
		
		i_PlayerEnemy[client] = enemy;
		i_PlayerEnemy[enemy] = client;
		
		//Check if player is still avalible
		//if(b_WaitingForEnemy[enemy] && i_PlayerArena[enemy] == LOBBY)
		//{
		
			//Set arena as not free (dont spawn others there)
			b_ArenaFree[arena] = false;
			i_PlayerArena[client] = arena;
			i_PlayerArena[enemy] = arena;
			
			i_PrevArena[client] = arena;
			i_PrevArena[enemy] = arena;
			
			b_WaitingForEnemy[client] = false;
			b_WaitingForEnemy[enemy] = false;
			
			//Setting up players
			SetupPlayer(client, enemy, arena, CS_TEAM_T);
			SetupPlayer(enemy, client, arena, CS_TEAM_CT);
			
			//Create backup timer to check for damage (if no damage, create new duel)
			ArenaDamageTmr[arena] = CreateTimer(25.0, CheckForDamage, arena);
		
		//} else {
		//	
		//	PrintToConsole(client, "/SetupMatch/ SORRY, PLAYER IS NOT AVALIBLE ANYMORE! :(");
		//	
		//}
		
	} else {
	
		PrintToChat(client, "Sorry, there was error, arena was not found!");
		PrintToConsole(client, "/SetupMatch/ Failed to find a free arena!");
	}

}

public Action CheckForDamage(Handle timer, any arena)
{
	LoopAllPlayers(i){
		if(i_PlayerArena[i] == arena){
			TeleportToLobby(i);
			b_WaitingForEnemy[i] = true;
			CreateTimer(0.5, SearchForNewEnemy, i);
		}
	}
	
	b_ArenaFree[arena] = true;

}

public Action SearchForNewEnemy(Handle tmr, any client)
{
	//Create their match
	if(b_WaitingForEnemy[client] && i_PlayerArena[client] == LOBBY)
	{
		int enemy = FindEnemy(client);
		if(enemy > 0 && !b_WaitingForEnemy[enemy] && i_PlayerArena[enemy] == LOBBY && !b_FirstWeaponSelect[enemy] && i_PlayerEnemy[client] == -1)
			if(IsClientInGame(enemy))
				SetupMatch(client, enemy);
	}
}

void SetupPlayer(int client, int client2, int arena, int team)
{

	PrintToConsole(client, "/SetupPlayer/ PLAYER SETUP changeteams");

	//Set clients team
	CS_SwitchTeam(client, team);

	PrintToConsole(client, "/SetupPlayer/ TELEPORT TO ARENA");

	//Teleport to arena
	float org[3], ang[3];
	GetArenaSpawn(arena, team, org, ang);
	TeleportEntity(client, org, ang, NULL_VECTOR);
	
	//Give player his own weapons
	int weapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
	if(weapon > 0) {
		RemovePlayerItem(client, weapon);
		RemoveEdict(weapon);
	}
	GivePlayerItem(client, g_PrimaryWeapon[client]);
	int weapon2 = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
	if(weapon2 > 0) {
		RemovePlayerItem(client, weapon2);
		RemoveEdict(weapon2);
	}
	GivePlayerItem(client, g_SecondaryWeapon[client]);
	
	//For safety set health and armor to 100
	SetEntityHealth(client, 100);
	SetEntProp(client, Prop_Send, "m_ArmorValue", 100, 10);
	
	PrintToConsole(client, "/SetupPlayer/ CREATE SHOW USERNAME SHIT");
	//Print in chat, vs who is he playing
	DataPack pack;
	CreateDataTimer(0.1, ShowUsername, pack);
	pack.WriteCell(client);
	pack.WriteCell(client2);
	//CreateTimer(0.1, ShowUsername, client);
	//PrintToChat(client, "%sTu esi arēnā ar %N (ARĒNA: %i)", PREFIX, client2, arena);
	
}

public Action ShowUsername(Handle timer, Handle pack)
{

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int client2 = ReadPackCell(pack);
	char username[128];
	GetClientName(client2, username, sizeof(username));
	hud_message(client, username);
}

