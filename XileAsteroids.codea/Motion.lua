Motion = class()

function Motion:init(velocity,spin)
    self.velocity = velocity or vec2()
    self.spin = spin or 0
end
