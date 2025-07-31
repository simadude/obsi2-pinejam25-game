local obsi = require("obsi2")
local ass = require("assetManager")

ass.addMusic("end", "mus/end.nbs")
-- ass.addSprites("buildings", "sprites/buildings.nfp", 37, 40)
-- ass.addSprite("logo", "sprites/logo.nfp")

return function ()
    obsi.audio.play(ass.music["end"], false)

    local t = obsi.timer.getTime()

    function obsi.draw()
        local w, h = obsi.graphics.getSize()
        local text = "Thank you for playing!"
        obsi.graphics.write(text, w/2-#text/2+1, h/2)
        local n = ass.music["end"].notes
        obsi.graphics.write(("%.1f/%.1f"):format(n[#n].timing+1, obsi.timer.getTime()-t), w/2-#text/2+1, h/2+2)
        if obsi.timer.getTime()-t > n[#n].timing+1 then
            obsi.quit()
        end
    end
end