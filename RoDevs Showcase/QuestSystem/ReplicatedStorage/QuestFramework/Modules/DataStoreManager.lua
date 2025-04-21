local DataStoreService = game:GetService("DataStoreService")
local manager = {}
local stores  = {}

local function getStore(key)
	if not stores[key] then
		stores[key] = DataStoreService:GetDataStore("QuestFramework1_" .. key)
		print(("[DataStore] Created store for key '%s'"):format(key))
	end
	return stores[key]
end

function manager:Get(player, key)
	local ds      = getStore(key)
	local userKey = tostring(player.UserId)

	local ok, data = pcall(function()
		return ds:GetAsync(userKey)
	end)

	if ok then
		local status = data == nil and "nil" or "table"
		print(("[DataStore] Get '%s' for %s → %s"):format(key, player.Name, status))
		return data
	else
		warn(("[DataStore] GetAsync error for %s key '%s': %s")
			:format(player.Name, key, tostring(data)))
		return nil
	end
end

function manager:Set(player, key, value)
	local ds      = getStore(key)
	local userKey = tostring(player.UserId)

	local ok, err = pcall(function()
		ds:SetAsync(userKey, value)
	end)

	if ok then
		print(("[DataStore] Set '%s' for %s"):format(key, player.Name))
	else
		warn(("[DataStore] SetAsync error for %s key '%s': %s")
			:format(player.Name, key, tostring(err)))
	end
end

return manager