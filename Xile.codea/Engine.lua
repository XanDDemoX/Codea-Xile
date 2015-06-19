local Engine = Xile.class()
Xile.Engine = Engine
Engine.__call = function(self,...) return self:item(...) end

local List = Xile.List
local from = Xile.from

function Engine:init(engineCache)
    
    local _system = {update=List(),draw=List(),touched=List(),collide=List()}
    
    local _sysqry = from(_system):keys()
    
    local _cache = engineCache
    
    local entity_update = function(sender,e)
        _cache:update(sender)
    end
    
    local isSystem = function(system)
        return Xile.type.is(system,Xile.System)
    end
    
    local isEntity = function(entity)
        return Xile.type.is(entity,Xile.Entity)
    end
    
    local addSystem = function(system)
        
        _sysqry:each(function(k)
            local sys = _system[k]
            if system[k] ~= nil and sys:contains(system) == false then
                sys:add(system)
            end
        end)
        system:attach(self)
    end
    
    local removeSystem = function(system)
        
        system:detach(self)
        
        _sysqry:each(function(k)
            local sys = _system[k]
            if system[k] ~= nil and sys:contains(system) == true then
                sys:remove(system)
            end
        end)
    end
    
    local addEntity = function(entity)
        _cache:add(entity)
    end
    
    local removeEntity = function(entity)
        _cache:remove(entity)
    end
    
    self.add = function(self,...)
        local arg = {...}
        from(arg):each(function(entity_or_system)
            
            if isEntity(entity_or_system) == true then
                addEntity(entity_or_system)
            elseif isSystem(entity_or_system) == true then
                addSystem(entity_or_system)
            end
            
        end)

        return self
    end
    
    self.remove = function(self,...)
        local arg = {...}
        from(arg):each(function(entity_or_system)
            if isEntity(entity_or_system) == true then
                removeEntity(entity_or_system)
            elseif isSystem(entity_or_system) == true then
                removeSystem(entity_or_system)
            end
        end)

        return self
    end
    
    self.item = function(self,...)
        return _cache(...)
    end
    
    _sysqry:extend(function(k)
        local system = _system[k]
        return k,function(self,...)
            local sys
            for i=1, system:count() do
                sys = system:item(i)
                sys[k](sys,...)
            end
        end
    end,self)
    
end
