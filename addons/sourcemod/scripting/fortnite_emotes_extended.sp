/*  SM Fortnite Emotes Extended
 *
 *  Copyright (C) 2020 Francisco 'Franc1sco' García
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see http://www.gnu.org/licenses/.
 */
#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <colors>

#undef REQUIRE_PLUGIN
#include <adminmenu>
#include <readyup>
#include <pause>
#include <vip_core>
#define REQUIRE_PLUGIN

/*****************************************************************
			G L O B A L   V A R S
*****************************************************************/

#define EF_BONEMERGE		  0x001
#define EF_NOSHADOW			  0x010
#define EF_BONEMERGE_FASTCULL 0x080
#define EF_NORECEIVESHADOW	  0x040
#define EF_PARENT_ANIMATES	  0x200
#define HIDEHUD_ALL			  (1 << 2)
#define HIDEHUD_CROSSHAIR	  (1 << 8)
#define CVAR_FLAGS			  FCVAR_NOTIFY

TopMenu
	hTopMenu;

ConVar
	g_cvarHidePlayers,

	g_cvarFlagEmotesMenu,
	g_cvarFlagDancesMenu,
	g_cvarCooldown,
	g_cvarSoundVolume,
	g_cvarEmotesSounds,
	g_cvarHideWeapons,
	g_cvarTeleportBack,
	g_cvarSpeed,
	g_cvarDownloadResources;

int
	g_iEmoteEnt[MAXPLAYERS + 1],
	g_iEmoteSoundEnt[MAXPLAYERS + 1],

	g_EmotesTarget[MAXPLAYERS + 1],
	g_iWeaponHandEnt[MAXPLAYERS + 1],

	playerModels[MAXPLAYERS + 1],
	playerModelsIndex[MAXPLAYERS + 1];

char
	g_sEmoteSound[MAXPLAYERS + 1][PLATFORM_MAX_PATH];

bool
	g_bClientDancing[MAXPLAYERS + 1],
	g_bEmoteCooldown[MAXPLAYERS + 1],
	g_bHooked[MAXPLAYERS + 1],

	g_bLateload,
	g_bVipCore	 = false,
	g_bAdminMenu = false,
	g_bPause	 = false;

Handle
	CooldownTimers[MAXPLAYERS + 1];

float
	g_fLastAngles[MAXPLAYERS + 1][3],
	g_fLastPosition[MAXPLAYERS + 1][3];

/*****************************************************************
			L I B R A R Y   I N C L U D E S
*****************************************************************/

#include "fnemotes/left4dhooks.sp"
#include "fnemotes/native.sp"
#include "fnemotes/resources.sp"
#include "fnemotes/menu.sp"
#include "fnemotes/vipcore.sp"
#include "fnemotes/emotes.sp"

/*****************************************************************
			P L U G I N   I N F O
*****************************************************************/

public Plugin myinfo =
{
	name		= "SM Fortnite Emotes Extended - L4D Version",
	author		= "Kodua, Franc1sco franug, TheBO$$, Foxhound, lechuga",
	description = "This plugin is for demonstration of some animations from Fortnite in L4D",
	version		= "1.6",
	url			= "https://github.com/lechuga16/Fortnite-Emotes-Extended"
};

/*****************************************************************
			F O R W A R D   P U B L I C S
*****************************************************************/

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!L4D_IsEngineLeft4Dead())
	{
		strcopy(error, err_max, "Plugin only supports in Left 4 Dead engine branch");
		return APLRes_SilentFailure;
	}

	AskPluginLoad2_native();
	g_bLateload = late;
	return APLRes_Success;
}

public void OnAllPluginsLoaded()
{
	g_bVipCore	 = LibraryExists("vip_core");
	g_bPause	 = LibraryExists("pause");
	g_bAdminMenu = LibraryExists("adminmenu");
}

public void OnLibraryRemoved(const char[] sName)
{
	if (StrEqual(sName, "vip_core"))
		g_bVipCore = false;

	if (StrEqual(sName, "pause"))
		g_bPause = false;

	if (StrEqual(sName, "adminmenu"))
		g_bAdminMenu = false;
}

public void OnLibraryAdded(const char[] sName)
{
	if (StrEqual(sName, "vip_core"))
		g_bVipCore = true;

	if (StrEqual(sName, "pause"))
		g_bPause = true;

	if (StrEqual(sName, "adminmenu"))
		g_bAdminMenu = true;
}

public void OnPluginStart()
{
	LoadTranslation("common.phrases");
	LoadTranslation("fnemotes.phrases");

	if (g_iEngine == Engine_Left4Dead)
	{
		HookEvent("player_afk", Event_PAfkQ);
		HookEvent("player_team", Event_PAfkQ);

		HookEvent("player_bot_replace", Event_PAfk);
		HookEvent("bot_player_replace", Event_PAfk);
	}
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
	HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Pre);
	HookEvent("round_start", Event_Start);
	HookEvent("player_team", Event_PlayerTeam);

	g_cvarEmotesSounds		= CreateConVar("sm_emotes_sounds", "1", "Enable/Disable sounds for emotes.", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_cvarCooldown			= CreateConVar("sm_emotes_cooldown", "2.0", "Cooldown for emotes in seconds. 0 = no cooldown.", CVAR_FLAGS, true, 0.0);
	g_cvarSoundVolume		= CreateConVar("sm_emotes_soundvolume", "1.0", "Sound volume for the emotes.", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_cvarFlagEmotesMenu	= CreateConVar("sm_emotes_admin_flag_menu", "", "admin flag for emotes (empty for all players)", CVAR_FLAGS);
	g_cvarFlagDancesMenu	= CreateConVar("sm_dances_admin_flag_menu", "", "admin flag for dances (empty for all players)", CVAR_FLAGS);
	g_cvarHideWeapons		= CreateConVar("sm_emotes_hide_weapons", "1", "Hide weapons when dancing", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_cvarHidePlayers		= CreateConVar("sm_emotes_hide_enemies", "0", "Hide enemy players when dancing", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_cvarTeleportBack		= CreateConVar("sm_emotes_teleportonend", "1", "Teleport back to the exact position when he started to dance. (Some maps need this for teleport triggers)", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_cvarSpeed				= CreateConVar("sm_emotes_speed", "1.0", "Sets the playback speed of the animation. default (1.0)", CVAR_FLAGS, true, 0.0);
	g_cvarDownloadResources = CreateConVar("sm_emotes_download_resources", "1", "Download method for the resources", CVAR_FLAGS, true, 0.0, true, 1.0);

	RegConsoleCmd("sm_emote", Command_Menu);
	RegConsoleCmd("sm_dance", Command_Menu);
	RegAdminCmd("sm_setemote", Command_Admin_Emotes, ADMFLAG_GENERIC, "[SM] Usage: sm_setemotes <#userid|name> [Emote ID]", "");
	RegAdminCmd("sm_setdance", Command_Admin_Emotes, ADMFLAG_GENERIC, "[SM] Usage: sm_setdance <#userid|name> [Emote ID]", "");

	AutoExecConfig(true, "fortnite_emotes_extended_l4d");

	OnPluginStart_resources();
	OnPluginStart_menu();
	OnPluginStart_vipcore();
}

public Action Command_Menu(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	if (g_bVipCore)
	{
		if (VIP_IsClientVIP(client))
			Menu_Dance(client);
		else
			CReplyToCommand(client, "%t %t", "TAG", "NO_DANCES_ACCESS_FLAG");

		return Plugin_Handled;
	}

	char sFlagAdmin[32];
	g_cvarFlagEmotesMenu.GetString(sFlagAdmin, sizeof(sFlagAdmin));

	if (CheckAdminFlags(client, ReadFlagString(sFlagAdmin)))
		Menu_Dance(client);
	else
		CReplyToCommand(client, "%t %t", "TAG", "NO_DANCES_ACCESS_FLAG");

	return Plugin_Handled;
}

Action Command_Admin_Emotes(int client, int args)
{
	if (args < 1)
	{
		CReplyToCommand(client, "%t: sm_setemotes <#userid|name> [Emote ID]", "USAGE");
		return Plugin_Handled;
	}

	char arg[65];
	GetCmdArg(1, arg, sizeof(arg));

	int amount = 1;
	if (args > 1)
	{
		char arg2[3];
		GetCmdArg(2, arg2, sizeof(arg2));
		if (StringToIntEx(arg2, amount) < 1 || StringToIntEx(arg2, amount) > 86)
		{
			CReplyToCommand(client, "%t %t", "TAG", "INVALID_EMOTE_ID");
			return Plugin_Handled;
		}
	}

	char target_name[MAX_TARGET_LENGTH];
	int	 target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;

	if ((target_count = ProcessTargetString(arg, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	for (int i = 0; i < target_count; i++)
	{
		PerformEmote(client, target_list[i], amount);
	}

	return Plugin_Handled;
}

public void OnMapStart()
{
	OnMapStart_Resources();
}

public void OnPluginEnd()
{
	StopDancer();
	OnPluginEnd_vipcore();
}

public void OnClientPutInServer(int client)
{
	if (IsValidClient(client))
	{
		ResetCam(client);
		TerminateEmote(client);
		g_iWeaponHandEnt[client] = INVALID_ENT_REFERENCE;

		if (CooldownTimers[client] != null)
			KillTimer(CooldownTimers[client]);
	}
}

public void OnClientDisconnect(int client)
{
	if (IsValidClient(client))
	{
		ResetCam(client);
		TerminateEmote(client);
	}
	if (CooldownTimers[client] != null)
	{
		KillTimer(CooldownTimers[client]);
		CooldownTimers[client]	 = null;
		g_bEmoteCooldown[client] = false;
	}

	g_bHooked[client] = false;
}

/*****************************************************************
			F O R W A R D   P L U G I N S
*****************************************************************/

public Action OnPlayerRunCmd(int client, int& iButtons, int& iImpulse, float fVelocity[3], float fAngles[3], int& iWeapon)
{
	if (g_bClientDancing[client] && !(GetEntityFlags(client) & FL_ONGROUND))
		StopEmote(client);

	static int iAllowedButtons = IN_BACK | IN_FORWARD | IN_MOVELEFT | IN_MOVERIGHT | IN_WALK | IN_SPEED | IN_SCORE;

	if (iButtons == 0)
		return Plugin_Continue;

	if (g_iEmoteEnt[client] == 0)
		return Plugin_Continue;

	if ((iButtons & iAllowedButtons) && !(iButtons & ~iAllowedButtons))
		return Plugin_Continue;

	StopEmote(client);

	return Plugin_Continue;
}

public void OnPause()
{
	StopDancer();
}

public void OnRoundLiveCountdownPre()
{
	StopDancer();
}

public void VIP_OnVIPLoaded()
{
	VIP_OnVIPLoaded_vipcore();
}

/****************************************************************
			C A L L B A C K   F U N C T I O N S
****************************************************************/

public void Event_PAfk(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "player"));
	int target = GetClientOfUserId(GetEventInt(event, "bot"));
	if (IsClientInGame(client))
	{
		ResetCam(client);
		TerminateEmote(client);
		RemoveSkin(client);
		WeaponUnblock(client);
		g_bClientDancing[client] = false;
	}

	SetEntityMoveType(target, MOVETYPE_WALK);
}

public void Event_PAfkQ(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (0 < client <= MaxClients && g_bClientDancing[client])
	{
		ResetCam(client);
		TerminateEmote(client);
		RemoveSkin(client);
		WeaponUnblock(client);
		g_bClientDancing[client] = false;
	}
}

public Action Event_PlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));

	if (IsValidClient(client))
	{
		ResetCam(client);
		StopEmote(client);
	}
	return Plugin_Continue;
}

public Action Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	int client	 = GetClientOfUserId(event.GetInt("userid"));

	if (!IsSurvivor(client))
		return Plugin_Continue;

	if (attacker != client)
		StopEmote(client);

	return Plugin_Continue;
}

public Action Event_Start(Event event, const char[] name, bool dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i, false) && g_bClientDancing[i])
		{
			ResetCam(i);
			// StopEmote(client);
			WeaponUnblock(i);

			g_bClientDancing[i] = false;
		}
	}

	return Plugin_Continue;
}

public void Event_PlayerTeam(Event hEvent, const char[] sEventName, bool bDontBroadcast)
{
	int iClient = GetClientOfUserId(hEvent.GetInt("userid"));
	if (!IsClientInGame(iClient) || IsFakeClient(iClient))
		return;

	L4DTeam
		OldTeam = view_as<L4DTeam>(hEvent.GetInt("oldteam"));

	if (OldTeam != L4DTeam_Survivor)
		return;

	StopEmote(iClient);
}

/*****************************************************************
			P L U G I N   F U N C T I O N S
*****************************************************************/

stock bool IsValidClient(int client, bool nobots = true)
{
	if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)))
		return false;

	return IsClientInGame(client);
}

bool CheckAdminFlags(int client, int iFlag)
{
	int iUserFlags = GetUserFlagBits(client);
	return (iUserFlags & ADMFLAG_ROOT || (iUserFlags & iFlag) == iFlag);
}

int GetEmotePeople()
{
	int count;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && g_bClientDancing[i])
			count++;
	}

	return count;
}

public void OnClientPostAdminCheck(int client)
{
	playerModelsIndex[client] = -1;
	playerModels[client]	  = INVALID_ENT_REFERENCE;
}

bool IsSurvivor(int client)
{
	return (client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2);
}

public int CreatePlayerModelProp(int client, char[] sModel)
{
	if (g_iEngine == Engine_Left4Dead)
	{
		RemoveSkin(client);
		int skin = CreateEntityByName("commentary_dummy");
		DispatchKeyValue(skin, "model", sModel);
		DispatchSpawn(skin);
		SetEntProp(skin, Prop_Send, "m_fEffects", EF_BONEMERGE | EF_BONEMERGE_FASTCULL | EF_PARENT_ANIMATES);
		SetVariantString("!activator");
		AcceptEntityInput(skin, "SetParent", client, skin);
		SetVariantString("primary");
		AcceptEntityInput(skin, "SetParentAttachment", skin, skin, 0);
		playerModels[client]	  = EntIndexToEntRef(skin);
		playerModelsIndex[client] = skin;
		return skin;
	}

	return 0;
}

public void RemoveSkin(int client)
{
	if (IsValidEntity(playerModels[client]))
		AcceptEntityInput(playerModels[client], "Kill");

	playerModels[client]	  = INVALID_ENT_REFERENCE;
	playerModelsIndex[client] = -1;
}

/**
 * Check if the translation file exists
 *
 * @param translation	Translation name.
 * @noreturn
 */
stock void LoadTranslation(const char[] translation)
{
	char
		sPath[PLATFORM_MAX_PATH],
		sName[64];

	Format(sName, sizeof(sName), "translations/%s.txt", translation);
	BuildPath(Path_SM, sPath, sizeof(sPath), sName);
	if (!FileExists(sPath))
		SetFailState("Missing translation file %s.txt", translation);

	LoadTranslations(translation);
}

/**
 * Stops the dancing emote for all valid clients.
 */
void StopDancer()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && g_bClientDancing[i])
			StopEmote(i);
	}
}