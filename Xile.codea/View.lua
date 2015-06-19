local View = Xile.class()
Xile.View = View

function View:init(args)
    
    self:base().init(self)
    
    args = args or {}
    
    local items = args.items

    self.draw = function(self)
        for i,v in ipairs(items) do
            if v.draw ~= nil then
                v:draw()
            end
        end
    end
    
    self.touched = function(self,touch)
        for i,v in ipairs(items) do
            if v.touched ~= nil then
                v:touched(touch)
            end
        end
    end
    
end
 























