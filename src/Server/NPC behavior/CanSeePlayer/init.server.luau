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

local function seenBodyPart(NPC : Model,bodyPart,hip) : boolean
		
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
		local startPos : CFrame = NPCCF
		if not hip then
			startPos *= CFrame.new(Vector3.yAxis * 1.6)
		end
		startPos *= CFrame.new(i * NPCCF.RightVector * 1.6)
		local endPos : Vector3 = bodyPart.CFrame
		if bodyPart.Name == "Head" then
			endPos *= CFrame.new(i * bodyPart.CFrame.RightVector  * 0.4)
		else
			endPos *= CFrame.new(i * bodyPart.CFrame.RightVector)
		end
		--endPos *= CFrame.new(i * bodyPart.CFrame.RightVector  * 0.4)
		local result : RaycastResult = castRayToTarget(
			NPC,
			startPos.Position,
			endPos.Position
		)
		--print(result)
		if not result then
			--return true,i -- no obstacle
		elseif result.Instance.Parent == bodyPart.Parent then
			return true,i
		end
		wait()
		
	end

	return false
end

local function sawPlayer(NPC: Model,playerCharacter : Model,hip)
	
	local seen : boolean,a = seenBodyPart(NPC,playerCharacter:WaitForChild("UpperTorso"),hip)
	if seen then
		return seen,a
	end
	wait()
	if not hip then
		local seen : boolean,a = seenBodyPart(NPC,playerCharacter:WaitForChild("Head"),hip)
		if seen then
			return seen,a,true
		end
		wait()
	end
	--local seen : boolean,a = seenBodyPart(NPC,playerCharacter:WaitForChild("LowerTorso"))
	--if seen then
	--	return seen,a
	--end
	--wait()
	return false
end

-- return player character if it can be seen (return the first one seen)
local function SeeingPlayer(NPC: Model,hip : boolean) : Model
	local pivot : CFrame = NPC:GetPivot()
	
	for i,v : Model in pairs(characters) do
		if not v then
			table.remove(characters,table.find(characters,v))
			return
		end
		
		if not (v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0) then
			table.remove(characters,i)
			continue
		end
		
		local target : Vector3 = v:GetPivot().Position
		local difference : Vector3 = target - pivot.Position
		difference = difference.Unit
		--print("facing")
		if true or difference:Dot(pivot.LookVector) > 0 then -- nasty bypass
			
			local seen : boolean,a,head = sawPlayer(NPC,v,hip)
			if seen then
				NPC:SetAttribute("Alerted",true)
				return v,a,head
			end
		end
		wait()
	end
	return false
end

script:WaitForChild("SeenPlayer").OnInvoke = SeeingPlayer


