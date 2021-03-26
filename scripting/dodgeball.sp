#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>
#include emitsoundany.inc
#pragma newdecls required

#define PLUGIN_VERSION "1.0"
int TeamSelection;
int OldTeamTarget;
int iDb_Ball = -1;
int ntarget = -1;
int weaponIndex0;
int weaponIndex1;
int weaponIndex2;
int weaponIndex3;
int g_ExplosionSprite;
int Trail;
int white;
int g_HaloSprite;

bool roundstart = false;

ConVar csdb_enable;
ConVar initialspeed;
ConVar maxspeed;
ConVar addspeed;
ConVar RocketSpawnLocX;
ConVar RocketSpawnLocY;
ConVar RocketSpawnLocZ;
ConVar csdb_taser;
ConVar particle_spawn;
ConVar modelpathstring;
ConVar chicken_ball;
ConVar chicken_skin;
ConVar chick_size;
bool g_enabled = false;

static const float g_fSpin[] ={0.0, 0.0, 40.0};
int RedTrail[] = {255, 0, 0, 255};
int BluTrail[] = {0, 255, 255, 255};
float BallSpeed;
float RocketSpawnpos[3];
public Plugin myinfo = {
	name = "Csgo Dodgeball",
	author = "TonyBaretta",
	description = "Dodgeball with homing ball!",
	version = PLUGIN_VERSION,
	url = "http://www.wantedgov.it"
};

public void OnMapStart() {
	char map[128];
	GetCurrentMap(map, sizeof(map));
	if (StrContains(map, "csdb_", false) == 0 || StrContains(map, "db_", false) == 0)
	{
		SetConVarBool(csdb_enable, true);
		g_enabled = true;
	}
	if (StrContains(map, "csdb_", false) == -1 || StrContains(map, "db_", false) == -1)
	{
		SetConVarBool(csdb_enable, false);
		g_enabled = false;
		return;
	}
	if(!csdb_enable) 
	{
		return;
	}
	/*
	char file[256];
	BuildPath(Path_SM, file, 255, "configs/csdb.ini");
	Handle fileh = OpenFile(file, "r");
	if (fileh != INVALID_HANDLE)
	{
		char buffer[256];
		char buffer_full[PLATFORM_MAX_PATH];

		while(ReadFileLine(fileh, buffer, sizeof(buffer)))
		{
			TrimString(buffer);
			if ((StrContains(buffer, "//") == -1) && (!StrEqual(buffer, "")))
			{
				PrintToServer("Reading downloads line :: %s", buffer);
				Format(buffer_full, sizeof(buffer_full), "%s", buffer);
				if (FileExists(buffer_full))
				{
					PrintToServer("Precaching %s", buffer);
					PrecacheModel(buffer, true);
					AddFileToDownloadsTable(buffer_full);
				}
			}
		}
	}
	
	char cutom_model[128];
	modelpathstring.GetString(cutom_model, 128);
	PrecacheModel(cutom_model, true);
	PrecacheModel("models/combine_helicopter/helicopter_bomb01.mdl", true);
	PrecacheModel("models/chicken/chicken.mdl", true);
	PrecacheModel("models/chicken/chicken_zombie.mdl", true);
	Trail = PrecacheModel("materials/sprites/laserbeam.vmt");
	white = PrecacheModel("materials/sprites/white.vmt");
	g_HaloSprite = PrecacheModel("materials/sprites/halo01.vmt");
	g_ExplosionSprite = PrecacheModel("sprites/sprite_fire01.vmt");
	*/
}
public void OnPluginStart()
{
	CreateConVar("csgododgeball_version", PLUGIN_VERSION, "Current dodgeball version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	HookEvent("player_spawn", Player_Spawn, EventHookMode_Pre);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("round_start", Event_RoundStart);
	HookEvent("player_death", PlayerDeath);
	HookEvent("weapon_fire", EventWeaponFire, EventHookMode_Post);
	//SetConVarInt(FindConVar("sv_disable_immunity_alpha"), 1);
	csdb_enable = CreateConVar("csdb_enable", "1", "Enable Dodgeball");
	particle_spawn = CreateConVar("csdb_particle", "1", "Enable fire on spawn point");
	csdb_taser = CreateConVar("csdb_taser", "1", "Enable taser (easy deflect)");
	initialspeed = CreateConVar("csdb_speed", "600.0", "Initial speed ball");
	chick_size = CreateConVar("csdb_chicken_size", "1.5", "size of chicken model");
	modelpathstring = CreateConVar("ball_model", "models/forlix/soccer/soccerball.mdl", "model path");
	chicken_ball = CreateConVar("chicken_model", "0", "spaw rocket with chicken model");
	chicken_skin = CreateConVar("chicken_skin", "0", " 1 normal chicken, 2 zombie chicken.");
	maxspeed = CreateConVar("csdb_maxspeed", "3500.0", "Max speed ball");
	addspeed = CreateConVar("csdb_reflect_add_speed", "50.0", "Speed added per reflection.");
	RocketSpawnLocX = CreateConVar("csdb_rocket_locX", "254.503067", "X-Location where spawn rocket.");
	RocketSpawnLocY = CreateConVar("csdb_rocket_locY", "-299.242554", "Y-Location where spawn rocket.");
	RocketSpawnLocZ = CreateConVar("csdb_rocket_locZ", "-900.746002", "Z-Location where spawn rocket.");
	AutoExecConfig(true, "csgo_dodgeball");
	roundstart = false;
	/*

	char file[256];
		BuildPath(Path_SM, file, 255, "configs/csdb.ini");
		Handle fileh = OpenFile(file, "r");
		if (fileh != INVALID_HANDLE)
		{
			char buffer[256];
			char buffer_full[PLATFORM_MAX_PATH];

			while(ReadFileLine(fileh, buffer, sizeof(buffer)))
			{
				TrimString(buffer);
				if ((StrContains(buffer, "//") == -1) && (!StrEqual(buffer, "")))
				{
					PrintToServer("Reading downloads line :: %s", buffer);
					Format(buffer_full, sizeof(buffer_full), "%s", buffer);
					if (FileExists(buffer_full))
					{
						PrintToServer("Precaching %s", buffer);
						PrecacheModel(buffer, true);
						AddFileToDownloadsTable(buffer_full);
					}
				}
			}
		}
		*/
		
		char cutom_model[128];
		modelpathstring.GetString(cutom_model, 128);
		PrecacheModel(cutom_model, true);
		PrecacheModel("models/combine_helicopter/helicopter_bomb01.mdl", true);
		PrecacheModel("models/chicken/chicken.mdl", true);
		PrecacheModel("models/chicken/chicken_zombie.mdl", true);
		Trail = PrecacheModel("materials/sprites/laserbeam.vmt");
		white = PrecacheModel("materials/sprites/white.vmt");
		g_HaloSprite = PrecacheModel("materials/sprites/halo01.vmt");
		g_ExplosionSprite = PrecacheModel("sprites/sprite_fire01.vmt");
		
}
public void OnClientPutInServer(int client) {
	if(csdb_enable.BoolValue){
		CreateTimer(30.0, Welcome, client);
	}
}
public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast){
	if(csdb_enable.BoolValue)
	{

			int DynProp = -1;
			while ((DynProp = FindEntityByClassname(DynProp, "prop_dynamic")) != -1)
			{
				if(IsValidEntity(DynProp)){
					SetEntProp(DynProp, Prop_Data, "m_nSolidType", 0);
				}
			}
			int StaticProp = -1;
			while ((StaticProp = FindEntityByClassname(StaticProp, "prop_static")) != -1)
			{
				if(IsValidEntity(StaticProp)){
					SetEntProp(StaticProp, Prop_Data, "m_nSolidType", 0);
				}
			}
			if(GetPlayerCountTeam(2) <= 0 || GetPlayerCountTeam(3) <= 0){
				PrintToChatAll("当双方都存在玩家时就开始游戏，请稍等^");
				//ServerCommand("mp_do_warmup_period 30.0");
				//ServerCommand("mp_warmup_start");
				return;
			}
			if(GetPlayerCountTeam(2) >= 1 && GetPlayerCountTeam(3) >= 1){
				int index = FindEntityByClassname(-1, "info_target")
				if(IsValidEntity(index)){
					char entName[50];
					GetEntPropString(index, Prop_Data, "m_iName", entName, sizeof(entName));
					if(strcmp(entName, "ball_spawn") == 0)
					{
						GetEntPropVector(index, Prop_Data, "m_vecAbsOrigin", RocketSpawnpos);
					}
					if(index<=-1)
					{
						float rocketpos[3];
						rocketpos[0] = RocketSpawnLocX.FloatValue;
						rocketpos[1] = RocketSpawnLocY.FloatValue;
						rocketpos[2] = RocketSpawnLocZ.FloatValue;
						index = CreateEntityByName("info_target");
						SetEntPropString(index, Prop_Data, "m_iName", "ball_spawn");
						TeleportEntity(index, rocketpos, NULL_VECTOR, NULL_VECTOR);
					}
					if(particle_spawn.BoolValue)
					{
						CreateParticle(index, "env_fire_small_smoke");
					}
					roundstart = true;
					if(OldTeamTarget <= 1){
						TeamSelection = GetRandomInt(2,3);
					}
					CreateTimer(0.1, Updatepos, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(4.0, iBallFired);
				}
			}

	}
}
public Action Event_RoundEnd(Event event, const char[] name, bool dontBroadcast){
	if(csdb_enable.BoolValue)
	{
		roundstart = false;
		if(IsValidEntity(iDb_Ball))
		{
			SDKUnhook(iDb_Ball, SDKHook_Touch, OnTouchDodge);
			SDKUnhook(iDb_Ball, SDKHook_OnTakeDamage, Dodgeball_Hurt);
			AcceptEntityInput(iDb_Ball, "Kill");
			iDb_Ball =-1;
		}
		if(GetPlayerCountTeam(2) <= 0 || GetPlayerCountTeam(3) <= 0){
			ServerCommand("mp_do_warmup_period 30");
		}
	}
}
public Action Updatepos(Handle timer)
{
	//if (GameRules_GetProp("m_bWarmupPeriod")) return Plugin_Stop;
	
	if(roundstart)
	{
		if (IsValidEntity(iDb_Ball))
		{
			OnCheckPos(iDb_Ball);
		}
		return Plugin_Continue;
	}
	return Plugin_Stop;
}
public Action Player_Spawn(Event event, const char[] name, bool dontBroadcast){
	if(csdb_enable.BoolValue){
		int client = GetClientOfUserId(GetEventInt(event, "userid"))
		RemoveClientWeapons(client);
		GivePlayerItem(client, "weapon_knife");
		if(csdb_taser.BoolValue){
			GivePlayerItem(client, "weapon_glock");
		}		
		SDKHook(client, SDKHook_OnTakeDamage, HurtClient);
	}
}
public Action PlayerDeath(Event event, const char[] name, bool dontBroadcast){
	if(csdb_enable.BoolValue){
		int client = GetClientOfUserId(GetEventInt(event, "userid"))
		SDKUnhook(client, SDKHook_OnTakeDamage, HurtClient);
	}
}
public Action Welcome(Handle timer, any client){
	if(!IsValidClient(client)) return Plugin_Handled;
	PrintToChat(client, "CSGO Dodgeball %s by -GoV-TonyBaretta\nCSS Dodgeball %s by misiu29", PLUGIN_VERSION,PLUGIN_VERSION);
	return Plugin_Handled;
}
public Action iBallFired(Handle hndl) {
	if(roundstart){
		float vVelocity[3];
		iDb_Ball = CreateEntityByName("smokegrenade_projectile");
		if (IsValidEntity(iDb_Ball))
		{
			DispatchKeyValue(iDb_Ball, "solid", "6");
			DispatchSpawn(iDb_Ball);
			SetEntPropEnt(iDb_Ball, Prop_Send, "m_hThrower", 0);
			vVelocity[0] = initialspeed.FloatValue;
			BallSpeed = initialspeed.FloatValue;
			TeleportEntity(iDb_Ball, RocketSpawnpos, NULL_VECTOR, vVelocity);
			SetEntityMoveType(iDb_Ball, MOVETYPE_FLY);
			char buffer[128];
			modelpathstring.GetString(buffer, 128);
			if(!chicken_ball.BoolValue){
				SetEntityModel(iDb_Ball, buffer);
			}
			if(chicken_ball.BoolValue){
				if(chicken_skin){
					SetEntityModel(iDb_Ball, "models/chicken/chicken_zombie.mdl");
					SetEntPropFloat(iDb_Ball, Prop_Send, "m_flModelScale", chick_size.FloatValue);
				}
				else{
					SetEntityModel(iDb_Ball, "models/chicken/chicken.mdl");
					SetEntPropFloat(iDb_Ball, Prop_Send, "m_flModelScale", chick_size.FloatValue);
				}
			}
			CreateParticle(iDb_Ball, "env_fire_small_smoke");
			SetEntPropVector(iDb_Ball, Prop_Data, "m_vecAngVelocity", g_fSpin);
			SDKHook(iDb_Ball, SDKHook_Touch, OnTouchDodge);
			SDKHook(iDb_Ball, SDKHook_TraceAttack, Dodgeball_Hurt);
			if(OldTeamTarget == 2){
				TeamSelection = 3;
			}
			else
			if(OldTeamTarget == 3){
				TeamSelection = 2;
			}
			if(TeamSelection == 2){			
				SetEntityRenderColor(iDb_Ball, 0, 255, 255, 255);
				TE_SetupBeamFollow(iDb_Ball, Trail, 0, 2.0, 1.0, 1.0, 1, BluTrail);
				TE_SendToAll();
			}
			if(TeamSelection == 3){
				SetEntityRenderColor(iDb_Ball, 255, 0, 0, 255);
				TE_SetupBeamFollow(iDb_Ball, Trail, 0, 2.0, 1.0, 1.0, 1, RedTrail);
				TE_SendToAll();
			}
			if(IsValidClient(ntarget) && IsValidEntity(iDb_Ball)){
				ntarget = GetRandomPlayerTeam(TeamSelection);
			}
			OldTeamTarget = TeamSelection;
		}
	}
	return Plugin_Handled;
	
}
public int OnCheckPos(int entity) {
	float ProjLocation[3];
	float ProjVector[3];
	float ProjSpeed;
	float ProjAngle[3];
	float TargetLocation[3];
	float AimVector[3];
	if((IsValidClient(ntarget) && GetClientTeam(ntarget)<= 1) || !IsValidClient(ntarget)){
		ntarget =  GetRandomPlayerTeam(GetRandomInt(2,3));
	}
	if(IsValidClient(ntarget) && !IsPlayerAlive(ntarget) && GetClientTeam(ntarget)>= 2){
		ntarget =  GetRandomPlayerTeam(GetClientTeam(ntarget));
	}
	if(IsValidClient(ntarget))
	{
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjLocation);
		GetClientAbsOrigin(ntarget, TargetLocation);
		TargetLocation[2] += 40.0;
		MakeVectorFromPoints(ProjLocation, TargetLocation , AimVector);
		GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", ProjVector);					
		ProjSpeed = GetVectorLength(ProjVector);					
		AddVectors(ProjVector, AimVector, ProjVector);	
		NormalizeVector(ProjVector, ProjVector);
		GetEntPropVector(entity, Prop_Data, "m_angRotation", ProjAngle);
		GetVectorAngles(ProjVector, ProjAngle);
		SetEntPropVector(entity, Prop_Data, "m_angRotation", ProjAngle);					
		ScaleVector(ProjVector, BallSpeed);
			
		SetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", ProjVector);
		TeleportEntity(entity, NULL_VECTOR, ProjAngle, ProjVector);
		
		float Distance2 = GetVectorDistance(ProjLocation, TargetLocation);
		
		float HitVec[3];
		int iHudSpeed;
		if (Distance2 > 100.0)
		{		
			iHudSpeed = RoundToZero(BallSpeed);
			if(iHudSpeed < 1000){
				PrintCenterTextAll("球速度:%i||\n目标: %N", RoundToZero(BallSpeed), ntarget);
			}
			if(iHudSpeed > 1000 && iHudSpeed < 1500){
				PrintCenterTextAll("球速度:%i|||||\n目标: %N", RoundToZero(BallSpeed), ntarget);
			}
			if(iHudSpeed > 1500){
				PrintCenterTextAll("球速度:%i||||||||\n目标: %N", RoundToZero(BallSpeed), ntarget);
			}
		}
		if(iHudSpeed > 1500){
			if (Distance2 > 200.0 && Distance2 < 1500.0){
				AddVectors(AimVector, ProjVector, HitVec);
				HitVec = AimVector;
				NormalizeVector(HitVec, HitVec);
				ScaleVector(HitVec, ProjSpeed);
				float FinalAng[3];
				GetVectorAngles(HitVec, FinalAng);
				TeleportEntity(entity, NULL_VECTOR, FinalAng, HitVec);
			}
		}
		if (Distance2 < 501.0){
			AddVectors(AimVector, ProjVector, HitVec);
			HitVec = AimVector;
			NormalizeVector(HitVec, HitVec);
			ScaleVector(HitVec, ProjSpeed);
			float FinalAng[3];
			GetVectorAngles(HitVec, FinalAng);
			TeleportEntity(entity, NULL_VECTOR, FinalAng, HitVec);
		}
		if (Distance2 < 30.0)
		{
			if (IsValidClient(ntarget) && IsValidEntity(entity))
			{
				GetClientAbsOrigin(ntarget, TargetLocation);
				int owner = GetEntPropEnt(entity, Prop_Send, "m_hThrower");
				float Damage = 500.0;
				if(owner <= 0){
					SDKHooks_TakeDamage(ntarget, 0, 0, Damage);
				}
				if(IsValidClient(owner)){
					SDKHooks_TakeDamage(ntarget, owner, owner, Damage);
				}
				ClientExplode(ntarget, TargetLocation);
				RequestFrame(Remove_Ragdoll, ntarget);
				if (IsValidEntity(entity))
				{
					SDKUnhook(entity, SDKHook_Touch, OnTouchDodge);
					SDKUnhook(entity, SDKHook_OnTakeDamage, Dodgeball_Hurt);
					AcceptEntityInput(entity, "Kill");
					iDb_Ball = -1;
					CreateTimer(0.5, iBallFired);
				}
			}
		}
	}
}
public Action Dodgeball_Hurt(int entity, int &attacker, int &inflictor, float &damage, int &damagetype) {
	entity = iDb_Ball;
	if (IsValidClient(attacker) && IsValidEntity(entity) && attacker == ntarget) {
		if(((GetEntityFlags(entity) & FL_ONGROUND)))return Plugin_Continue;
		
		float vel[3];
		damage = 100.0;
		if(BallSpeed <= maxspeed.FloatValue){
			BallSpeed += addspeed.FloatValue;
		}
		GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", vel);
		float currentspeed = SquareRoot(Pow(vel[0],2.0)+Pow(vel[1],2.0));
		float x = currentspeed / (BallSpeed*2.0);
		vel[0] /= -x;
		vel[1] /= -x;
		vel[2] = BallSpeed*2.5;

		TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vel);
		//SetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", vel);
		SetEntProp(entity, Prop_Data, "m_iTeamNum", GetClientTeam(attacker));
		SetEntPropFloat(entity, Prop_Data, "m_flDamage", 99.0);
		SetEntPropFloat(entity, Prop_Data, "m_DmgRadius", 350.0)
		SetEntPropEnt(entity, Prop_Send, "m_hThrower", attacker);
		if(GetClientTeam(ntarget) == 2){
			ntarget =  GetRandomPlayerTeam(3);
			SetEntityRenderColor(iDb_Ball, 255, 0, 0, 255);
			OldTeamTarget = 3;
		}
		else
		if(GetClientTeam(ntarget) == 3){
			ntarget =  GetRandomPlayerTeam(2);
			SetEntityRenderColor(iDb_Ball, 0, 255, 255, 255);
			OldTeamTarget = 2;
		}
		if(OldTeamTarget == 2){
			TE_SetupBeamFollow(entity, Trail, 0, 2.0, 1.0, 1.0, 1, BluTrail);
			TE_SendToAll();
		}
		if(OldTeamTarget == 3){
			TE_SetupBeamFollow(entity, Trail, 0, 2.0, 1.0, 1.0, 1, RedTrail);
			TE_SendToAll();
		}
	}
	return Plugin_Changed;
}
public Action OnTouchDodge(int entity, int other)
{
	entity = iDb_Ball;
	if(((GetEntityFlags(entity) & FL_ONGROUND)))return Plugin_Continue;
	if(other && other <= MaxClients){
		if (IsValidClient(other) && GetClientTeam(other) == TeamSelection && other == ntarget) {
			float TargetLocation[3];
			GetClientAbsOrigin(other, TargetLocation);
			ClientExplode(other, TargetLocation);
			int owner = GetEntPropEnt(entity, Prop_Send, "m_hThrower");
			float Damage = 1000.0;
			if(owner <= 0){
				SDKHooks_TakeDamage(ntarget, 0, 0, Damage);
			}
			if(IsValidClient(owner)){
				SDKHooks_TakeDamage(ntarget, owner, owner, Damage);
			}
			RequestFrame(Remove_Ragdoll, other);
			if (IsValidEntity(entity)) {
				SDKUnhook(entity, SDKHook_Touch, OnTouchDodge);
				SDKUnhook(entity, SDKHook_OnTakeDamage, Dodgeball_Hurt);
				AcceptEntityInput(entity, "Kill");
				iDb_Ball = -1;
				CreateTimer(0.5, iBallFired);
			}
		}
	}
	return Plugin_Continue;
}
public void OnClientDisconnect(int client)
{
	if(csdb_enable.BoolValue){
		if(client == ntarget){
			ntarget =  GetRandomPlayerTeam(GetClientTeam(ntarget));
		}
	}
}
public Action EventWeaponFire(Event event,const char[] name,bool dontBroadcast)
{
	if(csdb_enable.BoolValue){
		if(csdb_taser.BoolValue){
			int clientid = GetClientOfUserId(GetEventInt(event, "userid"));
			char weapon[32];
			GetEventString(event, "weapon", weapon, sizeof(weapon));
			if (StrEqual(weapon, "weapon_taser"))
			{
				CreateTimer(0.4, Refill, clientid);
			}
		}
	}
}
public Action Refill(Handle timer, any client)
{
	if (IsValidClient(client) && (IsPlayerAlive(client))) {
		GivePlayerItem(client, "weapon_taser");
	}
}
int GetRandomPlayerTeam(int team)
{
	int clients[MAXPLAYERS+1]; int clientCount;
	for (int i = 1; i <= MaxClients; i++)
		if (IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == team)
		clients[clientCount++] = i;
	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount-1)];
}
public int RemoveClientWeapons(int i) {
	if (IsValidClient(i) && (IsPlayerAlive(i))) {
		if ((weaponIndex0 = GetPlayerWeaponSlot(i, 0)) != -1)
			RemovePlayerItem(i, weaponIndex0);
		if ((weaponIndex1 = GetPlayerWeaponSlot(i, 1)) != -1)
			RemovePlayerItem(i, weaponIndex1);
		if ((weaponIndex2 = GetPlayerWeaponSlot(i, 2)) != -1)
			RemovePlayerItem(i, weaponIndex2);
		if ((weaponIndex3 = GetPlayerWeaponSlot(i, 3)) != -1)
			RemovePlayerItem(i, weaponIndex3);
	}
}
public Action HurtClient(int victim, int &attacker, int &inflictor, float &damage, int &damagetype) {
	if(victim <0 || victim > MAXPLAYERS)return Plugin_Changed;
	else
	if(damage <=600){
		damage = 0.0;
	}
	return Plugin_Changed;
}
stock bool IsValidClient(int iClient) {
	if (iClient <= 0) return false;
	if (iClient > MaxClients) return false;
	if (!IsClientConnected(iClient)) return false;
	return IsClientInGame(iClient);
}
public int Remove_Ragdoll(int client) {
	if(IsValidClient(client)) {
		int rag = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
		if (rag > MaxClients && IsValidEntity(rag))
			AcceptEntityInput(rag, "Kill");
	}
}
int ClientExplode(int client, float vec1[3])
{
	int color[4]={188,220,255,200};
	PrecacheSoundAny("weapons/hegrenade/explode4.wav",true);
	if(IsValidClient(client)){
		EmitSoundToAllAny("weapons/hegrenade/explode4.wav", SOUND_FROM_PLAYER, SNDCHAN_STATIC);
	}
	TE_SetupExplosion(vec1, g_ExplosionSprite, 10.0, 1, 0, 0, 750);
	TE_SendToAll();
	TE_SetupBeamRingPoint(vec1, 10.0, 500.0, white, g_HaloSprite, 0, 10, 0.6, 10.0, 0.5, color, 10, 0);
	TE_SendToAll();
}
int CreateParticle(int entity, char []particle)
{
	
	int ent = CreateEntityByName("info_particle_system");
	
	float particleOrigin[3];
	
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", particleOrigin);

	DispatchKeyValue(ent , "start_active", "0");
	DispatchKeyValue(ent, "effect_name", particle);
	DispatchSpawn(ent);
	
	TeleportEntity(ent , particleOrigin, NULL_VECTOR,NULL_VECTOR);
	
	
	SetVariantString("!activator");
	AcceptEntityInput(ent, "SetParent", entity, ent, 0);
	
	ActivateEntity(ent);
	AcceptEntityInput(ent, "Start");
	
	entity = EntIndexToEntRef(ent);
}
int GetPlayerCountTeam(int team)
{
    int players_team;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidClient(i) && GetClientTeam(i) == team)
            players_team++;
    }
    return players_team;
}