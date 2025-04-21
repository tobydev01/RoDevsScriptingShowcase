local QuestBase = require(script.Parent.Parent.QuestBase)
local DailyHerbs = setmetatable({}, { __index = QuestBase })
function DailyHerbs.new()
	local self = QuestBase.new(
		"DailyHerbs",
		"Daily Herb Run",
		"Collect 3 herbs for your daily bonus.",
		{ Herb = 3 }
	)
	self.Reward = 75
	return setmetatable(self, DailyHerbs)
end
return DailyHerbs