local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local SPEED = 1250
local DISTANCE = 75000
local NO_CLIP = true
local SCAN_INTERVAL = 0.1
local HEIGHT_OFFSET = 3
local MOVEMENT_DIRECTION = -1

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

local fallbackUsed = false
local unicornFound = false
local closestDistance = math.huge

if NO_CLIP then
    RunService.Stepped:Connect(function()
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

local function isUnicorn(model)
    return model and model:IsA("Model") and model.Name and (
        model.Name:lower():find("unicorn") or
        model:FindFirstChild("Horn") or
        (model:FindFirstChildWhichIsA("MeshPart") and 
         model:FindFirstChildWhichIsA("MeshPart").MeshId:lower():find("unicorn"))
    )
end

local function trySit(target, seatType)
    local seat = target:FindFirstChild(seatType)
    if seat and seat:IsA("Seat") then
        rootPart.CFrame = seat.CFrame
        task.wait(0.5)
        return true
    end
    return false
end

local function checkFallbackOptions()
    local animals = Workspace:FindFirstChild("Baseplates") and Workspace.Baseplates:FindFirstChild("Baseplate") and Workspace.Baseplates.Baseplate:FindFirstChild("CenterBaseplate") and Workspace.Baseplates.Baseplate.CenterBaseplate:FindFirstChild("Animals")

    if not animals then
        return
    end

    local horse = animals:FindFirstChild("Model_Horse")
    if horse and horse:IsA("Model") then
        local distance = (horse.PrimaryPart.Position - rootPart.Position).Magnitude
        if distance < closestDistance and trySit(horse, "VehicleSeat") then
            closestDistance = distance
            fallbackUsed = true
            return
        end
    end

    local chair = Workspace.RuntimeItems:FindFirstChild("Chair")
    if chair then
        local seat = chair:FindFirstChild("Seat")
        if seat then
            local distance = (seat.Position - rootPart.Position).Magnitude
            if distance < closestDistance and trySit(chair, "Seat") then
                closestDistance = distance
                fallbackUsed = true
                return
            end
        end
    end
end

local function tweenBackward()
    local startPos = rootPart.Position
    local startCFrame = CFrame.new(startPos.X, startPos.Y + HEIGHT_OFFSET, startPos.Z)
    local endCFrame = CFrame.new(
        startPos.X, 
        startPos.Y + HEIGHT_OFFSET, 
        startPos.Z + (DISTANCE * MOVEMENT_DIRECTION)
    )

    local lastScan = 0
    local heartbeat = RunService.Heartbeat:Connect(function(deltaTime)
        lastScan = lastScan + deltaTime
        if lastScan >= SCAN_INTERVAL then
            lastScan = 0
            for _, descendant in ipairs(Workspace:GetDescendants()) do
                if isUnicorn(descendant) then
                    unicornFound = true
                    checkFallbackOptions()
                    heartbeat:Disconnect()
                    return
                end
            end
        end
    end)

    local tweenInfo = TweenInfo.new(
        DISTANCE / SPEED,
        Enum.EasingStyle.Linear
    )
    local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = endCFrame})
    tween:Play()
    tween.Completed:Wait()

    heartbeat:Disconnect()
end

while not unicornFound or not fallbackUsed do
    local success, errorMessage = pcall(tweenBackward)
    if not success then
        warn("Error in tweenBackward: "..errorMessage)
        break
    end
end
