-- GitHub Repository Downloader with Paste Support
-- Features: Better GUI, paste support, progress tracking

-- GUI Configuration
local bgColor = colors.black
local textColor = colors.white
local inputColor = colors.gray
local highlightColor = colors.lightGray
local progressBg = colors.gray
local progressFg = colors.white
local errorColor = colors.red
local successColor = colors.green

-- Initialize display
local function initScreen()
    term.clear()
    term.setBackgroundColor(bgColor)
    term.setTextColor(textColor)
    term.setCursorPos(1,1)
end

-- Draw centered text with optional background
local function drawCentered(text, y, bg, fg)
    bg = bg or bgColor
    fg = fg or textColor
    local width = term.getSize()
    local x = math.floor((width - #text) / 2)
    term.setBackgroundColor(bg)
    term.setTextColor(fg)
    term.setCursorPos(x, y)
    term.write(text)
    term.setBackgroundColor(bgColor)
    term.setTextColor(textColor)
end

-- Draw a button
local function drawButton(text, x, y, width)
    term.setBackgroundColor(highlightColor)
    term.setTextColor(textColor)
    term.setCursorPos(x, y)
    term.write((" "):rep(width))
    term.setCursorPos(x + math.floor((width - #text)/2), y)
    term.write(text)
    term.setBackgroundColor(bgColor)
end

-- Get GitHub URL with paste support
local function getURL()
    initScreen()
    drawCentered("GitHub Repository Downloader", 2)
    drawCentered("Paste repository URL and press Enter", 4)
    
    -- Draw input box
    local width = term.getSize()
    term.setCursorPos(3, 6)
    term.write("URL: ")
    term.setBackgroundColor(inputColor)
    term.write((" "):rep(width - 8))
    term.setCursorPos(8, 6)
    
    local url = ""
    local pasteMode = false
    
    while true do
        local event, arg1, arg2, arg3 = os.pullEvent()
        
        if event == "paste" then
            -- Handle paste event
            url = arg1
            term.setCursorPos(8, 6)
            term.setBackgroundColor(inputColor)
            term.write(url)
            term.write((" "):rep(width - 8 - #url))
        elseif event == "char" then
            -- Handle typing
            if #url < (width - 8) then
                url = url .. arg1
                term.write(arg1)
            end
        elseif event == "key" then
            if arg1 == keys.backspace and #url > 0 then
                url = url:sub(1, -2)
                local x, y = term.getCursorPos()
                term.setCursorPos(x-1, y)
                term.write(" ")
                term.setCursorPos(x-1, y)
            elseif arg1 == keys.enter and #url > 0 then
                break
            elseif arg1 == keys.leftCtrl or arg1 == keys.rightCtrl then
                -- Prepare for paste (show indicator)
                drawCentered("(Paste Mode - Ctrl+V to paste)", 8, bgColor, highlightColor)
                pasteMode = true
            end
        end
    end
    
    return url
end

-- Draw progress bar
local function drawProgress(percent, message)
    local width = term.getSize()
    local barWidth = width - 4
    local progress = math.floor(barWidth * percent / 100)
    
    -- Draw message
    term.setBackgroundColor(bgColor)
    term.setTextColor(textColor)
    term.setCursorPos(2, 10)
    term.write((" "):rep(width - 2))
    term.setCursorPos(2, 10)
    term.write(message or "")
    
    -- Draw progress bar
    term.setCursorPos(2, 12)
    term.setBackgroundColor(progressBg)
    term.write((" "):rep(barWidth))
    
    term.setCursorPos(2, 12)
    term.setBackgroundColor(progressFg)
    term.write((" "):rep(progress))
    
    -- Draw percentage
    local percentText = math.floor(percent) .. "%"
    term.setBackgroundColor(progressBg)
    term.setTextColor(bgColor)
    term.setCursorPos(math.floor(width/2 - #percentText/2), 12)
    term.write(percentText)
    
    term.setBackgroundColor(bgColor)
    term.setTextColor(textColor)
end

-- Parse GitHub URL
local function parseURL(url)
    url = url:gsub("%.git$", ""):gsub("^https?://", "")
    local owner, repo = url:match("github%.com/([^/]+)/([^/]+)")
    return owner, repo
end

-- Download file with retry
local function downloadFile(url, path)
    for i = 1, 3 do  -- 3 retries
        local response = http.get(url)
        if response then
            local content = response.readAll()
            response.close()
            
            -- Create directories if needed
            local dir = path:match("(.+)/")
            if dir and not fs.exists(dir) then
                fs.makeDir(dir)
            end
            
            local file = fs.open(path, "w")
            file.write(content)
            file.close()
            return true
        end
        sleep(1)
    end
    return false
end

-- Main download function
local function downloadRepo(owner, repo, branch)
    initScreen()
    drawCentered("Github puller was forked from Tom (tiktop101)", 2)
    drawCentered("Downloading: "..owner.."/"..repo, 3)
    drawCentered("Branch: "..branch, 4)
    
    -- Get file list from GitHub API
    local apiUrl = "https://api.github.com/repos/"..owner.."/"..repo.."/git/trees/"..branch.."?recursive=1"
    local response = http.get(apiUrl)
    if not response then
        drawCentered("Failed to connect to GitHub", 6, bgColor, errorColor)
        return false
    end
    
    local data = textutils.unserializeJSON(response.readAll())
    response.close()
    
    if not data or not data.tree then
        drawCentered("Invalid repository data", 6, bgColor, errorColor)
        return false
    end
    
    -- Filter only files
    local files = {}
    for _, item in ipairs(data.tree) do
        if item.type == "blob" then
            table.insert(files, item.path)
        end
    end
    
    if #files == 0 then
        drawCentered("No files found in repository", 6, bgColor, errorColor)
        return false
    end
    
    -- Download files
    local successCount = 0
    local baseUrl = "https://raw.githubusercontent.com/"..owner.."/"..repo.."/"..branch.."/"
    
    for i, file in ipairs(files) do
        local percent = math.floor((i / #files) * 100)
        drawProgress(percent, "Downloading: "..file)
        
        if downloadFile(baseUrl..file, file) then
            successCount = successCount + 1
        end
    end
    
    -- Show results
    drawProgress(100, "Download complete!")
    drawCentered(successCount.."/"..#files.." files downloaded", 14)
    
    if successCount == #files then
        drawCentered("All files downloaded successfully!", 16, bgColor, successColor)
    else
        drawCentered("Some files failed to download", 16, bgColor, errorColor)
    end
    
    drawButton(" Continue ", math.floor(term.getSize()/2)-4, 18, 10)
    
    repeat
        local event, button = os.pullEvent("mouse_click")
    until button == 1
    
    return successCount == #files
end

-- Main program flow
local function main()
    local url = "https://github.com/simadude/obsi2-pinejam25-game"
    local owner, repo = parseURL(url)
    
    if owner and repo then
        -- Try main branch first, then master
        if not downloadRepo(owner, repo, "main") then
            downloadRepo(owner, repo, "master")
        end
    else
        initScreen()
        drawCentered("SOMETHING WENT WRONG.", 6, bgColor, errorColor)
        drawCentered("IDK WHAT THO. FUCK.", 8)
        drawButton(" Try Again ", math.floor(term.getSize()/2)-5, 10, 12)
    end
end

-- Start the program
term.clear()
term.setCursorPos(1,1)
main()
term.clear()
term.setCursorPos(1,1)
print("Just type \"main\" and it will do it.")