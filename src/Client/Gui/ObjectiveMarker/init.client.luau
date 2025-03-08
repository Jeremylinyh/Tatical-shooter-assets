-- place objective markers


-- Marker need to have the following attributes:
-- AttachedTo: attachment with a WorldPosition
-- Marker should be an attachment.

local screenGui = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("HUD")
local CS : CollectionService = game:GetService("CollectionService")
local RunService : RunService = game:GetService("RunService")

local frame : Frame = screenGui:WaitForChild("ObjectiveDisplayFrame")
local markerTemplate = script:WaitForChild("Template")
local templatesInUse = {}

local markerTagName = "ObjectiveMarker"

local BorderSize = 0.5

game:GetService("ReplicatedStorage"):WaitForChild("Vote"):WaitForChild("StartGame").OnClientEvent:Wait()

RunService.PreRender:Connect(function(delta)

	local camera = workspace.CurrentCamera
	local markersList = CS:GetTagged(markerTagName)
	

	for i,placeAt : Attachment in pairs(markersList) do
		local marker = templatesInUse[placeAt] 
		if not marker then
			marker = markerTemplate:Clone()
			marker.Parent = frame
			templatesInUse[placeAt] = marker
		end

		local worldPoint = placeAt.WorldPosition
		--print(placeAt.WorldPosition,placeAt.Parent.Position)
		--local position, onScreen = camera:WorldToViewportPoint(worldPoint)
		----print(onScreen)
		--local screenPoint = Vector2.new(position.X, position.Y)
		--screenPoint = adjustScreenPointToArea(screenPoint,frame,onScreen,position.Z)
		--local depth = position.Z

		--local placeMarkerAt : UDim2 = UDim2.fromOffset(screenPoint.X,screenPoint.Y)
		-- marker.Position = placeMarkerAt

		
		local Point = camera:WorldToViewportPoint(worldPoint)
		local X,Y = Point.X,Point.Y
		local ViewportSize = camera.ViewportSize
		local MinX,MaxX = BorderSize/2,ViewportSize.X - (BorderSize/2)
		local MinY,MaxY = BorderSize/2,ViewportSize.Y - (BorderSize/2)


		--Correct the values if the Z is negative (target is behind the camera).
		if Point.Z < 0 then
			--Invert the positions.
			X = ViewportSize.X - X
			Y = ViewportSize.Y - Y

			--Correct the position.
			local PercentageY = Y/ViewportSize.Y
			if PercentageY < 0.5 then
				Y = MinY
			else
				Y = MaxY
			end
		end

		--Set the marker position.
		marker.Position = UDim2.new(0,math.clamp(X,MinX,MaxX),0,math.clamp(Y,MinY,MaxY))
		
		
	end

end)

CS:GetInstanceRemovedSignal(markerTagName):Connect(function(instance : Attachment)
	local marker = templatesInUse[instance] 
	if marker then
		marker:Destroy()
	end
end)


