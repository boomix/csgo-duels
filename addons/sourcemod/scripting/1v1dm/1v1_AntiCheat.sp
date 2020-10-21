// Anti-Cheat compatibility.

// Defines from Little Anti-Cheat.
#define LILAC_CHEAT_AIMBOT 	5
#define LILAC_CHEAT_AIMLOCK 	6

// How long ago a teleport must be to block it, this is a little overkill, but should do.
#define LILAC_TELEPORT_BLOCK_TIME 	3.0

// Keep track of when a player was teleported.
static float fl_teleport_time[MAXPLAYERS + 1];

void AntiCheat_OnClientPutInServer(int client)
{
	fl_teleport_time[client] = 0.0;
}

// Teleports an entity/player and handles Anti-Cheat exceptions.
void TeleportEntitySafe(int entity, const float origin[3], const float angles[3], const float velocity[3])
{
	TeleportEntity(entity, origin, angles, velocity);

	// If this entity is a player, store the timestamp of when the player teleported.
	if (entity >= 1 && entity <= MaxClients && IsClientConnected(entity) && IsClientInGame(entity))
	{
		fl_teleport_time[entity] = GetGameTime();
	}
}

public Action lilac_allow_cheat_detection(int client, int cheat)
{
	// This player teleported recently, block Aimbot & Aimlock detections.
	if (GetGameTime() - fl_teleport_time[client] < LILAC_TELEPORT_BLOCK_TIME && (cheat == LILAC_CHEAT_AIMLOCK || cheat == LILAC_CHEAT_AIMBOT))
		return Plugin_Stop;

	// Don't block the detection.
	return Plugin_Continue;
}
