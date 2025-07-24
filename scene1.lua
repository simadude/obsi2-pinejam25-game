local ass = require("assetManager")

ass.addSprite("basement-room", "sprites/basement.nfp")
ass.addAnimation("basement-room", "basement-room", {{duration=1, index = 1}})
ass.addSprite("spamton-vined", "sprites/spamton-vined.nfp")
ass.addAnimation("spamton-vined", "spamton-vined", {{duration=1, index = 1}})
ass.addMusic("dialtone", "mus/dialtone.nbs")
ass.addPalette("basement", "palettes/basement.pal")
ass.currentPalette = "basement"

---@type game.Cutscene.Action[]
local actions = {
    {type = "playMusic", musicName = "dialtone", loop = true},
    {type = "addObject", objectName = "basement-room", x = 10, y = -8, defaultAnimation = "basement-room"} --[[@as game.Cutscene.AddObject]],
    {type = "addObject", objectName = "spamton-vined", x = 10, y = -60, defaultAnimation = "spamton-vined"} --[[@as game.Cutscene.AddObject]],
    {type = "fadeIn", waitForCompletion = true},
    -- {type = "addObject", objectName = "ralsei", uniqueName = "ralsei"} --[[@as game.Cutscene.AddObject]],
    -- {type = "addObject", objectName = "kris", uniqueName = "kris"} --[[@as game.Cutscene.AddObject]],
    -- {type = "addObject", objectName = "susie", uniqueName = "susie"} --[[@as game.Cutscene.AddObject]],
    {type = "dialog",  speaker = "spamton", text = "It seems after all I couldn't be anything more than a simple puppet.\0", waitForCompletion = true} --[[@as game.Cutscene.Dialog]],
    {type = "dialog",  speaker = "spamton", text = "But you three... You're strong.\0", waitForCompletion = true} --[[@as game.Cutscene.Dialog]],
    {type = "dialog",  speaker = "spamton", text = "With a power like that...\0", waitForCompletion = true} --[[@as game.Cutscene.Dialog]],
    {type = "dialog",  speaker = "spamton", text = "Maybe you three can break your own strings.\0", waitForCompletion = true} --[[@as game.Cutscene.Dialog]],
    {type = "dialog",  speaker = "spamton", text = "Let me become your strength.\0", waitForCompletion = true} --[[@as game.Cutscene.Dialog]],
    {type = "startAnimation", actor = "spamton", animationName = "vined-disappear", waitForCompletion = true},
    {type = "dialog",  speaker = "spamton", text = "Where\0 the fuck\0 am I.\0", waitForCompletion = true}
}

return actions