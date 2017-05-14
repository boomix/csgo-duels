
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

stock Handle ExecuteAndSaveCvars(const char[] cfgFile) {
    char lineBuffer[CVAR_NAME_MAX_LENGTH + CVAR_VALUE_MAX_LENGTH];
    char nameBuffer[CVAR_NAME_MAX_LENGTH];

    char filePath[PLATFORM_MAX_PATH];
    Format(filePath, sizeof(filePath), "cfg/%s", cfgFile);

    File file = OpenFile(filePath, "r");
    if (file != null) {
        ArrayList nameList = new ArrayList(CVAR_NAME_MAX_LENGTH);

        while (!file.EndOfFile() && file.ReadLine(lineBuffer, sizeof(lineBuffer))) {
            if (__firstWord(lineBuffer, nameBuffer, sizeof(nameBuffer))) {
                TrimString(nameBuffer);
                nameList.PushString(nameBuffer);
            }
        }

        Handle ret = SaveCvars(nameList);
        ServerCommand("exec %s", cfgFile);
        delete nameList;
        delete file;
        return ret;
    } else {
        LogError("Failed to open file for reading: %s", filePath);
        return INVALID_HANDLE;
    }
}

// Returns the first "word" in a line, as seperated by whitespace.
stock bool __firstWord(const char[] line, char[] buffer, int len) {
    char[] lineBuffer = new char[strlen(line)];
    strcopy(lineBuffer, strlen(line), line);
    TrimString(lineBuffer);
    int splitIndex = StrContains(line, " ");
    if (splitIndex == -1)
        splitIndex = StrContains(line, "\t");

    if (splitIndex == -1) {
        Format(buffer,len,  "");
        return false;
    }

    int destLen = splitIndex + 1;
    if (destLen > len)
        destLen = len;

    strcopy(buffer, destLen, lineBuffer);
    return true;
}

// Returns a cvar Handle that can be used to restore cvars.
stock Handle SaveCvars(ArrayList cvarNames) {
    ArrayList storageList = CreateArray();
    ArrayList cvarNameList = new ArrayList(CVAR_NAME_MAX_LENGTH);
    ArrayList cvarValueList = new ArrayList(CVAR_VALUE_MAX_LENGTH);

    char nameBuffer[CVAR_NAME_MAX_LENGTH];
    char valueBuffer[CVAR_VALUE_MAX_LENGTH];
    for (int i = 0; cvarNames != null && i < cvarNames.Length; i++) {
        cvarNames.GetString(i, nameBuffer, sizeof(nameBuffer));

        Handle cvar = FindConVar(nameBuffer);
        if (cvar != INVALID_HANDLE) {
            GetConVarString(cvar, valueBuffer, sizeof(valueBuffer));
            cvarNameList.PushString(nameBuffer);
            cvarValueList.PushString(valueBuffer);
        }

    }

    storageList.Push(cvarNameList);
    storageList.Push(cvarValueList);
    return storageList;
}