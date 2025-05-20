Config = {}

Config.MaxPlayers = GetConvarInt('sv_maxclients', 48) -- Gets max players from config file, default 48
Config.DefaultSpawn = vector4(-1035.71, -2731.87, 12.86, 0.0)
Config.UpdateInterval = 5                             -- how often to update player data in minutes
Config.StatusInterval = 5000                          -- how often to check hunger/thirst status in milliseconds

Config.Money = {}
Config.Money.MoneyTypes = { cash = 500, bank = 5000, crypto = 0 } -- type = startamount - Add or remove money types for your server (for ex. blackmoney = 0), remember once added it will not be removed from the database!
Config.Money.DontAllowMinus = { 'cash', 'crypto' }                -- Money that is not allowed going in minus
Config.Money.MinusLimit = -5000                                    -- The maximum amount you can be negative 
Config.Money.PayCheckTimeOut = 10                                 -- The time in minutes that it will give the paycheck

Config.Player = {}
Config.Player.HungerRate = 4.2 -- Rate at which hunger goes down.
Config.Player.ThirstRate = 3.8 -- Rate at which thirst goes down.
Config.Player.Bloodtypes = {
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
}

Config.Player.PlayerDefaults = {
    citizenid = function() return Core.Player.CreateCitizenId() end,
    cid = 1,
    money = function()
        local moneyDefaults = {}
        for moneytype, startamount in pairs(Config.Money.MoneyTypes) do
            moneyDefaults[moneytype] = startamount
        end
        return moneyDefaults
    end,
    optin = true,
    charinfo = {
        firstname = 'Firstname',
        lastname = 'Lastname',
        birthdate = '00-00-0000',
        gender = 0,
        nationality = 'USA',
        phone = function() return Core.Functions.CreatePhoneNumber() end,
        account = function() return Core.Functions.CreateAccountNumber() end
    },
    job = {
        name = 'unemployed',
        label = 'Civilian',
        payment = 10,
        type = 'none',
        onduty = false,
        isboss = false,
        grade = {
            name = 'Freelancer',
            level = 0
        }
    },
    gang = {
        name = 'none',
        label = 'No Gang Affiliation',
        isboss = false,
        grade = {
            name = 'none',
            level = 0
        }
    },
    metadata = {
        hunger = 100,
        thirst = 100,
        stress = 0,
        isdead = false,
        inlaststand = false,
        armor = 0,
        ishandcuffed = false,
        tracker = false,
        injail = 0,
        jailitems = {},
        status = {},
        phone = {},
        rep = {},
        currentapartment = nil,
        callsign = 'NO CALLSIGN',
        bloodtype = function() return Config.Player.Bloodtypes[math.random(1, #Config.Player.Bloodtypes)] end,
        fingerprint = function() return Core.Player.CreateFingerId() end,
        walletid = function() return Core.Player.CreateWalletId() end,
        criminalrecord = {
            hasRecord = false,
            date = nil
        },
        licences = {
            driver = true,
            business = false,
            weapon = false
        },
        inside = {
            house = nil,
            apartment = {
                apartmentType = nil,
                apartmentId = nil,
            }
        },
        phonedata = {
            SerialNumber = function() return Core.Player.CreateSerialNumber() end,
            InstalledApps = {}
        }
    },
    position = Config.DefaultSpawn,
    items = {},
}

Config.Server = {}                                    -- General server config
Config.Server.Closed = false                          -- Set server closed (no one can join except people with ace permission 'qbadmin.join')
Config.Server.ClosedReason = 'Server Closed'          -- Reason message to display when people can't join the server
Config.Server.Uptime = 0                              -- Time the server has been up.
Config.Server.Whitelist = false                       -- Enable or disable whitelist on the server
Config.Server.WhitelistPermission = 'admin'           -- Permission that's able to enter the server when the whitelist is on
Config.Server.PVP = true                              -- Enable or disable pvp on the server (Ability to shoot other players)
Config.Server.Discord = ''                            -- Discord invite link
Config.Server.CheckDuplicateLicense = true            -- Check for duplicate rockstar license on join
Config.Server.Permissions = { 'admin', 'mod' } -- Add as many groups as you want here after creating them in your server.cfg

Config.Commands = {}                                  -- Command Configuration
Config.Commands.OOCColor = { 255, 151, 133 }          -- RGB color code for the OOC command