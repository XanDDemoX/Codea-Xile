
--# Main
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




















--# EditorView

EditorView = Xile.class(Xile.View)

function EditorView:init(args)
    -- you can accept and set parameters here
    
    args = args or {}
    local editor = args.editor
    local items = args.items or {}
    
    self:base().init(self,{items=items})
    
    self.draw = self:hook(self.draw,function(base)
        base(self)
    end)
    
    self.touched = function(self,touch)
        
    end
end


--# AssetsView
AssetsView = class()

function AssetsView:init(x)
    -- you can accept and set parameters here
    self.x = x
end

function AssetsView:draw()
    -- Codea does not automatically call this method
end

function AssetsView:touched(touch)
    -- Codea does not automatically call this method
end

--# GridTile
GridTile = Xile.class(Xile.Image)

function GridTile:init(key)
    self:base().init(self,key,CORNER)
    
    local sw = 2
    
    self.draw = self:hook(self.draw,function(base,self)
        
        local sz = self:size()
        
        if sz == nil then return self end
        
        local hsw = sw/2
        
        translate(hsw,hsw)
        
        base(self)
        
        translate(-hsw,-hsw)
        
        strokeWidth(sw)
        fill(0,0)
        
        rect(0,0,sz.x,sz.y)
        
    end)
end



























--# Editor
Editor = class()

function Editor:init()
    -- you can accept and set parameters here
    
end


--# Project
Project = class()

function Project:init(x)
    -- you can accept and set parameters here
    self.x = x
end

function Project:draw()
    -- Codea does not automatically call this method
end

function Project:touched(touch)
    -- Codea does not automatically call this method
end

--# Serialiser
Serialiser = class()
local from = Xile.from

function Serialiser:init()
    -- you can accept and set parameters here
end

--http://lua-users.org/wiki/TableSerialization
local function ins(tbl,...)
    from({...}):copy(tbl)
end

local function userdata(v)
    local d = {}
    d.x = v.x
    d.y= v.y
    return d
end


function Serialiser:serialise(state,c)
    local str = {}
    
     c = c or ""
    for k,v in pairs(state) do
        local t =type(v)
        if t ~= "function" then
            
            
            if type(k) ~= "number" then
                ins(str,c,k,"=")
            else
                ins(str,c)
            end
            
            if t == "table" then
                ins(str,"{")
                ins(str,self:serialise(v))
                ins(str,"}")
            elseif t == "userdata" then
                ins(str,"{")
                ins(str,self:serialise(userdata(v)))
                ins(str,"}")
            else
                
                ins(str,tostring(v))
                
                c = ","
            end
            --c = ","
        end
    end

    return table.concat(str)
end


--# TilemapState
TilemapState = class()

local function createmap(sz,val)
    local map = {}
    
    for i = 0,sz.x*sz.y do
        table.insert(map,val or 0)
    end
    
    return map
end

local function calcIndex(pos,sz)
    return 1+(sz.x * pos.y) + pos.x
end

function TilemapState:init(args)
    -- you can accept and set parameters here
    args = args or {}
    self.tiles = args.tiles or {}
    self.empty = args.empty
    self.size = args.size or vec2(50,50)
    self.map = args.map or createmap(self.size,1)
    self.shader = args.shader
    self.colours = args.colours
end

function TilemapState:get(pos)
    if pos == nil then return end
    return self.map[calcIndex(pos,self.size)]
end

function TilemapState:set(pos,v)
    if pos == nil then return end
    if type(v) ~= "number" or v < 0 then return end
    self.map[calcIndex(pos,self.size)] = v
end

function TilemapState:has(pos)
    return self:get(pos) ~= nil
end
    
function TilemapState:getData()

end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
