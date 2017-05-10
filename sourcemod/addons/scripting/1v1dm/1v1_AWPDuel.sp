void ChangeAWPDuel(int client)
{
	
	if(b_AwpDuelEnabled[client])
	{
		b_AwpDuelEnabled[client] = false;
		SetClientCookie(client, g_AWPDuel, "0");
	} else {
		b_AwpDuelEnabled[client] = true;
		SetClientCookie(client, g_AWPDuel, "1");
	}

	ShowMainMenu(client);
	
}

void GiveAWPDuelWeapons(int client)
{
	
	RemoveGrenade(client);
	
	int weapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
	if(weapon > 0 && IsValidEntity(weapon)) {
		RemovePlayerItem(client, weapon);
		RemoveEdict(weapon);
	}
	GivePlayerItem(client, "weapon_awp");
	
	int weapon2 = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
	if(weapon2 > 0 && IsValidEntity(weapon2)) {
		RemovePlayerItem(client, weapon2);
		RemoveEdict(weapon2);
	}
	
	int weapon3 = GetPlayerWeaponSlot(client, CS_SLOT_KNIFE);
	if(weapon3 > 0 && IsValidEntity(weapon3)) {
		RemovePlayerItem(client, weapon3);
		RemoveEdict(weapon3);
	}
	GivePlayerItem(client, "weapon_knife");
}