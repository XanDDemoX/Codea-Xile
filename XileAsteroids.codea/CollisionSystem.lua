CollisionSystem = class(Xile.System)


local normal = function(px,py,x,y)
--http://stackoverflow.com/questions/1243614/how-do-i-calculate-the-normal-vector-of-a-line-segment
    -- normals = (-dy,dx) (dy,-dx)
    x=x or 1
    y=y or 1
    return vec2(x*(py.y-px.y),y*(py.x-px.x)):normalize()
end

local bounce = function(v,n)
--http://stackoverflow.com/questions/573084/how-to-calculate-bounce-angle
    local u = v:dot(n) * n
    local w = v - u
    return w - u
end


local collide = function(px,sx,py,sy,ax,ay)
    --[[http://gamedev.stackexchange.com/questions/29786/
    a-simple-2d-rectangle-collision-algorithm-that-also-determines-which-sides-that]]--
    ax=ax or 0
    ay=ay or 0
    
    local d = px-py
    local s = 0.5 * (sx + sy)
    
    if math.abs(d.x) <= s.x and math.abs(d.y) <= s.y then
        local wy,hx = d.x * s.x, d.y * s.y
        
        local cx,cy = vec2(0,0),vec2(0,0)
        
        local p = px
        local hs = sx * 0.5
        local a = ax
        
        if wy > hx then
            
            if wy > -hx then
                -- top
                cx.x,cx.y = p.x-hs.x,p.y+hs.y
                cy.x,cy.y = p.x+hs.x,p.y+hs.y
            else
                --left
                cx.x,cx.y = p.x-hs.x,p.y+hs.y
                cy.x,cy.y = p.x-hs.x,p.y-hs.y
            end
            return true, normal(cx,cy,-1,1)
        else
            
            if wy > -hx then
                -- bottom
                cx.x,cx.y = p.x-hs.x,p.y-hs.y
                cy.x,cy.y = p.x+hs.x,p.y-hs.y
            else
                --right
                cx.x,cx.y = p.x+hs.x,p.y+hs.y
                cy.x,cy.y = p.x+hs.x,p.y-hs.y
            end
            return true, normal(cx,cy,1,-1)
        end
        --return true,normal(cx,cy,-1,1),(cx-p):rotate(a)+p,(cy-p):rotate(a)+p
    end
    return false
end

local clamp = function(v,min,max)
    return math.min(math.max(v,min),max)
end

local sign = function(s)
    if s > 0 then return 1 end
    return -1
end

local signvec = function(v,s)
    return vec2(sign(s.x)*v.x,sign(s.y)*v.y)
end

local clampvec = function(v,min,max)
    if min == nil or max == nil then return v end
    return vec2(clamp(v.x,min.x,max.x),clamp(v.y,min.y,max.y))
end

local rand = function(min,max) return min + (max-min) * math.random() end

local Position = Xile.Data.Position
local Health = Xile.Data.Health

function CollisionSystem:init(minAsteroidVelocity,maxAsteroidVelocity)
    self:base().init(self)

    
    local asteroids = self:nodes(Asteroid,Position,Motion,Collision,Health)
    local bullets = self:nodes(Bullet,Position,Collision,Age)
    
    local c = 0
    
    local nodes = self:nodes(Collision,Position)
    
    local draw = function(self,w,h)
        rectMode(CENTER)
        fill(0,0)
        for n in nodes() do
            local p = n(Position)
            local a = math.rad(360*p.angle)
            p = p.value
            local s = n(Collision).size
            local hs = s * 0.5
            
            rect(p.x* w,p.y*h,s.x*w,s.y*h)
            local p1,p2 = vec2(p.x,p.y-hs.y),vec2(p.x,p.y+hs.y)
            p1,p2 = (p1-p):rotate(a)+p,(p2-p):rotate(a)+p
            
            line(p1.x*w,p1.y*h,p2.x*w,p2.y*h)
            
            p1,p2 = vec2(p.x-hs.x,p.y),vec2(p.x+hs.x,p.y)
            
            p1,p2 = (p1-p):rotate(a)+p,(p2-p):rotate(a)+p
            line(p1.x*w,p1.y*h,p2.x*w,p2.y*h)
            
        end
        
        
    end
    
   -- self.draw = draw
    
    local collideBullets = function(px,sx,a)
        local py,sy
        for b in bullets() do
            
            py = b(Position).value
            sy = b(Collision).size
            
            if collide(px,sx,py,sy) == true then
                a(Health).value = a(Health).value - b(Bullet).damage
                b(Age).age = b(Age).max
            end
            
        end
    end
    
    
    local collideAsteroids = function(px,sx,ax,a,time,minv,maxv)
        
        local py,ay,sy
        
        for aa in asteroids() do
            
            if a ~= aa then
                
                py = aa(Position).value
                ay = math.rad(aa(Position).angle*360)
                sy = aa(Collision).size
                
                local c,n1,n2 = collide(px,sx,py,sy,ax,ay)
                
                if c == true then
                    
                    local npx,npy = px,py
                    
                    if sx.x < sy.x and sx.y < sy.y then
                        npx = px + (px-py) * time
                    elseif sx.x >= sy.x and sx.y >= sy.y then
                        npy = py + (py - px) * time
                    end
                    
                    c = collide(npx,sx,npy,sy,ax,ay)
                    
                    if c == false then
                        
                        local v1,v2 =a(Motion).velocity, aa(Motion).velocity
                        
                        c,n2 = collide(py,sy,px,sx,ay,ax)
                        
                        if sx.x < sy.x and sx.y < sy.y then
                            a(Motion).velocity = bounce(clampvec(v2+(v2-v1),minv,maxv),n1)
                        elseif sx.x > sy.x and sx.y > sy.y then
                            aa(Motion).velocity = bounce(clampvec(v1+(v1-v2),minv,maxv),n2)
                        elseif sx.x == sy.x and sx.y == sy.y then
                            a(Motion).velocity = bounce(clampvec(v2+(v2-v1),minv,maxv),n1)
                            aa(Motion).velocity = bounce(clampvec(v1+(v1-v2),minv,maxv),n2)
                        end
                        

                        
                    end
                    px = npx
                    a(Position).value = npx
                    aa(Position).value = npy
                    
                end
                
            end
            
        end
        
    end
    
    
    self.update = function(self,time)
        
        local px,sx,ax,py,sy,ay
        
        for a in asteroids() do
            px = a(Position).value
            ax = math.rad(a(Position).angle*360)
            sx = a(Collision).size
            
            collideBullets(px,sx,a)
            
            collideAsteroids(px,sx,ax,a,time,minAsteroidVelocity,maxAsteroidVelocity)
            
        end
        
    end
    
    
    
    
end

