Collision = class()

function Collision:init(size)
    if type(size) == "number" then
        self.size = vec2(size,size)*2
    else
        self.size = size
    end
end
