local Players = game:GetService("Players")
local MessagingService = game:GetService("MessagingService")
local DungeonServer = require(script.Parent:WaitForChild("DungeonServer"))
local ReplicationManager = {subs={}}

function ReplicationManager:Subscribe(instanceId)
	if self.subs[instanceId] then return end
	local conn = MessagingService:SubscribeAsync("Dungeon_"..instanceId, function(msg)
		local d = msg.Data
		if d.action == "EnterRoom" then
			local player = Players:GetPlayerByUserId(d.player)
			if player then DungeonServer:EnterRoom(player, d.roomId) end
		elseif d.action == "LeaveDungeon" then
			local player = Players:GetPlayerByUserId(d.player)
			if player then DungeonServer:LeaveDungeon(player) end
		end
	end)
	self.subs[instanceId] = conn
end

function ReplicationManager:Register(player)
	local id = DungeonServer:GetOrCreate(player)
	self:Subscribe(id)
end

return ReplicationManager