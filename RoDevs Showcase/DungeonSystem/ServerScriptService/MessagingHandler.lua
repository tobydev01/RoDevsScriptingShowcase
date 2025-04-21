local Players = game:GetService("Players")
local ReplicationManager = require(script.Parent:WaitForChild("DungeonReplicationManager"))

Players.PlayerAdded:Connect(function(player)
	ReplicationManager:Register(player)
end)