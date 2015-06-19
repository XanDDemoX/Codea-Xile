AgeSystem = class(Xile.System)

function AgeSystem:init(removeEntity)
    self:base().init(self)
    
    removeEntity = removeEntity or function() end
    
    local nodes = self:nodes(Age)
    
    self.update = function(self,time)
        
        local a
        
        for node in nodes() do

            a = node(Age)
            a.age = a.age + (a.inc * time)
            
            if a.age > a.max then
                removeEntity(a.entity)
            end
            
        end
        
    end
    
end

