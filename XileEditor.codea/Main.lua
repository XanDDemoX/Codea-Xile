-- XileEditor
--Xile._debug = true
-- Use this function to perform your initial setup
setup = Xile.setup(function(engine)
    
    local x = Xile
    local Assets = x.Assets
    local TileMesh = x.TileMesh
    local Image = x.Image
    local View = x.View
    local Camera = x.Camera
    local Fps = x.Fps
    local import = x.import
    
    local Entity = x.Entity
    local System = x.System
    
    display = EditorView({items={}})

    local sz = vec2(10,10)
    local tile = {size=vec2(80,80)}
    
    local assets = Assets("Platformer Art")
    assets:asset(GridTile):add("tile1","Block Grass"):add("tile2","Block Brick"):add("tile3","Block Brick")
    
    local tiles = assets("tile1","tile2","tile3")
    
    local state = TilemapState({tiles=tiles,
                empty=GridTile(),
                size=sz})
    
    
    local tmap = TileMesh({tile=tile}):load(state)
    
    tmap.ontouch:add(function(sender,e)
    
        if e.touch.state == ENDED and e.touch.tapCount >= 2 then
            local pos = tmap:map(e.pos.x,e.pos.y)
            if state:has(pos) then
                tmap:set(pos.x,pos.y,math.fmod(tmap:get(pos.x,pos.y)+1,2))
            end
        end

    end)
            

    local e = Entity()
    
    e:add(View({items = {tmap}}),Camera(),Fps())
    
    local s = System()
    
    s.attach = function(self,engine)
        self.nodes = engine:item(View,Camera,Fps)
    end
    
    s.draw = function(self)
        
        local view,cam,fps
        
        for i=1, self.nodes:count() do
            local n = self.nodes(i)
            view,cam,fps = n(View),n(Camera),n(Fps)
            
            cam:begin()
            
            view:draw()
            
            cam:finish()
            
            fps:draw()
        end
    end
    
    s.touched = function(self,touch)
        local view,cam
        for i=1, self.nodes:count() do
            local n = self.nodes(i)
            view,cam = n(View),n(Camera)
            
            if touch.state ==  MOVING then
                cam:move(vec2(touch.deltaX,touch.deltaY))
            end
            
            local t = cam:touch(touch)
            view:touched(t)
        end
    end
    
    engine:add(s):add(e)
    
    
    local saved
    
    parameter.action("Save", function() 
    
        local s = Serialiser()
        saved = s:serialise(state)
        print("Saved:",saved)
        
    end)
    
    parameter.action("Load",function()
        
        local v,r = import(saved)
        tmap:update(v.map)
        print("Loaded:",saved)
    end)
    
end)

function update(engine)
    engine:update(DeltaTime)
end

-- This function gets called once every frame
function draw(engine)
    -- This sets a dark background color 
    background(40, 40, 50)

    -- This sets the line thickness
    strokeWidth(5)

    engine:draw()
end

function touched(engine,touch)
    
    engine:touched(touch)
    
end



















