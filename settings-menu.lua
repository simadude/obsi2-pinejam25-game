local obsi = require("obsi2")
local ass = require("assetManager")

local settingsOptions = {
    {name = "Music Volume", type = "number", step = 5, min = 0, value = 100, max = 150},
    {name = "SFX Volume", type = "number", step = 5, min = 0, value = 100, max = 150},
    {},
    {name = "EXIT", type = "function", value = function() end},
    selected = 1
}

settingsOptions[3] = {name = "APPLY", type = "function", value = function()
    obsi.audio.setVolume(1, settingsOptions[1].value/100)
    obsi.audio.setVolume(2, settingsOptions[2].value/100)
    settings.set("obsi-spamton-music", settingsOptions[1].value/100)
    settings.set("obsi-spamton-sfx", settingsOptions[2].value/100)
end}

return function ()
    -- ass.addSprite("camera", "sprites/camera.nfp")
    -- ass.addAnimation("camera", "camera", {{duration = 1, index = 1}})
    ass.addSprites("spamton-dance", "sprites/spamdance.nfp", 32, 38)
    ass.addSprite("logo", "sprites/logo.nfp")
    settingsOptions[1].value = settings.get("obsi-spamton-music", 1.0)*100
    settingsOptions[2].value = settings.get("obsi-spamton-sfx", 1.0)*100
    function obsi.draw()
        local w, h = obsi.graphics.getSize()
        local pw, ph = obsi.graphics.getPixelSize()
        local ty = h*0.5
        local tx = w*0.2

        local spm = ass.sprites["spamton-dance"]
        obsi.graphics.draw(spm[math.floor((obsi.timer.getTime()*9) % #spm) + 1], pw*0.7+1, ph/2-spm[1].height/2+1)
        obsi.graphics.draw(ass.sprites["logo"][1], 3, 3)

        for i, v in ipairs(settingsOptions) do
            if v.type == "number" then
                local txt = v.name..": "..tostring(v.value)
                obsi.graphics.write(txt, tx-5, ty+i*2-3, settingsOptions.selected == i and colors.yellow or colors.white)
            elseif v.type == "choice" then
                local txt = v.name..": "
                obsi.graphics.write(txt, tx-5, ty+i*2-3, settingsOptions.selected == i and colors.yellow or colors.white)
                local ox = #txt
                for j, choice in ipairs(v.choices) do
                    obsi.graphics.write(choice, tx-5+ox, ty+i*2-3, v.value == j and colors.yellow or colors.white)
                    ox = ox + #choice + 1
                end
            elseif v.type == "function" then
                obsi.graphics.write(v.name, tx-5, ty+i*2-3, settingsOptions.selected == i and colors.yellow or colors.white)
            end
        end
    end
end