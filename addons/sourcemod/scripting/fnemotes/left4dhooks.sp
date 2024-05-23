/**
 * vim  set ts=4
 * =============================================================================
 *
 * Left 4 Downtown 2 SourceMod Extension
 * Copyright (C) 2010 Michael "ProdigySim" Busby
 *
 * Left 4 Downtown SourceMod Extension
 * Copyright (C) 2009 Igor "Downtown1" Smirnov
 *
 * Left 4 Downtown 2 Extension updates
 * Copyright (C) 2012-2015 "Visor"
 *
 * Left 4 Downtown 2 Extension updates
 * Copyright (C) 2015 "Attano"
 *
 * Left 4 Downtown 2 Extension updates
 * Copyright (C) 2017 "Accelerator74"
 *
 * Left 4 DHooks Direct SourceMod plugin
 * Copyright (C) 2024 "SilverShot" / "Silvers"
 *
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http //www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http //www.sourcemod.net/license.php>.
 *
 * Version  $Id$
 */

#if defined _l4dh_included
 #endinput
#endif
#define _l4dh_included

// ====================================================================================================
// STOCKS
// ====================================================================================================
stock EngineVersion g_iEngine;

/**
 * @brief Returns if the server is running on the Left 4 Dead series engine
 *
 * @return					Returns true if the server is running on the Left 4 Dead series
 */
stock bool L4D_IsEngineLeft4Dead()
{
	if( g_iEngine == Engine_Unknown )
	{
		g_iEngine = GetEngineVersion();
	}

	return (g_iEngine == Engine_Left4Dead || g_iEngine == Engine_Left4Dead2);
}

// ====================================================================================================
// VARIOUS STOCKS: "l4d_stocks.inc" by "Mr. Zero"
// ====================================================================================================

enum L4DTeam
{
	L4DTeam_Unassigned				= 0,
	L4DTeam_Spectator				= 1,
	L4DTeam_Survivor				= 2,
	L4DTeam_Infected				= 3
}

/**
 * Returns the clients team using L4DTeam.
 *
 * @param client		Player's index.
 * @return				Current L4DTeam of player.
 * @error				Invalid client index.
 */
stock L4DTeam L4D_GetClientTeam(int client)
{
	int team = GetClientTeam(client);
	return view_as<L4DTeam>(team);
}