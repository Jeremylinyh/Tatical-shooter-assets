-- A script to handle objective updates recieved on the client.

-- this script expect to recieve titleName string, list of objectives (strings)
-- expect frameTemplate to have anchorpoint of 0,1
-- expect stepTemplate to have anchorpoint of 0,1

-- how this is set up is that the frame does not clip descendants. 
-- a child frame will clip descendants and have a Y scale of 1
-- the child frame will be parent of the steps, but not the title.

-- made it a linked list, because it literally is a list that's linked. was that a good idea? maybe...

local UIS : UserInputService = game:GetService("UserInputService")
local player : Player = game:GetService("Players").LocalPlayer
local TS : TweenService = game:GetService("TweenService")

local OBJSwitchSpeed = 0.36
local prevObj : Enum.KeyCode = Enum.KeyCode.LeftBracket
local nexObj : Enum.KeyCode = Enum.KeyCode.RightBracket

local objTextHeight = 36 -- Offset for now idk
local addObjective : RemoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("Objective"):WaitForChild("AddObjective")
local Root : Frame = player.PlayerGui:WaitForChild("HUD"):WaitForChild("TrackerOBJDisplay")

local frameTemplate : Frame = script.Frame
local tradeMarkedEntryPointGrayLol : BrickColor = BrickColor.new(50/256,50/256,50/256)
local stepTemplate : TextLabel = script.TextLabel

local currentIndex = 0
local tabTween = {}
local lastAddedStep = {}

local currentOBJ : string = "CKG"

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
	local shadow : TextLabel = newOBJ.Title:Clone()
	shadow.TextColor = tradeMarkedEntryPointGrayLol
	shadow.Parent = newOBJ.Title
	local originalUdim = newOBJ.Title.Position
	shadow.Size = UDim2.new(1,0,1,0)
	shadow.Position = UDim2.new(0,2,0,2)
	shadow.ZIndex = -100
	shadow.AnchorPoint = Vector2.new()
	newOBJ.Name = "Next" -- in effect, this is a linked list

	return newOBJ
end

local function addStep(partOf,stepText : String)
	local index : number = #partOf:GetChildren() - 0.3
	local step : TextLabel = stepTemplate:Clone()
	step.Parent = partOf
	step.Position = UDim2.new(0,0,0,index * objTextHeight/2)
	step.Text = stepText
	step.Size = UDim2.new(1,0,0,objTextHeight)

	local shadow : TextLabel = step:Clone()
	shadow.TextColor = tradeMarkedEntryPointGrayLol
	shadow.Parent = step
	shadow.Size = UDim2.new(1,0,1,0)
	shadow.Position = UDim2.new(0,2,0,2)
	shadow.AnchorPoint = Vector2.new()
	shadow.ZIndex = -100
end

local function tweenToGoalSize(UI,target : number)
	local goal = {}
	goal.Size = UDim2.new(UI.Size.X.Scale,UI.Size.X.Offset,0,target)
	local info : TweenInfo = TweenInfo.new(OBJSwitchSpeed)
	local T : Tween = TS:Create(UI,info,goal)
	if tabTween[UI] then
		tabTween[UI]:Pause()
		tabTween[UI]:Destroy()
	end
	tabTween[UI] = T
	T:Play()
end

local function closeAllExcept(except : number)
	local counter = 0 -- imagine starting with 1, cringe
	local currentStep = Root
	currentStep = currentStep:FindFirstChild("Next")
	while currentStep do
		local step = currentStep.Steps
		if counter == except then 
			-- expand
			currentOBJ = currentStep.Title.Text
			tweenToGoalSize(currentStep,(#step:GetChildren()) * objTextHeight/2 + 6)
		else
			-- close
			tweenToGoalSize(currentStep,0)
		end
		currentStep = currentStep:FindFirstChild("Next")
		counter += 1
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

local function rootContains(title : string) : Frame
	local currentStep = Root

	while currentStep do
		currentStep = currentStep:FindFirstChild("Next")
		if currentStep and currentStep.Title.Text == title then
			return currentStep
		end
	end
	
	return nil
end

local function amountInRoot(title)
	local counter = -1
	local currentStep = Root
	while currentStep do
		currentStep = currentStep:FindFirstChild("Next")
		counter += 1
		if currentStep and currentStep.Title.Text == title then
			return counter
		end
	end
	return counter
end

addObjective.OnClientEvent:Connect(function(title : string, objectives,Success)
	--print(title,objectives)
	local insertTo : Frame = rootContains(title)
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
	closeAllExcept(currentIndex)
end)

UIS.InputBegan:Connect(function(input,gp)
	if gp then return end
	if not player.Character or not player.Character:FindFirstChild("Humanoid") then return end
	if not (player.Character.Humanoid.Health > 0) then return end
	if not (#Root:GetChildren() > 0) then return end

	if input.KeyCode == prevObj then
		currentIndex -= 1
	elseif input.KeyCode == nexObj then
		currentIndex += 1
	else
		return
	end
	currentIndex = currentIndex % (amountInRoot())
	--print(currentIndex)
	closeAllExcept(currentIndex)
end)

game:GetService("ReplicatedStorage").Objective.SwitchOBJ.OnClientEvent:Connect(function(title:string)
	currentIndex = amountInRoot(title) % (amountInRoot())
	closeAllExcept(currentIndex)
end)

script:WaitForChild("GetCurrentOBJ").OnInvoke = function()
	return currentOBJ
end