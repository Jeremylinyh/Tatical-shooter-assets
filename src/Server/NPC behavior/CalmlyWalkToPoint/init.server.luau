-- This script have one job: move to the goal, return when done

local blindnessRandom : Random = Random.new()
local movesBeforeReCompute = 16
local variationSize = 6

local reactionTime = 0.36

-- return most optimal direction to adjust
-- how I think it should work is loop through all NPC
-- actually maybe I make another script with memoization or something idk
local function tooCloseToAnotherNPC(character) : Vector3
	return script.Parent.TooCloseToOther.Evaluate:Invoke(character)
end

local function variedFinish(humanoid : Humanoid,waypoints,index)
	--local prevW : Vector3 = waypoints[index].Position
	--local nextW : Vector3 = waypoints[index + 1].Position
	
	--if prevW and nextW then
	--	local nextPos = prevW:Lerp(nextW,blindnessRandom:NextNumber())
	--	humanoid:MoveTo(nextPos)
	--	humanoid.MoveToFinished:Wait()
	--else
	--	return
	--end
	
	local adjustment : Vector3 = tooCloseToAnotherNPC(humanoid.Parent)
	if adjustment then
		--reachedConnection:Disconnect()
		-- move away
		humanoid:MoveTo(humanoid.Parent:GetPivot().Position + adjustment)
		humanoid.MoveToFinished:Wait()
	end
end

local function followPath(character,waypoints)
	--local variation : number = blindnessRandom:NextInteger(0,variationSize)
	
	--local continueUntil = movesBeforeReCompute + (variation)
	
	local continueUntil = #waypoints --math.min(continueUntil,#waypoints-1)
	
	local nextWaypointIndex
	local reachedConnection : RBXScriptConnection
	
	local humanoid : Humanoid = character:WaitForChild("Humanoid")
	humanoid.AutoRotate = true
	-- Detect when movement to next waypoint is complete
	if not reachedConnection then
		reachedConnection = humanoid.MoveToFinished:Connect(function(reached)
			--print("next")
			
			
			--print(playerSeen)
			
			if reached and (nextWaypointIndex == continueUntil) then
				reachedConnection:Disconnect()
				variedFinish(humanoid,waypoints,nextWaypointIndex)
				return
			end
			--print(waypoints[nextWaypointIndex])
			if reached and nextWaypointIndex < continueUntil and waypoints[nextWaypointIndex] then
				-- Increase waypoint index and move to next waypoint
				nextWaypointIndex += 1
				humanoid:MoveTo(waypoints[nextWaypointIndex].Position)
			else
				reachedConnection:Disconnect()
				--blockedConnection:Disconnect()
				--wait(1)
				if not reached then
					--print("try again")
					return
			--script.Begin:Fire(character,waypoints)
				end
				return reached
			end
		end)
	end
	
	-- Initially move to second waypoint (first waypoint is path start; skip it)
	nextWaypointIndex = 1
	--print(waypoints[0],waypoints[1])
	humanoid:MoveTo(waypoints[nextWaypointIndex].Position)
	while reachedConnection and reachedConnection.Connected do
		wait(reactionTime)
		local playerSeen : boolean = 

			script.Parent.CanSeePlayer.SeenPlayer:Invoke(character)
	--print(playerSeen)
		if playerSeen then
			reachedConnection:Disconnect()
			wait(blindnessRandom:NextNumber())
			--local difference = tooCloseToAnotherNPC(character) or Vector3.new()
			humanoid:MoveTo(humanoid.Parent:GetPivot().Position) -- stay still
		end
		
		--local adjustment : Vector3 = tooCloseToAnotherNPC(character)
		--if adjustment then
		--	reachedConnection:Disconnect()
		--	-- move away
		--	humanoid:MoveTo(humanoid.Parent:GetPivot().Position + adjustment)
		--	humanoid.MoveToFinished:Wait()
		--end
	end
	return
end

script:WaitForChild("Execute").OnInvoke = followPath