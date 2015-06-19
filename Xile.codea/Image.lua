local Image = Xile.class(Xile.Asset)
Xile.Image = Image

local function resize(img,sz)
    if img.width == sz.x and img.height == sz.y then return img end
    local new = image(sz.x,sz.y)
    setContext(new)
    pushMatrix()
    pushStyle()
    spriteMode(CORNER)
    sprite(img,0,0,sz.x,sz.y)
    popStyle()
    popMatrix()
    setContext()
    return new
end

function Image:init(key,mode)
    self:base().init(self,key)
    
    local img,sp
    
    local size
    self.size = function(self)
        return size
    end
    
    self.load = self:hook(self.load,function(base,self,sz)
    
        base(self)
        
        size = sz
        
        local key = self:key()
        
        if key == nil then return self end
        
        if img == nil then
            img = readImage(key)
        end
        
        if size == nil then
            size = vec2(img.width,img.height)
        end
        
        sp = resize(img,size)
        
        return self
    end)

    self.draw = self:hook(self.draw,function(base,self)
        base(self)
        if sp ~= nil then 
            
            local cur
            
            if mode ~= nil then
                cur = spriteMode()
                if mode ~= cur then
                    spriteMode(mode)
                else 
                    cur = nil
                end
            end
            
            sprite(sp,0,0) 
            
            if cur ~= nil then
                spriteMode(cur)
            end
        end
    end)
    
    self.dispose = self:hook(self.dispose,function(base,self)
        img = nil
        sp = nil
        return self
    end)
end























