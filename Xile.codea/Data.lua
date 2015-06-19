Xile.Data = Xile.namespace(Xile.Data)
local Data = Xile.Data
local Component = Xile.Component

local Position = class(Component)

Data.Position = Position

function Position:init(value,angle)
    self.value = value or vec2()
    self.angle = angle or 0
end


local Health = class(Component)

Data.Health = Health

function Health:init(value)
    self.value = value or 100
end

local Display = class(Component)

Data.Display = Display

local _nullview = {draw =function() end}

function Display:init(view)
    self.view = view or _nullview
end
