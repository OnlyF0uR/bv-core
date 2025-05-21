local carrying = {}
--carrying[src] = targetSource, src is carrying targetSource
local carried = {}
--carried[targetSource] = src, targetSource is being carried by src

RegisterServerEvent("core-adapters:carry:sync")
AddEventHandler("core-adapters:carry:sync", function(targetSrc)
	local src = source
	local sourcePed = GetPlayerPed(src)
   	local sourceCoords = GetEntityCoords(sourcePed)
	local targetPed = GetPlayerPed(targetSrc)
        local targetCoords = GetEntityCoords(targetPed)
	if #(sourceCoords - targetCoords) <= 3.0 then 
		TriggerClientEvent("core-adapters:carry:syncTarget", targetSrc, src)
		carrying[src] = targetSrc
		carried[targetSrc] = src
	end
end)

RegisterServerEvent("core-adapters:carry:stop")
AddEventHandler("core-adapters:carry:stop", function(targetSrc)
	local src = source

	if carrying[src] then
		TriggerClientEvent("core-adapters:carry:cl_stop", targetSrc)
		carrying[src] = nil
		carried[targetSrc] = nil
	elseif carried[src] then
		TriggerClientEvent("core-adapters:carry:cl_stop", carried[src])			
		carrying[carried[src]] = nil
		carried[src] = nil
	end
end)

AddEventHandler('playerDropped', function(reason)
	local src = source
	
	if carrying[src] then
		TriggerClientEvent("core-adapters:carry:cl_stop", carrying[src])
		carried[carrying[src]] = nil
		carrying[src] = nil
	end

	if carried[src] then
		TriggerClientEvent("core-adapters:carry:cl_stop", carried[src])
		carrying[carried[src]] = nil
		carried[src] = nil
	end
end)