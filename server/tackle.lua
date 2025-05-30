RegisterServerEvent('core-adapters:server:SendTackle', function(target)
  TriggerClientEvent('core-adapters:client:GetTackled', target)
end)
