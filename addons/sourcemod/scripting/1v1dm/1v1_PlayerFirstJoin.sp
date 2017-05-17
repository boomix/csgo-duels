void PlayerFirstJoin_OnClientPutInServer(int client)
{
	b_FirstTeamJoin[client] = true;
}

void PlayersFirstJoin_OnPlayerTeam(int client, int team)
{
	if(team != CS_TEAM_SPECTATOR)
	{
		if(b_FirstTeamJoin[client])
		{
			//Spawntools are weird, we want to force player to be in lobby
			float org[3], ang[3];
			GetArenaSpawn(LOBBY, GetClientTeam(client), org, ang);
			TeleportEntity(client, org, ang, NULL_VECTOR);
			CreateTimer(0.1, Telepors, client, TIMER_FLAG_NO_MAPCHANGE);
			
			CreateTimer(0.5, FirstJoin, client, TIMER_FLAG_NO_MAPCHANGE);
			b_FirstTeamJoin[client] = false;
		}	
	}
}

public Action Telepors(Handle tmr, any client)
{
	if(IsClientInGame(client) && IsInRightTeam(client))
	{
		float org[3], ang[3];
		GetArenaSpawn(LOBBY, GetClientTeam(client), org, ang);
		TeleportEntity(client, org, ang, NULL_VECTOR);
	}
	
	return Plugin_Handled;
}

public Action FirstJoin(Handle tmr, any client)
{
	if(client > 0)
	{
		if(IsClientInGame(client) && IsInRightTeam(client))
		{
			
			//LogMessage("%N first joined team", client);
			
			//Respawn player if he is dead
			if(!IsPlayerAlive(client))
				CS_RespawnPlayer(client);
			
			//Teleport to lobby
			TeleportToLobby(client, false);
			
			//Show weapon menu
			if(StrContains(g_PrimaryWeapon[client], "weapon_") == -1)
			{
				ShowPrimaryWeaponMenu(client);
				
			} else {
				
				b_FirstWeaponSelect[client] = false;
				
				//If server wants to show menu when client joins the game
				if(g_WeaponMenuJoinCvar.IntValue == 1)
					ShowMainMenu(client);
				
				//Finished picking weapons
				b_WaitingForEnemy[client] = true;
					
				//Check if there is free enemy
				KillSearchTimer(client);
				SearchTmr[client] = CreateTimer(0.1, PlayerKilled, client, TIMER_FLAG_NO_MAPCHANGE);
				
				//LogMessage("%N started search timer from the join", client);
			}	
		}
	}
	
	return Plugin_Handled;
}
