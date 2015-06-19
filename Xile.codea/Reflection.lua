Xile.reflection = function(...)
    local arg = {...}
    
    -- original built in lua type func
    local _btype = type
    
    -- _G table refs
    local __G = {}
    __G[1] = _G
    
    -- add additional _G table refs (e.g sandboxed dynamically included type tables)
    if #arg > 0 then
        for i,v in ipairs(arg) do
            if _btype(v) == "table" then
                local contains=false
                for ii,vv in ipairs(__G) do
                    if vv == v then
                        contains = true
                        break
                    end
                end
                if contains == false then
                    table.insert(__G,v)
                end
            end
        end
    end
    -- getmetatable shortcut
    local _getmt = getmetatable
    
    -- create cached inverted _G table func (keys and values swapped)
    local _iGfunc=(function()
        local _bd={physics.body(CIRCLE,25),physics.body(CIRCLE,25)}
        _bd[3] = physics.joint(WELD,_bd[1],_bd[2],vec2())
        
        local _uD={vec2,vec3,vec4,matrix,mesh,shader,color,
        {"image",image(1,1)},{"soundbuffer",soundbuffer("",0,0)},
        {"rigidbody",_bd[1]},{"touch",CurrentTouch},{"buffer",mesh():buffer("position")},
        {"joint",_bd[3]}}
        
        -- generate inverted _G and add userdata
        local ig = {} 
       --prefix lookup 
        local prx = {}
        --prx[__G[1]] = ""
        for i,__g in ipairs(__G) do
            for k,v in pairs(__g) do 
                
                for ii=i,#__G do
                    if v == __G[ii] then
                        prx[v] = ((prx[__g] and prx[__g]..".") or "")..k
                    end
                end
                
                ig[v]=((prx[__g] and prx[__g]..".") or "")..k
            end
        end
        
        for k,v in pairs(_uD) do
            if _btype(v) == "table" then ig[_getmt(v[2])]=v[1] else ig[_getmt(v())]=ig[v] end
            _uD[k]=nil
        end
        
        for k,v in pairs(_bd) do
            v:destroy()
            _bd[k] = nil
        end
        
        return ig
    end)
    --create cached inverted _G
    local _iG = _iGfunc()
    
    --real type func (lookup type by meta table in inverted _G cache)
    local _rtype=function(x) return _iG[_getmt(x)] or (_btype(x) == "table" and x.is_a and _iG[x]) end
    
    local typeMeta = {}
    
    -- type func extension, looks up type and typename e.g
    -- userdata vec2
    -- number number
    -- table table
    -- table class classname
    
    typeMeta.__call =function(self,x)
        local t,r = _btype(x),_rtype(x)
        if t =="table" and x.is_a then return t,"class",r else return t,r or t end
    end
    
    local typeClass ={}
    
    -- get type constructor
    typeClass.ctor = function(x)
        local c = typeClass.class(x)
        local mt = _getmt(x)
        -- fast check
        if mt.__call ~= nil or mt._base ~= nil then
            return mt
        end
        -- exhaustive check - could have issues with multiple _Gs with the same type names needs improvement
        local idx = #__G
        local ct = nil
        
        for i=1, #__G do
            idx = idx + -1
            ct = __G[i][c]
            if ct ~= nil then
                return ct
            end
        end
        
        return nil
    end
    
    -- get type classname e.g vec2, number, classname
    typeClass.class=function(x)
        local t,r = _btype(x),_rtype(x)
        return r or t
    end
    -- returns the base type of a class or the class type
    typeClass.base=function(x)
        local c = _getmt(x)
        if c~=nil and c._base then
            return _iG[c._base], c._base
        else
            return _iG[c]
        end
    end
    
    typeClass.is=function(x,y)
        
        local xt,yt = _btype(x),_btype(y)
        
        if xt =="table" and yt == "table" and x.is_a then
            return x:is_a(y)
        elseif yt == "string" then
            return xt == y or _rtype(x) == y
        else
            return xt == yt and _rtype(x) == _rtype(y)
        end
    end
    
    -- returns the heirachy of a class (listed top down) to the base
    typeClass.info=function(x)
        local c={}
        for i,v in ipairs(typeClass.chain(x)) do
            table.insert(c,_rtype(v))
        end
        return c
    end
    
    typeClass.chain=function(x)
        local c,b={},_getmt(x)
        repeat
        if b ~= nil then
            table.insert(c,b)
            if b._base then b=b._base else b= nil end
        end
        until b == nil
        return c
    end
    
    setmetatable(typeClass,typeMeta)
    
    return typeClass
end

