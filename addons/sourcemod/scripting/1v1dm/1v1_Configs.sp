void Configs_OnPluginStartFunc()
{
	g_DamageGivenCvar 		= CreateConVar("sm_print_damage_given", 	"1", 							"Print in chat how much damage is given to enemy", 0, true, 0.0, true, 1.0);
	g_ShowUsernameCvar 		= CreateConVar("sm_show_username", 			"1", 							"Show username in left top corner", 0, true, 0.0, true, 1.0);
	g_PrefixCvar 			= CreateConVar("sm_prefix", 				"{GREEN}[DUELS]{WHITE} ", 		"Prefix for the chat");
	g_EnableRiflesCvar 		= CreateConVar("sm_enable_rifles", 			"1", 							"Allow to pick rifles from guns menu (for pistols only servers set 0)", 0, true, 0.0, true, 1.0);
	g_EnablePistolsCvar 	= CreateConVar("sm_enable_pistols", 		"1", 							"Allow to pick pistols from guns menu (for rifles only servers set 0)", 0, true, 0.0, true, 1.0);
	g_GiveArmorCvar 		= CreateConVar("sm_give_armor", 			"1", 							"Give armor to player when new duel starts", 0, true, 0.0, true, 1.0);
	g_GiveHelmetCvar 		= CreateConVar("sm_give_helmet", 			"1", 							"Give helmet to player when new duel starts", 0, true, 0.0, true, 1.0);
	g_WeaponMenuJoinCvar 	= CreateConVar("sm_weapon_menu_on_join",	"0", 							"Open weapon menu (default menu) when player joins the server", 0, true, 0.0, true, 1.0);
	g_AWPDuelsCvar 			= CreateConVar("sm_enable_awp_duels",		"1", 							"Enable AWP duels option", 0, true, 0.0, true, 1.0);
	g_DuelDelayCvar 		= CreateConVar("sm_duel_delay",				"1.4", 							"How long it will wait to find a new enemy (longer time means winner will stay longer in arena after duel win, but there will be bigger possibility to get different opponent)", 0, true, 0.3, true, 5.0);
	g_NoDamageCvar 			= CreateConVar("sm_nodamage_new_enemy", 	"25.0", 						"How long it will take when there is no damage in duel, to find a new duel for both enemies", 0, true, 0.0, true, 60.0);
	g_ShowKillFeedCvar 		= CreateConVar("sm_all_player_killfeed", 	"0", 							"0 will show ony killfeed in top right corner of your own kills, 1 will show all kills", 0, true, 0.0, true, 1.0);
	g_FlashbangDuelsCvar	= CreateConVar("sm_flashbangduel_enabled", 	"1", 							"Enable flashbang duel", 0, true, 0.0, true, 1.0);
	g_CustomDuelChanceCvar	= CreateConVar("sm_custom_duel_chance", 	"50", 							"Percentage of possibility to get a custom duel", 0, true, 0.0, true, 100.0);
	
	//killfeed
	
	AutoExecConfig(true, "1v1DM", "sourcemod/1v1DM");
	
	HookConVarChange(g_PrefixCvar, PrefixChanged);
	
	FixPrefix();
}

public int PrefixChanged(Handle cvar, const char[] oldValue, const char[] newValue) {
	FixPrefix();	
}

public void FixPrefix()
{

	g_PrefixCvar.GetString(PREFIX, sizeof(PREFIX));

	char ColorPre[150] = "\x1 ";
	ReplaceString(PREFIX, sizeof(PREFIX), "{WHITE}", "\x01");
	ReplaceString(PREFIX, sizeof(PREFIX), "{RED}", 	"\x02");
	ReplaceString(PREFIX, sizeof(PREFIX), "{TEAM}", "\x03");
	ReplaceString(PREFIX, sizeof(PREFIX), "{GREEN}", "\x04");
	ReplaceString(PREFIX, sizeof(PREFIX), "{LIME}", "\x05");
	ReplaceString(PREFIX, sizeof(PREFIX), "{LIGHTGREEN}", "\x06");
	ReplaceString(PREFIX, sizeof(PREFIX), "{LIGHTRED}", "\x07");
	ReplaceString(PREFIX, sizeof(PREFIX), "{GRAY}", "\x08");
	ReplaceString(PREFIX, sizeof(PREFIX), "{LIGHTOLIVE}", "\x09");
	ReplaceString(PREFIX, sizeof(PREFIX), "{OLIVE}", "\x10");
	ReplaceString(PREFIX, sizeof(PREFIX), "{PURPLE}", "\x0E");
	ReplaceString(PREFIX, sizeof(PREFIX), "{LIGHTBLUE}", "\x0B");
	ReplaceString(PREFIX, sizeof(PREFIX), "{BLUE}", "\x0C");
	
	StrCat(ColorPre, sizeof(ColorPre), PREFIX);
	
	PREFIX = ColorPre;
}