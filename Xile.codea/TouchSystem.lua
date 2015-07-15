local TouchSystem = Xile.class(Xile.System)
Xile.TouchSystem = TouchSystem

local from = Xile.from

local clear = function(t,max)
    t[BEGAN] = nil
    if max == 1 then
        t[MOVING] = nil
    else
        t[MOVING] = t[MOVING] or {}
        for i=1, #t[MOVING] do
            t[MOVING][i] = nil
        end
        
    end
    t[ENDED] = nil
end

function TouchSystem:init(maxMoving)
    self:base().init(self)
    if maxMoving ~= nil and maxMoving < 1 then maxMoving = nil end
    
    local ids,touches,count,max = {},{},0,maxMoving or 10
    local qry = from(touches)
    
    self.count = function(self)
        return count
    end
    
    self.item = function(self,...)
        local c = select('#',...)
        if c > 0 then
            local it = from({...}):map(function(i) return touches[i] end)
            if c == 1 then
                return it:unpack()
            end
            return it
        else
            return qry:iter()
        end
    end
    
    self.purge = function(self)
        for i,t in ipairs(touches) do
            if t[ENDED] ~= nil then
                clear(t,max)
            end
        end
    end
    
    self.touched = function(self,touch)
        local t
        if touch.state == BEGAN then
            count = count + 1
            ids[touch.id] = count
            
            touches[count] = touches[count] or {}
            
            t = touches[count]
            
            clear(t,max)
            
            t[BEGAN] = touch
            
        elseif ids[touch.id] ~= nil then
            t = touches[ids[touch.id]]
            
            if touch.state == MOVING then
                if max == 1 then
                    t[MOVING] = touch
                else
                    t[MOVING][math.fmod(#t[MOVING]+1,max+1)] = touch
                end
            elseif touch.state == ENDED then
                
                t[ENDED] = touch
                
                ids[touch.id] = nil
                count = count - 1
    
            end
        end
    end
end
