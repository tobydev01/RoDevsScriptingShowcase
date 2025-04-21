local Players   = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local QuestBase = require(script.Parent.QuestBase)

local QTfolder  = Workspace:WaitForChild("QuestTriggers",5)
local TriggerManager = {}
TriggerManager._quests  = {} -- [questId] = questInstance
TriggerManager._touched = {} -- [part] = { [player] = { [questId]=true } }

local function connectPart(part)
	if not part:IsA("BasePart") then return end
	local objVal = part:FindFirstChild("Objective")
	if not objVal or objVal.ClassName ~= "StringValue" then return end
	TriggerManager._touched[part] = {}
	part.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player then return end
		local key = objVal.Value
		local pm = TriggerManager._touched[part]
		pm[player] = pm[player] or {}
		for _, quest in pairs(TriggerManager._quests) do
			if quest.Player == player and quest.Progress[key] ~= nil then
				if not pm[player][quest.Id] then
					pm[player][quest.Id] = true
					if type(quest.UpdateProgress) == "function" then
						quest:UpdateProgress(key,1)
					else
						QuestBase.UpdateProgress(quest,key,1)
					end
				end
			end
		end
	end)
end

for _, part in ipairs(QTfolder:GetChildren()) do
	connectPart(part)
end
QTfolder.ChildAdded:Connect(connectPart)

function TriggerManager:RegisterQuest(quest)
	TriggerManager._quests[quest.Id] = quest
	for part, pm in pairs(TriggerManager._touched) do
		pm[quest.Player] = {}
	end
end

return TriggerManager