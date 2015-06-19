--Xile Main Template
--[[

setup = Xile.setup(function(engine)
    
    local x = Xile
    
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
    
    engine:draw()
end

function touched(engine,touch)
    engine:touched(touch)
end

function collide(engine,contact)
    engine:collide(contact)
end

]]--




















