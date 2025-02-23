-- Handle normal inputs

local UIS : UserInputService = game:GetService("UserInputService")
local TS  : TweenService     = game:GetService("TweenService")

local shoutKey = Enum.KeyCode.H
local shoutTween : Tween = nil
local shoutRoutine = nil
local lastYell : number = 0
local yellCoolDown = 1
local function shout()
	if (time() - lastYell) < yellCoolDown then
		return
	end
	game:GetService("ReplicatedStorage"):WaitForChild("Sounds"):WaitForChild("Yell"):FireServer()
	lastYell = time()
	if shoutRoutine then
		coroutine.close(shoutRoutine)
		--print("clsd")
	end
	shoutRoutine = coroutine.create(function()
		--print("start")
		if shoutTween then
			shoutTween:Cancel()
		end
		local player : Player = game:GetService("Players").LocalPlayer
		local radio = player.PlayerGui.Dialog.Radio
		radio.TextLabel.Text = "Halt!"
		radio.Size = UDim2.new(UDim.new(0,radio.Size.Width.Offset),radio.Size.Height)
		local goal = {}
		goal.Size = UDim2.new(UDim.new(1,radio.Size.Width.Offset),radio.Size.Height)
		shoutTween = TS:Create(radio,TweenInfo.new(1),goal)
		shoutTween:Play()
		wait(3)
		radio.TextLabel.Text = ""
	end)
	coroutine.resume(shoutRoutine)
end

UIS.InputBegan:Connect(function(input,gp)
	if gp then
		return
	end
	
	if input.KeyCode == shoutKey then
		shout()
	end
end)
