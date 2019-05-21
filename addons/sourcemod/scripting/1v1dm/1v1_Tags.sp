void Tags_OnClientPutInServer(int client)
{
	wins[client] = 0;
	UpdateTag(client);
}

void Tags_OnPlayerDeath(int victim, int killer)
{
	wins[killer] += 1;
	wins[victim] = ((wins[victim] - 1 < 0) ? 0 : wins[victim] - 1);
	//CS_SetClientContributionScore(victim, wins[victim]);
	//CS_SetClientContributionScore(killer, wins[killer]);
	UpdateTag(victim);
	UpdateTag(killer);
}


void Tags_OnPlayerSpawn(int client)
{
	UpdateTag(client);
}

void UpdateTag(int client)
{
	int i;
	int list_players[MAXPLAYERS+1];
	int player_count;
	
	for(i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsClientSourceTV(i))
		{
	    	list_players[player_count] = i;
	    	player_count++;
		}
	}

	SortCustom1D(list_players, player_count, sortfunc);
	
	int place = 0;
	for(i = 0; i < player_count; i++)
    {
    	if(list_players[i] == client)
    		place = i + 1;
    }

	
	//Set client tag
	char tag[50];
	Format(tag, sizeof(tag), "[%i - %i wins]", place, wins[client]);
	CS_SetClientClanTag(client, tag);
}

public int sortfunc(int elem1, int elem2, const int[] array, Handle hndl)
{
	if(wins[elem1] > wins[elem2]) {
		return -1;
	}
	else if(wins[elem1] < wins[elem2]) {
		return 1;
	}
	return 0;
}  