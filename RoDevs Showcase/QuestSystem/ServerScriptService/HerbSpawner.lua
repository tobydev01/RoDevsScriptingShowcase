local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")

local questFS        = ReplicatedStorage:WaitForChild("QuestFramework")
local template       = questFS:WaitForChild("HerbTemplate")
local triggersFolder = Workspace:WaitForChild("QuestTriggers")

local totalHerbs  = 10
local minRadius   = 20
local maxRadius   = 50

local function spawnHerbAt(pos)
	local h = template:Clone()
	h.Name   = "Herb"
	h.CFrame = CFrame.new(pos + Vector3.new(0,2,0))
	h.Parent = triggersFolder
end

local function spawnAround(origin)
	for i = 1, totalHerbs do
		local angle    = math.random() * 2 * math.pi
		local dist     = math.random() * (maxRadius - minRadius) + minRadius
		local offset   = Vector3.new(
			math.cos(angle) * dist,
			0,
			math.sin(angle) * dist
		)
		spawnHerbAt(origin + offset)
	end
end

local function onCharacterAdded(char)
	local hrp = char:WaitForChild("HumanoidRootPart",5)
	if hrp then
		spawnAround(hrp.Position)
	end
end

local function onPlayerAdded(player)
	player.CharacterAdded:Connect(onCharacterAdded)
	if player.Character then
		onCharacterAdded(player.Character)
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, pl in ipairs(Players:GetPlayers()) do
	onPlayerAdded(pl)
end