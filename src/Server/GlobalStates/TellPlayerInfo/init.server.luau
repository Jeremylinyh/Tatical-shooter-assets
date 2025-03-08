-- tells player stuff, like alarms going off, or they can't interact with a prompt

-- TODO: implement

script:WaitForChild("AlertPlayer").Event:Connect(function(player : Player,...)
	-- messages can be modified here
	local alert = game:GetService("ReplicatedStorage"):WaitForChild("GlobalEvents"):WaitForChild("AlertMessage")
	if not player then
		alert:FireAllClients(...)
	else
		alert:FireClient(player,...)
	end
end)