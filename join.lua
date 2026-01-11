--[[
    SCRIPT NHẢY SERVER XUYÊN SEA - ADMIN EDITION
    Sử dụng: loadstring(game:HttpGet("LINK_RAW"))("ID_SERVER")
]]

return function(TargetJobID)
    local Players = game:GetService("Players")
    local TeleportService = game:GetService("TeleportService")
    local StarterGui = game:GetService("StarterGui")
    local Player = Players.LocalPlayer
    
    -- ═══════════════════════════════════════════════════════
    --  KIỂM TRA ID SERVER
    -- ═══════════════════════════════════════════════════════
    if not TargetJobID or TargetJobID == "" then
        StarterGui:SetCore("SendNotification", {
            Title = "⚠️ LỖI NHẬP LIỆU",
            Text = "Thiếu JobID! Vui lòng nhập ID server.",
            Duration = 5
        })
        return
    end

    -- ═══════════════════════════════════════════════════════
    --  BYPASS PLACEID (Cho phép nhảy xuyên Sea)
    -- ═══════════════════════════════════════════════════════
    local SEA3_ID = 7449423635
    local mt = getmetatable(game)
    local old = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(...)
        local method = getnamecallmethod()
        if method == "TeleportToPlaceInstance" then
            local args = {...}
            args[2] = SEA3_ID
            return old(unpack(args))
        end
        return old(...)
    end)
    setreadonly(mt, true)

    -- ═══════════════════════════════════════════════════════
    --  THÔNG BÁO TELEPORT
    -- ═══════════════════════════════════════════════════════
    StarterGui:SetCore("SendNotification", {
        Title = "🌊 ĐANG DI CHUYỂN",
        Text = "Teleport tới Sea 3...\nJobID: " .. TargetJobID:sub(1, 8) .. "...",
        Duration = 3
    })

    -- ═══════════════════════════════════════════════════════
    --  THỰC HIỆN TELEPORT
    -- ═══════════════════════════════════════════════════════
    wait(0.5)
    TeleportService:TeleportToPlaceInstance(SEA3_ID, TargetJobID, Player)
    
    -- ═══════════════════════════════════════════════════════
    --  TẠO GUI HIỂN THỊ THÔNG TIN SERVER (Sau khi load xong)
    -- ═══════════════════════════════════════════════════════
    task.spawn(function()
        wait(5) -- Đợi game load xong
        
        local ScreenGui = Instance.new("ScreenGui")
        local MainFrame = Instance.new("Frame")
        local UICorner = Instance.new("UICorner")
        local Title = Instance.new("TextLabel")
        local InfoContainer = Instance.new("ScrollingFrame")
        local UIListLayout = Instance.new("UIListLayout")
        local CloseButton = Instance.new("TextButton")
        
        -- ═══ Setup GUI ═══
        ScreenGui.Name = "ServerInfoGUI"
        ScreenGui.Parent = Player:WaitForChild("PlayerGui")
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ScreenGui.ResetOnSpawn = false
        
        -- ═══ Main Frame ═══
        MainFrame.Name = "MainFrame"
        MainFrame.Parent = ScreenGui
        MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        MainFrame.BorderSizePixel = 0
        MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
        MainFrame.Size = UDim2.new(0, 400, 0, 500)
        MainFrame.Active = true
        MainFrame.Draggable = true
        
        UICorner.CornerRadius = UDim.new(0, 15)
        UICorner.Parent = MainFrame
        
        -- ═══ Title ═══
        Title.Name = "Title"
        Title.Parent = MainFrame
        Title.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        Title.BorderSizePixel = 0
        Title.Size = UDim2.new(1, 0, 0, 50)
        Title.Font = Enum.Font.GothamBold
        Title.Text = "🌊 THÔNG TIN SERVER SEA 3"
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.TextSize = 18
        
        local TitleCorner = Instance.new("UICorner")
        TitleCorner.CornerRadius = UDim.new(0, 15)
        TitleCorner.Parent = Title
        
        -- ═══ Close Button ═══
        CloseButton.Name = "CloseButton"
        CloseButton.Parent = MainFrame
        CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        CloseButton.BorderSizePixel = 0
        CloseButton.Position = UDim2.new(1, -45, 0, 5)
        CloseButton.Size = UDim2.new(0, 40, 0, 40)
        CloseButton.Font = Enum.Font.GothamBold
        CloseButton.Text = "✕"
        CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        CloseButton.TextSize = 20
        
        local CloseCorner = Instance.new("UICorner")
        CloseCorner.CornerRadius = UDim.new(0, 10)
        CloseCorner.Parent = CloseButton
        
        CloseButton.MouseButton1Click:Connect(function()
            ScreenGui:Destroy()
        end)
        
        -- ═══ Info Container ═══
        InfoContainer.Name = "InfoContainer"
        InfoContainer.Parent = MainFrame
        InfoContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        InfoContainer.BorderSizePixel = 0
        InfoContainer.Position = UDim2.new(0, 10, 0, 60)
        InfoContainer.Size = UDim2.new(1, -20, 1, -70)
        InfoContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
        InfoContainer.ScrollBarThickness = 6
        
        local InfoCorner = Instance.new("UICorner")
        InfoCorner.CornerRadius = UDim.new(0, 10)
        InfoCorner.Parent = InfoContainer
        
        UIListLayout.Parent = InfoContainer
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout.Padding = UDim.new(0, 8)
        
        -- ═══════════════════════════════════════════════════════
        --  HÀM TẠO INFO LABEL
        -- ═══════════════════════════════════════════════════════
        local function CreateInfoLabel(emoji, text, value, color)
            local Label = Instance.new("TextLabel")
            Label.Parent = InfoContainer
            Label.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            Label.BorderSizePixel = 0
            Label.Size = UDim2.new(1, -10, 0, 40)
            Label.Font = Enum.Font.Gotham
            Label.Text = string.format("%s %s: %s", emoji, text, tostring(value))
            Label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.TextWrapped = true
            
            local LabelPadding = Instance.new("UIPadding")
            LabelPadding.PaddingLeft = UDim.new(0, 10)
            LabelPadding.Parent = Label
            
            local LabelCorner = Instance.new("UICorner")
            LabelCorner.CornerRadius = UDim.new(0, 8)
            LabelCorner.Parent = Label
            
            return Label
        end
        
        -- ═══════════════════════════════════════════════════════
        --  KIỂM TRA THÔNG TIN SERVER
        -- ═══════════════════════════════════════════════════════
        local Workspace = game:GetService("Workspace")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        
        -- Trái ác quỷ
        local devilFruits = 0
        for _, v in pairs(Workspace:GetChildren()) do
            if string.find(v.Name, "Fruit") or v:FindFirstChild("Handle") then
                devilFruits = devilFruits + 1
            end
        end
        
        -- Chén thánh (Khi có event)
        local holyGrail = Workspace:FindFirstChild("HolyGrail") and "✅ CÓ" or "❌ KHÔNG"
        
        -- Đảo bí ẩn
        local mysteryIsland = Workspace:FindFirstChild("MysticIsland") and "✅ CÓ" or "❌ KHÔNG"
        
        -- Đảo tiền sử
        local fossilIsland = Workspace:FindFirstChild("FrozenDimension") and "✅ CÓ" or "❌ KHÔNG"
        
        -- Full Moon
        local Lighting = game:GetService("Lighting")
        local fullMoon = "❌ KHÔNG"
        if Lighting:FindFirstChild("Sky") then
            local moon = Lighting.Sky.MoonAngularSize
            if moon >= 11 then
                fullMoon = "🌕 TRĂNG TRÒN"
            end
        end
        
        -- Key Râu Đen (Kiểm tra trong ReplicatedStorage hoặc Player)
        local blackbeardKey = "❌ KHÔNG"
        if ReplicatedStorage:FindFirstChild("BlackbeardKey") then
            blackbeardKey = "✅ CÓ"
        end
        
        -- Thành viên
        local playerCount = #Players:GetPlayers() .. "/12"
        
        -- ═══════════════════════════════════════════════════════
        --  HIỂN THỊ THÔNG TIN
        -- ═══════════════════════════════════════════════════════
        CreateInfoLabel("🍇", "Trái Ác Quỷ", devilFruits .. " trái", Color3.fromRGB(200, 100, 255))
        CreateInfoLabel("🔑", "Key Râu Đen", blackbeardKey, Color3.fromRGB(255, 200, 50))
        CreateInfoLabel("🏆", "Chén Thánh", holyGrail, Color3.fromRGB(255, 215, 0))
        CreateInfoLabel("👥", "Thành Viên", playerCount, Color3.fromRGB(100, 200, 255))
        CreateInfoLabel("🏝️", "Đảo Bí Ẩn", mysteryIsland, Color3.fromRGB(50, 255, 150))
        CreateInfoLabel("🦴", "Đảo Tiền Sử", fossilIsland, Color3.fromRGB(150, 150, 255))
        CreateInfoLabel("🌕", "Full Moon", fullMoon, Color3.fromRGB(255, 255, 150))
        CreateInfoLabel("🆔", "JobID", TargetJobID:sub(1, 20) .. "...", Color3.fromRGB(150, 150, 150))
        
        -- Auto-resize canvas
        InfoContainer.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
    end)
end