local obsi = require("obsi2")
local assetManager = require("assetManager")

---@class game.Cutscene.Dialog
---@field type "dialog"
---@field speaker string Doesn't have to be an object.
---@field text string
---@field waitForCompletion? boolean

---@class game.Cutscene.StartAnimation
---@field type "startAnimation"
---@field actor string
---@field animationName string
---@field waitForCompletion? boolean

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

---@type game.Cutscene.Action[]
local currentActions = {}

---@type game.Cutscene.Action[]
local actionQueue = {}

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
    while i <= #currentActions do
        local action = currentActions[i]
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
            local t = (obsi.timer.getTime()-obj.startTimeMove)/action.duration
            local x = lerp(obj.oldx, obj.oldx+action.dx, t)
            local y = lerp(obj.oldy, obj.oldy+action.dy, t)
            obj.x = x
            obj.y = y
            if t >= 1 then
                obj.oldx = obj.oldx+action.dx
                obj.oldy = obj.oldy+action.dy
                obj.x = obj.oldx+action.dx
                obj.y = obj.oldy+action.dy
                processed = true
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
        end
        if processed then
            if action.waitForCompletion then
                while #actionQueue > 0 do
                    currentActions[#currentActions+1] = table.remove(actionQueue, 1)
                end
            end
            table.remove(currentActions, i)
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
                if anim.frames[obj.currentFrame].duration > obsi.timer.getTime()-obj.lastTimeAnimation then
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
end

---@param actions game.Cutscene.Action[]
function cutsceneDriver.setQueue(actions)
    for i, action in ipairs(actions) do
        currentActions[#currentActions+1] = action
        if action.waitForCompletion then
            for j = i+1, #actions do
                actionQueue[#actionQueue+1] = actions[j]
            end
            break
        end
    end
end

return cutsceneDriver