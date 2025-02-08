-- loads stuff like skills and clothing and gear

local players : Players = game:GetService("Players")

local function loadShirt()
	-- TODO: implement

	local defaultClothID = "rbxassetid://144076357"
	return defaultClothID
end

players.PlayerAdded:Connect(function(player)
	local character : Model = player.Character or player.CharacterAdded:Wait()
	if character:FindFirstChildOfClass("Shirt") then
		character:FindFirstChildOfClass("Shirt"):Destroy()
	end
	
	local characterShirt : Shirt = Instance.new("Shirt")
	characterShirt.Parent = character
	characterShirt.ShirtTemplate = loadShirt()
	characterShirt.Name = "Shirt"
end)