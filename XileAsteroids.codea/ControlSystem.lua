ControlSystem = class(Xile.TouchSystem)

function ControlSystem:init(createBullet,motion)
    self:base().init(self,1)
    
    local m = motion
    
    self.update = function(self,time)
        
        local t = self:item(1)
        
        if t == nil then return end
        
        if t[MOVING] then
            m.velocity = vec2(t[MOVING].deltaX/WIDTH,t[MOVING].deltaY/HEIGHT) * 10
        end
        
        if t[ENDED] then
            createBullet()
            self:purge()
        end
        
       
        
    end
    
    
end
