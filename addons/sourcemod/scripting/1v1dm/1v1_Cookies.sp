void Cookies_OnPluginStart()
{
	g_SoundEnabled 			= RegClientCookie("1v1dm_soundEnabled", "1v1DM if kill sound is enabled", 	CookieAccess_Protected);
	g_Rifle					= RegClientCookie("1v1dm_rifle", 		"1v1DM primary weapon (rifle)", 	CookieAccess_Protected);
	g_Pistol				= RegClientCookie("1v1dm_pistol", 		"1v1DM secondary weapon (pistol)", 	CookieAccess_Protected);
	g_AWPDuel				= RegClientCookie("1v1dm_awpDuel", 		"1v1DM if awp duel enabled", 		CookieAccess_Protected);
	g_FlashbangDuel			= RegClientCookie("1v1dm_flashbangDuel","1v1DM if flashbang duel enabled", 	CookieAccess_Protected);
}

void Cookies_OnClientPutInServer(int client)
{
	b_ClientSoundEnabled[client] 	= true;
	b_AwpDuelEnabled[client] 		= false;
	b_FlashbangDuelEnabled[client] 	= false;
}

void Cookies_OnPlayerTeam(int client)
{
	//Load all cookies
	if(AreClientCookiesCached(client))
	{
		char sCookieVal[50];
		
		//Kill sound cookie
		GetClientCookie(client, g_SoundEnabled, sCookieVal, sizeof(sCookieVal));
		int cookieVal= StringToInt(sCookieVal);
		b_ClientSoundEnabled[client] 	= (cookieVal == 0) ? false : true;
		
		//Rifle cookie
		GetClientCookie(client, g_Rifle, sCookieVal, sizeof(sCookieVal));
		if(!StrEqual(sCookieVal, ""))
			g_PrimaryWeapon[client] 	= sCookieVal;
			
		//Pistol cookie
		GetClientCookie(client, g_Pistol, sCookieVal, sizeof(sCookieVal));
		if(!StrEqual(sCookieVal, ""))
			g_SecondaryWeapon[client] 	= sCookieVal;
			
		//AWP duel cookie
		GetClientCookie(client, g_AWPDuel, sCookieVal, sizeof(sCookieVal));
		cookieVal 						= StringToInt(sCookieVal);
		b_AwpDuelEnabled[client] 		= (cookieVal == 1) ? true : false;
		
		//Flashbang duel cookie
		GetClientCookie(client, g_FlashbangDuel, sCookieVal, sizeof(sCookieVal));
		cookieVal 						= StringToInt(sCookieVal);
		b_FlashbangDuelEnabled[client] 	= (cookieVal == 1) ? true : false;		
	}
}