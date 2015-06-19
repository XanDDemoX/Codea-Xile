local NodeCache = class()
Xile.NodeCache = NodeCache
local from = Xile.from
function NodeCache:init(factory)
    
    local _nodes = {}
    
    self.new = function(...)
        local c= #_nodes
        if c > 0 then
            local n = _nodes[c]
            table.remove(_nodes)
            return n
        else
            return factory(...)
        end
    end
    
    self.dispose = function(self,node)
        node:clear()
        table.insert(_nodes,node)
    end
end

