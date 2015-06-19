local WaveyShader = Xile.class(Xile.Shader)
Xile.WaveyShader = WaveyShader
-- ExampleShader
function WaveyShader:init(freq)
    self:base().init(self,"Documents:Wavey")
    self.freq = freq or 1
    
    self.update = self:hook(self.update,function(base,self)
        base(self)
        self.object.freq  = self.freq
        self.object.time = ElapsedTime
    end)
end