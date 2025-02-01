-- make GUI size not relative to parent

local CS : CollectionService = game:GetService("CollectionService")

local tagName : string = "ConstantSizeGui"

local guis = CS:GetTagged(tagName)

local function perElementDivisionUdim(udim : UDim2, divisor : number) : UDim2
	local result : UDim2 = UDim2.new(udim.X.Scale/divisor.X.Scale,0
		,udim.Y.Scale/divisor.Y.Scale,0)
	
	return result
end

--refresh if change occurs
CS:GetInstanceAddedSignal(tagName):Connect(function(object : GuiObject)
	local parent : GuiObject = object.Parent
	local originalSize : UDim2 = object.Size
	local originalPosition : UDim2 = object.Position
	parent.Changed:Connect(function()
		object.Size = perElementDivisionUdim(originalSize,parent.Size)
		--object.Position = perElementDivisionUdim(originalPosition,parent.Position)
	end)
end)