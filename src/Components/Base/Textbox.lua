local root = script.Parent.Parent.Parent
local packages = root.Packages
local utility = root.Utility

local fusion = require(packages.fusion)
local types = require(utility.propertyTypes)

local new = fusion.New
local children = fusion.Children

local ref = fusion.Ref
local out = fusion.Out
local event = fusion.OnEvent

local computed = fusion.Computed
local value = fusion.Value

local tween = fusion.Tween

type properties = {
	frameProperties: types.frameProperties,
	textProperties: types.textProperties,
	-- not grouping the 2 properties below into interactiveProperties because we need seperate colors
	HoverColor: fusion.CanBeState<Color3>?,
	HoverStroke: fusion.CanBeState<Color3>?,
	AutoSizeX: boolean?,
	AutoSizeY: boolean?,
	MaxSize: fusion.CanBeState<Vector2>?,
	State: fusion.Value<string>,
}

return function(props: properties)
	local isFocused = value(false)
	local box = value(nil)

	local frameProperties = props.frameProperties
	local textProperties = props.textProperties

	return new("TextBox")({
		Name = "Textbox",
		AnchorPoint = frameProperties.AnchorPoint,
		Position = frameProperties.Position,
		Size = frameProperties.Size,
		AutomaticSize = props.AutoSizeX and props.AutoSizeY and Enum.AutomaticSize.XY
			or props.AutoSizeX and Enum.AutomaticSize.X
			or props.AutoSizeY and Enum.AutomaticSize.Y,
		-- appearance
		BackgroundColor3 = tween(
			computed(function(use)
				if use(isFocused) then
					return use(props.HoverColor) or use(frameProperties.Color)
				else
					return use(frameProperties.Color)
				end
			end),
			TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
		),
		Text = textProperties.Text,
		TextSize = textProperties.TextSize,
		PlaceholderText = textProperties.PlaceholderText,
		PlaceholderColor3 = textProperties.PlaceholderColor,
		Font = textProperties.Font,
		TextColor3 = textProperties.TextColor,
		TextWrapped = props.AutoSizeY and true,
		Parent = frameProperties.Parent,
		[ref] = box,
		[event("Focused")] = function()
			isFocused:set(true)
		end,
		[event("FocusLost")] = function()
			isFocused:set(false)
		end,
		[out("Text")] = props.State,
		[children] = {
			props.MaxSize and new("UISizeConstraint")({
				MaxSize = props.MaxSize,
			}),
			frameProperties.PaddingSize and new("UIPadding")({
				PaddingBottom = UDim.new(0, frameProperties.PaddingSize),
				PaddingTop = UDim.new(0, frameProperties.PaddingSize),
				PaddingLeft = UDim.new(0, frameProperties.PaddingSize),
				PaddingRight = UDim.new(0, frameProperties.PaddingSize),
			}),
			frameProperties.Stroke and new("UIStroke")({
				Thickness = 1,
				Color = tween(
					computed(function(use)
						if use(isFocused) then
							return use(props.HoverStroke) or use(frameProperties.Stroke)
						else
							return use(frameProperties.Stroke)
						end
					end),
					TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
				),
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			}),
			frameProperties.CornerSize and new("UICorner")({
				CornerRadius = frameProperties.CornerSize,
			}),
		},
	})
end
