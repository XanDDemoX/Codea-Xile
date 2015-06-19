local Entity = Xile.class()
Xile.Entity = Entity

Entity.__call = function(self,...) return self:item(...) end

local Component = Xile.Component
local from = Xile.from

local newid = (function()
    local _count = 0
    return function()
        _count = _count + 1
        return _count
    end
end)()

local getname = Component.getname

local update = function(self,components,component,raise,value)
    local n = getname(component)
    if n == nil then return end
    components[n] = value
    raise(self,{key=n,value=component})
end

function Entity:init()

    local id = newid()
    
    local components = {}
    local qry = from(components)
    
    local raiseAdded,raiseRemoved
    
    self.onAdded,raiseAdded = Xile.event()
    self.onRemoved,raiseRemoved = Xile.event()
    
    self.id = function(self)
        return id
    end
    
    self.keys = function(self)
        return qry:keys()
    end
    
    self.item = function(self,...)
        local count = select('#',...)
        if count > 0 then
            if count == 1 then
                return components[getname(select(1,...))]
            end
            return from({...}):map(getname):map(function(k) return components[k] end)
        else
            return qry:values()
        end
    end
    
    self.contains = function(self,...)    
        local arg = {...}
        return from(arg):map(getname):all(function(i)
            return components[i] ~= nil 
        end)
    end
    
    self.add = function(self,...)
        local arg = {...}
        from(arg):each(function(component)
            if self:contains(component) == true then return end
            update(self,components,component,raiseAdded,component)
        end)
        
        return self
        
    end
    
    self.remove = function(self,...)
        local arg = {...}
        from(arg):each(function(component)
            if self:contains(component) == false then return end
            update(self,components,component,raiseRemoved,nil)
        end)
        
        return self
    end
    
    self.clear = function(self)
        return self:remove(qry:values():unpack())
    end
    
end
