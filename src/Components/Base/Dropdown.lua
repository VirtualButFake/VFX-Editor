local root = script.Parent.Parent.Parent
local packages = root.Modules
local utility = root.Utility

local fusion = require(packages.fusion)
local types = require(utility.propertyTypes)
local ripple = require(utility.ripple)

local frame = require(script.Parent.Frame)

local new = fusion.New
local children = fusion.Children

local ref = fusion.Ref
local out = fusion.Out
local event = fusion.OnEvent

local peek = fusion.peek
local value = fusion.Value
local computed = fusion.Computed
local forPairs = fusion.ForPairs

local tween = fusion.Tween

type option = {
	value: fusion.CanBeState<string>,
	icon: fusion.CanBeState<string>?,
	callback: (value: boolean) -> ()?,
}

type properties = {
	frameProperties: types.frameProperties,
	arrowProperties: types.interactiveProperties,
	cellProperties: types.interactiveProperties,
	TextColor: fusion.CanBeState<Color3>?,
	Options: fusion.StateObject<{ option }>,
	MultiSelect: boolean?,
	MaxVisibleItems: number?,
	AutoSize: boolean?,
	-- top down control shit
	OnSelection: (option: option, value: boolean) -> (),
	IsOpen: fusion.Value<boolean>,
	Default: { option }?,
}

-- i still have no idea what the "proper" way to write fusion components is - complex components like this feel like an absolute mess
-- but given the unique requirements and responses for each value (or computed) it feels like I have to create them during property assignment and can't create them in the top scope
-- feedback on this is appreciated

-- also sorry for the autoscaling stuff, could think of no way to retain total control without it breaking with i.e. button ripple effects
return function(props: properties)
	-- size-related state
	local selectedOptions = fusion.Value(props.Default or {})

	local frameProperties = props.frameProperties
	local arrowProperties = props.arrowProperties
	local cellProperties = props.cellProperties

	local TextSize = value(0)
	local scrollerAbsSize = value(Vector2.new())
	local iconSize = value(Vector2.new())
	local xSize = computed(function(use)
		local size = use(frameProperties.Size)
		local offsetSize = use(frameProperties.Parent).AbsoluteSize.X * size.X.Scale + size.X.Offset

		local scrollerSize = use(scrollerAbsSize)
		if scrollerSize then
			local targetSize = scrollerSize.X
			return math.clamp(targetSize, offsetSize, math.huge)
		end

		return offsetSize
	end)

	local clickFrame = value(nil) -- click container

	local dropdownImage = value("rbxassetid://0")
	local isHovering = value(false)

	local isOpen = props.IsOpen

	return new("Frame")({
		Name = "DropdownContainer",
		Size = props.AutoSize and computed(function(use)
			if use(scrollerAbsSize) then
				return UDim2.new(0, use(xSize), use(frameProperties.Size).Y.Scale, use(frameProperties.Size).Y.Offset)
			end

			return use(frameProperties.Size)
		end) or peek(frameProperties.Size),
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = frameProperties.Position,
		BackgroundTransparency = 1,
		Parent = frameProperties.Parent,
		AnchorPoint = frameProperties.AnchorPoint,
		[children] = {
			new("UIListLayout")({
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				Padding = UDim.new(0, 4),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			frame({
				frameProperties = {
					Color = frameProperties.Color,
					CornerSize = UDim.new(0, 4),
					Stroke = frameProperties.Stroke,
					Size = props.AutoSize and computed(function(use)
						if use(scrollerAbsSize) then
							return UDim2.new(0, use(xSize), props.AutoSize and 0 or 1, 0)
						end

						return UDim2.fromScale(1, 1)
					end) or UDim2.fromScale(1, 1),
				},
				LayoutOrder = -1,
				Name = "Dropdown",

				AutomaticSize = props.AutoSize and Enum.AutomaticSize.Y,

				Children = {
					new("ImageButton")({
						Name = "Expand",
						Image = "rbxassetid://13945512676",
						Size = UDim2.fromScale(1, 1),
						ImageColor3 = tween(
							computed(function(use)
								local textColor = props.TextColor or Color3.fromRGB(255, 255, 255)
								if use(isHovering) then
									return arrowProperties.HoverColor
								else
									return textColor
								end
							end),
							TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
						),
						Rotation = tween(
							computed(function(use)
								if use(isOpen) then
									return 180
								else
									return 0
								end
							end),
							TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
						),
						BackgroundTransparency = 1,
						[children] = {
							new("UIAspectRatioConstraint")({
								AspectRatio = 1,
							}),
						},
						[out("AbsoluteSize")] = iconSize,
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.fromScale(1, 0.5),
						[event("Activated")] = function()
							isOpen:set(not peek(isOpen))
						end,
						[event("MouseEnter")] = function()
							isHovering:set(true)
						end,
						[event("MouseLeave")] = function()
							isHovering:set(false)
						end,
					}),
					new("ImageLabel")({
						Name = "Icon",
						Image = computed(function(use)
							local selected = use(selectedOptions)

							if typeof(selected) == "table" then
								if selected.value ~= nil then
									return selected.icon or "rbxassetid://0"
								elseif #selected == 1 then
									return selected[1].icon or "rbxassetid://0"
								end
							end

							return "rbxassetid://0"
						end),
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						ImageColor3 = props.TextColor,
						[children] = {
							new("UIAspectRatioConstraint")({
								AspectRatio = 1,
							}),
						},
						[out("Image")] = dropdownImage,
					}),
					new("TextLabel")({
						Name = "Title",
						Text = computed(function(use)
							local selected = use(selectedOptions)

							if typeof(selected) == "table" then
								if selected.value == nil then
									local names = {}

									for _, option in selected do
										table.insert(names, option.value)
									end

									return #selected >= 1 and table.concat(names, ", ") or "None"
								elseif selected.value ~= nil then
									return selected.value ~= "" and selected.value or "None"
								end
							end

							return "None"
						end),
						Size = computed(function(use)
							if use(iconSize) then
								if use(dropdownImage) ~= "rbxassetid://0" then
									return UDim2.new(1, -use(iconSize).X * 2 - 8, props.AutoSize and 0 or 1, 0)
								end

								return UDim2.new(1, -use(iconSize).X - 8, props.AutoSize and 0 or 1, 0)
							end

							return UDim2.fromScale(1, 1)
						end) or UDim2.fromScale(1, 1),
						Position = computed(function(use)
							if use(dropdownImage) ~= "rbxassetid://0" and use(iconSize) then
								return UDim2.new(0, use(iconSize).X + 8, 0, 0)
							end

							return UDim2.new()
						end),
						TextTruncate = Enum.TextTruncate.AtEnd,
						BackgroundTransparency = 1,
						TextColor3 = props.TextColor or Color3.fromRGB(255, 255, 255),
						Font = Enum.Font.Gotham,
						TextXAlignment = Enum.TextXAlignment.Left,
						AutomaticSize = Enum.AutomaticSize.Y,
						[out("AbsoluteSize")] = TextSize,
					}),
					new("UIPadding")({
						PaddingTop = UDim.new(0, 4),
						PaddingBottom = UDim.new(0, 4),
						PaddingLeft = UDim.new(0, 4),
						PaddingRight = UDim.new(0, 4),
					}),
				},
			}),
			new("CanvasGroup")({
				Name = "ValueHolder",
				Position = UDim2.new(0, 0, 1, 4),
				Size = computed(function(use)
					if use(TextSize) then
						if props.AutoSize and use(scrollerAbsSize) then
							return UDim2.new(
								0,
								use(xSize),
								0,
								math.clamp(#use(props.Options), 0, props.MaxVisibleItems or 5) * (use(TextSize).Y + 8)
							)
						else
							return UDim2.new(
								1,
								0,
								0,
								math.clamp(#use(props.Options), 0, props.MaxVisibleItems or 5) * (use(TextSize).Y + 8)
							)
						end
					end

					return UDim2.fromScale(1, 0)
				end),
				BackgroundColor3 = frameProperties.Color,
				Visible = isOpen,
				[children] = {
					new("Frame")({
						Name = "ClickContainer",
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						ZIndex = 2,
						[ref] = clickFrame,
					}),
					frameProperties.Stroke and new("UIStroke")({
						Thickness = 1,
						Color = frameProperties.Stroke,
					}),
					new("UICorner")({
						CornerRadius = UDim.new(0, 4),
					}),
					new("ScrollingFrame")({
						Name = "ValueList",
						Size = UDim2.fromScale(1, 1),
						CanvasSize = UDim2.new(0, 0, 0, 0),
						AutomaticCanvasSize = Enum.AutomaticSize.Y,
						AutomaticSize = props.AutoSize and Enum.AutomaticSize.X,
						BackgroundTransparency = 1,
						ScrollBarThickness = 0,
						[children] = {
							new("UIListLayout")({
								FillDirection = Enum.FillDirection.Vertical,
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								VerticalAlignment = Enum.VerticalAlignment.Top,
								Padding = UDim.new(0, 0),
								SortOrder = Enum.SortOrder.LayoutOrder,
							}),
							forPairs(props.Options, function(use, i, v)
								local isHovering = value(false)

								return i,
									new("ImageButton")({
										Name = "Container",
										LayoutOrder = i,
										AutomaticSize = props.AutoSize and Enum.AutomaticSize.X,
										BackgroundColor3 = tween(
											computed(function(use)
												local selected = use(selectedOptions)

												if typeof(selected) == "table" and table.find(selected, v) then
													return cellProperties.ClickColor
												elseif selected == v then
													return cellProperties.ClickColor
												end

												if use(isHovering) then
													return use(cellProperties.HoverColor)
												end

												return frameProperties.Color
											end),
											TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
										),
										Size = computed(function(use)
											if use(TextSize) then
												return UDim2.new(1, 0, 0, use(TextSize).Y + 8)
											end

											return UDim2.fromScale(1, 0)
										end),
										[event("Activated")] = function(input)
											task.spawn(ripple, {
												Frame = peek(clickFrame),
												Speed = 0.5,
												Position = Vector2.new(input.Position.X, input.Position.Y),
											})

											if props.MultiSelect then
												local current = peek(selectedOptions) :: {}
												local tblIndex = table.find(current, v)

												if tblIndex then
													if v.callback then
														v.callback(false)
													end

													if props.OnSelection then
														props.OnSelection(v, false)
													end

													table.remove(current, tblIndex)
												else
													if v.callback then
														v.callback(true)
													end

													if props.OnSelection then
														props.OnSelection(v, true)
													end

													table.insert(current, v)
												end

												selectedOptions:set(current)
											elseif peek(selectedOptions).value ~= v then
												if v.callback then
													v.callback(true)
												end

												if props.OnSelection then
													props.OnSelection(v, true)
												end

												selectedOptions:set(v)
											end
										end,
										[event("MouseEnter")] = function()
											isHovering:set(true)
										end,
										[event("MouseLeave")] = function()
											isHovering:set(false)
										end,
										[children] = {
											new("UIPadding")({
												PaddingTop = UDim.new(0, 4),
												PaddingBottom = UDim.new(0, 4),
												PaddingLeft = UDim.new(0, 4),
												PaddingRight = UDim.new(0, 4),
											}),
											new("UIListLayout")({
												FillDirection = Enum.FillDirection.Horizontal,
												HorizontalAlignment = Enum.HorizontalAlignment.Left,
												VerticalAlignment = Enum.VerticalAlignment.Center,
												Padding = UDim.new(0, 8),
												SortOrder = Enum.SortOrder.LayoutOrder,
											}),
											new("TextLabel")({
												Name = "Title",
												Text = v.value,
												AutomaticSize = props.AutoSize and Enum.AutomaticSize.X,
												Size = UDim2.fromScale(0, 1),
												BackgroundTransparency = 1,
												TextColor3 = props.TextColor or Color3.fromRGB(255, 255, 255),
												Font = Enum.Font.Gotham,
												LayoutOrder = 1,
												TextXAlignment = Enum.TextXAlignment.Left,
											}),
											v.icon and new("ImageLabel")({
												Name = "Icon",
												Image = v.icon,
												Size = UDim2.fromScale(1, 1),
												BackgroundTransparency = 1,
												ImageColor3 = props.TextColor,
												[children] = {
													new("UIAspectRatioConstraint")({
														AspectRatio = 1,
													}),
												},
											}),
											new("Frame")({
												Name = "SizePadding",
												BackgroundTransparency = 1,
												Size = UDim2.fromScale(1, 1),
												LayoutOrder = 2,
												[children] = {
													new("UIAspectRatioConstraint")({
														AspectRatio = 1,
													}),
												},
											}),
										},
									})
							end, fusion.Cleanup),
						},
						[out("AbsoluteSize")] = scrollerAbsSize,
					}),
				},
			}),
		},
	})
end
