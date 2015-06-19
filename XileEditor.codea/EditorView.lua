
EditorView = Xile.class(Xile.View)

function EditorView:init(args)
    -- you can accept and set parameters here
    
    args = args or {}
    local editor = args.editor
    local items = args.items or {}
    
    self:base().init(self,{items=items})
    
    self.draw = self:hook(self.draw,function(base)
        base(self)
    end)
    
    self.touched = function(self,touch)
        
    end
end

