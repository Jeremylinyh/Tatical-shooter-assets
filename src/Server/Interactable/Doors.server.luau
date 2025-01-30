-- The script that define the Door class
--
-- When placing doors, place them in the closed position

-- Type explanation:
-- Chance of being locked: 0-1, when game start, how likely is the door locked?
-- Closed: is the door currently closed? 
-- ClosedCFrame : how to position the door when it is closed?
-- Lock Direction: which side (-1,0,1) would be locked? 0 = neither
-- HowFarLeft : how far to open to the left, in degrees (same goes for right) (left and right dictated by the rightvector)
-- Usedby : who is using it?
-- InitialDirection : if the door is to start open, what direction to open in? (0 = start closed)
-- Transition_Speed : how fast auto open is?


local CS : CollectionService = game:GetService("CollectionService")
local Security = require(game:GetService("ServerScriptService"):WaitForChild("SecOps"):WaitForChild("Main"))
local DoorRandom : Random = Random.new()
local doorAngle : number = 0
local classname : string = "Door"

-- check wether it is a door
local function isDoor(possiblyDoor : Model) : boolean
	return CS:HasTag(possiblyDoor,classname)
end

-- player is able to use doors, and the door is a door (in terms of SecOps)
local function doorCanBeUsed(player : Player, door : Model) : boolean
	if not player then
		return false -- function breaking condition
	end
	local result : boolean = Security.PlayerInRange(player,door:GetPivot().Position)
	result = result and isDoor(door)
	return result
end

-- The door can be moved (in terms of gameplay)
local function doorCanBeMoved(door : Model) : boolean
	return not door:GetAttribute("Locked") and door:GetAttribute("Usedby") == ""
end

local function direction_from_user_position(door : Model, user : CFrame) : number
	local difference = door:GetPivot().Position - user.Position
	return math.sign(door:GetPivot().LookVector:Dot(difference.Unit))
end

local function determine_target_angle(door : Model, direction : number) : number
	if door:GetPivot() ~= door:GetAttribute("ClosedCFrame") then
		return 0
	end
	
	local target_angle = door:GetAttribute("HowFarLeft")
	if (direction < 0 or target_angle == 0) and not (door:GetAttribute("HowFarRight") == 0) then
		-- if both are 0, then it would be expected behavior regardless (probably right?)
		target_angle = door:GetAttribute("HowFarRight") 
	end
	return target_angle
end

-- open the indicated door
local function useDoor(door : Model,direction : number,user : string) : nil
	-- check that the door can be used, and prevent re-use
	if not doorCanBeMoved(door) or direction == 0 then
		return
	end
	if user then
		door:SetAttribute("Usedby",user)
	else
		door:SetAttribute("Usedby","Enemy")
	end
	door.Center.CanCollide = false
	
	local target_angle = determine_target_angle(door,direction)
	
	-- tween a cframe (this should be less verbose lol)
	local interploant : CFrameValue = Instance.new("CFrameValue")
	interploant.Value = door:GetPivot() -- initial value
	local goal = {}
	goal.Value = door:GetAttribute("ClosedCFrame") * CFrame.Angles(0,target_angle,0)
	
	local tween : Tween = game:GetService("TweenService"):Create(interploant,TweenInfo.new(door:GetAttribute("Transition_Speed")),goal)
	
	interploant.Changed:Connect(function(value)
		door:PivotTo(value)
	end)
	tween:Play()
	tween.Completed:Wait()
	interploant:Destroy()
	door:PivotTo(door:GetAttribute("ClosedCFrame") * CFrame.Angles(0,target_angle,0))
	
	-- clean up
	door:SetAttribute("Usedby","")
	door.Center.CanCollide = true
end

-- The entry point to this "class"

-- connect the indicated function
local function connectEvents(door : Model) : nil
	-- connecting useDoor
	local openDoorRemote : RemoteEvent = door:WaitForChild("Use")
	openDoorRemote.OnServerEvent:Connect(function(player : Player)
		if not doorCanBeUsed(player,door) then
			return -- we be cautious, we trust our own script, but not the client
		end
		--door:SetAttribute("Usedby",player.Name)
		useDoor(door,direction_from_user_position(door,player.Character:GetPivot()))
	end)
	local openDoorBindable : BindableEvent = openDoorRemote:WaitForChild("BindableEvent")
	openDoorBindable.Event:Connect(useDoor)
	
end

-- set default information such as wether the door is locked
local function initiateDoor(door : Model) : nil
	door:SetAttribute("ClosedCFrame", door:GetPivot() )
	local rng : number = DoorRandom:NextNumber()
	door:SetAttribute("Locked",rng < door:GetAttribute("Chance_of_being_locked"))
	door:SetAttribute("HowFarLeft",math.rad(door:GetAttribute("HowFarLeft")))
	door:SetAttribute("HowFarRight",math.rad(door:GetAttribute("HowFarRight")))
	useDoor(door,door:GetAttribute("InitialDirection"))
	-- TODO: continue implement
end

-- run everything
for i,door : Model in pairs(CS:GetTagged(classname)) do
	connectEvents(door)
	initiateDoor(door)
end