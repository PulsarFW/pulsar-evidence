-- component.lua's glob load order isn't guaranteed, so guard against it running first.
LOCAL_CACHED_EVIDENCE = LOCAL_CACHED_EVIDENCE or {}

local lastBleedLocation

AddEventHandler('Evidence:Client:BleedOnFloor', function()
    local coords = GetEntityCoords(PlayerPedId())
    local currentWeather = GlobalState['Sync:Weather']
    
    if not IsWeatherTypeRain(currentWeather) then
        if not IsCoordsInWater(coords) and (not lastBleedLocation or #(coords - lastBleedLocation) > 2.0) and not VEHICLE_INSIDE and plsr.State.flags.loggedIn then
            local rand = math.random(15, 95)

            table.insert(LOCAL_CACHED_EVIDENCE, {
                type = 'blood',
                route = plsr.State.flags.currentRoute,
                coords = vec(coords.x, coords.y, coords.z - 0.9),
                data = {
                    IsBloodPool = false,
                    DNA = plsr.State.character.SID,
                    tooDegraded = (rand >= 35 and rand <= 45),
                },
                active = true,
            })
            UpdateCachedEvidence()

            lastBleedLocation = coords
        end
    end
end)

AddEventHandler('Ped:Client:Died', function()
    local coords = GetEntityCoords(PlayerPedId())
    local currentWeather = GlobalState['Sync:Weather']
    
    if not IsWeatherTypeRain(currentWeather) then
        if not IsCoordsInWater(coords) and not VEHICLE_INSIDE and plsr.State.flags.loggedIn then
            local rand = math.random(5, 75)

            table.insert(LOCAL_CACHED_EVIDENCE, {
                type = 'blood',
                route = plsr.State.flags.currentRoute,
                coords = vec(coords.x, coords.y, coords.z - 0.9),
                data = {
                    IsBloodPool = true,
                    DNA = plsr.State.character.SID,
                    tooDegraded = (rand >= 32 and rand <= 35),
                },
                active = true,
            })

            UpdateCachedEvidence()
        end
    end
end)

RegisterNetEvent('Characters:Client:Logout', function()
    lastBleedLocation = nil
end)