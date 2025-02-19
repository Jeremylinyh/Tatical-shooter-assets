-- Once all the player are ready, give the player the guns

local charList = {}

local function characterPrimary() : string
	return "ASR"
	-- TODO: implement
end

local function characterSecondary() : string
	return "ASR"
	-- TODO: implement
end

local function equipWeapon(character : Model, weaponClass : string,slot : string)
	game:GetService("ReplicatedStorage"):WaitForChild("GunEvent").CurrentGunChanged:FireClient(
		game:GetService("Players"):GetPlayerFromCharacter(character)
	)
	local weaponToEquip : Model = game:GetService("ReplicatedStorage"):WaitForChild("Guns"):FindFirstChild(weaponClass)
	
	local currentlyEquipped = character:FindFirstChild(slot)
	if currentlyEquipped then
		currentlyEquipped:Destroy()
		-- TODO: signal for animation
	end
	
	if (not weaponToEquip) then
		return
	end
	
	-- TODO: signal for animation
	weaponToEquip = weaponToEquip:Clone()
	weaponToEquip.Name = slot
	weaponToEquip.Parent = character
	if slot == "Secondary" then
		weaponToEquip:WaitForChild("Holster").Attachment1 = character:WaitForChild("UpperTorso"):WaitForChild("BodyFrontAttachment")
	else
		weaponToEquip:WaitForChild("Holster").Attachment1 = character:WaitForChild("RightUpperLeg"):WaitForChild("RightHipRigAttachment")
	end
	weaponToEquip:WaitForChild("Holster").Attachment0 = weaponToEquip:WaitForChild("Body"):WaitForChild(slot)
end

local function armCharacter(character : Model)
	equipWeapon(character,characterPrimary(),"Primary")
	equipWeapon(character,characterSecondary(),"Secondary")
end

game:GetService("ServerScriptService"):WaitForChild("GameBegin"):WaitForChild("SpawnPlayer").Event:Connect(function()
	for i,v in pairs(charList) do
		armCharacter(v)
	end
end)

game:GetService("Players").PlayerAdded:Connect(function(player)
	local character = player.Character or player.CharacterAdded:Wait()
	table.insert(charList,character)
end)