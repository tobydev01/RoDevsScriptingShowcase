local RewardManager = {}

function RewardManager:GiveReward(player, quest)
	local amount = quest.Reward or 100
	local stats  = player:FindFirstChild("leaderstats")
	if not stats then
		warn("[RewardManager] No leaderstats for", player.Name)
		return
	end

	local xp = stats:FindFirstChild("XP")
	if not xp or not xp:IsA("IntValue") then
		warn("[RewardManager] No XP IntValue for", player.Name)
		return
	end

	xp.Value = xp.Value + amount
	print(("[RewardManager] Awarded %d XP to %s for %s")
		:format(amount, player.Name, quest.Id))
end

return RewardManager