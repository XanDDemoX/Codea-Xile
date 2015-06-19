local TileMesh = Xile.class(Xile.TileMap)
Xile.TileMesh = TileMesh

local calcIndex = Xile.TileMap.calcIndex

local imgMax = vec2(2048,2048)

local function calcScan(count,tz,max)
    max = max or imgMax
    local perRow = math.floor(max.x / tz.x)
    local rows = 1 + math.floor(count / perRow)
    return perRow,math.min(rows,math.floor(max.y / tz.y))
end


local function calcTexture(t,count,tz,max)
    local perRow,rows = calcScan(count,tz,max)
    return (1/math.fmod(count,perRow) * math.fmod(t,perRow)),(1/rows) * math.floor((t/perRow)),(1/count),1
end

local function createTexture(tiles,tz,count) 

    local perRow,rows = calcScan(count,tz)
    
    local w,h = tz.x * math.fmod(count,perRow), tz.y * rows
    
    local img = image(w,h)
    setContext(img)
    pushMatrix()
    
    local x,y
    
    for i=0,count-1 do
        
        x,y = calcTexture(i,count,tz)
        x,y = x * img.width, y * img.height
        
        translate(x,y)
        tiles[i]:draw()
        translate(-x,-y)
    end
        
    popMatrix()
    setContext()
    return img
end

local function calcTile(x,y,tz)
    return (tz.x / 2) + (x * tz.x),(tz.y / 2) + (y * tz.y),tz.x,tz.y
end

local defaultTextureColour = color(255,255,255,255)

local function updateTextureRect(m,i,t,count,tz,state,col)
    m:setRectTex(i,calcTexture(t,count,tz))
    m:setRectColor(i,state.colours and state.colours[i] or col or defaultTextureColour)
end

function TileMesh:init(...)
    self:base().init(self,...)
    
    local m,count
    
    self.load = self:hook(self.load,function(base,self,...)
        base(self,...)
        
        local state = self:state()
        
        if state == nil then return self end
        
        local count = self:count()
        local tile = self:tile()
        local tiles = self:tiles()
        
        local img = createTexture(tiles,tile.size,count)
        
        m = mesh()
        m.texture = img
        
        self:update()
        
        return self
    end)

    self.update = self:hook(self.update, function(base,self,...)
        
        base(self,...)
        
        if m == nil then return self end
        
        local state = self:state()
        local tile = self:tile()
        local count = self:count()
        
        m:clear()
        m.shader = state.shader and state.shader.object
        
        local x,y = 0,0
        local sz = state.size
        local tz = tile.size
        
        local i
        local t
        
        for y = 0, sz.y-1 do
            for x = 0, sz.x-1 do
                t = self:get(x,y)
                i = m:addRect(calcTile(x,y,tz))
                
                updateTextureRect(m,i,t,count,tz,state)
            end
        end

        return self
    end)
    
    self.set = self:hook(self.set,function(base,self,x,y,v)
        if m == nil then return self end
        
        base(self,x,y,v)
        
        local state = self:state()
        local tile = self:tile()
        local count = self:count()
        local i = calcIndex(x,y,state.size)
        
        updateTextureRect(m,i,self:get(x,y),count,tile.size,state)
        
        return self
    end)
    
    self.draw = function(self)
        if m == nil then return end
        
        if m.shader ~= nil then
            local state = self:state()
            state.shader:update()
        end
        
        m:draw() 
        
    end

end

















