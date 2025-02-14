--[[
  _____  _         __          __        _   _
 |  __ \(_)        \ \        / /       | | | |
 | |  | |_ _ __   __\ \  /\  / /__  __ _| |_| |__   ___ _ __
 | |  | | | '_ \ / _ \ \/  \/ / _ \/ _` | __| '_ \ / _ \ '__|
 | |__| | | | | | (_) \  /\  /  __/ (_| | |_| | | |  __/ |
 |_____/|_|_| |_|\___/ \/  \/ \___|\__,_|\__|_| |_|\___|_|

FiveM-DinoWeather
A Weather System that enhances realism by using GTA Natives relating to Zones.
Copyright (C) 2019  Jarrett Boice

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

]]

local activeWeather = false
local lastZone = 0

RegisterNetEvent("dinoweather:syncWeather")
AddEventHandler("dinoweather:syncWeather", function(activeWeathers)
  activeWeather = activeWeathers
end)

Citizen.CreateThread(function()
  TriggerServerEvent("dinoweather:syncWeather")
  while not activeWeather do Wait(0) end

  while true do
    Citizen.Wait(1000)

    local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(PlayerId())))
    local zone = GetNameOfZone(x, y, z)

    for i, weatherZone in ipairs(activeWeather) do
      if weatherZone[1] == zone and lastZone ~= zone then

        ClearOverrideWeather()
        ClearWeatherTypePersist()

        SetWeatherTypeOverTime(weatherZone[2], 15.0)
        SetWeatherTypePersist(weatherZone[2])
        SetWeatherTypeNow(weatherZone[2])
        SetWeatherTypeNowPersist(weatherZone[2])
  
        if weatherZone[2] == 'XMAS' then
          SetForceVehicleTrails(true)
          SetForcePedFootstepsTracks(true)
        else
          SetForceVehicleTrails(false)
          SetForcePedFootstepsTracks(false)
        end

        lastZone = zone

        break
      end
    end
  end
end)

-- Ace Permission dinoweather.cmds -- REQUIRED!!!
RegisterCommand("SetZoneWeather", function(source, args, rawCommand)
  if args[1] == nil then
    TriggerEvent("chatMessage", "^1You did not specify a Weather Type.")
  else
    for i, weatherType in ipairs(WeatherConfig.weatherTypes) do
      if weatherType == args[1] then
        local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(PlayerId())))
        local zoneName = GetNameOfZone(x, y, z)
        TriggerServerEvent("dinoweather:setWeatherInZone", zoneName, weatherType)
        return
      end
    end
    TriggerEvent("chatMessage", "^3The Weather Type you specified does not exist!")
  end
end, false)
