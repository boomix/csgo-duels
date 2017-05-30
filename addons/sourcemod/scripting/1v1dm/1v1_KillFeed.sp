void KillFeed_PlayerDeath(int victim, int attacker, char sWeapon[128], bool headshot = false, int penetrated)
{
	if(g_ShowKillFeedCvar.IntValue == 0)
	{
		bool IsValidV = IsValidClient(victim);
		bool IsValidK = IsValidClient(attacker);
		
		int mVictim = IsValidV ? GetClientUserId(victim) : 0;
		int mKiller = IsValidK ? GetClientUserId(attacker) : 0;
		
		Event event = CreateEvent("player_death");
		
		event.SetInt("userid", mVictim);
		event.SetInt("attacker", mKiller);
		event.SetString("weapon", sWeapon);
		event.SetBool("headshot", headshot);
		event.SetInt("penetrated", penetrated);
		   
		if ( IsValidV )
		   event.FireToClient(victim);
		if(IsValidK && victim != attacker)
		   event.FireToClient(attacker);

		event.Cancel();
		
	}
}

bool IsValidClient(int client)
{
    if(client <= 0 || client > MaxClients)
        return false;
       
    if(!IsClientInGame(client) || !IsClientConnected(client) || IsFakeClient(client))
        return false;
       
    return true;
}
