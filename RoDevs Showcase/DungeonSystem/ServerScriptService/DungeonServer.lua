local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage     = game:GetService("ServerStorage")

local modules           = ReplicatedStorage:WaitForChild("DungeonFramework"):WaitForChild("Modules")
local DungeonManager    = require(modules:WaitForChild("DungeonManager"))
local LockoutManager    = require(ServerStorage.DungeonLockouts:WaitForChild("LockoutManager"))

local ReplicationManager = require(script.Parent:WaitForChild("DungeonReplicationManager"))
local DungeonAction     = ReplicatedStorage.DungeonFramework.RemoteEvents:WaitForChild("DungeonAction")
local DungeonUpdate     = ReplicatedStorage.DungeonFramework.RemoteEvents:WaitForChild("DungeonUpdate")

local originalGenerate = DungeonManager.GenerateDungeon
function DungeonManager:GenerateDungeon(player)
	local ok, rem = LockoutManager:CanGenerate(player)
	if not ok then
		DungeonUpdate:FireClient(player, "Lockout", { remaining = rem })
		return
	end
	originalGenerate(self, player)
	LockoutManager:SetCooldown(player, 24 * 60 * 60)
	ReplicationManager:Register(player)
end

return DungeonManager