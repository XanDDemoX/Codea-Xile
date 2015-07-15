# Codea-Xile
A lightweight entity component system framework in Lua 5.3 for the Ipad app Codea.

Inspired by: [The Ash Framework By Richard Lord](http://www.ashframework.org)

Please note this not a direct port of the Ash Framework and it has not been tested in "production" circumstances. 

Installation
-------------

Copy the contents of a project from one of the links below and then in Codea press and hold the "Add New Project" button then press the "Paste Into Project" button.

* [Xile Framework](https://raw.githubusercontent.com/XanDDemoX/Codea-Xile/master/XileAutoInstall.codea/Xile.lua)

Example Projects
-------------
Don't forget to set a dependency to the Xile Framework project!

* [Asteriods Example Game](https://github.com/XanDDemoX/Codea-Xile/blob/master/XileAutoInstall.codea/XileAsteroids.lua)

* [Tilemap Editor](https://github.com/XanDDemoX/Codea-Xile/blob/master/XileAutoInstall.codea/XileEditor.lua)

Usage
-------------

1. Import the Xile Framework project into Codea.
2. Create a new project and add a dependency to your Xile Framework project
3. Replace the default "Main" tab with:

```lua
setup = Xile.setup(function(engine)
    
    
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
    
    engine:draw()
end

function touched(engine,touch)
    engine:touched(touch)
end

function collide(engine,contact)
    engine:collide(contact)
end
```

You can pass additional arguments through update, draw, touched and collide:

```lua
function update(engine)
    engine:update(DeltaTime,WIDTH,HEIGHT)
end
```

Components Example
-------------
Components can be any Codea class, inheriting the Component base class is optional.

```lua

-- 2D Position component

Position = class(Component)

function Position:init(value,angle)
    self.value = value or vec2()
    self.angle = angle or 0
end

-- Health component 

Health = class(Component)

function Health:init(value)
    self.value = value or 100
end


-- Display component

Display = class(Component)

local _nullview = {draw =function() end}

function Display:init(view)
    self.view = view or _nullview
end

```

System Example
-------------
Systems must inherit the Xile.System base class and register for nodes using self:nodes(componentType1,componentType2,...) on initialse.

```lua

-- 2D Render system

RenderSystem = class(Xile.System)

local Position = Xile.Data.Position
local Display = Xile.Data.Display

function RenderSystem:init()
    self:base().init(self)
    
	-- Register for Display and Position compents
    local nodes = self:nodes(Display,Position)
    
	-- called on draw
    self.draw = function(self,width,height)
        
        pushMatrix()
        
        local pos,a = vec2(0,0),0
        local p,pp,pa

		-- draw nodes
        for node in nodes() do
            
			-- get the position component
            p = node(Position)
            pp,pa = p.value,p.angle
            
			-- calculate position
            pos.x = pp.x * width 
            pos.y = pp.y * height
            
            a = pa * 360
            
			-- translate to the position 
            translate(pos.x,pos.y)
            rotate(a)
            
			-- draw the display component
            node(Display).view:draw(width,height)
            
			-- translate back to origin
            rotate(-a)
            translate(-pos.x,-pos.y)
            
        end
        
        
        popMatrix()
    end
    
end
```

Setup example
-------------
```lua

local Entity = Xile.Entity
local Position = Xile.Data.Position

setup = Xile.setup(function(engine)
    
	-- create ship entity 
    local shipEntity = Entity()

	
	-- add components 
	shipEntity
		:add(Spaceship(ship))
		:add(Display(SpaceshipView(e,img)))
		:add(Position(vec2(0.5,0.5),0.5))
		:add(Health(150))
		
		
	-- add systems
	engine
		:add(RenderSystem())
		:add(MotionSystem())
	
	
	-- add entities
	engine
		:add(shipEntity)
	
end)

```