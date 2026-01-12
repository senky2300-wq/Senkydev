
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Cấu hình
local CONFIG = {
    ServerJobId = "", -- Sẽ được điền tự động từ Python
    PlaceId = game.PlaceId,
}

-- UI Loading
local function createLoadingUI()
    local ScreenGui = Instance.new("ScreenGui")
    local Frame = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local Status = Instance.new("TextLabel")
    local Progress = Instance.new("Frame")
    local Bar = Instance.new("Frame")
    
    ScreenGui.Name = "LoadingScreen"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    Frame.Parent = ScreenGui
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BorderSizePixel = 0
    Frame.Position = UDim2.new(0.5, -200, 0.5, -150)
    Frame.Size = UDim2.new(0, 400, 0, 300)
    
    Title.Parent = Frame
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "JOINING SERVER"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 24
    
    Status.Name = "Status"
    Status.Parent = Frame
    Status.BackgroundTransparency = 1
    Status.Position = UDim2.new(0, 20, 0, 60)
    Status.Size = UDim2.new(1, -40, 0, 200)
    Status.Font = Enum.Font.Gotham
    Status.Text = "Loading server info..."
    Status.TextColor3 = Color3.fromRGB(200, 200, 200)
    Status.TextSize = 14
    Status.TextWrapped = true
    Status.TextYAlignment = Enum.TextYAlignment.Top
    
    Progress.Parent = Frame
    Progress.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Progress.Position = UDim2.new(0, 20, 1, -40)
    Progress.Size = UDim2.new(1, -40, 0, 20)
    
    Bar.Name = "Bar"
    Bar.Parent = Progress
    Bar.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    Bar.BorderSizePixel = 0
    Bar.Size = UDim2.new(0, 0, 1, 0)
    
    return ScreenGui, Status, Bar
end

-- Hàm lấy thông tin Full Moon
local function getFullMoonInfo()
    local currentTime = tick()
    local fullMoonCycle = 1500 -- 25 phút = 1500 giây
    local timeUntilFullMoon = fullMoonCycle - (currentTime % fullMoonCycle)
    
    local minutes = math.floor(timeUntilFullMoon / 60)
    local seconds = math.floor(timeUntilFullMoon % 60)
    
    local isFullMoon = false
    if timeUntilFullMoon > (fullMoonCycle - 300) then
        isFullMoon = true
    end
    
    return {
        timeUntil = string.format("%02d:%02d", minutes, seconds),
        isActive = isFullMoon
    }
end

-- Hàm kiểm tra đảo
local function checkIslands()
    local workspace = game:GetService("Workspace")
    local info = {
        mysteryIsland = false,
        prehistoricIsland = false,
        kitsuneIsland = false,
        holyGrail = false,
        ripIndra = false
    }
    
    if workspace:FindFirstChild("Map") then
        local map = workspace.Map
        
        if map:FindFirstChild("MysteryIsland") or map:FindFirstChild("SecretArea") then
            info.mysteryIsland = true
        end
        
        if map:FindFirstChild("PrehistoricIsland") or map:FindFirstChild("Dinosaur") then
            info.prehistoricIsland = true
        end
        
        if map:FindFirstChild("KitsuneIsland") or map:FindFirstChild("Kitsune") then
            info.kitsuneIsland = true
        end
    end
    
    if workspace:FindFirstChild("HolyGrail") or game.ReplicatedStorage:FindFirstChild("HolyGrail") then
        info.holyGrail = true
    end
    
    if workspace:FindFirstChild("NPCs") then
        if workspace.NPCs:FindFirstChild("rip_indra") or workspace.NPCs:FindFirstChild("Indra") then
            info.ripIndra = true
        end
    end
    
    return info
end

-- Hàm hiển thị thông tin server
local function displayServerInfo(statusLabel)
    local fullMoon = getFullMoonInfo()
    local islands = checkIslands()
    
    local info = "=== SERVER INFO ===\n\n"
    
    info = info .. "Full Moon:\n"
    if fullMoon.isActive then
        info = info .. "   ACTIVE NOW!\n"
    else
        info = info .. "   Time left: " .. fullMoon.timeUntil .. "\n"
    end
    
    info = info .. "\nSpecial Islands:\n"
    info = info .. "   " .. (islands.mysteryIsland and "YES Mystery Island" or "NO Mystery Island") .. "\n"
    info = info .. "   " .. (islands.prehistoricIsland and "YES Prehistoric Island" or "NO Prehistoric Island") .. "\n"
    info = info .. "   " .. (islands.kitsuneIsland and "YES Kitsune Island" or "NO Kitsune Island") .. "\n"
    
    info = info .. "\nBosses:\n"
    info = info .. "   " .. (islands.holyGrail and "YES Holy Grail" or "NO Holy Grail") .. "\n"
    info = info .. "   " .. (islands.ripIndra and "YES Rip Indra" or "NO Rip Indra") .. "\n"
    
    info = info .. "\nJoining in 5 seconds..."
    
    statusLabel.Text = info
end

-- Hàm animate progress bar
local function animateProgress(bar, duration)
    local startTime = tick()
    while tick() - startTime < duration do
        local progress = (tick() - startTime) / duration
        bar.Size = UDim2.new(progress, 0, 1, 0)
        wait(0.05)
    end
    bar.Size = UDim2.new(1, 0, 1, 0)
end

-- Hàm join server
local function joinServer(jobId)
    local success, errorMessage = pcall(function()
        TeleportService:TeleportToPlaceInstance(
            CONFIG.PlaceId,
            jobId,
            Players.LocalPlayer
        )
    end)
    
    if not success then
        warn("Teleport failed: " .. tostring(errorMessage))
        return false
    end
    
    return true
end

-- Main execution
local function main(serverJobId)
    -- Set JobId từ parameter
    CONFIG.ServerJobId = serverJobId or CONFIG.ServerJobId
    
    if CONFIG.ServerJobId == "" then
        warn("No server JobId provided!")
        return
    end
    
    -- Tạo UI
    local ui, statusLabel, progressBar = createLoadingUI()
    
    -- Hiển thị thông tin
    displayServerInfo(statusLabel)
    
    -- Animate progress bar
    spawn(function()
        animateProgress(progressBar, 5)
    end)
    
    -- Đợi 5 giây
    wait(5)
    
    -- Join server
    statusLabel.Text = "Teleporting..."
    
    local joined = joinServer(CONFIG.ServerJobId)
    
    if not joined then
        statusLabel.Text = "Failed to join server!\nRetrying in 3 seconds..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        wait(3)
        joinServer(CONFIG.ServerJobId)
    end
end

-- Return function để Python có thể gọi với parameter
return main
