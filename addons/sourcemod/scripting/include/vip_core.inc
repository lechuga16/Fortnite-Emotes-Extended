#if defined _vip_core_included
 #endinput
#endif
#define _vip_core_included

/* VIP Function Data Types*/
enum VIP_ValueType
{
	VIP_NULL	= 0,	// No data
	INT,				// Integer type
	FLOAT,				// Floating-point numbers
	BOOL,				// Boolean type (1/0)
	STRING				// String type
}

/* VIP Function Statuses*/
enum VIP_ToggleState
{
	DISABLED = 0,		// Disabled
	ENABLED,			// Enabled
	NO_ACCESS			// No access
}

/* VIP Function Types*/
enum VIP_FeatureType
{
	TOGGLABLE = 0,		// Toggleable in menu
	SELECTABLE,			// Selectable only
	HIDE				// Hidden
}

typeset ItemSelectCallback
{
	/**
	 *	Called when a VIP player clicks on a menu item (for TOGGLABLE type).
	 *
	 * @param iClient			Player index.
	 * @param szFeature			Unique function name.
	 * @param eOldStatus		Old status value.
	 * @param eNewStatus		New status value.
	 *
	 * @return					Plugin_Stop or Plugin_Handled - stop the status toggle;
	 *							Plugin_Continue - allow status toggle without changes;
	 *							Plugin_Changed - allow status toggle to eNewStatus.
	*/
	function Action (int iClient, const char[] szFeature, VIP_ToggleState eOldStatus, VIP_ToggleState &eNewStatus);

	/**
	 *	Called when a VIP player clicks on a menu item (for SELECTABLE type).
	 *
	 * @param iClient			Player index.
	 * @param szFeature			Unique function name.
	 *
	 * @return					true - reopen VIP menu to the player;
	 * 							false.
	*/
	function bool (int iClient, const char[] szFeature);
};

/**
 * Called when a VIP player sees an item in the menu.
 *
 * @param iClient           Player index.
 * @param szFeature         Unique feature name.
 * @param szDisplay         Buffer.
 * @param iMaxLength        Buffer size.
 *
 * @return                  true - Display the content of szDisplay.
 *                          false - Display unchanged.
*/
typedef ItemDisplayCallback = function bool(int iClient, const char[] szFeature, char[] szDisplay, int iMaxLength);

/**
 * Called when a VIP player sees the style of an item in the menu.
 *
 * @param iClient           Player index.
 * @param szFeature         Unique feature name.
 * @param iStyle            Style.
 *
 * @return                  Required style (ITEMDRAW_*).
*/
typedef ItemDrawCallback = function int(int iClient, const char[] szFeature, int iStyle);

/**
 * Called when a player respawns.
 *
 * @param iClient           Player index.
 * @param iTeam             Player's team (2 - T, 3 - CT).
 * @param bIsVIP            Whether the player has VIP status.
 *
 * @noreturn
*/
forward void VIP_OnPlayerSpawn(int iClient, int iTeam, bool bIsVIP);

/**
 * Called when information is displayed in the game.
 *
 * @param iClient           Player index.
 * @param szEvent           Event name:
 *                              "connect_info_time" - VIP player entered the server (temporary VIP status);
 *                              "connect_info_perm" - VIP player entered the server (permanent VIP status);
 *                              "no_access_info" - Player tried to open the VIP menu;
 *                              "connect_info_time" - VIP player's status expired.
 * @param szType            Message type:
 *                              "chat" - In chat;
 *                              "menu" - In menu;
 *                              "url" - In MOTD window.
 * @param hKeyValues        KeyValues of the event.
 *
 * @return                  Plugin_Stop or Plugin_Handled - prevents notification display;
 *                          Plugin_Changed - allows with changes;
 *                          Plugin_Continue - allows without changes.
*/
forward Action VIP_OnShowClientInfo(int iClient, const char[] szEvent, const char[] szType, KeyValues hKeyValues);
/**
 * Called when the status of a VIP player's feature changes.
 *
 * @param iClient           Player index.
 * @param szFeature         Unique feature name.
 * @param eOldStatus        Old status value.
 * @param eNewStatus        New status value.
 *
 * @return                  Plugin_Stop or Plugin_Handled - stops the status toggle;
 *                          Plugin_Continue - allows the status toggle without changes;
 *                          Plugin_Changed - allows the status toggle to eNewStatus.
*/
forward Action VIP_OnFeatureToggle(int iClient, const char[] szFeature, VIP_ToggleState eOldStatus, VIP_ToggleState &eNewStatus);

/**
 * Called when the VIP plugin is loaded.
 *
 * @noparams
 *
 * @noreturn
*/
forward void VIP_OnVIPLoaded();

/**
 * Called when a VIP feature is registered.
 *
 * @param szFeature         Unique feature name.
 *
 * @noreturn
*/
forward void VIP_OnFeatureRegistered(const char[] szFeature);

/**
 * Called when a VIP feature is unregistered.
 *
 * @param szFeature         Unique feature name.
 *
 * @noreturn
*/
forward void VIP_OnFeatureUnregistered(const char[] szFeature);

/**
 * Called before checking a player for VIP status.
 *
 * @param iClient           Player index.
 *
 * @return                  true - continue.
 *                          false - do not perform the check.
*/
forward bool VIP_OnClientPreLoad(int iClient);

/**
 * Called when a player has been loaded.
 *
 * @param iClient           Player index.
 * @param bIsVIP            Whether the player has VIP status.
 *
 * @noreturn
*/
forward void VIP_OnClientLoaded(int iClient, bool bIsVIP);

/**
 * Called when a VIP player has been loaded.
 *
 * @param iClient           Player index.
 *
 * @noreturn
*/
forward void VIP_OnVIPClientLoaded(int iClient);

/**
 * Called when a player is in the disconnect stage.
 *
 * @param iClient           Player index.
 * @param bIsVIP            Whether the player has VIP status.
 *
 * @noreturn
*/
forward void VIP_OnClientDisconnect(int iClient, bool bIsVIP);

/**
 * Called when a player receives VIP status.
 *
 * @param iClient           Player index.
 * @param iAdmin            Admin index (0 - server).
 *
 * @noreturn
*/
forward void VIP_OnVIPClientAdded(int iClient, int iAdmin);
/**
 * Called when a player loses VIP status.
 *
 * @param iClient           Player index.
 * @param szReason          Reason:
 *                              "Expired" - Expired;
 *                              "Removed by Admin" - Removed by admin;
 *                              "Removed by native" - Removed by native.
 * @param iAdmin            Admin index (0 - server).
 *
 * @noreturn
*/
forward void VIP_OnVIPClientRemoved(int iClient, const char[] szReason, int iAdmin);

/**
 * Initiates the check for VIP rights for a player.
 *
 * @param iClient           Player index.
 * @param bNotify           Notify the player about the check result.
 * @param bForward          Call VIP_OnClientPreLoad forward before the check.
 *
 * @noreturn
*/
native void VIP_CheckClient(int iClient, bool bNotify = false, bool bForward = true);

/**
 * Gets whether a player has VIP rights.
 *
 * @param iClient           Player index.
 *
 * @return                  true - The player has VIP status.
 *                          false - The player does not have VIP status.
*/
native bool VIP_IsClientVIP(int iClient);

/**
 * Gets the unique ID of a VIP player.
 *
 * @param iClient           Player index.
 *
 * @return                  Unique ID or -1 if temporary.
*/
native int VIP_GetClientID(int iClient);

/**
 * Gets the expiration time of VIP rights for a player (Unix format).
 *
 * @param iClient           Player index.
 *
 * @return                  Date in Unix format (0 - forever, -1 if retrieval failed).
*/
native int VIP_GetClientAccessTime(int iClient);

/**
 * Sets the expiration time of VIP rights for a player (Unix format).
 *
 * @param iClient           Player index.
 * @param iTime             Date in Unix format, 0 if rights are forever, -1 if temporary.
 * @param bInDB             Modify in the database.
 *
 * @return                  true - Successful.
 *                          false - Unable to execute.
*/
native bool VIP_SetClientAccessTime(int iClient, int iTime, bool bInDB = true);

/**
 * Gets the VIP group of a player.
 *
 * @param iClient           Player index.
 * @param szGroup           Buffer to hold the result.
 * @param iMaxLength        Buffer size.
 *
 * @return                  true - Successful.
 *                          false - Unable to execute.
*/
native bool VIP_GetClientVIPGroup(int iClient, char[] szGroup, int iMaxLength);

/**
 * Sets the VIP group for a player.
 *
 * @param iClient           Player index.
 * @param szGroup           VIP group.
 * @param bInDBB            Modify in the database.
 *
 * @return                  true - Successful.
 *                          false - Unable to execute.
*/
native bool VIP_SetClientVIPGroup(int iClient, const char[] szGroup, bool bInDB = true);

/**
 * Gets the Handle adt trie settings of a VIP player.
 *
 * @param iClient           Player index.
 *
 * @return                  StringMap (Handle) adt trie settings of a VIP player.
*/
native StringMap VIP_GetVIPClientTrie(int iClient);
/**
 * Checks the existence of a VIP group.
 *
 * @param szGroup           VIP group name.
 *
 * @return                  true - VIP group exists.
 *                          false - VIP group does not exist.
*/
native bool VIP_IsValidVIPGroup(const char[] szGroup);

/**
 * Displays a message to a player in the chat with a prefix (phrase translated as "VIP_CHAT_PREFIX").
 *
 * @param iClient           Player index.
 * @param szMessage         Message formatting rules.
 * @param ...               Formatting parameters.
 *
 * @noreturn
*/
native void VIP_PrintToChatClient(int iClient, const char[] szMessage, any ...);

/**
 * Displays a message to all players in the chat with a prefix (phrase translated as "VIP_CHAT_PREFIX").
 *
 * @param szMessage         Message formatting rules.
 * @param ...               Formatting parameters.
 *
 * @noreturn
*/
native void VIP_PrintToChatAll(const char[] szMessage, any ...);

/**
 * Writes a message to the log.
 *
 * @param szMessage         Message formatting rules.
 * @param ...               Formatting parameters.
 *
 * @noreturn
*/
native void VIP_LogMessage(const char[] szMessage, any ...);

/**
 * Sends the VIP menu to a player.
 *
 * @param iClient           Player index.
 * @param bSelection        Opening mode:
 *                          true - on the first page;
 *                          false - on the page of the last selected item.
 *
 * @noreturn
*/
native void VIP_SendClientVIPMenu(int iClient, bool bSelection = false);

/**
 * Grants VIP rights to a player.
 *
 * @param iAdmin            Admin index (0 - server, -1 - plugin).
 * @param iClient           Player index.
 * @param iTime             Time in seconds.
 * @param szGroup           VIP group name.
 * @param bAddToDB          Add to the database.
 *
 * @noreturn
*/
native void VIP_GiveClientVIP(int iAdmin = 0, int iClient, int iTime, const char[] szGroup, bool bAddToDB = true);

#pragma deprecated Use VIP_GiveClientVIP() instead
native bool VIP_SetClientVIP(int iClient, int iTime, any AuthType, const char[] szGroup, bool bAddToDB = true);

/**
 * Revokes VIP rights from a player.
 *
 * @param iAdmin            Admin index (0 - server, -1 - plugin).
 * @param iClient           Player index.
 * @param bInDB             Remove from the database.
 * @param bNotify           Player notification (true - notify/false - do not notify).
 *
 * @return                  true - Successful.
 *                          false - Unable to execute.
*/
native bool VIP_RemoveClientVIP2(int iAdmin = 0, int iClient, bool bInDB, bool bNotify);

#pragma deprecated Use VIP_RemoveClientVIP2() instead
native bool VIP_RemoveClientVIP(int iClient, bool bInDB, bool bNotify);

/**
 * Checks if the core is loaded and ready to register functions.
 *
 * @noparams
 *
 * @return                  true - Core is loaded.
 *                          false - Core is not loaded.
*/
native bool VIP_IsVIPLoaded();

/**
 * Adds a new VIP feature.
 *
 * @param szFeature                 Unique feature name.
 * @param eValType                  Data type of the feature.
 * @param eType                     Type of the feature.
 * @param Item_select_callback     Callback when the feature status changes.
 * @param Item_display_callback    Callback when displaying the feature item.
 * @param Item_draw_callback       Callback when displaying the style of the feature item.
 * @param eDefStatus                Default value:
 *                                  ENABLED - Enabled
 *                                  DISABLED - Disabled
 *                                  NO_ACCESS - Do not use (depends on sm_vip_features_default_status).
 * @param bCookie                   Register a cookie for the feature (valid only for the SELECTABLE type).
 *
 * @noreturn
*/
native void VIP_RegisterFeature(const char[]            szFeature,
                                VIP_ValueType           eValType                = VIP_NULL,
                                VIP_FeatureType         eType                   = TOGGLABLE,
                                ItemSelectCallback      Item_select_callback    = INVALID_FUNCTION,
                                ItemDisplayCallback     Item_display_callback   = INVALID_FUNCTION,
                                ItemDrawCallback        Item_draw_callback      = INVALID_FUNCTION,
                                VIP_ToggleState          eDefStatus              = NO_ACCESS,
                                bool                    bCookie                 = false);
/**
 * Removes a VIP feature.
 *
 * @param szFeature         Unique feature name.
 *
 * @noreturn
*/
native void VIP_UnregisterFeature(const char[] szFeature);

/**
 * Removes all VIP features registered by the plugin (call in OnPluginEnd()).
 *
 * @noparams
 *
 * @noreturn
*/
native void VIP_UnregisterMe();

/**
 * Checks the existence of a feature.
 *
 * @param szFeature         Unique feature name.
 *
 * @return                  true - VIP feature exists.
 *                          false - VIP feature does not exist.
*/
native bool VIP_IsValidFeature(const char[] szFeature);

/**
 * Gets the type of a feature.
 *
 * @param szFeature         Unique feature name.
 *
 * @return                  Returns an element from the VIP_FeatureType list.
*/
native VIP_FeatureType VIP_GetFeatureType(const char[] szFeature);

/**
 * Gets the value type of a feature.
 *
 * @param szFeature         Unique feature name.
 *
 * @return                  Returns an element from the VIP_ValueType list.
*/
native VIP_ValueType VIP_GetFeatureValueType(const char[] szFeature);

/**
 * Fills an adt array with features.
 *
 * @param hArray            Array of type ArrayList.
 *
 * @return                  Number of added elements.
*/
native int VIP_FillArrayByFeatures(ArrayList hArray);

/**
 * Returns the status of a VIP feature for a player.
 *
 * @param iClient           Player index.
 * @param szFeature         Unique feature name.
 *
 * @return                  Returns an element from the VIP_ToggleState list.
*/
native VIP_ToggleState VIP_GetClientFeatureStatus(int iClient, const char[] szFeature);

/**
 * Sets the status of a VIP feature for a player.
 *
 * @param iClient           Player index.
 * @param szFeature         Unique feature name.
 * @param eStatus           Status of the VIP feature.
 * @param bCallback         Call the toggle callback.
 * @param bSave             Save in the cookie.
 *
 * @return                  true - Successful.
 *                          false - Unable to execute.
*/
native bool VIP_SetClientFeatureStatus(int iClient, const char[] szFeature, VIP_ToggleState eStatus, bool bCallback = true, bool bSave = false);

/**
 * Returns the status of a VIP feature for a player.
 *
 * @param iClient           Player index.
 * @param szFeature         Unique feature name.
 *
 * @return                  true - VIP feature is enabled.
 *                          false - VIP feature is disabled or no access.
*/
native bool VIP_IsClientFeatureUse(int iClient, const char[] szFeature);

/**
 * Gets the integer value of a VIP feature parameter for a player.
 *
 * @param iClient           Player index.
 * @param szFeature         Unique feature name.
 *
 * @return                  Returns the integer value of a VIP feature parameter for a player.
*/
native int VIP_GetClientFeatureInt(int iClient, const char[] szFeature);

/**
 * Gets the floating-point value of a VIP feature parameter for a player.
 *
 * @param iClient           Player index.
 * @param szFeature         Unique feature name.
 *
 * @return                  Returns the floating-point value of a VIP feature parameter for a player.
*/
native float VIP_GetClientFeatureFloat(int iClient, const char[] szFeature);

/**
 * Gets the boolean value of a VIP feature parameter for a player.
 *
 * @param iClient           Player index.
 * @param szFeature         Unique feature name.
 *
 * @return                  Returns the boolean value of a VIP feature parameter for a player (true/false).
*/
native bool VIP_GetClientFeatureBool(int iClient, const char[] szFeature);

/**
 * Gets the string value of a VIP feature parameter for a player.
 *
 * @param iClient           Player index.
 * @param szFeature         Unique feature name.
 * @param szBuffer          Buffer to hold the result.
 * @param iMaxLength        Buffer size.
 *
 * @noreturn
*/
native void VIP_GetClientFeatureString(int iClient, const char[] szFeature, char[] szBuffer, int iMaxLength);
/**
 * Grants a VIP feature to a player and sets its value (for the duration of the session).
 *
 * @param iClient           Player index.
 * @param szFeature         Unique feature name.
 * @param szValue           Value (automatically converted to the feature's type).
 *
 * @return                  true - Successful.
 *                          false - Unable to execute.
*/
native bool VIP_GiveClientFeature(int iClient, const char[] szFeature, const char[] szValue);

/**
 * Revokes a VIP feature from a VIP player (for the duration of the session).
 *
 * @param iClient           Player index.
 * @param szFeature         Unique feature name.
 *
 * @return                  true - Successful.
 *                          false - Unable to execute.
*/
native bool VIP_RemoveClientFeature(int iClient, const char[] szFeature);

/**
 * Gets the handle of the database. Close with CloseHandle() or delete after use.
 *
 * @noparams
 *
 * @return                  Database (Handle) of the database.
*/
native Database VIP_GetDatabase();

/**
 * Gets the type of the database.
 *
 * @noparams
 *
 * @return                  true - MySQL.
 *                          false - SQLite.
*/
native bool VIP_GetDatabaseType();

/**
 * Converts time to seconds based on sm_vip_time_mode.
 *
 * @param iTime             Time.
 *
 * @return                  Returns the number of seconds based on sm_vip_time_mode.
*/
native int VIP_TimeToSeconds(int iTime);

/**
 * Converts seconds to time based on sm_vip_time_mode.
 *
 * @param iTime             Number of seconds.
 *
 * @return                  Returns time based on sm_vip_time_mode.
*/
native int VIP_SecondsToTime(int iTime);

/**
 * Converts seconds into a human-readable format.
 *
 * @param szBuffer          Buffer to hold the result.
 * @param iMaxLength        Buffer size.
 * @param iTimeStamp        Number of seconds.
 * @param iClient           Player index or LANG_SERVER.
 *
 * @return                  true - Successful.
 *                          false - Unable to execute.
*/
native bool VIP_GetTimeFromStamp(char[] szBuffer, int iMaxLength, int iTimeStamp, int iClient = LANG_SERVER);

/**
 * Appends the feature status to a string.
 *
 * @param szInput           Original string.
 * @param szBuffer          Buffer to hold the result.
 * @param iMaxLength        Buffer size.
 * @param szFeature         Unique feature name.
 * @param iClient           Player index.
 *
 * @noreturn
*/
native void VIP_AddStringToggleStatus(const char[] szInput, char[] szBuffer, int iMaxLength, const char[] szFeature, int iClient);

public SharedPlugin __pl_vip_core= 
{
	name = "vip_core",
	file = "VIP_Core.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_vip_core_SetNTVOptional()
{
	MarkNativeAsOptional("VIP_IsVIPLoaded");
	MarkNativeAsOptional("VIP_GetDatabase");
	MarkNativeAsOptional("VIP_GetDatabaseType");
	MarkNativeAsOptional("VIP_RegisterFeature");
	MarkNativeAsOptional("VIP_UnregisterFeature");
	MarkNativeAsOptional("VIP_IsValidFeature");
	MarkNativeAsOptional("VIP_GetFeatureType");
	MarkNativeAsOptional("VIP_GetFeatureValueType");
	MarkNativeAsOptional("VIP_SetFeatureDefStatus");
	MarkNativeAsOptional("VIP_FillArrayByFeatures");
	MarkNativeAsOptional("VIP_SetClientVIP");
	MarkNativeAsOptional("VIP_RemoveClientVIP");
	MarkNativeAsOptional("VIP_RemoveClientVIP2");
	MarkNativeAsOptional("VIP_CheckClient");
	MarkNativeAsOptional("VIP_IsClientVIP");
	MarkNativeAsOptional("VIP_GetClientID");
	MarkNativeAsOptional("VIP_GetClientVIPGroup");
	MarkNativeAsOptional("VIP_SetClientVIPGroup");
	MarkNativeAsOptional("VIP_GetClientAccessTime");
	MarkNativeAsOptional("VIP_SetClientAccessTime");
	MarkNativeAsOptional("VIP_GetVIPClientTrie");
	MarkNativeAsOptional("VIP_SendClientVIPMenu");
	MarkNativeAsOptional("VIP_IsValidVIPGroup");
	MarkNativeAsOptional("VIP_GetClientFeatureStatus");
	MarkNativeAsOptional("VIP_SetClientFeatureStatus");
	MarkNativeAsOptional("VIP_IsClientFeatureUse");
	MarkNativeAsOptional("VIP_GetClientFeatureInt");
	MarkNativeAsOptional("VIP_GetClientFeatureFloat");
	MarkNativeAsOptional("VIP_GetClientFeatureBool");
	MarkNativeAsOptional("VIP_GetClientFeatureString");
	MarkNativeAsOptional("VIP_PrintToChatClient");
	MarkNativeAsOptional("VIP_PrintToChatAll");
	MarkNativeAsOptional("VIP_LogMessage");
	MarkNativeAsOptional("VIP_TimeToSeconds");
	MarkNativeAsOptional("VIP_SecondsToTime");
	MarkNativeAsOptional("VIP_GetTimeFromStamp");
	MarkNativeAsOptional("VIP_AddStringToggleStatus");
	MarkNativeAsOptional("VIP_GiveClientVIP");
	MarkNativeAsOptional("VIP_UnregisterMe");
	MarkNativeAsOptional("VIP_GiveClientFeature");
	MarkNativeAsOptional("VIP_RemoveClientFeature");
}
#endif