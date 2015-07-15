
--# Xile

local ClassBase = class()

function ClassBase:init()
    
end

function ClassBase:base()
    local base = getmetatable(self)
    local b
    self.base = function()
        if base ~= nil then 
            b = b and b._base or base._base
            return b
        end
        b = nil
        return b
    end
    return self:base()
end

function ClassBase:hook(base,func)
    func = func or base
    base = func and base
    return function(...)
        return func and func(base or function() end,...)
    end
end

function ClassBase:extend(source,func)
    if source == nil then return end
    func = func or function(v) return v end
    for k,v in pairs(source) do
        self[k]=func(v)
    end
end

Xile = {}
Xile._debug = false

Xile.class = function(base) 
    return class(base or ClassBase)
end


Xile.try = function(func,catch,finally)
    local values = Xile.pack(xpcall(func,function(err)
        if catch ~= nil then catch(err,debug.traceback()) end
    end))
    if finally  ~= nil then finally() end
    return Xile.unpack(Xile.skip(values,1))
end

Xile.clamp = function(value,min,max)
    return math.min(math.max(value,min),max)
end


local _namespaces = {Xile}
Xile.namespace = function(namespace)
    local n = namespace or {}
    if namespace == nil then
        table.insert(_namespaces,n)
    end
    return n
end

function Xile.setup(func,engine)
    local g = _G
    local newfunc = function()
    
        local _engine = (engine ~= nil and engine()) or Xile.Engine(Xile.EngineCache(Xile.NodeCache(Xile.Node)))
        
        local _draw = g.draw
        local _update = g.update or function() end
        local _touched = g.touched
        local _collide = g.collide or function() end
        
        if g.draw ~= nil then
            g.draw = function()
                _update(_engine)
                _draw(_engine)
            end
        end
        
        if g.touched ~= nil then
            g.touched = function(touch)
                _touched(_engine,touch)
            end 
        end
        
        if g.collide ~= nil then 
             g.collide = function(contact)
                _collide(_engine,contact)
            end
        end
        
        Xile.include = Xile.include()
        
        Xile.type = Xile.reflection(unpack(_namespaces))
        
        func(_engine)
    end
    
    local _debug = Xile._debug
    
    if _debug == true then
        return function() Xile.try(newfunc,print) end
    end

    return newfunc
        
end

--# Main
-- Xile

-- Use this function to perform your initial setup

setup = Xile.setup(function(engine)
    
    local x = Xile
    local Data = x.Data
    local Assets = x.Assets
    local Entity = x.Entity
    local System = x.System
    local StateMachine = x.StateMachine
    local Image = x.Image
    local TileMesh = x.TileMesh
    local View = x.View
    local Camera = x.Camera
    local Fps = x.Fps
    
    local assets = Assets("Platformer Art")
    assets:asset(Image,CORNER):add("tile1","Block Grass"):add("tile2","Block Brick"):add("tile3","Block Brick")
    
    local tiles = assets("tile1","tile2","tile3")
  
    local sz = vec2(10,1)
    local tz = vec2(60,60)
    
    local backgr = Xile.TileMap({tile={size=tz}}):load({
                                tiles=tiles,
                                map={1,2,0,1,1,1,1,0,2,1}, 
                                size=sz})
    
        
    local foregr = TileMesh({tile={size=tz}}):load({
                                tiles=tiles,
                                map={0,0,3,0,0,0,0,3,0,0}, 
                                size=sz})
    
    local e = Entity()

    e:add(View({items = {backgr,foregr}}),Camera(),Fps())
    
    local s = System()
    
    s.attach = function(self,engine)
        self.nodes = engine(View,Camera,Fps)
    end
    
    s.draw = function(self)
        
        local view,cam,fps
        
        for n in self.nodes() do
            view,cam,fps = n(View),n(Camera),n(Fps)
            
            cam:begin()
            
            view:draw()
            
            cam:finish()
            
            fps:draw()
        end
    end
    
    s.touched = function(self,touch)
        local view,cam
        for n in self.nodes() do
            view,cam = n(View),n(Camera)
            local t = cam:touch(touch)
            view:touched(t)
        end
    end
    
    engine:add(s,Xile.TouchSystem()):add(e)
    
    --engine:remove(e)
    
    local amt = vec2(tz:unpack())
    
    local cam = e(Camera)
    
    parameter.action("Up",function() cam:move({y=-amt.y}) end)
    parameter.action("Down",function() cam:move({y=amt.y}) end)
    parameter.action("Left",function() cam:move({x=amt.x}) end)
    parameter.action("Right",function() cam:move({x=-amt.x}) end)
    
    parameter.action("Zoom In", function() cam:zoom(0.1) end)
    parameter.action("Zoom Out", function() cam:zoom(-0.1) end)
    
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
    --[[
    perspective()
    camera(0,0,-200,0,0,0)
    ]]--
    engine:draw()
end

function touched(engine,touch)
    engine:touched(touch)
end

function collide(engine,contact)
    engine:collide(contact)
end
























--# MainTemplate
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





















--# Include
---------------------------------------------------------
--                   Include Function                  --
-- Reads and executes a tab in annother codea project  --
-- or reads and executes an entire project without     --
--                  requiring a dependancy.            --
-- Ensure this tab is executed early and before it is  --
-- used. Include is only ever called once per tab.     --
--                  Written by XanDDemoX               --
--                      Version 1.00                   --
---------------------------------------------------------

-- create table for our instance
Xile.include = function()
    local getfenv,setfenv = getfenv,setfenv
    
    -- based on http://lua-users.org/lists/lua-l/2010-06/msg00314.html
    -- this assumes f is a function
    local function findenv(f)
        local level = 1
        repeat
        local name, value = debug.getupvalue(f, level)
        if name == '_ENV' then return level, value end
        level = level + 1
        until name == nil
        return nil
    end
    getfenv = getfenv or function (f) return(select(2, findenv(f)) or _G) end
    setfenv = setfenv or function (f, t)
        local level = findenv(f)
        if level then debug.setupvalue(f, level, t) end
        return f
    end
    
    local include = {
    
    }
    -- create meta table -- includes a cache to prevent double reads and properties for debug info
    
    local _loaded ={}
    
    local includemeta = {_debug=false,_debugstring=""}
    
    local _dbgmsg=function (...)
        if includemeta._debug == true then
            local arg = {...}
            for i,v in ipairs(arg) do
                includemeta._debugstring=
                includemeta._debugstring..tostring(v)
            end -- concat debug messages
            includemeta._debugstring=includemeta._debugstring.."\r\n\r\n"
        end
    end
    
    local _defaultMT = {__index = _G}
    
    includemeta.__call= function (self,...)
        
        -- check params table
        if select('#',...) == 0 then return end
        local arg = {...}
        local items = {}
        local valid = true
        
        -- validate items 
        for i,v in ipairs(arg) do
            
            if v == nil then valid = false end
            if valid and type(v) ~= "string" then valid = false end
        -- check its not the main file
            if valid and string.match(v,"[%a%d_]:Main") or tab == "Main" then valid = false end
            if valid then
                 -- check whether its a class key filename format
                if _loaded[v] ~= nil or string.match(v,"[%a%d_]:[%a%d_]") then
                    table.insert(items,v)-- add it too the list if it matches
                elseif string.match(v,"[%a%d_]") then
                    -- get project
                    local tabs = listProjectTabs(v)
                    if tabs == nil then
                        _dbgmsg("Invalid project: ",v)
                    elseif #tabs == 0 then
                        _dbgmsg("Invalid project: ",v)
                    else
                        for ii,vv in ipairs(tabs) do 
                            if vv ~= "Main" then
                                vv = v..":"..vv
                                table.insert(items,vv) -- add tabs to list
                            end
                        end
                    end
                    
                end
                
            else
                _dbgmsg("Invalid tab or project: ",v)
            end
            valid = true
        end
        
        -- check if tab or project is considered valid
        if items == nil then return end
        if #items == 0 then return end
        
        -- load each item in the given order from the list of items
        local tabs = {}
        local md= setmetatable(tabs, md and {__index = md} or _defaultMT)
        
        for i,v in ipairs(items) do
            
            if _loaded[v] == nil then 
                -- read the code to execute
                local t = readProjectTab(v)
    
                if t ~= nil then
                    local func,err = loadstring("return function() "..t.." end")
                    _loaded[v] = func -- ignore any further calls to load this tab
                end
            end
            
            local func = _loaded[v]
            if func ~= nil then
                
                local tab = setfenv(func(),md)
                if xpcall(tab,function() _dbgmsg("Error loading tab") end) then 
                    _dbgmsg("Successfully loaded tab: ",v)
                end
            end
            
        end
        
        return tabs
    end
    -- set the meta table to create the include function
    return setmetatable(include,includemeta)
end
    
--# Reflection
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


--# Query

local function iter(tbl_or_iter,create)
    if tbl_or_iter == iter then return nil end
    
    local t = type(tbl_or_iter)
    
    if tbl_or_iter == nil or t == "function" then return tbl_or_iter end
    if t ~= "table" then print("invaild iter: ",tbl_or_iter,t) return nil end
    
    if tbl_or_iter.iter ~= nil and type(tbl_or_iter.iter) == "function" then 
        if tbl_or_iter.iter == iter then return nil end
        return tbl_or_iter:iter() 
    end
    
    create = create or function()
        local tbl = tbl_or_iter
            -- account for a 0 based array
        local s,c=1,0
        if tbl[0]~= nil then
            s,c=0,1
        end
        return coroutine.wrap(function()

            for i=s, #tbl+c do
                coroutine.yield(tbl[i])
            end
        end)
    end
    
    local it
    return function()
        it = it or create()
        local i = it()
        if i == nil then it = nil end
        return i
    end
end

local function keys(tbl,...)
    if select('#',...) > 0 then
        local arg = {...}
        local it = iter(arg)
        return function()
            local i
            repeat
                i = it()
                for k,v in pairs(tbl) do 
                    if v == i then return k end
                end
            until i == nil
        end
    end
    
    return iter(tbl,function()
        return coroutine.wrap(function()
            for k,v in pairs(tbl) do
                coroutine.yield(k)
            end
        end)
    end)
    
end

local function values(tbl,...)
    if select('#',...) > 0 then
        local arg = {...}
        local it = iter(arg)
        return function()
            local i,ii
            
            repeat
            
                i = it()
                ii = tbl[i]
                
                if ii ~= nil then 
                    return ii 
                end
            
            until i == nil
            return nil
        end
    end
    return iter(tbl,function()
        return coroutine.wrap(function()
            for k,v in pairs(tbl) do
                coroutine.yield(v)
            end
        end)
    end)
end

local function map(tbl_or_iter,func)
    if tbl_or_iter == nil or func == nil then return tbl_or_iter end
    local it = iter(tbl_or_iter)
    return function()
        local i = it()
        
        if i ~= nil then
            return func(i)
        end
        
        return nil
    end
end

local function copy(tbl_or_iter,target,start,count)
    if type(target) == "number" then
        if start ~= nil then count = start end
        start = target
        target = nil
    end
    
    local result = target or {}
    
    -- account for zero based array
    if type(tbl_or_iter) == "table" and tbl_or_iter[0] ~= nil then
        start = start or 0
    end
    
    start = start or (start and start == 0) or (#result+1)
    
    local idx = start
    
    for i in iter(tbl_or_iter) do
        if count == nil or idx <= count then
            result[idx] = i
            idx = idx + 1 
        end
    end
    
    return result
end

local function each(tbl_or_iter,func)
    
    if tbl_or_iter == nil or func == nil then return tbl_or_iter end
    
    local stop
    for i in iter(tbl_or_iter) do
         if stop == nil then
            stop = func(i)
        end
    end
    return tbl_or_iter
end

local function any(tbl_or_iter,func)
    if tbl_or_iter == nil then return false end
    local value = false
    each(tbl_or_iter,function(i)
        if func == nil or func(i) == true then
            value = true
            return true
        end
    end)
    return value
end

local function all(tbl_or_iter,func)
    if tbl_or_iter == nil or func == nil then return false end
    local value = true
    local any = false
    each(tbl_or_iter,function(i)
        any = true
        if func(i) == false then
            value = false
            return false
        end
    end)
    return any and value
end

local function take(tbl_or_iter,count)
    
    if tbl_or_iter == nil or count == nil then return tbl_or_iter end
    
    local it = iter(tbl_or_iter)
    local cur = 0
    local i
    
    return function()
        if cur < count then
            cur = cur + 1
            i = it()
        else
            while it() ~= nil do end
            i = nil
        end
        if i == nil then cur = 0 end
        return i
    end
end

local function skip(tbl_or_iter,count)
    
    if tbl_or_iter == nil or count == nil then return tbl_or_iter end
    
    local it = iter(tbl_or_iter)
    local i
    return function()
        if i == nil then
            for x=1,count do
                i = it()
                if i == nil then return nil end
            end
        end
        i = it()
        return i
    end
end

local function join(...)
    local arg = {...}
    local cur = 1
    local count = #arg
    if count < 2 then return arg[1] end
    local it
    return function()
        local i
        while i == nil do
            it = it or iter(arg[cur])
            i = it and it()
            if i == nil and cur < count then
                cur = cur+1
                it = nil
            elseif i == nil and cur == count then
                it = nil
                cur = 1
                return nil
            end
        end
        return i
    end
end

local function flatten(tbl_or_iter,depth)
    
    if tbl_or_iter == nil then return nil end
    
    local fn
    local it = iter(tbl_or_iter)

    local its = {it}
    
    local fn 
        
    fn = function()
        local i = its[#its]()
        local t = type(i)
        if i~= nil and (depth == nil or #its < depth+1) and (t == "function" or t == "table") then
            table.insert(its,iter(i))
            i = fn()
        elseif i == nil and #its > 1 then
            table.remove(its)
            i= fn()
        end
        return i
    end
    
    return fn

end

local function where(tbl_or_iter,predicate)
    if tbl_or_iter == nil or predicate == nil then return tbl_or_iter end
    local it = iter(tbl_or_iter)
    return function()
        local i
        repeat
            i = it()
        until i == nil or predicate(i)
        return i
    end
end


local function slice(tbl_or_iter,idx,count)
    if tbl_or_iter == nil or (idx == nil and count == nil) then return tbl_or_iter end
    return take(skip(tbl_or_iter,idx),count)
end

local function split(tbl_or_iter,width)
    if tbl_or_iter == nil or width == nil or width < 1 then return tbl_or_iter end

    local it = iter(tbl_or_iter)
    local item
    local cur
    return function()
        if item == nil and cur ~= nil then
            cur = nil
            return nil
        else 
            cur = nil
        end
        for i = 1,width do
            item = it()
            if item ~= nil then
                cur = cur or {}
                table.insert(cur,item)
            else 
                break
            end
        end
        return cur
    end
end


local function extend(source,target,func)
    local tgt = target or {}
    func = func or function(v) return v end
    for k,v in pairs(source) do
        tgt[k]=func(v)
    end
    return tgt
end

local function pack(...)
    return {...}
end

local getfenv,setfenv = getfenv,setfenv

-- based on http://lua-users.org/lists/lua-l/2010-06/msg00314.html
-- this assumes f is a function
local function findenv(f)
    local level = 1
    repeat
    local name, value = debug.getupvalue(f, level)
    if name == '_ENV' then return level, value end
    level = level + 1
    until name == nil
    return nil
end
getfenv = getfenv or function (f) return(select(2, findenv(f)) or _G) end
setfenv = setfenv or function (f, t)
    local level = findenv(f)
    if level then debug.setupvalue(f, level, t) end
    return f
end

local function import(str,env)
    if str:byte(1) == 27 then return env end
    env = env or {}
    local load = loadstring("return function() "..str.." end")
    local err,r = xpcall(function() return pack(setfenv(load(),env)()) end,function() end)
    return env,r
end

Xile.iter = iter
Xile.keys = keys
Xile.values = values
Xile.all = all
Xile.any = any

Xile.array = function(tbl_or_iter,...) return copy(tbl_or_iter,...) end

Xile.lookup = function(tbl_or_iter,getPair,target)
    
    local result = target or {}
    local k,v
    
    if type(getPair) == "table" then
        local tbl = getPair
        getPair = function(k) return k,tbl[k] end
    end
    
    for i in iter(tbl_or_iter) do
        k,v = getPair(i)
        if k ~= nil then
            result[k] = v
        end
    end
    
    return result
end

local _unpack = unpack

Xile.unpack = function(tbl_or_iter)
    if type(tbl_or_iter) == "table" then return _unpack(tbl_or_iter) end
    local tbl = copy(tbl_or_iter)
    return _unpack(tbl)
end


Xile.import = import
Xile.extend = extend
Xile.pack = pack

local x = {}
x.map = map
x.each = each
x.copy = copy
x.take = take
x.skip = skip
x.flatten = flatten
x.where = where
x.join = join
x.slice = slice
x.split = split

extend(x,Xile)

local Query = Xile.class()
Xile.Query = Query
Query.__call=function(self,...) return self:copy(...) end

local _qry = function(tbl_or_iter)
    if tbl_or_iter == nil then return nil end
    return Query(tbl_or_iter)
end

_qry={from=_qry}

extend(_qry,Xile)

function Query:init(tbl_or_iter)
    
    local it = tbl_or_iter
    
    if type(it) == "table" and it.iter ~= nil and type(it.iter) == "function" then
        it = it:iter()
    end
    
    extend(x,self,function(v) 
        return function(self,...)
            local i = v(it,...)
            if i == nil or i == it then return self end
            return Query(i)
        end 
    end)

    self.iter = function(self)
        return Xile.iter(it)
    end
    
    self.all = function(self,...)
        return Xile.all(it,...)
    end
    
    self.any = function(self,...)
        return Xile.any(it,...)
    end
    
    self.keys = function(self,...)
        if type(it) == "table" then
            return Query(keys(it,...))
        end
        return self
    end
    
    self.values = function(self,...)
        if type(it) == "table" then
            return Query(values(it,...))
        end
        return self
    end
    
    self.array = function(self,...)
        return Xile.array(it,...)
    end
    
    self.lookup = function(self,...)
        return Xile.lookup(it,...)
    end
    
    self.unpack = function(self)
        return Xile.unpack(it)
    end
    
    self.pack = function(self,...) return self:join(pack(...)) end
    
    self.import = function(self,str,env) 
        local ev,result = Xile.import("return "..str,env)
        return self:join(result)
    end
    
    self.extend = function(self,getPair,...)
        extend(self:lookup(getPair),...)
        return self
    end
    
    self.is = function(self,tbl_or_iter)
        return tbl_or_iter ~= nil and it == tbl_or_iter
    end

end






















--# List
local List = Xile.class()
Xile.List = List

List.__call = function(self,...) return self:item(...) end

local from = Xile.from

function List:init(...)
    
    local items = {}

    local count = 0
        
    self.add = function(self,...)
        for i,v in ipairs({...}) do
            count = count + 1
            items[count] = v
        end
        return self
    end
    
    self.remove = function(self,...)
        local arg = {...}

        for i=1, count do
            
            for ii,v in ipairs(arg) do
                if v == items[i] then
                    table.remove(items,i)
                    table.remove(arg,ii)
                    count = count -1
                end
            end
            if items[i] == nil or #arg <1 then 
                break
            end
        end

        return self
    end
    
    self.clear = function(self)
        for i=1,count do
            items[i]=nil
        end
        count = 0
        return self
    end
    
    self.count = function(self)
        return count
    end
    
    self.contains = function(self,...)
        local arg = {...}

        for i=1, count do
            
            for ii,v in ipairs(arg) do
                if v == items[i] then
                    table.remove(arg,ii)
                end
            end
            if #arg <1 then 
                return true
            end
        end
        
        return false
    end
    
    self.item = function(self,...)
        local ac = select('#',...)
        if ac == 0 then
            local i = 0
            return function() 
                i=i+1
                return items[i]
            end
        elseif ac == 1 then
            return items[select(1,...)]
        elseif ac > 1 then
            return from({...}):map(function(i)
                return items[i]
            end)
        end
    end
    
    self.array = function(self,...)
        return Xile.copy(items)
    end
    
    self.iter = function(self)
        return Xile.iter(items)
    end
    
    self:add(...)
end


--# Event
local List = Xile.List
Xile.event = function()
    
    local evt = {}
    
    local handlers = List()
    
    evt.add = function(self,func)
        if type(self) == "function" then func = self end
        if func == nil then return end
        handlers:add(func)
    end
    
    evt.remove = function(self,func)
        if type(self) == "function" then func = self end
        if func == nil then return end
        handlers:remove(func)
    end
    
    evt.count = function(self)
        return handlers:count()
    end
    
    local raise = function(sender,...)
        if sender == nil or handlers:count() < 1 then return end
        
        local tbl = handlers:array()
        
        for i,func in ipairs(tbl) do
            func(sender,...)
        end
    end
    
    return evt,raise
end





















--# Component


local Component = class()
Xile.Component = Component

local _mtcache ={}

local metatable = function(component)
    local mt = _mtcache[component]
    if mt == nil then
        mt = getmetatable(component)
        _mtcache[component] = mt 
    end
    return mt
end

local getname = function(component)
    if component == nil then return nil end
    if type(component) == "string" then return component end
    local name = component.name 
    if name == nil then
        local mt = metatable(component)
        name = (mt and mt.name)
    end
    if name == nil then
        local bt,rt,ct = Xile.type(component)
        name = ct
    end
    name = name or component
    return name
end

local _cache = setmetatable({},{__mode="k"})

Component.getname = function(k) 
    local n = _cache[k]
    if n == nil then
        n = getname(k)
        _cache[k] = n
    end
    return n
end

Component.metatable = metatable

function Component:init()

end


--# Node
local Node = class()
Xile.Node = Node

Node.__call = function(self,...) return self:item(...) end

local from = Xile.from

local _cache = {}
local getname = Xile.Component.getname


function Node:init()
    
    local items = {}
    
    self.item = function(self,key)
        return items[getname(key)]
    end
    
    self.set = function(self,key,value)
        items[getname(key)] = value
    end
    
    self.clear = function(self)
        from(items):keys():each(function(k)
            items[k]=nil
        end)
    end
end


--# NodeCache
local NodeCache = class()
Xile.NodeCache = NodeCache
local from = Xile.from
function NodeCache:init(factory)
    
    local _nodes = {}
    
    self.new = function(...)
        local c= #_nodes
        if c > 0 then
            local n = _nodes[c]
            table.remove(_nodes)
            return n
        else
            return factory(...)
        end
    end
    
    self.dispose = function(self,node)
        node:clear()
        table.insert(_nodes,node)
    end
end


--# EngineCache
local EngineCache = Xile.class()
Xile.EngineCache = EngineCache

EngineCache.__call = function(self,...) return self:item(...) end

local Component = Xile.Component
local List = Xile.List
local from = Xile.from
local event = Xile.event

local getname = Component.getname

function EngineCache:init(nodeCache)
    
    local _nodes = nodeCache
    
    local _keys = {}
    
    local _cache = {}
    local _index = {}
    
    local _entity = List()
    
    local _events = {add={},update={},remove={}}
    local _evtqry = from(_events):keys()
    
    local eventGet = function(tbl,list)
        local evt,raise = tbl[list]
        if evt == nil then
            evt,raise = event()
            tbl[list] = {event=evt,raise=raise}
        end
        return evt
    end
    
    local raiseEvent = function(evt,k,node)
        local e = evt[k]
        if e ~= nil then
            e.raise(k,{node=node})
        end
    end
    
    local getkey = function(...)
        local arg = from({...}):map(getname):array()
        table.sort(arg)
        local key = table.concat(arg)
        if _keys[key] == nil then
            _keys[key] = {...}
        end
        return key
    end
    
    local updateNode = function(evt,k,entity,list,node,keys)
        if evt ~= nil then
            
            if evt == _events.add or evt == _events.update then
                if evt == _events.add then
                    list:add(node)
                    _index[k][entity] = node
                end
                
                for i,v in ipairs(keys) do
                    node:set(v,entity(v))
                end
                
            else
                list:remove(node)
                _index[k][entity] = nil
            end
            
            raiseEvent(evt,list,node)
            
            if evt == _events.remove then
                _nodes:dispose(node)
            end
        end
    end
    
    local updateEntities = function(k,keys,qry,func)
        local node,list,evt
        qry:each(function(entity)
            
            list = _cache[k]
            
            node = _index[k][entity]
            
            evt,node = func(entity,keys,node)
            
            if evt ~= nil and node ~= nil then
                updateNode(evt,k,entity,list,node,keys)
            end
            
        end)
    end
    
    local updateCache = function(func,...)
        local arg = {...}
        local qry = from(arg)
        
        local keys
        local node,list,evt
        
        for k,v in pairs(_keys) do
            updateEntities(k,v,qry,func)
        end

    end
    
    local entityNodeRemove = function(entity,keys,node)
        if node ~= nil then
            return _events.remove,node
        end
    end
    
    local entityNodeUpdate = function(entity,keys,node)
        if entity:contains(unpack(keys)) then
            
            if node == nil then
                node = _nodes:new()
                evt = _events.add
            else
                evt = _events.update
            end
            
        elseif node ~= nil then
            evt = _events.remove
        end
        return evt,node
    end
    
    local cacheGet = function(...)
        
        local key = getkey(...)
        
        local list = _cache[key]
        
        if list == nil then
            list = List()
            _evtqry:each(function(k)
                list["on"..k] = function(self) return eventGet(_events[k],list) end
            end)
            _cache[key] = list
            _index[key] = {}
            
            updateEntities(key,_keys[key],from(_entity),entityNodeUpdate)
        end
        
        return list
    end
    
    local entity_update = function(sender,e)
        updateCache(entityNodeUpdate,sender)
    end
    
    self.add = function(self,...)
        local arg = {...}
        from(arg):each(function(e)
            if _entity:contains(e) == false then
                
                _entity:add(e)
                
                updateCache(entityNodeUpdate,e)
                
                e.onAdded:add(entity_update)
                e.onRemoved:add(entity_update)
                
            end
        end)
        return self
    end
    
    self.update = function(self,...)
        local arg = {...}
        from(arg):each(function(e)
            if _entity:contains(e) == true then
                updateCache(entityNodeUpdate,e)
            end
        end)
        return self
    end
    
    self.remove = function(self,...)
        local arg = {...}
        from(arg):each(function(e)
            if _entity:contains(e) == true then
                
                _entity:remove(e)
                
                e.onAdded:remove(entity_update)
                e.onRemoved:remove(entity_update)
                
                updateCache(entityNodeRemove,e)
                
            end
        end)
        return self
    end
    
    self.contains = function(self,...)
        return _entity:contains(...)
    end
    
    self.item = function(self,...)
        return cacheGet(...)
    end
end


--# Engine
local Engine = Xile.class()
Xile.Engine = Engine
Engine.__call = function(self,...) return self:item(...) end

local List = Xile.List
local from = Xile.from

function Engine:init(engineCache)
    
    local _system = {update=List(),draw=List(),touched=List(),collide=List()}
    
    local _sysqry = from(_system):keys()
    
    local _cache = engineCache
    
    local entity_update = function(sender,e)
        _cache:update(sender)
    end
    
    local isSystem = function(system)
        return Xile.type.is(system,Xile.System)
    end
    
    local isEntity = function(entity)
        return Xile.type.is(entity,Xile.Entity)
    end
    
    local addSystem = function(system)
        
        _sysqry:each(function(k)
            local sys = _system[k]
            if system[k] ~= nil and sys:contains(system) == false then
                sys:add(system)
            end
        end)
        system:attach(self)
    end
    
    local removeSystem = function(system)
        
        system:detach(self)
        
        _sysqry:each(function(k)
            local sys = _system[k]
            if system[k] ~= nil and sys:contains(system) == true then
                sys:remove(system)
            end
        end)
    end
    
    local addEntity = function(entity)
        _cache:add(entity)
    end
    
    local removeEntity = function(entity)
        _cache:remove(entity)
    end
    
    self.add = function(self,...)
        local arg = {...}
        from(arg):each(function(entity_or_system)
            
            if isEntity(entity_or_system) == true then
                addEntity(entity_or_system)
            elseif isSystem(entity_or_system) == true then
                addSystem(entity_or_system)
            end
            
        end)

        return self
    end
    
    self.remove = function(self,...)
        local arg = {...}
        from(arg):each(function(entity_or_system)
            if isEntity(entity_or_system) == true then
                removeEntity(entity_or_system)
            elseif isSystem(entity_or_system) == true then
                removeSystem(entity_or_system)
            end
        end)

        return self
    end
    
    self.item = function(self,...)
        return _cache(...)
    end
    
    _sysqry:extend(function(k)
        local system = _system[k]
        return k,function(self,...)
            local sys
            for i=1, system:count() do
                sys = system:item(i)
                sys[k](sys,...)
            end
        end
    end,self)
    
end

--# Entity
local Entity = Xile.class()
Xile.Entity = Entity

Entity.__call = function(self,...) return self:item(...) end

local Component = Xile.Component
local from = Xile.from

local newid = (function()
    local _count = 0
    return function()
        _count = _count + 1
        return _count
    end
end)()

local getname = Component.getname

local update = function(self,components,component,raise,value)
    local n = getname(component)
    if n == nil then return end
    components[n] = value
    raise(self,{key=n,value=component})
end

function Entity:init()

    local id = newid()
    
    local components = {}
    local qry = from(components)
    
    local raiseAdded,raiseRemoved
    
    self.onAdded,raiseAdded = Xile.event()
    self.onRemoved,raiseRemoved = Xile.event()
    
    self.id = function(self)
        return id
    end
    
    self.keys = function(self)
        return qry:keys()
    end
    
    self.item = function(self,...)
        local count = select('#',...)
        if count > 0 then
            if count == 1 then
                return components[getname(select(1,...))]
            end
            return from({...}):map(getname):map(function(k) return components[k] end)
        else
            return qry:values()
        end
    end
    
    self.contains = function(self,...)    
        local arg = {...}
        return from(arg):map(getname):all(function(i)
            return components[i] ~= nil 
        end)
    end
    
    self.add = function(self,...)
        local arg = {...}
        from(arg):each(function(component)
            if self:contains(component) == true then return end
            update(self,components,component,raiseAdded,component)
        end)
        
        return self
        
    end
    
    self.remove = function(self,...)
        local arg = {...}
        from(arg):each(function(component)
            if self:contains(component) == false then return end
            update(self,components,component,raiseRemoved,nil)
        end)
        
        return self
    end
    
    self.clear = function(self)
        return self:remove(qry:values():unpack())
    end
    
end

--# StateMachine
local StateMachine = Xile.class()
Xile.StateMachine = StateMachine

local List = Xile.List
local from = Xile.from


function StateMachine:init(entity)
    
    local _states = {}
    local _entity = entity
    local _current
    
    self.keys = function(self)
        return from(_states):keys():array()
    end
    
    self.now = function(self)
        return _current
    end
    
    self.new = function(self,...)
        local arg = {...}
        return from(arg):map(function(k) 
            local state = List()
            _states[k] = from(state)
            return state
        end):unpack()
    end
    
    self.set = function(self,key)
        
        local state = _states[key]
        if state == nil then return end
        
        local cur = _states[_current]
        
        if cur ~= nil then
            _entity:remove(cur:unpack())
        end
        
        _entity:add(state:unpack())
        
        _current = key
    end
end
--# System
local System = Xile.class()
Xile.System = System

local from = Xile.from

function System:init()
    
    local _nodes = {}
    
    local _qry = from(_nodes):keys()
    
    -- important assumes first arg to be key
    self.nodes = function(self,...)
        local key = select(1,...)
        local item = _nodes[key]

        if item == nil then
            local l =Xile.List()
            item = {
                keys={...},
                list = l,
                add=function(sender,e) l:add(e.node) end,
                remove=function(sender,e) l:remove(e.node) end,
                attach = function(self,engine) 
                    local n = engine:item(unpack(self.keys))
                    n:onadd():add(self.add)
                    n:onremove():add(self.remove)
                end,
                detach = function(self,engine) 
                    local n = engine:item(unpack(self.keys))
                    n:onadd():remove(self.add)
                    n:onremove():remove(self.remove)
                end
            }
            _nodes[key] = item
        end
        
        return item.list
    end
    
    self.attach = function(self,engine)
        _qry:each(function(k)
             _nodes[k]:attach(engine)
        end)
    end
    
    self.detach = function(self,engine)
        _qry:each(function(k)
            _nodes[k]:detach(engine)
            _nodes[k] = nil
        end)
    end
    
    self.dispose = function(self)
        _nodes = nil
        _qry = nil
    end
    
end






--# Data
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

--# TouchSystem
local TouchSystem = Xile.class(Xile.System)
Xile.TouchSystem = TouchSystem

local from = Xile.from

local clear = function(t,max)
    t[BEGAN] = nil
    if max == 1 then
        t[MOVING] = nil
    else
        t[MOVING] = t[MOVING] or {}
        for i=1, #t[MOVING] do
            t[MOVING][i] = nil
        end
        
    end
    t[ENDED] = nil
end

function TouchSystem:init(maxMoving)
    self:base().init(self)
    if maxMoving ~= nil and maxMoving < 1 then maxMoving = nil end
    
    local ids,touches,count,max = {},{},0,maxMoving or 10
    local qry = from(touches)
    
    self.count = function(self)
        return count
    end
    
    self.item = function(self,...)
        local c = select('#',...)
        if c > 0 then
            local it = from({...}):map(function(i) return touches[i] end)
            if c == 1 then
                return it:unpack()
            end
            return it
        else
            return qry:iter()
        end
    end
    
    self.purge = function(self)
        for i,t in ipairs(touches) do
            if t[ENDED] ~= nil then
                clear(t,max)
            end
        end
    end
    
    self.touched = function(self,touch)
        local t
        if touch.state == BEGAN then
            count = count + 1
            ids[touch.id] = count
            
            touches[count] = touches[count] or {}
            
            t = touches[count]
            
            clear(t,max)
            
            t[BEGAN] = touch
            
        elseif ids[touch.id] ~= nil then
            t = touches[ids[touch.id]]
            
            if touch.state == MOVING then
                if max == 1 then
                    t[MOVING] = touch
                else
                    t[MOVING][math.fmod(#t[MOVING],max)] = touch
                end
            elseif touch.state == ENDED then
                
                t[ENDED] = touch
                
                ids[touch.id] = nil
                count = count - 1
    
            end
        end
    end
end

--# Assets
local Assets = Xile.class()
Xile.Assets = Assets

Assets.__call = function(self,...) return self:item(...) end

local from = Xile.from

function Assets:init(pack)
    local _pack = pack
    local _prefix = _pack..":"
    
    local _types = {}
    
    local _assets = {}
    
    local assetGet = function (k)
        local asset = _assets[k]
        if asset == nil then return end
        if asset.objects == nil then
            asset.objects = asset:create()
        end
        return asset.objects
    end
    
    
    self.asset = function(self,create,...)
        local t = _types[create]
        
        if t == nil then
            t = {}
            _types[create] = t
        end
        
        local args = {...}
        
        t.add=function(self,alias,...)
            if alias == nil then return self end
            local arg = {...}
            local a = {
            type = create,
            }
            
            if #arg > 1 then
                a.create=function(self) 
                    return from(arg):map(function(k) return create(_prefix..k,unpack(args)) end):array()
                end
            else
                a.create=function(self) 
                    return {create(_prefix..arg[1] or alias,unpack(args))}
                end
            end
            
            _assets[alias] = a
            
            return self
        end
        
        return t
    end
    
    self.item = function(self,...)
        local arg = {...}
        local c = #arg
        if c == 1 then
            local i = from(arg):map(assetGet):flatten(1):array()
            if #i > 1 then
                return i
            else
                return unpack(i)
            end
        elseif c > 1 then
            return from(arg):map(assetGet):flatten(1)
        else
            return from(_assets):keys():map(assetGet):flatten(1)
        end
    end
    
end

--# Asset
local Asset = Xile.class()
Xile.Asset = Asset

function Asset:init(key)
    
    self:base().init(self)
    
    local _key = key
    
    self.key = function(self)
        return _key
    end
    
    self.load = function(self)
        return self
    end
    
    self.dispose = function(self)
        return self
    end
end




































--# Image
local Image = Xile.class(Xile.Asset)
Xile.Image = Image

local function resize(img,sz)
    if img.width == sz.x and img.height == sz.y then return img end
    local new = image(sz.x,sz.y)
    setContext(new)
    pushMatrix()
    pushStyle()
    spriteMode(CORNER)
    sprite(img,0,0,sz.x,sz.y)
    popStyle()
    popMatrix()
    setContext()
    return new
end

function Image:init(key,mode)
    self:base().init(self,key)
    
    local img,sp
    
    local size
    self.size = function(self)
        return size
    end
    
    self.load = self:hook(self.load,function(base,self,sz)
    
        base(self)
        
        size = sz
        
        local key = self:key()
        
        if key == nil then return self end
        
        if img == nil then
            img = readImage(key)
        end
        
        if size == nil then
            size = vec2(img.width,img.height)
        end
        
        sp = resize(img,size)
        
        return self
    end)

    self.draw = self:hook(self.draw,function(base,self)
        base(self)
        if sp ~= nil then 
            
            local cur
            
            if mode ~= nil then
                cur = spriteMode()
                if mode ~= cur then
                    spriteMode(mode)
                else 
                    cur = nil
                end
            end
            
            sprite(sp,0,0) 
            
            if cur ~= nil then
                spriteMode(cur)
            end
        end
    end)
    
    self.dispose = self:hook(self.dispose,function(base,self)
        img = nil
        sp = nil
        return self
    end)
end
























--# Shader
local Shader = Xile.class(Xile.Asset)
Xile.Shader = Shader
    
function Shader:init(key)

    self:base().init(self,key)
    
    self.load = self:hook(self.load, function(base,self)
        
        base(self)
        
        local key = self:key()
        
        if key == nil then return self end
        
        if self.object == nil then
            self.object = shader(key)
        end
        
        return self
    end)
    
    self.update = function(self)
            
    end
    
    self.dispose = self:hook(self.dispose,function(base,self)
        self.object = nil
        return self
    end)
    
end


 

--# WaveyShader
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
--# View
local View = Xile.class()
Xile.View = View

function View:init(args)
    
    self:base().init(self)
    
    args = args or {}
    
    local items = args.items

    self.draw = function(self)
        for i,v in ipairs(items) do
            if v.draw ~= nil then
                v:draw()
            end
        end
    end
    
    self.touched = function(self,touch)
        for i,v in ipairs(items) do
            if v.touched ~= nil then
                v:touched(touch)
            end
        end
    end
    
end
 
























--# TileMap
local TileMap = Xile.class()
Xile.TileMap = TileMap

local event = Xile.event
local from = Xile.from

TileMap.calcIndex = function(x,y,sz) return 1+(sz.x * y) + x end

function TileMap:init(args)
    self:base().init(self)
    args = args or {}
    
    local state = args.state
    -- size
    local tile = args.tile or {}
    local tiles,count
    
    local calcIndex = function(x,y) return TileMap.calcIndex(x,y,state.size) end
    
    local raiseTouch
    self.ontouch,raiseTouch = event()
    
    self.tiles = function(self)
        return tiles
    end
    
    self.count = function(self)
        return count
    end
    
    self.tile = function(self)
        return tile
    end
    
    self.state = function(self)
        return state
    end
    
    self.load = function(self,s)
        if s ~= nil then state = s end
        
        if state == nil then return self end

        tiles = {}
        tiles[0] = state.tiles[0] or state.empty or {visible=false,load =function() end, draw=function() end}
        
        tiles = from(state.tiles)(tiles):each(function(i) i:load(tile.size) end):array()
        
        count = #tiles+1
        
        return self
    end
    
    self.update = function(self,newMap)
        if state == nil then return self end
        state.map = newMap or state.map
        return self
    end
    
    self.size = function(self)
        return vec2(tile.size.x * state.size.x,tile.size.y * state.size.y)
    end
    
    self.map = function(self,x,y)
        local sz = self:size()
        local tz = tile.size
        return vec2(math.floor((x * sz.x) / tz.x), math.floor((y * sz.y) / tz.y))
    end
    
    self.get = function (self,mapX,mapY)
        return state.map[calcIndex(mapX,mapY)]
    end
    
    self.set = function(self,mapX,mapY,value)
        state.map[calcIndex(mapX,mapY)] = value
        return self
    end
    
    self.draw = function(self)
        
        if state == nil then return end
    
        pushMatrix()
        
        local t
        local pos = vec2(0,0)
        local sz = state.size
        local tz = tile.size
        
        for y=0,sz.y-1 do
 
            for x=0, sz.x-1 do
                
                t = state.map[calcIndex(x,y)]
                t = tiles[t]
                
                if t~= nil then
                    pos.x, pos.y = x * tz.x, y * tz.y
                    t:draw()
                end
                translate(tz.x,0)
            end
            translate(-sz.x * tz.x,tz.y)
        end
        
        popMatrix()
    end
    
    self.hitTest = function(self,x,y)
        local sz = self:size()
        x = x / (sz.x / WIDTH)
        y = y / (sz.y / HEIGHT)
        if x >= 0 and y >= 0 and x <= 1 and y <= 1 then
            return x,y
        end
    end
    
    self.touched = function(self,touch)
        
        local t = touch
        -- bounds test
        
        local x,y = self:hitTest(t.x,t.y)
        local px,py = self:hitTest(t.prevX,t.prevY)
        
        if x and y then
            raiseTouch(self,{pos=vec2(x,y),
                             prev=px and py and vec2(px,py),
                             touch=t})
        end
    end

end


















--# TileMesh
local TileMesh = Xile.class(Xile.TileMap)
Xile.TileMesh = TileMesh

local calcIndex = Xile.TileMap.calcIndex

local imgMax = vec2(2048,2048)

local function calcScan(count,tz,max)
    max = max or imgMax
    local perRow = math.floor(max.x / tz.x)
    local rows = 1 + math.floor(count / perRow)
    return perRow,math.min(rows,math.floor(max.y / tz.y))
end


local function calcTexture(t,count,tz,max)
    local perRow,rows = calcScan(count,tz,max)
    return (1/math.fmod(count,perRow) * math.fmod(t,perRow)),(1/rows) * math.floor((t/perRow)),(1/count),1
end

local function createTexture(tiles,tz,count) 

    local perRow,rows = calcScan(count,tz)
    
    local w,h = tz.x * math.fmod(count,perRow), tz.y * rows
    
    local img = image(w,h)
    setContext(img)
    pushMatrix()
    
    local x,y
    
    for i=0,count-1 do
        
        x,y = calcTexture(i,count,tz)
        x,y = x * img.width, y * img.height
        
        translate(x,y)
        tiles[i]:draw()
        translate(-x,-y)
    end
        
    popMatrix()
    setContext()
    return img
end

local function calcTile(x,y,tz)
    return (tz.x / 2) + (x * tz.x),(tz.y / 2) + (y * tz.y),tz.x,tz.y
end

local defaultTextureColour = color(255,255,255,255)

local function updateTextureRect(m,i,t,count,tz,state,col)
    m:setRectTex(i,calcTexture(t,count,tz))
    m:setRectColor(i,state.colours and state.colours[i] or col or defaultTextureColour)
end

function TileMesh:init(...)
    self:base().init(self,...)
    
    local m,count
    
    self.load = self:hook(self.load,function(base,self,...)
        base(self,...)
        
        local state = self:state()
        
        if state == nil then return self end
        
        local count = self:count()
        local tile = self:tile()
        local tiles = self:tiles()
        
        local img = createTexture(tiles,tile.size,count)
        
        m = mesh()
        m.texture = img
        
        self:update()
        
        return self
    end)

    self.update = self:hook(self.update, function(base,self,...)
        
        base(self,...)
        
        if m == nil then return self end
        
        local state = self:state()
        local tile = self:tile()
        local count = self:count()
        
        m:clear()
        m.shader = state.shader and state.shader.object
        
        local x,y = 0,0
        local sz = state.size
        local tz = tile.size
        
        local i
        local t
        
        for y = 0, sz.y-1 do
            for x = 0, sz.x-1 do
                t = self:get(x,y)
                i = m:addRect(calcTile(x,y,tz))
                
                updateTextureRect(m,i,t,count,tz,state)
            end
        end

        return self
    end)
    
    self.set = self:hook(self.set,function(base,self,x,y,v)
        if m == nil then return self end
        
        base(self,x,y,v)
        
        local state = self:state()
        local tile = self:tile()
        local count = self:count()
        local i = calcIndex(x,y,state.size)
        
        updateTextureRect(m,i,self:get(x,y),count,tile.size,state)
        
        return self
    end)
    
    self.draw = function(self)
        if m == nil then return end
        
        if m.shader ~= nil then
            local state = self:state()
            state.shader:update()
        end
        
        m:draw() 
        
    end

end


















--# Camera
local Camera = Xile.class()
Xile.Camera = Camera

local function value(val)
    local num = (type(val) == "number" and val)
    local x,y = num or val.x or 0, num or val.y or 0
    return vec2(x,y)
end


function Camera:init(args)
    args = args or {}
    self.pos = args.pos or vec2(0,0)
    self.scale = args.scale or vec2(1,1)
    
    local p,s
    
    self.begin = function(self)
        p,s = self.pos,self.scale
        p = p.x == 0 and p.y==0
        s = s.x == 1 and s.y ==1
        if p == false or s == false then pushMatrix() end
        if s == false then scale(self.scale.x,self.scale.y) end
        if p == false then translate(self.pos.x,self.pos.y) end
        
    end
    
    self.finish =function(self)
        if p == false or s == false then popMatrix() end
    end
    
end

function Camera:move(pos)
    self.pos = self.pos + value(pos)
end

function Camera:zoom(amt)
    self.scale = self.scale + value(amt)
end

local function copytouch(t)
    return {
        id=t.id,
        x=t.x,
        y=t.y,
        prevX=t.prevX,
        prevY=t.prevY,
        deltaX=t.deltaX,
        deltaY=t.deltaY,
        state=t.state,
        tapCount=t.tapCount
    }
end

local function calcOffset(p,x,y)
    return x - p.x, y - p.y
end

local function calcScale(s,x,y)
    return x / s.x, y / s.y
end

function Camera:touch(touch)
    local t = copytouch(touch)
    local p = self.pos
    local s = self.scale
    
    t.x,t.y = calcOffset(p,t.x,t.y)
    t.prevX,t.prevY=calcOffset(p,t.prevX,t.prevY)
    
    t.x,t.y = calcScale(s,t.x,t.y)
    t.prevX,t.prevY=calcScale(s,t.prevX,t.prevY)
    
    t.x = t.x / WIDTH
    t.y = t.y / HEIGHT
    
    t.prevX = t.prevX / WIDTH
    t.prevY = t.prevY / HEIGHT
    
    return t
end


--# Fps
local Fps = Xile.class()
Xile.Fps = Fps

function Fps:init()
    
    self:base().init(self)
    
    local fps = 0
    local ideal = 60
    
    self.value = function()
        return fps
    end
    
    self.draw = function()
        if self.visible == false then return end
        fps = (fps*0.9)+(1/(DeltaTime)*0.1)
        local val = 255 * Xile.clamp(fps / ideal,0,1)
        pushStyle()
        fill(255-val, val,0, 255)
        text(tostring(fps),WIDTH-80,HEIGHT-20)
        popStyle()
    end
end
