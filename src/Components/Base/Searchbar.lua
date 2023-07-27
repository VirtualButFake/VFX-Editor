local root = script.Parent.Parent.Parent
local packages = root.Modules
local utility = root.Utility

local fusion = require(packages.fusion)
local types = require(utility.propertyTypes)

local frame = require(script.Parent.Frame)

local new = fusion.New
local children = fusion.Children
local hydrate = fusion.Hydrate

local change = fusion.OnChange
local out = fusion.Out
local event = fusion.OnEvent

local value = fusion.Value
local peek = fusion.peek
local computed = fusion.Computed

local tween = fusion.Tween

type option = {
	value: fusion.CanBeState<string>, -- text that is displayed,
	aliases: fusion.CanBeState<{ string }>?, -- alternative names that will count w/ search but not display,
}

type properties = {
	frameProperties: types.frameProperties,
	textProperties: types.textProperties,
	HoverColor: fusion.CanBeState<Color3>?,
	HoverStroke: fusion.CanBeState<Color3>?,
	Autocomplete: boolean?, -- autocompletes text when it's found only 1 match
	AutocompleteColor: fusion.CanBeState<Color3>?,
	Options: fusion.StateObject<{ option }>, -- a table of the options that are available in the search menu.
	AvailableOptions: fusion.Value<{
		{
			index: any,
			value: option,
		}
	}>, -- value object that holds the options that meet the current text. this is also the **only** way to access found values. the text is not exposed to make sure behaviour is consistent
}

local function getMatch(option: string, query: string)
	if #query == 0 then
		return false
	end

	return string.sub(option, 1, #query) == query
end

return function(props: properties)
	local frameProperties = props.frameProperties
	local textProperties = props.textProperties

	local absoluteSize = value(Vector2.new())

	local isFocused = value(false)
	local searchQuery = value(textProperties.Text or "")

	-- hydrating here to put absolutesize in state object
	return hydrate(frame({
		Name = "Searchbar",
		frameProperties = {
			Size = frameProperties.Size,
			Position = frameProperties.Position,
			Color = tween(
				computed(function(use)
					if use(isFocused) then
						return use(props.HoverColor)
					else
						return use(frameProperties.Color)
					end
				end),
				TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
			),
			Stroke = tween(
				computed(function(use)
					if use(isFocused) then
						return use(props.HoverStroke)
					else
						return use(frameProperties.Stroke)
					end
				end),
				TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
			),
			Parent = frameProperties.Parent,
			AnchorPoint = frameProperties.AnchorPoint,
			CornerSize = frameProperties.CornerSize,
		},
	}))({
		ClipsDescendants = true,
		[out("AbsoluteSize")] = absoluteSize,
		[children] = {
			new("Frame")({
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Name = "ContentContainer",
				Position = tween(
					computed(function(use)
						if use(isFocused) then
							local absSize = use(absoluteSize)

							if absSize then
								return UDim2.new(0, -math.min(absSize.X, absSize.Y) + frameProperties.PaddingSize, 0, 0)
							end
						end

						return UDim2.new()
					end),
					TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
				),
				[children] = {
					frameProperties.PaddingSize and new("UIPadding")({
						PaddingBottom = UDim.new(0, frameProperties.PaddingSize),
						PaddingTop = UDim.new(0, frameProperties.PaddingSize),
						PaddingLeft = UDim.new(0, frameProperties.PaddingSize),
						PaddingRight = UDim.new(0, frameProperties.PaddingSize),
					}),
					new("UIListLayout")({
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						Padding = UDim.new(0, frameProperties.PaddingSize),
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
					-- create search icon
					new("ImageLabel")({
						BackgroundTransparency = 1,
						Image = "rbxassetid://10734943674",
						Size = UDim2.new(1, 0, 1, 0),
						Position = UDim2.new(0, 0, 0.5, 0),
						AnchorPoint = Vector2.new(0, 0.5),
						ImageColor3 = textProperties.TextColor,
						LayoutOrder = -1,
						[children] = {
							new("UIAspectRatioConstraint")({}),
						},
					}),
					new("TextBox")({
						Text = searchQuery,
						[change("Text")] = function(text)
							local availableResults = {}

							for i, option: option in peek(props.Options) do
								local value, aliases = peek(option.value), peek(option.aliases)

								if getMatch(value, text) then
									table.insert(availableResults, {
										index = i,
										value = option,
									})
									continue
								end

								if aliases then
									for _, alias in aliases do
										if getMatch(alias, text) then
											table.insert(availableResults, {
												index = i,
												value = option,
											})
											break
										end
									end
								end
							end

							props.AvailableOptions:set(availableResults) -- propagate changes
							searchQuery:set(text) -- not sure if this is bad practice; had to do this for autocomplete. fusion seems to take care of this internally since change does not fire so it's fine
						end,
						ClipsDescendants = true,
						TextSize = textProperties.TextSize,
						TextColor3 = textProperties.TextColor,
						PlaceholderText = textProperties.PlaceholderText,
						PlaceholderColor3 = textProperties.PlaceholderColor,
						Font = textProperties.Font or Enum.Font.Gotham,
						TextXAlignment = Enum.TextXAlignment.Left,
						Size = tween(
							computed(function(use)
								-- not my preferred way of handling this but roblox has no nice solution
								-- get x size by doing parent x size - smallest offset value - padding
								local absSize = use(absoluteSize)

								if use(isFocused) then
									return UDim2.fromScale(1, 1)
								end

								if absSize then
									return UDim2.new(
										0,
										absSize.X - math.min(absSize.X, absSize.Y) - frameProperties.PaddingSize,
										1,
										0
									)
								end

								return UDim2.fromScale(0, 1)
							end),
							TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
						),
						[event("Focused")] = function()
							isFocused:set(true)
						end,
						[event("FocusLost")] = function()
							isFocused:set(false)

							local options = peek(props.AvailableOptions)

							if options and #options == 1 then
								searchQuery:set(options[1].value)
							end
						end,
						BackgroundTransparency = 1,
						[children] = {
							props.Autocomplete and new("TextLabel")({
								BackgroundTransparency = 1,
								Text = computed(function(use)
									local results = use(props.AvailableOptions)

									-- getmatch because we don't want to autocomplete aliases, this'll look weird with the textlabels
									if
										#results == 1
										and use(isFocused)
										and getMatch(results[1].value, use(searchQuery))
									then
										return results[1].value
									end

									return ""
								end),
								TextColor3 = props.AutocompleteColor,
								Size = UDim2.fromScale(1, 1),
								TextXAlignment = Enum.TextXAlignment.Left,
								TextSize = textProperties.TextSize,
								Font = textProperties.Font or Enum.Font.Gotham,
								ClipsDescendants = true,
							}),
						},
					}),
				},
			}),
		},
	})
end
