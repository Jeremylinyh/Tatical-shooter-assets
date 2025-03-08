-- A script that handles where user input will be sent.

local UIS : UserInputService = game:GetService("UserInputService")
local player : Player = game:GetService("Players").LocalPlayer
local currentReciever : BindableEvent = nil

UIS.InputBegan:Connect(function(input,gp)
	if gp or player:GetAttribute("Interacting") then return end
	if currentReciever then
		--print(currentReciever:GetTags())
		currentReciever:Fire(input)
	end
end)

UIS.PointerAction:Connect(function(wheel, _pan, _pinch, processed)
	if processed or player:GetAttribute("Interacting") then
		return
	end
	
	if currentReciever then
		currentReciever:Fire(wheel)
	end
end)

script.SetCurrentReciever.Event:Connect(function(reciever : BindableEvent)
	currentReciever = reciever
end)

player:SetAttribute("Interacting",false)