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
        :add(Health(100))
        
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
    
    
end

