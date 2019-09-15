if not SpawnSynchronizer then
    SpawnSynchronizer = class({})
end

SPAWN_INTERVAL = 30.0

-- runs only once during DOTA_GAMERULES_STATE_GAME_IN_PROGRESS
function SpawnSynchronizer:Setup()
	Timers:CreateTimer(function()
		SpawnSynchronizer.nextSpawnAt = GameRules:GetGameTime() + SPAWN_INTERVAL
		return SPAWN_INTERVAL
	end)
end

-- returns time in seconds until next tick
function SpawnSynchronizer:GetNextInterval()
	if SpawnSynchronizer.nextSpawnAt then
		return SpawnSynchronizer.nextSpawnAt - GameRules:GetGameTime()
	else
		return nil
	end
end