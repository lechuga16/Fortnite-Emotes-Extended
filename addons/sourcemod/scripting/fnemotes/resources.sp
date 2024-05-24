#if defined _resources_included
	#endinput
#endif
#define _resources_included

/*****************************************************************
			G L O B A L   V A R S
*****************************************************************/

#define FNEMOTES_PATH	"data/fnemotes.cfg"
#define KEY_MODELS_L4D2 "models_l4d2"
#define KEY_MODELS_L4D	"models_l4d"
#define KEY_SOUNDS		"sounds"
#define KEY_SIZE		"size"
#define MAX_RESOURCES	120

enum struct Resources
{
	int	 id;
	char path[PLATFORM_MAX_PATH];
}

KeyValues
	g_kvResources;

Resources
	g_Models[MAX_RESOURCES],
	g_Sounds[MAX_RESOURCES];

int
	g_iModelSize,
	g_iSoundsSize;

/*****************************************************************
			F O R W A R D   P U B L I C S
*****************************************************************/

OnPluginStart_resources()
{
	if (!g_cvarDownloadResources.BoolValue)
		return;

	char sFnemotesPatch[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sFnemotesPatch, sizeof(sFnemotesPatch), FNEMOTES_PATH);

	g_kvResources = new KeyValues("Resources");

	if (!g_kvResources.ImportFromFile(sFnemotesPatch))
		SetFailState("Couldn't load %s", sFnemotesPatch);
	else
		ReadResources();

	RegConsoleCmd("sm_emotes_resources", Command_resources);
}

public Action Command_resources(int client, int args)
{
	ReplyToCommand(client, "--------------------");
	for (int i = 1; i <= g_iModelSize; i++)
	{
		ReplyToCommand(client, "Model [%d] - [%s]", i, g_Models[i].path);
	}

	ReplyToCommand(client, "--------------------");
	for (int i = 1; i <= g_iSoundsSize; i++)
	{
		ReplyToCommand(client, "Sound [%d] - [%s]", i, g_Sounds[i].path);
	}
	ReplyToCommand(client, "--------------------");

	return Plugin_Handled;
}

OnMapStart_Resources()
{
	if (!g_cvarDownloadResources.BoolValue)
		return;

	for (int i = 1; i <= g_iModelSize; i++)
	{
		AddFileToDownloadsTable(g_Models[i].path);
	}

	for (int i = 1; i <= g_iSoundsSize; i++)
	{
		AddFileToDownloadsTable(g_Sounds[i].path);
	}

	if (g_iEngine == Engine_Left4Dead)
		PrecacheModel("models/fortnite_emotes/fnemotes_l4d.mdl", true);

	if (g_iEngine == Engine_Left4Dead2)
		PrecacheModel("models/fortnite_emotes/fnemotes_l4d2.mdl", true);

	char
		g_sSounds[MAX_RESOURCES];
	for (int i = 1; i <= g_iSoundsSize; i++)
	{
		Format(g_sSounds, sizeof(g_sSounds), g_Sounds[i].path);
		ReplaceStringEx(g_sSounds, sizeof(g_sSounds), "sound/", ""); // Remove sound/ prefix
		PrecacheSound(g_sSounds);
	}
}

/*****************************************************************
			P L U G I N   F U N C T I O N S
*****************************************************************/

/**
 * Reads the resources from the keyvalue file and populates the g_Models and g_Sounds arrays.
 * This function is used to retrieve the paths of models and sounds for the Fortnite emotes downloader.
 */
void ReadResources()
{
	g_kvResources.Rewind();

	if (g_iEngine == Engine_Left4Dead)
		g_kvResources.JumpToKey(KEY_MODELS_L4D);

	if (g_iEngine == Engine_Left4Dead2)
		g_kvResources.JumpToKey(KEY_MODELS_L4D2);

	g_iModelSize = g_kvResources.GetNum(KEY_SIZE, -1);

	char sIndex[4];
	for (int i = 1; i <= g_iModelSize; i++)
	{
		IntToString(i, sIndex, sizeof(sIndex));
		g_kvResources.GetString(sIndex, g_Models[i].path, PLATFORM_MAX_PATH);
	}

	g_kvResources.GoBack();
	g_kvResources.JumpToKey(KEY_SOUNDS);
	g_iSoundsSize = g_kvResources.GetNum(KEY_SIZE, -1);

	for (int i = 1; i <= g_iSoundsSize; i++)
	{
		IntToString(i, sIndex, sizeof(sIndex));
		g_kvResources.GetString(sIndex, g_Sounds[i].path, PLATFORM_MAX_PATH);
	}
}