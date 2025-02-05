-- handles input recieved by the doors

local CS : CollectionService = game:GetService("CollectionService")

local doorActionTag : string = "DoorInput"

local function processInputEvent(reciever : BindableEvent)
	reciever.Event:Connect(function(input : InputObject)
		--print(input)
		if typeof(input) == "number" then
			reciever.Parent.Parent:WaitForChild("Push"):FireServer(input/6)
		else
			--it's a input event
			local keyboard : InputObject = input
			if keyboard.KeyCode == Enum.KeyCode.F then
				reciever.Parent.Parent:WaitForChild("Use"):FireServer()
			end
		end
	end)
end

for i,v : BindableEvent in CS:GetTagged(doorActionTag) do
	processInputEvent(v)
end

CS:GetInstanceAddedSignal(doorActionTag):Connect(processInputEvent)