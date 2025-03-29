-- Determine if the player can be seen
-- parent to bindable function

-- Enemy attributes:
-- Armed : boolean
--    if this is false, the npc can ambush the player anyways by pulling out a pistol/phone
-- currentState : Int -- reserved field, default to 0
-- canBeShot : boolean -- wether the ROE allow shooting the NPC
-- alerted : boolean -- if already alerted
-- Tag: suspect 

local characters = {}
local players : Players = game:GetService("Players")
players.PlayerAdded:Connect(function(player)
	local char : Model = player.Character or player.CharacterAdded:Wait()
	--print(char)
	table.insert(characters,char)
end)

local function castRayToTarget(NPC : Model,start : Vector3, finish: Vector3) : RaycastResult
	local params : RaycastParams = RaycastParams.new()
	params.FilterDescendantsInstances = {NPC}
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.CollisionGroup = "Eyesight" -- TODO: create

	return workspace:Raycast(start, finish-start, params)
	end

local function seenBodyPart(NPC : Model,bodyPart) : boolean
		
	local real = {}
	real[-1] = -1
	real[0] = 1
	real[1] = 0
	local NPCCF = NPC:GetPivot()
	for index = 0, 0 do
		if not NPC or not NPC:FindFirstChild("Humanoid") or NPC.Humanoid.Health <= 0 then
			return
		end
		local i = real[index]
		local startPos : Vector3 = NPCCF.Position + Vector3.yAxis * 1.6
		startPos += i * NPCCF.RightVector * 1.6
		local endPos : Vector3 = bodyPart.Position
		endPos += i * bodyPart.CFrame.RightVector

		local result : RaycastResult = castRayToTarget(NPC,startPos,endPos)
		--print(result)
		if not result then
			--return true -- no obstacle
		elseif result.Instance.Parent == bodyPart.Parent then
			return true,i
		end
		wait()
		
	end

	return false
end

local function sawPlayer(NPC: Model,playerCharacter : Model)
	local seen : boolean,a = seenBodyPart(NPC,playerCharacter:WaitForChild("Head"))
	if seen then
		return seen,a
	end
	wait()
	local seen : boolean,a = seenBodyPart(NPC,playerCharacter:WaitForChild("UpperTorso"))
	if seen then
		return seen,a
	end
	wait()
	--local seen : boolean,a = seenBodyPart(NPC,playerCharacter:WaitForChild("LowerTorso"))
	--if seen then
	--	return seen,a
	--end
	--wait()
	return false
end

-- return player character if it can be seen (return the first one seen)
local function SeeingPlayer(NPC: Model) : Model
	local pivot : CFrame = NPC:GetPivot()
	
	for i,v : Model in pairs(characters) do
		if not v then
			table.remove(characters,table.find(characters,v))
			return
		end
		
		local target : Vector3 = v:GetPivot().Position
		local difference : Vector3 = target - pivot.Position
		difference = difference.Unit
		--print("facing")
		if true or difference:Dot(pivot.LookVector) > 0 then -- nasty bypass
			
			local seen : boolean,a = sawPlayer(NPC,v)
			if seen then
				NPC:SetAttribute("Alerted",true)
				return v,a
			end
		end
		wait()
	end
	return false
end

script:WaitForChild("SeenPlayer").OnInvoke = SeeingPlayer


