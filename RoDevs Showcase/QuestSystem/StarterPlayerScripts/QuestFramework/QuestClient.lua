local Players=game:GetService("Players")
local UserInputService=game:GetService("UserInputService")
local player=Players.LocalPlayer

local pg=player:WaitForChild("PlayerGui")
local RS=game:GetService("ReplicatedStorage"):WaitForChild("QuestFramework")
local Remotes=RS:WaitForChild("RemoteEvents")

local Update=Remotes:WaitForChild("QuestUpdate")
local Action=Remotes:WaitForChild("QuestAction")
local screenGui=pg:WaitForChild("QuestUI")

local journal=screenGui:WaitForChild("QuestJournalFrame")
local template=screenGui:WaitForChild("QuestEntryTemplate")

local function getEntry(data)
	local e=journal:FindFirstChild(data.questId)
	if not e then
		e=template:Clone()
		e.Name=data.questId
		e.Parent=journal
		e.Visible=true
	end
	return e
end

Update.OnClientEvent:Connect(function(t,data)
	if t=="Start" then
		local e=getEntry(data)
		e.QuestName.Text=data.name
		e.Description.Text=data.description
		local bg=e:WaitForChild("ProgressBarBackground")
		local bar=bg:WaitForChild("ProgressBar")
		local txt=bg:WaitForChild("ProgressText")
		local badge=e:WaitForChild("CompletedBadge")
		local obj,goal=next(data.objectives)
		local prog=(data.progress and data.progress[obj])or 0
		local frac=math.clamp(prog/goal,0,1)
		bar.Size=UDim2.new(frac,0,1,0)
		txt.Text=("%d/%d"):format(prog,goal)
		badge.Visible=data.isCompleted
		if data.isFailed then
			bg.BackgroundColor3=Color3.fromRGB(180,60,60)
			txt.Text="Failed"
		end
	elseif t=="Progress" then
		local e=journal:FindFirstChild(data.questId)
		if e then
			local bg=e:WaitForChild("ProgressBarBackground")
			local bar=bg:WaitForChild("ProgressBar")
			local txt=bg:WaitForChild("ProgressText")
			local frac=data.newValue/data.goal
			bar:TweenSize(UDim2.new(frac,0,1,0),"Out","Quad",0.2,true)
			txt.Text=("%d/%d"):format(data.newValue,data.goal)
		end
	elseif t=="Complete" then
		local e=journal:FindFirstChild(data.questId)
		if e then
			e.CompletedBadge.Visible=true
		end
	elseif t=="Fail" then
		local e=journal:FindFirstChild(data.questId)
		if e then
			local bg=e:WaitForChild("ProgressBarBackground")
			local txt=bg:WaitForChild("ProgressText")
			txt.Text="Failed"
			bg.BackgroundColor3=Color3.fromRGB(180,60,60)
		end
	elseif t=="Abandon" then
		local e=journal:FindFirstChild(data.questId)
		if e then e:Destroy() end
	end
end)

UserInputService.InputBegan:Connect(function(i,gp)
	if gp then return end
	if i.KeyCode==Enum.KeyCode.Q then
		Action:FireServer("StartQuest",{questId="CollectHerbs"})
	elseif i.KeyCode==Enum.KeyCode.J then
		journal.Visible=not journal.Visible
	elseif i.KeyCode==Enum.KeyCode.X then
		Action:FireServer("AbandonQuest",{questId="CollectHerbs"})
	end
end)