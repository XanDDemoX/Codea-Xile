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
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
