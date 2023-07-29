local root = script.Parent.Parent.Parent
local packages = root.Packages
local utility = root.Utility
local components = script.Parent.Parent

local fusion = require(packages.fusion)
local themeHandler = require(utility.themeHandler)

type properties = {
    Instance: Instance,
    PropertyData: {
        Title: string,
        Properties: {
            string
        }
    }
}

return function(props: properties)
    -- category = divider + property editors
end 