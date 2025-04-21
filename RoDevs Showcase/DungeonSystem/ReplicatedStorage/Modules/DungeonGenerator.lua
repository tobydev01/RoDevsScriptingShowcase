local Workspace       = game:GetService("Workspace")
local TemplateManager = require(script.Parent:WaitForChild("DungeonTemplateManager"))

local Generator = {}
Generator.__index = Generator

local ORDER = {
	"Room_Hall",
	"Room_Corridor",
	"Room_BossArena",
	"Room_Treasure",
}

local function sortTemplates(raw)
	local sorted = {}
	for _, id in ipairs(ORDER) do
		for _, tpl in ipairs(raw) do
			if tpl.Id == id then
				table.insert(sorted, tpl)
				break
			end
		end
	end
	return sorted
end

function Generator.GenerateWithSeed(seed)
	local instances = Workspace:WaitForChild("DungeonInstances")
	for _, c in ipairs(instances:GetChildren()) do c:Destroy() end

	local rawTpls   = TemplateManager:GetTemplates()
	local templates = sortTemplates(rawTpls)
	local rooms     = {}

	for i, tpl in ipairs(templates) do
		local clone = tpl.Model:Clone()
		clone.Parent = instances

		if clone.PrimaryPart then
			clone:SetPrimaryPartCFrame(tpl.Enter.CFrame)
		else
			clone:PivotTo(tpl.Enter.CFrame)
		end

		rooms[i] = {
			id     = tpl.Id,
			cframe = tpl.Enter.CFrame,
			model  = clone,
		}
	end

	return { rooms = rooms }
end

return Generator