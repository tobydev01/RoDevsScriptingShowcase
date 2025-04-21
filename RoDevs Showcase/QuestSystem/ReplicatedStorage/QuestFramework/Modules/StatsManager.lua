local DataStoreService = game:GetService("DataStoreService")
local store = DataStoreService:GetDataStore("QuestFramework_PlayerXP")

local StatsManager = {}

function StatsManager:LoadXP(player)
	local success, data = pcall(function()
		return store:GetAsync(tostring(player.UserId))
	end)
	if success and type(data) == "number" then
		print(("[StatsManager] Loaded %d XP for %s"):format(data, player.Name))
		return data
	else
		if not success then
			warn(("[StatsManager] GetAsync failed for %s: %s"):format(player.Name, tostring(data)))
		end
		return 0
	end
end

function StatsManager:SaveXP(player, xpValue)
	local success, err = pcall(function()
		store:SetAsync(tostring(player.UserId), xpValue)
	end)
	if success then
		print(("[StatsManager] Saved %d XP for %s"):format(xpValue, player.Name))
	else
		warn(("[StatsManager] SetAsync failed for %s: %s"):format(player.Name, tostring(err)))
	end
end

return StatsManager