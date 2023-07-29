local root = script.Parent.Parent.Parent
local packages = root.Packages
local utility = root.Utility
local components = script.Parent.Parent

local fusion = require(packages.fusion)
local themeHandler = require(utility.themeHandler)

type properties = {
    Instance: Instance,
    Property: string,
    CurrentValue: any
}

return function(props: properties)
    
end 