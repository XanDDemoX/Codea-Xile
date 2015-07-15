local Fps = Xile.class()
Xile.Fps = Fps

function Fps:init()
    
    self:base().init(self)
    
    local fps = 0
    local ideal = 60
    
    self.value = function()
        return fps
    end
    
    self.draw = function()
        if self.visible == false then return end
        fps = (fps*0.9)+(1/(DeltaTime)*0.1)
        local val = 255 * Xile.clamp(fps / ideal,0,1)
        pushStyle()
        fill(255-val, val,0, 255)
        text(tostring(fps),WIDTH-80,HEIGHT-20)
        popStyle()
    end
end
