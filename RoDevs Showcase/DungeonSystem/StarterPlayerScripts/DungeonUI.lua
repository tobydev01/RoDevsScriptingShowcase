local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local player      = Players.LocalPlayer
local screenGui   = player:WaitForChild("PlayerGui"):WaitForChild("DungeonUI")
local mainFrame   = screenGui:WaitForChild("MainFrame")
local generateBtn = mainFrame:WaitForChild("GenerateButton")
local statusLabel = mainFrame:WaitForChild("StatusLabel")

local df           = ReplicatedStorage:WaitForChild("DungeonFramework")
local DungeonAction = df:WaitForChild("RemoteEvents"):WaitForChild("DungeonAction")
local DungeonUpdate = df:WaitForChild("RemoteEvents"):WaitForChild("DungeonUpdate")

local rooms, current = {}, 0

local function showUI()
	mainFrame.Position = UDim2.new(0.5,0,1.5,0)
	mainFrame.Visible  = true
	TweenService:Create(mainFrame, TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5,0,0.5,0)
	}):Play()
end

local function setStatus(txt)
	statusLabel.Text = "Status: "..txt
end

local function teleportTo(cframe)
	local char = player.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		char.HumanoidRootPart.CFrame = cframe + Vector3.new(0,3,0)
	end
end

DungeonUpdate.OnClientEvent:Connect(function(evt,data)
	if evt == "DungeonGenerated" then
		screenGui.Enabled = false 
		rooms   = data.rooms
		current = data.index or 1
		setStatus("Dungeon Generated")
		task.wait(0.1)
		teleportTo(rooms[current].cframe)
	elseif evt == "RoomCleared" then
		rooms   = data.rooms
		current = data.index
		task.wait(0.1)
		teleportTo(rooms[current].cframe)
	elseif evt == "DungeonComplete" then
		setStatus("Dungeon Complete")
	end
end)

generateBtn.MouseButton1Click:Connect(function()
	showUI()
	setStatus("Generating…")
	DungeonAction:FireServer("GenerateDungeon",{})
end)

showUI()