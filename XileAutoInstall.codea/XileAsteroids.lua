
--# Main
-- Xile Asteroids
--Xile Main Template

setup = Xile.setup(function(engine)
    
    local x = Xile
    local Assets = x.Assets
    local Image = x.Image
    
    local assets = Assets("Space Art")
    
    assets:asset(Image,CENTER)
    :add("ship","Red Ship")
    :add("asteroids","Asteroid Large","Asteroid Small")
    :add("bullet","Green Bullet")
    
    assets():each(function(a) a:load() end)
    
    local factory = EntityFactory(assets,{ship="ship",asteroids="asteroids",bullet="bullet"})
    
    local ship = factory:createSpaceship()
    
    engine:add(RenderSystem())
    :add(MotionSystem())
    :add(ControlSystem(function()
        local b = factory:createBullet(ship,WIDTH,HEIGHT)
        engine:add(b) 
    end,ship(Motion)))
    :add(AgeSystem(function(entity) engine:remove(entity) end))
    :add(HealthSystem(function(entity) engine:remove(entity) end))
    :add(CollisionSystem(vec2(-0.009,-0.009),vec2(0.009,0.009)))
    :add(ship)
    
    local a
    
    for i=1, 15 do
        a = factory:createAsteroid(WIDTH,HEIGHT)
        engine:add(a)
    end
    
    fps = Xile.Fps()
    
end)

function update(engine)
    engine:update(DeltaTime)
end

function draw(engine)
    
    -- This sets a dark background color
    background(40, 40, 50)
    
    -- This sets the line thickness
    strokeWidth(5)
    
    -- Do your drawing here
    
    engine:draw(WIDTH,HEIGHT)
    
    fps:draw()
end

function touched(engine,touch)
    engine:touched(touch)
end

function collide(engine,contact)
    engine:collide(contact)
end
























--# EntityFactory
EntityFactory = class()

local Entity = Xile.Entity
local StateMachine = Xile.StateMachine
local Display = Xile.Data.Display
local Position = Xile.Data.Position
local Health = Xile.Data.Health

local function rand_real(min,max)
    return min + (max-min) * math.random()
end

local function rand_vec(min,max)
    return vec2(rand_real(min,max),rand_real(min,max))
end

function EntityFactory:init(assets,keys)
    
    self.createSpaceship = function(self)
        local e = Entity()
        
        local s = StateMachine(e)
        
        local ship = Spaceship(e,s)
        
        local img = assets(keys.ship)
        
        s:new("alive"):add(Display(SpaceshipView(e,img)))
        s:new("dead")
        
        e:add(ship)
        :add(Position(vec2(0.5,0.5),0.5))
        :add(Motion())
        
        s:set("alive")
        
        return e
    end
    
    self.createAsteroid = function(self,width,height)
        local e = Entity()
        
        local imgs = assets(keys.asteroids)
        
        local img = imgs[math.random(1,#imgs)]
        
        local sz = img:size()*0.75

        e:add(Asteroid(e))
        :add(Position(rand_vec(0.0,1.0),rand_real(-1,1)))
        :add(Motion(rand_vec(-0.009,0.009),rand_real(-0.019,0.019)))
        :add(Collision(vec2(sz.x/width,sz.y/height)))
        :add(Display(AsteroidView(e,img)))
        :add(Health(1))
        
        return e
    end
    
    self.createBullet = function(self,ship,width,height)
        local e = Entity()
        
        local p = ship(Position)
        local pp,pa = p.value,p.angle
        
        local img = assets(keys.bullet)
        local sz = img:size()
    
        
        e:add(Bullet(e))
        :add(Collision(math.max(sz.x/width,sz.y/height)/2))
        :add(Display(BulletView(e,img)))
        :add(Position(vec2(pp.x,pp.y),pa))
        :add(Motion(vec2(0.0,-0.8)))
        :add(Age(e,1))
        
        return e
    end
    
    self.createController = function()
        
        local e = Entity()
        
        local view = ControllerView()
        :add(0,0,2,1)
        :add(0,1,1,1)
        :add(1,1,1,1)
        :add(0,2,2,1)
        
        e:add(Position(vec2(0,0)))
        :add(Display(view))
        
        return e
    end
    
    
end


--# HealthSystem
HealthSystem = class(Xile.System)

local Health = Xile.Data.Health

function HealthSystem:init(removeEntity)
    self:base().init(self)
    
    removeEntity = removeEntity or function() end
    
    local nodes = self:nodes(Asteroid,Health)
    
    self.update = function(self,time)
        
        local a
        
        for node in nodes() do

            h = node(Health)
            
            if h.value <= 0 then
                removeEntity(node(Asteroid).entity)
            end
            
        end
        
    end
    
end

--# AgeSystem
AgeSystem = class(Xile.System)

function AgeSystem:init(removeEntity)
    self:base().init(self)
    
    removeEntity = removeEntity or function() end
    
    local nodes = self:nodes(Age)
    
    self.update = function(self,time)
        
        local a
        
        for node in nodes() do

            a = node(Age)
            a.age = a.age + (a.inc * time)
            
            if a.age > a.max then
                removeEntity(a.entity)
            end
            
        end
        
    end
    
end


--# ControlSystem
ControlSystem = class(Xile.TouchSystem)

function ControlSystem:init(createBullet,motion)
    self:base().init(self,1)
    
    local m = motion
    
    self.update = function(self,time)
        
        local t = self:item(1)
        
        if t == nil then return end
        
        if t[MOVING] then
            m.velocity = vec2(t[MOVING].deltaX/WIDTH,t[MOVING].deltaY/HEIGHT) * 10
        end
        
        if t[ENDED] then
            createBullet()
            self:purge()
        end
        
       
        
    end
    
    
end

--# MotionSystem
MotionSystem = class(Xile.System)

local Position = Xile.Data.Position

function MotionSystem:init()
    self:base().init(self)
    
    local nodes = self:nodes(Motion,Position)
    
    self.update = function(self,time)
        local pos
        local m,vel,sp
        local node
        for node in nodes() do
            
            pos = node(Position)
            m = node(Motion)
            vel = m.velocity
            sp = m.spin
            
            pos.value = pos.value + (vel * time)
            pos.angle = pos.angle + (sp * time)
        end
    end
end

--# RenderSystem
RenderSystem = class(Xile.System)

local Position = Xile.Data.Position
local Display = Xile.Data.Display

function RenderSystem:init()
    self:base().init(self)
    
    local nodes = self:nodes(Display,Position)
    
    self.draw = function(self,width,height)
        
        pushMatrix()
        
        local pos,a = vec2(0,0),0
        local p,pp,pa

        for node in nodes() do
            
            p = node(Position)
            pp,pa = p.value,p.angle
            
            pos.x = pp.x * width 
            pos.y = pp.y * height
            
            a = pa * 360
            
            translate(pos.x,pos.y)
            rotate(a)
            
            node(Display).view:draw(width,height)
            
            rotate(-a)
            translate(-pos.x,-pos.y)
            
        end
        
        
        popMatrix()
    end
    
end

--# CollisionSystem
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


--# Motion
Motion = class()

function Motion:init(velocity,spin)
    self.velocity = velocity or vec2()
    self.spin = spin or 0
end

--# Collision
Collision = class()

function Collision:init(size)
    if type(size) == "number" then
        self.size = vec2(size,size)*2
    else
        self.size = size
    end
end

--# Age
Age = class()

function Age:init(entity,max,inc,age)
    self.entity = entity
    self.age = age or 0
    self.max = max or 1
    self.inc = inc or 1
end

--# Spaceship
Spaceship = class()

function Spaceship:init(entity,fsm)
    self.entity = entity
end

--# Asteroid
Asteroid = class()

function Asteroid:init(entity)
    self.entity = entity
end


--# Bullet
Bullet = class()

function Bullet:init(entity,damage)
    self.entity = entity
    self.damage = damage or 1
end


--# ControllerView
ControllerView = class()

function ControllerView:init(args)
    args = args or {}
    
    local sz = vec2(75,75)
    
    local buttons = args.buttons or {}
    
    local button = function(x,y,w,h)
        rect(x*sz.x,y*sz.y,w*sz.x,h*sz.y)
    end
    
    self.add = function(self,x,y,w,h)
        table.insert(buttons,{x=x,y=y,w=w,h=h})
        return self
    end
    
    self.draw = function()
        
        for i,v in ipairs(buttons) do
            button(v.x,v.y,v.w,v.h)
        end
        
    end
    
end



--# EntityImageView
EntityImageView = Xile.class()

function EntityImageView:init(entity,img)
    
    local _img = img
    
    local _entity = entity
    
    local c = _entity(Collision)
    
    local sz 
    
    self.draw = function(self,width,height)
        if _img == nil then return end
        _img:draw()
        
        --sz = img:size()
        
        --[[
        if c ~= nil then
            local f = fill()
            local m = rectMode()
            rectMode(CENTER)
            fill(0,0)
            rect(0,0, c.size.x* width, c.size.y*height)
            fill(f)
            text("top",0-c.size.x*width*0.5,c.size.y*height*0.5)
            text("left",0-c.size.x*width*0.5,0)
            rectMode(m)
        end
          ]]--
        
        
    end
end


--# BulletView
BulletView = class(EntityImageView)

function BulletView:init(...)
    self:base().init(self,...)
end


--# AsteroidView
AsteroidView = class(EntityImageView)

function AsteroidView:init(...)
    self:base().init(self,...)
end

--# SpaceshipView
SpaceshipView = class(EntityImageView)

function SpaceshipView:init(...)
    self:base().init(self,...)
    
end
