local root = script.Parent.Parent.Parent
local packages = root.Packages
local utility = root.Utility
local components = script.Parent.Parent

local fusion = require(packages.fusion)
local themeHandler = require(utility.themeHandler)

local frame = require(components.Base.Frame)
local button = require(components.Base.Button)

local item = require(components.Plugin.Item)

local new = fusion.New
local children = fusion.Children

local event = fusion.OnEvent

local value = fusion.Value
local computed = fusion.Computed
local forPairs = fusion.ForPairs

local tween = fusion.Tween

local camera = workspace.CurrentCamera
local selection = game:GetService("Selection")

type properties = {
	Parent: fusion.CanBeState<Instance>,
}

return function(props: properties)
	local cogHovered = value(false)
	local settingsOpen = value(false)
	local selectedObjects = fusion.Value({ workspace.VFXPart.Attachment:FindFirstChildOfClass("ParticleEmitter") }) -- debug --fusion.Value(selection:Get())
	local selectedParticles = computed(function(use)
		local validSelections = {}

		for _, v in use(selectedObjects) do
			if v:IsA("ParticleEmitter") or v:IsA("Attachment") or v:IsA("Beam") then
				table.insert(validSelections, v)
			end
		end

		return validSelections
	end)

	selection.SelectionChanged:Connect(function()
		--selectedObjects:set(selection:Get())
	end)

	return new("Frame")({
		Name = "MainWindow",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = themeHandler.get(Enum.StudioStyleGuideColor.MainBackground),
		Parent = props.Parent,
		[children] = {
			frame({
				frameProperties = {
					Color = themeHandler.get(Enum.StudioStyleGuideColor.InputFieldBackground),
					Size = UDim2.new(1, 0, 0, 30),
					PaddingSize = 8,
					Stroke = themeHandler.get(Enum.StudioStyleGuideColor.InputFieldBorder),
				},
				otherProperties = {
					Name = "Topbar",
				},
				Children = {
					new("TextLabel")({
						Name = "Title",
						Size = UDim2.fromScale(0.8, 1),
						BackgroundTransparency = 1,
						ClipsDescendants = true,
						TextXAlignment = Enum.TextXAlignment.Left,
						Text = "VirtualButFake's VFX Editor",
						Font = Enum.Font.Gotham,
						TextColor3 = themeHandler.get(Enum.StudioStyleGuideColor.BrightText),
					}),
					new("ImageButton")({
						Name = "SettingsCog",
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.fromScale(1, 0.5),
						Size = UDim2.fromOffset(16, 16),
						BackgroundTransparency = 1,
						Image = "rbxassetid://10734950309",
						ImageColor3 = tween(
							computed(function(use)
								-- don't think this is best practice but oh well
								if use(cogHovered) then
									return use(themeHandler.get(Enum.StudioStyleGuideColor.TitlebarText))
								else
									return use(themeHandler.get(Enum.StudioStyleGuideColor.BrightText))
								end
							end),
							TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
						),
						[event("MouseEnter")] = function()
							cogHovered:set(true)
						end,
						[event("MouseLeave")] = function()
							cogHovered:set(false)
						end,
					}),
				},
			}),
			new("Frame")({
				Name = "Content",
				Size = UDim2.new(1, 0, 1, -30),
				Position = UDim2.new(0, 0, 0, 30),
				BackgroundTransparency = 1,
				[children] = {
					new("ScrollingFrame")({
						Name = "MainContainer",
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						AutomaticCanvasSize = Enum.AutomaticSize.Y,
						CanvasSize = UDim2.new(),
						ScrollBarImageColor3 = themeHandler.get(Enum.StudioStyleGuideColor.ScrollBar),
						ScrollBarThickness = 2,
						TopImage = "rbxassetid://0",
						BottomImage = "rbxassetid://0",
						Visible = computed(function(use)
							return #use(selectedParticles) > 0 and not use(settingsOpen)
						end),
						[children] = {
							new("UIPadding")({
								PaddingBottom = UDim.new(0, 8),
								PaddingTop = UDim.new(0, 8),
								PaddingLeft = UDim.new(0, 8),
								PaddingRight = UDim.new(0, 8),
							}),
							new("UIListLayout")({
								Padding = UDim.new(0, 16),
								FillDirection = Enum.FillDirection.Vertical,
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								VerticalAlignment = Enum.VerticalAlignment.Top,
								SortOrder = Enum.SortOrder.LayoutOrder,
							}),
							forPairs(selectedParticles, function(use, i, instance)
								return i, item({
									Instance = instance,
								})
							end, fusion.cleanup),
						},
					}),
					frame({
						otherProperties = {
							Name = "SettingsFrame",
							BackgroundTransparency = 1,
							Visible = computed(function(use)
								return use(settingsOpen)
							end),
						},
						frameProperties = {
							PaddingSize = 8,
							Size = UDim2.fromScale(1, 1),
							Color = Color3.fromRGB(0, 0, 0),
						},
					}),
					frame({
						otherProperties = {
							Name = "EmptyFrame",
							BackgroundTransparency = 1,
							Visible = computed(function(use)
								return #use(selectedParticles) == 0 and not use(settingsOpen)
							end),
						},
						frameProperties = {
							PaddingSize = 8,
							Size = UDim2.fromScale(1, 1),
							Color = Color3.fromRGB(0, 0, 0),
						},
						Children = {
							new("UIListLayout")({
								Padding = UDim.new(0, 16),
								FillDirection = Enum.FillDirection.Vertical,
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								VerticalAlignment = Enum.VerticalAlignment.Top,
								SortOrder = Enum.SortOrder.LayoutOrder,
							}),
							new("TextLabel")({
								Name = "Header",
								Text = "It's a little empty here. To get started with a base part, press the button below.",
								TextSize = 18,
								TextYAlignment = Enum.TextYAlignment.Top,
								TextWrapped = true,
								TextColor3 = themeHandler.get(Enum.StudioStyleGuideColor.MainText),
								Size = UDim2.new(0.75, 0, 0, 0),
								AutomaticSize = Enum.AutomaticSize.Y,
								BackgroundTransparency = 1,
								Font = Enum.Font.Gotham,
								LayoutOrder = -1,
							}),
							button({
								frameProperties = {
									Color = themeHandler.get(Enum.StudioStyleGuideColor.Button),
									Stroke = themeHandler.get(Enum.StudioStyleGuideColor.Border),
									Size = UDim2.new(0, 0, 0, 25),
									PaddingSize = 8,
									CornerSize = UDim.new(0, 4),
								},
								interactiveProperties = {
									HoverColor = themeHandler.get(Enum.StudioStyleGuideColor.InputFieldBackground),
								},
								textProperties = {
									Text = "Create base part",
									TextColor = themeHandler.get(Enum.StudioStyleGuideColor.ButtonText),
									Font = Enum.Font.Gotham,
								},
								Callback = function()
									local part = new("Part")({
										Size = Vector3.new(1, 1, 1),
										Name = "VFXPart",
										Parent = workspace,
										Transparency = 1,
										[children] = {
											new("Attachment")({}),
										},
									})

									part.Position = (camera.CFrame * CFrame.new(0, 0, -5)).Position
									selection:Add({ part.Attachment })
								end,
								AutoSize = true,
								Ripple = true
							}),
						},
					}),
				},
			}),
		},
	})
end
