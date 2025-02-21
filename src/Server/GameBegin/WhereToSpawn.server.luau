-- chooses the spawn

local arrayOfSpawn = workspace:WaitForChild("PossibleSpawns"):GetChildren()
local changeSpawnEvent = game:GetService("ReplicatedStorage"):WaitForChild("ChooseSpawn"):WaitForChild("Next")
local setPlayerCameraPosEvent = game:GetService("ReplicatedStorage"):WaitForChild("KeepCameraAt"):WaitForChild("Location")
local currentIndex = {}
local currentSpawnLocation = {}

local function processSpawnLocation(location : Instance,player : Player)
	currentSpawnLocation[player] = location.CFrame
	if not player then
		return
	end
	local cameraCFrame = location:WaitForChild("CamPos").CFrame
	setPlayerCameraPosEvent:FireClient(player,cameraCFrame,true)
end

changeSpawnEvent.OnServerEvent:Connect(function(player : Player,ToNext : boolean)
	if not player then
		return
	end
	currentIndex[player] +=  if ToNext then 1 else -1
	currentIndex[player] = currentIndex[player] % #arrayOfSpawn
	--print(currentIndex,#arrayOfSpawn)
	processSpawnLocation(arrayOfSpawn[currentIndex[player] + 1],player)
end)

local function setCollisionGroup(character : Model)
	for i, bodypart in pairs(character:GetChildren()) do
		if bodypart:IsA("BasePart") or bodypart:IsA("MeshPart") then
			bodypart.CollisionGroup = "Players"
		end
	end
end

script.Parent:WaitForChild("SpawnPlayer").Event:Connect(function()
	for i : Player,v : CFrame in pairs(currentSpawnLocation) do
		i.Character.Parent = workspace
		if not i.Character then
			i.CharacterAdded:Wait()
		end
		i.Character:PivotTo(v)
		i.Character:FindFirstChildOfClass("Humanoid").BreakJointsOnDeath = false
		setCollisionGroup(i.Character)
		local beginRagdoll : RBXScriptConnection = nil
		beginRagdoll = i.Character:FindFirstChildOfClass("Humanoid").Died:Connect(function()
			beginRagdoll:Disconnect()
			--print(i)
			script.Parent.RagdollCharacter:Fire(i.Character)
		end)
	end
	return
end)

game:GetService("Players").PlayerAdded:Connect(function(player)
	if not player.Character then
		player.CharacterAdded:Wait()
	end
	currentIndex[player] = 0
	processSpawnLocation(arrayOfSpawn[currentIndex[player] + 1],player)
end)
