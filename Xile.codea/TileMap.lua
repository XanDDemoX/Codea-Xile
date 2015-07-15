local TileMap = Xile.class()
Xile.TileMap = TileMap

local event = Xile.event
local from = Xile.from

TileMap.calcIndex = function(x,y,sz) return 1+(sz.x * y) + x end

function TileMap:init(args)
    self:base().init(self)
    args = args or {}
    
    local state = args.state
    -- size
    local tile = args.tile or {}
    local tiles,count
    
    local calcIndex = function(x,y) return TileMap.calcIndex(x,y,state.size) end
    
    local raiseTouch
    self.ontouch,raiseTouch = event()
    
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

        tiles = {}
        tiles[0] = state.tiles[0] or state.empty or {visible=false,load =function() end, draw=function() end}
        
        tiles = from(state.tiles)(tiles):each(function(i) i:load(tile.size) end):array()
        
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
    
    self.map = function(self,x,y)
        local sz = self:size()
        local tz = tile.size
        return vec2(math.floor((x * sz.x) / tz.x), math.floor((y * sz.y) / tz.y))
    end
    
    self.get = function (self,mapX,mapY)
        return state.map[calcIndex(mapX,mapY)]
    end
    
    self.set = function(self,mapX,mapY,value)
        state.map[calcIndex(mapX,mapY)] = value
        return self
    end
    
    self.draw = function(self)
        
        if state == nil then return end
    
        pushMatrix()
        
        local t
        local pos = vec2(0,0)
        local sz = state.size
        local tz = tile.size
        
        for y=0,sz.y-1 do
 
            for x=0, sz.x-1 do
                
                t = state.map[calcIndex(x,y)]
                t = tiles[t]
                
                if t~= nil then
                    pos.x, pos.y = x * tz.x, y * tz.y
                    t:draw()
                end
                translate(tz.x,0)
            end
            translate(-sz.x * tz.x,tz.y)
        end
        
        popMatrix()
    end
    
    self.hitTest = function(self,x,y)
        local sz = self:size()
        x = x / (sz.x / WIDTH)
        y = y / (sz.y / HEIGHT)
        if x >= 0 and y >= 0 and x <= 1 and y <= 1 then
            return x,y
        end
    end
    
    self.touched = function(self,touch)
        
        local t = touch
        -- bounds test
        
        local x,y = self:hitTest(t.x,t.y)
        local px,py = self:hitTest(t.prevX,t.prevY)
        
        if x and y then
            raiseTouch(self,{pos=vec2(x,y),
                             prev=px and py and vec2(px,py),
                             touch=t})
        end
    end

end

















