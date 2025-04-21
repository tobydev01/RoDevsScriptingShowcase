local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RS                = ReplicatedStorage:WaitForChild("DungeonFramework")
local Modules           = RS:WaitForChild("Modules")

require(Modules:WaitForChild("DungeonManager"))

require(script:WaitForChild("DungeonServer"))

require(script:WaitForChild("DungeonReplicationManager"))

require(script:WaitForChild("MessagingHandler"))