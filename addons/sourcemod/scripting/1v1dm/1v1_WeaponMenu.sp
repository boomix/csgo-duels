void WeaponMenu_OnClientPutInServer(int client){
	b_FirstWeaponSelect[client] = true;
	g_PrimaryWeapon[client] = "";
	g_SecondaryWeapon[client] = "";
	b_HideMainWeaponMenu[client] = false;
}

void WeaponMenu_MapStart()
{
	if(g_Rifles == null)
	{
		g_Rifles = new ArrayList(40);
		g_Pistols = new ArrayList(40);
	}
	else
	{
		g_Rifles.Clear();
		g_Pistols.Clear();
	}
	
	//g_numPistols = 0;
	//g_numRifles = 0;

	char configFile[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, configFile, sizeof(configFile), "configs/1v1DM/weapons.cfg");


	//Check if file exists
	if (!FileExists(configFile)) {
		LogError("The weapon config file does not exist: %s", configFile);
		return;
	}
	
	//Go thru file
	KeyValues kv = new KeyValues("Weapons");
	kv.ImportFromFile(configFile);
	
	// Parse the rifles section
	if (!KvJumpToKey(kv, "Rifles")) {
		LogError("The weapon config file did not contain a \"Rifles\" section: %s", configFile);
		delete kv;
		return;
	}
	if (!kv.GotoFirstSubKey()) {
		LogError("No rifles were found.");
	}
	do {
		char weapon[50], name[50];
		kv.GetSectionName(weapon, sizeof(weapon));
		kv.GetString("name", name, sizeof(name));
		g_Rifles.PushString(weapon);
		g_Rifles.PushString(name);
		//PrintToServer("%s", name);
	} while (kv.GotoNextKey());
	kv.Rewind();


	// Parse the pistols section
	if (!KvJumpToKey(kv, "Pistols")) {
		LogError("The weapon config file did not contain a \"Pistols\" section: %s", configFile);
		delete kv;
		return;
	}

	if (!kv.GotoFirstSubKey()) {
		LogError("No pistols were found.");
	}
	do {
		char weapon[50], name[50];
		kv.GetSectionName(weapon, sizeof(weapon));
		kv.GetString("name", name, sizeof(name));
		PushArrayString(g_Pistols, weapon);
		PushArrayString(g_Pistols, name);
	} while (kv.GotoNextKey());

	delete kv;
	
	//PrintToServer("RIFLES: %i | PISTOLS: %i", g_Rifles.Length, g_Pistols.Length);

}

public Action CMD_Weapons(int client, int args)
{
	if(StrContains(g_PrimaryWeapon[client], "weapon_") == -1)
		ShowPrimaryWeaponMenu(client);
	else
		ShowMainMenu(client);
		
	return Plugin_Handled;
}

void ShowMainMenu(int client)
{
	SetGlobalTransTarget(client);
	Menu menu = new Menu(MenuHandlers_MainMenu);
	char Weapon_preferences[64];
	Format(Weapon_preferences,sizeof(Weapon_preferences),"%T","Weapon preferences",client);
	menu.SetTitle(Weapon_preferences);
	
	//Primary weapon
	char AddItemChar[50], WeaponName[50];
	
	if(g_EnableRiflesCvar.IntValue == 1)
	{
		int rifleID = g_Rifles.FindString(g_PrimaryWeapon[client]);
		g_Rifles.GetString(rifleID + 1, WeaponName, sizeof(WeaponName));
		Format(AddItemChar, 50, "%T","Rifle:",client,WeaponName);
		menu.AddItem("OpenRifleMenu", AddItemChar);
	}
	
	if(g_EnablePistolsCvar.IntValue == 1)
	{
		//Secondary weapon
		int pistolID = g_Pistols.FindString(g_SecondaryWeapon[client]);
		g_Pistols.GetString(pistolID + 1, WeaponName, sizeof(WeaponName));
		Format(AddItemChar, 50, "%T","Pistol:",client,WeaponName);
		menu.AddItem("OpenPistolMenu", AddItemChar);
	}
	
	//Kill sound
	if(b_ClientSoundEnabled[client])
		Format(AddItemChar, 50, "%T","Kill sound: On",client);
	else
		Format(AddItemChar, 50, "%T","Kill sound: Off",client);
	menu.AddItem("ChangeSound", AddItemChar);
	
	
	//Here will go natives?!
	//But for now manual AWP DUEL added
	//because Im too lazy to create natives
	
	if(g_AWPDuelsCvar.IntValue == 1)
	{
		if(b_AwpDuelEnabled[client])
			Format(AddItemChar, 50, "%T","AWP Duels: On",client);
		else
			Format(AddItemChar, 50, "%T","AWP Duels: Off",client);
		menu.AddItem("AWPDuel", AddItemChar);
	}
	
	if(g_FlashbangDuelsCvar.IntValue == 1)
	{
		if(b_FlashbangDuelEnabled[client])
			Format(AddItemChar, 50, "%T","Flashbang Duels: On",client);
		else
			Format(AddItemChar, 50, "%T","Flashbang Duels: Off",client);
		menu.AddItem("FlashbangDuel", AddItemChar);
	}
	
	//Display
	menu.ExitButton = true;
	menu.Display(client, 0);
	
}

public int MenuHandlers_MainMenu(Menu menu, MenuAction action, int client, int item) 
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if(IsClientInGame(client) && IsPlayerAlive(client)) 
			{
				
				char info[32];
				GetMenuItem(menu, item, info, sizeof(info));
				
				if(StrEqual(info, "OpenRifleMenu"))
					ShowPrimaryWeaponMenu(client);
				
				else if(StrEqual(info, "OpenPistolMenu"))
					ShowSecondaryWeaponMenu(client);
					
				else if(StrEqual(info, "ChangeSound"))
					ChangeClientSound(client);
					
				else if(StrEqual(info, "AWPDuel"))
					ChangeAWPDuel(client);
					
				else if(StrEqual(info, "FlashbangDuel"))
					ChangeFlashbangDuel(client);
			}
		}
		case MenuAction_End:
			delete menu;
	}
}

void ShowPrimaryWeaponMenu(int client)
{
	if(g_EnableRiflesCvar.IntValue == 1)
	{
		SetGlobalTransTarget(client);
		Menu menu = new Menu(MenuHandlers_PrimaryWeapon);
		char Primary_weapon[64];
		Format(Primary_weapon,sizeof(Primary_weapon),"%T","Primary weapon",client);
		menu.SetTitle(Primary_weapon);
		
		for (int i = 0; i < g_Rifles.Length; i+=2)
		{
			char weapon[60], weaponName[60];
			g_Rifles.GetString(i, weapon, sizeof(weapon));
			g_Rifles.GetString(i + 1, weaponName, sizeof(weaponName));
			menu.AddItem(weapon, weaponName);
		}
		
		if(b_FirstWeaponSelect[client])
			menu.ExitButton = false;
		else
			menu.ExitButton = true;
		menu.Display(client, 0);
	} else {
		ShowSecondaryWeaponMenu(client);
	}
}

void ShowSecondaryWeaponMenu(int client)
{
	if(g_EnablePistolsCvar.IntValue == 1)
	{
		Menu menu = new Menu(MenuHandlers_SecondaryWeapon);
		SetGlobalTransTarget(client);
		char Secondary_Weapon[64];
		Format(Secondary_Weapon,sizeof(Secondary_Weapon),"%T","Secondary Weapon",client);
		menu.SetTitle(Secondary_Weapon);
		
		for (int i = 0; i < g_Pistols.Length; i+=2)
		{
			char weapon[60], weaponName[60];
			g_Pistols.GetString(i, weapon, sizeof(weapon));
			g_Pistols.GetString(i + 1, weaponName, sizeof(weaponName));
			menu.AddItem(weapon, weaponName);
		}
	
		if(b_FirstWeaponSelect[client])
			menu.ExitButton = false;
		else
			menu.ExitButton = true;
			
		menu.Display(client, 0);
	}
}

public int MenuHandlers_PrimaryWeapon(Menu menu, MenuAction action, int client, int item) 
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if(IsClientInGame(client) && IsPlayerAlive(client)) 
			{
				
				char info[32];
				GetMenuItem(menu, item, info, sizeof(info));
				
				if(i_PlayerArena[client] == LOBBY)
				{
					int weapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
					if(weapon > 0 && IsValidEntity(weapon)) {
						RemovePlayerItem(client, weapon);
						RemoveEdict(weapon);
					}
					
					GivePlayerItem(client, info);
				}

				
				//Save clients weapon choice
				g_PrimaryWeapon[client] = info;
				SetClientCookie(client, g_Rifle, info);

				if(StrContains(g_SecondaryWeapon[client], "weapon_") == -1)
					ShowSecondaryWeaponMenu(client);
				else
					ShowMainMenu(client);

			}
		}
		case MenuAction_End:
			delete menu;
	}
}

public int MenuHandlers_SecondaryWeapon(Menu menu, MenuAction action, int client, int item) 
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if(IsClientInGame(client) && IsPlayerAlive(client)) 
			{
				
				char info[32];
				GetMenuItem(menu, item, info, sizeof(info));
				
				if(i_PlayerArena[client] == LOBBY)
				{
					int weapon = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
					if(weapon > 0 && IsValidEntity(weapon)) {
						RemovePlayerItem(client, weapon);
						RemoveEdict(weapon);
					}
					
					GivePlayerItem(client, info);
				}
				
				//Save clients weapon choice
				g_SecondaryWeapon[client] = info;
				SetClientCookie(client, g_Pistol, info);
				
				if(b_FirstWeaponSelect[client])
				{
					b_FirstWeaponSelect[client] = false;
				
					//Finished picking weapons
					b_WaitingForEnemy[client] = true;
					
					//Check if there is free enemy
					KillSearchTimer(client);
					SearchTmr[client] = CreateTimer(0.1, PlayerKilled, client, TIMER_FLAG_NO_MAPCHANGE);
					
				}
				
				if(!b_HideMainWeaponMenu[client])
					ShowMainMenu(client);
			}
		}
		case MenuAction_End:
			delete menu;
	}
}

void GivePlayerHisWeapons(int client)
{
	
	int weapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
	if(weapon > 0 && IsValidEntity(weapon)) {
		RemovePlayerItem(client, weapon);
		RemoveEdict(weapon);
	}
	if(!StrEqual(g_PrimaryWeapon[client], "") && g_EnableRiflesCvar.IntValue == 1)
		GivePlayerItem(client, g_PrimaryWeapon[client]);
		
	int weapon2 = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
	if(weapon2 > 0 && IsValidEntity(weapon2)) {
		RemovePlayerItem(client, weapon2);
		RemoveEdict(weapon2);
	}
	if(!StrEqual(g_SecondaryWeapon[client], "") && g_EnablePistolsCvar.IntValue == 1)
		GivePlayerItem(client, g_SecondaryWeapon[client]);
		
		
	int weapon3 = GetPlayerWeaponSlot(client, CS_SLOT_KNIFE);
	if(weapon3 > 0 && IsValidEntity(weapon3)) {
		RemovePlayerItem(client, weapon3);
		RemoveEdict(weapon3);
	}
	GivePlayerItem(client, "weapon_knife");
}
