local obsi = require("obsi2")
local ass = require("assetManager")

local game = {}

if not ass.sprites["soul"] then
    ass.addSprites("soul", "sprites/blue-soul.nfp", 6, 5)
end
if not ass.sprites["star"] then
    ass.addSprites("star", "sprites/star.nfp", 8, 8)
end

local image_soul = ass.sprites["soul"][1]
local star = ass.sprites["star"]
local image_platform = obsi.graphics.newImage("sprites/platform.nfp")
local music = obsi.audio.newSound("mus/rules.nbs")
local winMusic = obsi.audio.newSound("mus/win.onb")
local player = {x = 30, y = 40, width = image_soul.width, height = image_soul.height, speedY = 0, landed = false}
local center = {x = 0, y = 0}
ass.addSprites("enemy1", "sprites/enemy1.nfp", 12, 12)
ass.addSprites("enemy2", "sprites/enemy2.nfp", 12, 11)
local enemy1 = ass.sprites["enemy1"]
local enemy2 = ass.sprites["enemy2"]
local enemies = {}
local hasStarted = false
local gameOver = false
local highScore = settings.get("obsi-spamton-highscore", 0)
local firstPlay = settings.get("obsi-spamton-firstPlay", true)
local score = 0
local health = 3
local carParts = {}
local carPartsCount = 0
local maximumCarParts = 10
local hasWon = false
local winTime = 0
local playedWinMusic = false
local damageTime = 0
local splashText = 1

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
        floor_platforms[i] = {x = platx, y = platy, width = image_platform.width, height = image_platform.height, type = 1}
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
            local r = math.random(1, 20)
            if r <= 10 then
                floor_platforms[#floor_platforms+1] = {x = platx, y = platy, width = image_platform.width, height = image_platform.height, type = 1}
            elseif r <= 15 then
                for j = 1, 3 do
                    platx = math.random(platformMinX, platformMaxX)
                    local platformRangeY = 10
                    platy = floor_platforms[#floor_platforms].y - platformRangeY + math.random(-platformMarginY, platformMarginY)
                    floor_platforms[#floor_platforms+1] = {x = platx, y = platy, width = image_platform.width, height = image_platform.height, type = 1}
                    if math.random(1, 5) == 1 then
                        if carParts[#carParts] then
                            if carParts[#carParts].y - platy > 50 then
                                carParts[#carParts+1] = {x = platx+math.random(-8, 16), y = platy-8, width = star[1].width, height = star[1].height}
                            end
                        else
                            carParts[#carParts+1] = {x = platx+math.random(-8, 16), y = platy-8, width = star[1].width, height = star[1].height}
                        end
                    end
                    if math.random(1, 10) > 7 and player.y < -500 then
                        local enemyType = math.random(1, 2)
                        local enemy = {x = math.random(walls[1].x, walls[2].x-12), y = platy-12+math.random(-2, 0), type = enemyType, width = enemyType == 1 and enemy1[1].width or enemy2[1].width, height = enemyType == 1 and enemy1[1].height or enemy2[1].height}
                        enemies[#enemies+1] = enemy
                    end
                end
            elseif r < 20 then
                floor_platforms[#floor_platforms+1] = {x = platx, y = platy, width = image_platform.width, height = image_platform.height, type = 2}
            end
        end
    end
end

function game.reset()
    player.x = 30
    player.y = 42
    center.y = 0
    carParts = {}
    carPartsCount = 0
    floor_platforms = {}
    enemies = {}
    platformRangeY = 5
    platformMarginY = 1
    initPlatforms()
    hasStarted = false
    gameOver = false
    score = 0
    health = 3
end

function game.load()
    playedWinMusic = false
    obsi.graphics.clearPalette()
    settings.set("obsi-spamton-skipcutscene", true)
    function obsi.update(dt)
        if not gameOver and not hasWon then
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
            score = math.max(score, math.floor(-player.y+40))
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
            if obsi.timer.getTime()-damageTime > 2.5 then
                for _, enemy in ipairs(enemies) do
                    -- AABB collision test
                    local overlapX = player.x < enemy.x + enemy.width-2 and
                                    player.x + player.width > enemy.x+2
                    local overlapY = player.y + player.height >= enemy.y+2 and
                                    player.y + player.height <= enemy.y + enemy.height-2
                    if overlapX and overlapY then
                        health = math.max(0, health-1)
                        damageTime = obsi.timer.getTime()
                    end
                end
            end
        end

        for i, carPart in ipairs(carParts) do
            -- AABB collision test
            local overlapX = player.x < carPart.x + carPart.width-2 and
                            player.x + player.width > carPart.x+2
            local overlapY = player.y + player.height >= carPart.y+2 and
                            player.y + player.height <= carPart.y + carPart.height-2
            if overlapX and overlapY then
                table.remove(carParts, i)
                carPartsCount = carPartsCount + 1
            end
        end

        if not hasWon and carPartsCount == maximumCarParts then
            hasWon = true
            winTime = obsi.timer.getTime()
            hasStarted = false
        end

        if not hasStarted and not hasWon then
            hasStarted = (-player.y+40) > 0
        end
        if gameOver or (not hasStarted and not hasWon) or (hasWon and not obsi.audio.isID(winMusic, 1) and not playedWinMusic) then
            obsi.audio.stop(1)
        elseif not gameOver and not obsi.audio.isID(music, 1) and not hasWon then
            obsi.audio.play(music, true)
        end

        if hasWon and not playedWinMusic then
            playedWinMusic = true
            obsi.audio.play(winMusic, false)
        end

        if hasStarted and not gameOver then
            if center.y > player.y - 10 then
                center.y = player.y - 10
            else
                center.y = center.y - 6*dt
            end
            if (player.y - center.y > obsi.graphics.getPixelHeight()+10) or (health == 0) then
                gameOver = true
                firstPlay = false
                splashText = math.random(1, 2)
                highScore = math.max(highScore, score)
            end
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
            if platform.type == 1 then
                obsi.graphics.draw(image_platform, platform.x, platform.y)
            elseif platform.type == 2 then
                obsi.graphics.draw(image_platform, platform.x, platform.y)
            end
        end
        for _, enemy in ipairs(enemies) do
            local t = obsi.timer.getTime()
            local spr = enemy1[math.floor(t % #enemy1)+1]
            if enemy.type == 2 then
                spr = enemy2[math.floor(t % #enemy2)+1]
            end
            obsi.graphics.draw(spr, enemy.x, enemy.y)
        end
        for _, carPart in ipairs(carParts) do
            obsi.graphics.draw(star[math.floor(obsi.timer.getTime()*1.5 % #star) + 1], carPart.x, carPart.y)
        end
        obsi.graphics.draw(image_soul, player.x, player.y)
        obsi.graphics.write(("Score: %s"):format(score), 1, 1)
        obsi.graphics.write(("High Score: %s"):format(highScore), 1, 2)
        obsi.graphics.write(("Car parts: %s/%s"):format(carPartsCount, maximumCarParts), 1, 3)
        obsi.graphics.write("Health: \3", 1, 4, "00000000"..(({"e", "4", "5"})[health] or "f"), "fffffffff")
        if not hasStarted and not hasWon then
            local txt = "Your goal is to get all car parts."
            obsi.graphics.write(txt, w/2-#txt/2, math.floor(h/2))
            if firstPlay then
                txt = "Good luck."
                obsi.graphics.write(txt, w/2-#txt/2, math.floor(h/2)+1)
            elseif splashText == 1 then
                txt = "You can do it!"
                obsi.graphics.write(txt, w/2-#txt/2, math.floor(h/2)+1)
            elseif splashText == 2 then
                txt = "Don't give up!"
                obsi.graphics.write(txt, w/2-#txt/2, math.floor(h/2)+1)
            end
        end
        if hasWon then
            local t = obsi.timer.getTime()
            if t-winTime > 5 then
                local txt = "You won!"
                obsi.graphics.write(txt, w/2-#txt/2, math.floor(h/2)-1)
            end
            if t-winTime > 5.5 then
                local txt = "Congratulations."
                obsi.graphics.write(txt, w/2-#txt/2, math.floor(h/2))
            end
            if t-winTime > 6 then
                local txt = "Press any key to continue."
                obsi.graphics.write(txt, w/2-#txt/2, math.floor(h/2)+1)
            end
        end
        if gameOver then
            local txt = "Game Over!"
            local txt1 = "Press any key to restart."
            obsi.graphics.write(txt, w/2-#txt/2, math.floor(h/2))
            obsi.graphics.write(txt1, w/2-#txt1/2, math.floor(h/2)+1)
        end
        -- obsi.graphics.write(("%s"):format(obsi.timer.getTime()-winTime), 1, 6)
        -- obsi.graphics.write(("%s"):format(platformRangeY), 1, 1)
    end

    function obsi.onKeyPress(k)
        if gameOver then
            game.reset()
        end
        if k == keys.b then
            carPartsCount = carPartsCount + 1
        end
        if hasWon and obsi.timer.getTime()-winTime > 6 then
            require("end")()
        end
    end
end

return game