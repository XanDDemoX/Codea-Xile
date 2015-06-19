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

