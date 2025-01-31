-- A script that handles where user input will be sent.

local UIS : UserInputService = game:GetService("UserInputService")

local currentReciever : BindableEvent = nil

UIS.InputBegan:Connect(function(input,gp)
	if gp then return end
	if currentReciever then
		currentReciever:Fire(input)
	end
end)

UIS.PointerAction:Connect(function(wheel, _pan, _pinch, processed)
	if processed then
		return
	end
	
	if currentReciever then
		currentReciever:Fire(wheel)
	end
end)

script.SetCurrentReciever.Event:Connect(function(reciever : BindableEvent)
	currentReciever = reciever
end)