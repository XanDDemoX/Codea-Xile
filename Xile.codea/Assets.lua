local Assets = Xile.class()
Xile.Assets = Assets

Assets.__call = function(self,...) return self:item(...) end

local from = Xile.from

function Assets:init(pack)
    local _pack = pack
    local _prefix = _pack..":"
    
    local _types = {}
    
    local _assets = {}
    
    local assetGet = function (k)
        local asset = _assets[k]
        if asset == nil then return end
        if asset.objects == nil then
            asset.objects = asset:create()
        end
        return asset.objects
    end
    
    
    self.asset = function(self,create,...)
        local t = _types[create]
        
        if t == nil then
            t = {}
            _types[create] = t
        end
        
        local args = {...}
        
        t.add=function(self,alias,...)
            if alias == nil then return self end
            local arg = {...}
            local a = {
            type = create,
            }
            
            if #arg > 1 then
                a.create=function(self) 
                    return from(arg):map(function(k) return create(_prefix..k,unpack(args)) end):array()
                end
            else
                a.create=function(self) 
                    return {create(_prefix..arg[1] or alias,unpack(args))}
                end
            end
            
            _assets[alias] = a
            
            return self
        end
        
        return t
    end
    
    self.item = function(self,...)
        local arg = {...}
        local c = #arg
        if c == 1 then
            local i = from(arg):map(assetGet):flatten(1):array()
            if #i > 1 then
                return i
            else
                return unpack(i)
            end
        elseif c > 1 then
            return from(arg):map(assetGet):flatten(1)
        else
            return from(_assets):keys():map(assetGet):flatten(1)
        end
    end
    
end
