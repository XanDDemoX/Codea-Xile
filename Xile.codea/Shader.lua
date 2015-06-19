local Shader = Xile.class(Xile.Asset)
Xile.Shader = Shader
    
function Shader:init(key)

    self:base().init(self,key)
    
    self.load = self:hook(self.load, function(base,self)
        
        base(self)
        
        local key = self:key()
        
        if key == nil then return self end
        
        if self.object == nil then
            self.object = shader(key)
        end
        
        return self
    end)
    
    self.update = function(self)
            
    end
    
    self.dispose = self:hook(self.dispose,function(base,self)
        self.object = nil
        return self
    end)
    
end


 
