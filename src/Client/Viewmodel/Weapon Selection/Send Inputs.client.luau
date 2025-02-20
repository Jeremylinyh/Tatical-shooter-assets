-- Sends input to the equipped weapon

local UIS: UserInputService = game:GetService("UserInputService")

local currentGun : Model = nil

script.Parent:WaitForChild("EquippingWeapon").Event:Connect(function(equipping : boolean,gun : Model)
	if equipping then
		currentGun = gun
	else
		currentGun = nil
	end
end)

UIS.InputBegan:Connect(function(input,gp)
	if gp then
		return
	end
	if not currentGun then
		return
	end
	currentGun:WaitForChild("RecieveInput"):Fire(input,true)
end)

UIS.InputEnded:Connect(function(input,gp)
	if gp then
		return
	end
	if not currentGun then
		return
	end
	currentGun:WaitForChild("RecieveInput"):Fire(input,false)
end)