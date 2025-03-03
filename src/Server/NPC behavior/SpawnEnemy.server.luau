-- Handles spawning NPC
-- When a new NPC spawn, it is parented to workspace
-- A target is selected for the lifetime of the NPC

-- literally a script I drafted in google docs during class lol

local Players : Players = game:GetService("Players")

local EnemyRandom : Random = Random.new()
local activeNPCcount : number = 0
local isLoud : boolean = false

local waitBetweenEachSpawning = 3
local maxActiveAllowed = 8

Players.PlayerAdded:Connect(function(player)
	player:SetAttribute("Threat",3)
end)

local function getThreatLevel(player : Player)
	return player:GetAttribute("Threat")
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
		if not v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
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

local function SetupSquad(spawnPart : Part)
	local squadMembers = {}
	local indidualSpawn = spawnPart:GetChildren()
	local squadCount = #indidualSpawn
	
	for count = 1, squadCount, 1 do
		local NPC : Model = selectEnemyTemplate()
		NPC.Parent = workspace
		NPC.Parent = workspace
		NPC:PivotTo(indidualSpawn[count].WorldCFrame)
		table.insert(squadMembers,NPC)
	end

	
	return squadMembers
end

-- select the random active one
local function selectSpawnPart(target : CFrame) : Part
	local spawnList = workspace:WaitForChild("EnemySpawns"):WaitForChild("Active"):GetChildren()
	return spawnList[EnemyRandom:NextInteger(1,#spawnList)]
end

game:GetService("ServerScriptService"):WaitForChild("GlobalStates"):WaitForChild("LoudBegin").Event
	:Connect(function()
	isLoud = true
	while isLoud do
			local target : Player = IdentifyTarget()
			local members = SetupSquad(selectSpawnPart(target)) 
		
		script.Parent:WaitForChild("EnemySquadBehaviorInit"):Fire(members,target)
		--print(#members)
		for i,v in pairs(members) do
			activeNPCcount += 1
			local death
			death = v.Humanoid.Died:Connect(function()
				death:Disconnect()
				activeNPCcount -= 1
			end)
		end
		
		wait(waitBetweenEachSpawning)
		--print(activeNPCcount)
		while activeNPCcount >= maxActiveAllowed do
				wait(waitBetweenEachSpawning)
			--print(activeNPCcount,"no longer spawning")
		end
	end
end)

