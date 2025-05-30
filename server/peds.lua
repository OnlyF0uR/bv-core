local _pedSet = {}

RegisterNetEvent("Core:Server:RegisterPed", function(networkId)
  _pedSet[networkId] = true
end)

Core.Functions.CreateCallback("Core:Server:IsRegisteredPed", function(source, cb, networkId)
  cb(_pedSet[networkId] ~= nil)
end)
