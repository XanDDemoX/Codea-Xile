local Node = class()
Xile.Node = Node

Node.__call = function(self,...) return self:item(...) end

local from = Xile.from

local _cache = {}
local getname = Xile.Component.getname


function Node:init()
    
    local items = {}
    
    self.item = function(self,key)
        return items[getname(key)]
    end
    
    self.set = function(self,key,value)
        items[getname(key)] = value
    end
    
    self.clear = function(self)
        from(items):keys():each(function(k)
            items[k]=nil
        end)
    end
end

