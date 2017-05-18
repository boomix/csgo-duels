
void Cvars_OnConfigsExecuted()
{
	//Execute all game cvars
	ExecuteAndSaveCvars("sourcemod/1v1DM/game_cvars.cfg");
	SetCvar("mp_ignore_round_win_conditions", "0");
}

void Cvars_MapStart()
{
	//Update cvars
	//SetCvar("mp_restartgame", 						"1");
	SetCvar("mp_teammates_are_enemies", 			"1");
	SetCvar("mp_display_kill_assists", 				"0");
	SetCvar("sv_delta_entity_full_buffer_size", 	"262144");
	SetCvar("mp_solid_teammates", 					"1"); 
	SetCvar("sv_teamid_overhead_always_prohibit",	"1"); 
	SetCvar("sv_show_team_equipment_prohibit",		"1");
	SetCvar("sv_infinite_ammo",						"0");
	SetCvar("mp_autoteambalance",					"0"); 
}

void SetCvar(char[] scvar, char[] svalue)
{
	Handle cvar = FindConVar(scvar);
	SetConVarString(cvar, svalue, true);
}

//******
//FUNCTIONS FROM MULTI 1V1 ARENA (thanks splewis)
//******

stock Handle ExecuteAndSaveCvars(const char[] cfgFile)
{
    char filePath[PLATFORM_MAX_PATH];
    Format(filePath, sizeof(filePath), "cfg/%s", cfgFile);

    File file = OpenFile(filePath, "r");
    if (file != null) {
        ServerCommand("exec %s", cfgFile);
        delete file;
    } else {
        LogError("Failed to open file for reading: %s", filePath);
    }
}