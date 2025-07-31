local obsi = require("obsi2")
local ass = require("assetManager")

ass.addMusic("menu", "mus/home.nbs")
ass.addSprites("spamton-dance", "sprites/spamdance.nfp", 32, 38)
ass.addSprite("logo", "sprites/logo.nfp")

return function ()
    obsi.audio.play(ass.music["menu"], true)

    local menuOptions = {
        "PLAY",
        "SETTINGS",
        "EXIT",
        selected = 1
    }

    function obsi.draw()
        local w, h = obsi.graphics.getSize()
        local pw, ph = obsi.graphics.getPixelSize()
        local ty = h*0.5
        local tx = w*0.2

        local spm = ass.sprites["spamton-dance"]
        obsi.graphics.draw(spm[math.floor((obsi.timer.getTime()*9) % #spm) + 1], pw*0.7+1, ph/2-spm[1].height/2+1)
        obsi.graphics.draw(ass.sprites["logo"][1], 3, 3)
        
        obsi.graphics.write("Submission for PineJam 2025, by Simadude", 1, h-1)

        for i, txt in ipairs(menuOptions) do
            txt = ((math.floor(obsi.timer.getTime()*1.33)%2 == 0 and menuOptions.selected == i) and "[ %s ]" or "[%s]"):format(txt)
            obsi.graphics.write(txt, tx-#txt/2, ty+i-#menuOptions/2, menuOptions.selected == i and colors.yellow or colors.white)
        end
    end
end