-- Handles spawning NPC
-- When a new NPC spawn, it is parented to workspace
-- A target is selected for the lifetime of the NPC

-- literally a script I drafted in google docs during class lol

local Players : Players = game:GetService("Players")

local EnemyRandom : Random = Random.new()
local activeNPCcount : number = 0
local isLoud : boolean = false

Players.PlayerAdded:Connect(function(player)
	player:SetAttribute("Threat",0.5)
end)

local function getThreatLevel(player : Player)
	return player:GetAttribute("Threat",0.5)
end


local function getDistance(NPCPos : CFrame,character : Model)
	local difference = NPCPos.Position - character:GetPivot().Position
	return math.dot(difference,difference)
end

local function IdentifyTarget() : Model
	local totalThreatValue : number = 0
	local interval = {}
	local PlayerList = Players:GetPlayers()

	-- Ensure there is at least one player
	if #PlayerList == 0 then
		return nil
	end

	for i,v : Player in PlayerList do
		if not v.Character then
			continue
		end
		local threat = math.abs(getThreatLevel(v))
		local threatInterval : Vector2 = Vector2.new(totalThreatValue, totalThreatValue + threat)
		totalThreatValue = threatInterval.Y
		table.insert(interval,threatInterval)
	end

	local pickNumber : number = math.abs(EnemyRandom:NextNumber()  * totalThreatValue)
	for i : number,v : Vector2 in ipairs(interval) do
		local lower : number = v.X
		local upper : number = v.Y
		if pickNumber >= lower and pickNumber < upper then
			return PlayerList[i]
		end
	end
	return PlayerList[1]
end

local function selectEnemyTemplate() : Model
	return game:GetService("ServerStorage"):WaitForChild("NPC"):WaitForChild("Assault").Enemy:Clone()
end

local function SetupSquad(spawnAt : CFrame,squadCount : number)
	if not squadCount then
		squadCount = 4
	end	

	local target : Player = IdentifyTarget()
	local squadMembers = {}
	
	local NPC : Model = selectEnemyTemplate()
	
	for count = 0, squadCount, 1 do
		
		NPC.Parent = workspace
		NPC:PivotTo(spawnAt)
		table.insert(squadMembers,NPC)
	end

	if not target or not target.Character then
		NPC : Destroy()
		return
	end
	return squadMembers, target
end

-- select the random active one
local function selectSpawnPart(target : CFrame) : Part
local spawnList = workspace:WaitForChild("EnemyDeploymentLocations"):WaitForChild("Active"):GetChildren()
return spawnList[EnemyRandom:NextInteger(1,#EnemyRandom)]
end

game:GetService("ReplicatedStorage"):WaitForChild("GameState"):WaitForChild("LoudBegin"):Connect(function()
	isLoud = true
	while isLoud do
		local members,target = SetupSquad() 
		if not members or #members <= 0 or not target or not target.Character then
			return
		end
		local spawnSquadAt : Part = selectSpawnPart(target.Character:GetPivot())
		for i,v : Attachment in spawnSquadAt:GetChildren() do
			members[i].Parent = workspace
			members[i]:PivotTo(v.WorldCFrame)
		end
		script.Parent:WaitForChild("EnemySquadBehavior"):Fire(members,target)
	end
end)

