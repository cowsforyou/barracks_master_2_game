--[[
    Usage: write key values under each map on map_settings.kv
           later, access them with MapSettings:GetData(key)
--]]

if not MapSettings then
    MapSettings = class({})
end

function MapSettings:Load()
    MapSettings.File = LoadKeyValues("scripts/kv/map_settings.kv")
    if not MapSettings.File then
        self:print("Error, no map_settings.kv file found or incorrect syntax")
    end

    MapSettings.Data = MapSettings.File[GetMapName()]
end

function MapSettings:GetData(key)
    return MapSettings.Data[key] or self:print("Error, no value for "..GetMapName().." "..key.." in map_settings.kv")
end

function MapSettings:print(...)
    print("[MapSettings] ".. ...)
end

if not MapSettings.File then MapSettings:Load() end