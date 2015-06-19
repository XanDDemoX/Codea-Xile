RenderSystem = class(Xile.System)

local Position = Xile.Data.Position
local Display = Xile.Data.Display

function RenderSystem:init()
    self:base().init(self)
    
    local nodes = self:nodes(Display,Position)
    
    self.draw = function(self,width,height)
        
        pushMatrix()
        
        local pos,a = vec2(0,0),0
        local p,pp,pa

        for node in nodes() do
            
            p = node(Position)
            pp,pa = p.value,p.angle
            
            pos.x = pp.x * width 
            pos.y = pp.y * height
            
            a = pa * 360
            
            translate(pos.x,pos.y)
            rotate(a)
            
            node(Display).view:draw(width,height)
            
            rotate(-a)
            translate(-pos.x,-pos.y)
            
        end
        
        
        popMatrix()
    end
    
end
