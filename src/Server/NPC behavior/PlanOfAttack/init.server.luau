-- engage the enemy I mean player

local Players : Players = game:GetService("Players")
local helper = require(game:GetService("ReplicatedStorage"):WaitForChild("Helper"))
local characterStats = require(game:GetService("ReplicatedStorage").Player:WaitForChild("PlayerStats"))

local animations = {}
local currentlyPlaying = {}

local function loadAnimations(v : Model)
	local memberAnimation = {}
	memberAnimation.Walk = helper.loadAnimationFromID(characterStats.WalkAnim,v.Humanoid
		:WaitForChild("Animator"))
	memberAnimation.Crouch = helper.loadAnimationFromID(characterStats.CrouchAnim,v.Humanoid.Animator)
	animations[v] = memberAnimation
	currentlyPlaying[v] = memberAnimation.Walk
end

local function attackLoop(NPC : Model,target : Model) 
	local waypoints = script.Parent["Compute path"].Execute:Invoke(NPC,target:GetPivot())
	if not (waypoints and #waypoints > 3) then
		wait(3)
		return
	end
	script.Parent.CalmlyWalkToPoint.Execute:Invoke(NPC,waypoints)
	local playerSeen : Model = script.Parent.CanSeePlayer.SeenPlayer:Invoke(NPC)
	while playerSeen do
		print("playerSeen")
		wait(6) -- TODO: sync this time with attack loop
		-- let the gun take care of itself
		playerSeen = script.Parent.CanSeePlayer.SeenPlayer:Invoke(NPC)
	end
end

local function individualNPCCommand(NPC : Model,target : Model)
	local humanoid : Humanoid = NPC:FindFirstChild("Humanoid")
	if not humanoid then
		return
	end
	local NPCdeath : RBXScriptConnection
	NPCdeath = humanoid.Died:Connect(function()
		NPCdeath:Disconnect()
		game:GetService("ServerScriptService").GameBegin.RagdollCharacter:Fire(NPC)
		return
	end)
	
	while humanoid.Health > 0 do
		if target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
			attackLoop(NPC,target)
			
		else
			-- get a new target or smth idk
			humanoid.Health = 0
		end
	end
end

local function init(members, player : Player)
	local target = player.Character
	if not target then
		for i,v in pairs(members) do
			v:Destroy()
		end
		return
	end
	--local waypoints = {}
	--local noPlayerSeen = true
	--local playerSeenEvent : BindableEvent = Instance.new("BindableEvent")
	
	for i,v in pairs(members) do
		local deathConnection : RBXScriptConnection
		deathConnection = v.Humanoid.Died:Connect(function()
			deathConnection:Disconnect()
			deathConnection = nil
			table.remove(members,table.find(members,v))
		end)
	end
	
	
		
		
	for i,v in pairs(members) do
		
	
	
		if not v:FindFirstChild("Humanoid") then
			v:Destroy()
			table.remove(members,table.find(v))
			continue
		end
		loadAnimations(v)
		local wrapped = coroutine.wrap(individualNPCCommand)
	    wrapped(v,player.Character)
		
	end
		
		
end

script:WaitForChild("Init").Event:Connect(init)