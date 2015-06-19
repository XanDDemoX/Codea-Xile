local List = Xile.class()
Xile.List = List

List.__call = function(self,...) return self:item(...) end

local from = Xile.from

function List:init(...)
    
    local items = {}

    local count = 0
        
    self.add = function(self,...)
        for i,v in ipairs({...}) do
            count = count + 1
            items[count] = v
        end
        return self
    end
    
    self.remove = function(self,...)
        local arg = {...}

        for i=1, count do
            
            for ii,v in ipairs(arg) do
                if v == items[i] then
                    table.remove(items,i)
                    table.remove(arg,ii)
                    count = count -1
                end
            end
            if items[i] == nil or #arg <1 then 
                break
            end
        end

        return self
    end
    
    self.clear = function(self)
        for i=1,count do
            items[i]=nil
        end
        count = 0
        return self
    end
    
    self.count = function(self)
        return count
    end
    
    self.contains = function(self,...)
        local arg = {...}

        for i=1, count do
            
            for ii,v in ipairs(arg) do
                if v == items[i] then
                    table.remove(arg,ii)
                end
            end
            if #arg <1 then 
                return true
            end
        end
        
        return false
    end
    
    self.item = function(self,...)
        local ac = select('#',...)
        if ac == 0 then
            local i = 0
            return function() 
                i=i+1
                return items[i]
            end
        elseif ac == 1 then
            return items[select(1,...)]
        elseif ac > 1 then
            return from({...}):map(function(i)
                return items[i]
            end)
        end
    end
    
    self.array = function(self,...)
        return Xile.copy(items)
    end
    
    self.iter = function(self)
        return Xile.iter(items)
    end
    
    self:add(...)
end

