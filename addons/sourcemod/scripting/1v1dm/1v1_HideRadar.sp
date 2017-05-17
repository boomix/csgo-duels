void HideRadar_OnPlayerSpawn(int client)
{
	CreateTimer(0.0, RemoveRadar, client);
}

public Action RemoveRadar(Handle timer, any client) 
{
	if(client > 0)
		if(IsClientInGame(client) && !IsFakeClient(client))
			SetEntProp(client, Prop_Send, "m_iHideHUD", GetEntProp(client, Prop_Send, "m_iHideHUD") | 1<<12);
	
	return Plugin_Handled;
}