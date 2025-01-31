-- select the proximity prompt the player most likely wants

local CS : CollectionService = game:GetService("CollectionService")

local playerStats = require(game:GetService("ReplicatedStorage"):WaitForChild("Player"):WaitForChild("PlayerStats"))

local maxPromptDistance : number = playerStats.ArmLength

local promptTag : string = "ProxPrompt"
local previousShown = nil
local prompts = CS:GetTagged(promptTag)

--refresh if change occurs
CS:GetInstanceAddedSignal(promptTag):Connect(function()
	prompts = CS:GetTagged(promptTag)
end)

CS:GetInstanceRemovedSignal(promptTag):Connect(function()
	prompts = CS:GetTagged(promptTag)
end)

local function sortByDistance()
	local camera = workspace.CurrentCamera
	table.sort(prompts,function(a : Instance,b : Instance)
		local distanceToA : number = (a.CFrame.Position * Vector3.new(1,0,1) - camera.CFrame.Position * Vector3.new(1,0,1)).Magnitude
		local distanceToB : number = (b.CFrame.Position * Vector3.new(1,0,1) - camera.CFrame.Position * Vector3.new(1,0,1)).Magnitude
		return distanceToA > distanceToB
	end)
end

local function selectCurrentPrompt()
	local currentSelected : Instance = nil
	local currentHighest : number = -math.huge
	for index = 1, 6, 1 do
		if not prompts[index] then
			break
		end
		local camera = workspace.CurrentCamera
		local distanceToPrompt = (prompts[index].Position * Vector3.new(1,0,1) - camera.CFrame.Position * Vector3.new(1,0,1)).Magnitude
		if distanceToPrompt < maxPromptDistance then
			local tocamera : Vector3 = prompts[index].Position - camera.CFrame.Position
			local alignment : number = camera.CFrame.LookVector:Dot(tocamera.Unit)
			if alignment > currentHighest then
				currentHighest = alignment
				currentSelected = prompts[index]
			end
		end


	end
	return currentSelected
end

local function alignmentTest()
	local currentSelected : Instance = selectCurrentPrompt()
	
	if previousShown == currentSelected then
		return
	end
	
	if previousShown then
		previousShown.SurfaceGui.TextLabel.Size = UDim2.new()
		previousShown = nil
	end
	
	if currentSelected then
		currentSelected.SurfaceGui.TextLabel.Size = UDim2.new(1,0,0.8,0)
		previousShown = currentSelected
		--print(currentSelected)
	end
end

while true do
	-- sort by distance
	sortByDistance()
	for i = 1, 10 , 1 do
		alignmentTest()
		wait(0.3)
	end
end