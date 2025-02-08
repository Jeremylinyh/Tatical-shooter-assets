-- sets up clothing for the viewmodel

local player : Player = game:GetService("Players").LocalPlayer
local viewmodelShirt : Shirt = script.Parent.Parent:WaitForChild("Arms"):WaitForChild("Shirt")

local function changeClothing(id : string)
	viewmodelShirt.ShirtTemplate = id
end

local function swapShirt()
	local charShirt : Shirt = player.Character:WaitForChild("Shirt")
	
	changeClothing(charShirt.ShirtTemplate)
	charShirt:GetPropertyChangedSignal("ShirtTemplate"):Connect(function()
		changeClothing(charShirt.ShirtTemplate)
	end)
end
-- server please gaurrentee a shirt
game.ReplicatedStorage:WaitForChild("Vote"):WaitForChild("StartGame").OnClientEvent:Connect(function()
	swapShirt()
	script.Parent:Fire()
end)