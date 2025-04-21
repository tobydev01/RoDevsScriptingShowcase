local Workspace      = game:GetService("Workspace")
local RS             = game:GetService("ReplicatedStorage")
local TemplateFolder = RS:WaitForChild("DungeonFramework"):WaitForChild("Enemies")
local EnemyTemplate  = TemplateFolder:WaitForChild("EnemyTemplate")
local Debris         = game:GetService("Debris")

local AIManager = {}
AIManager.__index = AIManager

local function gatherFloorParts(model)
	local floorParts = {}
	for _, obj in ipairs(model:GetDescendants()) do
		if obj:IsA("BasePart") and obj.CanCollide then
			local s = obj.Size
			local minHoriz = math.min(s.X, s.Z)
			if s.Y < minHoriz * 0.3 then
				table.insert(floorParts, obj)
			end
		end
	end
	return floorParts
end

local function computeFloorBounds(parts)
	local minX, minZ, maxX, maxZ, minY
	for _, part in ipairs(parts) do
		local p = part.Position
		if not minX then
			minX, maxX = p.X, p.X
			minZ, maxZ = p.Z, p.Z
			minY = p.Y
		else
			minX = math.min(minX, p.X)
			maxX = math.max(maxX, p.X)
			minZ = math.min(minZ, p.Z)
			maxZ = math.max(maxZ, p.Z)
			minY = math.min(minY, p.Y)
		end
	end
	return minX, minZ, maxX, maxZ, minY
end

function AIManager:SpawnFor(player, roomModel)
	task.wait(0.5)

	local instances = Workspace:WaitForChild("DungeonInstances")
	for _, obj in ipairs(instances:GetChildren()) do
		if obj.Name == EnemyTemplate.Name then obj:Destroy() end
	end

	local enter = roomModel:FindFirstChild("Enter", true)
	if not enter then return end

	local floors = gatherFloorParts(roomModel)
	if #floors == 0 then return end
	local minX, minZ, maxX, maxZ, minY = computeFloorBounds(floors)

	local centerXZ = Vector3.new((minX+maxX)/2, 0, (minZ+maxZ)/2)

	local enterFlat = Vector3.new(enter.Position.X, 0, enter.Position.Z)
	local toEnter = (enterFlat - centerXZ)
	if toEnter.Magnitude < 1 then toEnter = Vector3.new(0,0,1) end
	local awayDir = (-toEnter).Unit
	local perpDir = Vector3.new(-awayDir.Z, 0, awayDir.X).Unit

	-- spawn config
	local numAI   = 3
	local margin  = 3
	local roomW   = maxX - minX
	local roomD   = maxZ - minZ
	local radius  = math.max((math.min(roomW, roomD) * 0.5) - margin, 2)
	local spread  = math.max((math.min(roomW, roomD) * 0.5) - margin, 2)
	local spawnY  = minY + 2
	local alive   = numAI

	-- compute spawn positions
	local spawnPositions = {}
	for i = 1, numAI do
		local t = (i - (numAI+1)/2) / ((numAI-1)/2)
		local base = centerXZ + awayDir * radius
		spawnPositions[i] = base + perpDir * (t * spread) + Vector3.new(0, spawnY, 0)
	end

	-- spawn NPCs
	for _, pos in ipairs(spawnPositions) do
		local npc = EnemyTemplate:Clone()
		npc.Parent = instances
		npc.Name   = EnemyTemplate.Name

		local root = npc.PrimaryPart or npc:FindFirstChildWhichIsA("BasePart")
		local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if root and hrp then
			spawn(function()
				while npc.Parent and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 do
					root.CFrame = CFrame.new(pos, hrp.Position)
					task.wait(0.1)
				end
			end)
		end

		-- shooting loop always active
		spawn(function()
			local hum = npc:WaitForChild("Humanoid")
			while hum.Health > 0 and hrp and hrp.Parent do
				local origin = root and root.Position or pos
				local vel = hrp.AssemblyLinearVelocity or Vector3.new()
				local predict = hrp.Position + vel * 0.2
				local aimPos = predict + Vector3.new(math.random(-2,2), math.random(-1,1), math.random(-2,2))
				local dir = (aimPos - origin).Unit
				local bullet = Instance.new("Part")
				bullet.Size       = Vector3.new(0.2,0.2,1)
				bullet.CFrame     = CFrame.lookAt(origin, aimPos)
				bullet.CanCollide = false
				bullet.Anchored   = false
				bullet.Velocity   = dir * 300
				bullet.Parent     = instances
				bullet.Touched:Connect(function(hit)
					local h = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
					if h and hit.Parent ~= npc then
						h:TakeDamage(1)
						bullet:Destroy()
					end
				end)
				Debris:AddItem(bullet, 3)
				task.wait(0.5)
			end
		end)

		-- death handler
		npc:WaitForChild("Humanoid").Died:Connect(function()
			alive = alive - 1
			if alive <= 0 then
				local DM = require(script.Parent:WaitForChild("DungeonManager"))
				DM:OnRoomCleared(player)
			end
		end)
	end
end

return setmetatable({}, AIManager)
