Core.Players = {}
Core.Player = {}

-- On player login get their data or set defaults
-- Don't touch any of this unless you know what you are doing
-- Will cause major issues!

local resourceName = GetCurrentResourceName()
function Core.Player.Login(source, citizenid, newData)
    if source and source ~= '' then
        if citizenid then
            local license = Core.Functions.GetIdentifier(source, 'license')
            local PlayerData = MySQL.prepare.await('SELECT * FROM players where citizenid = ?', { citizenid })
            if PlayerData and license == PlayerData.license then
                PlayerData.money = json.decode(PlayerData.money)
                PlayerData.job = json.decode(PlayerData.job)
                PlayerData.gang = json.decode(PlayerData.gang)
                PlayerData.position = json.decode(PlayerData.position)
                PlayerData.metadata = json.decode(PlayerData.metadata)
                PlayerData.charinfo = json.decode(PlayerData.charinfo)
                Core.Player.CheckPlayerData(source, PlayerData)
            else
                DropPlayer(source, Lang:t('info.exploit_dropped'))
                TriggerEvent('bv-log:server:CreateLog', 'anticheat', 'Anti-Cheat', 'white',
                    GetPlayerName(source) .. ' Has Been Dropped For Character Joining Exploit', false)
            end
        else
            Core.Player.CheckPlayerData(source, newData)
        end
        return true
    else
        Core.ShowError(resourceName, 'ERROR Core.PLAYER.LOGIN - NO SOURCE GIVEN!')
        return false
    end
end

function Core.Player.GetOfflinePlayer(citizenid)
    if citizenid then
        local PlayerData = MySQL.prepare.await('SELECT * FROM players where citizenid = ?', { citizenid })
        if PlayerData then
            PlayerData.money = json.decode(PlayerData.money)
            PlayerData.job = json.decode(PlayerData.job)
            PlayerData.gang = json.decode(PlayerData.gang)
            PlayerData.position = json.decode(PlayerData.position)
            PlayerData.metadata = json.decode(PlayerData.metadata)
            PlayerData.charinfo = json.decode(PlayerData.charinfo)
            return Core.Player.CheckPlayerData(nil, PlayerData)
        end
    end
    return nil
end

function Core.Player.GetPlayerByLicense(license)
    if license then
        local source = Core.Functions.GetSource(license)
        if source > 0 then
            return Core.Players[source]
        else
            return Core.Player.GetOfflinePlayerByLicense(license)
        end
    end
    return nil
end

function Core.Player.GetOfflinePlayerByLicense(license)
    if license then
        local PlayerData = MySQL.prepare.await('SELECT * FROM players where license = ?', { license })
        if PlayerData then
            PlayerData.money = json.decode(PlayerData.money)
            PlayerData.job = json.decode(PlayerData.job)
            PlayerData.gang = json.decode(PlayerData.gang)
            PlayerData.position = json.decode(PlayerData.position)
            PlayerData.metadata = json.decode(PlayerData.metadata)
            PlayerData.charinfo = json.decode(PlayerData.charinfo)
            return Core.Player.CheckPlayerData(nil, PlayerData)
        end
    end
    return nil
end

local function applyDefaults(playerData, defaults)
    for key, value in pairs(defaults) do
        if type(value) == 'function' then
            playerData[key] = playerData[key] or value()
        elseif type(value) == 'table' then
            playerData[key] = playerData[key] or {}
            applyDefaults(playerData[key], value)
        else
            playerData[key] = playerData[key] or value
        end
    end
end

function Core.Player.CheckPlayerData(source, PlayerData)
    PlayerData = PlayerData or {}
    local Offline = not source

    if source then
        PlayerData.source = source
        PlayerData.license = PlayerData.license or Core.Functions.GetIdentifier(source, 'license')
        PlayerData.name = GetPlayerName(source)
    end

    local validatedJob = false
    if PlayerData.job and PlayerData.job.name ~= nil and PlayerData.job.grade and PlayerData.job.grade.level ~= nil then
        local jobInfo = Core.Shared.Jobs[PlayerData.job.name]

        if jobInfo then
            local jobGradeInfo = jobInfo.grades[tostring(PlayerData.job.grade.level)]
            if jobGradeInfo then
                PlayerData.job.label = jobInfo.label
                PlayerData.job.grade.name = jobGradeInfo.name
                PlayerData.job.payment = jobGradeInfo.payment
                PlayerData.job.grade.isboss = jobGradeInfo.isboss or false
                PlayerData.job.isboss = jobGradeInfo.isboss or false
                validatedJob = true
            end
        end
    end

    if validatedJob == false then
        -- set to nil, as the default job (unemployed) will be added by `applyDefaults`
        PlayerData.job = nil
    end

    local validatedGang = false
    if PlayerData.gang and PlayerData.gang.name ~= nil and PlayerData.gang.grade and PlayerData.gang.grade.level ~= nil then
        local gangInfo = Core.Shared.Gangs[PlayerData.gang.name]

        if gangInfo then
            local gangGradeInfo = gangInfo.grades[tostring(PlayerData.gang.grade.level)]
            if gangGradeInfo then
                PlayerData.gang.label = gangInfo.label
                PlayerData.gang.grade.name = gangGradeInfo.name
                PlayerData.gang.payment = gangGradeInfo.payment
                PlayerData.gang.grade.isboss = gangGradeInfo.isboss or false
                PlayerData.gang.isboss = gangGradeInfo.isboss or false
                validatedGang = true
            end
        end
    end

    if validatedGang == false then
        -- set to nil, as the default gang (unemployed) will be added by `applyDefaults`
        PlayerData.gang = nil
    end

    applyDefaults(PlayerData, Core.Config.Player.PlayerDefaults)

    if GetResourceState('bv-inventory') ~= 'missing' then
        PlayerData.items = exports['bv-inventory']:LoadInventory(PlayerData.source, PlayerData.citizenid)
    end

    return Core.Player.CreatePlayer(PlayerData, Offline)
end

-- On player logout

function Core.Player.Logout(source)
    TriggerClientEvent('Core:Client:OnPlayerUnload', source)
    TriggerEvent('Core:Server:OnPlayerUnload', source)
    TriggerClientEvent('Core:Player:UpdatePlayerData', source)
    Wait(200)
    Core.Players[source] = nil
end

-- Create a new character
-- Don't touch any of this unless you know what you are doing
-- Will cause major issues!

function Core.Player.CreatePlayer(PlayerData, Offline)
    local self = {}
    self.Functions = {}
    self.PlayerData = PlayerData
    self.Offline = Offline

    function self.Functions.UpdatePlayerData()
        if self.Offline then return end
        TriggerEvent('Core:Player:SetPlayerData', self.PlayerData)
        TriggerClientEvent('Core:Player:SetPlayerData', self.PlayerData.source, self.PlayerData)
    end

    function self.Functions.SetJob(job, grade)
        job = job:lower()
        grade = grade or '0'
        if not Core.Shared.Jobs[job] then return false end
        self.PlayerData.job = {
            name = job,
            label = Core.Shared.Jobs[job].label,
            onduty = Core.Shared.Jobs[job].defaultDuty,
            type = Core.Shared.Jobs[job].type or 'none',
            grade = {
                name = 'No Grades',
                level = 0,
                payment = 30,
                isboss = false
            }
        }
        local gradeKey = tostring(grade)
        local jobGradeInfo = Core.Shared.Jobs[job].grades[gradeKey]
        if jobGradeInfo then
            self.PlayerData.job.grade.name = jobGradeInfo.name
            self.PlayerData.job.grade.level = tonumber(gradeKey)
            self.PlayerData.job.grade.payment = jobGradeInfo.payment
            self.PlayerData.job.grade.isboss = jobGradeInfo.isboss or false
            self.PlayerData.job.isboss = jobGradeInfo.isboss or false
        end

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            TriggerEvent('Core:Server:OnJobUpdate', self.PlayerData.source, self.PlayerData.job)
            TriggerClientEvent('Core:Client:OnJobUpdate', self.PlayerData.source, self.PlayerData.job)
        end

        return true
    end

    function self.Functions.SetGang(gang, grade)
        gang = gang:lower()
        grade = grade or '0'
        if not Core.Shared.Gangs[gang] then return false end
        self.PlayerData.gang = {
            name = gang,
            label = Core.Shared.Gangs[gang].label,
            grade = {
                name = 'No Grades',
                level = 0,
                isboss = false
            }
        }
        local gradeKey = tostring(grade)
        local gangGradeInfo = Core.Shared.Gangs[gang].grades[gradeKey]
        if gangGradeInfo then
            self.PlayerData.gang.grade.name = gangGradeInfo.name
            self.PlayerData.gang.grade.level = tonumber(gradeKey)
            self.PlayerData.gang.grade.isboss = gangGradeInfo.isboss or false
            self.PlayerData.gang.isboss = gangGradeInfo.isboss or false
        end

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            TriggerEvent('Core:Server:OnGangUpdate', self.PlayerData.source, self.PlayerData.gang)
            TriggerClientEvent('Core:Client:OnGangUpdate', self.PlayerData.source, self.PlayerData.gang)
        end

        return true
    end

    function self.Functions.Notify(text, type, length)
        TriggerClientEvent('Core:Notify', self.PlayerData.source, text, type, length)
    end

    function self.Functions.HasItem(items, amount)
        return Core.Functions.HasItem(self.PlayerData.source, items, amount)
    end

    function self.Functions.GetName()
        local charinfo = self.PlayerData.charinfo
        return charinfo.firstname .. ' ' .. charinfo.lastname
    end

    function self.Functions.SetJobDuty(onDuty)
        self.PlayerData.job.onduty = not not onDuty
        TriggerEvent('Core:Server:OnJobUpdate', self.PlayerData.source, self.PlayerData.job)
        TriggerClientEvent('Core:Client:OnJobUpdate', self.PlayerData.source, self.PlayerData.job)
        self.Functions.UpdatePlayerData()
    end

    function self.Functions.SetPlayerData(key, val)
        if not key or type(key) ~= 'string' then return end
        self.PlayerData[key] = val
        self.Functions.UpdatePlayerData()
    end

    function self.Functions.SetMetaData(meta, val)
        if not meta or type(meta) ~= 'string' then return end
        if meta == 'hunger' or meta == 'thirst' then
            val = val > 100 and 100 or val
        end
        self.PlayerData.metadata[meta] = val
        self.Functions.UpdatePlayerData()
    end

    function self.Functions.Heal()
        if not self.Offline then
            TriggerClientEvent('Core:Client:HealPlayer', self.PlayerData.source)
        end
        self.PlayerData.metadata.hunger = 100
        self.PlayerData.metadata.thirst = 100
        self.PlayerData.metadata.stress = 0
        self.Functions.UpdatePlayerData()
    end

    function self.Functions.GetMetaData(meta)
        if not meta or type(meta) ~= 'string' then return end
        return self.PlayerData.metadata[meta]
    end

    function self.Functions.AddRep(rep, amount)
        if not rep or not amount then return end
        local addAmount = tonumber(amount)
        local currentRep = self.PlayerData.metadata['rep'][rep] or 0
        self.PlayerData.metadata['rep'][rep] = currentRep + addAmount
        self.Functions.UpdatePlayerData()
    end

    function self.Functions.RemoveRep(rep, amount)
        if not rep or not amount then return end
        local removeAmount = tonumber(amount)
        local currentRep = self.PlayerData.metadata['rep'][rep] or 0
        if currentRep - removeAmount < 0 then
            self.PlayerData.metadata['rep'][rep] = 0
        else
            self.PlayerData.metadata['rep'][rep] = currentRep - removeAmount
        end
        self.Functions.UpdatePlayerData()
    end

    function self.Functions.GetRep(rep)
        if not rep then return end
        return self.PlayerData.metadata['rep'][rep] or 0
    end

    function self.Functions.AddMoney(moneytype, amount, reason)
        reason = reason or 'unknown'
        moneytype = moneytype:lower()
        amount = tonumber(amount)
        if amount < 0 then return end
        if not self.PlayerData.money[moneytype] then return false end
        self.PlayerData.money[moneytype] = self.PlayerData.money[moneytype] + amount

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            if amount > 100000 then
                TriggerEvent('bv-log:server:CreateLog', 'playermoney', 'AddMoney', 'lightgreen',
                    '**' ..
                    GetPlayerName(self.PlayerData.source) ..
                    ' (citizenid: ' ..
                    self.PlayerData.citizenid ..
                    ' | id: ' ..
                    self.PlayerData.source ..
                    ')** $' ..
                    amount ..
                    ' (' ..
                    moneytype ..
                    ') added, new ' ..
                    moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason, true)
            else
                TriggerEvent('bv-log:server:CreateLog', 'playermoney', 'AddMoney', 'lightgreen',
                    '**' ..
                    GetPlayerName(self.PlayerData.source) ..
                    ' (citizenid: ' ..
                    self.PlayerData.citizenid ..
                    ' | id: ' ..
                    self.PlayerData.source ..
                    ')** $' ..
                    amount ..
                    ' (' ..
                    moneytype ..
                    ') added, new ' ..
                    moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason)
            end
            TriggerClientEvent('hud:client:OnMoneyChange', self.PlayerData.source, moneytype, amount, false)
            TriggerClientEvent('Core:Client:OnMoneyChange', self.PlayerData.source, moneytype, amount, 'add', reason)
            TriggerEvent('Core:Server:OnMoneyChange', self.PlayerData.source, moneytype, amount, 'add', reason)
        end

        return true
    end

    function self.Functions.RemoveMoney(moneytype, amount, reason)
        reason = reason or 'unknown'
        moneytype = moneytype:lower()
        amount = tonumber(amount)
        if amount < 0 then return end
        if not self.PlayerData.money[moneytype] then return false end
        for _, mtype in pairs(Core.Config.Money.DontAllowMinus) do
            if mtype == moneytype then
                if (self.PlayerData.money[moneytype] - amount) < 0 then
                    return false
                end
            end
        end
        if self.PlayerData.money[moneytype] - amount < Core.Config.Money.MinusLimit then return false end
        self.PlayerData.money[moneytype] = self.PlayerData.money[moneytype] - amount

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            if amount > 100000 then
                TriggerEvent('bv-log:server:CreateLog', 'playermoney', 'RemoveMoney', 'red',
                    '**' ..
                    GetPlayerName(self.PlayerData.source) ..
                    ' (citizenid: ' ..
                    self.PlayerData.citizenid ..
                    ' | id: ' ..
                    self.PlayerData.source ..
                    ')** $' ..
                    amount ..
                    ' (' ..
                    moneytype ..
                    ') removed, new ' ..
                    moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason, true)
            else
                TriggerEvent('bv-log:server:CreateLog', 'playermoney', 'RemoveMoney', 'red',
                    '**' ..
                    GetPlayerName(self.PlayerData.source) ..
                    ' (citizenid: ' ..
                    self.PlayerData.citizenid ..
                    ' | id: ' ..
                    self.PlayerData.source ..
                    ')** $' ..
                    amount ..
                    ' (' ..
                    moneytype ..
                    ') removed, new ' ..
                    moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason)
            end
            TriggerClientEvent('hud:client:OnMoneyChange', self.PlayerData.source, moneytype, amount, true)
            if moneytype == 'bank' then
                TriggerClientEvent('bv-phone:client:RemoveBankMoney', self.PlayerData.source, amount)
            end
            TriggerClientEvent('Core:Client:OnMoneyChange', self.PlayerData.source, moneytype, amount, 'remove', reason)
            TriggerEvent('Core:Server:OnMoneyChange', self.PlayerData.source, moneytype, amount, 'remove', reason)
        end

        return true
    end

    function self.Functions.SetMoney(moneytype, amount, reason)
        reason = reason or 'unknown'
        moneytype = moneytype:lower()
        amount = tonumber(amount)
        if amount < 0 then return false end
        if not self.PlayerData.money[moneytype] then return false end
        local difference = amount - self.PlayerData.money[moneytype]
        self.PlayerData.money[moneytype] = amount

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            TriggerEvent('bv-log:server:CreateLog', 'playermoney', 'SetMoney', 'green',
                '**' ..
                GetPlayerName(self.PlayerData.source) ..
                ' (citizenid: ' ..
                self.PlayerData.citizenid ..
                ' | id: ' ..
                self.PlayerData.source ..
                ')** $' ..
                amount ..
                ' (' ..
                moneytype ..
                ') set, new ' .. moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason)
            TriggerClientEvent('hud:client:OnMoneyChange', self.PlayerData.source, moneytype, math.abs(difference),
                difference < 0)
            TriggerClientEvent('Core:Client:OnMoneyChange', self.PlayerData.source, moneytype, amount, 'set', reason)
            TriggerEvent('Core:Server:OnMoneyChange', self.PlayerData.source, moneytype, amount, 'set', reason)
        end

        return true
    end

    function self.Functions.GetMoney(moneytype)
        if not moneytype then return false end
        moneytype = moneytype:lower()
        return self.PlayerData.money[moneytype]
    end

    function self.Functions.Save()
        if self.Offline then
            Core.Player.SaveOffline(self.PlayerData)
        else
            Core.Player.Save(self.PlayerData.source)
        end
    end

    function self.Functions.Logout()
        if self.Offline then return end
        Core.Player.Logout(self.PlayerData.source)
    end

    function self.Functions.AddMethod(methodName, handler)
        self.Functions[methodName] = handler
    end

    function self.Functions.AddField(fieldName, data)
        self[fieldName] = data
    end

    if self.Offline then
        return self
    else
        Core.Players[self.PlayerData.source] = self
        Core.Player.Save(self.PlayerData.source)
        TriggerEvent('Core:Server:PlayerLoaded', self)
        self.Functions.UpdatePlayerData()
    end
end

-- Add a new function to the Functions table of the player class
-- Use-case:
--[[
    AddEventHandler('Core:Server:PlayerLoaded', function(Player)
        Core.Functions.AddPlayerMethod(Player.PlayerData.source, "functionName", function(oneArg, orMore)
            -- do something here
        end)
    end)
]]

function Core.Functions.AddPlayerMethod(ids, methodName, handler)
    local idType = type(ids)
    if idType == 'number' then
        if ids == -1 then
            for _, v in pairs(Core.Players) do
                v.Functions.AddMethod(methodName, handler)
            end
        else
            if not Core.Players[ids] then return end

            Core.Players[ids].Functions.AddMethod(methodName, handler)
        end
    elseif idType == 'table' and table.type(ids) == 'array' then
        for i = 1, #ids do
            Core.Functions.AddPlayerMethod(ids[i], methodName, handler)
        end
    end
end

-- Add a new field table of the player class
-- Use-case:
--[[
    AddEventHandler('Core:Server:PlayerLoaded', function(Player)
        Core.Functions.AddPlayerField(Player.PlayerData.source, "fieldName", "fieldData")
    end)
]]

function Core.Functions.AddPlayerField(ids, fieldName, data)
    local idType = type(ids)
    if idType == 'number' then
        if ids == -1 then
            for _, v in pairs(Core.Players) do
                v.Functions.AddField(fieldName, data)
            end
        else
            if not Core.Players[ids] then return end

            Core.Players[ids].Functions.AddField(fieldName, data)
        end
    elseif idType == 'table' and table.type(ids) == 'array' then
        for i = 1, #ids do
            Core.Functions.AddPlayerField(ids[i], fieldName, data)
        end
    end
end

-- Save player info to database (make sure citizenid is the primary key in your database)

function Core.Player.Save(source)
    local ped = GetPlayerPed(source)
    local pcoords = GetEntityCoords(ped)
    local PlayerData = Core.Players[source].PlayerData
    if PlayerData then
        MySQL.insert(
            'INSERT INTO players (citizenid, cid, license, name, money, charinfo, job, gang, position, metadata) VALUES (:citizenid, :cid, :license, :name, :money, :charinfo, :job, :gang, :position, :metadata) ON DUPLICATE KEY UPDATE cid = :cid, name = :name, money = :money, charinfo = :charinfo, job = :job, gang = :gang, position = :position, metadata = :metadata',
            {
                citizenid = PlayerData.citizenid,
                cid = tonumber(PlayerData.cid),
                license = PlayerData.license,
                name = PlayerData.name,
                money = json.encode(PlayerData.money),
                charinfo = json.encode(PlayerData.charinfo),
                job = json.encode(PlayerData.job),
                gang = json.encode(PlayerData.gang),
                position = json.encode(pcoords),
                metadata = json.encode(PlayerData.metadata)
            })
        if GetResourceState('bv-inventory') ~= 'missing' then exports['bv-inventory']:SaveInventory(source) end
        Core.ShowSuccess(resourceName, PlayerData.name .. ' PLAYER SAVED!')
    else
        Core.ShowError(resourceName, 'ERROR Core.PLAYER.SAVE - PLAYERDATA IS EMPTY!')
    end
end

function Core.Player.SaveOffline(PlayerData)
    if PlayerData then
        MySQL.insert(
            'INSERT INTO players (citizenid, cid, license, name, money, charinfo, job, gang, position, metadata) VALUES (:citizenid, :cid, :license, :name, :money, :charinfo, :job, :gang, :position, :metadata) ON DUPLICATE KEY UPDATE cid = :cid, name = :name, money = :money, charinfo = :charinfo, job = :job, gang = :gang, position = :position, metadata = :metadata',
            {
                citizenid = PlayerData.citizenid,
                cid = tonumber(PlayerData.cid),
                license = PlayerData.license,
                name = PlayerData.name,
                money = json.encode(PlayerData.money),
                charinfo = json.encode(PlayerData.charinfo),
                job = json.encode(PlayerData.job),
                gang = json.encode(PlayerData.gang),
                position = json.encode(PlayerData.position),
                metadata = json.encode(PlayerData.metadata)
            })
        if GetResourceState('bv-inventory') ~= 'missing' then exports['bv-inventory']:SaveInventory(PlayerData, true) end
        Core.ShowSuccess(resourceName, PlayerData.name .. ' OFFLINE PLAYER SAVED!')
    else
        Core.ShowError(resourceName, 'ERROR Core.PLAYER.SAVEOFFLINE - PLAYERDATA IS EMPTY!')
    end
end

-- Delete character

local playertables = { -- Add tables as needed
    { table = 'players' },
    { table = 'apartments' },
    { table = 'bank_accounts' },
    { table = 'crypto_transactions' },
    { table = 'phone_invoices' },
    { table = 'phone_messages' },
    { table = 'playerskins' },
    { table = 'player_contacts' },
    { table = 'player_houses' },
    { table = 'player_mails' },
    { table = 'player_outfits' },
    { table = 'player_vehicles' }
}

function Core.Player.DeleteCharacter(source, citizenid)
    local license = Core.Functions.GetIdentifier(source, 'license')
    local result = MySQL.scalar.await('SELECT license FROM players where citizenid = ?', { citizenid })
    if license == result then
        local query = 'DELETE FROM %s WHERE citizenid = ?'
        local tableCount = #playertables
        local queries = table.create(tableCount, 0)

        for i = 1, tableCount do
            local v = playertables[i]
            queries[i] = { query = query:format(v.table), values = { citizenid } }
        end

        MySQL.transaction(queries, function(result2)
            if result2 then
                TriggerEvent('bv-log:server:CreateLog', 'joinleave', 'Character Deleted', 'red',
                    '**' .. GetPlayerName(source) .. '** ' .. license .. ' deleted **' .. citizenid .. '**..')
            end
        end)
    else
        DropPlayer(source, Lang:t('info.exploit_dropped'))
        TriggerEvent('bv-log:server:CreateLog', 'anticheat', 'Anti-Cheat', 'white',
            GetPlayerName(source) .. ' Has Been Dropped For Character Deletion Exploit', true)
    end
end

function Core.Player.ForceDeleteCharacter(citizenid)
    local result = MySQL.scalar.await('SELECT license FROM players where citizenid = ?', { citizenid })
    if result then
        local query = 'DELETE FROM %s WHERE citizenid = ?'
        local tableCount = #playertables
        local queries = table.create(tableCount, 0)
        local Player = Core.Functions.GetPlayerByCitizenId(citizenid)

        if Player then
            DropPlayer(Player.PlayerData.source, 'An admin deleted the character which you are currently using')
        end
        for i = 1, tableCount do
            local v = playertables[i]
            queries[i] = { query = query:format(v.table), values = { citizenid } }
        end

        MySQL.transaction(queries, function(result2)
            if result2 then
                TriggerEvent('bv-log:server:CreateLog', 'joinleave', 'Character Force Deleted', 'red',
                    'Character **' .. citizenid .. '** got deleted')
            end
        end)
    end
end

-- Inventory Backwards Compatibility

function Core.Player.SaveInventory(source)
    if GetResourceState('bv-inventory') == 'missing' then return end
    exports['bv-inventory']:SaveInventory(source, false)
end

function Core.Player.SaveOfflineInventory(PlayerData)
    if GetResourceState('bv-inventory') == 'missing' then return end
    exports['bv-inventory']:SaveInventory(PlayerData, true)
end

function Core.Player.GetTotalWeight(items)
    if GetResourceState('bv-inventory') == 'missing' then return end
    return exports['bv-inventory']:GetTotalWeight(items)
end

function Core.Player.GetSlotsByItem(items, itemName)
    if GetResourceState('bv-inventory') == 'missing' then return end
    return exports['bv-inventory']:GetSlotsByItem(items, itemName)
end

function Core.Player.GetFirstSlotByItem(items, itemName)
    if GetResourceState('bv-inventory') == 'missing' then return end
    return exports['bv-inventory']:GetFirstSlotByItem(items, itemName)
end

-- Util Functions

function Core.Player.CreateCitizenId()
    local CitizenId = tostring(Core.Shared.RandomStr(3) .. Core.Shared.RandomInt(5)):upper()
    local result = MySQL.prepare.await('SELECT EXISTS(SELECT 1 FROM players WHERE citizenid = ?) AS uniqueCheck',
        { CitizenId })
    if result == 0 then return CitizenId end
    return Core.Player.CreateCitizenId()
end

function Core.Functions.CreateAccountNumber()
    local AccountNumber = 'US0' ..
        math.random(1, 9) .. 'Core' .. math.random(1111, 9999) .. math.random(1111, 9999) .. math.random(11, 99)
    local result = MySQL.prepare.await(
        'SELECT EXISTS(SELECT 1 FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(charinfo, "$.account")) = ?) AS uniqueCheck',
        { AccountNumber })
    if result == 0 then return AccountNumber end
    return Core.Functions.CreateAccountNumber()
end

function Core.Functions.CreatePhoneNumber()
    local PhoneNumber = math.random(100, 999) .. math.random(1000000, 9999999)
    local result = MySQL.prepare.await(
        'SELECT EXISTS(SELECT 1 FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(charinfo, "$.phone")) = ?) AS uniqueCheck',
        { PhoneNumber })
    if result == 0 then return PhoneNumber end
    return Core.Functions.CreatePhoneNumber()
end

function Core.Player.CreateFingerId()
    local FingerId = tostring(Core.Shared.RandomStr(2) ..
        Core.Shared.RandomInt(3) ..
        Core.Shared.RandomStr(1) .. Core.Shared.RandomInt(2) .. Core.Shared.RandomStr(3) .. Core.Shared.RandomInt(4))
    local result = MySQL.prepare.await(
        'SELECT EXISTS(SELECT 1 FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(metadata, "$.fingerprint")) = ?) AS uniqueCheck',
        { FingerId })
    if result == 0 then return FingerId end
    return Core.Player.CreateFingerId()
end

function Core.Player.CreateWalletId()
    local WalletId = 'BV-' .. math.random(11111111, 99999999)
    local result = MySQL.prepare.await(
        'SELECT EXISTS(SELECT 1 FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(metadata, "$.walletid")) = ?) AS uniqueCheck',
        { WalletId })
    if result == 0 then return WalletId end
    return Core.Player.CreateWalletId()
end

function Core.Player.CreateSerialNumber()
    local SerialNumber = math.random(11111111, 99999999)
    local result = MySQL.prepare.await(
        'SELECT EXISTS(SELECT 1 FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(metadata, "$.phonedata.SerialNumber")) = ?) AS uniqueCheck',
        { SerialNumber })
    if result == 0 then return SerialNumber end
    return Core.Player.CreateSerialNumber()
end

PaycheckInterval() -- This starts the paycheck system
