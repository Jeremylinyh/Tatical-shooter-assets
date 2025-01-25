-- A script to handle per frame data gathering.
--
-- turns on appoporite GUI

local RS : RunService = game:GetService("RunService")
local Players : Players = game:GetService("Players")
local CAS : ContextActionService = game:GetService("ContextActionService")
local TS : TweenService = game:GetService("TweenService")
local PlayerStats = require(game:GetService("ReplicatedStorage"):WaitForChild("Player"):WaitForChild("PlayerStats") )

local camera : Camera = workspace.CurrentCamera
local previousParent = nil
local onBreak : boolean = false

-- fire the remote event 
local function OpenDoor(actionName : string, inputState : Enum.UserInputState, input : InputObject)
	if not previousParent or inputState == Enum.UserInputState.End or actionName ~= "OpenDoor" or input.KeyCode == Enum.KeyCode.Unknown then
		return
	end
	previousParent:WaitForChild("Use"):FireServer()
end

-- we must remain dry lol
local function processTextLabel(textlabel : TextLabel,becomeVisible : boolean)
	if not textlabel then
		return
	end
	textlabel.Visible = true
	
	local direction = if becomeVisible then 1 else 0
	local goal = {}
	goal.Size = UDim2.new(0,200 * direction,0,50)
	textlabel.Size = UDim2.new(0,200 * -(direction - 1),0,50)
	local sizetween = TS:Create(textlabel,TweenInfo.new(0.6),goal)
	sizetween:Play()
	sizetween.Completed:Connect(function()
		onBreak = false
	end)
	
end

-- display GUI on door (or remove it from door)
local function engageDoor(door : Model,becomeVisible : boolean)
	if not door then
		return
	end
	
	if becomeVisible then
		CAS:BindAction("OpenDoor",OpenDoor,true,Enum.KeyCode.F)
	else
		CAS:UnbindAction("OpenDoor")
	end
	
	local textlabel : TextLabel = door:WaitForChild("Center"):WaitForChild("Front"):WaitForChild("TextLabel")
	processTextLabel(textlabel,becomeVisible)
	textlabel = door:WaitForChild("Center"):WaitForChild("Back"):WaitForChild("TextLabel")
	processTextLabel(textlabel,becomeVisible)
end

-- IMPORTANT: to add future stuff to be detected, add it here
local function processItem(item,direction : boolean)
	if not item then
		return
	end
	if item:HasTag("Door") then
		engageDoor(item,direction) 
	end
	
	onBreak = true
end

-- cast a ray every frame and see what we find
RS.PreRender:Connect(function(delta)
	if (not Players.LocalPlayer) or (not Players.LocalPlayer.Character) or onBreak then
		return
	end
	
	local params : RaycastParams = RaycastParams.new()
	params.FilterDescendantsInstances = {Players.LocalPlayer.Character}
	params.FilterType = Enum.RaycastFilterType.Exclude
	
	local result : RaycastResult = workspace:Raycast(camera.CFrame.Position,camera.CFrame.LookVector * PlayerStats.ArmLength,params)
	if not result then
		processItem(previousParent,false) -- unvisible surface guis
		previousParent = nil
		return
	end
	local parent = result.Instance.Parent
	
	if parent == previousParent then
		-- nothing changed
		return
	end
	processItem(previousParent,false)
	processItem(parent,true) -- true = visible
	previousParent = parent
end)
