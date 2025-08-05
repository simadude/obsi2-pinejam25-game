local obsi = require("obsi2")
local ass = require("assetManager")

ass.addMusic("end", "mus/end.nbs")
ass.addSprites("buildings", "sprites/buildings.nfp", 37, 40)
ass.addSprites("spamtruck", "sprites/spamtruck.nfp", 49, 37)
ass.addSprite("road", "sprites/city-road.nfp")
ass.addPalette("city", "palettes/city.pal")
-- ass.addSprite("logo", "sprites/logo.nfp")

return function ()
    obsi.audio.play(ass.music["end"], false)
    obsi.graphics.setPalette(ass.palettes["city"])

    local start_time = obsi.timer.getTime()
    local road_objects = {}
    local max_road_objects = 12
    for i = 0, max_road_objects do
        road_objects[i] = {x = (i-1)*ass.sprites["road"][1].width}
    end

    local function updateRoads(dt)
        local rw = ass.sprites["road"][1].width
        -- find a road with least x
        local min_x = 999999
        local min_x_i = 1
        for i, road in ipairs(road_objects) do
            if min_x > road.x then
                min_x = road.x
                min_x_i = i
            end
        end

        min_x = math.floor(min_x - 60*dt)
        road_objects[min_x_i].x = min_x

        -- update every other road
        local max_x = 0
        local prev_x = min_x
        for i = min_x_i+1, #road_objects do
            prev_x = prev_x+rw
            road_objects[i].x = prev_x
            max_x = math.max(max_x, prev_x)
        end
        for i = 1, min_x_i-1 do
            prev_x = prev_x+rw
            road_objects[i].x = prev_x
            max_x = math.max(max_x, prev_x)
        end

        -- check if the last one is off bound

        if min_x < -rw then
            road_objects[min_x_i].x = max_x+rw
        end
    end

    local building_objects = {}

    local function createBuilding(x, type)
        building_objects[#building_objects+1] = {
            x = x,
            type = type
        }
    end

    for i = 1, obsi.graphics.getPixelWidth()*1.5, 50 do
        createBuilding(i, math.random(4))
    end

    local last_building_time = 0

    local function updateBuildings(dt)
        for _, build in ipairs(building_objects) do
            build.x = build.x - dt*16
        end
        if obsi.timer.getTime()-last_building_time > 4 then
            last_building_time = obsi.timer.getTime()
            local r = math.random(1, 10)
            local t = {1, 2, 3, 4}
            if r == 10 then
                t = {5, 6, 7}
            end
            createBuilding(obsi.graphics.getPixelWidth()*2, t[math.random(1, #t)])
        end
    end

    function obsi.update(dt)
        updateRoads(dt)
        updateBuildings(dt)
    end

    function obsi.draw()
        local w, h = obsi.graphics.getSize()
        local t = obsi.timer.getTime()
        local pw, ph = obsi.graphics.getPixelSize()
        obsi.graphics.setOrigin(0, -ph/2+50)

        local rspr = ass.sprites["road"][1]
        for _, road in ipairs(road_objects) do
            obsi.graphics.draw(rspr, road.x, 59)
        end

        local bspr = ass.sprites["buildings"]
        for _, build in ipairs(building_objects) do
            obsi.graphics.draw(bspr[build.type], build.x, 16)
        end

        obsi.graphics.setForegroundColor("f")
        obsi.graphics.rectangle("fill", 0, 59+rspr.height, pw, ph-59+rspr.height)
        obsi.graphics.setForegroundColor("0")

        rspr = ass.sprites["spamtruck"][math.floor(((5*t)%(#ass.sprites["spamtruck"]-1))+2)]
        local x = math.ceil(math.sin(t+1.5*math.cos(t))*4)
        obsi.graphics.draw(rspr, math.floor((pw/2-rspr.width/2+x)/2)*2+1, 38)

        local text = "Thank you for playing!"
        obsi.graphics.write(text, w/2-#text/2+1, 1)
        local n = ass.music["end"].notes
        text = ("%.1f/%.1f"):format(n[#n].timing+1, t-start_time)
        obsi.graphics.write(text, w-#text+1, h)
        if t-start_time > n[#n].timing+1 then
            obsi.quit()
        end
        obsi.graphics.setBackgroundColor(2^12)
    end

    function obsi.onKeyPress(k)
        if k == keys.q then
            obsi.quit()
        end
    end
end