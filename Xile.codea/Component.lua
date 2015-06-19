

local Component = class()
Xile.Component = Component

local _mtcache ={}

local metatable = function(component)
    local mt = _mtcache[component]
    if mt == nil then
        mt = getmetatable(component)
        _mtcache[component] = mt 
    end
    return mt
end

local getname = function(component)
    if component == nil then return nil end
    if type(component) == "string" then return component end
    local name = component.name 
    if name == nil then
        local mt = metatable(component)
        name = (mt and mt.name)
    end
    if name == nil then
        local bt,rt,ct = Xile.type(component)
        name = ct
    end
    name = name or component
    return name
end

local _cache = setmetatable({},{__mode="k"})

Component.getname = function(k) 
    local n = _cache[k]
    if n == nil then
        n = getname(k)
        _cache[k] = n
    end
    return n
end

Component.metatable = metatable

function Component:init()

end

