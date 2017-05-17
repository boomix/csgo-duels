void ShowDamage_OnClientPutInServer(int client)
{
	i_DamageGiven[client] 		= 0;
}

void ShowDamage_OnPlayerDeath(int client, int attacker)
{
	if(g_DamageGivenCvar.IntValue == 1)
		PrintToChat(client, "%s %N killed you with %i hp left", PREFIX, attacker, 100 - i_DamageGiven[client]);
	
	//if(g_DamageReceivedCvar.IntValue == 1)
	//	PrintToChat(attacker, "%sDamage received from \x4%N\x1: %i", PREFIX, client, i_DamageGiven[client]);
}

void ShowDamage_PlayerHurt(int attacker, int damage)
{
	i_DamageGiven[attacker] += damage;
}