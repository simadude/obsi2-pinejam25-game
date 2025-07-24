local obsi = require("obsi2")
local assetManager = require("assetManager")

---@class game.Cutscene.Dialog
---@field type "dialog"
---@field speaker string Doesn't have to be an object.
---@field text string
---@field waitForCompletion? boolean
---@field currentPos? number
---@field hasStopped? boolean
---@field lastTimeCharacter? number

---@class game.Cutscene.StartAnimation
---@field type "startAnimation"
---@field actor string
---@field animationName string

---@class game.Cutscene.Move
---@field type "move"
---@field actor string
---@field dx number
---@field dy number
---@field duration number
---@field waitForCompletion? boolean

---@class game.Cutscene.PlayMusic
---@field type "playMusic"
---@field musicName string
---@field loop boolean

---@class game.Cutscene.AddObject
---@field type "addObject"
---@field objectName string
---@field x number
---@field y number
---@field defaultAnimation string

---@class game.Cutscene.RemoveObject
---@field type "removeObject"
---@field objectName string

---@class game.Cutscene.FadeOut
---@field type "fadeOut"
---@field startTime? number
---@field waitForCompletion boolean

---@class game.Cutscene.FadeIn
---@field type "fadeIn"
---@field startTime? number
---@field waitForCompletion boolean

---@class game.Cutscene.Function
---@field type "function"
---@field func function

---@class game.Cutscene.Wait
---@field type "wait"
---@field duration number
---@field startTime? number
---@field waitForCompletion boolean

---@alias game.Cutscene.Action
---| game.Cutscene.AddObject
---| game.Cutscene.PlayMusic
---| game.Cutscene.RemoveObject
---| game.Cutscene.StartAnimation
---| game.Cutscene.Move
---| game.Cutscene.Dialog
---| game.Cutscene.FadeOut
---| game.Cutscene.FadeIn
---| game.Cutscene.Function
---| game.Cutscene.Wait

---@class game.Cutscene.Object
---@field name string
---@field x number
---@field y number
---@field oldx number
---@field oldy number
---@field currentAnimation string
---@field currentFrame number
---@field lastTimeAnimation number
---@field startTimeMove number
---@field order number

local function lerp(a, b, t)
    return a + (b - a)*t
end

local cutsceneDriver = {}
---@type game.Cutscene.Object[]
local objects = {
    {
        name = "camera",
        currentAnimation = "camera",
        currentFrame = 1,
        oldx = 0,
        oldy = 0,
        x = 0,
        y = 0,
        lastTimeAnimation = 0,
        startTimeMove = 0,
        order = 999999,
    }
}

-- set this shit to true yourself when pressing key
cutsceneDriver.continueDialog = false

---@type game.Cutscene.Action[]
cutsceneDriver.currentActions = {}

---@type game.Cutscene.Action[]
cutsceneDriver.actionQueue = {}

---@param objectName string
---@param x number
---@param y number
---@param defaultAnimation string
function cutsceneDriver.createObject(objectName, x, y, defaultAnimation)
    objects[#objects+1] = {
        name = objectName,
        x = x,
        y = y,
        oldx = x,
        oldy = y,
        currentAnimation = defaultAnimation,
        currentFrame = 1,
        lastTimeAnimation = obsi.timer.getTime(),
        startTimeMove = 0,
        order = #objects + 1
    }
end

function cutsceneDriver.processActions(dt)
    local i = 1
    while i <= #cutsceneDriver.currentActions do
        local action = cutsceneDriver.currentActions[i]
        local processed = false
        if action.type == "addObject" then
            cutsceneDriver.createObject(action.objectName, action.x, action.y, action.defaultAnimation)
            processed = true
        elseif action.type == "playMusic" then
            obsi.audio.play(assetManager.music[action.musicName], action.loop)
            processed = true
        elseif action.type == "move" then
            ---@type game.Cutscene.Object
            local obj
            for _, o in ipairs(objects) do
                if o.name == action.actor then
                    obj = o
                    break
                end
            end
            if not obj then
                processed = true
            elseif obj.startTimeMove == 0 then
                obj.startTimeMove = obsi.timer.getTime()
            end
            if obj then
                local t = (obsi.timer.getTime()-obj.startTimeMove)/action.duration
                local x = lerp(obj.oldx, obj.oldx+action.dx, t)
                local y = lerp(obj.oldy, obj.oldy+action.dy, t)
                obj.x = x
                obj.y = y
                if t >= 1 then
                    obj.oldx = obj.oldx+action.dx
                    obj.oldy = obj.oldy+action.dy
                    obj.x = obj.oldx
                    obj.y = obj.oldy
                    processed = true
                end
            end
        elseif action.type == "fadeOut" then
            local pal = assetManager.palettes[assetManager.currentPalette].data
            if not action.startTime then
                action.startTime = obsi.timer.getTime()
            end
            local t = math.max(0, 1-(obsi.timer.getTime()-action.startTime))
            for i = 1, 16 do
                obsi.graphics.setPaletteColor(2^(i-1), pal[i][1]*t, pal[i][2]*t, pal[i][3]*t)
            end
            if t <= 0 then
                processed = true
            end
        elseif action.type == "fadeIn" then
            local pal = assetManager.palettes[assetManager.currentPalette].data
            if not action.startTime then
                action.startTime = obsi.timer.getTime()
            end
            local t = math.min(1, (obsi.timer.getTime()-action.startTime))
            for i = 1, 16 do
                obsi.graphics.setPaletteColor(2^(i-1), pal[i][1]*t, pal[i][2]*t, pal[i][3]*t)
            end
            if t >= 1 then
                processed = true
            end
        elseif action.type == "function" then
            action.func()
            processed = true
        elseif action.type == "wait" then
            if not action.startTime then
                action.startTime = obsi.timer.getTime()
            end
            local t = (obsi.timer.getTime()-action.startTime)
            if t >= action.duration then
                processed = true
            end
        elseif action.type == "dialog" then
            if not action.currentPos then
                action.currentPos = 0
                action.lastTimeCharacter = 0
            end
            if action.hasStopped and cutsceneDriver.continueDialog then
                action.hasStopped = false
            end
            cutsceneDriver.continueDialog = false
            if (obsi.timer.getTime()-action.lastTimeCharacter) >= 0.05 and not action.hasStopped then
                action.lastTimeCharacter = obsi.timer.getTime()
                action.currentPos = action.currentPos + 1
                local curChar = action.text:sub(action.currentPos, action.currentPos)
                local nextChar = action.text:sub(action.currentPos+1, action.currentPos+1)
                if curChar == "\0" and action.currentPos < #action.text and nextChar < "\17" then
                    action.currentPos = action.currentPos + 1
                elseif curChar == "\0" then
                    action.hasStopped = true
                end
                if action.currentPos > #action.text then
                    processed = true
                end
            end
        elseif action.type == "startAnimation" then
            ---@type game.Cutscene.Object
            local obj
            for _, o in ipairs(objects) do
                if o.name == action.actor then
                    obj = o
                    break
                end
            end
            if not obj then
                processed = true
            end
            obj.currentAnimation = action.animationName
            obj.currentFrame = 1
            obj.lastTimeAnimation = obsi.timer.getTime()
            processed = true
        end
        if processed then
            if action.waitForCompletion then
                -- idk why this works, ask deepseek
                local added = 0
                while #cutsceneDriver.actionQueue > 0 do
                    local nextAction = table.remove(cutsceneDriver.actionQueue, 1)
                    cutsceneDriver.currentActions[#cutsceneDriver.currentActions+1] = nextAction
                    added = added + 1
                    if nextAction.waitForCompletion then
                        break
                    end
                end
            end
            if cutsceneDriver.currentActions[i] == action then -- THIS IS VERY WEIRD BEHAVIOUR WHEN THIS ISN'T TRUE.
                table.remove(cutsceneDriver.currentActions, i) -- SOMETHING HAS TO DO WITH RESETTING QUEUE WITHIN AN ACTION.
            end
        else
            i = i + 1
        end
    end
end

function cutsceneDriver.processAnimations()
    for _, obj in ipairs(objects) do
        if obj.currentAnimation ~= "" then
            local anim = assetManager.animations[obj.currentAnimation]
            if #anim.frames > 1 then
                if obsi.timer.getTime()-obj.lastTimeAnimation > anim.frames[obj.currentFrame].duration then
                    obj.lastTimeAnimation = obsi.timer.getTime()
                    if anim.loop and obj.currentFrame == #anim.frames then
                        obj.currentFrame = 1
                    elseif obj.currentFrame < #anim.frames then
                        obj.currentFrame = obj.currentFrame + 1
                    end
                end
            end
        end
    end
end

function cutsceneDriver.draw()
    table.sort(objects, function(a, b) return a.order < b.order end)
    local camera = objects[#objects]
    obsi.graphics.setOrigin(camera.x-obsi.graphics.getPixelWidth()/2, camera.y-obsi.graphics.getPixelHeight()/2)
    for _, obj in ipairs(objects) do
        if obj.currentAnimation ~= "" then
            local img = assetManager.getAnimationImage(obj.currentAnimation, obj.currentFrame)
            obsi.graphics.draw(img, obj.x, obj.y)
        end
    end
    for _, action in ipairs(cutsceneDriver.currentActions) do
        if action.type == "dialog" then
            local h = obsi.graphics.getHeight()-4
            do
                obsi.graphics.write(("\131"):rep(41), 5, h)
            end
            local str = ""
            local fgstr = ""
            local bgstr = ""
            local curFGColor = "0"
            local curBGColor = "F"
            local i = 1
            local iy = 1
            while i <= action.currentPos and i <= #action.text do
                local char = action.text:sub(i, i)
                if char == "\0" and i < #action.text and action.text:sub(i+1, i+1) < "\17" then
                    i = i + 1
                    curFGColor = colors.toBlit(2^(action.text:byte(i, i)))
                elseif char > "\17" and char ~= "\n" then
                    str = str..char
                    fgstr = fgstr .. curFGColor
                    bgstr = bgstr .. curBGColor
                end
                i = i + 1
                if char == "\n" then
                    obsi.graphics.write(str, 5, h+iy, fgstr, bgstr)
                    str = ""
                    fgstr = ""
                    bgstr = ""
                    iy = iy + 1
                end
                if i >= action.currentPos or i >= #action.text then
                    obsi.graphics.write(str, 5, h+iy, fgstr, bgstr)
                end
            end
        end
    end
end

---@param actions game.Cutscene.Action[]
function cutsceneDriver.setQueue(actions)
    cutsceneDriver.currentActions = {}
    cutsceneDriver.actionQueue = actions
    while #cutsceneDriver.actionQueue ~= 0 do
        local action = table.remove(cutsceneDriver.actionQueue, 1) --[[@as game.Cutscene.Action]]
        cutsceneDriver.currentActions[#cutsceneDriver.currentActions+1] = action
        if action.waitForCompletion then
            break
        end
    end
end

return cutsceneDriver