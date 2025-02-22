-- sets up clothing for the viewmodel

local player : Player = game:GetService("Players").LocalPlayer
local viewmodelShirt : Shirt = game:GetService("ReplicatedStorage"):WaitForChild("Guns"):WaitForChild("Arms"):Clone()

local function changeClothing(id : string)
	viewmodelShirt:WaitForChild("Shirt").ShirtTemplate = id
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
	script.Parent.Parent:WaitForChild("SetCurrentArm"):Fire(viewmodelShirt)
	script.Parent:Fire()
end)
