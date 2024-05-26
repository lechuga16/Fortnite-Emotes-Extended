#if defined _resources_included
	#endinput
#endif
#define _resources_included

/*****************************************************************
			G L O B A L   V A R S
*****************************************************************/

#define FNEMOTES_DIR	"data/fnemotes"
#define FNEMOTES_LIMIT_FILES	5	// Max number of files in the fnemotes directory. Sourcepawn doesn't support dynamic gloval arrays

#define KEY_MODELS 		"models"
#define KEY_SOUNDS		"sounds"
#define KEY_EMOTES		"emotes"
#define KEY_DANCES		"dances"
#define KEY_SIZE		"size"
#define MAX_RESOURCES	120

enum struct Resources
{
	char path[PLATFORM_MAX_PATH];
}

KeyValues
	g_kvResources[FNEMOTES_LIMIT_FILES];

Resources
	g_Models[FNEMOTES_LIMIT_FILES][MAX_RESOURCES],
	g_Sounds[FNEMOTES_LIMIT_FILES][MAX_RESOURCES];

int
	g_iModelSize[FNEMOTES_LIMIT_FILES],
	g_iSoundsSize[FNEMOTES_LIMIT_FILES],
	g_iEmotesSize[FNEMOTES_LIMIT_FILES],
	g_iDancesSize[FNEMOTES_LIMIT_FILES],
	g_iFilesFnemotesCounter; // Counter for the number of files in the fnemotes directory

enum struct FilesFnEmotes
{
	char name[32];
}

FilesFnEmotes
	g_FilesConfig[FNEMOTES_LIMIT_FILES], // Array to store the names of the .cfg files in the fnemotes directory
	g_Emotes[FNEMOTES_LIMIT_FILES][MAX_RESOURCES],
	g_Dances[FNEMOTES_LIMIT_FILES][MAX_RESOURCES];

/*****************************************************************
			F O R W A R D   P U B L I C S
*****************************************************************/

OnPluginStart_resources()
{
	if(g_bLateload)
	{
		CReplyToCommand(SERVER_INDEX, "%t Resources plugin loaded late, skipping initialization.", "TAG");
		return;
	}
	
	if(!ReadDirectory())
		SetFailState("Couldn't read %s directory or files", FNEMOTES_DIR);

	for(int i = 1; i <= g_iFilesFnemotesCounter; i++)
	{
		char sFnemotesPatch[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, sFnemotesPatch, sizeof(sFnemotesPatch), "%s/%s", FNEMOTES_DIR, g_FilesConfig[i].name);

		g_kvResources[i] = new KeyValues("Resources");
	
		if (!g_kvResources[i].ImportFromFile(sFnemotesPatch))
			SetFailState("Couldn't load %s", sFnemotesPatch);

		ReadResources(i);
		
		char sBuffer[62];
		strcopy(sBuffer, sizeof(sBuffer), g_FilesConfig[i].name);
		ReplaceString(sBuffer, sizeof(sBuffer), ".cfg", "");	// Remove .cfg extension
		Format(sBuffer, sizeof(sBuffer), "%s.phrases", sBuffer);
		LoadTranslation(sBuffer);
	}

	RegConsoleCmd("sm_emotes_resources", Command_resources);
}

public Action Command_resources(int client, int args)
{
	for (int i = 1; i <= g_iFilesFnemotesCounter; i++)
	{
		ReplyToCommand(client, "\nFile [%s]", g_FilesConfig[i].name);
		ReplyToCommand(client, "--------------------");
		for (int j = 1; j <= g_iModelSize[i]; j++)
		{
			ReplyToCommand(client, "Model [%d] - [%s]", j, g_Models[i][j].path);
		}

		ReplyToCommand(client, "--------------------");
		for (int j = 1; j <= g_iSoundsSize[i]; j++)
		{
			ReplyToCommand(client, "Sound [%d] - [%s]", j, g_Sounds[i][j].path);
		}
		ReplyToCommand(client, "--------------------");

		for (int j = 1; j <= g_iEmotesSize[i]; j++)
		{
			ReplyToCommand(client, "Emote [%d] - [%s]", j, g_Emotes[i][j].name);
		}
		ReplyToCommand(client, "--------------------");

		for (int j = 1; j <= g_iDancesSize[i]; j++)
		{
			ReplyToCommand(client, "Dance [%d] - [%s]", j, g_Dances[i][j].name);
		}
		ReplyToCommand(client, "--------------------");
	}

	return Plugin_Handled;
}

void OnConfigsExecuted_resources()
{
	if (!g_cvarDownloadResources.BoolValue || g_bLateload)
		return;

	for(int i = 1; i <= g_iFilesFnemotesCounter; i++)
	{
		for (int j = 1; j <= g_iModelSize[i]; j++)
		{
			AddFileToDownloadsTable(g_Models[i][j].path);
		}

		for (int j = 1; j <= g_iSoundsSize[i]; j++)
		{
			AddFileToDownloadsTable(g_Sounds[i][j].path);
		}
	}

	PrintToServer("Added %d models and %d sounds to the downloads table.", g_iModelSize, g_iSoundsSize);
}

void OnMapStart_Resources()
{
	if(g_bLateload)
		return;

	for(int i = 1; i <= g_iFilesFnemotesCounter; i++)
	{
		for (int j = 1; j <= g_iModelSize[i]; j++)
		{
			if (StrContains(g_Models[i][j].path, ".mdl") == -1)
				continue;

			PrecacheModel(g_Models[i][j].path, true);
		}

		char
			g_sSounds[MAX_RESOURCES];
		for (int j = 1; j <= g_iSoundsSize[i]; j++)
		{
			Format(g_sSounds, sizeof(g_sSounds), g_Sounds[i][j].path);
			ReplaceStringEx(g_sSounds, sizeof(g_sSounds), "sound/", "");	// Remove sound/ prefix
			PrecacheSound(g_sSounds);
		}
	}
}

/*****************************************************************
			P L U G I N   F U N C T I O N S
*****************************************************************/


/**
 * Reads the resources from the specified file and populates the global arrays for models and sounds.
 *
 * @param i The index of the file to read resources from.
 */
void ReadResources(int i)
{
	g_kvResources[i].Rewind();
	g_kvResources[i].JumpToKey(KEY_MODELS);
	g_iModelSize[i] = g_kvResources[i].GetNum(KEY_SIZE, -1);

	char sIndex[4];
	for (int j = 1; j <= g_iModelSize[i]; j++)
	{
		IntToString(j, sIndex, sizeof(sIndex));
		g_kvResources[i].GetString(sIndex, g_Models[i][j].path, sizeof(g_Models[][].path));
	}

	g_kvResources[i].GoBack();
	g_kvResources[i].JumpToKey(KEY_SOUNDS);
	g_iSoundsSize[i] = g_kvResources[i].GetNum(KEY_SIZE, -1);

	for (int j = 1; j <= g_iSoundsSize[i]; j++)
	{
		IntToString(j, sIndex, sizeof(sIndex));
		g_kvResources[i].GetString(sIndex, g_Sounds[i][j].path, sizeof(g_Models[][].path));
	}

	g_kvResources[i].GoBack();
	g_kvResources[i].JumpToKey(KEY_EMOTES);
	g_iEmotesSize[i] = g_kvResources[i].GetNum(KEY_SIZE, -1);

	for (int j = 1; j <= g_iEmotesSize[i]; j++)
	{
		IntToString(j, sIndex, sizeof(sIndex));
		g_kvResources[i].GetString(sIndex, g_Emotes[i][j].name, sizeof(g_Emotes[][].name));
	}

	g_kvResources[i].GoBack();
	g_kvResources[i].JumpToKey(KEY_DANCES);
	g_iDancesSize[i] = g_kvResources[i].GetNum(KEY_SIZE, -1);

	for (int j = 1; j <= g_iDancesSize[i]; j++)
	{
		IntToString(j, sIndex, sizeof(sIndex));
		g_kvResources[i].GetString(sIndex, g_Dances[i][j].name, sizeof(g_Dances[][].name));
	}
}

/**
 * Reads the directory specified by `FNEMOTES_DIR` and populates the `g_FilesConfig` array with the names of the .cfg files found.
 * 
 * @return True if at least one .cfg file is found in the directory, false otherwise.
 */
bool ReadDirectory()
{
	char sPath[PLATFORM_MAX_PATH];

	BuildPath(Path_SM, sPath, sizeof(sPath), FNEMOTES_DIR);

	if (!DirExists(sPath))
		return false;

	DirectoryListing dL = OpenDirectory(sPath);

	g_iFilesFnemotesCounter = 1;
	while (dL.GetNext(g_FilesConfig[g_iFilesFnemotesCounter].name, sizeof(g_FilesConfig[].name)))
	{
		if (StrContains(g_FilesConfig[g_iFilesFnemotesCounter].name, ".cfg") == -1)
			continue;

		g_iFilesFnemotesCounter++;
	}
	g_iFilesFnemotesCounter--; // the last array is always empty, we don't need it

	if (g_iFilesFnemotesCounter == 0)
		return false;

	return true;
}