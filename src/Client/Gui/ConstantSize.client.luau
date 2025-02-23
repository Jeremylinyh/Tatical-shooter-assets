-- make GUI size not relative to parent

local CS : CollectionService = game:GetService("CollectionService")

local tagName : string = "ConstantSizeGui"

local guis = CS:GetTagged(tagName)

local function perElementDivisionUdim(udim : UDim2, divisor : number) : UDim2
	local xScale = divisor.X.Scale ~= 0 and (udim.X.Scale / divisor.X.Scale) or 0
	local yScale = divisor.Y.Scale ~= 0 and (udim.Y.Scale / divisor.Y.Scale) or 0

	return UDim2.new(xScale, udim.Width.Offset, yScale, udim.Height.Offset)
end

local function processObject(object : GuiObject)
	local parent : GuiObject = object.Parent
	local originalSize : UDim2 = object.Size
	local originalPosition : UDim2 = object.Position
	parent.Changed:Connect(function()
		--print(parent)
		object.Size = perElementDivisionUdim(originalSize,parent.Size)  -- TODO: DEBUG
		--print(object.Size)
		--object.Position = perElementDivisionUdim(originalPosition,parent.Position)
	end)
end

--refresh if change occurs
CS:GetInstanceAddedSignal(tagName):Connect(processObject)

for i,v in CS:GetTagged(tagName) do
	processObject(v)
end