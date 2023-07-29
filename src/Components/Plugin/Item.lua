local root = script.Parent.Parent.Parent
local packages = root.Packages
local utility = root.Utility
local components = script.Parent.Parent

local fusion = require(packages.fusion)
local themeHandler = require(utility.themeHandler)

local new = fusion.New
local children = fusion.Children

local cleanup = fusion.Cleanup

local forPairs = fusion.ForPairs
local value = fusion.Value
local computed = fusion.Computed

local frame = require(components.Base.Frame)
local button = require(components.Base.Button)
local propertyCategory = require(components.Plugin.propertyCategory)

local instanceProperties = {
	ParticleEmitter = {
		Icon = {
			Dark = "rbxassetid://13945146645",
		},
		AvailableProperties = {
			{
				Title = "Appearance",
				Properties = {
					"Rate",
				},
			},
		},
		Emit = {
			Text = "Emit",
			Callback = function(instance, amount)
				instance:Emit(amount)
			end,
		},
	},
}

type properties = {
	Instance: Instance,
}

return function(props: properties)
	-- putting this in var for future mesh flipbook support
	local instanceType = props.Instance.ClassName
	local instanceName = value(props.Instance.Name)

	local properties = instanceProperties[instanceType]

	local nameConnection = props.Instance:GetPropertyChangedSignal("Name"):Connect(function()
		instanceName:set(props.Instance.Name)
	end)

	local buttonPressed = value(false)

	local Frame = frame({
		frameProperties = {
			Color = themeHandler.get(Enum.StudioStyleGuideColor.ViewPortBackground),
			Stroke = themeHandler.get(Enum.StudioStyleGuideColor.Border),
			Size = UDim2.new(1, 0, 0, 36),
			PaddingSize = 4,
			CornerSize = UDim.new(0, 4),
		},
		otherProperties = {
			AutomaticSize = Enum.AutomaticSize.Y,
			Name = "Item",
			[cleanup] = {
				nameConnection,
			},
		},
		Children = {
			new("Frame")({
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 28),
				Name = "TopbarLeft",
				[children] = {
					new("UIListLayout")({
						Padding = UDim.new(0, 8),
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
					new("ImageLabel")({
						Name = "Icon",
						Size = UDim2.fromScale(1, 1),
						Image = properties.Icon.Dark, -- todo: make this adapt to theme
						BackgroundTransparency = 1,
						LayoutOrder = 0,
						[children] = {
							new("UIAspectRatioConstraint")({}),
						},
					}),
					new("TextLabel")({
						Name = "Title",
						Size = UDim2.fromScale(0, 1),
						Text = instanceName,
						Font = Enum.Font.Gotham,
						TextColor3 = themeHandler.get(Enum.StudioStyleGuideColor.MainText),
						AutomaticSize = Enum.AutomaticSize.X,
						BackgroundTransparency = 1,
					}),
				},
			}),
			new("Frame")({
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 28),
				Name = "TopbarRight",
				[children] = {
					new("UIListLayout")({
						Padding = UDim.new(0, 8),
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Right,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
					new("ImageLabel")({
						Name = "Chevron",
						Size = UDim2.fromScale(1, 0.8),
						Image = "rbxassetid://14237634107",
						ImageColor3 = themeHandler.get(Enum.StudioStyleGuideColor.BrightText),
						BackgroundTransparency = 1,
						LayoutOrder = 2,
						[children] = {
							new("UIAspectRatioConstraint")({}),
						},
					}),
					properties.Emit and button({
						frameProperties = {
							Color = themeHandler.get(Enum.StudioStyleGuideColor.Button),
							Stroke = themeHandler.get(Enum.StudioStyleGuideColor.Border),
							Size = UDim2.new(0, 0, 0, 25),
							PaddingSize = 4,
							CornerSize = UDim.new(0, 4),
						},
						interactiveProperties = {
							HoverColor = themeHandler.get(Enum.StudioStyleGuideColor.InputFieldBackground),
						},
						textProperties = {
							Text = properties.Emit.Text,
							TextColor = themeHandler.get(Enum.StudioStyleGuideColor.ButtonText),
							Font = Enum.Font.Gotham,
						},
						AutoSize = true,
						Callback = function()
							properties.Emit.Callback(props.Instance, 10)
						end,
						Ripple = false,
					}),
				},
			}),
			new("Frame")({
				Name = "ItemContainer",
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0, 32),
				[children] = {
					new("UIListLayout")({
						Padding = UDim.new(0, 8),
						FillDirection = Enum.FillDirection.Vertical,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Top,
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
					new("Frame")({
						Name = "Divider",
						Size = UDim2.new(1, 8, 0, 1),
						BackgroundColor3 = themeHandler.get(Enum.StudioStyleGuideColor.Border),
						LayoutOrder = -1,
					}),
					new("Frame")({
						Name = "Properties",
						Size = UDim2.new(1, 0, 0, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
						BackgroundTransparency = 1,
						[children] = {
							forPairs(properties.AvailableProperties, function(use, i, v)
								return i,
									propertyCategory({
										Instance = props.Instance,
										PropertyData = v,
									})
							end),
						},
					}),
				},
			}),
		},
	})

	return Frame
end
