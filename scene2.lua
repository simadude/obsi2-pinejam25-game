local ass = require("assetManager")
local wtfdrive = require("wtfdrive")

ass.addSprite("seam-room", "sprites/seam-room.nfp")
ass.addAnimation("seam-room", "seam-room", {{duration = 1, index = 1}})

ass.addSprite("soul", "sprites/blue-soul.nfp")
ass.addAnimation("soul", "soul", {{duration = 1, index = 1}})

ass.addSprites("seam", "sprites/seam.nfp", 37, 33)
ass.addAnimation("seam", "seam", {{duration = 0.5, index = 1}, {duration = 0.25, index = 2}, {duration = 0.25, index = 3}, {duration = 0.25, index = 4}}, true)
ass.addAnimation("seam-serious", "seam", {{duration = 0.5, index = 5}, {duration = 0.25, index = 6}, {duration = 0.25, index = 7}, {duration = 0.25, index = 8}}, true)
ass.addAnimation("seam-serious-right", "seam", {{duration = 0.5, index = 9}, {duration = 0.25, index = 10}, {duration = 0.25, index = 11}, {duration = 0.25, index = 12}}, true)
ass.addAnimation("seam-putting-soul", "seam", {{duration = 0.5, index = 13}, {duration = 0.25, index = 14}, {duration = 0.25, index = 15}, {duration = 0.25, index = 16}, {duration = 0.25, index = 17}}, false)

ass.addSprites("spamton-1", "sprites/spamton-1.nfp", 21, 27)
ass.addAnimation("spamton-left", "spamton-1", {{duration = 1, index = 1}})
ass.addAnimation("spamton-right", "spamton-1", {{duration = 1, index = 2}})
ass.addAnimation("spamton-right-arms-up", "spamton-1", {{duration = 1, index = 3}})
ass.addAnimation("spamton-right-arms-up-open", "spamton-1", {{duration = 1, index = 4}})
ass.addAnimation("spamton-block", "spamton-1", {{duration = 1, index = 5}})
ass.addAnimation("spamton-soul", "spamton-1", {{duration = 1, index = 12}})

ass.addSprites("soul", "sprites/blue-soul.nfp", 5, 4)
ass.addAnimation("soul", "soul", {{duration = 1, index = 1}}, true)

ass.addMusic("lantern", "mus/lanterning.nbs")

ass.addPalette("seam", "palettes/seam.pal")
ass.currentPalette = "seam"

---@type game.Cutscene.Action[]
local actions = {
    {type = "move", actor = "camera", dx = 52, dy = 32, duration = 0.001, waitForCompletion = false},
    {type = "wait", duration = 1, waitForCompletion = true},
    {type = "playMusic", musicName = "lantern", loop = true},
    {type = "addObject", objectName = "seam-room", x = -6, y = -9, defaultAnimation = "seam-room"} --[[@as game.Cutscene.AddObject]],
    {type = "addObject", objectName = "seam", x = 59, y = 12, defaultAnimation = "seam"} --[[@as game.Cutscene.AddObject]],
    {type = "addObject", objectName = "spamton", x = -20, y = 31, defaultAnimation = "spamton-right"},
    {type = "setBackgroundColor", color = colors.gray},
    {type = "fadeIn", waitForCompletion = true},
    {type = "move", actor = "spamton", dx = 30, dy = 0, duration = 2} --[[@as game.Cutscene.Move]],
    {type = "dialog",  speaker = "spamton", text = "SEAM!\0", waitForCompletion = true} --[[@as game.Cutscene.Dialog]],
    {type = "startAnimation", actor = "seam", animationName = "seam-serious", waitForCompletion = true},
    {type = "dialog",  speaker = "spamton", text = "OLD FRIEND,\0 OLD PAL,\n\0OLD [[End User License agreement]]!\0", waitForCompletion = true} --[[@as game.Cutscene.Dialog]],
    {type = "dialog",  speaker = "spamton", text = "I'VE COME TO MAKE A [[Deal of a\nLifetime]]!\0", waitForCompletion = true} --[[@as game.Cutscene.Dialog]],
    {type = "dialog",  speaker = "seam", text = "...Spamton. I thought you'd be...\n\0well, recycled by now.\0", waitForCompletion = true} --[[@as game.Cutscene.Dialog]],
    {type = "dialog",  speaker = "seam", text = "What is it you're seeling this time?\0", waitForCompletion = true} --[[@as game.Cutscene.Dialog]],
    {type = "startAnimation", actor = "seam", animationName = "seam", waitForCompletion = true},
    {type = "dialog",  speaker = "seam", text = "Broken dreams?\0 Empty promises?\0", waitForCompletion = true} --[[@as game.Cutscene.Dialog]],
    {type = "dialog",  speaker = "spamton", text = "BETTER!\0 I'M IN THE MARKET FOR\n[[LUXURY]]! FOR [[Horsepower]]!\0", waitForCompletion = true} --[[@as game.Cutscene.Dialog]],
    {type = "dialog",  speaker = "spamton", text = "I NEED A VEHICLE, SEAM!\0 A REAL\n[[BIG SHOT]] ATOMOBILE!\0 ONE THAT\nCAN OUTRUN THE [[Hands of Fate]] THEMSELVES!\0", waitForCompletion = true} --[[@as game.Cutscene.Dialog]],
    {type = "dialog",  speaker = "seam", text = "A vehicle? Heh. And what would you pay\nfor it with? You don't seem to\nhave a... leg... to stand on.\0", waitForCompletion = true} --[[@as game.Cutscene.Dialog]],
    {type = "startAnimation", actor = "spamton", animationName = "spamton-block", waitForCompletion = true},
    {type = "wait", duration = 2, waitForCompletion = true},
    {type = "startAnimation", actor = "spamton", animationName = "spamton-right", waitForCompletion = true},
    {type = "dialog", speaker = "spamton", text = "I'LL GET THE [[Kromer]]!\0 I ALWAYS GET THE\n[[Kromer]]!\0 I JUST NEED THE PARTS!\0", waitForCompletion = true},
    {type = "dialog", speaker = "spamton", text = "THE [[Scrap Metal]]!\0 THE GUTS OF THE\nMACHINE!\0 YOU'VE BEEN AROUND, OLD CAT.\0", waitForCompletion = true},
    {type = "dialog", speaker = "spamton", text = "YOU KNOW WHERE THE WORLD HIDES\nITS TRASH.\0", waitForCompletion = true},
    {type = "startAnimation", actor = "seam", animationName = "seam-serious-right", waitForCompletion = true},
    {type = "wait", duration = 1.5, waitForCompletion = true},
    {type = "dialog", speaker = "seam", text = "Well, there is a place...\0", waitForCompletion = true},
    {type = "dialog", speaker = "seam", text = "The Great Garbage Grave, south of the\ncity. A mountain of forgotten things.\0", waitForCompletion = true},
    {type = "dialog", speaker = "seam", text = "The higher you climb, the better the...\nquality... of the refuse.\0", waitForCompletion = true},
    {type = "dialog", speaker = "seam", text = "Be warned. Many things have been\nthrown away there.\0", waitForCompletion = true},
    {type = "dialog", speaker = "seam", text = "Not all of them are happy about it.\0", waitForCompletion = true},
    {type = "startAnimation", actor = "spamton", animationName = "spamton-right-arms-up", waitForCompletion = true},
    {type = "dialog", speaker = "spamton", text = "PERFECT!\0 IT'S A [[Fixer Upper]]\nOPPORTUNITY!\0", waitForCompletion = true},
    {type = "startAnimation", actor = "seam", animationName = "seam-putting-soul", waitForCompletion = true},
    {type = "wait", duration = 2, waitForCompletion = true},
    {type = "startAnimation", actor = "seam", animationName = "seam", waitForCompletion = true},
    {type = "addObject", objectName = "soul", x = 74, y = 39, defaultAnimation = "soul"},
    {type = "dialog", speaker = "seam", text = "You'll need a way to get around in that\nmess. Here.\0", waitForCompletion = true},
    {type = "dialog", speaker = "seam", text = "Found this thing rolling around in the\nback. It's not for sale.\0", waitForCompletion = true},
    {type = "dialog", speaker = "seam", text = "Too... persistent. It has a habit of\nwanting to go up.\0", waitForCompletion = true},
    {type = "dialog", speaker = "seam", text = "Perhaps you two can be miserable\ntogether.\0", waitForCompletion = true},
    {type = "startAnimation", actor = "spamton", animationName = "spamton-right-arms-up-open", waitForCompletion = true},
    {type = "dialog", speaker = "spamton", text = "A [[Free Gift With Purchase]]!?\0", waitForCompletion = true},
    {type = "dialog", speaker = "spamton", text = "SEAM, YOU DRIVE A HARD BARGAIN!\0", waitForCompletion = true},
    {type = "move", actor = "spamton", dx = 8, dy = 0, duration = 0.3} --[[@as game.Cutscene.Move]],
    {type = "dialog", speaker = "spamton", text = "WITH THIS [[Heart-Shaped Object]],\nI'LL REACH THE TOP!\0", waitForCompletion = true},
    {type = "move", actor = "spamton", dx = 8, dy = 0, duration = 0.3} --[[@as game.Cutscene.Move]],
    {type = "dialog", speaker = "spamton", text = "I'LL BUILD MY RIDE!\0", waitForCompletion = true},
    {type = "move", actor = "spamton", dx = 8, dy = 0, duration = 0.3} --[[@as game.Cutscene.Move]],
    {type = "dialog", speaker = "spamton", text = "I'LL BECOME SO [[Fast & Furious]]\nEVEN MY OWN [[Strings]] WON'T CATCH\nME!\0", waitForCompletion = true},
    {type = "move", actor = "spamton", dx = 16, dy = 0, duration = 0.3, waitForCompletion = true} --[[@as game.Cutscene.Move]],
    {type = "removeObject", objectName = "soul"},
    {type = "startAnimation", actor = "spamton", animationName = "spamton-soul"},
    {type = "dialog", speaker = "spamton", text = "SEE YA, PAL!\0", waitForCompletion = true},
    {type = "move", actor = "spamton", dx = -128, dy = 0, duration = 1, waitForCompletion = true} --[[@as game.Cutscene.Move]],
    {type = "fadeOut", waitForCompletion = true},
    {type = "stopMusic"},
    {type = "function", func = function() wtfdrive.setQueue(require("scene3")) end}
}

return actions