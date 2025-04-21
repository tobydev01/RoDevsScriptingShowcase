local Players      = game:GetService("Players")
local StatsManager = require(game.ReplicatedStorage.QuestFramework.Modules.StatsManager)

Players.PlayerAdded:Connect(function(player)
	local stats = Instance.new("Folder")
	stats.Name   = "leaderstats"
	stats.Parent = player

	local xp = Instance.new("IntValue")
	xp.Name   = "XP"
	xp.Value  = StatsManager:LoadXP(player)
	xp.Parent = stats

	xp.Changed:Connect(function(newVal)
		StatsManager:SaveXP(player, newVal)
	end)
end)