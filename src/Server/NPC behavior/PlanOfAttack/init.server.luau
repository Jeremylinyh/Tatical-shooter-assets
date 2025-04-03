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
	memberAnimation.Idle = helper.loadAnimationFromID(characterStats.IdleAnim,v.Humanoid.Animator)
	animations[v] = memberAnimation
	currentlyPlaying[v] = memberAnimation.Crouch
	local aimAnim = helper.loadAnimationFromID(
		(100272572157095),
		v.Humanoid.Animator,Enum.AnimationPriority.Action4,
		"Aim"
	)
	aimAnim:Play()
--	print(aimAnim.Priority)
end

local function attackLoop(NPC : Model,target : Model) 
	--print(target:GetPivot().Position)
	local waypoints = script.Parent.ComputePath.Execute:Invoke(NPC:GetPivot(),target:GetPivot())
	if not waypoints or not next(waypoints) then
		wait(3)
		return
	end
	if currentlyPlaying[NPC] ~= animations[NPC].Walk then
		currentlyPlaying[NPC]:Stop()
		currentlyPlaying[NPC] = animations[NPC].Walk
		--print(currentlyPlaying[NPC].Priority)
		currentlyPlaying[NPC]:Play()
	end
	script.Parent.CalmlyWalkToPoint.Execute:Invoke(NPC,waypoints)
	--print("walked")
	local playerSeen : Model = script.Parent.CanSeePlayer.SeenPlayer:Invoke(NPC)
	local canSeeWhenCrouch = (script.Parent.CanSeePlayer.SeenPlayer:Invoke(NPC,true))
	
	while playerSeen do
		local goalAnime = animations[NPC].Idle
		if canSeeWhenCrouch then
			goalAnime = animations[NPC].Crouch
		end
--		print(canSeeWhenCrouch,goalAnime == animations[NPC].Idle)
		if currentlyPlaying[NPC] ~= goalAnime then
			currentlyPlaying[NPC]:Stop()
			currentlyPlaying[NPC] = goalAnime
			currentlyPlaying[NPC]:Play()
		--elseif headOnly then
		--	currentlyPlaying[NPC]:Stop()
		--	currentlyPlaying[NPC] = animations[NPC].Idle
		end
		local humanoid : Humanoid = NPC.Humanoid
		humanoid.AutoRotate = false
		local difference = script.Parent.TooCloseToOther.Evaluate:Invoke(NPC) or Vector3.new()
		--print(difference)
		local startTime = time()
		if difference then
			--if currentlyPlaying[NPC] ~= animations[NPC].Walk then
			--	currentlyPlaying[NPC]:Stop()
			--	currentlyPlaying[NPC] = animations[NPC].Walk
			--	currentlyPlaying[NPC]:Play()
			--end
			--humanoid.AutoRotate = true
			humanoid:Move(difference) 
			wait(0.36)
			humanoid:Move(Vector3.zero)
			humanoid.AutoRotate = false
			--if currentlyPlaying[NPC] ~= animations[NPC].Crouch then
			--	currentlyPlaying[NPC]:Stop()
			--	currentlyPlaying[NPC] = animations[NPC].Crouch
			--	currentlyPlaying[NPC]:Play()
			--end
		end
		--wait(6) -- TODO: sync this time with attack loop
		-- let the gun take care of itself
		
		for i = 1, 3, 1 do
			task.wait(1)
			local goalAnime = animations[NPC].Idle
			if canSeeWhenCrouch then
				goalAnime = animations[NPC].Crouch
			end
			--		print(canSeeWhenCrouch,goalAnime == animations[NPC].Idle)
			if currentlyPlaying[NPC] ~= goalAnime then
				currentlyPlaying[NPC]:Stop()
				currentlyPlaying[NPC] = goalAnime
				currentlyPlaying[NPC]:Play()
				--elseif headOnly then
				--	currentlyPlaying[NPC]:Stop()
				--	currentlyPlaying[NPC] = animations[NPC].Idle
			end
		end
		
		playerSeen = script.Parent.CanSeePlayer.SeenPlayer:Invoke(NPC)
		canSeeWhenCrouch = (script.Parent.CanSeePlayer.SeenPlayer:Invoke(NPC,true))
	end
	script.Parent:WaitForChild("Reload"):WaitForChild("Begin"):Fire(NPC)
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
			--print("looping attack")
			attackLoop(NPC,target)
			--return
		else
			-- get a new target or smth idk
			--humanoid.Health = 0
			wait(1)
			target = workspace.Level.Players:GetChildren()[1]
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