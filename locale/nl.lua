local Translations = {
    error = {
        not_online                  = 'Speler niet online',
        wrong_format                = 'Onjuiste opmaak',
        missing_args                = 'Niet elk argument is ingevuld (x, y, z)',
        missing_args2               = 'Alle argumenten moeten worden ingevuld!',
        no_access                   = 'Geen toegang tot dit commando',
        company_too_poor            = 'Je werkgever is arm',
        item_not_exist              = 'Item bestaat niet',
        too_heavy                   = 'Broekzakken zitten vol',
        location_not_exist          = 'Locatie bestaat niet',
        duplicate_license           = 'Dubbele Rockstar-licentie gevonden',
        no_valid_license            = 'Geen geldige Rockstar-licentie gevonden',
        not_whitelisted             = 'U bent niet whitelisted voor deze server',
        server_already_open         = 'De server is al open',
        server_already_closed       = 'De server is al gesloten',
        no_permission               = 'Je hebt geen permissie voor dit..',
        no_waypoint                 = 'Geen bestemming geselecteerd',
        tp_error                    = 'Er is een foutje begaan tijdens het teleporteren',
        connecting_database_error   =
        'Er is een databasefout opgetreden tijdens het maken van een verbinding met de server. (Is de SQL-server ingeschakeld?)',
        connecting_database_timeout =
        'Er is een time-out opgetreden voor verbinding met database. (Is de SQL-server ingeschakeld?)',
    },
    success = {
        server_opened = 'De server is geopend',
        server_closed = 'De server is gesloten',
        teleported_waypoint = 'Geteleporteerd naar bestemming',
    },
    info = {
        received_paycheck = 'Je hebt je salaris ontvangen van $%{value}',
        job_info = 'Job: %{value} | Graad: %{value2} | Dienst: %{value3}',
        gang_info = 'Gang: %{value} | Graad: %{value2}',
        on_duty = 'U bent nu in dienst!',
        off_duty = 'U bent nu uit dienst!',
        checking_ban = 'Hallo %s. We checken even of je op onze banlist staat.',
        join_server = 'Welkom %s bij {Server Name}.',
        checking_whitelisted = 'Hallo %s. We checken even of je toegang hebt.',
        exploit_banned = 'Je bent verbannen wegens cheating. Bekijk onze Discord voor meer informatie: %{discord}',
        exploit_dropped = 'Je bent gekicked voor exploitation',
    },
    command = {
        tp = {
            help = 'Teleport naar speler of coördinaten (Alleen Admin)',
            params = {
                x = { name = 'id/x', help = 'ID van speler of X-positie' },
                y = { name = 'y', help = 'Y positie' },
                z = { name = 'z', help = 'Z positie' },
            },
        },
        tpm = { help = 'Teleport naar bestemming (Alleen Admin)' },
        togglepvp = { help = 'PVP op de server in-/uitschakelen (Alleen Admin)' },
        addpermission = {
            help = 'Spelersmachtigingen toevoegen (alleen God)',
            params = {
                id = { name = 'id', help = 'ID van de speler' },
                permission = { name = 'permission', help = 'Machtigingsniveau' },
            },
        },
        removepermission = {
            help = 'Spelersmachtigingen verwijderen (alleen God)',
            params = {
                id = { name = 'id', help = 'ID van de speler' },
                permission = { name = 'permission', help = 'Machtigingsniveau' },
            },
        },
        openserver = { help = 'Open de server voor iedereen (Alleen Admin)' },
        closeserver = {
            help = 'Sluit de server voor personen zonder machtigingen (Alleen Admin)',
            params = {
                reason = { name = 'reason', help = 'Reden voor sluiting (optioneel)' },
            },
        },
        car = {
            help = 'Spawn Voertuig (Alleen Admin)',
            params = {
                model = { name = 'model', help = 'Modelnaam van het voertuig' },
            },
        },
        dv = { help = 'Verwijder Voertuig (Alleen Admin)' },
        givemoney = {
            help = 'Geef een speler geld (Alleen Admin)',
            params = {
                id = { name = 'id', help = 'Speler ID' },
                moneytype = { name = 'moneytype', help = 'Type geld (cash, bank, crypto)' },
                amount = { name = 'amount', help = 'Hoeveelheid geld' },
            },
        },
        setmoney = {
            help = 'Stel spelers geldbedrag in (Alleen Admin)',
            params = {
                id = { name = 'id', help = 'Speler ID' },
                moneytype = { name = 'moneytype', help = 'Type geld (cash, bank, crypto)' },
                amount = { name = 'amount', help = 'Hoeveelheid geld' },
            },
        },
        job = { help = 'Controleer uw job' },
        setjob = {
            help = 'Een speler zijn job instellen (Alleen Admin)',
            params = {
                id = { name = 'id', help = 'Speler ID' },
                job = { name = 'job', help = 'Job naam' },
                grade = { name = 'grade', help = 'Job graad' },
            },
        },
        gang = { help = 'Controleer uw bende' },
        setgang = {
            help = 'Een speler zijn bende instellen (Alleen Admin)',
            params = {
                id = { name = 'id', help = 'Speler ID' },
                gang = { name = 'gang', help = 'Bendenaam' },
                grade = { name = 'grade', help = 'Bende rol' },
            },
        },
        ooc = { help = 'OOC Chat Bericht' },
        me = {
            help = 'Lokaal bericht weergeven',
            params = {
                message = { name = 'message', help = 'Bericht dat je wil versturen' }
            },
        },
    },
    weathersync = {
        weather = {
            now_frozen = 'Weer is bevroren.',
            now_unfrozen = 'Weer is niet langer bevroren.',
            invalid_syntax = 'Ongeldige commando, correcte commando is: /weather <weertype> ',
            invalid_syntaxc = 'Ongeldige commando, gebruik /weather <weertype> !',
            updated = 'Het weer is bijgewerkt.',
            invalid =
            'Ongeldig weertype, geldige weertypes zijn: \nEXTRASUNNY CLEAR NEUTRAL SMOG FOGGY OVERCAST CLOUDS CLEARING RAIN THUNDER SNOW BLIZZARD SNOWLIGHT XMAS HALLOWEEN ',
            invalidc =
            'Ongeldig weertype, geldige weertypes zijn: \nEXTRASUNNY CLEAR NEUTRAL SMOG FOGGY OVERCAST CLOUDS CLEARING RAIN THUNDER SNOW BLIZZARD SNOWLIGHT XMAS HALLOWEEN ',
            willchangeto = 'Het weer verandert in: %{value}.',
            accessdenied = 'Toegang voor commando /weather geweigerd.',
        },
        dynamic_weather = {
            disabled = 'Dynamische weersveranderingen zijn nu uitgeschakeld.',
            enabled = 'Dynamische weersveranderingen zijn nu ingeschakeld.',
        },
        time = {
            frozenc = 'De tijd is bevroren.',
            unfrozenc = 'De tijd is niet langer bevroren.',
            now_frozen = 'De tijd is bevroren.',
            now_unfrozen = 'De tijd is niet langer bevroren.',
            morning = 'Tijd ingesteld op ochtend.',
            noon = 'Tijd ingesteld op middag.',
            evening = 'Tijd ingesteld op avond.',
            night = 'Tijd ingesteld op nacht.',
            change = 'De tijd is veranderd in %{value}:%{value2}.',
            changec = 'De tijd is veranderd in: %{value}!',
            invalid = 'Ongeldige commando, correcte commando is: time <hour> <minute> !',
            invalidc = 'Ongeldige commando. gebruik /time <uur> <minuut> !',
            access = 'Toegang voor commando /time geweigerd.',
        },
        blackout = {
            enabled = 'Black-out is ingeschakeld.',
            enabledc = 'Black-out is ingeschakeld.',
            disabled = 'Black-out is uitgeschakeld.',
            disabledc = 'Black-out is uitgeschakeld.',
        },
        help = {
            weathercommand = 'Verander het weer.',
            weathertype = 'weertype',
            availableweather =
            'Beschikbare typen: extrasunny, clear, neutral, smog, foggy, overcast, clouds, clearing, rain, thunder, snow, blizzard, snowlight, xmas & halloween',
            timecommand = 'Verander de tijd.',
            timehname = 'uren',
            timemname = 'minuten',
            timeh = 'Een getal tussen 0 - 23',
            timem = 'Een getal tussen 0 - 59',
            freezecommand = 'Tijd bevriezen / ontdooien.',
            freezeweathercommand = 'Dynamische weersveranderingen in-/uitschakelen.',
            morningcommand = 'Zet de tijd op 09:00',
            nooncommand = 'Zet de tijd op 12:00',
            eveningcommand = 'Zet de tijd op 18:00',
            nightcommand = 'Zet de tijd op 23:00',
            blackoutcommand = 'Schakel de black-outmodus.',
        },
    },
    carlocks = {
        locked = 'Voertuig is nu gesloten.',
        unlocked = 'Voertuig is nu open.',
        lockpicked = 'Voertuig successvol gelockpickt.',
        lockpick_failed = 'Lockpickpoging gefaald, probeer opnieuw.',
    }
}

if GetConvar('qb_locale', 'en') == 'nl' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
