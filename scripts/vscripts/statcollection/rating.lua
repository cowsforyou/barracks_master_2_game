function GetBMRatingKSensitivity ()
    return 32
end

function RunBMRatingCalculationsAndSetScore ()
    WebApi:GetTotalTeamRating ( 0 , 0 , 0 , 0 , 0 , function ( teamACount , totalARating , teamBCount , totalBRating ) 
        local goodGuysTeamCurrentRating = math.floor(totalARating / teamACount)
        local badGuysTeamCurrentRating = math.floor(totalBRating / teamBCount)
        SetNewBMRatingForTeams(goodGuysTeamCurrentRating , badGuysTeamCurrentRating)
    end)
end

function SetNewBMRatingForTeams( goodGuysTeamCurrentRating , badGuysTeamCurrentRating )
    local goodGuysTeamRatingRatio = goodGuysTeamCurrentRating / (goodGuysTeamCurrentRating + badGuysTeamCurrentRating)
    local badGuysTeamRatingRatio = 1 - goodGuysTeamRatingRatio

    if WebApi.winner == nil or WebApi.winner == -1 then
        print("No winner declared, no new rating given.")
        -- return
    end

    local goodGuysTeamWin = 0
    local badGuysTeamWin = 0
    if WebApi.winner == DOTA_TEAM_GOODGUYS then
        goodGuysTeamWin = 1
    elseif WebApi.winner == DOTA_TEAM_BADGUYS then
        badGuysTeamWin = 1
    end

    local kSensitivity = GetBMRatingKSensitivity()

    local goodGuysTeamNewRating = math.floor(goodGuysTeamCurrentRating + (kSensitivity * (goodGuysTeamWin - goodGuysTeamRatingRatio)))
    local badGuysTeamNewRating = math.floor(badGuysTeamCurrentRating + (kSensitivity * (badGuysTeamWin - badGuysTeamRatingRatio)))
     
    for playerId = 0, 23 do
		if PlayerResource:IsValidTeamPlayerID(playerId) then
            if PlayerResource:GetTeam(playerId) == DOTA_TEAM_GOODGUYS then
                -- print('new score', goodGuysTeamNewRating)
                WebApi:SetUserRating(playerId, goodGuysTeamNewRating)
            elseif PlayerResource:GetTeam(playerId) == DOTA_TEAM_BADGUYS then
                -- print(' new score bad', badGuysTeamNewRating)
                WebApi:SetUserRating(playerId, badGuysTeamNewRating)
            end
        end
    end
end