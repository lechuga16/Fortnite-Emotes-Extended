#if defined _resources_included
 #endinput
#endif
#define _resources_included

/*****************************************************************
			F O R W A R D   P U B L I C S
*****************************************************************/

OnMapStart_Resources()
{
	if(!g_cvarDownloadResources.BoolValue)
		return;
	
	if (g_iEngine == Engine_Left4Dead)
	{
		AddFileToDownloadsTable("models/player/custom_player/foxhound/fortnite_dances_emotes_l4d.mdl");
		AddFileToDownloadsTable("models/player/custom_player/foxhound/fortnite_dances_emotes_l4d.vvd");
		AddFileToDownloadsTable("models/player/custom_player/foxhound/fortnite_dances_emotes_l4d.dx90.vtx");
	}
	else if (g_iEngine == Engine_Left4Dead2)
	{
		AddFileToDownloadsTable("models/player/custom_player/foxhound/fortnite_dances_emotes_ok.mdl");
		AddFileToDownloadsTable("models/player/custom_player/foxhound/fortnite_dances_emotes_ok.vvd");
		AddFileToDownloadsTable("models/player/custom_player/foxhound/fortnite_dances_emotes_ok.dx90.vtx");
	}

	// edit
	// add the sound file routes here

	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/ninja_dance_01.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/dance_soldier_03.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/Hip_Hop_Good_Vibes_Mix_01_Loop.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/emote_zippy_A.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/athena_emote_electroshuffle_music.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/emote_aerobics_01.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/athena_music_emotes_bendy.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/athena_emote_bandofthefort_music.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/emote_boogiedown.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/athena_emote_flapper_music.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/athena_emote_chicken_foley_01.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/emote_cry.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/athena_emote_music_boneless.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/athena_emotes_music_shoot_v7.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/Athena_Emotes_Music_SwipeIt.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/athena_emote_disco.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/athena_emote_worm_music.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/athena_music_emotes_takethel.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/athena_emote_breakdance_music.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/Emote_Dance_Pump.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/athena_emote_ridethepony_music_01.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/athena_emote_facepalm_foley_01.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/Athena_Emotes_OnTheHook_02.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/athena_emote_floss_music.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/Emote_FlippnSexy.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/athena_emote_fresh_music.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/emote_groove_jam_a.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/br_emote_shred_guitar_mix_03_loop.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/Emote_HeelClick.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/s5_hiphop_breakin_132bmp_loop.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/Emote_Hotstuff.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/emote_hula_01.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/athena_emote_infinidab.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/emote_Intensity.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/emote_irish_jig_foley_music_loop.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/Athena_Music_Emotes_KoreanEagle.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/emote_kpop_01.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/emote_laugh_01.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/emote_LivingLarge_A.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/Emote_Luchador.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/Emote_Hillbilly_Shuffle.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/emote_samba_new_B.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/athena_emote_makeitrain_music.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/Athena_Emote_PopLock.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/Emote_PopRock_01.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/athena_emote_robot_music.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/athena_emote_salute_foley_01.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/Emote_Snap1.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/emote_stagebow.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/Emote_Dino_Complete.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/athena_emote_founders_music.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/athena_emotes_music_twist.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/Emote_Warehouse.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/Wiggle_Music_Loop.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/Emote_Yeet.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/youre_awesome_emote_music.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/athena_emotes_lankylegs_loop_02.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/eastern_bloc_musc_setup_d.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/athena_emote_hot_music.mp3");
	AddFileToDownloadsTable("sound/kodua/fortnite_emotes/emote_capoeira.mp3");

	// this dont touch
	if (g_iEngine == Engine_Left4Dead)
		PrecacheModel("models/player/custom_player/foxhound/fortnite_dances_emotes_l4d.mdl", true);
	else if (g_iEngine == Engine_Left4Dead2)
		PrecacheModel("models/player/custom_player/foxhound/fortnite_dances_emotes_ok.mdl", true);

	// edit
	// add mp3 files without sound/
	// add wav files with */

	PrecacheSound("kodua/fortnite_emotes/ninja_dance_01.mp3");
	PrecacheSound("kodua/fortnite_emotes/dance_soldier_03.mp3");
	PrecacheSound("kodua/fortnite_emotes/Hip_Hop_Good_Vibes_Mix_01_Loop.mp3");
	PrecacheSound("kodua/fortnite_emotes/emote_zippy_A.mp3");
	PrecacheSound("kodua/fortnite_emotes/athena_emote_electroshuffle_music.mp3");
	PrecacheSound("kodua/fortnite_emotes/emote_aerobics_01.mp3");
	PrecacheSound("kodua/fortnite_emotes/athena_music_emotes_bendy.mp3");
	PrecacheSound("kodua/fortnite_emotes/athena_emote_bandofthefort_music.mp3");
	PrecacheSound("kodua/fortnite_emotes/emote_boogiedown.mp3");
	PrecacheSound("kodua/fortnite_emotes/emote_capoeira.mp3");
	PrecacheSound("kodua/fortnite_emotes/athena_emote_flapper_music.mp3");
	PrecacheSound("kodua/fortnite_emotes/athena_emote_chicken_foley_01.mp3");
	PrecacheSound("kodua/fortnite_emotes/emote_cry.mp3");
	PrecacheSound("kodua/fortnite_emotes/athena_emote_music_boneless.mp3");
	PrecacheSound("kodua/fortnite_emotes/athena_emotes_music_shoot_v7.mp3");
	PrecacheSound("kodua/fortnite_emotes/Athena_Emotes_Music_SwipeIt.mp3");
	PrecacheSound("kodua/fortnite_emotes/athena_emote_disco.mp3");
	PrecacheSound("kodua/fortnite_emotes/athena_emote_worm_music.mp3");
	PrecacheSound("kodua/fortnite_emotes/athena_music_emotes_takethel.mp3");
	PrecacheSound("kodua/fortnite_emotes/athena_emote_breakdance_music.mp3");
	PrecacheSound("kodua/fortnite_emotes/Emote_Dance_Pump.mp3");
	PrecacheSound("kodua/fortnite_emotes/athena_emote_ridethepony_music_01.mp3");
	PrecacheSound("kodua/fortnite_emotes/athena_emote_facepalm_foley_01.mp3");
	PrecacheSound("kodua/fortnite_emotes/Athena_Emotes_OnTheHook_02.mp3");
	PrecacheSound("kodua/fortnite_emotes/athena_emote_floss_music.mp3");
	PrecacheSound("kodua/fortnite_emotes/Emote_FlippnSexy.mp3");
	PrecacheSound("kodua/fortnite_emotes/athena_emote_fresh_music.mp3");
	PrecacheSound("kodua/fortnite_emotes/emote_groove_jam_a.mp3");
	PrecacheSound("kodua/fortnite_emotes/br_emote_shred_guitar_mix_03_loop.mp3");
	PrecacheSound("kodua/fortnite_emotes/Emote_HeelClick.mp3");
	PrecacheSound("kodua/fortnite_emotes/s5_hiphop_breakin_132bmp_loop.mp3");
	PrecacheSound("kodua/fortnite_emotes/Emote_Hotstuff.mp3");
	PrecacheSound("kodua/fortnite_emotes/emote_hula_01.mp3");
	PrecacheSound("kodua/fortnite_emotes/athena_emote_infinidab.mp3");
	PrecacheSound("kodua/fortnite_emotes/emote_Intensity.mp3");
	PrecacheSound("kodua/fortnite_emotes/emote_irish_jig_foley_music_loop.mp3");
	PrecacheSound("kodua/fortnite_emotes/Athena_Music_Emotes_KoreanEagle.mp3");
	PrecacheSound("kodua/fortnite_emotes/emote_kpop_01.mp3");
	PrecacheSound("kodua/fortnite_emotes/emote_laugh_01.mp3");
	PrecacheSound("kodua/fortnite_emotes/emote_LivingLarge_A.mp3");
	PrecacheSound("kodua/fortnite_emotes/Emote_Luchador.mp3");
	PrecacheSound("kodua/fortnite_emotes/Emote_Hillbilly_Shuffle.mp3");
	PrecacheSound("kodua/fortnite_emotes/emote_samba_new_B.mp3");
	PrecacheSound("kodua/fortnite_emotes/athena_emote_makeitrain_music.mp3");
	PrecacheSound("kodua/fortnite_emotes/Athena_Emote_PopLock.mp3");
	PrecacheSound("kodua/fortnite_emotes/Emote_PopRock_01.mp3");
	PrecacheSound("kodua/fortnite_emotes/athena_emote_robot_music.mp3");
	PrecacheSound("kodua/fortnite_emotes/athena_emote_salute_foley_01.mp3");
	PrecacheSound("kodua/fortnite_emotes/Emote_Snap1.mp3");
	PrecacheSound("kodua/fortnite_emotes/emote_stagebow.mp3");
	PrecacheSound("kodua/fortnite_emotes/Emote_Dino_Complete.mp3");
	PrecacheSound("kodua/fortnite_emotes/athena_emote_founders_music.mp3");
	PrecacheSound("kodua/fortnite_emotes/athena_emotes_music_twist.mp3");
	PrecacheSound("kodua/fortnite_emotes/Emote_Warehouse.mp3");
	PrecacheSound("kodua/fortnite_emotes/Wiggle_Music_Loop.mp3");
	PrecacheSound("kodua/fortnite_emotes/Emote_Yeet.mp3");
	PrecacheSound("kodua/fortnite_emotes/youre_awesome_emote_music.mp3");
	PrecacheSound("kodua/fortnite_emotes/athena_emotes_lankylegs_loop_02.mp3");
	PrecacheSound("kodua/fortnite_emotes/eastern_bloc_musc_setup_d.mp3");
	PrecacheSound("kodua/fortnite_emotes/athena_emote_hot_music.mp3");
}