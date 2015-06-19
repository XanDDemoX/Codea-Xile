ControlSystem = class(Xile.TouchSystem)

function ControlSystem:init(createBullet)
    self:base().init(self)
    
    
    self.update = function(self,time)
        
        local t = self:item(1)
        
        if t == nil then return end
        
        if t[ENDED] then
            createBullet()
            self:purge()
        end
        
       
        
    end
    
    
end
