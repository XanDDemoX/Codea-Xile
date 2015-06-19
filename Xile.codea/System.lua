local System = Xile.class()
Xile.System = System

local from = Xile.from

function System:init()
    
    local _nodes = {}
    
    local _qry = from(_nodes):keys()
    
    -- important assumes first arg to be key
    self.nodes = function(self,...)
        local key = select(1,...)
        local item = _nodes[key]

        if item == nil then
            local l =Xile.List()
            item = {
                keys={...},
                list = l,
                add=function(sender,e) l:add(e.node) end,
                remove=function(sender,e) l:remove(e.node) end,
                attach = function(self,engine) 
                    local n = engine:item(unpack(self.keys))
                    n:onadd():add(self.add)
                    n:onremove():add(self.remove)
                end,
                detach = function(self,engine) 
                    local n = engine:item(unpack(self.keys))
                    n:onadd():remove(self.add)
                    n:onremove():remove(self.remove)
                end
            }
            _nodes[key] = item
        end
        
        return item.list
    end
    
    self.attach = function(self,engine)
        _qry:each(function(k)
             _nodes[k]:attach(engine)
        end)
    end
    
    self.detach = function(self,engine)
        _qry:each(function(k)
            _nodes[k]:detach(engine)
            _nodes[k] = nil
        end)
    end
    
    self.dispose = function(self)
        _nodes = nil
        _qry = nil
    end
    
end





