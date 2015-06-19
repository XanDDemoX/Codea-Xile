
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





















