local ass = require("assetManager")
local wtfdrive = require("wtfdrive")
local dither = require("dither")

ass.addSprite("basement-room", "sprites/basement.nfp")
ass.addAnimation("basement-room", "basement-room", {{duration=1, index = 1}})
ass.addSprite("spamton-vined", "sprites/spamton-vined.nfp")

local frames = ass.sprites["spamton-vined"]

---@param img obsi.Image
---@return obsi.Image
local function copyImage(img)
    local cimg = {
        width = img.width,
        height = img.height,
        data = {}
    }
    for y = 1, #img.data do
        local row = img.data[y]
        cimg.data[y] = {}
        for x = 1, #row do
            cimg.data[y][x] = row[x]
        end
    end
    return cimg
end
for i = 1, 8 do
    local img = copyImage(frames[i])
    dither(img, i)
    frames[i+1] = img
end

ass.addAnimation("spamton-vined", "spamton-vined", {{duration=1, index = 1}})
ass.addAnimation("spamton-vined-disappear", "spamton-vined", {{duration=0.25, index = 1}, {duration=0.25, index = 2}, {duration=0.25, index = 3}, {duration=0.25, index = 4}, {duration=0.25, index = 5}, {duration=0.25, index = 6}, {duration=0.25, index = 7}, {duration=0.25, index = 8}, {duration=0.25, index = 9}})

ass.addSprites("kris", "sprites/kris.nfp", 11, 24)
ass.addAnimation("kris-still-up", "kris", {{duration = 1, index = 1}})
ass.addAnimation("kris-walk-up", "kris", {{duration = 0.25, index = 1}, {duration = 0.25, index = 2}, {duration = 0.25, index = 3}, {duration = 0.25, index = 4}}, true)
ass.addAnimation("kris-walk-down", "kris", {{duration = 0.25, index = 5}, {duration = 0.25, index = 6}, {duration = 0.25, index = 7}, {duration = 0.25, index = 8}}, true)
ass.addAnimation("kris-still-down", "kris", {{duration = 1, index = 5}})

ass.addSprites("susie", "sprites/susie.nfp", 16, 27)
ass.addAnimation("susie-still-up", "susie", {{duration = 1, index = 1}})
ass.addAnimation("susie-still-left", "susie", {{duration = 1, index = 6}})
ass.addAnimation("susie-walk-down", "susie", {{duration = 0.25, index = 2}, {duration = 0.25, index = 3}, {duration = 0.25, index = 4}, {duration = 0.25, index = 5}}, true)
ass.addAnimation("susie-walk-left", "susie", {{duration = 0.25, index = 6}, {duration = 0.25, index = 7}, {duration = 0.25, index = 8}, {duration = 0.25, index = 9}}, true)

ass.addSprites("ralsei", "sprites/ralsei.nfp", 15, 27)
ass.addAnimation("ralsei-still-up", "ralsei", {{duration = 1, index = 1}})
ass.addAnimation("ralsei-still-right", "ralsei", {{duration = 1, index = 6}})
ass.addAnimation("ralsei-walk-down", "ralsei", {{duration = 0.25, index = 2}, {duration = 0.25, index = 3}, {duration = 0.25, index = 4}, {duration = 0.25, index = 5}}, true)
ass.addAnimation("ralsei-walk-right", "ralsei", {{duration = 0.25, index = 6}, {duration = 0.25, index = 7}, {duration = 0.25, index = 8}, {duration = 0.25, index = 9}}, true)

ass.addSprites("star", "sprites/star.nfp", 8, 8)
ass.addAnimation("star", "star", {{duration = 0.5, index = 1}, {duration = 0.5, index = 2}}, true)

ass.addSprites("spamton", "sprites/spamton.nfp", 21, 27)
ass.addAnimation("spamton-left", "spamton", {{duration = 1, index = 1}})
ass.addAnimation("spamton-right", "spamton", {{duration = 1, index = 2}})
ass.addAnimation("spamton-right-arms-up", "spamton", {{duration = 1, index = 3}})
ass.addAnimation("spamton-right-arms-up-open", "spamton", {{duration = 1, index = 4}})
ass.addAnimation("spamton-block", "spamton", {{duration = 1, index = 5}})

ass.addMusic("dialtone", "mus/dialtone.nbs")
ass.addMusic("realboy", "mus/realboy.nbs")

ass.addPalette("basement", "palettes/basement.pal")
ass.currentPalette = "basement"

---@type game.Cutscene.Action[]
local actions = {
    {type = "move", actor = "camera", dx = 30, dy = 40, duration = 0.001, waitForCompletion = false},
    {type = "wait", duration = 1, waitForCompletion = true},
    {type = "playMusic", musicName = "dialtone", loop = true},
    {type = "addObject", objectName = "basement-room", x = 0, y = 0, defaultAnimation = "basement-room"} --[[@as game.Cutscene.AddObject]],
    {type = "addObject", objectName = "star", x = 27, y = 20, defaultAnimation = "star"} --[[@as game.Cutscene.AddObject]],
    {type = "addObject", objectName = "spamton-vined", x = 3, y = -52, defaultAnimation = "spamton-vined"} --[[@as game.Cutscene.AddObject]],
    {type = "addObject", objectName = "ralsei", x = 5, y = 37, defaultAnimation = "ralsei-still-up"} --[[@as game.Cutscene.AddObject]],
    {type = "addObject", objectName = "kris", x = 24, y = 37, defaultAnimation = "kris-still-up"} --[[@as game.Cutscene.AddObject]],
    {type = "addObject", objectName = "susie", x = 40, y = 37, defaultAnimation = "susie-still-up"} --[[@as game.Cutscene.AddObject]],
    {type = "fadeIn", waitForCompletion = true},
    -- {type = "dialog",  speaker = "spamton", text = "* Where\0 \0\14THE FUCK\0 \0\0am I.\0", waitForCompletion = true},
    {type = "dialog",  speaker = "spamton", text = "It seems after all I couldn't be\nanything more than a simple puppet.\0", waitForCompletion = true} --[[@as game.Cutscene.Dialog]],
    {type = "dialog",  speaker = "spamton", text = "But you three... You're strong.\0", waitForCompletion = true} --[[@as game.Cutscene.Dialog]],
    {type = "dialog",  speaker = "spamton", text = "With a power like that...\0", waitForCompletion = true} --[[@as game.Cutscene.Dialog]],
    {type = "dialog",  speaker = "spamton", text = "Maybe you three can break your own\nstrings.\0", waitForCompletion = true} --[[@as game.Cutscene.Dialog]],
    {type = "dialog",  speaker = "spamton", text = "Let me become your strength.\0", waitForCompletion = true} --[[@as game.Cutscene.Dialog]],
    {type = "startAnimation", actor = "spamton-vined", animationName = "spamton-vined-disappear", waitForCompletion = true},
    {type = "wait", duration = 1.5, waitForCompletion = true},
    {type = "move", actor = "star", dx = 0, dy = 15, duration = 1, waitForCompletion = false},
    {type = "wait", duration = 0.5, waitForCompletion = true},
    {type = "startAnimation", actor = "kris", animationName = "kris-walk-up", waitForCompletion = false},
    {type = "move", actor = "kris", dx = 0, dy = 8, duration = 0.5, waitForCompletion = false},
    {type = "wait", duration = 0.25, waitForCompletion = true},
    {type = "startAnimation", actor = "susie", animationName = "susie-still-left", waitForCompletion = false},
    {type = "wait", duration = 0.25, waitForCompletion = true},
    {type = "startAnimation", actor = "kris", animationName = "kris-still-up", waitForCompletion = false},
    {type = "wait", duration = 1, waitForCompletion = true},
    {type = "startAnimation", actor = "kris", animationName = "kris-still-down", waitForCompletion = false},
    {type = "wait", duration = 1, waitForCompletion = true},
    {type = "startAnimation", actor = "kris", animationName = "kris-walk-down", waitForCompletion = false},
    {type = "move", actor = "kris", dx = 0, dy = 4, duration = 1, waitForCompletion = true},
    {type = "removeObject", objectName = "kris"},
    {type = "wait", duration = 1, waitForCompletion = true},
    {type = "startAnimation", actor = "susie", animationName = "susie-still-up", waitForCompletion = false},
    {type = "wait", duration = 1, waitForCompletion = true},
    {type = "startAnimation", actor = "susie", animationName = "susie-still-left", waitForCompletion = false},
    {type = "wait", duration = 0.5, waitForCompletion = true},
    {type = "startAnimation", actor = "susie", animationName = "susie-walk-left", waitForCompletion = false},
    {type = "move", actor = "susie", dx = -16, dy = 0, duration = 0.5, waitForCompletion = false},
    {type = "wait", duration = 0.25, waitForCompletion = true},
    {type = "startAnimation", actor = "ralsei", animationName = "ralsei-still-right", waitForCompletion = false},
    {type = "wait", duration = 0.25, waitForCompletion = true},
    {type = "startAnimation", actor = "susie", animationName = "susie-walk-down", waitForCompletion = false},
    {type = "move", actor = "susie", dx = 0, dy = 8, duration = 0.5, waitForCompletion = false},
    {type = "wait", duration = 0.25, waitForCompletion = true},
    {type = "startAnimation", actor = "ralsei", animationName = "ralsei-walk-right", waitForCompletion = false},
    {type = "move", actor = "ralsei", dx = 16, dy = 0, duration = 0.6, waitForCompletion = false},
    {type = "wait", duration = 0.25, waitForCompletion = true},
    {type = "removeObject", objectName = "susie"},
    {type = "wait", duration = 0.35, waitForCompletion = true},
    {type = "startAnimation", actor = "ralsei", animationName = "ralsei-walk-down", waitForCompletion = false},
    {type = "move", actor = "ralsei", dx = 0, dy = 10, duration = 0.6, waitForCompletion = true},
    {type = "removeObject", objectName = "ralsei"},
    {type = "dialog", speaker = "spamton", text = "...\0", waitForCompletion = true} --[[@as game.Cutscene.Dialog]],
    {type = "dialog", speaker = "spamton", text = "They left me.\0", waitForCompletion = true} --[[@as game.Cutscene.Dialog]],
    {type = "dialog", speaker = "spamton", text = "They didn't even want me.\0", waitForCompletion = true} --[[@as game.Cutscene.Dialog]],
    {type = "dialog", speaker = "spamton", text = "But maybe...\0", waitForCompletion = true} --[[@as game.Cutscene.Dialog]],
    {type = "stopMusic"},
    {type = "wait", duration = 2, waitForCompletion = true},
    {type = "playMusic", musicName = "realboy", loop = true},
    {type = "removeObject", objectName = "star"},
    {type = "addObject", objectName = "spamton", x = 20, y = 21, defaultAnimation = "spamton-left"},
    {type = "dialog", speaker = "spamton", text = "MAYBE I DON'T NEED THEM!\n\0MAYBE I DON'T NEED [[FREEDOM]]!\0", waitForCompletion = true} --[[@as game.Cutscene.Dialog]],
    {type = "move", actor = "spamton", dx = -4, dy = 0, duration = 0.5, waitForCompletion = false},
    {type = "dialog", speaker = "spamton", text = "OR MAYBE...\0 MY APPROACH WAS TOO NARROW.\0", waitForCompletion = true} --[[@as game.Cutscene.Dialog]],
    {type = "move", actor = "spamton", dx = 6, dy = 0, duration = 0.5, waitForCompletion = false},
    {type = "startAnimation", actor = "spamton", animationName = "spamton-right-arms-up", waitForCompletion = false},
    {type = "dialog", speaker = "spamton", text = "I DON'T NEED TO BE [[BIGGER]].\n\0I NEED TO BE\n[[Faster Than The Speed Of Sound]]!\0", waitForCompletion = true} --[[@as game.Cutscene.Dialog]],
    {type = "wait", duration = 1, waitForCompletion = true},
    {type = "startAnimation", actor = "spamton", animationName = "spamton-block", waitForCompletion = false},
    {type = "dialog", speaker = "spamton", text = "BUT I'LL NEED SOME [[Customer Support]]\nFirst.\0", waitForCompletion = true} --[[@as game.Cutscene.Dialog]],
    {type = "startAnimation", actor = "spamton", animationName = "spamton-right", waitForCompletion = false},
    {type = "wait", duration = 0.5, waitForCompletion = true},
    {type = "move", actor = "spamton", dx = 100, dy = 0, duration = 1.5, waitForCompletion = true},
    {type = "wait", duration = 0.75, waitForCompletion = true},
    {type = "fadeOut", waitForCompletion = true},
    {type = "move", actor = "camera", dx = -30, dy = -40, duration = 0.001, waitForCompletion = false},
    {type = "wait", duration = 0.5, waitForCompletion = true},
    {type = "stopMusic"},
    {type = "removeObject", objectName = "basement-room"},
    {type = "removeObject", objectName = "spamton"},
    {type = "function", func = function() wtfdrive.setQueue(require("scene2")) end}
}

return actions