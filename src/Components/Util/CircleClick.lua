local Packages = script.Parent.Parent.Parent.Packages
local Fusion = require(Packages.fusion)

local New = Fusion.New
local Children = Fusion.Children
local Value = Fusion.Value
local Observer = Fusion.Observer
local Computed = Fusion.Computed

local Tween = Fusion.Tween

type properties = {
	Frame: GuiObject,
	Speed: number,
	Position: Vector2,
}

return function(props: properties)
	local relativePosition = props.Position - props.Frame.AbsolutePosition
	local targetSize = math.max(props.Frame.AbsoluteSize.X, props.Frame.AbsoluteSize.Y)

	local target = Value(0)
	local progress = Tween(
		Computed(function()
			return target:get()
		end),
		TweenInfo.new(props.Speed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
	)

	local frame = New("Frame")({
		AnchorPoint = Vector2.new(0, 0),
		BackgroundTransparency = 1,
		Parent = props.Frame,
		ZIndex = 10,
		Size = UDim2.fromScale(1, 1),
		ClipsDescendants = true,
		[Children] = {
			New("Frame")({
				Position = UDim2.fromOffset(relativePosition.X, relativePosition.Y),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = Computed(function()
					return UDim2.fromOffset(targetSize * progress:get(), targetSize * progress:get())
				end),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = Computed(function()
					return 0.9 + (0.1 * progress:get())
				end),
				[Children] = {
					New("UICorner")({
						CornerRadius = UDim.new(1, 0),
					}),
				},
			}),
		},
	})

	target:set(1)

	local observer = Observer(progress)
	local disconnect
	disconnect = observer:onChange(function()
		if progress:get() == 1 then
			frame:Destroy()
			disconnect()
		end
	end)
end
