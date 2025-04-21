local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService  = game:GetService("DataStoreService")

local RS                = ReplicatedStorage:WaitForChild("DungeonFramework")
local RemoteEvents      = RS:WaitForChild("RemoteEvents")
local ActionEvent       = RemoteEvents:WaitForChild("DungeonAction")
local UpdateEvent       = RemoteEvents:WaitForChild("DungeonUpdate")
local RemoteFuncs       = RS:WaitForChild("RemoteFunctions")
local GetInstanceFunc   = RemoteFuncs:WaitForChild("GetDungeonInstance")

local Generator         = require(script.Parent:WaitForChild("DungeonGenerator"))
local AIManager         = require(script.Parent:WaitForChild("AIManager"))

local SeedStore         = DataStoreService:GetDataStore("DungeonSeed")
local ProgressStore     = DataStoreService:GetDataStore("DungeonProgress")

local DungeonManager    = {}
DungeonManager.__index  = DungeonManager

local dungeons = {}

ActionEvent.OnServerEvent:Connect(function(player, action, params)
	if action == "GenerateDungeon" then
		DungeonManager:GenerateDungeon(player)
	elseif action == "EnterRoom" then
		DungeonManager:OnRoomCleared(player, params.roomId)
	elseif action == "SaveDungeon" then
		DungeonManager:SavePlayerProgress(player)
	end
end)

GetInstanceFunc.OnServerInvoke = function(player)
	return DungeonManager:GetOrCreate(player)
end

Players.PlayerAdded:Connect(function(player)
	DungeonManager:LoadPlayerDungeon(player)
end)

Players.PlayerRemoving:Connect(function(player)
	DungeonManager:SavePlayerProgress(player)
	dungeons[player.UserId] = nil
end)

function DungeonManager:GetOrCreate(player)
	local uid = player.UserId
	local d = dungeons[uid]
	if not d then
		d = { seed = nil, layout = nil, currentIndex = 0 }
		dungeons[uid] = d
	end
	return d
end

function DungeonManager:GenerateDungeon(player)
	local uid = player.UserId
	local d = self:GetOrCreate(player)
	local seed = math.random(1, 1e9)
	d.seed = seed
	pcall(function() SeedStore:SetAsync(tostring(uid), seed) end)
	local layout = Generator.GenerateWithSeed(seed)
	d.layout = layout
	d.currentIndex = 1
	UpdateEvent:FireClient(player, "DungeonGenerated", { rooms = layout.rooms, index = 1 })
	AIManager:SpawnFor(player, layout.rooms[1].model)
	pcall(function() ProgressStore:SetAsync(tostring(uid), 1) end)
end

function DungeonManager:OnRoomCleared(player)
	local uid = player.UserId
	local d = dungeons[uid]
	if not d or not d.layout then return end
	d.currentIndex = d.currentIndex + 1
	if d.currentIndex <= #d.layout.rooms then
		pcall(function() ProgressStore:SetAsync(tostring(uid), d.currentIndex) end)
		UpdateEvent:FireClient(player, "RoomCleared", { rooms = d.layout.rooms, index = d.currentIndex })
		AIManager:SpawnFor(player, d.layout.rooms[d.currentIndex].model)
	else
		UpdateEvent:FireClient(player, "DungeonComplete", {})
	end
end

function DungeonManager:SavePlayerProgress(player)
	local uid = player.UserId
	local d = dungeons[uid]
	if not d then return end
	pcall(function() ProgressStore:SetAsync(tostring(uid), d.currentIndex) end)
end

function DungeonManager:LoadPlayerDungeon(player)
	local uid = player.UserId
	local okS, seed = pcall(function() return SeedStore:GetAsync(tostring(uid)) end)
	if not okS or not seed then return end
	local okP, idx = pcall(function() return ProgressStore:GetAsync(tostring(uid)) end)
	local index = (okP and idx) or 1
	local layout = Generator.GenerateWithSeed(seed)
	dungeons[uid] = { seed = seed, layout = layout, currentIndex = index }
	UpdateEvent:FireClient(player, "DungeonGenerated", { rooms = layout.rooms, index = index })
	AIManager:SpawnFor(player, layout.rooms[index].model)
end

return setmetatable({}, DungeonManager)