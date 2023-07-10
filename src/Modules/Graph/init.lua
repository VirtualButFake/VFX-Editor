--!strict
local graphHandler = {}
graphHandler.__index = graphHandler

local cameraOrientation = CFrame.new(Vector3.new(), Vector3.new(0, 0, -1))
local fovConstant = 0.017454177141189575 -- found by printing DynamicFieldOfView in a frame with FOV 1 and AR 1:1

local function convertTo3D(value: number, minBound: number, maxBound: number, offset: number): number
	return (-offset / 2) + ((offset / 2 - (-offset / 2)) * (value - minBound) / (maxBound - minBound))
end

local function convertToVector(value1: number, value2: number, bounds: bounds, offset: Vector2): Vector3
	local xPos = convertTo3D(value1, bounds.x.min, bounds.x.max, offset.X)
	local yPos = convertTo3D(value2, bounds.y.min, bounds.y.max, offset.Y)
	return Vector3.new(xPos, yPos, 0)
end

function interpolate(a: number, b: number, alpha: number): number
	a = not a and 0 or a :: number
	b = not b and 0 or b :: number

	return a * (1 - alpha) + b * alpha
end

function extrapolate(a: point, b: point, alpha: number, valueName: string)
	local aValue = a[valueName] or 0
	local bValue = b[valueName] or 0

	return (aValue + (alpha - a.index) / (b.index - a.index) * (bValue - aValue))
end

local function getPoint(points: { point }, pointIndex): point
	-- 2 cases: value falls between 2 values: interpolate
	-- or it falls in front or behind the boundaries of the points. calculate the slope and determine the value based off of this
	local lastPoint: number

	for i, point in points do
		if lastPoint then
			if pointIndex > lastPoint and pointIndex < point.index then
				-- falls inbetween
				local width = point.index - lastPoint
				local dist = pointIndex - lastPoint
				local perc = dist / width

				local envelope = interpolate(points[lastPoint].envelope, points[i].envelope, perc)

				return {
					value = interpolate(points[lastPoint].value, points[i].value, perc),
					index = pointIndex,
					envelope = envelope,
				}
			end

			if pointIndex == point.index and i then
				return {
					value = point.value,
					index = pointIndex,
					envelope = point.envelope,
				}
			end
		end

		lastPoint = point.index
	end

	return {
		index = pointIndex,
		value = pointIndex > points[#points].index
			and extrapolate(points[#points - 1], points[#points], pointIndex, "value")
			or extrapolate(points[1], points[2], pointIndex, "value"),
		envelope = pointIndex > points[#points].index
			and extrapolate(points[#points - 1], points[#points], pointIndex, "envelope")
			or extrapolate(points[1], points[2], pointIndex, "envelope"),
	}
end

local function compressPoints(points: {point}, resolution: number, rangeWidth: number, start: number)
	local resolutionIncrement = rangeWidth / resolution
	local compressedPoints: { point } = {}

	for i = 0, resolution do
		local v = start + (resolutionIncrement * i)
		table.insert(compressedPoints, getPoint(points, v))
	end

	local validPoints = {}
	local lastPoint: point?

	for i, point in compressedPoints do
		if lastPoint and points[i - 2] then
			local slope1
			local slope2

			-- compare self to slope between i-2 and i-1 and exchang self with i-1 if same
			do
				-- first slope
				local diffX = point.index - lastPoint.index
				local diffY = point.value - lastPoint.value
				slope1 = diffY / diffX
			end

			do
				-- second slope
				local diffX = points[i - 2].index - lastPoint.index
				local diffY = points[i - 2].value - lastPoint.value

				slope2 = diffY / diffX
			end

			if math.abs(slope1 - slope2) > 1e-6 then
				table.insert(validPoints, point)
				lastPoint = point
				continue
			else
				-- replace i-1
				validPoints[#validPoints] = point
				lastPoint = point
				continue
			end
		end

		table.insert(validPoints, point)
		lastPoint = point
	end

	return validPoints
end

function graphHandler.new(
	points: { [number]: number } | { point },
	bounds: bounds,
	color: Color3,
	envelopeColor: Color3,
	pxScale: number
): graph
	if #points < 2 then
		error(`Could not create graph with {#points} points. >2 points needed.`)
	end

	local graph = {
		bounds = bounds,
		color = color,
		envelopeColor = envelopeColor,
		pxScale = pxScale or 1
	}

	local Container = Instance.new("ViewportFrame")
	Container.BackgroundTransparency = 1
	Container.Size = UDim2.fromScale(1, 1)
	Container.Name = "GraphContainer"
	Container.Ambient = Color3.fromRGB(255, 255, 255)
	Container.LightColor = Color3.fromRGB(255, 255, 255)

	local WorldModel = Instance.new("WorldModel")
	WorldModel.Parent = Container

	-- camera
	local Camera = Instance.new("Camera")
	Camera.FieldOfView = 1
	Camera.CFrame = cameraOrientation * CFrame.new(0, 0, -bounds.x.max - bounds.x.min)
	Container.CurrentCamera = Camera

	graph._camera = Camera
	graph._container = Container
	graph._worldmodel = WorldModel

	local newPoints: { point } = {}

	for idx, point in pairs(points) do
		if typeof(point) == "number" then
			table.insert(newPoints, {
				index = idx,
				value = point,
				envelope = 0, -- probably not a particle related graph if it's passed like this
			})
		else
			if point.envelope == nil then
				point.envelope = 0
			end

			table.insert(newPoints, point)
		end
	end

	graph.points = newPoints

	return setmetatable(graph, graphHandler) :: graph
end

function graphHandler.render(self: graph, frame: GuiObject, resolution: number)
	if self._redrawConnection then 
		self._redrawConnection:Disconnect()
	end 

	self._worldmodel:ClearAllChildren()
	self._container.Parent = frame

	-- set our graph distance to size / fovConstant (this way we can treat it like UI)
	local rangeWidth = self.bounds.x.max - self.bounds.x.min
	local halfExtent = rangeWidth / fovConstant
	self._camera.CFrame = CFrame.new(0, 0, halfExtent)
	self._camera.Parent = self._container

	-- calculate useful values
	local aspectRatio = frame.AbsoluteSize.X / frame.AbsoluteSize.Y
	local horizontalScale = rangeWidth * aspectRatio
	local verticalScale = rangeWidth / 2 * 2
	
	local pxScale = self.pxScale / frame.AbsoluteSize.Y
	local lineSize = verticalScale * pxScale

	local offset = Vector2.new(horizontalScale, verticalScale)

	-- render all points
	local validPoints = compressPoints(self.points, resolution, rangeWidth, self.bounds.x.min)
	local lastPoint: point?

	local lineData = {}

	for i, point in validPoints do
		if lastPoint then
			local startPosition = convertToVector(lastPoint.index, lastPoint.value, self.bounds, offset)
			local endPosition = convertToVector(point.index, point.value, self.bounds, offset)

			local rot = math.atan2(endPosition.Y - startPosition.Y, endPosition.X - startPosition.X)
			local distance = (startPosition - endPosition).Magnitude

			local line = script.Node:Clone()
			line.Size = Vector3.new(distance, 1, lineSize)
			local inbetweenPosition = (startPosition + endPosition) / 2
			line.CFrame = CFrame.new(inbetweenPosition) * CFrame.Angles(0, 0, rot)
			line.Color = self.color
			line.Parent = self._worldmodel

			-- create sphere to fill gaps
			local cap = script.Cap:Clone()
			cap.Size = Vector3.new(lineSize, lineSize, lineSize)
			cap.CFrame = CFrame.new(startPosition)
			cap.Color = self.color
			cap.Parent = line

			local verticalSize = convertTo3D(point.envelope + point.value, self.bounds.y.min, self.bounds.y.max, verticalScale) - endPosition.Y
			local lowestEnvelope = convertTo3D(lastPoint.envelope + lastPoint.value, self.bounds.y.min, self.bounds.y.max, verticalScale) - startPosition.Y

			local envelopeSquare = script.Cube:Clone()
			envelopeSquare.Color = self.envelopeColor
			envelopeSquare.Parent = self._worldmodel

			local pastSegment = lineData[i - 1]
			envelopeSquare.Name = tostring(i)

			envelopeSquare.TopLeft.WorldPosition = pastSegment and pastSegment[1]
				or startPosition + Vector3.new(0, lowestEnvelope, 0)
			envelopeSquare.TopRight.WorldPosition = endPosition + Vector3.new(0, verticalSize, 0)

			envelopeSquare.BottomLeft.WorldPosition = pastSegment and pastSegment[2]
				or startPosition - Vector3.new(0, lowestEnvelope, 0)
			envelopeSquare.BottomRight.WorldPosition = endPosition - Vector3.new(0, verticalSize, 0)

			lineData[i] = {envelopeSquare.TopRight.WorldPosition, envelopeSquare.BottomRight.WorldPosition}
		end

		lastPoint = point
	end

	self._redrawConnection = frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:render(frame, resolution)
	end)
end

type bounds = {
	x: {
		min: number,
		max: number,
	},
	y: {
		min: number,
		max: number,
	},
}

type point = {
	index: number,
	value: number,
	envelope: number,
}

export type graph = typeof(setmetatable({} :: {
	points: { point },
	bounds: bounds,
	color: Color3,
	envelopeColor: Color3,
	pxScale: number,
	_container: ViewportFrame,
	_worldmodel: WorldModel,
	_camera: Camera,
	_redrawConnection: RBXScriptConnection,
}, graphHandler))

return graphHandler
