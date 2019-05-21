
void Cvars_OnConfigsExecuted()
{
	//Execute all game cvars
	ExecuteAndSaveCvars("sourcemod/1v1DM/game_cvars.cfg");
}

void SetCvar(char[] scvar, char[] svalue)
{
	Handle cvar = FindConVar(scvar);
	SetConVarString(cvar, svalue, true, false);
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
	
	//Set round time as timelimit
	g_Timelimit = FindCvarAndLogError("mp_timelimit");
	GameRules_SetProp("m_iRoundTime", g_Timelimit.IntValue * 60, 4, 0, true);

}