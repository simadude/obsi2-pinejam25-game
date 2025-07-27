local obsi = require("obsi2")
local game = {}

local image_soul = obsi.graphics.newImage("sprites/blue-soul.nfp")
local image_platform = obsi.graphics.newImage("sprites/platform.nfp")
local player = {x = 30, y = 40, width = image_soul.width, height = image_soul.height, speedY = 0, landed = false}
local center = {x = 0, y = 0}

local floor_platforms = {}
local walls = {
    {x = 2, y = 0, width = 2, height = 256},
    {x = 98, y = 0, width = 2, height = 256},
}
local floor = {x = 2, y = 51, width = 98, height = 2}

-- maximum y margin is 28
local platformRangeY = 5
local platformMarginY = 1

local platformMinX = walls[1].x+walls[1].width+1
local platformMaxX = walls[2].x-20

local function initPlatforms()
    for i = 1, 10 do
        local platx = math.random(platformMinX, platformMaxX)
        local platy = floor_platforms[i-1] and floor_platforms[i-1].y - platformRangeY + math.random(-platformMarginY, platformMarginY) or 30
        floor_platforms[i] = {x = platx, y = platy, width = image_platform.width, height = image_platform.height}
    end
end

local function spawnPlatforms()
    if center.y < floor_platforms[#floor_platforms].y then
        if center.y < -100 then
            platformRangeY = 10
        end
        if center.y < -300 then
            platformRangeY = 15
        end
        if center.y < -500 then
            platformRangeY = 20
        end
        if center.y < -700 then
            platformRangeY = 23
        end
        for i = 1, 10 do
            local platx = math.random(platformMinX, platformMaxX)
            local prevplatx = floor_platforms[#floor_platforms].x
            if math.abs(platx-prevplatx) > 30 then
                if platx > prevplatx then
                    platx = prevplatx+29
                else
                    platx = prevplatx-30
                end
            end
            local platy = floor_platforms[#floor_platforms].y - platformRangeY + math.random(-platformMarginY, platformMarginY)
            floor_platforms[#floor_platforms+1] = {x = platx, y = platy, width = image_platform.width, height = image_platform.height}
            if math.random(1, 10) == 5 then
                for j = 1, 3 do
                    platx = math.random(platformMinX, platformMaxX)
                    local platformRangeY = 10
                    platy = floor_platforms[#floor_platforms].y - platformRangeY + math.random(-platformMarginY, platformMarginY)
                    floor_platforms[#floor_platforms+1] = {x = platx, y = platy, width = image_platform.width, height = image_platform.height}
                end
            end
        end
    end
end

function obsi.load()
    initPlatforms()
end

function obsi.update(dt)
    if obsi.keyboard.isDown("left") then
        player.x = player.x - 30*dt
    end
    if obsi.keyboard.isDown("right") then
        player.x = player.x + 30*dt
    end
    player.x = math.min(walls[2].x-player.width, player.x)
    player.x = math.max(walls[1].x+walls[1].width, player.x)
    -- check if floor under player
    if player.y+player.height >= floor.y then
        player.landed = true
        player.y = floor.y - player.height
    else
        player.landed = false
    end
    -- check if platforms under player
    if player.speedY >= 0 then
        for _, platform in ipairs(floor_platforms) do
            -- AABB collision test
            local overlapX = player.x < platform.x + platform.width and
                             player.x + player.width > platform.x
            local overlapY = player.y + player.height >= platform.y and
                             player.y + player.height <= platform.y + platform.height + 2 -- small tolerance
            if overlapX and overlapY then
                player.landed = true
                player.y = platform.y - player.height
                player.speedY = 0
                break
            end
        end
    end
    if not player.landed then
        player.speedY = player.speedY + 20*dt
        player.y = player.y + player.speedY * 5*dt
    elseif obsi.keyboard.isDown("up") then -- gonna assume player.landed==true
        player.speedY = -15
        player.y = player.y - 1
    end
    for _, wall in ipairs(walls) do
        wall.height = math.min(256, floor.y-center.y+2)
    end
    if center.y > player.y - 10 then
        center.y = player.y - 10
    else
        center.y = center.y - 6*dt
    end

    spawnPlatforms()
end

function obsi.draw()
    local w, h = obsi.graphics.getSize()
    local pw, ph = obsi.graphics.getPixelSize()
    if w/51 >= 2 and h/19 >= 2 and obsi.graphics.getRenderer() ~= "neat" then
        obsi.graphics.setRenderer("neat")
    elseif (w/51 <= 2 or h/19 < 2) and obsi.graphics.getRenderer() ~= "pixelbox" then
        obsi.graphics.setRenderer("pixelbox")
    end
    center.x = (98+4-pw)/2
    obsi.graphics.setOrigin(center.x, 0)
    obsi.graphics.setForegroundColor(colors.green)
    for _, wall in ipairs(walls) do
        obsi.graphics.rectangle("fill", wall.x, wall.y, wall.width, wall.height)
    end
    obsi.graphics.setOrigin(center.x, center.y)
    obsi.graphics.rectangle("fill", floor.x, floor.y, floor.width, floor.height)
    obsi.graphics.setForegroundColor("0")
    for _, platform in ipairs(floor_platforms) do
        obsi.graphics.draw(image_platform, platform.x, platform.y)
    end
    obsi.graphics.draw(image_soul, player.x, player.y)
    -- obsi.graphics.write(("%s"):format(#floor_platforms), 1, 1)
    -- obsi.graphics.write(("%s"):format(platformRangeY), 1, 1)
end

obsi.init()

-- return game