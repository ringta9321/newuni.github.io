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
local unicornPositions = {}

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
local animalsFolder = workspace:WaitForChild("RuntimeItems")

local function scanForUnicorns()
    for _, m in ipairs(animalsFolder:GetChildren()) do
        if m:IsA("Model") and m.Name == "Unicorn" then
            local root = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
            if not root then
                warn("Unicorn missing HumanoidRootPart:", m)
                continue
            end

            local p = root.Position
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
            end
        end
    end
end

-- Phase 1: Teleport and scan
spawn(function()
    while true do
        if isRunningPhase then
            foundUnicorns = {}
            local scanConn = RunService.Heartbeat:Connect(scanForUnicorns)
            
            for _, pt in ipairs(pathPoints) do
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

-- Include Loadstring for Castle Teleport
loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/castletpfast.github.io/refs/heads/main/FASTCASTLE.lua"))()
task.wait(3)
player:LoadCharacter()

-- Start scanning automatically
isRunningPhase = true
