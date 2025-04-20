
-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Player & Character
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local runtime = workspace:WaitForChild("RuntimeItems")

-- Flags & storage
local isRunningPhase = false
local foundUnicorns = {}
local unicornPositions = {} -- Отдельный хранилище для позиций единорогов

-- Teleport delay in seconds
local teleportDelay = 5

-- Full list of path points (Y = 20)
local pathPoints = {
        Vector3.new(13.66, 20, 29620.67),
    Vector3.new(-15.98, 20, 28227.97),
    Vector3.new(-63.54, 20, 26911.59),
    Vector3.new(-15.98, 20, 28227.97),
    Vector3.new(-75.71, 20, 25558.11),
    Vector3.new(-49.51, 20, 24038.67),
    Vector3.new(-34.48, 20, 22780.89),
    Vector3.new(-63.71, 20, 21477.32),
    Vector3.new(-84.23, 20, 19970.94),
    Vector3.new(-84.76, 20, 18676.13),
    Vector3.new(-87.32, 20, 17246.92),
    Vector3.new(-95.48, 20, 15988.29),
    Vector3.new(-93.76, 20, 14597.43),
    Vector3.new(-86.29, 20, 13223.68),
    Vector3.new(-97.56, 20, 11824.61),
    Vector3.new(-92.71, 20, 10398.51),
    Vector3.new(-98.43, 20, 9092.45),
    Vector3.new(-90.89, 20, 7741.15),
    Vector3.new(-86.46, 20, 6482.59),
    Vector3.new(-77.49, 20, 5081.21),
    Vector3.new(-73.84, 20, 3660.66),
    Vector3.new(-73.84, 20, 2297.51),
    Vector3.new(-76.56, 20, 933.68),
    Vector3.new(-81.48, 20, -429.93),
    Vector3.new(-83.47, 20, -1683.45),
    Vector3.new(-94.18, 20, -3035.25),
    Vector3.new(-109.96, 20, -4317.15),
    Vector3.new(-119.63, 20, -5667.43),
    Vector3.new(-118.63, 20, -6942.88),
    Vector3.new(-118.09, 20, -8288.66),
    Vector3.new(-132.12, 20, -9690.39),
    Vector3.new(-122.83, 20, -11051.38),
    Vector3.new(-117.53, 20, -12412.74),
    Vector3.new(-119.81, 20, -13762.14),
    Vector3.new(-126.27, 20, -15106.33),
    Vector3.new(-134.45, 20, -16563.82),
    Vector3.new(-129.85, 20, -17884.73),
    Vector3.new(-127.23, 20, -19234.89),
    Vector3.new(-133.49, 20, -20584.07),
    Vector3.new(-137.89, 20, -21933.47),
    Vector3.new(-139.93, 20, -23272.51),
    Vector3.new(-144.12, 20, -24612.54),
    Vector3.new(-142.93, 20, -25962.13),
    Vector3.new(-149.21, 20, -27301.58),
    Vector3.new(-156.19, 20, -28640.93),
    Vector3.new(-164.87, 20, -29990.78),
    Vector3.new(-177.65, 20, -31340.21),
    Vector3.new(-184.67, 20, -32689.24),
    Vector3.new(-208.92, 20, -34027.44),
    Vector3.new(-227.96, 20, -35376.88),
    Vector3.new(-239.45, 20, -36726.59),
    Vector3.new(-250.48, 20, -38075.91),
    Vector3.new(-260.28, 20, -39425.56),
    Vector3.new(-274.86, 20, -40764.67),
    Vector3.new(-297.45, 20, -42103.61),
    Vector3.new(-321.64, 20, -43442.59),
    Vector3.new(-356.78, 20, -44771.52),
    Vector3.new(-387.68, 20, -46100.94),
    Vector3.new(-415.83, 20, -47429.85),
    Vector3.new(-452.39, 20, -49407.44),
}

-- Scan helper
-- В самом верху модуля, вместо RuntimeItems:
local animalsFolder = workspace:WaitForChild("RuntimeItems")

local function scanForUnicorns()
    for _, m in ipairs(animalsFolder:GetChildren()) do
        if m:IsA("Model") and m.Name == "Unicorn" then
            -- на всякий случай найдём корневую часть модели
            local root = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
            if not root then
                warn("Unicorn без HumanoidRootPart:", m)
                continue
            end

            local p = root.Position
            -- проверка дубликатов
            local exists = false
            for _, v in ipairs(unicornPositions) do
                if (v - p).Magnitude < 5 then
                    exists = true
                    break
                end
            end

            if not exists then
                table.insert(unicornPositions, p)
                table.insert(foundUnicorns, p)
                updateUnicornsList()
            end
        end
    end
end

-- Phase 1: Teleport and scan
spawn(function()
    while true do
        if isRunningPhase then
            foundUnicorns = {} -- Очищаем только временный список
            local scanConn = RunService.Heartbeat:Connect(scanForUnicorns)
            
            for i, pt in ipairs(pathPoints) do
                if not isRunningPhase then break end
                hrp.CFrame = CFrame.new(pt)
                task.wait(teleportDelay)
            end
            
            scanConn:Disconnect()
            isRunningPhase = false
        end
        task.wait(0.1)
    end
end)

-- GUI Elements
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "UnicornFarmGUI"

local toggleButton = Instance.new("TextButton", gui)
toggleButton.Size = UDim2.new(0, 20, 0, 20)
toggleButton.Position = UDim2.new(0, 0, 0, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
toggleButton.Text = ""

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0.2, 0, 0.5, 0)
mainFrame.Position = UDim2.new(0, 20, 0.25, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.Visible = false

-- Unicorns List
local scrollFrame = Instance.new("ScrollingFrame", mainFrame)
scrollFrame.Size = UDim2.new(1, -10, 0.7, -60)
scrollFrame.Position = UDim2.new(0, 5, 0, 50)
scrollFrame.BackgroundTransparency = 1
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local listLayout = Instance.new("UIListLayout", scrollFrame)
listLayout.Padding = UDim.new(0, 5)

local function updateUnicornsList()
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Используем основное хранилище для отображения
    for idx, pos in ipairs(unicornPositions) do
        local frame = Instance.new("Frame", scrollFrame)
        frame.Size = UDim2.new(1, 0, 0, 30)
        frame.BackgroundTransparency = 1
        
        local posText = Instance.new("TextLabel", frame)
        posText.Size = UDim2.new(0.7, 0, 1, 0)
        posText.Text = string.format("Единорог %d: X:%.1f, Y:%.1f, Z:%.1f", idx, pos.X, pos.Y, pos.Z)
        posText.TextColor3 = Color3.new(1,1,1)
        
        local tpBtn = Instance.new("TextButton", frame)
        tpBtn.Size = UDim2.new(0.25, 0, 1, 0)
        tpBtn.Position = UDim2.new(0.75, 0, 0, 0)
        tpBtn.Text = "🦄"
        tpBtn.MouseButton1Click:Connect(function()
            hrp.CFrame = CFrame.new(pos + Vector3.new(0,5,0))
        end)
    end
end

-- Control Buttons
local startBtn = Instance.new("TextButton", mainFrame)
startBtn.Size = UDim2.new(1, -10, 0, 40)
startBtn.Position = UDim2.new(0, 5, 0, 5)
startBtn.Text = "Начать поиск"
startBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
startBtn.MouseButton1Click:Connect(function()
    isRunningPhase = true
end)

local castleBtn = Instance.new("TextButton", mainFrame)
castleBtn.Size = UDim2.new(1, -10, 0, 40)
castleBtn.Position = UDim2.new(0, 5, 1, -45)
castleBtn.Text = "TP в замок"
castleBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
castleBtn.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/castletpfast.github.io/refs/heads/main/FASTCASTLE.lua"))()
    task.wait(3)
    player:LoadCharacter()
end)

toggleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    if mainFrame.Visible then
        updateUnicornsList()
    end
end)
