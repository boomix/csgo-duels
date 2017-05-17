void KillSound_OnPlayerDeath(int killer)
{
	if(killer > 0)
		if(IsClientInGame(killer) && !IsFakeClient(killer) && IsPlayerAlive(killer) && b_ClientSoundEnabled[killer])
			ClientCommand(killer, "play */buttons/bell1.wav");
}

void ChangeClientSound(int client){
	
	if(b_ClientSoundEnabled[client])
	{
		b_ClientSoundEnabled[client] = false;
		SetClientCookie(client, g_SoundEnabled, "0");
	} else {
		b_ClientSoundEnabled[client] = true;
		SetClientCookie(client, g_SoundEnabled, "1");
	}

	ShowMainMenu(client);
}
