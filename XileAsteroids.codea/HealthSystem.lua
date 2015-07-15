HealthSystem = class(Xile.System)

local Health = Xile.Data.Health

function HealthSystem:init(removeEntity)
    self:base().init(self)
    
    removeEntity = removeEntity or function() end
    
    local nodes = self:nodes(Asteroid,Health)
    
    self.update = function(self,time)
        
        local a
        
        for node in nodes() do

            h = node(Health)
            
            if h.value <= 0 then
                removeEntity(node(Asteroid).entity)
            end
            
        end
        
    end
    
end
