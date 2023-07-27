local root = script.Parent.Parent.Parent
local packages = root.Modules
local utility = root.Utility

local fusion = require(packages.fusion)
local types = require(utility.propertyTypes)
local ripple = require(utility.ripple)

local frame = require(script.Parent.Frame)

local new = fusion.New
local children = fusion.Children
local event = fusion.OnEvent

local ref = fusion.Ref
local value = fusion.Value
local computed = fusion.Computed
local peek = fusion.peek

local tween = fusion.Tween

type properties = {
	frameProperties: types.frameProperties,
	interactiveProperties: types.interactiveProperties,
	State: fusion.Value<boolean>,
	OnClick: () -> (),
}

return function(props: properties)
	local parentFrame = value()
	local hovering = value(false)

	local frameProperties = props.frameProperties
	local interactiveProperties = props.interactiveProperties

	return new("ImageButton")({
		[ref] = parentFrame,
		Position = frameProperties.Position,
		Size = frameProperties.Size,
		BackgroundColor3 = tween(
			computed(function(use)
				if use(hovering) then
					return use(interactiveProperties.HoverColor)
				else
					return use(frameProperties.Color)
				end
			end),
			TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
		),
		ImageTransparency = 1,
		AnchorPoint = frameProperties.AnchorPoint,
		Parent = frameProperties.Parent,
		[event("Activated")] = function(input)
			task.spawn(ripple, {
				Position = Vector2.new(input.Position.X, input.Position.Y),
				Speed = 0.5,
				Frame = peek(parentFrame),
			})

			task.spawn(props.OnClick)
		end,
		[event("MouseEnter")] = function()
			hovering:set(true)
		end,
		[event("MouseLeave")] = function()
			hovering:set(false)
		end,
		[children] = {
			frameProperties.Stroke ~= nil and new("UIStroke")({
				Thickness = 1,
				Color = frameProperties.Stroke,
			}) or nil,
			frameProperties.CornerSize ~= nil and new("UICorner")({
				CornerRadius = frameProperties.CornerSize,
			}) or nil,
			new("UIAspectRatioConstraint")({}),
			new("ImageLabel")({
				Size = UDim2.fromScale(1, 1),
				Image = "rbxassetid://7072706620",
				ImageColor3 = tween(
					computed(function(use)
						if use(hovering) then
							return use(interactiveProperties.HoverColor)
						else
							return use(frameProperties.Color)
						end
					end),
					TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
				),
				BackgroundTransparency = 1,
			}),
			frame({
				frameProperties = {
					Size = UDim2.new(1, 8, 1, 8),
					Position = UDim2.fromScale(0.5, 0.5),
					Color = peek(interactiveProperties.ClickColor),
					AnchorPoint = Vector2.new(0.5, 0.5),
					CornerSize = frameProperties.CornerSize,
				},
				ZIndex = 0,
				BackgroundTransparency = tween(
					computed(function(use)
						if use(props.State) then
							return 0
						else
							return 1
						end
					end),
					TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
				),
			}),
			new("UIPadding")({
				PaddingTop = UDim.new(0, 4),
				PaddingBottom = UDim.new(0, 4),
				PaddingRight = UDim.new(0, 4),
				PaddingLeft = UDim.new(0, 4),
			}),
		},
	})
end
