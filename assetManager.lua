local obsi = require("obsi2")

local assets = {
    ---@type obsi.Image[][]
    sprites = {},
    ---@type game.Assets.Animation[]
    animations = {},
    ---@type obsi.Audio[]
    music = {},
    ---@type obsi.Palette[]
    palettes = {
        ["default"] = obsi.graphics.getPallete()
    },
    currentPalette = "default"
}

---@param familyName string
---@param path string
---@param tilewidth number
---@param tileheight number
function assets.addSprites(familyName, path, tilewidth, tileheight)
    assets.sprites[familyName] = obsi.graphics.newImagesFromTilesheet(path, tilewidth, tileheight)
end

---@param familyName string
---@param path string
function assets.addSprite(familyName, path)
    assets.sprites[familyName] = {obsi.graphics.newImage(path)}
end

---@param musicName string
---@param path string
function assets.addMusic(musicName, path)
    assets.music[musicName] = obsi.audio.newSound(path)
end

---@class game.Assets.Animation
---@field spriteFamily string
---@field frames game.Assets.Animation.Frame[]
---@field loop boolean

---@class game.Assets.Animation.Frame
---@field index number
---@field duration number

---@param animationName string
---@param spriteFamily string
---@param frames game.Assets.Animation.Frame[]
---@param loop? boolean
function assets.addAnimation(animationName, spriteFamily, frames, loop)
    assets.animations[animationName] = {
        spriteFamily = spriteFamily,
        frames = frames,
        loop = loop or false
    }
end

---@param animationName string
---@param frame number
---@return obsi.Image
function assets.getAnimationImage(animationName, frame)
    local anim = assets.animations[animationName]
    local sprites = assets.sprites[anim.spriteFamily]
    return sprites[anim.frames[frame].index]
end

---@param paletteName string
---@param path string
function assets.addPalette(paletteName, path)
    assets.palettes[paletteName] = obsi.graphics.newPalette(path)
end

return assets