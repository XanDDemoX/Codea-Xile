local Asset = Xile.class()
Xile.Asset = Asset

function Asset:init(key)
    
    self:base().init(self)
    
    local _key = key
    
    self.key = function(self)
        return _key
    end
    
    self.load = function(self)
        return self
    end
    
    self.dispose = function(self)
        return self
    end
end



































