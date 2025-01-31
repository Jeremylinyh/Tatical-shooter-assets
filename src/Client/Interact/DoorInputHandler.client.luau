-- handles input recieved by the doors

local CS : CollectionService = game:GetService("CollectionService")

local doorActionTag : string = "DoorInput"

CS:GetInstanceAddedSignal(doorActionTag):Connect(function(reciever : BindableEvent)
	reciever.Event:Connect(function(input)
		
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
end)