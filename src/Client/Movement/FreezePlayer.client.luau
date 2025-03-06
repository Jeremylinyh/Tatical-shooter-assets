-- freezes the player

local function tellPlayerWhyFrozen(reason : string)
	-- TODO: implement a gui like press f to cancel interact
end

game:GetService("ReplicatedStorage"):WaitForChild("Player"):WaitForChild("FreezePlayer")
	.OnClientEvent:Connect(function(freezing : boolean,reason : string)
	local PlayerModule = 
		require(game:GetService('Players').LocalPlayer.PlayerScripts:WaitForChild('PlayerModule'))
		local controls = PlayerModule:GetControls()
		if freezing then
			controls:Disable()
			tellPlayerWhyFrozen(reason)
		else
			controls:Enable()
		end
end)