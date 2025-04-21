local manager = {}
manager.Templates = {}

local templateFolder = script.Parent:WaitForChild("Templates")
for _, mod in ipairs(templateFolder:GetChildren()) do
	if mod:IsA("ModuleScript") then
		local templClass = require(mod)
		assert(type(templClass)=="table" and type(templClass.new)=="function",
			"[QTM] "..mod.Name.." must return a .new()")
		local sample = templClass.new()
		assert(type(sample.Id)=="string",
			"[QTM] "..mod.Name..".new() must set .Id:string")
		manager.Templates[sample.Id] = templClass
	end
end

function manager:GetTemplateById(id)
	local templ = manager.Templates[id]
	assert(templ, "[QTM] no template registered for Id '"..tostring(id).."'" )
	return templ
end

function manager:CreateQuest(id, player)
	local templ = self:GetTemplateById(id)
	local quest = templ.new()
	return quest
end

return manager