Bullet = class()

function Bullet:init(entity,damage)
    self.entity = entity
    self.damage = damage or 1
end

