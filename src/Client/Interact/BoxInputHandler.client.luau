-- handles input recieved by the boxes

local CS : CollectionService = game:GetService("CollectionService")

local doorActionTag : string = "BoxInput"

local function processInputEvent(powerBox : Model)
	local reciever = powerBox:WaitForChild("Left"):WaitForChild("ConnectInputs")
	local doorModel : Model = reciever.Parent.Parent
	reciever.Event:Connect(function(input : InputObject)
		--print(input)
		if typeof(input) == "number" then
			
		else
			--it's a input event
			local keyboard : InputObject = input
			if keyboard.KeyCode == Enum.KeyCode.F then
				doorModel:WaitForChild("Use"):FireServer()
			end
		end
	end)
end

for i,v : Model in CS:GetTagged(doorActionTag) do
	processInputEvent(v)
end

CS:GetInstanceAddedSignal(doorActionTag):Connect(processInputEvent)