-- Handles and animate the viewmodel

local RS : RunService = game:GetService("RunService")
local viewmodelConnection = nil
local arms : Model = script.Parent.Parent:WaitForChild("Arms")

local function process(delta : number)
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	
	local placeArmAt : CFrame = camera.CFrame
	placeArmAt += camera.CFrame.LookVector * 0.3
	
	arms:PivotTo(placeArmAt)
end

-- true : draw | false : holster
script.Parent.Event:Connect(function(equip : boolean)
	if equip and not viewmodelConnection then
		viewmodelConnection = RS.PreRender:Connect(process)
		arms.Parent = game.Workspace
		
	elseif viewmodelConnection then
		viewmodelConnection:Disconnect()
		arms.Parent = script.Parent.Parent
	end
end)

-- TODO: remove
script.Parent.Parent.ClothingDone.Event:Connect(function()
	script.Parent:Fire(true)
end)
