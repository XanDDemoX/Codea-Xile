EntityImageView = Xile.class()

function EntityImageView:init(entity,img)
    
    local _img = img
    
    local _entity = entity
    
    local c = _entity(Collision)
    
    local sz 
    
    self.draw = function(self,width,height)
        if _img == nil then return end
        _img:draw()
        
        --sz = img:size()
        
        --[[
        if c ~= nil then
            local f = fill()
            local m = rectMode()
            rectMode(CENTER)
            fill(0,0)
            rect(0,0, c.size.x* width, c.size.y*height)
            fill(f)
            text("top",0-c.size.x*width*0.5,c.size.y*height*0.5)
            text("left",0-c.size.x*width*0.5,0)
            rectMode(m)
        end
          ]]--
        
        
    end
end

