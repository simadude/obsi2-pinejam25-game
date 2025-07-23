local obsi = require("obsi2")

local music = {
    ["menu"] = obsi.audio.newSound("mus/home.nbs")
}
local sprites = {
    ["spamton-dance"] = obsi.graphics.newImagesFromTilesheet("sprites/spamdance.nfp", 32, 38),
    ["logo"] = obsi.graphics.newImage("sprites/logo.nfp")
}

---@type "menu"|"settings"|"game"|"cutscene"|"shop"|"battle"
local gameState = "menu"

local menuOptions = {
    "PLAY",
    "SETTINGS",
    "EXIT",
    selected = 1
}

local settingsOptions = {
    {name = "Music Volume", type = "number", step = 5, min = 0, value = 100, max = 150},
    {name = "SFX Volume", type = "number", step = 5, min = 0, value = 100, max = 150},
    {name = "vro I forgor", type = "choice", value = 1, choices = {"what", "who"}},
    {},
    {name = "EXIT", type = "function", value = function() gameState = "menu" end},
    selected = 1
}
settingsOptions[4] = {name = "APPLY", type = "function", value = function()
    obsi.audio.setVolume(1, settingsOptions[1].value/100)
    obsi.audio.setVolume(2, settingsOptions[2].value/100)
    settings.set("obsi-spamton-music", settingsOptions[1].value/100)
    settings.set("obsi-spamton-sfx", settingsOptions[2].value/100)
end}

function obsi.load()
    obsi.audio.play(music["menu"], true)
    settingsOptions[1].value = settings.get("obsi-spamton-music", 1.0)*100
    settingsOptions[2].value = settings.get("obsi-spamton-sfx", 1.0)*100
    obsi.audio.setVolume(1, settings.get("obsi-spamton-music", 1.0))
    obsi.audio.setVolume(2, settings.get("obsi-spamton-sfx", 1.0))
end

function obsi.draw()
    local w, h = obsi.graphics.getSize()
    local pw, ph = obsi.graphics.getPixelSize()
    if w/51 >= 2 and h/19 >= 2 and obsi.graphics.getRenderer() ~= "neat" then
        obsi.graphics.setRenderer("neat")
    elseif (w/51 <= 2 or h/19 < 2) and obsi.graphics.getRenderer() ~= "pixelbox" then
        obsi.graphics.setRenderer("pixelbox")
    end
    if gameState == "menu" or gameState == "settings" then
        local spm = sprites["spamton-dance"]
        obsi.graphics.draw(spm[math.floor((obsi.timer.getTime()*9) % #spm) + 1], pw*0.7+1, ph/2-spm[1].height/2+1)
        obsi.graphics.draw(sprites["logo"], 3, 3)
    end
    
    local ty = h*0.5
    local tx = w*0.2
    if gameState == "menu" then
        for i, txt in ipairs(menuOptions) do
            txt = ((math.floor(obsi.timer.getTime()*1.33)%2 == 0 and menuOptions.selected == i) and "[ %s ]" or "[%s]"):format(txt)
            obsi.graphics.write(txt, tx-#txt/2, ty+i-#menuOptions/2, menuOptions.selected == i and colors.yellow or colors.white)
        end
    elseif gameState == "settings" then
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
    obsi.graphics.write("Submission for PineJam 2025, by Simadude", 1, h-1)
end

function obsi.update(dt)
    
end

function obsi.onKeyPress(k)
    if gameState == "menu" then
        if k == keys.enter then
            if menuOptions.selected == 1 then
                obsi.quit()
            elseif menuOptions.selected == 2 then
                gameState = "settings"
                -- obsi.quit()
            elseif menuOptions.selected == 3 then
                obsi.quit() -- DO NOT REMOVE
            end
        elseif k == keys.up then
            menuOptions.selected = (menuOptions.selected - 2)%#menuOptions+1
        elseif k == keys.down then
            menuOptions.selected = (menuOptions.selected)%#menuOptions+1
        end
    elseif gameState == "settings" then
        if k == keys.up then
            settingsOptions.selected = math.max(settingsOptions.selected-1, 1)
        elseif k == keys.down then
            settingsOptions.selected = math.min(settingsOptions.selected+1, #settingsOptions)
        elseif k == keys.right then
            local setting = settingsOptions[settingsOptions.selected]
            if setting.type == "number" then
                setting.value = math.min(setting.max, setting.value + setting.step)
            elseif setting.type == "choice" then
                setting.value = math.min(#setting.choices, setting.value + 1)
            end
        elseif k == keys.left then
            local setting = settingsOptions[settingsOptions.selected]
            if setting.type == "number" then
                setting.value = math.max(setting.min, setting.value - setting.step)
            elseif setting.type == "choice" then
                setting.value = math.max(1, setting.value - 1)
            end
        elseif k == keys.enter then
            local setting = settingsOptions[settingsOptions.selected]
            if setting.type == "function" then
                setting.value()
            end
        end
    end
end

obsi.init()