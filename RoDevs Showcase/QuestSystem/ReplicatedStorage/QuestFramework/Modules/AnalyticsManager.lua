local AnalyticsManager = {}

function AnalyticsManager:LogProgress(quest, objectiveName, newValue)
	print(("[Analytics] %s: %s → %d/%d"):format(
		quest.Player.Name,
		objectiveName,
		newValue,
		quest.Objectives[objectiveName]
		))
end

function AnalyticsManager:LogCompletion(quest)
	local duration = quest.CompleteTime - quest.StartTime
	print(("[Analytics] %s finished %s in %.1f seconds"):format(
		quest.Player.Name,
		quest.Id,
		duration
		))
end

return AnalyticsManager