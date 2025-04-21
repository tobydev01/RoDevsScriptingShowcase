local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local QuestBase         = require(script.Parent.QuestBase)
local RS                = ReplicatedStorage:WaitForChild("QuestFramework")
local Remotes           = RS:WaitForChild("RemoteEvents")
local QuestUpdateRE     = Remotes:WaitForChild("QuestUpdate")
local QuestActionRE     = Remotes:WaitForChild("QuestAction")

local QuestTemplateManager = require(script.Parent.QuestTemplateManager)
local DataStoreManager     = require(script.Parent.DataStoreManager)
local TriggerManager       = require(script.Parent.TriggerManager)
local RewardManager        = require(script.Parent.RewardManager)
local AnalyticsManager     = require(script.Parent.AnalyticsManager)

local DAILY_QUEST_IDS = { "DailyHerbs" }

local QuestManager = {}
QuestManager.__index = QuestManager
QuestManager._activeQuests = {}

function QuestManager:GetSecondsUntilNextDaily()
	local now = os.time()
	local t   = os.date("*t", now)
	t.hour, t.min, t.sec = 24, 0, 0
	return os.time(t) - now
end

function QuestManager:RotateDailyQuests()
	for _, player in ipairs(Players:GetPlayers()) do
		for _, id in ipairs(DAILY_QUEST_IDS) do
			if not self._activeQuests[player][id] then
				self:StartQuest(player, id)
			end
		end
	end
end

function QuestManager:SetupDailyRotation()
	task.delay(self:GetSecondsUntilNextDaily(), function()
		self:RotateDailyQuests()
		self:SetupDailyRotation()
	end)
end

function QuestManager:Init()
	Players.PlayerAdded:Connect(function(player)
		self._activeQuests[player] = {}
		self:LoadPlayerQuests(player)
	end)
	Players.PlayerRemoving:Connect(function(player)
		self:SaveAll(player)
	end)
	QuestActionRE.OnServerEvent:Connect(function(player, action, params)
		if action == "StartQuest" then
			self:StartQuest(player, params.questId)
		elseif action == "AbandonQuest" then
			self:AbandonQuest(player, params.questId)
		end
	end)
	RunService.Heartbeat:Connect(function() self:CheckExpirations() end)
	self:SetupDailyRotation()
end

function QuestManager:LoadPlayerQuests(player)
	local saved = DataStoreManager:Get(player, "ActiveQuests") or {}
	for _, entry in ipairs(saved) do
		local ok, templ = pcall(function()
			return QuestTemplateManager:GetTemplateById(entry.id)
		end)
		if ok then
			local q = templ.new()
			q.Player       = player
			q.Progress     = entry.progress or {}
			q.StartTime    = entry.startTime
			q.IsCompleted  = entry.isCompleted
			q.IsFailed     = entry.isFailed
			q.CompleteTime = entry.completeTime
			self:_registerInstance(player, q, false)
		else
			warn("[QuestManager] Skipping unknown quest ID:", entry.id)
		end
	end
end

function QuestManager:StartQuest(player, id)
	if self._activeQuests[player][id] then return end
	local templ = QuestTemplateManager:GetTemplateById(id)
	local q     = templ.new()
	self:_registerInstance(player, q, true)
end

function QuestManager:AbandonQuest(player, id)
	local q = self._activeQuests[player][id]
	if not q then return end
	q:Reset()
	QuestUpdateRE:FireClient(player, "Abandon", { questId = id })
	self._activeQuests[player][id] = nil
	self:SaveAll(player)
end

function QuestManager:CheckExpirations()
	for player, quests in pairs(self._activeQuests) do
		for _, q in pairs(quests) do
			if type(q)=="table"
				and q.ExpiryTime
				and not q.IsCompleted
				and not q.IsFailed
				and q.StartTime
				and tick() >= q.StartTime + q.ExpiryTime
			then
				q:Fail()
			end
		end
	end
end

function QuestManager:_registerInstance(player, q, isNew)
	q.Player = player

	local pm, pl = QuestManager, player

	q.OnStart = function(self)
		QuestUpdateRE:FireClient(pl, "Start", {
			questId     = self.Id,
			name        = self.Name,
			description = self.Description,
			objectives  = self.Objectives,
			progress    = self.Progress,
			isCompleted = self.IsCompleted,
			isFailed    = self.IsFailed,
		})
		pm:SaveAll(pl)
	end

	q.OnProgress = function(self, obj, val)
		QuestUpdateRE:FireClient(pl, "Progress", {
			questId       = self.Id,
			objectiveName = obj,
			newValue      = val,
			goal          = self.Objectives[obj],
		})
		AnalyticsManager:LogProgress(self, obj, val)
		pm:SaveAll(pl)
	end

	q.OnComplete = function(self)
		QuestUpdateRE:FireClient(pl, "Complete", { questId = self.Id })
		RewardManager:GiveReward(pl, self)
		AnalyticsManager:LogCompletion(self)
		pm:SaveAll(pl)
	end

	q.OnFail = function(self)
		QuestUpdateRE:FireClient(pl, "Fail", { questId = self.Id })
		pm:SaveAll(pl)
	end

	if isNew then
		QuestBase.Start(q, player)
	else
		q:OnStart()
	end

	TriggerManager:RegisterQuest(q)
	self._activeQuests[player][q.Id] = q
end

function QuestManager:SaveAll(player)
	local list = {}
	for id, q in pairs(self._activeQuests[player] or {}) do
		table.insert(list, {
			id           = id,
			progress     = q.Progress,
			startTime    = q.StartTime,
			isCompleted  = q.IsCompleted,
			isFailed     = q.IsFailed,
			completeTime = q.CompleteTime,
		})
	end
	DataStoreManager:Set(player, "ActiveQuests", list)
end

QuestManager:Init()
return QuestManager