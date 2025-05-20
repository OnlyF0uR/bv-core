Core.Holograms = {}
Core.Holograms.Draw = function(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local pX, pY, pZ = table.unpack(GetGameplayCamCoords())

    local scale = 0.5

    SetTextScale(scale, scale)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEntry("STRING")
    SetTextCentre(true)
    SetTextColour(255, 255, 255, 215)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 820

    DrawRect(_x, _y + scale / 30, 0.095 + factor, 0.072 * scale, 41, 11, 41, 100)
end