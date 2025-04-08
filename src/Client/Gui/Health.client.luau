-- updates the health UI

local player : Player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Health,false)

local healthbar = player.PlayerGui:WaitForChild("HUD"):WaitForChild("CharData"):WaitForChild("Health")

humanoid.Changed:Connect(function()
	local truHealth : number = humanoid.Health/humanoid.MaxHealth
	truHealth = math.pow(truHealth,3)
	healthbar.Size = UDim2.new(truHealth,0,1/3,0)
end)