local OLD_TABLE_NAME = "" -- old table name for all your vehicles

local function transferVehicles()
    if OLD_TABLE_NAME == "" then
        print("OLD_TABLE_NAME is currently nil.")
        return
    end

    local fetchQuery = string.format("SELECT * FROM `%s`", OLD_TABLE_NAME)

    exports.oxmysql:execute(fetchQuery, {}, function(results)
        if not results or #results == 0 then
            print("no vehicles found in old table")
            return
        end

        local insertQuery = [[
            INSERT INTO cardealer_cars (model, display, price, category, brand, image)
            VALUES (?, ?, ?, ?, ?, ?)
        ]]

        for _, row in ipairs(results) do
            -- CHANGE ALL THESE TO MATCH YOUR CURRENT OLD TABLE DATA.
            local model = row.vehicle_id or ""
            local display = row.vehicle_name or ""
            local price = tonumber(row.max_price) or 0
            local category = string.format('[ "%s" ]', row.category or "") -- this has to be an array it should look something like this [ 'categoryname1', 'categoryname2' ]
            local brand = row.brand or "GTA"
            local image = ""

            local params = { model, display, price, category, brand, image }
            exports.oxmysql:execute(insertQuery, params)
        end

        print(string.format("Transferred %d vehicles from %s to cardealer_cars.", #results, OLD_TABLE_NAME))
    end)
end

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        transferVehicles()
    end
end)
