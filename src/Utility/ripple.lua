local packages = script.Parent.Parent.Modules
local fusion = require(packages.fusion)

local new = fusion.New
local children = fusion.Children

local value = fusion.Value
local observer = fusion.Observer
local computed = fusion.Computed
local peek = fusion.peek

local tween = fusion.Tween

type properties = {
	Frame: GuiObject,
	Speed: number,
	Position: Vector2,
}

return function(props: properties)
	local relativePosition = props.Position - props.Frame.AbsolutePosition
	local targetSize = math.max(props.Frame.AbsoluteSize.X, props.Frame.AbsoluteSize.Y)

	local target = value(0)
	local progress = tween(
		computed(function(use)
			return use(target)
		end),
		TweenInfo.new(props.Speed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
	)

	local frame = new("Frame")({
		AnchorPoint = Vector2.new(0, 0),
		BackgroundTransparency = 1,
		Parent = props.Frame,
		ZIndex = 10,
		Size = UDim2.fromScale(1, 1),
		ClipsDescendants = true,
		[children] = {
			new("Frame")({
				ZIndex = 11,
				Position = UDim2.fromOffset(relativePosition.X, relativePosition.Y),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = computed(function(use)
					return UDim2.fromOffset(targetSize * use(progress), targetSize * use(progress))
				end),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = computed(function(use)
					return 0.9 + (0.1 * use(progress))
				end),
				[children] = {
					new("UICorner")({
						CornerRadius = UDim.new(1, 0),
					}),
				},
			}),
		},
	})

	target:set(1)

	local disconnect
	disconnect = observer(progress):onChange(function()
		if peek(progress) == 1 then -- hit end of anim
			frame:Destroy()
			disconnect()
		end
	end)
end
