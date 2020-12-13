--Constant parameters
SELECTION_DURATION_LIMIT = 90

--Class definition
if HeroSelection == nil then
	HeroSelection = {}
	HeroSelection.__index = HeroSelection
end

--[[
	Start
	Call this function from your gamemode once the gamestate changes
	to pre-game to start the hero selection.
]]
function HeroSelection:Start()
	--Figure out which players have to pick
	 HeroSelection.playerPicks = {}
	 HeroSelection.numPickers = 0
	 HeroSelection.botPicked = false
	 HeroSelection.botSpawned = false

	for pID = 0, DOTA_MAX_PLAYERS -1 do
		if PlayerResource:IsValidPlayer( pID ) then
			HeroSelection.numPickers = self.numPickers + 1
		end
	end

	--Start the pick timer
	HeroSelection.TimeLeft = SELECTION_DURATION_LIMIT
	
	Timers:CreateTimer({
        useGameTime = false,
        endTime = 0.04,
        callback = HeroSelection.Tick
      })

	--Keep track of the number of players that have picked
	HeroSelection.playersPicked = 0

	--Listen for the pick event
	HeroSelection.listener = CustomGameEventManager:RegisterListener( "hero_selected", HeroSelection.HeroSelect )

	--Listen for the hero preview event
	HeroSelection.previewSelectionListener = CustomGameEventManager:RegisterListener( "hero_preview", HeroSelection.HeroPreview )
end

--[[
	Tick
	A tick of the pick timer.
	Params:
		- event {table} - A table containing PlayerID and HeroID.
]]
function HeroSelection:Tick() 
	--Send a time update to all clients
	if HeroSelection.TimeLeft >= 0 then
		CustomGameEventManager:Send_ServerToAllClients( "picking_time_update", {time = HeroSelection.TimeLeft} )
	end

	--Tick away a second of time
	HeroSelection.TimeLeft = HeroSelection.TimeLeft - 1
	if HeroSelection.TimeLeft == -1 then
		--End picking phase
		HeroSelection:EndPicking()

		if GameRules.botEnabled == true and HeroSelection.botSpawned == false then
			local ent = Entities:FindByName(nil, "badguys_spawn_2")
			local position = ent:GetAbsOrigin()
			bot:SetRespawnPosition(position)
			bot:RespawnHero(false, false)
			HeroSelection.botSpawned = true	
		end
		
		return nil
	elseif HeroSelection.TimeLeft == 88 then
		PauseGame(true)
		GameRules:GetGameModeEntity():SetPauseEnabled(false)
		local mapInfo = {
			mapName = GetMapName(),
			maxPlayer = MapSettings:GetData('maxPlayers')
		  }
	
		CustomGameEventManager:Send_ServerToAllClients( "send_map_info", mapInfo )
			
		if GameRules.botEnabled == true and HeroSelection.botPicked == false then
			bot:MakeVisibleToTeam(DOTA_TEAM_GOODGUYS, 0.5)
			bot:MakeVisibleToTeam(DOTA_TEAM_BADGUYS, 0.5)
			PlayerColors:SetPlayerColorUnselected({ PlayerID = bot:GetPlayerID() })
			if RandomInt(0,1) == 1 then
				HeroSelection:HeroSelect( { PlayerID = bot:GetPlayerID(), HeroName = 'npc_dota_hero_nevermore'} )
			else
				HeroSelection:HeroSelect( { PlayerID = bot:GetPlayerID(), HeroName = 'npc_dota_hero_keeper_of_the_light'} )
			end

			HeroSelection.botPicked = true
		end

		return 1
	elseif HeroSelection.TimeLeft >= 0 then
		return 1
	else
		return nil
	end
end

--[[
	HeroPreview
	A player has previewed a hero. This function is called by the CustomGameEventManager
	once a 'hero_preview' event was seen.
	Params:
			- event {table} - A table containing PlayerID and HeroID.
]]
function HeroSelection:HeroPreview( event )
	CustomGameEventManager:Send_ServerToAllClients( "hero_preview_pick", 
	{ PlayerID = event.PlayerID, HeroName = event.HeroName} )
end

--[[
	HeroSelect
	A player has selected a hero. This function is caled by the CustomGameEventManager
	once a 'hero_selected' event was seen.
	Params:
		- event {table} - A table containing PlayerID and HeroID.
]]
function HeroSelection:HeroSelect( event )

	--If this player has not picked yet give him the hero
	if HeroSelection.playerPicks[ event.PlayerID ] == nil then
		HeroSelection.playersPicked = HeroSelection.playersPicked + 1
		HeroSelection.playerPicks[ event.PlayerID ] = event.HeroName

		--Send a pick event to all clients
		CustomGameEventManager:Send_ServerToAllClients( "picking_player_pick", 
			{ PlayerID = event.PlayerID, HeroName = event.HeroName} )

		--Assign the hero if picking is over
		if HeroSelection.TimeLeft <= 0 then
			HeroSelection:AssignHero( event.PlayerID, event.HeroName )
		end
	end

	--Check if all heroes have been picked
	if HeroSelection.playersPicked >= HeroSelection.numPickers then
		--End picking
		if HeroSelection.TimeLeft > 5 then
			HeroSelection.TimeLeft = 5
		end
		HeroSelection:Tick()
	end
end

--[[
	EndPicking
	The final function of hero selection which is called once the selection is done.
	This function spawns the heroes for the players and signals the picking screen
	to disappear.
]]
function HeroSelection:EndPicking()
	--Stop listening to pick events
	CustomGameEventManager:UnregisterListener( self.listener )

	--Assign the picked heroes to all players that have picked
	for player, hero in pairs( HeroSelection.playerPicks ) do
		HeroSelection:AssignHero( player, hero )
		
		local originalColorData = CustomNetTables:GetTableValue("selected_player_colors", tostring(player))
		print(originalColorData)
		PrintTable(originalColorData)
	end

	--Signal the picking screen to disappear
	CustomGameEventManager:Send_ServerToAllClients( "picking_done", {} )

	-- Unpause the game
	PauseGame(false)
	GameRules:GetGameModeEntity():SetPauseEnabled(true)
	
	-- Assigns color for users who did not select color
	local playerCount = PlayerResource:GetPlayerCount()
	local test  = PlayerResource:IsValidPlayer( 0 )

	-- Speeds the game back up
	-- Convars:SetInt("host_timescale", tonumber(1))
end

--[[
	AssignHero
	Assign a hero to the player. Replaces the current hero of the player
	with the selected hero, after it has finished precaching.
	Params:
		- player {integer} - The playerID of the player to assign to.
		- hero {string} - The unit name of the hero to assign (e.g. 'npc_dota_hero_rubick')
]]
function HeroSelection:AssignHero( player, hero )
	PrecacheUnitByNameAsync( hero, function()
		PlayerResource:ReplaceHeroWith( player, hero, 0, 0 )

		-- Initialize Hero
		local playerEnt = PlayerResource:GetPlayer(player)
		local heroEnt = playerEnt:GetAssignedHero()
		BMCore:InitializeHero(heroEnt)
		Upgrades:CheckAbilityRequirements(heroEnt)
	end, player)
end