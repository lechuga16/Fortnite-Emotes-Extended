#if defined _emotes_included
	#endinput
#endif
#define _emotes_included

/*****************************************************************
			P L U G I N   F U N C T I O N S
*****************************************************************/

Action CreateEmote(int client, const char[] anim1, const char[] anim2, const char[] soundName, bool isLooped)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	if (g_EmoteForward_Pre != null)
	{
		Action res = Plugin_Continue;
		Call_StartForward(g_EmoteForward_Pre);
		Call_PushCell(client);
		Call_Finish(res);

		if (res != Plugin_Continue)
			return Plugin_Handled;
	}

	L4DTeam team = L4D_GetClientTeam(client);
	if (team != L4DTeam_Survivor)
	{
		CPrintToChat(client, "%t %t", "TAG", "NOTSURVIVOR");
		return Plugin_Handled;
	}

	if (g_bPause && IsInPause())
	{
		CPrintToChat(client, "%t %t", "TAG", "PAUSE_MODE");
		return Plugin_Handled;
	}

	if (!IsPlayerAlive(client))
	{
		CPrintToChat(client, "%t %t", "TAG", "MUST_BE_ALIVE");
		return Plugin_Handled;
	}

	if (!(GetEntityFlags(client) & FL_ONGROUND))
	{
		CPrintToChat(client, "%t %t", "TAG", "STAY_ON_GROUND");
		return Plugin_Handled;
	}

	if (CooldownTimers[client])
	{
		CPrintToChat(client, "%t %t", "TAG", "COOLDOWN_EMOTES");
		return Plugin_Handled;
	}

	if (StrEqual(anim1, ""))
	{
		CPrintToChat(client, "%t %t", "TAG", "AMIN_1_INVALID");
		return Plugin_Handled;
	}

	if (g_iEmoteEnt[client])
		StopEmote(client);

	if (GetEntityMoveType(client) == MOVETYPE_NONE)
	{
		CPrintToChat(client, "%t %t", "TAG", "CANNOT_USE_NOW");
		return Plugin_Handled;
	}

	int EmoteEnt = CreateEntityByName("prop_dynamic");
	if (IsValidEntity(EmoteEnt))
	{
		SetEntityMoveType(client, MOVETYPE_NONE);
		if (g_iEngine == Engine_Left4Dead)
			SetEntityRenderMode(client, RENDER_TRANSALPHA);

		WeaponBlock(client);

		float
			vec[3],
			ang[3];

		GetClientAbsOrigin(client, vec);
		GetClientAbsAngles(client, ang);

		g_fLastPosition[client] = vec;
		g_fLastAngles[client]	= ang;
		int	 skin				= -1;
		char emoteEntName[16];
		FormatEx(emoteEntName, sizeof(emoteEntName), "emoteEnt%i", GetRandomInt(1000000, 9999999));
		char model[PLATFORM_MAX_PATH];
		GetClientModel(client, model, sizeof(model));
		skin = CreatePlayerModelProp(client, model);
		DispatchKeyValue(EmoteEnt, "targetname", emoteEntName);

		if (g_iEngine == Engine_Left4Dead)
			DispatchKeyValue(EmoteEnt, "model", "models/player/custom_player/foxhound/fortnite_dances_emotes_l4d.mdl");
		else if (g_iEngine == Engine_Left4Dead2)
			DispatchKeyValue(EmoteEnt, "model", "models/player/custom_player/foxhound/fortnite_dances_emotes_ok.mdl");

		DispatchKeyValue(EmoteEnt, "solid", "0");
		DispatchKeyValue(EmoteEnt, "rendermode", "0");

		ActivateEntity(EmoteEnt);
		DispatchSpawn(EmoteEnt);

		TeleportEntity(EmoteEnt, vec, ang, NULL_VECTOR);

		SetVariantString(emoteEntName);
		AcceptEntityInput(client, "SetParent", client, client, skin);

		g_iEmoteEnt[client] = EntIndexToEntRef(EmoteEnt);

		SetEntProp(client, Prop_Send, "m_fEffects", EF_BONEMERGE | EF_NOSHADOW | EF_NORECEIVESHADOW | EF_BONEMERGE_FASTCULL | EF_PARENT_ANIMATES);

		// Sound

		if (g_cvarEmotesSounds.BoolValue && !StrEqual(soundName, ""))
		{
			int EmoteSoundEnt = CreateEntityByName("info_target");
			if (IsValidEntity(EmoteSoundEnt))
			{
				char soundEntName[16];
				FormatEx(soundEntName, sizeof(soundEntName), "soundEnt%i", GetRandomInt(1000000, 9999999));

				DispatchKeyValue(EmoteSoundEnt, "targetname", soundEntName);

				DispatchSpawn(EmoteSoundEnt);

				vec[2] += 72.0;
				TeleportEntity(EmoteSoundEnt, vec, NULL_VECTOR, NULL_VECTOR);

				SetVariantString(emoteEntName);
				AcceptEntityInput(EmoteSoundEnt, "SetParent");

				g_iEmoteSoundEnt[client] = EntIndexToEntRef(EmoteSoundEnt);

				// Formatting sound path

				char soundNameBuffer[64];

				if (StrEqual(soundName, "ninja_dance_01") || StrEqual(soundName, "dance_soldier_03"))
				{
					int randomSound = GetRandomInt(0, 1);

					soundNameBuffer = randomSound ? "ninja_dance_01" : "dance_soldier_03";
				}
				else
					FormatEx(soundNameBuffer, sizeof(soundNameBuffer), "%s", soundName);

				FormatEx(g_sEmoteSound[client], PLATFORM_MAX_PATH, "kodua/fortnite_emotes/%s.mp3", soundNameBuffer);

				EmitSoundToAll(g_sEmoteSound[client], EmoteSoundEnt, SNDCHAN_AUTO, SNDLEVEL_CONVO, _, g_cvarSoundVolume.FloatValue, _, _, vec, _, _, _);
			}
		}
		else
			g_sEmoteSound[client] = "";

		if (StrEqual(anim2, "none", false))
		{
			HookSingleEntityOutput(EmoteEnt, "OnAnimationDone", EndAnimation, true);
		}
		else
		{
			SetVariantString(anim2);
			AcceptEntityInput(EmoteEnt, "SetDefaultAnimation", -1, -1, 0);
		}

		SetVariantString(anim1);
		AcceptEntityInput(EmoteEnt, "SetAnimation", -1, -1, 0);

		if (g_cvarSpeed.FloatValue != 1.0)
			SetEntPropFloat(EmoteEnt, Prop_Send, "m_flPlaybackRate", g_cvarSpeed.FloatValue);

		SetCam(client);

		g_bClientDancing[client] = true;

		if (g_cvarHidePlayers.BoolValue)
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) != GetClientTeam(client) && !g_bHooked[i])
				{
					SDKHook(i, SDKHook_SetTransmit, SetTransmit);
					g_bHooked[i] = true;
				}
			}
		}

		if (g_cvarCooldown.FloatValue > 0.0)
			CooldownTimers[client] = CreateTimer(g_cvarCooldown.FloatValue, ResetCooldown, client);

		if (g_EmoteForward != null)
		{
			Call_StartForward(g_EmoteForward);
			Call_PushCell(client);
			Call_Finish();
		}

		if (isLooped) {}	// ????
	}

	return Plugin_Handled;
}

void EndAnimation(const char[] output, int caller, int activator, float delay)
{
	if (caller > 0)
	{
		activator = GetEmoteActivator(EntIndexToEntRef(caller));
		StopEmote(activator);
	}
}

int GetEmoteActivator(int iEntRefDancer)
{
	if (iEntRefDancer == INVALID_ENT_REFERENCE)
		return 0;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (g_iEmoteEnt[i] == iEntRefDancer)
			return i;
	}
	return 0;
}

void StopEmote(int client)
{
	if (!g_iEmoteEnt[client])
		return;

	int iEmoteEnt = EntRefToEntIndex(g_iEmoteEnt[client]);
	if (iEmoteEnt && iEmoteEnt != INVALID_ENT_REFERENCE && IsValidEntity(iEmoteEnt))
	{
		char emoteEntName[50];
		GetEntPropString(iEmoteEnt, Prop_Data, "m_iName", emoteEntName, sizeof(emoteEntName));
		SetVariantString(emoteEntName);
		AcceptEntityInput(client, "ClearParent", iEmoteEnt, iEmoteEnt, 0);
		DispatchKeyValue(iEmoteEnt, "OnUser1", "!self,Kill,,1.0,-1");
		AcceptEntityInput(iEmoteEnt, "FireUser1");

		if (g_cvarTeleportBack.BoolValue)
			TeleportEntity(client, g_fLastPosition[client], g_fLastAngles[client], NULL_VECTOR);

		RemoveSkin(client);
		ResetCam(client);
		WeaponUnblock(client);
		SetEntityMoveType(client, MOVETYPE_WALK);

		if (g_iEngine == Engine_Left4Dead)
			SetEntityRenderMode(client, RENDER_NORMAL);

		g_iEmoteEnt[client]		 = 0;
		g_bClientDancing[client] = false;
	}
	else
	{
		g_iEmoteEnt[client]		 = 0;
		g_bClientDancing[client] = false;
	}

	if (g_iEmoteSoundEnt[client])
	{
		int iEmoteSoundEnt = EntRefToEntIndex(g_iEmoteSoundEnt[client]);

		if (!StrEqual(g_sEmoteSound[client], "") && iEmoteSoundEnt && iEmoteSoundEnt != INVALID_ENT_REFERENCE && IsValidEntity(iEmoteSoundEnt))
		{
			StopSound(iEmoteSoundEnt, SNDCHAN_AUTO, g_sEmoteSound[client]);
			AcceptEntityInput(iEmoteSoundEnt, "Kill");
			g_iEmoteSoundEnt[client] = 0;
		}
		else
			g_iEmoteSoundEnt[client] = 0;
	}
}

void TerminateEmote(int client)
{
	if (!g_iEmoteEnt[client])
		return;

	int iEmoteEnt = EntRefToEntIndex(g_iEmoteEnt[client]);
	if (iEmoteEnt && iEmoteEnt != INVALID_ENT_REFERENCE && IsValidEntity(iEmoteEnt))
	{
		char emoteEntName[50];
		GetEntPropString(iEmoteEnt, Prop_Data, "m_iName", emoteEntName, sizeof(emoteEntName));
		SetVariantString(emoteEntName);
		AcceptEntityInput(client, "ClearParent", iEmoteEnt, iEmoteEnt, 0);
		DispatchKeyValue(iEmoteEnt, "OnUser1", "!self,Kill,,1.0,-1");
		AcceptEntityInput(iEmoteEnt, "FireUser1");

		g_iEmoteEnt[client]		 = 0;
		g_bClientDancing[client] = false;
	}
	else
	{
		g_iEmoteEnt[client]		 = 0;
		g_bClientDancing[client] = false;
	}

	if (g_iEmoteSoundEnt[client])
	{
		int iEmoteSoundEnt = EntRefToEntIndex(g_iEmoteSoundEnt[client]);

		if (!StrEqual(g_sEmoteSound[client], "") && iEmoteSoundEnt && iEmoteSoundEnt != INVALID_ENT_REFERENCE && IsValidEntity(iEmoteSoundEnt))
		{
			StopSound(iEmoteSoundEnt, SNDCHAN_AUTO, g_sEmoteSound[client]);
			AcceptEntityInput(iEmoteSoundEnt, "Kill");
			g_iEmoteSoundEnt[client] = 0;
		}
		else
			g_iEmoteSoundEnt[client] = 0;
	}
}

void PerformEmote(int client, int target, int amount)
{
	switch (amount)
	{
		case 1:
			CreateEmote(target, "Emote_Fonzie_Pistol", "none", "", false);
		case 2:
			CreateEmote(target, "Emote_Bring_It_On", "none", "", false);
		case 3:
			CreateEmote(target, "Emote_ThumbsDown", "none", "", false);
		case 4:
			CreateEmote(target, "Emote_ThumbsUp", "none", "", false);
		case 5:
			CreateEmote(target, "Emote_Celebration_Loop", "", "", false);
		case 6:
			CreateEmote(target, "Emote_BlowKiss", "none", "", false);
		case 7:
			CreateEmote(target, "Emote_Calculated", "none", "", false);
		case 8:
			CreateEmote(target, "Emote_Confused", "none", "", false);
		case 9:
			CreateEmote(target, "Emote_Chug", "none", "", false);
		case 10:
			CreateEmote(target, "Emote_Cry", "none", "emote_cry", false);
		case 11:
			CreateEmote(target, "Emote_DustingOffHands", "none", "athena_emote_bandofthefort_music", true);
		case 12:
			CreateEmote(target, "Emote_DustOffShoulders", "none", "athena_emote_hot_music", true);
		case 13:
			CreateEmote(target, "Emote_Facepalm", "none", "athena_emote_facepalm_foley_01", false);
		case 14:
			CreateEmote(target, "Emote_Fishing", "none", "Athena_Emotes_OnTheHook_02", false);
		case 15:
			CreateEmote(target, "Emote_Flex", "none", "", false);
		case 16:
			CreateEmote(target, "Emote_golfclap", "none", "", false);
		case 17:
			CreateEmote(target, "Emote_HandSignals", "none", "", false);
		case 18:
			CreateEmote(target, "Emote_HeelClick", "none", "Emote_HeelClick", false);
		case 19:
			CreateEmote(target, "Emote_Hotstuff", "none", "Emote_Hotstuff", false);
		case 20:
			CreateEmote(target, "Emote_IBreakYou", "none", "", false);
		case 21:
			CreateEmote(target, "Emote_IHeartYou", "none", "", false);
		case 22:
			CreateEmote(target, "Emote_Kung-Fu_Salute", "none", "", false);
		case 23:
			CreateEmote(target, "Emote_Laugh", "Emote_Laugh_CT", "emote_laugh_01.mp3", false);
		case 24:
			CreateEmote(target, "Emote_Luchador", "none", "Emote_Luchador", false);
		case 25:
			CreateEmote(target, "Emote_Make_It_Rain", "none", "athena_emote_makeitrain_music", false);
		case 26:
			CreateEmote(target, "Emote_NotToday", "none", "", false);
		case 27:
			CreateEmote(target, "Emote_RockPaperScissor_Paper", "none", "", false);
		case 28:
			CreateEmote(target, "Emote_RockPaperScissor_Rock", "none", "", false);
		case 29:
			CreateEmote(target, "Emote_RockPaperScissor_Scissor", "none", "", false);
		case 30:
			CreateEmote(target, "Emote_Salt", "none", "", false);
		case 31:
			CreateEmote(target, "Emote_Salute", "none", "athena_emote_salute_foley_01", false);
		case 32:
			CreateEmote(target, "Emote_SmoothDrive", "none", "", false);
		case 33:
			CreateEmote(target, "Emote_Snap", "none", "Emote_Snap1", false);
		case 34:
			CreateEmote(target, "Emote_StageBow", "none", "emote_stagebow", false);
		case 35:
			CreateEmote(target, "Emote_Wave2", "none", "", false);
		case 36:
			CreateEmote(target, "Emote_Yeet", "none", "Emote_Yeet", false);
		case 37:
			CreateEmote(target, "DanceMoves", "none", "ninja_dance_01", false);
		case 38:
			CreateEmote(target, "Emote_Mask_Off_Intro", "Emote_Mask_Off_Loop", "Hip_Hop_Good_Vibes_Mix_01_Loop", true);
		case 39:
			CreateEmote(target, "Emote_Zippy_Dance", "none", "emote_zippy_A", true);
		case 40:
			CreateEmote(target, "ElectroShuffle", "none", "athena_emote_electroshuffle_music", true);
		case 41:
			CreateEmote(target, "Emote_AerobicChamp", "none", "emote_aerobics_01", true);
		case 42:
			CreateEmote(target, "Emote_Bendy", "none", "athena_music_emotes_bendy", true);
		case 43:
			CreateEmote(target, "Emote_BandOfTheFort", "none", "athena_emote_bandofthefort_music", true);
		case 44:
			CreateEmote(target, "Emote_Boogie_Down_Intro", "Emote_Boogie_Down", "emote_boogiedown", true);
		case 45:
			CreateEmote(target, "Emote_Capoeira", "none", "emote_capoeira", false);
		case 46:
			CreateEmote(target, "Emote_Charleston", "none", "athena_emote_flapper_music", true);
		case 47:
			CreateEmote(target, "Emote_Chicken", "none", "athena_emote_chicken_foley_01", true);
		case 48:
			CreateEmote(target, "Emote_Dance_NoBones", "none", "athena_emote_music_boneless", true);
		case 49:
			CreateEmote(target, "Emote_Dance_Shoot", "none", "athena_emotes_music_shoot_v7", true);
		case 50:
			CreateEmote(target, "Emote_Dance_SwipeIt", "none", "Athena_Emotes_Music_SwipeIt", true);
		case 51:
			CreateEmote(target, "Emote_Dance_Disco_T3", "none", "athena_emote_disco", true);
		case 52:
			CreateEmote(target, "Emote_DG_Disco", "none", "athena_emote_disco", true);
		case 53:
			CreateEmote(target, "Emote_Dance_Worm", "none", "athena_emote_worm_music", false);
		case 54:
			CreateEmote(target, "Emote_Dance_Loser", "Emote_Dance_Loser_CT", "athena_music_emotes_takethel", true);
		case 55:
			CreateEmote(target, "Emote_Dance_Breakdance", "none", "athena_emote_breakdance_music", false);
		case 56:
			CreateEmote(target, "Emote_Dance_Pump", "none", "Emote_Dance_Pump", true);
		case 57:
			CreateEmote(target, "Emote_Dance_RideThePony", "none", "athena_emote_ridethepony_music_01", false);
		case 58:
			CreateEmote(target, "Emote_Dab", "none", "", false);
		case 59:
			CreateEmote(target, "Emote_EasternBloc_Start", "Emote_EasternBloc", "eastern_bloc_musc_setup_d", true);
		case 60:
			CreateEmote(target, "Emote_FancyFeet", "Emote_FancyFeet_CT", "athena_emotes_lankylegs_loop_02", true);
		case 61:
			CreateEmote(target, "Emote_FlossDance", "none", "athena_emote_floss_music", true);
		case 62:
			CreateEmote(target, "Emote_FlippnSexy", "none", "Emote_FlippnSexy", false);
		case 63:
			CreateEmote(target, "Emote_Fresh", "none", "athena_emote_fresh_music", true);
		case 64:
			CreateEmote(target, "Emote_GrooveJam", "none", "emote_groove_jam_a", true);
		case 65:
			CreateEmote(target, "Emote_guitar", "none", "br_emote_shred_guitar_mix_03_loop", true);
		case 66:
			CreateEmote(target, "Emote_Hillbilly_Shuffle_Intro", "Emote_Hillbilly_Shuffle", "Emote_Hillbilly_Shuffle", true);
		case 67:
			CreateEmote(target, "Emote_Hiphop_01", "Emote_Hip_Hop", "s5_hiphop_breakin_132bmp_loop", true);
		case 68:
			CreateEmote(target, "Emote_Hula_Start", "Emote_Hula", "emote_hula_01", true);
		case 69:
			CreateEmote(target, "Emote_InfiniDab_Intro", "Emote_InfiniDab_Loop", "athena_emote_infinidab", true);
		case 70:
			CreateEmote(target, "Emote_Intensity_Start", "Emote_Intensity_Loop", "emote_Intensity", true);
		case 71:
			CreateEmote(target, "Emote_IrishJig_Start", "Emote_IrishJig", "emote_irish_jig_foley_music_loop", true);
		case 72:
			CreateEmote(target, "Emote_KoreanEagle", "none", "Athena_Music_Emotes_KoreanEagle", true);
		case 73:
			CreateEmote(target, "Emote_Kpop_02", "none", "emote_kpop_01", true);
		case 74:
			CreateEmote(target, "Emote_LivingLarge", "none", "emote_LivingLarge_A", true);
		case 75:
			CreateEmote(target, "Emote_Maracas", "none", "emote_samba_new_B", true);
		case 76:
			CreateEmote(target, "Emote_PopLock", "none", "Athena_Emote_PopLock", true);
		case 77:
			CreateEmote(target, "Emote_PopRock", "none", "Emote_PopRock_01", true);
		case 78:
			CreateEmote(target, "Emote_RobotDance", "none", "athena_emote_robot_music", true);
		case 79:
			CreateEmote(target, "Emote_T-Rex", "none", "Emote_Dino_Complete", false);
		case 80:
			CreateEmote(target, "Emote_TechnoZombie", "none", "athena_emote_founders_music", true);
		case 81:
			CreateEmote(target, "Emote_Twist", "none", "athena_emotes_music_twist", true);
		case 82:
			CreateEmote(target, "Emote_WarehouseDance_Start", "Emote_WarehouseDance_Loop", "Emote_Warehouse", true);
		case 83:
			CreateEmote(target, "Emote_Wiggle", "none", "Wiggle_Music_Loop", true);
		case 84:
			CreateEmote(target, "Emote_Youre_Awesome", "none", "youre_awesome_emote_music", false);
		default:
			CPrintToChat(client, "%t %t", "TAG", "INVALID_EMOTE_ID");
	}
}

void WeaponBlock(int client)
{
	SDKHook(client, SDKHook_WeaponCanUse, WeaponCanUseSwitch);
	SDKHook(client, SDKHook_WeaponSwitch, WeaponCanUseSwitch);

	if (g_cvarHideWeapons.BoolValue)
		SDKHook(client, SDKHook_PostThinkPost, OnPostThinkPost);

	int iEnt = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if (iEnt != -1)
	{
		g_iWeaponHandEnt[client] = EntIndexToEntRef(iEnt);

		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", -1);
	}
}

void WeaponUnblock(int client)
{
	SDKUnhook(client, SDKHook_WeaponCanUse, WeaponCanUseSwitch);
	SDKUnhook(client, SDKHook_WeaponSwitch, WeaponCanUseSwitch);

	// Even if are not activated, there will be no errors
	SDKUnhook(client, SDKHook_PostThinkPost, OnPostThinkPost);

	if (GetEmotePeople() == 0)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && g_bHooked[i])
			{
				SDKUnhook(i, SDKHook_SetTransmit, SetTransmit);
				g_bHooked[i] = false;
			}
		}
	}

	if (IsPlayerAlive(client) && g_iWeaponHandEnt[client] != INVALID_ENT_REFERENCE)
	{
		int iEnt = EntRefToEntIndex(g_iWeaponHandEnt[client]);
		if (iEnt != INVALID_ENT_REFERENCE)
			SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", iEnt);
	}

	g_iWeaponHandEnt[client] = INVALID_ENT_REFERENCE;
}

Action WeaponCanUseSwitch(int client, int weapon)
{
	return Plugin_Stop;
}

void OnPostThinkPost(int client)
{
	SetEntProp(client, Prop_Send, "m_iAddonBits", 0);
}

public Action SetTransmit(int entity, int client)
{
	if (g_bClientDancing[client] && IsPlayerAlive(client) && GetClientTeam(client) != GetClientTeam(entity))
		return Plugin_Handled;

	return Plugin_Continue;
}

void SetCam(int client)
{
	if (g_iEngine == Engine_Left4Dead)
	{
		SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", 0);
		SetEntProp(client, Prop_Send, "m_iObserverMode", 1);
		SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 0);
	}
	else if (g_iEngine == Engine_Left4Dead2)
		SetEntPropFloat(client, Prop_Send, "m_TimeForceExternalView", 99999.3);

	SetEntProp(client, Prop_Send, "m_iHideHUD", GetEntProp(client, Prop_Send, "m_iHideHUD") | HIDEHUD_CROSSHAIR);
}

void ResetCam(int client)
{
	if (g_iEngine == Engine_Left4Dead)
	{
		SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", -1);
		SetEntProp(client, Prop_Send, "m_iObserverMode", 0);
		SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 1);
	}
	else if (g_iEngine == Engine_Left4Dead2)
		SetEntPropFloat(client, Prop_Send, "m_TimeForceExternalView", 0.0);

	SetEntProp(client, Prop_Send, "m_iHideHUD", GetEntProp(client, Prop_Send, "m_iHideHUD") & ~HIDEHUD_CROSSHAIR);
}

Action ResetCooldown(Handle timer, any client)
{
	CooldownTimers[client] = null;
	return Plugin_Stop;
}