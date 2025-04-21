local QuestBase = {}
QuestBase.__index = QuestBase

function QuestBase.new(id,name,description,objectives,expiryTime)
	local self = setmetatable({},QuestBase)
	self.Id           = id
	self.Name         = name
	self.Description  = description
	self.Objectives   = objectives
	self.Progress     = {}
	self.IsCompleted  = false
	self.IsFailed     = false
	self.StartTime    = nil
	self.CompleteTime = nil
	self.ExpiryTime   = expiryTime
	self.Player       = nil
	return self
end

function QuestBase:Start(player)
	self.Player      = player
	self.StartTime   = tick()
	self.IsCompleted = false
	self.IsFailed    = false
	for k in pairs(self.Objectives) do
		self.Progress[k] = 0
	end
	if self.OnStart then
		self:OnStart()
	end
end

function QuestBase:UpdateProgress(objectiveName,amount)
	if self.IsCompleted or self.IsFailed then return end
	local current = self.Progress[objectiveName] or 0
	local goal    = self.Objectives[objectiveName]
	local newValue= math.min(current+amount,goal)
	self.Progress[objectiveName] = newValue
	if self.OnProgress then
		self:OnProgress(objectiveName,newValue)
	end
	QuestBase.CheckCompletion(self)
end

function QuestBase:CheckCompletion()
	for k,goal in pairs(self.Objectives) do
		if self.Progress[k] < goal then
			return
		end
	end
	QuestBase.Complete(self)
end

function QuestBase:Complete()
	if self.IsCompleted or self.IsFailed then return end
	self.IsCompleted  = true
	self.CompleteTime = tick()
	if self.OnComplete then
		self:OnComplete()
	end
end

function QuestBase:Fail()
	if self.IsCompleted or self.IsFailed then return end
	self.IsFailed = true
	if self.OnFail then
		self:OnFail()
	end
end

function QuestBase:Reset()
	self.StartTime    = nil
	self.CompleteTime = nil
	self.IsCompleted  = false
	self.IsFailed     = false
	for k in pairs(self.Objectives) do
		self.Progress[k] = 0
	end
end

return QuestBase