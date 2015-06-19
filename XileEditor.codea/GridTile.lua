GridTile = Xile.class(Xile.Image)

function GridTile:init(key)
    self:base().init(self,key,CORNER)
    
    local sw = 2
    
    self.draw = self:hook(self.draw,function(base,self)
        
        local sz = self:size()
        
        if sz == nil then return self end
        
        local hsw = sw/2
        
        translate(hsw,hsw)
        
        base(self)
        
        translate(-hsw,-hsw)
        
        strokeWidth(sw)
        fill(0,0)
        
        rect(0,0,sz.x,sz.y)
        
    end)
end


























