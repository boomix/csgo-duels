void Players_OnClientPutInServer(int client)
{
	//Player default settings
	b_WaitingForEnemy[client] 	= false;
	i_PlayerArena[client] 		= LOBBY;
	i_PlayerEnemy[client] 		= -1;
	
	//Timers
	KillSearchTimer(client);
	
	//Arena thing settings
	i_PrevArena[client] 		= -1;
	iTextEntity[client] 		= -1;
	
	//LogMessage("%N is connecting to server", client);

}

//**####################**
//~~~ PLAYER DISCONNECT ~~
//**####################**
void Players_OnClientDisconnect(int client)
{
	KillSearchTimer(client);
	
	//Check if player is playing and disconnects
	if(i_PlayerArena[client] != LOBBY)
	{
		//Kill damage timer, because already ingame
		KillDamageTimer(i_PlayerArena[client]);
	}
	
	//
	if(iTextEntity[client] && IsValidEntity(iTextEntity[client]) && iTextEntity[client] > 0)
		AcceptEntityInput(iTextEntity[client], "Kill");
		
	//Print chat message
	int opponent = i_PlayerEnemy[client];
	if(opponent > 0)
	{
		if(IsClientInGame(opponent) && IsInRightTeam(opponent) && i_PlayerEnemy[opponent] == client)
		{
			
			i_PrevEnemy[opponent] = -1;
			
			b_ArenaFree[i_PlayerArena[opponent]] = true;
			
			//Teleport to lobby, because enemy left
			TeleportToLobby(opponent, true, true);
		}
	}
}

//**####################**
//~~~ 	PLAYER DEATH 	~~
//**####################**
void Players_OnPlayerDeath(int client, int attacker)
{
	
	//Someone dies from world?!
	if(attacker == 0) {
		int opponent = i_PlayerEnemy[client];
		if(opponent > 0)
			if(IsClientInGame(opponent) && IsInRightTeam(opponent))
			{
				KillSearchTimer(opponent);
				SearchTmr[opponent] = CreateTimer(g_DuelDelayCvar.FloatValue, PlayerKilled, opponent, TIMER_FLAG_NO_MAPCHANGE);
			}
	}
	
	//Keep them arena for small amount of time, so they know they killed someone :D
	
	if(IsClientInGame(client))
		CreateTimer(0.6, PlayerGotKilled, client);
	
	if(attacker > 0)
		if(IsClientInGame(attacker) && IsInRightTeam(attacker))
		{
			KillSearchTimer(attacker);
			SearchTmr[attacker] = CreateTimer(g_DuelDelayCvar.FloatValue, PlayerKilled, attacker, TIMER_FLAG_NO_MAPCHANGE);
		}
}

//----------------------------
//Player who got killed timer
//----------------------------
public Action PlayerGotKilled(Handle tmr, any client)
{
	if(IsClientInGame(client) && IsInRightTeam(client))
		TeleportToLobby(client, true);
	
	return Plugin_Handled;
}

//------------------------------
//Player who killed other player
//------------------------------
public Action PlayerKilled(Handle tmr, any client)
{
	KillSearchTimer(client);
	
	if(IsClientInGame(client) && IsInRightTeam(client))
	{

		//Set his arena free
		if(i_PlayerArena[client] != LOBBY)
			b_ArenaFree[i_PlayerArena[client]] = true;
	
		//He wants to find opponent (someone from lobby)
		int opponent = FindOpponent(client);
		if(opponent > -1){
			
			//Setup match
			SetupMatch(client, opponent);
	
		} else {
			//No opponent found
			if(i_PlayerArena[client] != LOBBY)
				TeleportToLobby(client, true);
			
			//Make him search for enemy, if he can find one
			SearchTmr[client] = CreateTimer(1.0, PlayerKilled, client, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	
	return Plugin_Handled;
}

//**####################**
//~~~ STOCK FUNCTIONS ~~
//**####################**

void TeleportToLobby(int client, bool searchEnable, bool ImSearching = false)
{
	if(client > 0)
	{
		if(IsClientInGame(client) && IsInRightTeam(client))
		{
		
			//Set that enemys opponent to -1, because we went to lobby
			int opponent = i_PlayerEnemy[client];
			if(opponent > 0)
				if(IsClientInGame(opponent) && IsInRightTeam(opponent) && i_PlayerEnemy[opponent] == client)
					i_PlayerEnemy[opponent] = -1;
					
			
			//Check if player is dead, respawn
			if(!IsPlayerAlive(client))
				CS_RespawnPlayer(client);
			
			float org[3], ang[3];
			GetArenaSpawn(LOBBY, GetClientTeam(client), org, ang);
			TeleportEntity(client, org, ang, NULL_VECTOR);
			i_PlayerArena[client] 		= LOBBY;
			i_PlayerEnemy[client] 		= -1;
			
			//Make 
			SetEntData(client, g_offsCollisionGroup, 2, 4, true);
			
			if(searchEnable)
				b_WaitingForEnemy[client] = true;
			else
				b_WaitingForEnemy[client] = false;
				
			if(ImSearching && SearchTmr[client] == null)
			{
				KillSearchTimer(client);
				SearchTmr[client] = CreateTimer(0.1, PlayerKilled, client, TIMER_FLAG_NO_MAPCHANGE);
			}
				
		}
	}
}

int FindOpponent(int client)
{
	
	int enemy = iChallengeEnemy[client];
	if(enemy > 0)
	{
		if(i_PlayerArena[enemy] == LOBBY && !b_FirstWeaponSelect[enemy] && i_PlayerEnemy[enemy] == -1 && b_WaitingForEnemy[enemy])
		{
			b_WaitingForEnemy[client] 		= false;
			b_WaitingForEnemy[enemy] 		= false;
			i_PlayerEnemy[enemy] 			= client;
			i_PlayerEnemy[client] 			= enemy;
			return enemy;
		}
		else
			return -1;
	}
	
	int opponent = -1;

	//Check if there is any opponent avalibe without last one
	int AllPlayers2[MAXPLAYERS + 1], count2;
	LoopAllPlayers(i)
	{	
		//If the player fits requirements (Is in lobby, has selected weapons, has no opponent, and is waiting for one)
		if(i != client && i_PlayerArena[i] == LOBBY && !b_FirstWeaponSelect[i] && i_PlayerEnemy[i] == -1 && b_WaitingForEnemy[i] && i_PrevEnemy[client] != i)
			AllPlayers2[count2++] = i;
	}
	int opponent2 = (count2 == 0) ? -1 : AllPlayers2[GetRandomInt(0, count2 - 1)];
	
	if(opponent2 == -1)
	{
		
		//If there is no one avalible, try to generate with last enemy also
		int AllPlayers[MAXPLAYERS + 1], count;
		LoopAllPlayers(i)
		{	
			//If the player fits requirements (Is in lobby, has selected weapons, has no opponent, and is waiting for one)
			if(i != client && i_PlayerArena[i] == LOBBY && !b_FirstWeaponSelect[i] && i_PlayerEnemy[i] == -1 && b_WaitingForEnemy[i])
				AllPlayers[count++] = i;
		}
		
			
		//Get one random player from 'AllPlayers'
		opponent = (count == 0) ? -1 : AllPlayers[GetRandomInt(0, count - 1)];
	
	} else {
		
		opponent = opponent2;
	}
	
	//Lets check if that player is still avalible
	if(opponent > 0)
	{
		if(b_WaitingForEnemy[opponent] && i_PlayerEnemy[opponent] == -1 && i_PlayerArena[opponent] == LOBBY){
			
			//Set the player not avalible anymore
			b_WaitingForEnemy[client] 		= false;
			b_WaitingForEnemy[opponent] 	= false;
			i_PlayerEnemy[opponent] 		= client;
			i_PlayerEnemy[client] 			= opponent;
			
			return opponent;
		}
	}
	
	return -1;
}

void SetupMatch(int client, int enemy)
{
	//Check if both players are still ingame (because of timer bellow)
	if(IsClientInGame(client) && IsClientInGame(enemy) && IsInRightTeam(client) && IsInRightTeam(enemy))
	{
	
		//Generate free arena, if it didn't find any free arena, try again every 0.1 second
		int arena = GetFreeArena(i_PrevArena[client]);

		if(arena == -1)
		{
			DataPack pack;
			CreateDataTimer(0.1, TrySetupMatchAgain, pack);
			pack.WriteCell(client);
			pack.WriteCell(enemy);
			
			//debug
			int count = 0;
			for (int i = 1; i <= g_maxArenas; i++){
				if(b_ArenaFree[i] && i != LOBBY){
					count++;
				}
			}
			
		} else if(arena > 0) {
			
			//Stop search timers if one of them has one
			KillSearchTimer(client);
			KillSearchTimer(enemy);
			
			//Make the arena not free and set variables
			b_ArenaFree[arena] 		= false;
			i_PlayerArena[client] 	= arena;
			i_PlayerArena[enemy] 	= arena;
			i_PrevArena[client] 	= arena;
			i_PrevArena[enemy] 		= arena;
			i_PrevEnemy[client]	 	= enemy;
			i_PrevEnemy[enemy] 		= client;
			i_DamageGiven[client] 	= 0;
			i_DamageGiven[enemy] 	= 0;
			g_CustomRoundName[client] = "";
			g_CustomRoundName[enemy] = "";
			
			//Count how many custom duels are enabled
			int customDuels 	= 0;
			ArrayList customDuelsArray = new ArrayList();
			if(b_AwpDuelEnabled[client] && b_AwpDuelEnabled[enemy] && g_AWPDuelsCvar.IntValue == 1){
				customDuels++;
				customDuelsArray.PushString("awpDuel");
			}
			if(b_FlashbangDuelEnabled[client] && b_FlashbangDuelEnabled[enemy] && g_FlashbangDuelsCvar.IntValue == 1){
				customDuels++;
				customDuelsArray.PushString("FlashbangDuel");
			}
			
			//Make 50/50 to have custom round if both of them have enabled any
			if(customDuels != 0 && GetRandomInt(1, 100) <= g_CustomDuelChanceCvar.IntValue)
			{
				//Generate one of enabled duels
				int randomDuel = GetRandomInt(0, customDuelsArray.Length - 1);
				char randomNames[50];
				customDuelsArray.GetString(randomDuel, randomNames, sizeof(randomNames));
				//AWP duel setup
				if(StrEqual(randomNames, "awp")){
					g_CustomRoundName[client] = "AWP Duel";
					g_CustomRoundName[enemy] = "AWP Duel";
					SetupPlayer(client, enemy, arena, CS_TEAM_T, false);
					SetupPlayer(enemy, client, arena, CS_TEAM_CT, false);	
					GiveAWPDuelWeapons(client);
					GiveAWPDuelWeapons(enemy);
				}
				//Flashbang duel setup
				else if(StrEqual(randomNames, "Fla"))
				{
					g_CustomRoundName[client] = "Flashbang Duel";
					g_CustomRoundName[enemy] = "Flashbang Duel";
					SetupPlayer(client, enemy, arena, CS_TEAM_T);
					SetupPlayer(enemy, client, arena, CS_TEAM_CT);	
					GiveFlashbangs(client);
					GiveFlashbangs(enemy);
				}
				
				
			} else {
	
				//Setting up players
				SetupPlayer(client, enemy, arena, CS_TEAM_T);
				SetupPlayer(enemy, client, arena, CS_TEAM_CT);	
			
			}
			
			delete customDuelsArray;
			
			//Create new duel if there is no damage in 25 seconds
			ArenaDamageTmr[arena] = CreateTimer(g_NoDamageCvar.FloatValue, ArenaDamageTimer, arena, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public Action TrySetupMatchAgain(Handle timer, Handle pack)
{
	ResetPack(pack);
	int client = ReadPackCell(pack);	
	int enemy = ReadPackCell(pack);
	SetupMatch(client, enemy);
	
	return Plugin_Handled;
}

void KillSearchTimer(int client)
{
	if (SearchTmr[client] != null)
	{
		KillTimer(SearchTmr[client]);
		SearchTmr[client] = null;
	}
}

void KillDamageTimer(int arena)
{
	if (ArenaDamageTmr[arena] != null)
	{
		KillTimer(ArenaDamageTmr[arena]);
		ArenaDamageTmr[arena] = null;
	}
}

void SetupPlayer(int client, int opponent, int arena, int team, int giveWeapons = true)
{

	//Teleport to arena
	TeleportToArena(client, team, arena);
	
	//Remove his flash
	SetEntPropFloat(client, Prop_Send, "m_flFlashMaxAlpha", 0.0);
	
	//Give right weapons
	if(giveWeapons){
		GivePlayerHisWeapons(client);
		RemoveGrenade(client);	
	}
	
	//For safety reset health
	SetEntityHealth(client, 100);
	
	//Armor
	if(g_GiveArmorCvar.IntValue == 1)
		SetEntProp(client, Prop_Send, "m_ArmorValue", 100, 10);
	else
		SetEntProp(client, Prop_Send, "m_ArmorValue", 0, 10);
	
	//Helmet
	if(g_GiveHelmetCvar.IntValue == 1)
		SetEntProp(client, Prop_Send, "m_bHasHelmet", 1);
	else
		SetEntProp(client, Prop_Send, "m_bHasHelmet", 0);
	
	
	if(g_ShowUsernameCvar.IntValue == 1)
	{
		char username[500];
		GetClientName(opponent, username, sizeof(username));
		hud_message(client, username);
	}
}


void TeleportToArena(int client, int team, int arena)
{
	float org[3], ang[3], vec[3];
	GetArenaSpawn(arena, team, org, ang);
	TeleportEntity(client, org, ang, vec);
	SetEntData(client, g_offsCollisionGroup, 5, 4, true);
}

public Action ArenaDamageTimer(Handle timer, any arena)
{
	
	//Set timer to null
	ArenaDamageTmr[arena] = null;
	
	//Get both players who are playing in that arena
	int player = -1, player2 = -1;
	LoopAllPlayers(i) 
	{
		if(i_PlayerArena[i] == arena)
		{
			if(player == -1)
				player = i;
			else
				player2 = i;
		}
	}
	
	//One player teleport to lobby, one player searches for new enemy
	int random = GetRandomInt(1, 2);
	
	if(random == 1)
	{
		TeleportToLobby(player2, true);
		if(player > 0)
		{
			KillSearchTimer(player);
			SearchTmr[player] = CreateTimer(0.1, PlayerKilled, player, TIMER_FLAG_NO_MAPCHANGE);
		}
	} else {
		TeleportToLobby(player, true);
		if(player2 > 0)
		{
			KillSearchTimer(player);
			SearchTmr[player2] = CreateTimer(0.1, PlayerKilled, player2, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	
	return Plugin_Handled;
}

bool IsInRightTeam(int client)
{
	if(GetClientTeam(client) == CS_TEAM_CT || GetClientTeam(client) == CS_TEAM_T)
		return true;
	else
		return false;
}