local Config = {
    WebhookURL = 'https://canary.discord.com/api/webhooks/1258017697556598825/7SPYvBctRz1S6JX8rgAReIsp-M8p-viz3jI5kYZiQozC1eUcBWMqf7fOSOR1WnWGXgSc',
    ReportInterval = 30000,
    EmbedColor = 3447003,
    EmbedTitle = "💸 JŪSŲ SERVERIO EKONOMIKA",
    FooterText = "Informacija gauta: ",
    ImageURL = "https://imgur.com/CVGFUZ8.png"
}

local function sendEconomyDataToDiscord(totalCash, totalBank, totalDirty, totalVehicles)
    local description = table.concat({
        "💰 ***Kišenėje laikomi pinigai:***\n" .. totalCash .. "€",
        "💸 ***Banke laikomi pinigai:***\n" .. totalBank .. "€",
        "📈 ***Bendri serverio pinigai:***\n" .. (totalCash + totalBank + totalDirty) .. "€",
        "🚗 ***Viso serveryje nuosavų tr. priemonių:***\n" .. totalVehicles .. " transporto priemonės"
    }, "\n\n")

    local data = {
        {
            ["color"] = Config.EmbedColor,
            ["title"] = Config.EmbedTitle,
            ["description"] = description,
            ["footer"] = {
                ["text"] = Config.FooterText .. os.date("%Y-%m-%d %H:%M:%S")
            },
            ["thumbnail"] = {
                ["url"] = Config.ImageURL
            }
        }
    }

    PerformHttpRequest(Config.WebhookURL, function(err, text, headers)
        if err ~= 204 then
            print("Klaida siunčiant: " .. err)
        else
            print("Sekmingai išsiusta")
        end
    end, 'POST', json.encode({username = Config.ServerName, embeds = data}), { ['Content-Type'] = 'application/json' })
end

local function getEconomyData()
    local totalCash = 0
    local totalBank = 0
    local totalDirty = 0
    local totalVehicles = 0

    MySQL.Async.fetchAll('SELECT accounts FROM users', {}, function(users)
        for i = 1, #users, 1 do
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
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(Config.ReportInterval)
            getEconomyData()
        end
    end)
end

setupEconomyReport()