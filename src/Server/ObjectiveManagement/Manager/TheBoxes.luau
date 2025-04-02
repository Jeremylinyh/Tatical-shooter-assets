-- so probably comment the objectives first or smth idk yea

-- 1. Disable the black powerbox
-- 2. Defend the rest of the powerboxes
-- 3. Exfiltrate idk

local Objectives = workspace:WaitForChild("Level"):WaitForChild("Objectives")
local blackBox = Objectives:WaitForChild("Security"):WaitForChild("SecurityBox")
local optionOfBoxes = Objectives:WaitForChild("Required")

local markerTagName = "ObjectiveMarker"

local boxAllowInputTag = "BoxInput"

local function AddMarkerToList(list,inputTag)
	for i,v in ipairs(list) do
		v.Left.ArrowAttach:AddTag(markerTagName)
		v:AddTag(inputTag)
	end
end

local function removeMarkersFromList(list,inputTag,except)
	for i,v : Instance in ipairs(list) do
		if v == except then
			continue
		end
		v.Left.ArrowAttach:RemoveTag(markerTagName)
		v:RemoveTag(inputTag)
	end
end

-- WARNING: NOT TESTED
local function stageOne()
	blackBox:WaitForChild("Part").ArrowAttach:AddTag(markerTagName) -- give it the objective Arrow
	blackBox:AddTag(boxAllowInputTag) -- allow you to hold F
	blackBox:WaitForChild("FullyRewired").Event:Wait()

	blackBox:RemoveTag(boxAllowInputTag)	
	blackBox:RemoveTag(markerTagName)
	-- TODO: update the objective tracker UI
end

-- WARNING: NOT TESTED
local function stageTwo()
	local stageTwoFullyDone : BindableEvent = Instance.new("BindableEvent")

	local nextOBJlist = optionOfBoxes:GetChildren()
	AddMarkerToList(nextOBJlist,boxAllowInputTag)
	for i,box : Model in ipairs(nextOBJlist) do
		local boxOnChange : RBXScriptConnection
		boxOnChange = box.GetAttributeChangedSignal("On"):Connect(function()
			local boxOn = box:GetAttribute("On")
			if boxOn then
				blackBox:RemoveTag(boxAllowInputTag) -- don't turn it of that is silly
				removeMarkersFromList(nextOBJlist,boxAllowInputTag,boxOn) -- only on box need marker
			else
				blackBox:AddTag(boxAllowInputTag) -- Go fix it right now
			end
		end)
		box:WaitForChild("FullyRewired"):Connect(function()
			boxOnChange:Disconnect()
			box.Parent = Objectives.Irrelevant
			nextOBJlist = optionOfBoxes:GetChildren()
			if #nextOBJlist == 0 then
				stageTwoFullyDone:Fire()
			else
				AddMarkerToList(nextOBJlist,boxAllowInputTag)
			end
		end)
	end

	stageTwoFullyDone.Event:Wait()
end

local function OBJ()
	
	stageOne()
	stageTwo()
	-- TODO: finish the mission
end

return OBJ
