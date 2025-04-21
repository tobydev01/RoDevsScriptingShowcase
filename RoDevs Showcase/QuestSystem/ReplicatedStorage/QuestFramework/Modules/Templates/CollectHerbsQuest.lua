local QuestBase = require(script.Parent.Parent.QuestBase)
local CollectHerbs = {}
CollectHerbs.__index = CollectHerbs
setmetatable(CollectHerbs, { __index = QuestBase })

function CollectHerbs.new()
	local self = setmetatable(QuestBase.new(
		"CollectHerbs",                  -- THIS ID must match StartQuest calls
		"Gather Healing Herbs",
		"Collect 5 healing herbs from the forest floor.",
		{ Herb = 5 }
		), CollectHerbs)
	self.Reward = 100
	return self
end

return CollectHerbs