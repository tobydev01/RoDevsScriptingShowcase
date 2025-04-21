local TemplateManager = {}
TemplateManager.__index = TemplateManager

local RS = game:GetService("ReplicatedStorage")
local folder = RS:WaitForChild("DungeonFramework"):WaitForChild("Templates")

function TemplateManager:GetTemplates()
	local list = {}
	for _, model in ipairs(folder:GetChildren()) do
		if model:IsA("Model") then
			local enterPart = model:FindFirstChild("Enter", true)
			if enterPart and enterPart:IsA("BasePart") then
				table.insert(list, {
					Id    = model.Name,
					Model = model,
					Enter = enterPart,
				})
			else
				warn("[TemplateManager] Skipping "..model.Name.." (no Enter part)")
			end
		end
	end
	return list
end

return setmetatable({}, TemplateManager)