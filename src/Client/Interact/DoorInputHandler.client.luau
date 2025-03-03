-- handles input recieved by the doors

local CS : CollectionService = game:GetService("CollectionService")

local doorActionTag : string = "DoorInput"

local function processInputEvent(reciever : BindableEvent)
	local doorModel : Model = reciever.Parent.Parent
	reciever.Event:Connect(function(input : InputObject)
		--print(input)
		if typeof(input) == "number" then
			doorModel:WaitForChild("Push"):FireServer(input/6)
		else
			--it's a input event
			local keyboard : InputObject = input
			if keyboard.KeyCode == Enum.KeyCode.F then
				doorModel:WaitForChild("Use"):FireServer()
			end
		end
	end)
end

for i,v : BindableEvent in CS:GetTagged(doorActionTag) do
	processInputEvent(v)
end

CS:GetInstanceAddedSignal(doorActionTag):Connect(processInputEvent)