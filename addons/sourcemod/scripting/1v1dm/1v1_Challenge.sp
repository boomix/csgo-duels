void Challenge_OnClientPutInServer(int client)
{
	iChallengeEnemy[client] = -1;
	iChallengeInvite[client] = -1;
}

void Challenge_OnClientDisconnect(int client)
{
	
	int opponent = iChallengeEnemy[client];
	if(opponent > 0)
		if(IsClientInGame(opponent))
			if(iChallengeEnemy[opponent] == client)
				iChallengeEnemy[opponent] = -1;
				

	iChallengeEnemy[client] = -1;
	iChallengeInvite[client] = -1;
	
	
	//Split up duels if there are not enogh players
	int count = 0;
	LoopAllPlayers(i)
		count++;
	
	if(count < g_ChallengeMinPlayerCvar.IntValue)
	{
		LoopAllPlayers(i)
		{
			if(iChallengeEnemy[i] > 0)
			{
				PrintToChat(i, "%s%T", PREFIX, "Not enogh players to start challenge", i, g_ChallengeMinPlayerCvar.IntValue);
				CMD_Deny(i, 0);
			}			
		}
	}
	
}

//Challenge turned off
public int ChallengeChanged(Handle cvar, const char[] oldValue, const char[] newValue) {
	
	if(StringToInt(newValue) == 0)
		LoopAllPlayers(i)
			if(iChallengeEnemy[i] > 0)
				CMD_Deny(i, 0);	
	
}

public Action CMD_Challenge(int client, int args)
{
	
	if(g_ChallengeEnabled.IntValue == 0)
		return Plugin_Handled;
	
	int count = 0;
	LoopAllPlayers(i)
		count++;
	
	if(count < g_ChallengeMinPlayerCvar.IntValue)
	{
		PrintToChat(client, "%s%T", PREFIX, "Not enogh players to start challenge", client, g_ChallengeMinPlayerCvar.IntValue);
		return Plugin_Handled;
	}
	
	
	//Here will be checks if player is allowed to type that
	if(iChallengeEnemy[client] > 0)
	{
		PrintToChat(client, "%s%T", PREFIX, "Your already in challenge", client);
		return Plugin_Handled;
	}
	
	//Player entered wrong command
	if(args > 1)
	{
		
		PrintToChat(client, "%s!challenge [username]", PREFIX);
		return Plugin_Handled;
	
	
	//Player entered direct username	
	} else if(args == 1) {

		char user[MAX_NAME_LENGTH], target_name[MAX_TARGET_LENGTH];
		GetCmdArg(1, user, sizeof(user));
		int target_list[MAXPLAYERS], target_count;
		bool tn_is_ml;
		if ((target_count = ProcessTargetString(user, client, target_list, MAXPLAYERS, COMMAND_FILTER_CONNECTED, target_name, sizeof(target_name), tn_is_ml)) <= 0)
		{
			PrintToChat(client, "%s%T", PREFIX, "Player not found", client);
			return Plugin_Handled;
		}
		
		if(target_count > 1)
		{
			PrintToChat(client, "%s%T", PREFIX, "There are several players with this name", client);
			return Plugin_Handled;
		} else if(target_count == 1) {
			
			if(client == target_list[0])
			{
				PrintToChat(client, "%s%T", PREFIX, client, "You cant select yourself as enemy", client);
				return Plugin_Handled;
			}
			
			ChallengePlayer(client, target_list[0]);
			return Plugin_Handled;
		}
	
	
	//Player didn't enter username, lets show him menu with all users
	} else {
		
		SetGlobalTransTarget(client);
		Menu menu = new Menu(MenuHandlers_Challenge);
		char cMenuTitle[64];
		Format(cMenuTitle, sizeof(cMenuTitle), "%T", "Select opponent", client);
		menu.SetTitle(cMenuTitle);
		
		LoopAllPlayers(i)
		{
			if(iChallengeEnemy[i] == -1 && i != client)
			{
				char username[128], userID[10];
				GetClientName(i, username, sizeof(username));
				IntToString(GetClientUserId(i), userID, sizeof(userID));
				menu.AddItem(userID, username);	
			}
		}
		
		//Display
		menu.ExitButton = true;
		menu.Display(client, 20);
		
	}
	
	
	return Plugin_Handled;
}

public int MenuHandlers_Challenge(Menu menu, MenuAction action, int client, int item) 
{
	switch(action)
	{
		case MenuAction_Select:
		{
			
			char ctarget[5];
			GetMenuItem(menu, item, ctarget, sizeof(ctarget));
			int target = GetClientOfUserId(StringToInt(ctarget));
			
			if(IsClientInGame(target))
				ChallengePlayer(client, target);
			
		}
		
		case MenuAction_End:
			delete menu;
	}
}



void ChallengePlayer(int client, int target)
{
	if(g_ChallengeEnabled.IntValue == 0)
		return;
	
	iChallengeEnemy[client] = -1;
	
	if(!IsClientInGame(target))
	{
		PrintToChat(client, "%s%T", PREFIX, "Enemy left the game", client);
		return;
	}
	
	if(iChallengeEnemy[target] != -1)
	{
		PrintToChat(client, "%s%T", PREFIX, "Opponent in challenge", client);
		return;
	}
	
	iChallengeInvite[client] 	= target;
	iChallengeInvite[target]	= client;
	KillInviteTimer(client);
	ChallengeTmrInvite[client] 	= CreateTimer(20.0, RemoveInvite, GetClientUserId(client));
	
	char username[MAX_NAME_LENGTH], username2[MAX_NAME_LENGTH];
	GetClientName(client, username, sizeof(username));
	GetClientName(target, username2, sizeof(username2));
	PrintToChat(client, "%s%T", PREFIX, "Challenge is sent", client, username2);
	PrintToChat(target, " ");
	PrintToChat(target, "%s%T", PREFIX, "Player invited you to challeng", target, username);
	PrintToChat(target, " ");
	
}

void KillInviteTimer(int client)
{
	if (ChallengeTmrInvite[client] != null)
	{
		KillTimer(ChallengeTmrInvite[client]);
		ChallengeTmrInvite[client] = null;
	}
}

public Action RemoveInvite(Handle tmr, any userID)
{
	int client = GetClientOfUserId(userID);
	if(client > 0)
	{
		ChallengeTmrInvite[client] = null;
		if(IsClientInGame(client))
		{
			int opponent = iChallengeInvite[client];
			if(iChallengeEnemy[opponent] != client)
			{
				iChallengeInvite[client] = -1;
				PrintToChat(client, "%s%T", PREFIX, "Invite expired", client);
				PrintToChat(opponent, "%s%T", PREFIX, "Invite expired", opponent);
			}			
		}
	}
		
}



public Action CMD_Accept(int client, int args)
{
	if(iChallengeInvite[client] == -1)
	{
		PrintToChat(client, "%s%T", PREFIX, "No invites", client);
		return Plugin_Handled;
	}
	
	int opponent = iChallengeInvite[client];
	
	if(iChallengeInvite[opponent] != client)
	{
		PrintToChat(client, "%s%T", PREFIX, "Invite expired", client);
		return Plugin_Handled;
	}
	
	KillInviteTimer(opponent);
	iChallengeInvite[client] 	= -1;
	iChallengeInvite[opponent]	= -1;
	iChallengeEnemy[opponent] 	= client;
	iChallengeEnemy[client] 	= opponent;
	
	PrintToChat(client, "%sYou accepted invite!", PREFIX, client);
	PrintToChat(opponent, "%sYour invite is accepted!", PREFIX, opponent);
	
	return Plugin_Handled;	
}

public Action CMD_Deny(int client, int args)
{
	
	if(iChallengeEnemy[client] != -1)
	{
		int opponent = iChallengeEnemy[client];
		PrintToChat(client, "%s%T", PREFIX, "You left challenge", client);
		
		if(opponent > 0)
		{
			if(IsClientInGame(opponent))
			{
				char username[MAX_NAME_LENGTH];
				GetClientName(client, username, sizeof(username));
				PrintToChat(opponent, "%s%T", PREFIX, "Opponent left the challenge", opponent, username);
				iChallengeEnemy[opponent] 	= -1;
				iChallengeInvite[opponent] 	= -1;
			}
		}
		
		iChallengeEnemy[client] = -1;
		iChallengeInvite[client] = -1;
	}
	
	return Plugin_Handled;	
}
