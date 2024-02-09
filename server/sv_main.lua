ESX = exports.es_extended:getSharedObject()

local LabsData = {}

local Labs = {}

AddEventHandler('onResourceStart', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then
    return
  end

  Labs.LoadLabs()
end)

Labs.LoadLabs = function()
  Citizen.Wait(500)
  MySQL.Async.fetchAll('SELECT * FROM kmf_lab', {}, function(result)
    if result ~= nil then
      for k, v in pairs(result) do
        DebugPrint('Setting up data for lab: ' .. v.LabID)

        LabsData[v.LabID] = {
          LabID = v.LabID,
          Owner = v.Owner,
          LabInfo = json.decode(v.LabInfo),
          Employees = json.decode(v.Employees),
          Deposit = json.decode(v.Deposit),
          Accounts = json.decode(v.Accounts),
          BoughtUpgrades = json.decode(v.BoughtUpgrades),
          BoughtLabs = json.decode(v.BoughtLabs),
          Crafting = json.decode(v.Crafting),
        }

        -- print(ESX.DumpTable(LabsData[v.LabID]['BoughtUpgrades']))

        if LabsData[v.LabID]['LabInfo'].DailyChest == nil or LabsData[v.LabID]['LabInfo'].DailyChest == 0 then
          LabsData[v.LabID]['LabInfo'].DailyChest = exports.KmF_Lib:convertToSeconds(os.date('%Y-%m-%d %H:%M:%S', os.time()))
        end
        
        if LabsData[v.LabID]['BoughtUpgrades']['crafting_table_upgrade']['level'] <= 1 then
          -- print('Removing crafting table from lab ' .. v.LabID)
          LabsData[v.LabID]['Crafting']['Tables'] = {
            {
              key = 0,
              item = nil,
              remainingTime = nil,
              percentage = nil,
              ready = false,
              locked = false,   
            },
          }
        end

        if not LabsData[v.LabID]['Crafting'].Queues then
          LabsData[v.LabID]['Crafting'].Queues = {}
          for x, y in pairs(LabsData[v.LabID]['Crafting']['Tables']) do
            if not y.locked then
              LabsData[v.LabID]['Crafting'].Queues[x] = {}
            end
          end
        end

        for x, y in pairs(LabsData[v.LabID]['Crafting']['Tables']) do
          if y.locked then
            y.locked = false
          end
        end

        for x, y in pairs(Config.UpgradesList) do
          local present = false
          for k2, v2 in pairs(LabsData[v.LabID].BoughtUpgrades) do
            if k2 == x then
              present = true
              break
            end
          end

          -- print('Present: ' .. tostring(present))
          if not present then
            LabsData[v.LabID]['BoughtUpgrades'][x] = y
            if not v.max_level then
              LabsData[v.LabID]['BoughtUpgrades'][x].cooldown = 0
            end
            -- print('Added upgrade ' .. k .. ' to lab ' .. v.LabID)
          end
        end

        for idx, value in pairs(LabsData[v.LabID]['Employees']) do
          -- DebugPrint('^00^11^22^33^44^55^66^77^88^99')
          DebugPrint('^5[' .. v.LabID .. '] -> ^3Sending lab to player ' .. idx)
          local xPlayer = ESX.GetPlayerFromIdentifier(idx)
          if xPlayer then
            TriggerClientEvent('KmF_Lab:Client:SetLab', xPlayer.source, LabsData[v.LabID])
          end
        end
        -- Labs.UpdateLabEmployees(v.LabID)
      end
      DebugPrint('Loaded ' .. #result .. ' labs from database')
    end
  end)
  return true
end

Labs.WipeLabs = function()
  MySQL.Async.execute('DELETE FROM kmf_lab', {}, function(rowsChanged)
    if rowsChanged > 0 then
      DebugPrint('^1Wiped ' .. rowsChanged .. ' labs from database')
    else
      DebugPrint('^8[ERROR] ^1Labs not wiped')
    end
  end)
  return true
end

RegisterServerEvent('KmF_Lab:Server:WipeLabs')
AddEventHandler('KmF_Lab:Server:WipeLabs', function()
  Labs.WipeLabs()
end)

RegisterServerEvent('KmF_Lab:Server:LoadLabs')
AddEventHandler('KmF_Lab:Server:LoadLabs', function()
  Labs.LoadLabs()
end)

RegisterServerEvent('KmF_Lab:Server:SaveLabs')
AddEventHandler('KmF_Lab:Server:SaveLabs', function()
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)

  if xPlayer.getGroup() == 'superadmin' or xPlayer.getGroup() == 'admin' then
    Labs.SaveLabs()
    TriggerClientEvent('esx:showNotification', src, 'Laboratori salvati', 'success')
  else
    TriggerClientEvent('esx:showNotification', src, 'Non hai i permessi per eseguire questo comando', 'error')
  end
end)

AddEventHandler('onResourceStop', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then
    return
  end

  Labs.SaveLabs()
end)

ESX.RegisterServerCallback('KmF_Lab:Server:GetPlayerIdentifier', function(source, cb)
  local xPlayer = ESX.GetPlayerFromId(source)
  cb(xPlayer.identifier)
end)

Labs.SaveLabs = function()
  for k, v in pairs(LabsData) do
    MySQL.Async.fetchAll('INSERT INTO kmf_lab (LabID, Owner, LabInfo, Employees, Deposit, Accounts, BoughtUpgrades, BoughtLabs, Crafting) VALUES(@LabID, @Owner, @LabInfo, @Employees, @Deposit, @Accounts, @BoughtUpgrades, @BoughtLabs, @Crafting) ON DUPLICATE KEY UPDATE LabID=@LabID, Owner=@Owner, LabInfo=@LabInfo,Employees=@Employees, Deposit=@Deposit, Accounts=@Accounts, BoughtUpgrades=@BoughtUpgrades, BoughtLabs=@BoughtLabs, Crafting=@Crafting', {
      ['@LabID'] = v.LabID,
      ['@Owner'] = v.Owner,
      ['@LabInfo'] = json.encode(v.LabInfo),
      ['@Employees'] = json.encode(v.Employees),
      ['@Deposit'] = json.encode(v.Deposit),
      ['@Accounts'] = json.encode(v.Accounts),
      ['@BoughtUpgrades'] = json.encode(v.BoughtUpgrades),
      ['@BoughtLabs'] = json.encode(v.BoughtLabs),
      ['@Crafting'] = json.encode(v.Crafting),
    }, function(rowsChanged)
      -- print('RC: ' .. #rowsChanged)
      if #rowsChanged > 0 then
        DebugPrint('^9[INFO] ^5Lab ' .. v.LabID .. ' saved')
      else
        DebugPrint('^8[ERROR] ^1Lab ' .. v.LabID .. ' not saved')
      end
    end)
  end
  return true
end

Labs.GetLabs = function() 
  return
end

ESX.RegisterServerCallback('KmF_Lab:Server:BuyLab', function(source, cb)
  local xPlayer = ESX.GetPlayerFromId(source)

  if Labs.CheckEmployee({identifier = identifier}).status then
    cb({ status = false, reason = 'Sei gia in un laboratorio' })
    return
  end

  local money = exports['qs-inventory']:GetItemTotalAmount(xPlayer.source, 'black_money')

  if money >= Config.LabPrice then
    exports['qs-inventory']:RemoveItem(xPlayer.source, 'black_money', Config.LabPrice)
    Labs.CreateLab(xPlayer)
    cb({ status = true })
  else
    cb({ status = false, reason = 'Non hai abbastanza denaro sporco' })
  end
end)

Labs.AddNewTable = function ( labID )
  local newTable = {
    key = #LabsData[labID]['Crafting']['Tables'],
    item = nil,
    remainingTime = nil,
    percentage = nil,
    ready = false,
    locked = false,   
  }

  table.insert(LabsData[labID]['Crafting']['Tables'], newTable)
end

ESX.RegisterServerCallback('KmF_Lab:Server:GetDailyChest', function(src, cb, labId)
  local xPlayer = ESX.GetPlayerFromId(src)
  local currentTime = exports.KmF_Lib:convertToSeconds(os.date('%Y-%m-%d %H:%M:%S', os.time()))
  if LabsData[labId]['LabInfo'].DailyChest > currentTime then
    TriggerClientEvent('esx:showNotification', src, 'Hai gia ritirato la cassa gratuita giornaliera oggi, torna domani!', 'error')
    cb({status = false, lab = LabsData[labId]})
  end

  if LabsData[labId]['LabInfo'].DailyChest <= currentTime then
    if xPlayer.canCarryItem('lab_lootbox', 1) then
      xPlayer.addInventoryItem('lab_lootbox', 1)
      TriggerClientEvent('esx:showNotification', src, 'Hai ritirato la tua cassa gratuita giornaliera!', 'success')
      LabsData[labId]['LabInfo'].DailyChest = exports.KmF_Lib:convertToSeconds(os.date('%Y-%m-%d %H:%M:%S', os.time())) + 86400
      cb({status = true, lab = LabsData[labId]})
      -- UpdateLabEmployees(labId)
      Labs.UpdateLabEmployees(labId)
      return
    else
      TriggerClientEvent('esx:showNotification', src, 'Non hai abbastanza spazio per ritirare la cassa gratuita giornaliera', 'error')
      cb({status = false, lab = LabsData[labId]})
      return
    end
  end
end)

Labs.CreateLab = function ( xOwner )
  local identifier = xOwner.identifier

  if Labs.CheckEmployee({identifier = identifier}).status then
    -- print('Employee already in a lab')
    return
  end
  -- identifier = string.sub(identifier, 7)
  
  -- Generate 24 char random string aA1
  local charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
  local length = 24
  local randomString = ''

  math.randomseed(os.time())

  for i = 1, length do
    local rand = math.random(1, #charset)
    randomString = randomString .. charset:sub(rand, rand)
  end

  local labIdentifier = 'lab:'..randomString
  
  local upgrades = {}
  for k, v in pairs(Config.UpgradesList) do
    upgrades[k] = v
    if not v.max_level then
      upgrades[k].cooldown = 0
    end
  end

  LabsData[labIdentifier] = {
    LabID = labIdentifier,
    Owner = xOwner.identifier,
    LabInfo = {
      MaxEmployees = 10,
      MaxDeposit = 100,
      AttackPower = 0,
      MaxAttackPower = 100,
      DefencePower = 0,
      MaxDefencePower = 100,
      DailyChest = exports.KmF_Lib:convertToSeconds(os.date('%Y-%m-%d %H:%M:%S', os.time())),
    },
    Employees = {
      [xOwner.identifier] = {
        Name = xOwner.name,
        Grade = 3,
        GradeLabel = 'PROPRIETARIO',
        Assumption = os.date('%d/%m/%Y %H:%M:%S'),
      }
    },
    Deposit = {
    },
    Accounts = {
      Balance = 0,
      Tax = Config.LabTaxPrice,
    },
    BoughtUpgrades = upgrades,
    BoughtLabs = {
    },
    Crafting = {
      Tables = {
        {
          key = 0,
          item = nil,
          remainingTime = nil,
          percentage = nil,
          ready = false,
          locked = false,   
        },
        -- {
        --   key = 1,
        --   item = nil,
        --   remainingTime = nil,
        --   percentage = nil,
        --   ready = false,
        --   locked = true,   
        -- },
        -- {
        --   key = 2,
        --   item = nil,
        --   remainingTime = nil,
        --   percentage = nil,
        --   ready = false,
        --   locked = true,   
        -- },
      },
      Recipes = {
        'default',

      },
    }
  }

  TriggerClientEvent('KmF_Lab:Client:SetLab', xOwner.source, LabsData[labIdentifier])

  exports['KmF_Lib']:DiscordLog('lab', 'Laboratorio creato', 
  'LabID: ' .. labIdentifier .. 
  '\nProprietario: ' .. GetPlayerName(xOwner.source) .. 
  '\nLicense: ' .. xOwner.identifier ..
  '\nData: ' .. os.date('%d/%m/%Y %H:%M:%S'))
  
  DebugPrint('Lab created with ID ' .. labIdentifier)
  -- print(ESX.DumpTable(LabsData))
end

Labs.DeleteLab = function ( LabId )
  for k, v in pairs(LabsData) do
    if v.LabID == LabId then
      table.remove(LabsData, k)

      exports['KmF_Lib']:DiscordLog('lab', 'Laboratorio eliminato',
      'LabID: ' .. LabId)

      return true
    end
  end

  Labs.UpdateLabEmployees(LabId)

  return false
end

Labs.RemoveDepositItem = function ( LabId, Item, Qty )
  for k, v in pairs(LabsData[LabId]['Deposit']) do
    if v.name == Item then
      if v.qty == Qty then
        LabsData[LabId]['Deposit'][k] = nil
        Labs.UpdateLabEmployees(LabId)
        return true
      else
        if tonumber(v.qty) >= tonumber(Qty) then
          v.qty = tonumber(v.qty) - tonumber(Qty)
          Labs.UpdateLabEmployees(LabId)

          return true
        else
          return false
        end
      end
    end
  end
end

ESX.RegisterServerCallback('KmF_Lab:Server:GetPlayerLab', function(source, cb)
  local xPlayer = ESX.GetPlayerFromId(source)
  if xPlayer then
    local identifier = xPlayer.identifier
    local labId = Labs.CheckEmployee({identifier = identifier}).lab

    if labId == nil then
      cb({ lab = nil })
      return
    end
    cb({ lab = LabsData[labId], labId = labId })
  end
end)

Labs.AddDepositItem = function ( LabId, Item, Qty )
  for k, v in pairs(LabsData[LabId]['Deposit']) do
    if v.name == Item.name then
      v.qty = v.qty + Qty

      Labs.UpdateLabEmployees(LabId)
      return true
    end
  end

  LabsData[LabId]['Deposit'][Item.name] = {
    name = Item.name,
    label = Item.label,
    qty = Qty,
    type = Item.type,
  }

  Labs.UpdateLabEmployees(LabId)

  return true
end

Labs.SyncClientCrafting = function(LabID, CTableKey, CTable)
  DebugPrint('CRAFTING_SYNC - Received crafting sync request for lab ' .. LabID .. ' by ' .. CTable['syncOwner'])
  for k, v in pairs(LabsData[LabID]['Employees']) do
    local xPlayer = ESX.GetPlayerFromIdentifier(k)
    if xPlayer then

      DebugPrint('Syncing crafting for player ' .. xPlayer.name .. '[' .. xPlayer.identifier .. ']')
      if CTable['syncOwner'] == k then
        DebugPrint('CRAFTING_SYNC - User ' .. xPlayer.name .. ' is the SyncOwner, ignoring sync')
      else
        TriggerClientEvent('KmF_Lab:Client:SyncCrafting', xPlayer.source, CTableKey, CTable, CTable['syncOwner'])
      end

    end
  end
end

RegisterServerEvent('KmF_Lab:Server:SyncCrafting')
AddEventHandler('KmF_Lab:Server:SyncCrafting', function(LabId, CTableKey, CTable)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)
  local identifier = xPlayer.identifier

  DebugPrint('CRAFTING_SYNC - Received crafting sync request from player ' .. identifier .. ' for Lab ' .. LabId)
  -- print(ESX.DumpTable(CTable))

  LabsData[LabId]['Crafting']['Tables'][CTableKey] = CTable

  -- LabsData[LabId]['Crafting']['Tables'][CTableKey]['syncOwner'] = identifier
  Labs.SyncClientCrafting(LabId, CTableKey, CTable)
end)

Labs.GetDepositItemQty = function ( LabId, ItemName )
  for k, v in pairs(LabsData[LabId]['Deposit']) do
    if v.name == ItemName then
      return v.qty
    end
  end
  return 0
end

ESX.RegisterServerCallback('KmF_Lab:Server:RechargeAccount', function(source, cb, LabId, moneyToCharge)
  local xPlayer = ESX.GetPlayerFromId(source)
  local moneyQty = exports['qs-inventory']:GetItemTotalAmount(xPlayer.source, 'black_money')

  if moneyQty >= tonumber(moneyToCharge) then
    exports['qs-inventory']:RemoveItem(xPlayer.source, 'black_money', tonumber(moneyToCharge))
    LabsData[LabId]['Accounts'].Balance = tonumber(LabsData[LabId]['Accounts'].Balance) + tonumber(moneyToCharge)
    Labs.UpdateLabEmployees(LabId)

    exports['KmF_Lib']:DiscordLog('lab', 'Ricarica conto laboratorio',
    'LabID: ' .. LabId ..
    '\nGiocatore: ' .. GetPlayerName(xPlayer.source) ..
    '\nLicense: ' .. xPlayer.identifier ..
    '\nQuantita: ' .. moneyToCharge)

    cb({status = true})
  else
    cb({status = false, reason = 'Non hai abbastanza denaro sporco'})
  end
end)

Labs.HandleUpgrade = function( LabId, UpgradeId )
  if UpgradeId == 'deposit_upgrade' then
    local level = LabsData[LabId]['BoughtUpgrades'][UpgradeId]['level']

    LabsData[LabId]['LabInfo'].MaxDeposit = LabsData[LabId]['LabInfo'].MaxDeposit + 10
  end

  if UpgradeId == 'crafting_table_upgrade' then
    local level = LabsData[LabId]['BoughtUpgrades'][UpgradeId]['level']

    Labs.AddNewTable(LabId)
  end

  if UpgradeId == 'max_employees_upgrade' then
    local level = LabsData[LabId]['BoughtUpgrades'][UpgradeId]['level']

    LabsData[LabId]['LabInfo'].MaxEmployees = LabsData[LabId]['LabInfo'].MaxEmployees + 1
  end

  if UpgradeId == 'max_attackers_upgrade' then
    local level = LabsData[LabId]['BoughtUpgrades'][UpgradeId]['level']

    LabsData[LabId]['LabInfo'].MaxAttackPower = LabsData[LabId]['LabInfo'].MaxAttackPower + 10
  end

  if UpgradeId == 'max_defenders_upgrade' then
    local level = LabsData[LabId]['BoughtUpgrades'][UpgradeId]['level']

    LabsData[LabId]['LabInfo'].MaxDefencePower = LabsData[LabId]['LabInfo'].MaxDefencePower + 10
  end

  Labs.UpdateLabEmployees(LabId)
end

Labs.BuyUpgrade = function ( LabId, Type, UpgradeId )
  if Type == 'lab' then
    for k, v in pairs(LabsData[LabId]['BoughtLabs']) do
      if k == UpgradeId then
        return { status = false, reason = 'Laboratorio gia acquistato' }
      end
    end

    local moneyQty = LabsData[LabId]['Accounts'].Balance

    if moneyQty >= Config.LabList[UpgradeId].price then
      LabsData[LabId]['Accounts'].Balance = LabsData[LabId]['Accounts'].Balance - Config.LabList[UpgradeId].price
      LabsData[LabId]['Accounts'].Tax = LabsData[LabId]['Accounts'].Tax + Config.LabList[UpgradeId].tax
      LabsData[LabId]['BoughtLabs'][UpgradeId] = ""

      -- print(ESX.DumpTable(LabsData[LabId]['Crafting']))

      LabsData[LabId]['Crafting']['Recipes'][UpgradeId] = ""


      exports['KmF_Lib']:DiscordLog('lab', 'SHOP - Acquisto laboratorio',
      'LabID: ' .. LabId ..
      '\nPrezzo: ' .. Config.LabList[UpgradeId].price .. ' $' ..
      '\nLaboratorio: ' .. UpgradeId)

      -- print(ESX.DumpTable(LabsData[LabId]['Crafting']))
      Labs.UpdateLabEmployees(LabId)
      return { status = true }
    else
      return { status = false, reason = 'Non hai abbastanza saldo nel laboratorio' }
    end
  end

  if Type == 'upgrade' then
    for k, v in pairs(LabsData[LabId]['BoughtUpgrades']) do
      if k == UpgradeId then
        if Config.UpgradesList[UpgradeId].max_level then
          -- print(json.encode(v))

          if v.level >= v.max_level then
            return { status = false, reason = 'Upgrade gia al livello massimo' }
          end

          if Config.UpgradesList[UpgradeId].max_level < v.level then
            v.level = Config.UpgradesList[UpgradeId].max_level
            return { status = false, reason = 'Upgrade gia al livello massimo' }
          end

          if Config.UpgradesList[UpgradeId].cooldown ~= nil then
            if Config.UpgradesList[UpgradeId].cooldown > 0 then
              return { status = false, reason = 'Upgrade in cooldown' }
            end
          end

          local moneyQty = LabsData[LabId]['Accounts'].Balance

          local upgradePrice = math.floor(Config.UpgradesList[UpgradeId].price * math.pow(Config.UpgradesList[UpgradeId].price_multiplier, v.level))


          if moneyQty >= Config.UpgradesList[UpgradeId].price then
            LabsData[LabId]['Accounts'].Balance = LabsData[LabId]['Accounts'].Balance - upgradePrice
            LabsData[LabId]['BoughtUpgrades'][UpgradeId]['level'] = LabsData[LabId]['BoughtUpgrades'][UpgradeId]['level'] + 1
            
            if Config.UpgradesList[UpgradeId].cooldown ~= nil then
              LabsData[LabId]['BoughtUpgrades'][UpgradeId]['cooldown'] = Config.UpgradesList[UpgradeId].cooldown
            end
            
            LabsData[LabId]['BoughtUpgrades'][UpgradeId]['max_level'] = Config.UpgradesList[UpgradeId].max_level or nil

            exports['KmF_Lib']:DiscordLog('lab', 'SHOP - Aggiornamento upgrade',
            'LabID: ' .. LabId ..
            '\nPrezzo: ' .. upgradePrice .. ' $' ..
            '\nUpgrade: ' .. UpgradeId ..
            '\nLivello: ' .. LabsData[LabId]['BoughtUpgrades'][UpgradeId]['level'])


            Labs.HandleUpgrade(LabId, UpgradeId)

            Labs.UpdateLabEmployees(LabId)
            return { status = true }
          else
            return { status = false, reason = 'Non hai abbastanza saldo nel laboratorio' }
          end
        else
          if Config.UpgradesList[UpgradeId].cooldown > 0 then
            return { status = false, reason = 'Upgrade in cooldown' }
          end

          local moneyQty = LabsData[LabId]['Accounts'].Balance

          if moneyQty >= Config.UpgradesList[UpgradeId].price then
            LabsData[LabId]['Accounts'].Balance = LabsData[LabId]['Accounts'].Balance - Config.UpgradesList[UpgradeId].price
            LabsData[LabId]['BoughtUpgrades'][UpgradeId]['cooldown'] = Config.UpgradesList[UpgradeId].cooldown
            
            Labs.HandleUpgrade(LabId, UpgradeId)

            Labs.UpdateLabEmployees(LabId)
            return { status = true }
          else
            return { status = false, reason = 'Non hai abbastanza saldo nel laboratorio' }
          end
        end
      end
    end

    local moneyQty = LabsData[LabId]['Accounts'].Balance

    if moneyQty >= Config.UpgradesList[UpgradeId].price then
      LabsData[LabId]['Accounts'].Balance = LabsData[LabId]['Accounts'].Balance - Config.UpgradesList[UpgradeId].price
      LabsData[LabId]['BoughtUpgrades'][UpgradeId] = ""

      exports['KmF_Lib']:DiscordLog('lab', 'SHOP - Acquisto upgrade',
      'LabID: ' .. LabId ..
      '\nPrezzo: ' .. Config.UpgradesList[UpgradeId].price .. ' $' ..
      '\nUpgrade: ' .. UpgradeId)

      Labs.UpdateLabEmployees(LabId)
      return { status = true }
    else
      return { status = false, reason = 'Non hai abbastanza saldo nel laboratorio' }
    end
  end

  return { status = false, reason = 'Tipo di upgrade non valido' }
end

Labs.GetDepositCapability = function ( LabId )
  local depositQty = 0
  for k, v in pairs(LabsData[LabId]['Deposit']) do
    depositQty = depositQty + v.qty
  end

  return LabsData[LabId]['LabInfo'].MaxDeposit - depositQty
end

Labs.GetDepositTotalItems = function ( LabId )
  local depositQty = 0
  for k, v in pairs(LabsData[LabId]['Deposit']) do
    depositQty = depositQty + 1
  end

  return depositQty
end

ESX.RegisterServerCallback('KmF_Lab:Server:GetDepositCapability', function(source, cb, LabId)
  cb({ capability = Labs.GetDepositCapability(LabId) })
end)

ESX.RegisterServerCallback('KmF_Lab:Server:GetDepositTotalItems', function(source, cb, LabId)
  cb({ totalItems = Labs.GetDepositTotalItems(LabId) })
end)

ESX.RegisterServerCallback('KmF_Lab:Server:BuyUpgrade', function(source, cb, LabId, UpgradeType, UpgradeId)
  local res = Labs.BuyUpgrade(LabId, UpgradeType, UpgradeId)

  if res.status then
    cb({status = true})
  else
    cb({status = false, reason = res.reason})
  end
end)

Labs.CraftItem = function ( LabId, Item )
  local hasItems = true

  for rIdx, req in pairs(Item.requirements) do
    local depQty = Labs.GetDepositItemQty(LabId, req.name)
    if tonumber(depQty) < tonumber(req.count) then
      hasItems = false
      break
    end
  end

  if hasItems then
    for k, v in pairs(Item['requirements']) do
      -- print(json.encode(v))
      Labs.RemoveDepositItem(LabId, v.name, v.count)

      -- exports['KmF_Lib']:DiscordLog('lab', 'Crafting oggetto',
      -- 'LabID: ' .. LabId ..
      -- '\nOggetto: ' .. Item.result.label ..
      -- '\nQuantita: ' .. Item.result.count)

      -- return ({ status = true })
    end
    return ({ status = true })
  else
    return { status = false, reason = 'Il deposito non ha abbastanza risorse' }
  end
end

Labs.ResetCraft = function ( LabId, PosId, src )
  for k, v in pairs(LabsData[LabId]['Crafting']['Tables']) do
    if v.key == PosId then
      local capability = Labs.GetDepositCapability(LabId)
      if capability >= v.item.result.count then

        if LabsData[LabId]['BoughtUpgrades']['crafting_fortune_upgrade'] ~= nil then
          local fortuneLevel = LabsData[LabId]['BoughtUpgrades']['crafting_fortune_upgrade']['level']
          local fortuneChance = fortuneLevel
          local fortuneRoll = math.random(1, 100)
          if fortuneRoll <= fortuneChance then
            v.item.result.count = v.item.result.count + 1
            if src then
              exports['KmF_Lib']:DiscordLog('lab', 'CRAFTING - Fortuna di crafting',
              'LabID: ' .. LabId ..
              '\nGiocatore: ' .. GetPlayerName(src) ..
              '\nLicense: ' .. ESX.GetPlayerFromId(src).identifier ..
              '\nFortuna: ' .. fortuneLevel .. ' [' .. fortuneChance .. '%]')
              TriggerClientEvent('KmF_Lab:Client:Notify', src, 'Che fortuna! Hai ottenuto 1 ' .. v.item.result.label .. ' extra!', 'success')
            end
          end
          
        end

        local xPlayer = ESX.GetPlayerFromId(src)

        exports['KmF_Lib']:DiscordLog('lab', 'Oggetto craftato ritirato',
        'LabID: ' .. LabId ..
        '\nGiocatore: ' .. GetPlayerName(src) .. ' [' .. xPlayer.identifier .. ']' ..
        '\nPostazione: ' .. PosId ..
        '\nOggetto: ' .. v.item.result.label ..
        '\nQuantita: ' .. v.item.result.count)


        Labs.AddDepositItem(LabId, v.item.result, v.item.result.count)
        v.item = nil
        v.percentage = nil
        v.ready = false
        Labs.UpdateLabEmployees(LabId)
        return { status = true }
      else
        return { status = false, reason = 'Il deposito non ha abbastanza spazio'}
      end
    end
  end
  return { status = false, reason = 'Postazione non trovata'}
end

ESX.RegisterServerCallback('KmF_Lab:Server:ResetCraft', function(source, cb, LabId, PosId)
  
  local res = Labs.ResetCraft(LabId, PosId, source)

  if res.status then
    cb({status = true})
  else
    cb({status = false, reason = res.reason})
  end
end)

ESX.RegisterServerCallback('KmF_Lab:Server:CraftItem', function(source, cb, LabId, TableKey, Item)
  local xPlayer = ESX.GetPlayerFromId(source)
  local labDeposit = LabsData[LabId]['Deposit']

  -- DebugPrint(ESX.DumpTable(Item))
  -- print('TK: ' .. TableKey)

  -- Check if item.requirements are in labDeposit
  for k, v in pairs(Item.requirements) do
    if labDeposit[v.name] == nil then
      cb({status = false, reason = 'Non hai abbastanza oggetti'})
      return
    end
    
    if tonumber(labDeposit[v.name].qty) < tonumber(v.count) then
      cb({status = false, reason = 'Non hai abbastanza oggetti'})
      return
    end
  end

  local res = Labs.CraftItem(LabId, Item)

  if res.status then

    exports['KmF_Lib']:DiscordLog('lab', 'Crafting avviato',
    'LabID: ' .. LabId ..
    '\nGiocatore: ' .. GetPlayerName(xPlayer.source) ..
    '\nLicense: ' .. xPlayer.identifier ..
    '\nPostazione: ' .. TableKey ..
    '\nOggetto: ' .. Item.result.label ..
    '\nQuantita: ' .. Item.result.count ..
    '\nRichieste: ' .. json.encode(Item.requirements))


    Labs.RemoveDepositItem(LabId, Item.name, tonumber(Item.qty))
    cb({status = true, tableKey = TableKey})
  else
    cb({status = false, reason = res.reason })
  end
end)

local allitems = exports['qs-inventory']:GetItemList()

ESX.RegisterServerCallback('KmF_Lab:Server:DepositItem', function(source, cb, LabId, item_name, item_qty)
  local src = source
  local inventory = exports['qs-inventory']:GetInventory(src)

  local itemqty = exports['qs-inventory']:GetItemTotalAmount(src, item_name)

  if itemqty < tonumber(item_qty) then
    cb({status = false, reason = 'Non hai abbastanza oggetti'})
    return false
  end

  if Labs.AddDepositItem(LabId, allitems[item_name], item_qty) then
    exports['qs-inventory']:RemoveItem(src, item_name, item_qty)
    cb({status = true})

    local xPlayer = ESX.GetPlayerFromId(src)

    exports['KmF_Lib']:DiscordLog('lab', 'Oggetto depositato nel deposito',
    'LabID: ' .. LabId ..
    '\nGiocatore: ' .. GetPlayerName(src) .. ' [' .. xPlayer.identifier .. ']' ..
    '\nOggetto: ' .. item_name ..
    '\nQuantita: ' .. item_qty)

    return true
  else
    cb({status = false, reason = 'Errore durante il deposito degli oggetti'})
    return false
  end

  return false
end)

ESX.RegisterServerCallback('KmF_Lab:Server:WithdrawItem', function(source, cb, LabId, item_name, item_qty)
  local src = source
  local inventory = exports['qs-inventory']:GetInventory(src)
  local xPlayer = ESX.GetPlayerFromId(src)

  if xPlayer.canCarryItem(item_name, item_qty) == false then
    cb({status = false, reason = 'Non hai abbastanza spazio'})
    return
  end

  if Labs.RemoveDepositItem(LabId, item_name, item_qty) then
    exports['qs-inventory']:AddItem(src, item_name, item_qty)

    local xPlayer = ESX.GetPlayerFromId(src)

    exports['KmF_Lib']:DiscordLog('lab', 'Oggetto prelevato dal deposito',
    'LabID: ' .. LabId ..
    '\nGiocatore: ' .. GetPlayerName(src) .. ' [' .. xPlayer.identifier .. ']' ..
    '\nOggetto: ' .. item_name ..
    '\nQuantita: ' .. item_qty)

    cb({status = true})
  else
    cb({status = false, reason = 'Errore durante il prelievo degli oggetti'})
  end
end)

Labs.CheckEmployee = function ( Employee )
  for k, v in pairs(LabsData) do
    if v.Employees[Employee.identifier] ~= nil then
      -- print('Employee found in lab ' .. v.LabID)
      return { status = true, lab = v.LabID }
    end
  end
  return { status = false }
end

Labs.AddEmployee = function ( LabId, Employee )
  if LabsData[LabId]['Employees'][Employee.identifier] ~= nil then
    return false
  end

  if Labs.CheckEmployee(Employee).status then
    return false
  end

  LabsData[LabId]['Employees'][Employee.identifier] = {
    Name = Employee.name,
    Grade = 1,
    GradeLabel = 'Dipendente',
    Assumption = os.date('%d/%m/%Y %H:%M:%S'),
  }

  exports['KmF_Lib']:DiscordLog('lab', 'Dipendente assunto',
  'LabID: ' .. LabId ..
  '\nGiocatore: ' .. Employee.name .. ' [' .. Employee.identifier .. ']')


  TriggerClientEvent('KmF_Lab:Client:Notify', Employee.source, 'Sei stato assunto in un laboratorio', 'success')

  Labs.UpdateLabEmployees(LabId)

  -- print(ESX.DumpTable(LabsData))

  DebugPrint('Employee added to lab ' .. LabId)
  return true
end

Labs.FireEmployee = function ( LabId, Employee )
  if LabsData[LabId]['Employees'][Employee] == nil then
    -- print('NO ID XD')
    return false
  end

  LabsData[LabId]['Employees'][Employee] = nil
  local xEmployee = ESX.GetPlayerFromIdentifier(Employee)
  if xEmployee then
    -- print('Player found')
    TriggerClientEvent('KmF_Lab:Client:Notify', xEmployee.source, 'Sei stato licenziato da un laboratorio', 'error')
  end

  exports['KmF_Lib']:DiscordLog('lab', 'Dipendente licenziato',
  'LabID: ' .. LabId ..
  '\nIdentifier: ' .. Employee)
  Labs.UpdateLabEmployees(LabId)

  DebugPrint('Employee fired from lab ' .. LabId)
  return true
end

Labs.PromoteEmployee = function ( LabId, Employee )
  -- print(Employee)
  if LabsData[LabId]['Employees'][Employee] == nil then
    -- print('hee 1')
    return false
  end

  if LabsData[LabId]['Employees'][Employee]['Grade'] == 3 then
    -- print('hee 2')
    return false
  end

  LabsData[LabId]['Employees'][Employee]['Grade'] = LabsData[LabId]['Employees'][Employee]['Grade'] + 1
  LabsData[LabId]['Employees'][Employee]['GradeLabel'] = 'Manager'

  local xEmployee = ESX.GetPlayerFromIdentifier(Employee)
  if xEmployee then
    TriggerClientEvent('KmF_Lab:Client:Notify', xEmployee.source, 'Sei stato promosso a Manager nel tuo laboratorio', 'success')
  end


  exports['KmF_Lib']:DiscordLog('lab', 'Dipendente promosso',
  'LabID: ' .. LabId ..
  '\nGiocatore: ' .. Employee)

  Labs.UpdateLabEmployees(LabId)

  DebugPrint('Employee promoted in lab ' .. LabId)
  return true
end

Labs.DegradeEmployee = function ( LabId, Employee )
  if LabsData[LabId]['Employees'][Employee] == nil then
    return false
  end

  if LabsData[LabId]['Employees'][Employee]['Grade'] == 1 then
    return false
  end

  LabsData[LabId]['Employees'][Employee]['Grade'] = LabsData[LabId]['Employees'][Employee]['Grade'] - 1
  LabsData[LabId]['Employees'][Employee]['GradeLabel'] = 'Dipendente'

  local xEmployee = ESX.GetPlayerFromIdentifier(Employee)
  if xEmployee then
    TriggerClientEvent('KmF_Lab:Client:Notify', xEmployee.source, 'Sei stato degradato a Dipendente nel tuo laboratorio', 'error')
  end

  exports['KmF_Lib']:DiscordLog('lab', 'Dipendente degradato',
  'LabID: ' .. LabId ..
  '\nGiocatore: ' .. Employee.name .. ' [' .. Employee.identifier .. ']')

  Labs.UpdateLabEmployees(LabId)

  DebugPrint('Employee degraded in lab ' .. LabId)
  return true
end

Labs.UpdateLabEmployees = function ( LabId )
  for k, v in pairs(LabsData[LabId]['Employees']) do
    -- print('Updating lab for player ' .. k)
    local xPlayer = ESX.GetPlayerFromIdentifier(k)
    -- print(xPlayer.source)
    if xPlayer then
      -- Citizen.Wait(1000)
      TriggerClientEvent('KmF_Lab:Client:SetLab', xPlayer.source, LabsData[LabId])
      -- print('Updated lab for player ' .. xPlayer.name)
    else
      -- print('Player not found')
    end
  end
end

RegisterServerEvent('KmF_Lab:Server:CreateLab')
AddEventHandler('KmF_Lab:Server:CreateLab', function()
  local xOwner = ESX.GetPlayerFromId(source)
  Labs.CreateLab(xOwner)
end)


ESX.RegisterServerCallback('KmF_Lab:Server:Hire', function(source, cb, LabId, employeeId)
  local xEmployee = ESX.GetPlayerFromId(employeeId)

  if xEmployee == nil then
    cb({status = false, reason = "Nessun giocatore con questo ID trovato"})
    return
  end

  if Labs.AddEmployee( LabId, xEmployee ) then

    cb({status = true})
  else
    cb({status = false, reason = "Il giocatore fa gia' parte di un laboratorio"})
  end
end)

ESX.RegisterServerCallback('KmF_Lab:Server:FireEmployee', function(source, cb, LabId, employeeId)
  if Labs.FireEmployee( LabId, employeeId ) then
    cb({status = true})
  else
    cb({status = false, reason = "Il giocatore non fa parte di questo laboratorio"})
  end
end)

ESX.RegisterServerCallback('KmF_Lab:Server:PromoteEmployee', function(source, cb, LabId, employeeId)
  if Labs.PromoteEmployee( LabId, employeeId ) then
    cb({status = true})
  else
    cb({status = false, reason = "Il giocatore non fa parte di questo laboratorio"})
  end
end)

ESX.RegisterServerCallback('KmF_Lab:Server:DegradeEmployee', function(source, cb, LabId, employeeId)
  if Labs.DegradeEmployee( LabId, employeeId ) then
    cb({status = true})
  else
    cb({status = false, reason = "Il giocatore non fa parte di questo laboratorio"})
  end
end)

function DebugPrint(text)
  if Config.Debug then
    print('^1[KmF_Labs] ^0' .. text .. '^0')
  end
end

ESX.RegisterServerCallback('KmF_Lab:Server:GetInventoryItems', function(source, cb)
  local xPlayer = ESX.GetPlayerFromId(source)
  local inventory = exports['qs-inventory']:GetInventory(xPlayer.source)

  cb(inventory)
end)

autosave = true

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(Config.DatabaseSaveTime)
    if autosave then

      exports['KmF_Lib']:DiscordLog('lab', 'SALVATAGGIO LABORATORI',
      'Laboratori salvati sul database' .. 
      '\nOrario: ' .. os.date('%d/%m/%Y %H:%M:%S') ..
      '\nNumero laboratori: ' .. #LabsData)

      Labs.SaveLabs()
    end
  end
end)

AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
  if eventData.secondsRemaining == 60 then
    CreateThread(function()
      Wait(10000)

      exports['KmF_Lib']:DiscordLog('lab', 'SALVATAGGIO LABORATORI (RESTART)',
      'Laboratori salvati sul database' .. 
      '\nOrario: ' .. os.date('%d/%m/%Y %H:%M:%S') ..
      '\nNumero laboratori: ' .. #LabsData)

      autosave = false
      Labs.SaveLabs()
    end)
  end
end)

AddEventHandler('txAdmin:events:serverShuttingDown', function()
  autosave = false
end)


RegisterServerEvent('KmF_Lab:Server:GiveRandomBox')
AddEventHandler('KmF_Lab:Server:GiveRandomBox', function(token)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)

  local randN = math.random(1, 3)
  -- print(randN)

  local item = Config.FakeLabItems[randN]

  if xPlayer.canCarryItem(item, 1) == false then
    TriggerClientEvent('esx:showNotification', src, 'Non hai abbastanza spazio', 'error')
    return
  end

  xPlayer.addInventoryItem(item, 1)
  TriggerClientEvent('esx:showNotification', src, 'Hai raccolto un ' .. allitems[item].label, 'success')

end)