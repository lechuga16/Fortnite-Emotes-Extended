#if defined _menu_included
	#endinput
#endif
#define _menu_included

/*****************************************************************
			F O R W A R D   P U B L I C S
*****************************************************************/

void OnPluginStart_menu()
{
	if (g_bLateload)
		g_bAdminMenu = LibraryExists("adminmenu");

	TopMenu topmenu;
	if (!g_bAdminMenu || ((topmenu = GetAdminTopMenu()) == null))
		return;

	OnAdminMenuReady(topmenu);
}

/*****************************************************************
			F O R W A R D   P L U G I N S
*****************************************************************/
public void OnAdminMenuReady(Handle aTopMenu)
{
	TopMenu topmenu = TopMenu.FromHandle(aTopMenu);

	/* Block us from being called twice */
	if (topmenu == hTopMenu)
		return;

	/* Save the Handle */
	hTopMenu					  = topmenu;

	/* Find the "Player Commands" category */
	TopMenuObject player_commands = hTopMenu.FindCategory(ADMINMENU_PLAYERCOMMANDS);

	if (player_commands != INVALID_TOPMENUOBJECT)
		hTopMenu.AddItem("sm_setemotes", AdminMenu_Emotes, player_commands, "sm_setemotes", ADMFLAG_SLAY);
}

void AdminMenu_Emotes(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
		Format(buffer, maxlength, "%T", "EMOTE_PLAYER", param);
	else if (action == TopMenuAction_SelectOption)
		DisplayEmotePlayersMenu(param);
}

/*****************************************************************
			P L U G I N   F U N C T I O N S
*****************************************************************/

Action Menu_Dance(int client)
{
	Menu menu = new Menu(MenuHandler1);

	char title[65];
	Format(title, sizeof(title), "%T:", "TITLE_MAIM_MENU", client);
	menu.SetTitle(title);

	AddTranslatedMenuItem(menu, "", "RANDOM_EMOTE", client);
	AddTranslatedMenuItem(menu, "", "RANDOM_DANCE", client);
	AddTranslatedMenuItem(menu, "", "EMOTES_LIST", client);
	AddTranslatedMenuItem(menu, "", "DANCES_LIST", client);

	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

int MenuHandler1(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			int
				client = param1,
				item   = param2;

			switch (item)
			{
				case 0:
				{
					RandomEmote(client);
					Menu_Dance(client);
				}
				case 1:
				{
					RandomDance(client);
					Menu_Dance(client);
				}
				case 2:
					EmotesMenu(client);
				case 3:
					DancesMenu(client);
			}
		}
		case MenuAction_End:
			delete menu;
	}
	return 0;
}

Action EmotesMenu(int client)
{
	char sBuffer[32];
	g_cvarFlagEmotesMenu.GetString(sBuffer, sizeof(sBuffer));

	if (!CheckAdminFlags(client, ReadFlagString(sBuffer)))
	{
		CPrintToChat(client, "%t %t", "TAG", "NO_EMOTES_ACCESS_FLAG");
		return Plugin_Handled;
	}

	Menu menu = new Menu(MenuHandlerEmotes);

	char title[65];
	Format(title, sizeof(title), "%T:", "TITLE_EMOTES_MENU", client);
	menu.SetTitle(title);

	AddTranslatedMenuItem(menu, "1", "Emote_Fonzie_Pistol", client);
	AddTranslatedMenuItem(menu, "2", "Emote_Bring_It_On", client);
	AddTranslatedMenuItem(menu, "3", "Emote_ThumbsDown", client);
	AddTranslatedMenuItem(menu, "4", "Emote_ThumbsUp", client);
	AddTranslatedMenuItem(menu, "5", "Emote_Celebration_Loop", client);
	AddTranslatedMenuItem(menu, "6", "Emote_BlowKiss", client);
	AddTranslatedMenuItem(menu, "7", "Emote_Calculated", client);
	AddTranslatedMenuItem(menu, "8", "Emote_Confused", client);
	AddTranslatedMenuItem(menu, "9", "Emote_Chug", client);
	AddTranslatedMenuItem(menu, "10", "Emote_Cry", client);
	AddTranslatedMenuItem(menu, "11", "Emote_DustingOffHands", client);
	AddTranslatedMenuItem(menu, "12", "Emote_DustOffShoulders", client);
	AddTranslatedMenuItem(menu, "13", "Emote_Facepalm", client);
	AddTranslatedMenuItem(menu, "14", "Emote_Fishing", client);
	AddTranslatedMenuItem(menu, "15", "Emote_Flex", client);
	AddTranslatedMenuItem(menu, "16", "Emote_golfclap", client);
	AddTranslatedMenuItem(menu, "17", "Emote_HandSignals", client);
	AddTranslatedMenuItem(menu, "18", "Emote_HeelClick", client);
	AddTranslatedMenuItem(menu, "19", "Emote_Hotstuff", client);
	AddTranslatedMenuItem(menu, "20", "Emote_IBreakYou", client);
	AddTranslatedMenuItem(menu, "21", "Emote_IHeartYou", client);
	AddTranslatedMenuItem(menu, "22", "Emote_Kung-Fu_Salute", client);
	AddTranslatedMenuItem(menu, "23", "Emote_Laugh", client);
	AddTranslatedMenuItem(menu, "24", "Emote_Luchador", client);
	AddTranslatedMenuItem(menu, "25", "Emote_Make_It_Rain", client);
	AddTranslatedMenuItem(menu, "26", "Emote_NotToday", client);
	AddTranslatedMenuItem(menu, "27", "Emote_RockPaperScissor_Paper", client);
	AddTranslatedMenuItem(menu, "28", "Emote_RockPaperScissor_Rock", client);
	AddTranslatedMenuItem(menu, "29", "Emote_RockPaperScissor_Scissor", client);
	AddTranslatedMenuItem(menu, "30", "Emote_Salt", client);
	AddTranslatedMenuItem(menu, "31", "Emote_Salute", client);
	AddTranslatedMenuItem(menu, "32", "Emote_SmoothDrive", client);
	AddTranslatedMenuItem(menu, "33", "Emote_Snap", client);
	AddTranslatedMenuItem(menu, "34", "Emote_StageBow", client);
	AddTranslatedMenuItem(menu, "35", "Emote_Wave2", client);
	AddTranslatedMenuItem(menu, "36", "Emote_Yeet", client);

	menu.ExitButton		= true;
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

int MenuHandlerEmotes(Menu menu, MenuAction action, int client, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char info[16];
			if (menu.GetItem(param2, info, sizeof(info)))
			{
				int iParam2 = StringToInt(info);

				switch (iParam2)
				{
					case 1:
						CreateEmote(client, "Emote_Fonzie_Pistol", "none", "", false);
					case 2:
						CreateEmote(client, "Emote_Bring_It_On", "none", "", false);
					case 3:
						CreateEmote(client, "Emote_ThumbsDown", "none", "", false);
					case 4:
						CreateEmote(client, "Emote_ThumbsUp", "none", "", false);
					case 5:
						CreateEmote(client, "Emote_Celebration_Loop", "", "", false);
					case 6:
						CreateEmote(client, "Emote_BlowKiss", "none", "", false);
					case 7:
						CreateEmote(client, "Emote_Calculated", "none", "", false);
					case 8:
						CreateEmote(client, "Emote_Confused", "none", "", false);
					case 9:
						CreateEmote(client, "Emote_Chug", "none", "", false);
					case 10:
						CreateEmote(client, "Emote_Cry", "none", "emote_cry", false);
					case 11:
						CreateEmote(client, "Emote_DustingOffHands", "none", "athena_emote_bandofthefort_music", true);
					case 12:
						CreateEmote(client, "Emote_DustOffShoulders", "none", "athena_emote_hot_music", true);
					case 13:
						CreateEmote(client, "Emote_Facepalm", "none", "athena_emote_facepalm_foley_01", false);
					case 14:
						CreateEmote(client, "Emote_Fishing", "none", "Athena_Emotes_OnTheHook_02", false);
					case 15:
						CreateEmote(client, "Emote_Flex", "none", "", false);
					case 16:
						CreateEmote(client, "Emote_golfclap", "none", "", false);
					case 17:
						CreateEmote(client, "Emote_HandSignals", "none", "", false);
					case 18:
						CreateEmote(client, "Emote_HeelClick", "none", "Emote_HeelClick", false);
					case 19:
						CreateEmote(client, "Emote_Hotstuff", "none", "Emote_Hotstuff", false);
					case 20:
						CreateEmote(client, "Emote_IBreakYou", "none", "", false);
					case 21:
						CreateEmote(client, "Emote_IHeartYou", "none", "", false);
					case 22:
						CreateEmote(client, "Emote_Kung-Fu_Salute", "none", "", false);
					case 23:
						CreateEmote(client, "Emote_Laugh", "Emote_Laugh_CT", "emote_laugh_01.mp3", false);
					case 24:
						CreateEmote(client, "Emote_Luchador", "none", "Emote_Luchador", false);
					case 25:
						CreateEmote(client, "Emote_Make_It_Rain", "none", "athena_emote_makeitrain_music", false);
					case 26:
						CreateEmote(client, "Emote_NotToday", "none", "", false);
					case 27:
						CreateEmote(client, "Emote_RockPaperScissor_Paper", "none", "", false);
					case 28:
						CreateEmote(client, "Emote_RockPaperScissor_Rock", "none", "", false);
					case 29:
						CreateEmote(client, "Emote_RockPaperScissor_Scissor", "none", "", false);
					case 30:
						CreateEmote(client, "Emote_Salt", "none", "", false);
					case 31:
						CreateEmote(client, "Emote_Salute", "none", "athena_emote_salute_foley_01", false);
					case 32:
						CreateEmote(client, "Emote_SmoothDrive", "none", "", false);
					case 33:
						CreateEmote(client, "Emote_Snap", "none", "Emote_Snap1", false);
					case 34:
						CreateEmote(client, "Emote_StageBow", "none", "emote_stagebow", false);
					case 35:
						CreateEmote(client, "Emote_Wave2", "none", "", false);
					case 36:
						CreateEmote(client, "Emote_Yeet", "none", "Emote_Yeet", false);
				}
			}
			menu.DisplayAt(client, GetMenuSelectionPosition(), MENU_TIME_FOREVER);
		}
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_ExitBack)
				Menu_Dance(client);
		}
	}
	return 0;
}

Action DancesMenu(int client)
{
	char sBuffer[32];
	g_cvarFlagDancesMenu.GetString(sBuffer, sizeof(sBuffer));

	if (!CheckAdminFlags(client, ReadFlagString(sBuffer)))
	{
		CPrintToChat(client, "%t %t", "TAG", "NO_DANCES_ACCESS_FLAG");
		return Plugin_Handled;
	}
	Menu menu = new Menu(MenuHandlerDances);

	char title[65];
	Format(title, sizeof(title), "%T:", "TITLE_DANCES_MENU", client);
	menu.SetTitle(title);

	AddTranslatedMenuItem(menu, "1", "DanceMoves", client);
	AddTranslatedMenuItem(menu, "2", "Emote_Mask_Off_Intro", client);
	AddTranslatedMenuItem(menu, "3", "Emote_Zippy_Dance", client);
	AddTranslatedMenuItem(menu, "4", "ElectroShuffle", client);
	AddTranslatedMenuItem(menu, "5", "Emote_AerobicChamp", client);
	AddTranslatedMenuItem(menu, "6", "Emote_Bendy", client);
	AddTranslatedMenuItem(menu, "7", "Emote_BandOfTheFort", client);
	AddTranslatedMenuItem(menu, "8", "Emote_Boogie_Down_Intro", client);
	AddTranslatedMenuItem(menu, "9", "Emote_Capoeira", client);
	AddTranslatedMenuItem(menu, "10", "Emote_Charleston", client);
	AddTranslatedMenuItem(menu, "11", "Emote_Chicken", client);
	AddTranslatedMenuItem(menu, "12", "Emote_Dance_NoBones", client);
	AddTranslatedMenuItem(menu, "13", "Emote_Dance_Shoot", client);
	AddTranslatedMenuItem(menu, "14", "Emote_Dance_SwipeIt", client);
	AddTranslatedMenuItem(menu, "15", "Emote_Dance_Disco_T3", client);
	AddTranslatedMenuItem(menu, "16", "Emote_DG_Disco", client);
	AddTranslatedMenuItem(menu, "17", "Emote_Dance_Worm", client);
	AddTranslatedMenuItem(menu, "18", "Emote_Dance_Loser", client);
	AddTranslatedMenuItem(menu, "19", "Emote_Dance_Breakdance", client);
	AddTranslatedMenuItem(menu, "20", "Emote_Dance_Pump", client);
	AddTranslatedMenuItem(menu, "21", "Emote_Dance_RideThePony", client);
	AddTranslatedMenuItem(menu, "22", "Emote_Dab", client);
	AddTranslatedMenuItem(menu, "23", "Emote_EasternBloc_Start", client);
	AddTranslatedMenuItem(menu, "24", "Emote_FancyFeet", client);
	AddTranslatedMenuItem(menu, "25", "Emote_FlossDance", client);
	AddTranslatedMenuItem(menu, "26", "Emote_FlippnSexy", client);
	AddTranslatedMenuItem(menu, "27", "Emote_Fresh", client);
	AddTranslatedMenuItem(menu, "28", "Emote_GrooveJam", client);
	AddTranslatedMenuItem(menu, "29", "Emote_guitar", client);
	AddTranslatedMenuItem(menu, "30", "Emote_Hillbilly_Shuffle_Intro", client);
	AddTranslatedMenuItem(menu, "31", "Emote_Hiphop_01", client);
	AddTranslatedMenuItem(menu, "32", "Emote_Hula_Start", client);
	AddTranslatedMenuItem(menu, "33", "Emote_InfiniDab_Intro", client);
	AddTranslatedMenuItem(menu, "34", "Emote_Intensity_Start", client);
	AddTranslatedMenuItem(menu, "35", "Emote_IrishJig_Start", client);
	AddTranslatedMenuItem(menu, "36", "Emote_KoreanEagle", client);
	AddTranslatedMenuItem(menu, "37", "Emote_Kpop_02", client);
	AddTranslatedMenuItem(menu, "38", "Emote_LivingLarge", client);
	AddTranslatedMenuItem(menu, "39", "Emote_Maracas", client);
	AddTranslatedMenuItem(menu, "40", "Emote_PopLock", client);
	AddTranslatedMenuItem(menu, "41", "Emote_PopRock", client);
	AddTranslatedMenuItem(menu, "42", "Emote_RobotDance", client);
	AddTranslatedMenuItem(menu, "43", "Emote_T-Rex", client);
	AddTranslatedMenuItem(menu, "44", "Emote_TechnoZombie", client);
	AddTranslatedMenuItem(menu, "45", "Emote_Twist", client);
	AddTranslatedMenuItem(menu, "46", "Emote_WarehouseDance_Start", client);
	AddTranslatedMenuItem(menu, "47", "Emote_Wiggle", client);
	AddTranslatedMenuItem(menu, "48", "Emote_Youre_Awesome", client);

	menu.ExitButton		= true;
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

int MenuHandlerDances(Menu menu, MenuAction action, int client, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char info[16];
			if (menu.GetItem(param2, info, sizeof(info)))
			{
				int iParam2 = StringToInt(info);

				switch (iParam2)
				{
					case 1:
						CreateEmote(client, "DanceMoves", "none", "ninja_dance_01", false);
					case 2:
						CreateEmote(client, "Emote_Mask_Off_Intro", "Emote_Mask_Off_Loop", "Hip_Hop_Good_Vibes_Mix_01_Loop", true);
					case 3:
						CreateEmote(client, "Emote_Zippy_Dance", "none", "emote_zippy_A", true);
					case 4:
						CreateEmote(client, "ElectroShuffle", "none", "athena_emote_electroshuffle_music", true);
					case 5:
						CreateEmote(client, "Emote_AerobicChamp", "none", "emote_aerobics_01", true);
					case 6:
						CreateEmote(client, "Emote_Bendy", "none", "athena_music_emotes_bendy", true);
					case 7:
						CreateEmote(client, "Emote_BandOfTheFort", "none", "athena_emote_bandofthefort_music", true);
					case 8:
						CreateEmote(client, "Emote_Boogie_Down_Intro", "Emote_Boogie_Down", "emote_boogiedown", true);
					case 9:
						CreateEmote(client, "Emote_Capoeira", "none", "emote_capoeira", false);
					case 10:
						CreateEmote(client, "Emote_Charleston", "none", "athena_emote_flapper_music", true);
					case 11:
						CreateEmote(client, "Emote_Chicken", "none", "athena_emote_chicken_foley_01", true);
					case 12:
						CreateEmote(client, "Emote_Dance_NoBones", "none", "athena_emote_music_boneless", true);
					case 13:
						CreateEmote(client, "Emote_Dance_Shoot", "none", "athena_emotes_music_shoot_v7", true);
					case 14:
						CreateEmote(client, "Emote_Dance_SwipeIt", "none", "Athena_Emotes_Music_SwipeIt", true);
					case 15:
						CreateEmote(client, "Emote_Dance_Disco_T3", "none", "athena_emote_disco", true);
					case 16:
						CreateEmote(client, "Emote_DG_Disco", "none", "athena_emote_disco", true);
					case 17:
						CreateEmote(client, "Emote_Dance_Worm", "none", "athena_emote_worm_music", false);
					case 18:
						CreateEmote(client, "Emote_Dance_Loser", "Emote_Dance_Loser_CT", "athena_music_emotes_takethel", true);
					case 19:
						CreateEmote(client, "Emote_Dance_Breakdance", "none", "athena_emote_breakdance_music", false);
					case 20:
						CreateEmote(client, "Emote_Dance_Pump", "none", "Emote_Dance_Pump", true);
					case 21:
						CreateEmote(client, "Emote_Dance_RideThePony", "none", "athena_emote_ridethepony_music_01", false);
					case 22:
						CreateEmote(client, "Emote_Dab", "none", "", false);
					case 23:
						CreateEmote(client, "Emote_EasternBloc_Start", "Emote_EasternBloc", "eastern_bloc_musc_setup_d", true);
					case 24:
						CreateEmote(client, "Emote_FancyFeet", "Emote_FancyFeet_CT", "athena_emotes_lankylegs_loop_02", true);
					case 25:
						CreateEmote(client, "Emote_FlossDance", "none", "athena_emote_floss_music", true);
					case 26:
						CreateEmote(client, "Emote_FlippnSexy", "none", "Emote_FlippnSexy", false);
					case 27:
						CreateEmote(client, "Emote_Fresh", "none", "athena_emote_fresh_music", true);
					case 28:
						CreateEmote(client, "Emote_GrooveJam", "none", "emote_groove_jam_a", true);
					case 29:
						CreateEmote(client, "Emote_guitar", "none", "br_emote_shred_guitar_mix_03_loop", true);
					case 30:
						CreateEmote(client, "Emote_Hillbilly_Shuffle_Intro", "Emote_Hillbilly_Shuffle", "Emote_Hillbilly_Shuffle", true);
					case 31:
						CreateEmote(client, "Emote_Hiphop_01", "Emote_Hip_Hop", "s5_hiphop_breakin_132bmp_loop", true);
					case 32:
						CreateEmote(client, "Emote_Hula_Start", "Emote_Hula", "emote_hula_01", true);
					case 33:
						CreateEmote(client, "Emote_InfiniDab_Intro", "Emote_InfiniDab_Loop", "athena_emote_infinidab", true);
					case 34:
						CreateEmote(client, "Emote_Intensity_Start", "Emote_Intensity_Loop", "emote_Intensity", true);
					case 35:
						CreateEmote(client, "Emote_IrishJig_Start", "Emote_IrishJig", "emote_irish_jig_foley_music_loop", true);
					case 36:
						CreateEmote(client, "Emote_KoreanEagle", "none", "Athena_Music_Emotes_KoreanEagle", true);
					case 37:
						CreateEmote(client, "Emote_Kpop_02", "none", "emote_kpop_01", true);
					case 38:
						CreateEmote(client, "Emote_LivingLarge", "none", "emote_LivingLarge_A", true);
					case 39:
						CreateEmote(client, "Emote_Maracas", "none", "emote_samba_new_B", true);
					case 40:
						CreateEmote(client, "Emote_PopLock", "none", "Athena_Emote_PopLock", true);
					case 41:
						CreateEmote(client, "Emote_PopRock", "none", "Emote_PopRock_01", true);
					case 42:
						CreateEmote(client, "Emote_RobotDance", "none", "athena_emote_robot_music", true);
					case 43:
						CreateEmote(client, "Emote_T-Rex", "none", "Emote_Dino_Complete", false);
					case 44:
						CreateEmote(client, "Emote_TechnoZombie", "none", "athena_emote_founders_music", true);
					case 45:
						CreateEmote(client, "Emote_Twist", "none", "athena_emotes_music_twist", true);
					case 46:
						CreateEmote(client, "Emote_WarehouseDance_Start", "Emote_WarehouseDance_Loop", "Emote_Warehouse", true);
					case 47:
						CreateEmote(client, "Emote_Wiggle", "none", "Wiggle_Music_Loop", true);
					case 48:
						CreateEmote(client, "Emote_Youre_Awesome", "none", "youre_awesome_emote_music", false);
				}
			}
			menu.DisplayAt(client, GetMenuSelectionPosition(), MENU_TIME_FOREVER);
		}
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_ExitBack)
				Menu_Dance(client);
		}
	}
	return 0;
}

void RandomEmote(int i)
{
	char sBuffer[32];
	g_cvarFlagEmotesMenu.GetString(sBuffer, sizeof(sBuffer));

	if (!CheckAdminFlags(i, ReadFlagString(sBuffer)))
	{
		CPrintToChat(i, "%t %t", "TAG", "NO_EMOTES_ACCESS_FLAG");
		return;
	}

	int number = GetRandomInt(1, 36);

	switch (number)
	{
		case 1:
			CreateEmote(i, "Emote_Fonzie_Pistol", "none", "", false);
		case 2:
			CreateEmote(i, "Emote_Bring_It_On", "none", "", false);
		case 3:
			CreateEmote(i, "Emote_ThumbsDown", "none", "", false);
		case 4:
			CreateEmote(i, "Emote_ThumbsUp", "none", "", false);
		case 5:
			CreateEmote(i, "Emote_Celebration_Loop", "", "", false);
		case 6:
			CreateEmote(i, "Emote_BlowKiss", "none", "", false);
		case 7:
			CreateEmote(i, "Emote_Calculated", "none", "", false);
		case 8:
			CreateEmote(i, "Emote_Confused", "none", "", false);
		case 9:
			CreateEmote(i, "Emote_Chug", "none", "", false);
		case 10:
			CreateEmote(i, "Emote_Cry", "none", "emote_cry", false);
		case 11:
			CreateEmote(i, "Emote_DustingOffHands", "none", "athena_emote_bandofthefort_music", true);
		case 12:
			CreateEmote(i, "Emote_DustOffShoulders", "none", "athena_emote_hot_music", true);
		case 13:
			CreateEmote(i, "Emote_Facepalm", "none", "athena_emote_facepalm_foley_01", false);
		case 14:
			CreateEmote(i, "Emote_Fishing", "none", "Athena_Emotes_OnTheHook_02", false);
		case 15:
			CreateEmote(i, "Emote_Flex", "none", "", false);
		case 16:
			CreateEmote(i, "Emote_golfclap", "none", "", false);
		case 17:
			CreateEmote(i, "Emote_HandSignals", "none", "", false);
		case 18:
			CreateEmote(i, "Emote_HeelClick", "none", "Emote_HeelClick", false);
		case 19:
			CreateEmote(i, "Emote_Hotstuff", "none", "Emote_Hotstuff", false);
		case 20:
			CreateEmote(i, "Emote_IBreakYou", "none", "", false);
		case 21:
			CreateEmote(i, "Emote_IHeartYou", "none", "", false);
		case 22:
			CreateEmote(i, "Emote_Kung-Fu_Salute", "none", "", false);
		case 23:
			CreateEmote(i, "Emote_Laugh", "Emote_Laugh_CT", "emote_laugh_01.mp3", false);
		case 24:
			CreateEmote(i, "Emote_Luchador", "none", "Emote_Luchador", false);
		case 25:
			CreateEmote(i, "Emote_Make_It_Rain", "none", "athena_emote_makeitrain_music", false);
		case 26:
			CreateEmote(i, "Emote_NotToday", "none", "", false);
		case 27:
			CreateEmote(i, "Emote_RockPaperScissor_Paper", "none", "", false);
		case 28:
			CreateEmote(i, "Emote_RockPaperScissor_Rock", "none", "", false);
		case 29:
			CreateEmote(i, "Emote_RockPaperScissor_Scissor", "none", "", false);
		case 30:
			CreateEmote(i, "Emote_Salt", "none", "", false);
		case 31:
			CreateEmote(i, "Emote_Salute", "none", "athena_emote_salute_foley_01", false);
		case 32:
			CreateEmote(i, "Emote_SmoothDrive", "none", "", false);
		case 33:
			CreateEmote(i, "Emote_Snap", "none", "Emote_Snap1", false);
		case 34:
			CreateEmote(i, "Emote_StageBow", "none", "emote_stagebow", false);
		case 35:
			CreateEmote(i, "Emote_Wave2", "none", "", false);
		case 36:
			CreateEmote(i, "Emote_Yeet", "none", "Emote_Yeet", false);
	}
}

void RandomDance(int i)
{
	char sBuffer[32];
	g_cvarFlagDancesMenu.GetString(sBuffer, sizeof(sBuffer));

	if (!CheckAdminFlags(i, ReadFlagString(sBuffer)))
	{
		CPrintToChat(i, "%t %t", "TAG", "NO_DANCES_ACCESS_FLAG");
		return;
	}
	int number = GetRandomInt(1, 48);

	switch (number)
	{
		case 1:
			CreateEmote(i, "DanceMoves", "none", "ninja_dance_01", false);
		case 2:
			CreateEmote(i, "Emote_Mask_Off_Intro", "Emote_Mask_Off_Loop", "Hip_Hop_Good_Vibes_Mix_01_Loop", true);
		case 3:
			CreateEmote(i, "Emote_Zippy_Dance", "none", "emote_zippy_A", true);
		case 4:
			CreateEmote(i, "ElectroShuffle", "none", "athena_emote_electroshuffle_music", true);
		case 5:
			CreateEmote(i, "Emote_AerobicChamp", "none", "emote_aerobics_01", true);
		case 6:
			CreateEmote(i, "Emote_Bendy", "none", "athena_music_emotes_bendy", true);
		case 7:
			CreateEmote(i, "Emote_BandOfTheFort", "none", "athena_emote_bandofthefort_music", true);
		case 8:
			CreateEmote(i, "Emote_Boogie_Down_Intro", "Emote_Boogie_Down", "emote_boogiedown", true);
		case 9:
			CreateEmote(i, "Emote_Capoeira", "none", "emote_capoeira", false);
		case 10:
			CreateEmote(i, "Emote_Charleston", "none", "athena_emote_flapper_music", true);
		case 11:
			CreateEmote(i, "Emote_Chicken", "none", "athena_emote_chicken_foley_01", true);
		case 12:
			CreateEmote(i, "Emote_Dance_NoBones", "none", "athena_emote_music_boneless", true);
		case 13:
			CreateEmote(i, "Emote_Dance_Shoot", "none", "athena_emotes_music_shoot_v7", true);
		case 14:
			CreateEmote(i, "Emote_Dance_SwipeIt", "none", "Athena_Emotes_Music_SwipeIt", true);
		case 15:
			CreateEmote(i, "Emote_Dance_Disco_T3", "none", "athena_emote_disco", true);
		case 16:
			CreateEmote(i, "Emote_DG_Disco", "none", "athena_emote_disco", true);
		case 17:
			CreateEmote(i, "Emote_Dance_Worm", "none", "athena_emote_worm_music", false);
		case 18:
			CreateEmote(i, "Emote_Dance_Loser", "Emote_Dance_Loser_CT", "athena_music_emotes_takethel", true);
		case 19:
			CreateEmote(i, "Emote_Dance_Breakdance", "none", "athena_emote_breakdance_music", false);
		case 20:
			CreateEmote(i, "Emote_Dance_Pump", "none", "Emote_Dance_Pump", true);
		case 21:
			CreateEmote(i, "Emote_Dance_RideThePony", "none", "athena_emote_ridethepony_music_01", false);
		case 22:
			CreateEmote(i, "Emote_Dab", "none", "", false);
		case 23:
			CreateEmote(i, "Emote_EasternBloc_Start", "Emote_EasternBloc", "eastern_bloc_musc_setup_d", true);
		case 24:
			CreateEmote(i, "Emote_FancyFeet", "Emote_FancyFeet_CT", "athena_emotes_lankylegs_loop_02", true);
		case 25:
			CreateEmote(i, "Emote_FlossDance", "none", "athena_emote_floss_music", true);
		case 26:
			CreateEmote(i, "Emote_FlippnSexy", "none", "Emote_FlippnSexy", false);
		case 27:
			CreateEmote(i, "Emote_Fresh", "none", "athena_emote_fresh_music", true);
		case 28:
			CreateEmote(i, "Emote_GrooveJam", "none", "emote_groove_jam_a", true);
		case 29:
			CreateEmote(i, "Emote_guitar", "none", "br_emote_shred_guitar_mix_03_loop", true);
		case 30:
			CreateEmote(i, "Emote_Hillbilly_Shuffle_Intro", "Emote_Hillbilly_Shuffle", "Emote_Hillbilly_Shuffle", true);
		case 31:
			CreateEmote(i, "Emote_Hiphop_01", "Emote_Hip_Hop", "s5_hiphop_breakin_132bmp_loop", true);
		case 32:
			CreateEmote(i, "Emote_Hula_Start", "Emote_Hula", "emote_hula_01", true);
		case 33:
			CreateEmote(i, "Emote_InfiniDab_Intro", "Emote_InfiniDab_Loop", "athena_emote_infinidab", true);
		case 34:
			CreateEmote(i, "Emote_Intensity_Start", "Emote_Intensity_Loop", "emote_Intensity", true);
		case 35:
			CreateEmote(i, "Emote_IrishJig_Start", "Emote_IrishJig", "emote_irish_jig_foley_music_loop", true);
		case 36:
			CreateEmote(i, "Emote_KoreanEagle", "none", "Athena_Music_Emotes_KoreanEagle", true);
		case 37:
			CreateEmote(i, "Emote_Kpop_02", "none", "emote_kpop_01", true);
		case 38:
			CreateEmote(i, "Emote_LivingLarge", "none", "emote_LivingLarge_A", true);
		case 39:
			CreateEmote(i, "Emote_Maracas", "none", "emote_samba_new_B", true);
		case 40:
			CreateEmote(i, "Emote_PopLock", "none", "Athena_Emote_PopLock", true);
		case 41:
			CreateEmote(i, "Emote_PopRock", "none", "Emote_PopRock_01", true);
		case 42:
			CreateEmote(i, "Emote_RobotDance", "none", "athena_emote_robot_music", true);
		case 43:
			CreateEmote(i, "Emote_T-Rex", "none", "Emote_Dino_Complete", false);
		case 44:
			CreateEmote(i, "Emote_TechnoZombie", "none", "athena_emote_founders_music", true);
		case 45:
			CreateEmote(i, "Emote_Twist", "none", "athena_emotes_music_twist", true);
		case 46:
			CreateEmote(i, "Emote_WarehouseDance_Start", "Emote_WarehouseDance_Loop", "Emote_Warehouse", true);
		case 47:
			CreateEmote(i, "Emote_Wiggle", "none", "Wiggle_Music_Loop", true);
		case 48:
			CreateEmote(i, "Emote_Youre_Awesome", "none", "youre_awesome_emote_music", false);
	}
}

void DisplayEmotePlayersMenu(int client)
{
	Menu menu = new Menu(MenuHandler_EmotePlayers);

	char title[65];
	Format(title, sizeof(title), "%T:", "EMOTE_PLAYER", client);
	menu.SetTitle(title);
	menu.ExitBackButton = true;

	AddTargetsToMenu(menu, client, true, true);

	menu.Display(client, MENU_TIME_FOREVER);
}

int MenuHandler_EmotePlayers(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
		delete menu;
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu)
			hTopMenu.Display(param1, TopMenuPosition_LastCategory);
	}
	else if (action == MenuAction_Select)
	{
		char info[32];
		int	 userid, target;

		menu.GetItem(param2, info, sizeof(info));
		userid = StringToInt(info);

		if ((target = GetClientOfUserId(userid)) == 0)
			CPrintToChat(param1, "%t %t", "TAG", "Player no longer available");
		else if (!CanUserTarget(param1, target))
			CPrintToChat(param1, "%t %t", "TAG", "Unable to target");
		else
		{
			g_EmotesTarget[param1] = userid;
			DisplayEmotesAmountMenu(param1);
			return 0;	 // Return, because we went to a new menu and don't want the re-draw to occur.
		}

		/* Re-draw the menu if they're still valid */
		if (IsClientInGame(param1) && !IsClientInKickQueue(param1))
			DisplayEmotePlayersMenu(param1);
	}

	return 0;
}

void DisplayEmotesAmountMenu(int client)
{
	Menu menu = new Menu(MenuHandler_EmotesAmount);

	char title[65];
	Format(title, sizeof(title), "%T: %N", "SELECT_EMOTE", client, GetClientOfUserId(g_EmotesTarget[client]));
	menu.SetTitle(title);
	menu.ExitBackButton = true;

	AddTranslatedMenuItem(menu, "1", "Emote_Fonzie_Pistol", client);
	AddTranslatedMenuItem(menu, "2", "Emote_Bring_It_On", client);
	AddTranslatedMenuItem(menu, "3", "Emote_ThumbsDown", client);
	AddTranslatedMenuItem(menu, "4", "Emote_ThumbsUp", client);
	AddTranslatedMenuItem(menu, "5", "Emote_Celebration_Loop", client);
	AddTranslatedMenuItem(menu, "6", "Emote_BlowKiss", client);
	AddTranslatedMenuItem(menu, "7", "Emote_Calculated", client);
	AddTranslatedMenuItem(menu, "8", "Emote_Confused", client);
	AddTranslatedMenuItem(menu, "9", "Emote_Chug", client);
	AddTranslatedMenuItem(menu, "10", "Emote_Cry", client);
	AddTranslatedMenuItem(menu, "11", "Emote_DustingOffHands", client);
	AddTranslatedMenuItem(menu, "12", "Emote_DustOffShoulders", client);
	AddTranslatedMenuItem(menu, "13", "Emote_Facepalm", client);
	AddTranslatedMenuItem(menu, "14", "Emote_Fishing", client);
	AddTranslatedMenuItem(menu, "15", "Emote_Flex", client);
	AddTranslatedMenuItem(menu, "16", "Emote_golfclap", client);
	AddTranslatedMenuItem(menu, "17", "Emote_HandSignals", client);
	AddTranslatedMenuItem(menu, "18", "Emote_HeelClick", client);
	AddTranslatedMenuItem(menu, "19", "Emote_Hotstuff", client);
	AddTranslatedMenuItem(menu, "20", "Emote_IBreakYou", client);
	AddTranslatedMenuItem(menu, "21", "Emote_IHeartYou", client);
	AddTranslatedMenuItem(menu, "22", "Emote_Kung-Fu_Salute", client);
	AddTranslatedMenuItem(menu, "23", "Emote_Laugh", client);
	AddTranslatedMenuItem(menu, "24", "Emote_Luchador", client);
	AddTranslatedMenuItem(menu, "25", "Emote_Make_It_Rain", client);
	AddTranslatedMenuItem(menu, "26", "Emote_NotToday", client);
	AddTranslatedMenuItem(menu, "27", "Emote_RockPaperScissor_Paper", client);
	AddTranslatedMenuItem(menu, "28", "Emote_RockPaperScissor_Rock", client);
	AddTranslatedMenuItem(menu, "29", "Emote_RockPaperScissor_Scissor", client);
	AddTranslatedMenuItem(menu, "30", "Emote_Salt", client);
	AddTranslatedMenuItem(menu, "31", "Emote_Salute", client);
	AddTranslatedMenuItem(menu, "32", "Emote_SmoothDrive", client);
	AddTranslatedMenuItem(menu, "33", "Emote_Snap", client);
	AddTranslatedMenuItem(menu, "34", "Emote_StageBow", client);
	AddTranslatedMenuItem(menu, "35", "Emote_Wave2", client);
	AddTranslatedMenuItem(menu, "36", "Emote_Yeet", client);
	AddTranslatedMenuItem(menu, "37", "DanceMoves", client);
	AddTranslatedMenuItem(menu, "38", "Emote_Mask_Off_Intro", client);
	AddTranslatedMenuItem(menu, "39", "Emote_Zippy_Dance", client);
	AddTranslatedMenuItem(menu, "40", "ElectroShuffle", client);
	AddTranslatedMenuItem(menu, "41", "Emote_AerobicChamp", client);
	AddTranslatedMenuItem(menu, "42", "Emote_Bendy", client);
	AddTranslatedMenuItem(menu, "43", "Emote_BandOfTheFort", client);
	AddTranslatedMenuItem(menu, "44", "Emote_Boogie_Down_Intro", client);
	AddTranslatedMenuItem(menu, "45", "Emote_Capoeira", client);
	AddTranslatedMenuItem(menu, "46", "Emote_Charleston", client);
	AddTranslatedMenuItem(menu, "47", "Emote_Chicken", client);
	AddTranslatedMenuItem(menu, "48", "Emote_Dance_NoBones", client);
	AddTranslatedMenuItem(menu, "49", "Emote_Dance_Shoot", client);
	AddTranslatedMenuItem(menu, "50", "Emote_Dance_SwipeIt", client);
	AddTranslatedMenuItem(menu, "51", "Emote_Dance_Disco_T3", client);
	AddTranslatedMenuItem(menu, "52", "Emote_DG_Disco", client);
	AddTranslatedMenuItem(menu, "53", "Emote_Dance_Worm", client);
	AddTranslatedMenuItem(menu, "54", "Emote_Dance_Loser", client);
	AddTranslatedMenuItem(menu, "55", "Emote_Dance_Breakdance", client);
	AddTranslatedMenuItem(menu, "56", "Emote_Dance_Pump", client);
	AddTranslatedMenuItem(menu, "57", "Emote_Dance_RideThePony", client);
	AddTranslatedMenuItem(menu, "58", "Emote_Dab", client);
	AddTranslatedMenuItem(menu, "59", "Emote_EasternBloc_Start", client);
	AddTranslatedMenuItem(menu, "60", "Emote_FancyFeet", client);
	AddTranslatedMenuItem(menu, "61", "Emote_FlossDance", client);
	AddTranslatedMenuItem(menu, "62", "Emote_FlippnSexy", client);
	AddTranslatedMenuItem(menu, "63", "Emote_Fresh", client);
	AddTranslatedMenuItem(menu, "64", "Emote_GrooveJam", client);
	AddTranslatedMenuItem(menu, "65", "Emote_guitar", client);
	AddTranslatedMenuItem(menu, "66", "Emote_Hillbilly_Shuffle_Intro", client);
	AddTranslatedMenuItem(menu, "67", "Emote_Hiphop_01", client);
	AddTranslatedMenuItem(menu, "68", "Emote_Hula_Start", client);
	AddTranslatedMenuItem(menu, "69", "Emote_InfiniDab_Intro", client);
	AddTranslatedMenuItem(menu, "70", "Emote_Intensity_Start", client);
	AddTranslatedMenuItem(menu, "71", "Emote_IrishJig_Start", client);
	AddTranslatedMenuItem(menu, "72", "Emote_KoreanEagle", client);
	AddTranslatedMenuItem(menu, "73", "Emote_Kpop_02", client);
	AddTranslatedMenuItem(menu, "74", "Emote_LivingLarge", client);
	AddTranslatedMenuItem(menu, "75", "Emote_Maracas", client);
	AddTranslatedMenuItem(menu, "76", "Emote_PopLock", client);
	AddTranslatedMenuItem(menu, "77", "Emote_PopRock", client);
	AddTranslatedMenuItem(menu, "78", "Emote_RobotDance", client);
	AddTranslatedMenuItem(menu, "79", "Emote_T-Rex", client);
	AddTranslatedMenuItem(menu, "80", "Emote_TechnoZombie", client);
	AddTranslatedMenuItem(menu, "81", "Emote_Twist", client);
	AddTranslatedMenuItem(menu, "82", "Emote_WarehouseDance_Start", client);
	AddTranslatedMenuItem(menu, "83", "Emote_Wiggle", client);
	AddTranslatedMenuItem(menu, "84", "Emote_Youre_Awesome", client);

	menu.Display(client, MENU_TIME_FOREVER);
}

int MenuHandler_EmotesAmount(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
		delete menu;
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu)
			hTopMenu.Display(param1, TopMenuPosition_LastCategory);
	}
	else if (action == MenuAction_Select)
	{
		char info[32];
		int	 amount;
		int	 target;

		menu.GetItem(param2, info, sizeof(info));
		amount = StringToInt(info);

		if ((target = GetClientOfUserId(g_EmotesTarget[param1])) == 0)
			CPrintToChat(param1, "%t %t", "TAG", "Player no longer available");
		else if (!CanUserTarget(param1, target))
			CPrintToChat(param1, "%t %t", "TAG", "Unable to target");
		else
		{
			char name[MAX_NAME_LENGTH];
			GetClientName(target, name, sizeof(name));

			PerformEmote(param1, target, amount);
		}

		/* Re-draw the menu if they're still valid */
		if (IsClientInGame(param1) && !IsClientInKickQueue(param1))
			DisplayEmotePlayersMenu(param1);
	}
	return 0;
}

void AddTranslatedMenuItem(Menu menu, const char[] opt, const char[] phrase, int client)
{
	char buffer[128];
	Format(buffer, sizeof(buffer), "%T", phrase, client);
	menu.AddItem(opt, buffer);
}
