local webhookURL = 'WEBHOOK' -- ĮRAŠYKITE SAVO WEBHOOK

local function sendEconomyDataToDiscord(totalCash, totalBank, totalDirty, totalVehicles)
    local description = table.concat({
        "💵 **Kišenėje laikomi pinigai:**\n" .. totalCash .. "€",
        "🏦 **Banke laikomi pinigai:**\n" .. totalBank .. "€",
        "💰 **Viso pinigų serveryje:**\n" .. (totalCash + totalBank + totalDirty) .. "€",
        "🚗 **Viso serveryje nuosavų tr. priemonių:**\n" .. totalVehicles .. " transporto priemonės"
    }, "\n\n")

    local data = {
        {
            ["color"] = 3447003,
            ["title"] = "🟢 SERVERIO EKONOMIKA",
            ["description"] = description,
            ["footer"] = {
                ["text"] = "Informacija gauta: " .. os.date("%Y-%m-%d %H:%M:%S")
            },
            ["image"] = {
                ["url"] = "https://api.delfi.lt/media-api-image-cropper/v1/ed705dc0-7d85-11ed-bf2e-07693578e20d.jpg" -- ( JŪSŲ NORIMA NUOTRAUKA )
            }
        }
    }

    PerformHttpRequest(webhookURL, function(err, text, headers)
        if err ~= 204 then
            print("Klaida siunčiant: " .. err)
        else
            print("Sekmingai išsiusta")
        end
    end, 'POST', json.encode({username = "SERVERIO EKONOMIKA", embeds = data}), { ['Content-Type'] = 'application/json' })
end

local function getEconomyData()
    local totalCash = 0
    local totalBank = 0
    local totalDirty = 0
    local totalVehicles = 0

    MySQL.Async.fetchAll('SELECT accounts FROM users', {}, function(users)
        for i=1, #users, 1 do
            local accounts = json.decode(users[i].accounts)
            totalCash = totalCash + (accounts.money or 0)
            totalBank = totalBank + (accounts.bank or 0)
            totalDirty = totalDirty + (accounts.black_money or 0)
        end

        MySQL.Async.fetchScalar('SELECT COUNT(*) FROM owned_vehicles', {}, function(vehicleCount)
            totalVehicles = vehicleCount

            sendEconomyDataToDiscord(totalCash, totalBank, totalDirty, totalVehicles)
        end)
    end)
end

local function setupEconomyReport()
    local interval = 21600000 -- ( LAIKAS M. SEC )
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(interval)
            getEconomyData()
        end
    end)
end

setupEconomyReport()
