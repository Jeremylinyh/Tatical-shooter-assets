-- A script to handle objective updates recieved on the client.

-- this script expect to recieve titleName string, list of objectives (strings)
-- expect frameTemplate to have anchorpoint of 0,1
-- expect stepTemplate to have anchorpoint of 0,1

-- how this is set up is that the frame does not clip descendants. 
-- a child frame will clip descendants and have a Y scale of 1
-- the child frame will be parent of the steps, but not the title.

local UIS : UserInputService = game:GetService("UserInputService")
local player : Player = game:GetService("Players").LocalPlayer
local TS : TweenService = game:GetService("TweenService")

local OBJSwitchSpeed = 0.36
local prevObj : Enum.Keycode = Enum.Keycode.LeftBracket
local nexObj : Enum.Keycode = Enum.Keycord.RightBracket

local objTextHeight = 100 -- Offset for now idk
local addObjective : RemoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("Objective"):WaitForChild("AddObjective")
local Root : Frame = player.PlayerGui:WaitForChild("HUD"):WaitForChild("ObjectiveDisplayFrame")

local frameTemplate : Frame = script.Frame
local tradeMarkedEntryPointGrayLol : Color3 = Color3.new(0.1,0.1,0.1)
local stepTemplate : TextLabel = script.TextLabel

local currentIndex = 1
local tabTween = {}
local lastAddedStep = {}

local function addSet(title : String) : Frame
	local newOBJ = frameTemplate:Clone()
	if #Root:GetChildren() > 0 then
		local currentStep = Root
		local prevStep = nil

		while currentStep do
			prevStep = currentStep
			currentStep = currentStep:FindFirstChild("Next")
		end
		newOBJ.Parent = prevStep
		--newOBJ.Parent = Root:GetChildren()[#Root:GetChildren()] -- last item
		-- /\ the purpose of this is that when you swap the objectives
		-- if it uses anchor point, everything under it gets moved full auto
	else
		-- so this is the first thing then
		newOBJ.Parent = Root
	end
	newOBJ:WaitForChild("Title").Text = title
	local shadow = newOBJ.Title:Clone()
	shadow.TextColor = tradeMarkedEntryPointGrayLol
	shadow.Parent = newOBJ.Title
	local originalUdim = newOBJ.Title.Position
	shadow.Size = UDim2.new(1,0,1,0)
	shadow.Position = UDim2.new(0,2,0,-2)
	newOBJ.Name = "Next" -- in effect, this is a linked list

	return newOBJ
end

local function addStep(partOf,stepText : String)
	local index : number = #partOf:GetChildren()
	local step : TextLabel = stepTemplate:Clone()
	step.Parent = partOf
	step.Position = UDim2.new(0,0,0,index * objTextHeight)
	step.Text = stepText

	local shadow : TextLabel = step:Clone()
	shadow.TextColor = tradeMarkedEntryPointGrayLol
	shadow.Parent = step
	shadow.Size = UDim2.new(1,0,1,0)
	shadow.Position = UDim2.new(0,2,0,-2)
end

local function tweenToGoalSize(UI,target : number)
	local goal = {}
	goal.Size = UDim2.new(UI.Size.X.Scale,UI.Size.X.Offset,0,target)
	local info : TweenInfo = TweenInfo.new(OBJSwitchSpeed)
	local T : Tween = TS:Create(UI,info,goal)
	if tabTween[UI] then
		tabTween[UI]:Stop()
	end
	tabTween[UI] = T
	T:Play()
end

local function closeAllExcept(except : number)
	local counter = 0 -- imagine starting with 1, cringe
	local currentStep = Root
	currentStep = currentStep:FindFirstChild("Next")
	while currentStep do
		local step = currentStep
		if counter == except then 
			-- expand
			tweenToGoalSize(step,step.Title.Size.Y.Offset + #step:GetChildren() * objTextHeight)
		else
			-- close
			tweenToGoalSize(step,step.Title.Size.Y.Offset)
		end
		currentStep = currentStep:FindFirstChild("Next")
	end
end

local function completeObjective(parent,title : string,success : boolean)
	-- TODO: implement
	local target : TextLabel = parent:FindFirstChild(title)
	if not target then return end
	if success then
		target.Text = target.Text .. " - Completed"
	else
		target.Text = target.Text .. " - Failed"
	end
end

addObjective.OnClientEvent:Connect(function(title : string, objectives,Success)
	local insertTo : Frame = Root:FindFirstChild(title)
	if not insertTo then
		insertTo = addSet(title)
	end
	--for i, step : String in ipairs(objectives) do
	--	addStep(insertTo.Steps,step) -- no custom type checking bruh
	--end
	addStep(insertTo.Steps,objectives)
	if lastAddedStep[title] then
		completeObjective(insertTo.Steps,lastAddedStep[title],Success)
	end
	lastAddedStep[title] = objectives
end)

UIS.InputBegan:Connect(function(input,gp)
	if gp then return end
	if not player.Character or player.Character:FindFirstChild("Humanoid") then return end
	if not (player.Character.Humanoid.Health > 0) then return end
	if not (#Root:GetChildren() > 0) then return end

	if input.KeyCode == prevObj then
		currentIndex += 1
	elseif input.KeyCode == nexObj then
		currentIndex -= 1
	else
		return
	end
	currentIndex = currentIndex % #Root:GetChildren()
	closeAllExcept(currentIndex)
end)

