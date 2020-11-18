WebApi = WebApi or {}

local isTesting = true
local serverHost = "https://stats.barracksmaster.com"
local dedicatedServerKey = GetDedicatedServerKeyV2("1")
local winner = -1

function WebApi:Send(path, data, onSuccess, onError)
	local request = CreateHTTPRequestScriptVM("POST", serverHost .. "/parse/" .. path)
	if isTesting then
		print("Request to " .. path)
		DeepPrintTable(data)
	end

	request:SetHTTPRequestHeaderValue("X-Parse-Application-Id", dedicatedServerKey)
	if data ~= nil then
		request:SetHTTPRequestRawPostBody("application/json", json.encode(data))
	end

	request:Send(function(response)
		if response.StatusCode == 201 then
			local data = json.decode(response.Body)
			if isTesting then
				print("Response from " .. path .. ":")
				DeepPrintTable(data)
			end
			if onSuccess then
				onSuccess(data, response.StatusCode)
			end
		else
			if isTesting then
				print("Error from " .. path .. ": " .. response.StatusCode)
				if response.Body then
					local status, result = pcall(json.decode, response.Body)
					if status then
						DeepPrintTable(result)
					else
						print(response.Body)
					end
				end
			end
			if onError then
				-- TODO: Is response.Body nullable?
				onError(response.Body or "Unknown error (" .. response.StatusCode .. ")", response.StatusCode)
			end
		end
	end)
end

function WebApi:LogEvent( eventName )
	local requestBody = {
		customGame = WebApi.customGame,
		event = eventName,
		matchId = tonumber(tostring(GameRules:GetMatchID())),
		duration = math.floor(GameRules:GetDOTATime(false, true)),
		mapName = GetMapName(),
		players = {}
	}

	for playerId = 0, 23 do
		if PlayerResource:IsValidTeamPlayerID(playerId) and not PlayerResource:IsFakeClient(playerId) then
			local playerScore = CustomNetTables:GetTableValue("scores", tostring(playerId))
			local playerData = {
				playerId = playerId,
				connectionState = PlayerResource:GetConnectionState(playerId),
				steamId = tostring(PlayerResource:GetSteamID(playerId)),
				team = PlayerResource:GetTeam(playerId),
				hero = PlayerResource:GetSelectedHeroName(playerId),
				bmPoints = GetBMPointsForPlayer(playerId),
				netWorth = playerScore["netWorth"],
				gold = playerScore["gold"],
				cs = playerScore["cs"],
				lumber = playerScore["lumber"],
			}

			table.insert(requestBody.players, playerData)
		end
	end

	WebApi:Send("classes/GameEvents", requestBody)
end

function WebApi:AfterMatch(winnerTeam)
	-- if not isTesting then
	-- 	if GameRules:IsCheatMode() then return end
	-- 	if GameRules:GetDOTATime(false, true) < 60 then return end
	-- end
	if winnerTeam < DOTA_TEAM_FIRST or winnerTeam > DOTA_TEAM_CUSTOM_MAX then return end
	if winnerTeam == DOTA_TEAM_NEUTRALS or winnerTeam == DOTA_TEAM_NOTEAM then return end

	local requestBody = {
		customGame = WebApi.customGame,
		matchId = tonumber(tostring(GameRules:GetMatchID())),
		duration = math.floor(GameRules:GetDOTATime(false, true)),
		mapName = GetMapName(),
		winner = winnerTeam,
		players = {}
	}

	for playerId = 0, 23 do
		if PlayerResource:IsValidTeamPlayerID(playerId) and not PlayerResource:IsFakeClient(playerId) then
			local playerScore = CustomNetTables:GetTableValue("scores", tostring(playerId))
			local playerData = {
				playerId = playerId,
				matchId = tonumber(tostring(GameRules:GetMatchID())),
				steamId = tostring(PlayerResource:GetSteamID(playerId)),
				team = PlayerResource:GetTeam(playerId),
				hero = PlayerResource:GetSelectedHeroName(playerId),
				bmPoints = GetBMPointsForPlayer(playerId),
				netWorth = playerScore["netWorth"],
				gold = playerScore["gold"],
				cs = playerScore["cs"],
				lumber = playerScore["lumber"],
			}

			table.insert(requestBody.players, playerData)

			WebApi:Send("classes/UserScore", playerData)
		end
	end

	-- if isTesting or #requestBody.players >= 5 then
		WebApi:Send("classes/GameScore", requestBody)
		WebApi:LogEvent( "BM_GAME_END" )
	-- end
end

function WebApi:GetLeaderBoard()
	local request = CreateHTTPRequestScriptVM("GET", serverHost .. '/parse/aggregate/UserScore?group={"objectId":"$steamId","bmPoints":{"$sum":"$bmPoints"}}&sort={"bmPoints":-1}&limit=10')
	request:SetHTTPRequestHeaderValue("X-Parse-Master-Key", dedicatedServerKey)
	request:SetHTTPRequestHeaderValue("X-Parse-Application-Id", dedicatedServerKey)

	request:Send(function(response)
		if response.StatusCode == 200 then
			local data = json.decode(response.Body)
			if isTesting then
				print("Response from Leaderboard")
				DeepPrintTable(data)
			end

			CustomGameEventManager:Send_ServerToAllClients( "leaderboard_data_update", data )

			if onSuccess then
				onSuccess(data, response.StatusCode)
			end
		else
			if isTesting then
				print("Error from leaderboard " .. response.StatusCode)
				if response.Body then
					local status, result = pcall(json.decode, response.Body)
					if status then
						DeepPrintTable(result)
					else
						print(response.Body)
					end
				end
			end
			if onError then
				-- TODO: Is response.Body nullable?
				onError(response.Body or "Unknown error (" .. response.StatusCode .. ")", response.StatusCode)
			end
		end
	end)
end