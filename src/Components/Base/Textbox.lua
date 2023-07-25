local Modules = script.Parent.Parent.Parent.Modules
local Fusion = require(Modules.fusion)

local New = Fusion.New
local Children = Fusion.Children
local Event = Fusion.OnEvent

local Tween = Fusion.Tween
local Computed = Fusion.Computed
local Value = Fusion.Value
local Ref = Fusion.Ref
local Out = Fusion.Out

type properties = {
	CornerSize: Fusion.CanBeState<UDim>?,
	Color: Fusion.CanBeState<Color3>,
	Stroke: Fusion.CanBeState<Color3>?,
	Size: Fusion.CanBeState<UDim2>?,
	Position: Fusion.CanBeState<UDim2>?,
	AnchorPoint: Fusion.CanBeState<Vector2>?,
	Parent: Instance?,
	Text: Fusion.Value<string>?,
	Placeholder: string?,
	TextColor: Fusion.CanBeState<Color3>?,
	TextSize: Fusion.CanBeState<number>?,
	PlaceholderColor: Fusion.CanBeState<Color3>?,
	Font: Enum.Font,
	HoverColor: Color3?,
	HoverStroke: Color3?,
	AutoSizeX: boolean?,
	AutoSizeY: boolean?,
	PaddingSize: number?,
	MaxSize: Fusion.CanBeState<Vector2>?,
}

return function(props: properties)
	local isFocused = Value(false)
	local box = Value()

	return New("TextBox")({
		Name = "Textbox",
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = props.Size,
		AutomaticSize = props.AutoSizeX and props.AutoSizeY and Enum.AutomaticSize.XY
			or props.AutoSizeX and Enum.AutomaticSize.X
			or props.AutoSizeY and Enum.AutomaticSize.Y,
		-- appearance
		BackgroundColor3 = Tween(
			Computed(function()
				if isFocused:get() then
					return props.HoverColor or props.Color
				else
					return props.Color
				end
			end),
			TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
		),
		Text = props.Text,
		TextSize = props.TextSize,
		PlaceholderText = props.Placeholder,
		PlaceholderColor3 = props.PlaceholderColor,
		Font = props.Font,
		TextColor3 = props.TextColor,
		TextWrapped = props.AutoSizeY and true,
		Parent = props.Parent,
		[Ref] = box,
		[Event("Focused")] = function()
			isFocused:set(true)
		end,
		[Event("FocusLost")] = function()
			isFocused:set(false)
		end,
		[Out("Text")] = props.Text,
		[Children] = {
			props.MaxSize and New("UISizeConstraint")({
				MaxSize = props.MaxSize,
			}),
			props.PaddingSize and New("UIPadding")({
				PaddingBottom = UDim.new(0, props.PaddingSize),
				PaddingTop = UDim.new(0, props.PaddingSize),
				PaddingLeft = UDim.new(0, props.PaddingSize),
				PaddingRight = UDim.new(0, props.PaddingSize),
			}),
			props.Stroke and New("UIStroke")({
				Thickness = 1,
				Color = Tween(
					Computed(function()
						if isFocused:get() then
							return props.HoverStroke or props.Stroke
						else
							return props.Stroke
						end
					end),
					TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
				),
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			}),
			props.CornerSize and New("UICorner")({
				CornerRadius = props.CornerSize,
			}),
		},
	})
end
