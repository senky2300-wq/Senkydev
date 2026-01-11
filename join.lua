-- [[ 
--    SCRIPT NHẢY SERVER XUYÊN SEA CHO ADMIN 1180691145630683216 
--    Cấu trúc: loadstring(game:HttpGet("LINK_RAW"))("ID_SERVER")()
-- ]]

return function(TargetJobID)
    -- 1. Kiểm tra ID đầu vào
    if not TargetJobID or TargetJobID == "" then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "❌ THIẾU ID",
            Text = "Bot chưa truyền JobID cho script!",
            Duration = 5
        })
        return
    end

    -- 2. Bộ lọc Bypass PlaceID (Giúp nhảy xuyên Sea 1, 2 lên 3)
    local SEA3_ID = 744995991
    local mt = getmetatable(game)
    local old = mt.__index
    setreadonly(mt, false)
    mt.__index = newcclosure(function(t, k)
        if k == "PlaceId" then 
            return SEA3_ID 
        end
        return old(t, k)
    end)
    setreadonly(mt, true)

    -- 3. Thông báo trên màn hình game
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🚀 ADMIN TELEPORT",
        Text = "Đang đưa mày lên Sea 3 săn trăng...",
        Duration = 10
    })

    -- 4. Thực hiện nhảy server
    local TeleportService = game:GetService("TeleportService")
    TeleportService:TeleportToPlaceInstance(SEA3_ID, TargetJobID, game.Players.LocalPlayer)
end