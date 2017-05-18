
#define LoopAllPlayers(%1) for(int %1=1;%1<=MaxClients;++%1)\
if(IsClientInGame(%1) && !IsFakeClient(%1) && GetClientTeam(i) == CS_TEAM_CT || IsClientInGame(%1) && !IsFakeClient(%1) && GetClientTeam(i) == CS_TEAM_T)
//#define LOBBY	2
#define CVAR_NAME_MAX_LENGTH 255
#define CVAR_VALUE_MAX_LENGTH 255


char PREFIX[150] = "";

//Weapons
ArrayList g_Rifles = null;
ArrayList g_Pistols = null;
char g_PrimaryWeapon[MAXPLAYERS + 1][50];
char g_SecondaryWeapon[MAXPLAYERS + 1][50];
char g_CustomRoundName[MAXPLAYERS + 1][50];
bool b_FirstWeaponSelect[MAXPLAYERS + 1];

//Spawns
ArrayList g_TSpawnsList;
ArrayList g_TAnglesList;
ArrayList g_CTSpawnsList;
ArrayList g_CTAnglesList;

ConVar g_RoundRestartDelayCvar;

//Arenas
int g_maxArenas = 0;
bool b_ArenaFree[32] = true;

//Players
bool b_WaitingForEnemy[MAXPLAYERS + 1] = false;
int i_PlayerArena[MAXPLAYERS + 1] = -1;
bool b_FirstTeamJoin[MAXPLAYERS + 1] = true;
int i_PrevArena[MAXPLAYERS + 1];
int i_PlayerEnemy[MAXPLAYERS + 1];
int i_PrevEnemy[MAXPLAYERS + 1];
int iArenaArrayID[64] = -1;
int g_offsCollisionGroup;

int g_roundStartedTime = -1;
bool b_NullOnce;

int LOBBY = 1;

Handle ArenaDamageTmr[64];
Handle SearchTmr[MAXPLAYERS + 1] = {null, ...};

//Cookies
Handle g_SoundEnabled;
bool b_ClientSoundEnabled[MAXPLAYERS + 1];

Handle g_Rifle;
Handle g_Pistol;

Handle g_AWPDuel;
Handle g_FlashbangDuel;
bool b_AwpDuelEnabled[MAXPLAYERS + 1];
bool b_FlashbangDuelEnabled[MAXPLAYERS + 1];
bool b_HideMainWeaponMenu[MAXPLAYERS + 1];

int i_DamageGiven[MAXPLAYERS + 1];

int iTextEntity[MAXPLAYERS + 1];

//Convars
ConVar g_DamageGivenCvar;
//ConVar g_DamageReceivedCvar;
ConVar g_ShowUsernameCvar;
ConVar g_PrefixCvar;
ConVar g_EnableRiflesCvar;
ConVar g_EnablePistolsCvar;
//ConVar g_HeadshotOnlyCvar;
ConVar g_GiveArmorCvar;
ConVar g_GiveHelmetCvar;
ConVar g_WeaponMenuJoinCvar;
ConVar g_AWPDuelsCvar;
ConVar g_FlashbangDuelsCvar;
ConVar g_DuelDelayCvar;
ConVar g_NoDamageCvar;
ConVar g_ShowKillFeedCvar;
ConVar g_CustomDuelChanceCvar;
ConVar g_ChallengeMinPlayerCvar;
ConVar g_ChallengeEnabled;

ConVar g_Timelimit;

int iChallengeEnemy[MAXPLAYERS + 1];
int iChallengeInvite[MAXPLAYERS + 1];
Handle ChallengeTmrInvite[MAXPLAYERS + 1];
