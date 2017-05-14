void ChangeFlashbangDuel(int client)
{
	
	if(b_FlashbangDuelEnabled[client])
	{
		b_FlashbangDuelEnabled[client] = false;
		SetClientCookie(client, g_FlashbangDuel, "0");
	} else {
		b_FlashbangDuelEnabled[client] = true;
		SetClientCookie(client, g_FlashbangDuel, "1");
	}

	ShowMainMenu(client);
	
}

void GiveFlashbangs(int client)
{
	RemoveGrenade(client);
	GivePlayerItem(client, "weapon_flashbang");
}

void RemoveGrenade(int client)
{
	int weapon = GetPlayerWeaponSlot(client, CS_SLOT_GRENADE);
	if(weapon > 0 && IsValidEntity(weapon)) {
		RemovePlayerItem(client, weapon);
		AcceptEntityInput(weapon, "Kill");	
	}
}