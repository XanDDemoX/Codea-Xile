Age = class()

function Age:init(entity,max,inc,age)
    self.entity = entity
    self.age = age or 0
    self.max = max or 1
    self.inc = inc or 1
end
