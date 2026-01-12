-- Senky Join Server UI (2026 Edition)
-- loadstring(game:HttpGet("your_raw_link"))()(jobId)

local TS = game:GetService("TeleportService")
local PL = game:GetService("Players")
local HS = game:GetService("HttpService")
local LP = PL.LocalPlayer

local CONFIG = {
    JobId = "",
    PlaceId = game.PlaceId,
    MaxRetry = 3,
    RetryDelay = 4
}

local function createUI()
    local sg = Instance.new("ScreenGui", game.CoreGui)
    sg.Name = "SenkyJoin"
    sg.IgnoreGuiInset = true

    local bg = Instance.new("Frame", sg)
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundColor3 = Color3.fromRGB(10,10,18)
    bg.BackgroundTransparency = 0.45

    local blur = Instance.new("ImageLabel", bg)
    blur.Size = UDim2.new(1,0,1,0)
    blur.BackgroundTransparency = 1
    blur.Image = "rbxassetid://4590657393"
    blur.ImageTransparency = 0.65

    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0,420,0,280)
    frame.Position = UDim2.new(0.5,-210,0.5,-140)
    frame.BackgroundColor3 = Color3.fromRGB(18,18,28)
    frame.BackgroundTransparency = 0.3

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,16)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1,0,0,60)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.Text = "JOINING SERVER"
    title.TextColor3 = Color3.fromRGB(0,180,255)
    title.TextSize = 32
    title.TextStrokeTransparency = 0.8

    local status = Instance.new("TextLabel", frame)
    status.Size = UDim2.new(1,-40,0,140)
    status.Position = UDim2.new(0,20,0,70)
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.Gotham
    status.Text = "Đang chuẩn bị..."
    status.TextColor3 = Color3.fromRGB(220,220,240)
    status.TextSize = 16
    status.TextWrapped = true

    local pframe = Instance.new("Frame", frame)
    pframe.Size = UDim2.new(1,-60,0,12)
    pframe.Position = UDim2.new(0,30,1,-50)
    pframe.BackgroundColor3 = Color3.fromRGB(40,40,50)

    local pbar = Instance.new("Frame", pframe)
    pbar.Size = UDim2.new(0,0,1,0)
    pbar.BackgroundColor3 = Color3.fromRGB(0,180,255)

    Instance.new("UICorner", pbar).CornerRadius = UDim.new(1,0)

    return sg, status, pbar
end

local function getMoon()
    local t = os.time()
    local cycle = 1500
    local left = cycle - (t % cycle)
    return {
        time = string.format("%02d:%02d", math.floor(left/60), left%60),
        active = left <= 300
    }
end

local function checkIslands()
    local ws = workspace
    return {
        mystery = ws:FindFirstChild("MysteryIsland", true) ~= nil,
        prehistoric = ws:FindFirstChild("PrehistoricIsland", true) ~= nil,
        kitsune = ws:FindFirstChild("KitsuneIsland", true) ~= nil,
        grail = ws:FindFirstChild("HolyGrail", true) ~= nil,
        indra = ws:FindFirstChild("rip_indra", true) ~= nil or ws:FindFirstChild("Indra", true) ~= nil
    }
end

local function main(jobId)
    if not jobId or jobId == "" then warn("No JobId!") return end
    CONFIG.JobId = jobId

    local gui, stat, bar = createUI()

    local function update()
        local moon = getMoon()
        local isl = checkIslands()
        local txt = "SERVER INFO:\n\n"
        txt ..= "Full Moon: " .. (moon.active and "ĐANG CÓ!" or "Còn: "..moon.time) .. "\n\n"
        txt ..= "Islands:\n  • Mystery: " .. (isl.mystery and "CÓ" or "KHÔNG") .. "\n"
        txt ..= "  • Prehistoric: " .. (isl.prehistoric and "CÓ" or "KHÔNG") .. "\n"
        txt ..= "  • Kitsune: " .. (isl.kitsune and "CÓ" or "KHÔNG") .. "\n\n"
        txt ..= "Boss:\n  • Holy Grail: " .. (isl.grail and "CÓ" or "KHÔNG") .. "\n"
        txt ..= "  • Rip Indra: " .. (isl.indra and "CÓ" or "KHÔNG") .. "\n\n"
        txt ..= "Teleporting..."
        stat.Text = txt
    end
    update()

    spawn(function()
        for i=0,1,0.01 do
            bar.Size = UDim2.new(i,0,1,0)
            task.wait(0.04)
        end
    end)

    task.wait(5.5)
    stat.Text = "Teleporting..."

    local retries = 0
    while retries < CONFIG.MaxRetry do
        local ok = pcall(function()
            TS:TeleportToPlaceInstance(CONFIG.PlaceId, CONFIG.JobId, LP)
        end)
        if ok then
            stat.Text = "Thành công! Chờ load..."
            stat.TextColor3 = Color3.fromRGB(80,255,120)
            task.delay(12, function() gui:Destroy() end)
            return
        end
        retries += 1
        stat.Text = ("Thử lại %d/%d..."):format(retries, CONFIG.MaxRetry)
        task.wait(CONFIG.RetryDelay)
    end

    stat.Text = "Thất bại sau " .. CONFIG.MaxRetry .. " lần thử!"
end

return main