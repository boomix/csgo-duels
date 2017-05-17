#define CHECK_ARENA(%1) if (%1 <= 0 || %1 > g_maxArenas) PrintToServer("Arena %d is not valid", %1)

void Spawns_MapStart()
{
	
	CreateTimer(1.0, IfCustomSpawnsAreAdded);
	//There is 'spawntools7', what creates the spawns bit later
	
}

void ResetArenasArray()
{
	for (int i = 0; i < 64; i++)
	{
		iArenaArrayID[i] = -1;
	}
}

public Action IfCustomSpawnsAreAdded(Handle tmr, any client)
{
	if(g_TSpawnsList == null)
	{
		g_TSpawnsList = new ArrayList();
		g_TAnglesList = new ArrayList();
		g_CTSpawnsList = new ArrayList();
		g_CTAnglesList = new ArrayList();
	}
	else
	{
		g_TSpawnsList.Clear();
		g_TAnglesList.Clear();
		g_CTSpawnsList.Clear();
		g_CTAnglesList.Clear();
	}
	
	AddTeamSpawns("info_player_terrorist", g_TSpawnsList, g_TAnglesList);
	AddTeamSpawns("info_player_counterterrorist", g_CTSpawnsList, g_CTAnglesList);
    
	int ct = GetArraySize(g_CTSpawnsList);
	int t = GetArraySize(g_TSpawnsList);
	g_maxArenas = (ct < t) ? ct : t;
	
	int lobbyID = -1;
	for (int i = 1; i <= g_maxArenas; i++)
	{
		b_ArenaFree[i] = true;
		
		//Get lobby arena (the one that is nearest to y0 and x0)
		float org[3], ang[3], org2[3], ang2[3];
		float mid[3];
		mid[0] = 0.0;
		mid[1] = 0.0;
		mid[2] = 0.0;
		
		if(lobbyID == -1){
			lobbyID = i;	
		} else {
			
			//Get both spawnpoint coors
			GetArenaSpawn(lobbyID, CS_TEAM_CT, org, ang);
			GetArenaSpawn(i, CS_TEAM_CT, org2, ang2);
			
			float distanceLobby = GetVectorDistance(mid, org, true);
			float distanceNew = GetVectorDistance(mid, org2, true);
			
			//PrintToServer("%f un %f", distanceLobby, distanceNew);
			
			if(distanceNew < distanceLobby)
				lobbyID = i;
			
		}
	}
	
	LOBBY = lobbyID;
	
	return Plugin_Handled;
}

int GetFreeArena(int prevOne = -1)
{
	ArrayList AllArenas = new ArrayList(g_maxArenas);
	
	for (int i = 1; i <= g_maxArenas; i++){
		if(b_ArenaFree[i] && i != LOBBY && i != prevOne){
			char arenaID[3];
			IntToString(i, arenaID, sizeof(arenaID));
			PushArrayString(AllArenas, arenaID);
		}
	}
	
	if(AllArenas.Length <= 0)
	{
		for (int i = 1; i <= g_maxArenas; i++){
			if(b_ArenaFree[i] && i != LOBBY){
				char arenaID[3];
				IntToString(i, arenaID, sizeof(arenaID));
				PushArrayString(AllArenas, arenaID);
			}
		}
	}
	
	if(AllArenas.Length > 0)
	{
		int random = GetRandomInt(0, AllArenas.Length - 1);
	
		char arenaID2[3];
		AllArenas.GetString(random, arenaID2, sizeof(arenaID2));
		
		int retArena = StringToInt(arenaID2);
		if(retArena > 0 && retArena < g_maxArenas + 1)
		{
			delete AllArenas;
			return retArena;
		}
	}
	
	delete AllArenas;
	
	return -1;
		
}

//Function from multi1v1
static void AddTeamSpawns(const char[] className, ArrayList spawnList, ArrayList angleList) {
	
    ResetArenasArray();
    
    float spawn[3];
    float angle[3];
	
    int ent = -1;
    while ((ent = FindEntityByClassname(ent, className)) != -1) {

    	GetEntPropVector(ent, Prop_Data, "m_vecOrigin", 	spawn);
        GetEntPropVector(ent, Prop_Data, "m_angRotation", 	angle);
    	
    	char spawnName[100];
        GetEntPropString(ent, Prop_Data, "m_iName", spawnName, sizeof(spawnName));
        if(StrContains(spawnName, "arena") != -1 || StrContains(spawnName, "spawnroom") != -1 ){
        	
        	int currentArenaID;
        	
        	if(StrContains(spawnName, "spawnroom") != -1)
        	{
        		
        		currentArenaID = 0;
        		
       		} else {
        	
				char brake[4][40];
				ExplodeString(spawnName, ".", brake, sizeof(brake), sizeof(brake[]));
				currentArenaID = StringToInt(brake[1]);
            
           	}

       		for (int i = 0; i < 64; i++)
       		{
       			if(currentArenaID + 1 > GetArraySize(spawnList))
       			{
       				ArrayList spawns = new ArrayList(3);
			    	ArrayList angles = new ArrayList(3);
			    	iArenaArrayID[currentArenaID] = PushArrayCell(spawnList, spawns);
			    	PushArrayCell(angleList, angles);
       			} else {
       				iArenaArrayID[currentArenaID] = currentArenaID;
       			}
       		}
			
       		ArrayList spawns = view_as<ArrayList>(spawnList.Get(currentArenaID));
       		ArrayList angles = view_as<ArrayList>(angleList.Get(currentArenaID));
       		spawns.PushArray(spawn);
       		angles.PushArray(angle);

       		
       		//There already is array with that arena
       		/*if(iArenaArrayID[currentArenaID] != -1){
				
        		ArrayList spawns = view_as<ArrayList>(spawnList.Get(iArenaArrayID[currentArenaID]));
       			ArrayList angles = view_as<ArrayList>(angleList.Get(iArenaArrayID[currentArenaID]));
       			spawns.PushArray(spawn);
                angles.PushArray(angle);
               // PrintToServer("%i added to array %i", currentArenaID, iArenaArrayID[currentArenaID]);
                
			} else {
			
				//Create new array
       			ArrayList spawns = new ArrayList(3);
			    ArrayList angles = new ArrayList(3);
			    spawns.PushArray(spawn);
			    angles.PushArray(angle);
			    iArenaArrayID[currentArenaID] = PushArrayCell(spawnList, spawns);
			    //PrintToServer("arena %i created array %i", currentArenaID, iArenaArrayID[currentArenaID]);
			    PushArrayCell(angleList, angles);			
				
			}*/
       		
       		/*if(currentArenaID == LastArenaID)
       		{
       			//Put in last array
        		ArrayList spawns = view_as<ArrayList>(spawnList.Get(GetArraySize(spawnList) - 1));
       			ArrayList angles = view_as<ArrayList>(angleList.Get(GetArraySize(spawnList) - 1));
       			spawns.PushArray(spawn);
                angles.PushArray(angle);
       			
       		} else {
       			
       			//Check if array doesnt exist already
       			if(currentArenaID <= GetArraySize(spawnList))
       			{
       				//Put in last array
        			ArrayList spawns = view_as<ArrayList>(spawnList.Get(currentArenaID - 1));
       				ArrayList angles = view_as<ArrayList>(angleList.Get(currentArenaID - 1));
       				spawns.PushArray(spawn);
                	angles.PushArray(angle);
       				
       			} else {
       			
	       			//Create new array
	       			ArrayList spawns = new ArrayList(3);
				    ArrayList angles = new ArrayList(3);
				    spawns.PushArray(spawn);
				    angles.PushArray(angle);
				    PushArrayCell(spawnList, spawns);
				    PushArrayCell(angleList, angles);
			    
			   	}
       		}*/
       		
       		//LastArenaID = currentArenaID;
       		
       		//PrintToServer("NAME: %s | %i | array: %i", spawnName, currentArenaID, iArenaArrayID[currentArenaID]);

      	} else {
    		
        	AddSpawn(spawn, angle, spawnList, angleList);
        
       	}
    }
    
    //int ent2 = -1;
    //while ((ent2 = FindEntityByClassname(ent2, className)) != -1) {
    //	BoomEoFix(ent2);
    //}
    
}


static void AddSpawn(float spawn[3], float angle[3], ArrayList spawnList, ArrayList angleList) {
    // First scan for a nearby arena to place this spawn into.
    // If one is found - these spawn is pushed onto that arena's list.
    for (int i = 0; i < GetArraySize(spawnList); i++) {
        ArrayList spawns = view_as<ArrayList>(spawnList.Get(i));
        ArrayList angles = view_as<ArrayList>(angleList.Get(i));
        
        //Find closest arena in distance
        int closestIndex = NearestNeighborIndex(spawn, spawns);

        if (closestIndex >= 0) {
            float closestSpawn[3];
            spawns.GetArray(closestIndex, closestSpawn);
            float dist = GetVectorDistance(spawn, closestSpawn);

            if (dist < 1600.0) {
                spawns.PushArray(spawn);
                angles.PushArray(angle);
                return;
            }
        }
    }

    // If no nearby arena was found - create a new list for this newly found arena and push it.
    ArrayList spawns = new ArrayList(3);
    ArrayList angles = new ArrayList(3);
    spawns.PushArray(spawn);
    angles.PushArray(angle);
    PushArrayCell(spawnList, spawns);
    //PrintToServer("lobby: %i", arrays);
    PushArrayCell(angleList, angles);
}

/**
 * Given an array of vectors, returns the index of the index
 * that minimizes the euclidean distance between the vectors.
 */
stock int NearestNeighborIndex(const float vec[3], ArrayList others) {
    int closestIndex = -1;
    float closestDistance = 0.0;
    for (int i = 0; i < others.Length; i++) {
        float tmp[3];
        others.GetArray(i, tmp);
        float dist = GetVectorDistance(vec, tmp);
        if (closestIndex < 0 || dist < closestDistance) {
            closestDistance = dist;
            closestIndex = i;
        }
    }

    return closestIndex;
}

int GetArenaSpawn(int arena, int team, float origin[3], float angle[3]) {

    CHECK_ARENA(arena);
    
    if (team == CS_TEAM_T || team == CS_TEAM_CT)
    {
        ArrayList spawns;
        ArrayList angles;
        if (team == CS_TEAM_CT) {
            spawns = view_as<ArrayList>(GetArrayCell(g_CTSpawnsList, arena - 1));
            angles = view_as<ArrayList>(GetArrayCell(g_CTAnglesList, arena - 1));
        } else {
            spawns = view_as<ArrayList>(GetArrayCell(g_TSpawnsList, arena - 1));
            angles = view_as<ArrayList>(GetArrayCell(g_TAnglesList, arena - 1));
        }
    
        int count = GetArraySize(spawns);
        int index = GetRandomInt(0, count - 1);
        GetArrayArray(spawns, index, origin);
        GetArrayArray(angles, index, angle);
	
        return index;
    }
   
    return -1;
}

public void Spawns_MapEnd() {
    CloseNestedList(g_TSpawnsList);
    CloseNestedList(g_TAnglesList);
    CloseNestedList(g_CTSpawnsList);
    CloseNestedList(g_CTAnglesList);
}

void CloseNestedList(ArrayList list) {
    int n = list.Length;
    for (int i = 0; i < n; i++) {
        ArrayList tmp = view_as<ArrayList>(list.Get(i));
        delete tmp;
    }
    delete list;
}