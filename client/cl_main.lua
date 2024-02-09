local society = nil

ESX = exports['es_extended']:getSharedObject()

myLab = nil
myIdentifier = nil

isInNui = false

local pLoaded = false

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function()
    pLoaded = true
    Citizen.Wait(2500)
    ESX.TriggerServerCallback('KmF_Lab:Server:GetPlayerLab', function(lab)
        if lab.lab ~= nil then
            myLab = lab.lab
        end
    end)
end)

-- RegisterCommand('synclab', function(source, args, rawCommand)
--     local tableKey = 0
--     for k, v in pairs(myLab['Crafting']['Tables']) do
--         if v.key == tableKey then
--             TriggerServerEvent('KmF_Lab:Server:SyncCrafting', myLab['LabID'], k, myLab['Crafting']['Tables'][k])
--         end
--     end
-- end)

RegisterNuiCallback('freeChest', function(data, cb)
  ESX.TriggerServerCallback('KmF_Lab:Server:GetDailyChest', function(cb)
    -- print('Callback received')
  end, myLab['LabID'])
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        if ESX.IsPlayerLoaded() then
            -- print('Player is loaded')
            pLoaded = true
        end

        while not pLoaded do
            Citizen.Wait(100)
        end

        Citizen.Wait(1500)
        -- print('Loading lab')

        ESX.TriggerServerCallback('KmF_Lab:Server:GetPlayerLab', function(lab)
            if lab.lab ~= nil then
                myLab = lab.lab
            end
        end)
    end
end)

RegisterNetEvent('KmF_Lab:Client:SyncCrafting')
AddEventHandler('KmF_Lab:Client:SyncCrafting', function(tableKey, tableData, SyncOwner)
    myLab['Crafting']['Tables'][tableKey] = tableData
end)

RegisterNetEvent('KmF_Lab:Client:OpenLabUI')
AddEventHandler('KmF_Lab:Client:OpenLabUI', function()
    toggleLabNui()
end)

Citizen.CreateThread(function()
    local cnt = nil
    while true do
      sleep = 3000

      if myLab ~= nil then

        if not myLab['Crafting'] then
          sleep = 5000
        else

          for k2, v2 in pairs(myLab['Crafting']['Tables']) do

            if v2.item ~= nil and v2.ready == false then

              sleep = 1000
              local item = v2.item

              if v2.remainingTime == nil then

                local upgradeLvl = myLab['BoughtUpgrades']['crafting_time_upgrade'].level
                if upgradeLvl > 0 then
                    local percent = 5 * upgradeLvl
                    v2.remainingTime = math.floor(item.time - ((item.time * percent) / 100))
                    item.time = v2.remainingTime
                else
                    v2.remainingTime = item.time
                end

                -- v2.remainingTime = item.time
              end

              if v2.remainingTime > 0 then
                if cnt == nil then
                    if v2.syncOwner == myIdentifier then
                        -- print('YOU ARE SYNC OWNER ::::: SYNCING OTHER PLAYERS')
                        TriggerServerEvent('KmF_Lab:Server:SyncCrafting', myLab['LabID'], k2, myLab['Crafting']['Tables'][k2])
                        cnt = 0
                    end
                end

                if v2.syncOwner == myIdentifier then
                    cnt = cnt + 1
                end

                if item.elapsedTime == nil then
                  item.elapsedTime = 0
                end

                item.elapsedTime = item.elapsedTime + 1
                v2.remainingTime = v2.remainingTime - 1
                v2.percentage = ((item.time - (item.time-item.elapsedTime)) * 100) / item.time

                if v2.syncOwner == myIdentifier then
                    if cnt == 5 then
                        if v2.syncOwner == myIdentifier then
                            TriggerServerEvent('KmF_Lab:Server:SyncCrafting', myLab['LabID'], k2, myLab['Crafting']['Tables'][k2])
                            cnt = 0
                        end
                    end
                end
            else
                if v2.syncOwner == myIdentifier then
                    cnt = 0
                end
                v2.percentage = 100
                v2.ready = true
                v2.remainingTime = nil
                if v2.syncOwner == myIdentifier then
                    TriggerServerEvent('KmF_Lab:Server:SyncCrafting', myLab['LabID'], k2, myLab['Crafting']['Tables'][k2])
                end
                break
              end

              SendNUIMessage({
                action = 'setLab',
                data = {
                  lab = myLab,
                }
              })
            end
          end
        end
      else
        sleep = 10000
      end
    Citizen.Wait(sleep)
    end
end)

RegisterNUICallback('craft', function(data)
    local tableKey = nil

    for k, v in pairs(myLab['Crafting']['Tables']) do
        if v.item == nil then
            tableKey = k
            break
        end
    end

    if tableKey == nil then
        ESX.ShowNotification('Non ci sono tavoli liberi', 'error')
        return
    end

    data.item['tableKey'] = tableKey

    -- print('ITEM: ' .. data.item .. ' TABLE: ' .. tableKey)

    myLab['Crafting']['Tables'][tableKey]['item'] = data.item
    -- TriggerServerEvent('KmF_Lab:Server:SyncCrafting', myLab['LabID'], tableKey, myLab['Crafting']['Tables'][tableKey])
end)

RegisterNUICallback('buyLab', function(data)
    SetNuiFocus(false, false)
    TriggerScreenblurFadeOut(1000)
    if data.buy then
        ESX.TriggerServerCallback('KmF_Lab:Server:BuyLab', function(cb)
            if cb.status then
                ESX.ShowNotification('Laboratorio acquistato con successo', 'success')
            else
                ESX.ShowNotification(cb.reason, 'error')
            end
        end)
    end
end)

function toggleLabNui()
    if myIdentifier == nil then
        ESX.TriggerServerCallback('KmF_Lab:Server:GetPlayerIdentifier', function( identifier )
            myIdentifier = identifier
        end)
    end

    while myIdentifier == nil do
        Wait(100)
    end

    if myLab == nil then
        SendNUIMessage({
            action = 'showBuyDialog',
            data = {
              toggle = true,
              config = Config
            }
        })
        SetNuiFocus(true, true)
        TriggerScreenblurFadeIn(1000)
        return
    end

    if isInNui then isInNui = false 
    elseif not isInNui then isInNui = true end

    SendNUIMessage({
        action = 'showUi',
        data = {
            toggle = isInNui,
            lab = myLab,
            myIdentifier = myIdentifier,
            config = Config,
        }
    })

    SetNuiFocus(isInNui, isInNui)
    TriggerScreenblurFadeIn(1000)
end

RegisterNUICallback('rechargeAccount', function(data)
    -- print('Callback received ' .. data.money)
    ESX.TriggerServerCallback('KmF_Lab:Server:RechargeAccount', function(cb)
        if cb.status then
            ESX.ShowNotification('Conto ricaricato con successo', 'success')
        else
            ESX.ShowNotification(cb.reason, 'error')
        end
    end, myLab['LabID'], data.money)
end)

RegisterNUICallback('buyLabUpgrade', function(data)
    -- print('Buying upgrade ' .. data.type .. ' ' .. data.id)
    ESX.TriggerServerCallback('KmF_Lab:Server:BuyUpgrade', function(cb)
        if cb.status then
            if data.type == 'lab' then
                ESX.ShowNotification('Laboratorio acquistato con successo', 'success')
            else
                ESX.ShowNotification('Upgrade acquistato con successo', 'success')
            end
        else
            ESX.ShowNotification(cb.reason, 'error')
        end
    end, myLab['LabID'], data.type, data.id)
end)

RegisterNUICallback('closeMenu', function(data, cb)
    isInNui = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'showUi',
        data = false
    })
    TriggerScreenblurFadeOut(1000)
end)

RegisterNUICallback('resetCraft', function(data)
    ESX.TriggerServerCallback('KmF_Lab:Server:ResetCraft', function(cb)
        if cb.status then
            ESX.ShowNotification('Oggetto ritirato ed inviato al deposito', 'success')
        else
            ESX.ShowNotification(cb.reason, 'error')
        end
    end, myLab['LabID'], tonumber(data.id))
end)

RegisterNUICallback('withdrawDepositItem', function(data)
    ESX.TriggerServerCallback('KmF_Lab:Server:WithdrawItem', function(cb)
        if cb.status then
            ESX.ShowNotification('Oggetto ritirato con successo', 'success')
        else
            ESX.ShowNotification(cb.reason, 'error')
        end
    end, myLab['LabID'], data.item, data.qty)
end)

RegisterNUICallback('AddItemToDeposit', function(data)
    local item = data.item
    local amount = data.qty

    ESX.TriggerServerCallback('KmF_Lab:Server:GetDepositCapability', function(capability)
        if tonumber(capability.capability) >= tonumber(amount) then
            ESX.TriggerServerCallback('KmF_Lab:Server:DepositItem', function(cb)
                if cb.status then
                    ESX.ShowNotification('Oggetto aggiunto al deposito con successo', 'success')
                else
                    ESX.ShowNotification(cb.reason, 'error')
                end
            end, myLab['LabID'], item, amount)
        else
            ESX.ShowNotification('Non c\'è abbastanza spazio nel deposito', 'error')
        end
    end, myLab['LabID'])
end)

RegisterNUICallback('startCraft', function(data)
    local item = data.item

    tableKey = nil

    for k, v in pairs(myLab['Crafting']['Tables']) do
        if not v.locked then
            if not v.item then
                tableKey = k
                break
            end
        end
    end

    if tableKey == nil then
        ESX.ShowNotification('Non ci sono tavoli liberi', 'error')
        return
    end

    ESX.TriggerServerCallback('KmF_Lab:Server:CraftItem', function(cb)

        if cb.status then
            myLab['Crafting']['Tables'][tableKey]['item'] = item
            myLab['Crafting']['Tables'][tableKey]['syncOwner'] = myIdentifier

            TriggerServerEvent('KmF_Lab:Server:SyncCrafting', myLab['LabID'], tableKey, myLab['Crafting']['Tables'][tableKey])
            ESX.ShowNotification('Lavorazione avviata con successo', 'success')
        else
            ESX.ShowNotification(cb.reason, 'error')
        end
    end, myLab['LabID'], tableKey, item)
end)

RegisterNetEvent('KmF_Lab:Client:SetLab')
AddEventHandler('KmF_Lab:Client:SetLab', function(lab)
    myLab = lab
    -- print('UPDATED LAB, ID: ' .. myLab['LabID'])
    if isInNui then
        SendNUIMessage({
            action = 'setLab',
            data = {
                lab = myLab,
            }
        })
    end
end)

RegisterNUICallback('GetInventoryItems', function()
    ESX.TriggerServerCallback('KmF_Lab:Server:GetInventoryItems', function(items)
        SendNUIMessage({
            action = 'SetInventoryItems',
            data = items,
        })
    end)
end)

RegisterNetEvent('KmF_Lab:Client:Notify')
AddEventHandler('KmF_Lab:Client:Notify', function(msg, type)
    ESX.ShowNotification(msg, type)
end)

RegisterCommand('registerlab', function(source, args, rawCommand)
    TriggerEvent('KmF_Lab:Client:RegisterLab')
end, true)

RegisterNUICallback("hireEmployee", function( data )
    ESX.TriggerServerCallback('KmF_Lab:Server:Hire', function( cb )
        if cb.status then
            ESX.ShowNotification('Dipendente assunto con successo', 'success')
        else
            ESX.ShowNotification(cb.reason, 'error')
        end
    end, myLab.LabID, data.employeeId )

end)

RegisterNUICallback("fireEmployee", function(data)
    local employeeId = data.employee

    ESX.TriggerServerCallback('KmF_Lab:Server:FireEmployee', function(cb)
        if cb.status then
            ESX.ShowNotification('Dipendente licenziato con successo', 'success')
        else
            ESX.ShowNotification(cb.reason, 'error')
        end
    end, myLab['LabID'], employeeId)
end)

RegisterNUICallback("promoteEmployee", function(data)
    local employee = data.employee
    -- print(employee)

    ESX.TriggerServerCallback('KmF_Lab:Server:PromoteEmployee', function(cb)
        if cb.status then
            ESX.ShowNotification('Dipendente promosso con successo', 'success')
        else
            ESX.ShowNotification(cb.reason, 'error')
        end
    end, myLab['LabID'], employee)
end)

RegisterNUICallback("degradeEmployee", function(data)
    local employee = data.employee

    ESX.TriggerServerCallback('KmF_Lab:Server:DegradeEmployee', function(cb)
        if cb.status then
            ESX.ShowNotification('Dipendente declassato con successo', 'success')
        else
            ESX.ShowNotification(cb.reason, 'error')
        end
    end, myLab['LabID'], employee)
end)

function RegisterLab()
    TriggerServerEvent('KmF_Lab:Server:RegisterLab')
end

-- DEBUG COMMANDS
if Config.Debug then
    RegisterCommand('createlab', function(source, args, rawCommand)
        TriggerServerEvent('KmF_Lab:Server:CreateLab')
    end)

    RegisterCommand('testnui', function(source, args, rawCommand)
        toggleLabNui()
    end, false)

    RegisterCommand('loadlabs', function(source, args, rawCommand)
        TriggerServerEvent('KmF_Lab:Server:LoadLabs')
    end, false)

    RegisterCommand('wipelabs', function(source, args, rawCommand)
        TriggerServerEvent('KmF_Lab:Server:WipeLabs')
    end, false)

    RegisterCommand('wipelab', function(source, args, rawCommand)
        local labId = args[1] or nil

        if labId == nil then
            ESX.ShowNotification('Devi specificare un Lab ID', 'error')
            return
        end

        TriggerServerEvent('KmF_Lab:Server:WipeLab', labId)
    end, false)
end

RegisterCommand('savelabs', function(source, args, rawCommand)
    TriggerServerEvent('KmF_Lab:Server:SaveLabs')
end, false)

-- MARKER / POLYZONE
Citizen.CreateThread(function()
    for k, v in pairs(Config.LabPositions) do

        exports.ox_target:addBoxZone({
            coords = v.position,
            size = v.size,
            rotation = v.rotation,
            debug = false,
            options = {
                {
                    type = "client",
                    event = "KmF_Lab:Client:OpenLabUI",
                    icon = 'fa-solid fa-computer',
                    label = "Gestione laboratorio",
                },
            },
        })

        TriggerEvent('gridsystem:registerMarker', {
            name = "lab_"..k,
            pos = v.position + vector3(0.0, 0.0, 0.5),
            scale = vector3(0.2, 0.2, 0.2),
            rot = vector3(90.0, 0.0, 90.0),
            msg = '',
            InteractDistance = 0.0,
            drawDistance = 10.0,
            control = 'E',
            type = 9,
            bump = true,
            rotate = false,
            faceCamera = true,
            color = { r = 255, g = 255, b = 255, a = 200 },
            textureDict = 'marker',
            textureName = 'pc',
        })

        if v.blip then
            local blip = AddBlipForCoord(v.position)
            SetBlipSprite(blip, 499)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, v.blip.scale)
            SetBlipColour(blip, v.blip.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.blip.label)
            EndTextCommandSetBlipName(blip)
        end

    end
end)

-- NPCS

Citizen.CreateThread(function()
    local hash = GetHashKey("s_m_m_doctor_01")
    while not HasModelLoaded(hash) do
        RequestModel(hash)
        Wait(20)
    end

    local npc = CreatePed(4, hash, vector4(890.30, -3203.14, -99.20, 54.97), false, true)
    SetEntityHeading(npc, 90.0)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    SetPedDiesWhenInjured(npc, false)
    SetPedCanPlayAmbientAnims(npc, true)
    SetPedCanRagdollFromPlayerImpact(npc, false)
    SetEntityCanBeDamaged(npc, false)
    SetPedCanRagdoll(npc, false)
    SetPedCanSwitchWeapon(npc, false)
    SetPedCombatAttributes(npc, 46, true)
    SetPedFleeAttributes(npc, 0, 0)
    SetPedConfigFlag(npc, 118, true)
end)


local bunkerPoly = BoxZone:Create(Config.LabPolyzone, 2.0,  2.0, {
    name="bunker",
    offset={0.0, 0.0, 0.0},
    scale={110.0, 90.0, 1.0},
    debugPoly= false,
    minZ = (-101.5),
    maxZ = (-80.5),
})


Citizen.CreateThread(function()
    while true do
        local sleep = 1500
        if isInPolyzone then
            -- print('in garage')
            sleep = 1
            HideMinimapExteriorMapThisFrame()
            SetRadarZoom(10)
        else
            -- print('out garage')
            HideMinimapInteriorMapThisFrame()
            sleep = 1500
        end
        Citizen.Wait(sleep)
    end
end)

bunkerPoly:onPointInOut(PolyZone.getPlayerPosition, function(isPointInside, point)
    if isPointInside then
        isInPolyzone = true
        -- TriggerServerEvent('KmF_DealerShip:Server:SetInInterior', true)
        -- print('in garage')
    else
        isInPolyzone = false
        -- print('out garage')
        -- TriggerServerEvent('KmF_DealerShip:Server:SetInInterior', false)
    end
end)

for k, v in pairs(Config.FakeLabPositions) do
    TriggerEvent('gridsystem:registerMarker', {
        name = "labFake_"..k,
        pos = v + vector3(0.0, 0.0, 1.0),
        scale = vector3(0.3, 0.3, 0.3),
        rot = vector3(90.0, 0.0, 90.0),
        msg = 'Raccogli scatole',
        InteractDistance = 1.0,
        drawDistance = 10.0,
        control = 'E',
        type = 9,
        bump = true,
        rotate = false,
        faceCamera = true,
        color = { r = 255, g = 255, b = 255, a = 200 },
        textureDict = 'marker',
        textureName = 'Code',
        action = function()

            exports.rprogress:Custom({
                Async = false,
                canCancel = true,       -- Allow cancelling
                cancelKey = 178,        -- Custom cancel key
                x = 0.5,                -- Position on x-axis
                y = 0.5,                -- Position on y-axis
                From = 0,               -- Percentage to start from
                To = 100,               -- Percentage to end
                Duration = 1000,        -- Duration of the progress
                Radius = 40,            -- Radius of the dial
                Stroke = 8,            -- Thickness of the progress dial
                Cap = 'butt',           -- or 'round'
                Padding = 0,            -- Padding between the progress dial and the background dial
                MaxAngle = 360,         -- Maximum sweep angle of the dial in degrees
                Rotation = 0,           -- 2D rotation of the dial in degrees
                Width = 300,            -- Width of bar in px if Type = 'linear'
                Height = 40,            -- Height of bar in px if Type = 'linear'
                ShowTimer = false,       -- Shows the timer countdown within the radial dial
                ShowProgress = false,   -- Shows the progress % within the radial dial    
                Easing = "easeLinear",
                Label = "Raccogliendo la scatola",
                LabelPosition = "bottom",
                Color = "rgba(255, 255, 255, 1.0)",
                BGColor = "rgba(0, 0, 0, 0.4)",
                DisableControls = {
                    Mouse = true,
                    Player = true,
                    Vehicle = true
                },
                onStart = function()
                    -- do something when progress starts
                end,
                onComplete = function(cancelled)
                    local token = exports["bs_tokens"]:getToken()

                    TriggerServerEvent('KmF_Lab:Server:GiveRandomBox', token)
                end
            })

        end
    })
end

RegisterNUICallback('attack/buySpy', function()
    ESX.TriggerServerCallback('KmF_Lab:Server:BuySpy', function(cb)
        if cb.status then
            ESX.ShowNotification('Spia acquistata con successo', 'success')
        else
            ESX.ShowNotification(cb.reason, 'error')
        end
    end, myLab['LabID'])
end)