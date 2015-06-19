MotionSystem = class(Xile.System)

local Position = Xile.Data.Position

function MotionSystem:init()
    self:base().init(self)
    
    local nodes = self:nodes(Motion,Position)
    
    self.update = function(self,time)
        local pos
        local m,vel,sp
        local node
        for node in nodes() do
            
            pos = node(Position)
            m = node(Motion)
            vel = m.velocity
            sp = m.spin
            
            pos.value = pos.value + (vel * time)
            pos.angle = pos.angle + (sp * time)
        end
    end
end
