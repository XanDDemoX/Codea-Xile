
local ClassBase = class()

function ClassBase:init()
    
end

function ClassBase:base()
    local base = getmetatable(self)
    local b
    self.base = function()
        if base ~= nil then 
            b = b and b._base or base._base
            return b
        end
        b = nil
        return b
    end
    return self:base()
end

function ClassBase:hook(base,func)
    func = func or base
    base = func and base
    return function(...)
        return func and func(base or function() end,...)
    end
end

function ClassBase:extend(source,func)
    if source == nil then return end
    func = func or function(v) return v end
    for k,v in pairs(source) do
        self[k]=func(v)
    end
end

Xile = {}
Xile._debug = false

Xile.class = function(base) 
    return class(base or ClassBase)
end


Xile.try = function(func,catch,finally)
    local values = Xile.pack(xpcall(func,function(err)
        if catch ~= nil then catch(err,debug.traceback()) end
    end))
    if finally  ~= nil then finally() end
    return Xile.unpack(Xile.skip(values,1))
end

Xile.clamp = function(value,min,max)
    return math.min(math.max(value,min),max)
end


local _namespaces = {Xile}
Xile.namespace = function(namespace)
    local n = namespace or {}
    if namespace == nil then
        table.insert(_namespaces,n)
    end
    return n
end

function Xile.setup(func,engine)
    local g = _G
    local newfunc = function()
    
        local _engine = (engine ~= nil and engine()) or Xile.Engine(Xile.EngineCache(Xile.NodeCache(Xile.Node)))
        
        local _draw = g.draw
        local _update = g.update or function() end
        local _touched = g.touched
        local _collide = g.collide or function() end
        
        if g.draw ~= nil then
            g.draw = function()
                _update(_engine)
                _draw(_engine)
            end
        end
        
        if g.touched ~= nil then
            g.touched = function(touch)
                _touched(_engine,touch)
            end 
        end
        
        if g.collide ~= nil then 
             g.collide = function(contact)
                _collide(_engine,contact)
            end
        end
        
        Xile.include = Xile.include()
        
        Xile.type = Xile.reflection(unpack(_namespaces))
        
        func(_engine)
    end
    
    local _debug = Xile._debug
    
    if _debug == true then
        return function() Xile.try(newfunc,print) end
    end

    return newfunc
        
end
