local obsi = require("obsi2")
local game = {}

local soul = obsi.graphics.newImage("sprites/blue-soul.nfp")
local player = {x = 20, y = 30, speedY = -15, landed = false}
local center = {x = 0, y = 0}

function obsi.onKeyPress(k)
    
end

function obsi.update(dt)
    if obsi.keyboard.isDown("left") then
        player.x = player.x - 30*dt
    end
    if obsi.keyboard.isDown("right") then
        player.x = player.x + 30*dt
    end
    if player.landed then
        -- check if platforms still under player
    end
    if not player.landed then
        player.speedY = player.speedY + 20*dt
        player.y = player.y + player.speedY * 5*dt
    end
end

function obsi.draw()
    local w, h = obsi.graphics.getSize()
    local pw, ph = obsi.graphics.getPixelSize()
    if w/51 >= 2 and h/19 >= 2 and obsi.graphics.getRenderer() ~= "neat" then
        obsi.graphics.setRenderer("neat")
    elseif (w/51 <= 2 or h/19 < 2) and obsi.graphics.getRenderer() ~= "pixelbox" then
        obsi.graphics.setRenderer("pixelbox")
    end
    obsi.graphics.setOrigin((98+4-pw)/2, 0)
    obsi.graphics.line({3, 0}, {3, ph})
    obsi.graphics.line({98, 0}, {98, ph})
    obsi.graphics.setOrigin(center.x, center.y)
    obsi.graphics.draw(soul, player.x, player.y)
end

obsi.init()

-- return game