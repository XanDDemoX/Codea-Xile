local Camera = Xile.class()
Xile.Camera = Camera

local function value(val)
    local num = (type(val) == "number" and val)
    local x,y = num or val.x or 0, num or val.y or 0
    return vec2(x,y)
end


function Camera:init(args)
    args = args or {}
    self.pos = args.pos or vec2(0,0)
    self.scale = args.scale or vec2(1,1)
    
    local p,s
    
    self.begin = function(self)
        p,s = self.pos,self.scale
        p = p.x == 0 and p.y==0
        s = s.x == 1 and s.y ==1
        if p == false or s == false then pushMatrix() end
        if s == false then scale(self.scale.x,self.scale.y) end
        if p == false then translate(self.pos.x,self.pos.y) end
        
    end
    
    self.finish =function(self)
        if p == false or s == false then popMatrix() end
    end
    
end

function Camera:move(pos)
    self.pos = self.pos + value(pos)
end

function Camera:zoom(amt)
    self.scale = self.scale + value(amt)
end

local function copytouch(t)
    return {
        id=t.id,
        x=t.x,
        y=t.y,
        prevX=t.prevX,
        prevY=t.prevY,
        deltaX=t.deltaX,
        deltaY=t.deltaY,
        state=t.state,
        tapCount=t.tapCount
    }
end

local function calcOffset(p,x,y)
    return x - p.x, y - p.y
end

local function calcScale(s,x,y)
    return x / s.x, y / s.y
end

function Camera:touch(touch)
    local t = copytouch(touch)
    local p = self.pos
    local s = self.scale
    
    t.x,t.y = calcOffset(p,t.x,t.y)
    t.prevX,t.prevY=calcOffset(p,t.prevX,t.prevY)
    
    t.x,t.y = calcScale(s,t.x,t.y)
    t.prevX,t.prevY=calcScale(s,t.prevX,t.prevY)
    
    t.x = t.x / WIDTH
    t.y = t.y / HEIGHT
    
    t.prevX = t.prevX / WIDTH
    t.prevY = t.prevY / HEIGHT
    
    return t
end

