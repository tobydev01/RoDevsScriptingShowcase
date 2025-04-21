local DataStoreService = game:GetService("DataStoreService")
local store = DataStoreService:GetDataStore("DungeonLockouts")

local LockoutManager = {}

function LockoutManager:CanGenerate(player)
	local key = "Lockout_"..player.UserId
	local ok, expiry = pcall(function() return store:GetAsync(key) end)
	if ok and expiry then
		if tick() < expiry then
			return false, expiry - tick()
		end
	end
	return true
end

function LockoutManager:SetCooldown(player, duration)
	local key = "Lockout_"..player.UserId
	local expiry = tick() + duration
	pcall(function() store:SetAsync(key, expiry) end)
end

return LockoutManager