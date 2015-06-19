local TileMap,xi = Xile.class(Xile.Element)
xi.TileMap = TileMap

function TileMap:init(args)
    self:base().init(self)
    args = args or {}
    
    local state = args.state
    -- size
    local tile = args.tile or {}
    local tiles,count
    
    local calcIndex = function(x,y) return 1+(state.size.x * y) + x end
    
    local raiseTouch
    self.ontouch,raiseTouch = xi.Event()
    
    self.tiles = function(self)
        return tiles
    end
    
    self.count = function(self)
        return count
    end
    
    self.tile = function(self)
        return tile
    end
    
    self.state = function(self)
        return state
    end
    
    self.load = function(self,s)
        if s ~= nil then state = s end
        
        if state == nil then return self end

        tiles = xi(state.tiles):map(function(i) return i:load(tile.size) end):array()
        
        tiles[0] = state.empty or {visible=false,load = function() end, draw=function() end}
        
        tiles[0]:load(tile.size)
        
        count = #tiles+1
        
        return self
    end
    
    self.update = function(self,newMap)
        if state == nil then return self end
        state.map = newMap or state.map
        return self
    end
    
    self.size = function(self)
        return vec2(tile.size.x * state.size.x,tile.size.y * state.size.y)
    end
    
    self.screen = function(self,mapX,mapY)
        local sz = tile.size
        return vec2(mapX*sz.x,mapY*sz.y)
    end
    
    self.map = function(self,sx,sy)
        return vec2(math.floor(sx / tile.size.x), math.floor(sy / tile.size.y))
    end
    
    self.get = function (self,mapX,mapY)
        return state.map[calcIndex(mapX,mapY)]
    end
    
    self.draw = function(self)
        
        if state == nil then return end
    
        pushMatrix()
        
        local t
        local pos
        local sz = state.size
        local tz = tile.size
        
        for y=0,sz.y-1 do
 
            for x=0, sz.x-1 do
                
                t=tiles[self:get(x,y)]
                
                if t~= nil and t.visible == true then
                    pos = self:screen(x,y)
                    
                    t:draw()
                
                end
                translate(tz.x,0)
            end
            translate(-sz.x * tz.x,tz.y)
        end
        
        popMatrix()
    end
    
    self.hittest = function(self,x,y)
       local sz = self:size()
       return x > 0 and y > 0 and x <= sz.x and y <= sz.y
    end
    
    
    self.touched = function(self,touch)
        
        local t = touch
        -- bounds test
        if self:hittest(t.x, t.y) then
            raiseTouch(self,{pos=self:map(t.x,t.y),
                             prev=self:map(t.prevX,t.prevY),
                             touch=t})
        end
    end

end

















