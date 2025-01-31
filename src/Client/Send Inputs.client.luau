-- A script that handles where user input will be sent.

local UIS : UserInputService = game:GetService("UserInputService")

local currentReciever : BindableEvent = nil

UIS.InputBegan:Connect(function(input,gp)
	if gp then return end
	if currentReciever then
		currentReciever:Fire(input)
	end
end)