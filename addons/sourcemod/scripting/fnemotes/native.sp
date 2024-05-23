#if defined _native_included
	#endinput
#endif
#define _native_included

/*****************************************************************
			G L O B A L   V A R S
*****************************************************************/

GlobalForward
	g_EmoteForward,
	g_EmoteForward_Pre;

/*****************************************************************
			F O R W A R D   P U B L I C S
*****************************************************************/
public AskPluginLoad2_native()
{
	g_EmoteForward	   = CreateGlobalForward("fnemotes_OnEmote", ET_Ignore, Param_Cell);
	g_EmoteForward_Pre = CreateGlobalForward("fnemotes_OnEmote_Pre", ET_Event, Param_Cell);

	CreateNative("fnemotes_IsClientEmoting", Native_IsClientEmoting);
	RegPluginLibrary("fnemotes");
}

/*****************************************************************
			N A T I V E S
*****************************************************************/

int Native_IsClientEmoting(Handle plugin, int numParams)
{
	return g_bClientDancing[GetNativeCell(1)];
}