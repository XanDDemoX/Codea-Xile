-- Xile Asteroids
--Xile Main Template

setup = Xile.setup(function(engine)
    
    local x = Xile
    local Assets = x.Assets
    local Image = x.Image
    
    local assets = Assets("Space Art")
    readImage("Space Art:Asteroid Small")
    
    assets:asset(Image,CENTER)
    :add("ship","Red Ship")
    :add("asteroids","Asteroid Large","Asteroid Small")
    :add("bullet","Green Bullet")
    
    assets():each(function(a) a:load() end)
    
    local factory = EntityFactory(assets,{ship="ship",asteroids="asteroids",bullet="bullet"})
    
    local ship = factory:createSpaceship()
    
    local controller = factory:createController()
    
    engine:add(RenderSystem())
    :add(MotionSystem())
    :add(ControlSystem(function()
        local b = factory:createBullet(ship,WIDTH,HEIGHT)
        engine:add(b) 
    end))
    :add(AgeSystem(function(entity) engine:remove(entity) end))
    :add(CollisionSystem(vec2(-0.009,-0.009),vec2(0.009,0.009)))
    :add(ship)
    :add(controller)
    
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























