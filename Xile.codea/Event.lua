local List = Xile.List
Xile.event = function()
    
    local evt = {}
    
    local handlers = List()
    
    evt.add = function(self,func)
        if type(self) == "function" then func = self end
        if func == nil then return end
        handlers:add(func)
    end
    
    evt.remove = function(self,func)
        if type(self) == "function" then func = self end
        if func == nil then return end
        handlers:remove(func)
    end
    
    evt.count = function(self)
        return handlers:count()
    end
    
    local raise = function(sender,...)
        if sender == nil or handlers:count() < 1 then return end
        
        local tbl = handlers:array()
        
        for i,func in ipairs(tbl) do
            func(sender,...)
        end
    end
    
    return evt,raise
end




















