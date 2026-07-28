_withinBallistics = false
_ballisticsId = nil
_holdingGun = nil

AddEventHandler("Weapons:Client:SwitchedWeapon", function(weapon, weaponData, weaponItemData)
    if weapon and weaponItemData and weaponItemData.gun then
        _holdingGun = weaponData
    else
        _holdingGun = nil
    end
end)

AddEventHandler('Polyzone:Enter', function(id, point, insideZone, data)
    if data and data.ballistics and plsr.State.flags.onDuty == 'police' then
        _ballisticsId = id
        _withinBallistics = true
        plsr.Action:Show('ballistics', '{keybind}primary_action{/keybind} Test & File Gun Ballistics | {key}Use Projectile Evidence{/key} File Projectile & Compare')
    end
end)

AddEventHandler('Polyzone:Exit', function(id, point, insideZone, data)
    if _withinBallistics and data and data.ballistics and plsr.State.flags.onDuty == 'police' then
        _ballisticsId = nil
        _withinBallistics = false
        plsr.Action:Hide('ballistics')
    end
end)

AddEventHandler('Keybinds:Client:KeyUp:primary_action', function()
    if _withinBallistics and plsr.State.flags.loggedIn then
        plsr.Action:Hide('ballistics')

        local function reshowAction()
            if _withinBallistics then
                plsr.Action:Show('ballistics', '{keybind}primary_action{/keybind} Test & File Gun Ballistics | {key}Use Projectile Evidence{/key} File Projectile & Compare')
            end
        end

        if not _holdingGun or not _holdingGun.MetaData then
            plsr.Notification:Error('No weapon in hand', 7500)
            return reshowAction()
        end

        local serial = _holdingGun.MetaData.SerialNumber or _holdingGun.MetaData.ScratchedSerialNumber
        if not serial then
            plsr.Notification:Error('No serial number found on weapon', 7500)
            return reshowAction()
        end

        plsr.Animations.Emotes:Play('type3', false, 5500, true, true)
        plsr.Progress:Progress({
            name = 'weapon_ballistics_test',
            duration = 5000,
            label = 'Testing & Filing Gun Ballistics',
            useWhileDead = false,
            canCancel = false,
            ignoreModifier = true,
            disarm = false,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = false,
                disableMouse = false,
                disableCombat = true,
            },
        }, function(status)
            if status then
                return reshowAction()
            end

            plsr.Callbacks:ServerCallback("Evidence:Ballistics:FileGun", {
                slotNum = _holdingGun.Slot,
                serial = serial,
            }, function(success, alreadyFiled, matchingEvidence, policeWeaponId)
                if success then
                    local idSuffix = policeWeaponId and string.format(' - Police Weapon ID: %s', policeWeaponId) or ''
                    if alreadyFiled then
                        plsr.Notification:Success('Weapon already filed' .. idSuffix, 7500)
                    else
                        plsr.Notification:Success('Weapon filed successfully' .. idSuffix, 7500)
                    end

                    if matchingEvidence and #matchingEvidence > 0 then
                        plsr.Notification:Info(string.format('Found %d matching projectiles', #matchingEvidence), 7500)
                    end
                else
                    plsr.Notification:Error('Failed to file weapon - invalid weapon or serial number', 7500)
                end

                reshowAction()
            end)
        end)
    end
end)

RegisterNetEvent('Evidence:Client:FiledProjectile', function(tooDegraded, success, alreadyFiled, filedEvidenceData, matchingWeaponData, evidenceId)
    if tooDegraded then
        return plsr.Notification:Error('Projectile too Degraded to Run Ballistics')
    end

    plsr.Animations.Emotes:Play('type3', false, 5500, true, true)
    plsr.Progress:Progress({
        name = 'projectile_ballistics_test',
        duration = 5000,
        label = 'Testing Projectile Ballistics',
        useWhileDead = false,
        canCancel = false,
        ignoreModifier = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        },
    }, function(status)
        if not status then
            if success then
                if alreadyFiled then
                    plsr.Notification:Success('Projectile Was Already Filed', 7500)
                else
                    plsr.Notification:Success('Projectile Filed Successfully', 7500)
                end

                local desc, label

                if matchingWeaponData and matchingWeaponData.police_filed then
                    label = string.format('Successfully Matched to a %s', matchingWeaponData.model)

                    if matchingWeaponData.scratched then
                        desc = string.format('Matched to a Weapon with no Serial Number<br>Assigned Police Weapon ID: PWI-%s', matchingWeaponData.police_id)
                    else
                        desc = string.format('Serial Number: %s', matchingWeaponData.serial)
                    end
                else
                    label = 'No Matching Weapon Found'
                    desc = 'There are currently no weapons filed that match this projectile'
                end

                if label and desc then
                    plsr.ListMenu:Show({
                        main = {
                            label = 'Ballistics Comparison - Results',
                            items = {
                                {
                                    label = 'Projectile Evidence Identifier',
                                    description = evidenceId,
                                },
                                {
                                    label = label,
                                    description = desc,
                                }
                            },
                        },
                    })
                end
            else
                plsr.Notification:Error('Ballistics Testing Failed')
            end
        end
    end)
end)