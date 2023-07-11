local Packages = script.Parent.Parent.Parent.Packages
local Fusion = require(Packages.fusion)

local CircleClick = require(script.Parent.CircleClick)

local New = Fusion.New
local Ref = Fusion.Ref
local Children = Fusion.Children
local Event = Fusion.OnEvent

local Value = Fusion.Value
local Computed = Fusion.Computed

local Tween = Fusion.Tween

type properties = {
	CornerSize: Fusion.CanBeState<UDim>?,
	Color: Fusion.CanBeState<Color3>,
	HoverColor: Color3,
	PaddingSize: number?,
	Callback: () -> (),
	Text: Fusion.CanBeState<string>,
	TextColor: Fusion.CanBeState<Color3>,
	Stroke: Fusion.CanBeState<Color3>?,
	Size: Fusion.CanBeState<UDim2>?,
	Position: Fusion.CanBeState<UDim2>?,
	AnchorPoint: Vector2?,
	Parent: Instance?,
	Font: Enum.Font?,
	AutoSize: boolean?,
}

return function(props: properties)
	local hovering = Value(false)
	local parentFrame = Value()

	local button = New("TextButton")({
		Size = props.Size,
		Position = props.Position,
		BackgroundColor3 = Tween(
			Computed(function()
				if hovering:get() then
					return props.HoverColor
				else
					return props.Color
				end
			end),
			TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
		),
		AnchorPoint = props.AnchorPoint,
		Parent = props.Parent,
		Text = props.Text,
		TextColor3 = props.TextColor,
		Font = props.Font or Enum.Font.Gotham,
		[Event("MouseEnter")] = function()
			hovering:set(true)
		end,
		[Event("MouseLeave")] = function()
			hovering:set(false)
		end,
		[Event("Activated")] = function(input)
			CircleClick({
				Position = Vector2.new(input.Position.X, input.Position.Y),
				Speed = 0.5,
				Frame = parentFrame:get(),
			})
		end,
		[Children] = {
			props.Stroke and New("UIStroke")({
				Thickness = 1,
				Color = props.Stroke,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			}),
			props.CornerSize and New("UICorner")({
				CornerRadius = props.CornerSize,
			}),
			props.PaddingSize and New("UIPadding")({
				PaddingBottom = UDim.new(0, props.PaddingSize),
				PaddingTop = UDim.new(0, props.PaddingSize),
				PaddingLeft = UDim.new(0, props.PaddingSize),
				PaddingRight = UDim.new(0, props.PaddingSize),
			}),
		},
		[Ref] = parentFrame,
	})

	return button
end
