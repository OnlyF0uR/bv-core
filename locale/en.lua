local Translations = {
    error = {
        not_online                  = 'Player not online',
        wrong_format                = 'Incorrect format',
        missing_args                = 'Not every argument has been entered (x, y, z)',
        missing_args2               = 'All arguments must be filled out!',
        no_access                   = 'No access to this command',
        company_too_poor            = 'Your employer is broke',
        item_not_exist              = 'Item does not exist',
        too_heavy                   = 'Inventory too full',
        location_not_exist          = 'Location does not exist',
        duplicate_license           = '[Core] - Duplicate Rockstar License Found',
        no_valid_license            = '[Core] - No Valid Rockstar License Found',
        not_whitelisted             = '[Core] - You\'re not whitelisted for this server',
        server_already_open         = 'The server is already open',
        server_already_closed       = 'The server is already closed',
        no_permission               = 'You don\'t have permissions for this..',
        no_waypoint                 = 'No Waypoint Set.',
        tp_error                    = 'Error While Teleporting.',
        ban_table_not_found         =
        '[Core] - Unable to find the bans table in the database. Please ensure you have imported the SQL file correctly.',
        connecting_database_error   =
        '[Core] - An error occurred while connecting to the database. Ensure that the SQL server is running and that the details in the server.cfg file are correct.',
        connecting_database_timeout =
        '[Core] - The database connection has timed out. Ensure that the SQL server is running and that the details in the server.cfg file are correct.',
    },
    success = {
        server_opened = 'The server has been opened',
        server_closed = 'The server has been closed',
        teleported_waypoint = 'Teleported To Waypoint.',
    },
    info = {
        received_paycheck = 'You received your paycheck of $%{value}',
        job_info = 'Job: %{value} | Grade: %{value2} | Duty: %{value3}',
        gang_info = 'Gang: %{value} | Grade: %{value2}',
        on_duty = 'You are now on duty!',
        off_duty = 'You are now off duty!',
        checking_ban = 'Hello %s. We are checking if you are banned.',
        join_server = 'Welcome %s to {Server Name}.',
        checking_whitelisted = 'Hello %s. We are checking your allowance.',
        exploit_banned = 'You have been banned for cheating. Check our Discord for more information: %{discord}',
        exploit_dropped = 'You Have Been Kicked For Exploitation',
    },
    command = {
        tp = {
            help = 'TP To Player or Coords (Admin Only)',
            params = {
                x = { name = 'id/x', help = 'ID of player or X position' },
                y = { name = 'y', help = 'Y position' },
                z = { name = 'z', help = 'Z position' },
            },
        },
        tpm = { help = 'TP To Marker (Admin Only)' },
        togglepvp = { help = 'Toggle PVP on the server (Admin Only)' },
        addpermission = {
            help = 'Give Player Permissions (God Only)',
            params = {
                id = { name = 'id', help = 'ID of player' },
                permission = { name = 'permission', help = 'Permission level' },
            },
        },
        removepermission = {
            help = 'Remove Player Permissions (God Only)',
            params = {
                id = { name = 'id', help = 'ID of player' },
                permission = { name = 'permission', help = 'Permission level' },
            },
        },
        openserver = { help = 'Open the server for everyone (Admin Only)' },
        closeserver = {
            help = 'Close the server for people without permissions (Admin Only)',
            params = {
                reason = { name = 'reason', help = 'Reason for closing (optional)' },
            },
        },
        car = {
            help = 'Spawn Vehicle (Admin Only)',
            params = {
                model = { name = 'model', help = 'Model name of the vehicle' },
            },
        },
        dv = { help = 'Delete Vehicle (Admin Only)' },
        dvall = { help = 'Delete All Vehicles (Admin Only)' },
        dvp = { help = 'Delete All Peds (Admin Only)' },
        dvo = { help = 'Delete All Objects (Admin Only)' },
        givemoney = {
            help = 'Give A Player Money (Admin Only)',
            params = {
                id = { name = 'id', help = 'Player ID' },
                moneytype = { name = 'moneytype', help = 'Type of money (cash, bank, crypto)' },
                amount = { name = 'amount', help = 'Amount of money' },
            },
        },
        setmoney = {
            help = 'Set Players Money Amount (Admin Only)',
            params = {
                id = { name = 'id', help = 'Player ID' },
                moneytype = { name = 'moneytype', help = 'Type of money (cash, bank, crypto)' },
                amount = { name = 'amount', help = 'Amount of money' },
            },
        },
        job = { help = 'Check Your Job' },
        setjob = {
            help = 'Set A Players Job (Admin Only)',
            params = {
                id = { name = 'id', help = 'Player ID' },
                job = { name = 'job', help = 'Job name' },
                grade = { name = 'grade', help = 'Job grade' },
            },
        },
        gang = { help = 'Check Your Gang' },
        setgang = {
            help = 'Set A Players Gang (Admin Only)',
            params = {
                id = { name = 'id', help = 'Player ID' },
                gang = { name = 'gang', help = 'Gang name' },
                grade = { name = 'grade', help = 'Gang grade' },
            },
        },
        ooc = { help = 'OOC Chat Message' },
        me = {
            help = 'Show local message',
            params = {
                message = { name = 'message', help = 'Message to send' }
            },
        },
    },
    weathersync = {
        weather = {
            now_frozen = 'Weather is now frozen.',
            now_unfrozen = 'Weather is no longer frozen.',
            invalid_syntax = 'Invalid syntax, correct syntax is: /weather <weathertype> ',
            invalid_syntaxc = 'Invalid syntax, use /weather <weatherType> instead!',
            updated = 'Weather has been updated.',
            invalid =
            'Invalid weather type, valid weather types are: \nEXTRASUNNY CLEAR NEUTRAL SMOG FOGGY OVERCAST CLOUDS CLEARING RAIN THUNDER SNOW BLIZZARD SNOWLIGHT XMAS HALLOWEEN ',
            invalidc =
            'Invalid weather type, valid weather types are: \nEXTRASUNNY CLEAR NEUTRAL SMOG FOGGY OVERCAST CLOUDS CLEARING RAIN THUNDER SNOW BLIZZARD SNOWLIGHT XMAS HALLOWEEN ',
            willchangeto = 'Weather will change to: %{value}.',
            accessdenied = 'Access for command /weather denied.',
        },
        dynamic_weather = {
            disabled = 'Dynamic weather changes are now disabled.',
            enabled = 'Dynamic weather changes are now enabled.',
        },
        time = {
            frozenc = 'Time is now frozen.',
            unfrozenc = 'Time is no longer frozen.',
            now_frozen = 'Time is now frozen.',
            now_unfrozen = 'Time is no longer frozen.',
            morning = 'Time set to morning.',
            noon = 'Time set to noon.',
            evening = 'Time set to evening.',
            night = 'Time set to night.',
            change = 'Time has changed to %{value}:%{value2}.',
            changec = 'Time was changed to: %{value}!',
            invalid = 'Invalid syntax, correct syntax is: time <hour> <minute> !',
            invalidc = 'Invalid syntax. Use /time <hour> <minute> instead!',
            access = 'Access for command /time denied.',
        },
        blackout = {
            enabled = 'Blackout is now enabled.',
            enabledc = 'Blackout is now enabled.',
            disabled = 'Blackout is now disabled.',
            disabledc = 'Blackout is now disabled.',
        },
        help = {
            weathercommand = 'Change the weather.',
            weathertype = 'weathertype',
            availableweather =
            'Available types: extrasunny, clear, neutral, smog, foggy, overcast, clouds, clearing, rain, thunder, snow, blizzard, snowlight, xmas & halloween',
            timecommand = 'Change the time.',
            timehname = 'hours',
            timemname = 'minutes',
            timeh = 'A number between 0 - 23',
            timem = 'A number between 0 - 59',
            freezecommand = 'Freeze / unfreeze time.',
            freezeweathercommand = 'Enable/disable dynamic weather changes.',
            morningcommand = 'Set the time to 09:00',
            nooncommand = 'Set the time to 12:00',
            eveningcommand = 'Set the time to 18:00',
            nightcommand = 'Set the time to 23:00',
            blackoutcommand = 'Toggle blackout mode.',
        },
    },
    carlocks = {
        locked = 'Vehicle is now locked.',
        unlocked = 'Vehicle is now unlocked.',
        lockpicked = 'Successfully lockpicked the vehicle.',
        lockpick_failed = 'Lockpick failed, try again.',
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
