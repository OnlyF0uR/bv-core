RegisterNetEvent('core_dev:server:possave')
AddEventHandler('core_dev:server:possave', function(points)
    local src = source
    if not Core.Functions.HasPermission(src, 'admin') then return end
    if not points or #points == 0 then return end

    local textString = ''

    for k,v in pairs(points) do
        textString = textString .. ("vector3(%s, %s, %s),\n"):format(v.x, v.y, v.z)
    end

    local time = os.time(os.date('*t'))
    SaveResourceFile(GetCurrentResourceName(), 'files/' .. time .. '.txt', textString)
end)

Core.Commands.Add('poscollect', 'Collects the position of the player', {}, false, function(src, args)
    TriggerClientEvent('core_dev:client:poscollect', src)
end, 'admin')

Core.Commands.Add('getheading', 'Get the heading of the player', {}, false, function(src, args)
    TriggerClientEvent('core_dev:client:poscollect:getheading', src)
end, 'admin')

Core.Commands.Add('idgun', 'Activate ID gun mode', {}, false, function(src, args)
    TriggerClientEvent('core_dev:client:idgun', src)
end, 'admin')