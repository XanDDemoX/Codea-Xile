-- Xile

-- Use this function to perform your initial setup

setup = Xile.setup(function(engine)
    
    local x = Xile
    local Data = x.Data
    local Assets = x.Assets
    local Entity = x.Entity
    local System = x.System
    local StateMachine = x.StateMachine
    local Image = x.Image
    local TileMesh = x.TileMesh
    local View = x.View
    local Camera = x.Camera
    local Fps = x.Fps
    
    local assets = Assets("Platformer Art")
    assets:asset(Image,CORNER):add("tile1","Block Grass"):add("tile2","Block Brick"):add("tile3","Block Brick")
    
    local tiles = assets("tile1","tile2","tile3")
  
    local sz = vec2(10,1)
    local tz = vec2(60,60)
    
    local backgr = Xile.TileMap({tile={size=tz}}):load({
                                tiles=tiles,
                                map={1,2,0,1,1,1,1,0,2,1}, 
                                size=sz})
    
        
    local foregr = TileMesh({tile={size=tz}}):load({
                                tiles=tiles,
                                map={0,0,3,0,0,0,0,3,0,0}, 
                                size=sz})
    
    local e = Entity()

    e:add(View({items = {backgr,foregr}}),Camera(),Fps())
    
    local s = System()
    
    s.attach = function(self,engine)
        self.nodes = engine(View,Camera,Fps)
    end
    
    s.draw = function(self)
        
        local view,cam,fps
        
        for n in self.nodes() do
            view,cam,fps = n(View),n(Camera),n(Fps)
            
            cam:begin()
            
            view:draw()
            
            cam:finish()
            
            fps:draw()
        end
    end
    
    s.touched = function(self,touch)
        local view,cam
        for n in self.nodes() do
            view,cam = n(View),n(Camera)
            local t = cam:touch(touch)
            view:touched(t)
        end
    end
    
    engine:add(s,Xile.TouchSystem()):add(e)
    
    --engine:remove(e)
    
    local amt = vec2(tz:unpack())
    
    local cam = e(Camera)
    
    parameter.action("Up",function() cam:move({y=-amt.y}) end)
    parameter.action("Down",function() cam:move({y=amt.y}) end)
    parameter.action("Left",function() cam:move({x=amt.x}) end)
    parameter.action("Right",function() cam:move({x=-amt.x}) end)
    
    parameter.action("Zoom In", function() cam:zoom(0.1) end)
    parameter.action("Zoom Out", function() cam:zoom(-0.1) end)
    
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
    --[[
    perspective()
    camera(0,0,-200,0,0,0)
    ]]--
    engine:draw()
end

function touched(engine,touch)
    engine:touched(touch)
end

function collide(engine,contact)
    engine:collide(contact)
end























