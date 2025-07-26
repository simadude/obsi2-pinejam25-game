---@param img obsi.Image
---@param level integer
local function dither(img, level)
    if level <= 0 or level > 8 then
        return img
    end
    if level == 1 then
        for y = 1, img.height, 4 do
            for x = 1, img.width, 4 do
                img.data[y][x] = -1
            end
        end
    end
    if level == 2 then
        for y = 3, img.height, 4 do
            for x = 3, img.width, 4 do
                img.data[y][x] = -1
            end
        end
    end
    if level == 3 then
        for y = 1, img.height, 4 do
            for x = 3, img.width, 4 do
                img.data[y][x] = -1
            end
        end
        for y = 3, img.height, 4 do
            for x = 1, img.width, 4 do
                img.data[y][x] = -1
            end
        end
    end
    if level == 4 then
        for y = 2, img.height, 2 do
            for x = 2, img.width, 2 do
                img.data[y][x] = -1
            end
        end
    end
    if level == 5 then
        for y = 2, img.height, 2 do
            for x = 1, img.width, 2 do
                img.data[y][x] = -1
            end
        end
    end
    if level == 6 then
        for y = 1, img.height, 4 do
            for x = 2, img.width, 4 do
                img.data[y][x] = -1
            end
        end
        for y = 3, img.height, 4 do
            for x = 4, img.width, 4 do
                img.data[y][x] = -1
            end
        end
    end
    if level == 7 then
        for y = 3, img.height, 4 do
            for x = 2, img.width, 4 do
                img.data[y][x] = -1
            end
        end
    end
    if level == 8 then
        -- not bothered to set every other pixel here, let's just do all nothing
        for y = 1, img.height do
            for x = 1, img.width do
                img.data[y][x] = -1
            end
        end
    end
end

return dither