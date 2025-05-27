local function IsWeaponBlocked(WeaponName)
    local retval = false
    for _, name in pairs(Shared.Weapons.DurabilityBlockedWeapons) do
        if name == WeaponName then
            retval = true
            break
        end
    end
    return retval
end

-- Callback

Core.Functions.CreateCallback('core-weapons:server:GetShared.Weapons', function(_, cb)
    cb(Shared.Weapons.WeaponRepairPoints)
end)

Core.Functions.CreateCallback('weapon:server:GetWeaponAmmo', function(src, cb, WeaponData)
    local Player = Core.Functions.GetPlayer(src)
    local retval = 0
    if WeaponData then
        if Player then
            local ItemData = Player.Functions.GetItemBySlot(WeaponData.slot)
            if ItemData then
                retval = ItemData.info.ammo and ItemData.info.ammo or 0
            end
        end
    end
    cb(retval, WeaponData.name)
end)

Core.Functions.CreateCallback('core-weapons:server:RepairWeapon', function(src, cb, RepairPoint, data)
    local Player = Core.Functions.GetPlayer(src)
    local minute = 60 * 1000
    local Timeout = math.random(5 * minute, 10 * minute)
    local WeaponData = Core.Shared.Weapons.List[GetHashKey(data.name)]
    local WeaponClass = (Core.Shared.SplitStr(WeaponData.ammotype, '_')[2]):lower()

    if not Player then
        cb(false)
        return
    end

    if not Player.PlayerData.items[data.slot] then
        TriggerClientEvent('Core:Notify', src, Lang:t('error.no_weapon_in_hand'), 'error')
        TriggerClientEvent('core-weapons:client:SetCurrentWeapon', src, {}, false)
        cb(false)
        return
    end

    if not Player.PlayerData.items[data.slot].info.quality or Player.PlayerData.items[data.slot].info.quality == 100 then
        TriggerClientEvent('Core:Notify', src, Lang:t('error.no_damage_on_weapon'), 'error')
        cb(false)
        return
    end

    if not Player.Functions.RemoveMoney('cash', Shared.Weapons.WeaponRepairCosts[WeaponClass]) then
        cb(false)
        return
    end

    Shared.Weapons.WeaponRepairPoints[RepairPoint].IsRepairing = true
    Shared.Weapons.WeaponRepairPoints[RepairPoint].RepairingData = {
        CitizenId = Player.PlayerData.citizenid,
        WeaponData = Player.PlayerData.items[data.slot],
        Ready = false,
    }

    if not exports['bv-inventory']:RemoveItem(src, data.name, 1, data.slot, 'core-weapons:server:RepairWeapon') then
        Player.Functions.AddMoney('cash', Shared.Weapons.WeaponRepairCosts[WeaponClass],
            'core-weapons:server:RepairWeapon')
        return
    end

    TriggerClientEvent('bv-inventory:client:ItemBox', src, Core.Shared.Items[data.name], 'remove')
    TriggerClientEvent('bv-inventory:client:CheckWeapon', src, data.name)
    TriggerClientEvent('core-weapons:client:SyncRepairShops', -1, Shared.Weapons.WeaponRepairPoints[RepairPoint],
        RepairPoint)

    SetTimeout(Timeout, function()
        Shared.Weapons.WeaponRepairPoints[RepairPoint].IsRepairing = false
        Shared.Weapons.WeaponRepairPoints[RepairPoint].RepairingData.Ready = true
        TriggerClientEvent('core-weapons:client:SyncRepairShops', -1, Shared.Weapons.WeaponRepairPoints[RepairPoint],
            RepairPoint)
        exports['bv-phone']:sendNewMailToOffline(Player.PlayerData.citizenid, {
            sender = Lang:t('mail.sender'),
            subject = Lang:t('mail.subject'),
            message = Lang:t('mail.message', { value = WeaponData.label })
        })

        SetTimeout(7 * 60000, function()
            if Shared.Weapons.WeaponRepairPoints[RepairPoint].RepairingData.Ready then
                Shared.Weapons.WeaponRepairPoints[RepairPoint].IsRepairing = false
                Shared.Weapons.WeaponRepairPoints[RepairPoint].RepairingData = {}
                TriggerClientEvent('core-weapons:client:SyncRepairShops', -1,
                    Shared.Weapons.WeaponRepairPoints[RepairPoint], RepairPoint)
            end
        end)
    end)

    cb(true)
end)

Core.Functions.CreateCallback('prison:server:checkThrowable', function(src, cb, weapon)
    local Player = Core.Functions.GetPlayer(src)
    if not Player then return cb(false) end
    local throwable = false
    for _, v in pairs(Shared.Weapons.Throwables) do
        if Core.Shared.Weapons.List[weapon].name == 'weapon_' .. v then
            if not exports['bv-inventory']:RemoveItem(src, 'weapon_' .. v, 1, false, 'prison:server:checkThrowable') then
                return
                    cb(false)
            end
            throwable = true
            break
        end
    end
    cb(throwable)
end)

-- Events

RegisterNetEvent('core-weapons:server:UpdateWeaponAmmo', function(CurrentWeaponData, amount)
    local src = source
    local Player = Core.Functions.GetPlayer(src)
    if not Player then return end
    amount = tonumber(amount)
    if CurrentWeaponData then
        if Player.PlayerData.items[CurrentWeaponData.slot] then
            Player.PlayerData.items[CurrentWeaponData.slot].info.ammo = amount
        end
        Player.Functions.SetInventory(Player.PlayerData.items, true)
    end
end)

RegisterNetEvent('core-weapons:server:TakeBackWeapon', function(k)
    local src = source
    local Player = Core.Functions.GetPlayer(src)
    if not Player then return end
    local itemdata = Shared.Weapons.WeaponRepairPoints[k].RepairingData.WeaponData
    itemdata.info.quality = 100
    exports['bv-inventory']:AddItem(src, itemdata.name, 1, false, itemdata.info, 'core-weapons:server:TakeBackWeapon')
    TriggerClientEvent('bv-inventory:client:ItemBox', src, Core.Shared.Items[itemdata.name], 'add')
    Shared.Weapons.WeaponRepairPoints[k].IsRepairing = false
    Shared.Weapons.WeaponRepairPoints[k].RepairingData = {}
    TriggerClientEvent('core-weapons:client:SyncRepairShops', -1, Shared.Weapons.WeaponRepairPoints[k], k)
end)

RegisterNetEvent('core-weapons:server:SetWeaponQuality', function(data, hp)
    local src = source
    local Player = Core.Functions.GetPlayer(src)
    if not Player then return end
    local WeaponSlot = Player.PlayerData.items[data.slot]
    WeaponSlot.info.quality = hp
    Player.Functions.SetInventory(Player.PlayerData.items, true)
end)

RegisterNetEvent('core-weapons:server:UpdateWeaponQuality', function(data, RepeatAmount)
    local src = source
    local Player = Core.Functions.GetPlayer(src)
    local WeaponData = Core.Shared.Weapons.List[GetHashKey(data.name)]
    local WeaponSlot = Player.PlayerData.items[data.slot]
    local DecreaseAmount = Shared.Weapons.DurabilityMultiplier[data.name]
    if WeaponSlot then
        if not IsWeaponBlocked(WeaponData.name) then
            if WeaponSlot.info.quality then
                for _ = 1, RepeatAmount, 1 do
                    if WeaponSlot.info.quality - DecreaseAmount > 0 then
                        WeaponSlot.info.quality = Core.Shared.Round(WeaponSlot.info.quality - DecreaseAmount, 2)
                    else
                        WeaponSlot.info.quality = 0
                        TriggerClientEvent('core-weapons:client:UseWeapon', src, data, false)
                        TriggerClientEvent('Core:Notify', src, Lang:t('error.weapon_broken_need_repair'), 'error')
                        break
                    end
                end
            else
                WeaponSlot.info.quality = 100
                for _ = 1, RepeatAmount, 1 do
                    if WeaponSlot.info.quality - DecreaseAmount > 0 then
                        WeaponSlot.info.quality = Core.Shared.Round(WeaponSlot.info.quality - DecreaseAmount, 2)
                    else
                        WeaponSlot.info.quality = 0
                        TriggerClientEvent('core-weapons:client:UseWeapon', src, data, false)
                        TriggerClientEvent('Core:Notify', src, Lang:t('error.weapon_broken_need_repair'), 'error')
                        break
                    end
                end
            end
        end
    end
    Player.Functions.SetInventory(Player.PlayerData.items, true)
end)

RegisterNetEvent('core-weapons:server:removeWeaponAmmoItem', function(item)
    local src = source
    local Player = Core.Functions.GetPlayer(src)
    if not Player or type(item) ~= 'table' or not item.name or not item.slot then return end
    exports['bv-inventory']:RemoveItem(src, item.name, 1, item.slot, 'core-weapons:server:removeWeaponAmmoItem')
end)

-- Commands

Core.Commands.Add('repairweapon', 'Repair Weapon (God Only)', { { name = 'hp', help = Lang:t('info.hp_of_weapon') } },
    true, function(src, args)
        TriggerClientEvent('core-weapons:client:SetWeaponQuality', src, tonumber(args[1]))
    end, 'god')

-- Items

-- AMMO
for ammoItem, properties in pairs(Shared.Weapons.AmmoTypes) do
    Core.Functions.CreateUseableItem(ammoItem, function(src, item)
        TriggerClientEvent('core-weapons:client:AddAmmo', src, properties.ammoType, properties.amount, item)
    end)
end

-- TINTS

local function GetWeaponSlotByName(items, weaponName)
    for index, item in pairs(items) do
        if item.name == weaponName then
            return item, index
        end
    end
    return nil, nil
end

local function IsMK2Weapon(weaponHash)
    local weaponName = Core.Shared.Weapons.List[weaponHash]['name']
    return string.find(weaponName, 'mk2') ~= nil
end

local function EquipWeaponTint(src, tintIndex, item, isMK2)
    local Player = Core.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local selectedWeaponHash = GetSelectedPedWeapon(ped)

    if selectedWeaponHash == `WEAPON_UNARMED` then
        TriggerClientEvent('Core:Notify', src, 'You have no weapon selected.', 'error')
        return
    end

    local weaponName = Core.Shared.Weapons.List[selectedWeaponHash].name
    if not weaponName then return end

    if isMK2 and not IsMK2Weapon(selectedWeaponHash) then
        TriggerClientEvent('Core:Notify', src, 'This tint is only for MK2 weapons', 'error')
        return
    end

    local weaponSlot, weaponSlotIndex = GetWeaponSlotByName(Player.PlayerData.items, weaponName)
    if not weaponSlot then return end

    if weaponSlot.info.tint == tintIndex then
        TriggerClientEvent('Core:Notify', src, 'This tint is already applied to your weapon.', 'error')
        return
    end

    weaponSlot.info.tint = tintIndex
    Player.PlayerData.items[weaponSlotIndex] = weaponSlot
    Player.Functions.SetInventory(Player.PlayerData.items, true)
    exports['bv-inventory']:RemoveItem(src, item, 1, false, 'bv-weapon:EquipWeaponTint')
    TriggerClientEvent('bv-inventory:client:ItemBox', src, Core.Shared.Items[item], 'remove')
    TriggerClientEvent('core-weapons:client:EquipTint', src, selectedWeaponHash, tintIndex)
end

for i = 0, 7 do
    Core.Functions.CreateUseableItem('weapontint_' .. i, function(src, item)
        EquipWeaponTint(src, i, item.name, false)
    end)
end

for i = 0, 32 do
    Core.Functions.CreateUseableItem('weapontint_mk2_' .. i, function(src, item)
        EquipWeaponTint(src, i, item.name, true)
    end)
end

-- Attachments

local function HasAttachment(component, attachments)
    for k, v in pairs(attachments) do
        if v.component == component then
            return true, k
        end
    end
    return false, nil
end

local function DoesWeaponTakeWeaponComponent(item, weaponName)
    if Shared.Weapons.WeaponAttachments[item] and Shared.Weapons.WeaponAttachments[item][weaponName] then
        return Shared.Weapons.WeaponAttachments[item][weaponName]
    end
    return false
end

local function EquipWeaponAttachment(src, item)
    local shouldRemove = false
    local ped = GetPlayerPed(src)
    local selectedWeaponHash = GetSelectedPedWeapon(ped)
    if selectedWeaponHash == `WEAPON_UNARMED` then return end
    local weaponName = Core.Shared.Weapons.List[selectedWeaponHash].name
    if not weaponName then return end
    local attachmentComponent = DoesWeaponTakeWeaponComponent(item, weaponName)
    if not attachmentComponent then
        TriggerClientEvent('Core:Notify', src, 'This attachment is not valid for the selected weapon.', 'error')
        return
    end
    local Player = Core.Functions.GetPlayer(src)
    if not Player then return end
    local weaponSlot, weaponSlotIndex = GetWeaponSlotByName(Player.PlayerData.items, weaponName)
    if not weaponSlot then return end
    weaponSlot.info.attachments = weaponSlot.info.attachments or {}
    local hasAttach, attachIndex = HasAttachment(attachmentComponent, weaponSlot.info.attachments)
    if hasAttach then
        RemoveWeaponComponentFromPed(ped, selectedWeaponHash, attachmentComponent)
        table.remove(weaponSlot.info.attachments, attachIndex)
    else
        weaponSlot.info.attachments[#weaponSlot.info.attachments + 1] = {
            component = attachmentComponent,
        }
        GiveWeaponComponentToPed(ped, selectedWeaponHash, attachmentComponent)
        shouldRemove = true
    end
    Player.PlayerData.items[weaponSlotIndex] = weaponSlot
    Player.Functions.SetInventory(Player.PlayerData.items, true)
    if shouldRemove then
        exports['bv-inventory']:RemoveItem(src, item, 1, false, 'core-weapons:EquipWeaponAttachment')
        TriggerClientEvent('bv-inventory:client:ItemBox', src, Core.Shared.Items[item], 'remove')
    end
end

for attachmentItem in pairs(Shared.Weapons.WeaponAttachments) do
    Core.Functions.CreateUseableItem(attachmentItem, function(src, item)
        EquipWeaponAttachment(src, item.name)
    end)
end

Core.Functions.CreateCallback('core-weapons:server:RemoveAttachment', function(src, cb, AttachmentData, WeaponData)
    local Player = Core.Functions.GetPlayer(src)
    local Inventory = Player.PlayerData.items
    local allAttachments = Shared.Weapons.WeaponAttachments
    local AttachmentComponent = allAttachments[AttachmentData.attachment][WeaponData.name]
    if Inventory[WeaponData.slot] then
        if Inventory[WeaponData.slot].info.attachments and next(Inventory[WeaponData.slot].info.attachments) then
            local HasAttach, key = HasAttachment(AttachmentComponent, Inventory[WeaponData.slot].info.attachments)
            if HasAttach then
                table.remove(Inventory[WeaponData.slot].info.attachments, key)
                Player.Functions.SetInventory(Player.PlayerData.items, true)
                exports['bv-inventory']:AddItem(src, AttachmentData.attachment, 1, false, false,
                    'core-weapons:server:RemoveAttachment')
                TriggerClientEvent('bv-inventory:client:ItemBox', src, Core.Shared.Items[AttachmentData.attachment],
                    'add')
                TriggerClientEvent('Core:Notify', src,
                    Lang:t('info.removed_attachment', { value = Core.Shared.Items[AttachmentData.attachment].label }),
                    'error')
                cb(Inventory[WeaponData.slot].info.attachments)
            else
                cb(false)
            end
        else
            cb(false)
        end
    else
        cb(false)
    end
end)
