ControllerView = class()

function ControllerView:init(args)
    args = args or {}
    
    local sz = vec2(75,75)
    
    local buttons = args.buttons or {}
    
    local button = function(x,y,w,h)
        rect(x*sz.x,y*sz.y,w*sz.x,h*sz.y)
    end
    
    self.add = function(self,x,y,w,h)
        table.insert(buttons,{x=x,y=y,w=w,h=h})
        return self
    end
    
    self.draw = function()
        
        for i,v in ipairs(buttons) do
            button(v.x,v.y,v.w,v.h)
        end
        
    end
    
end


