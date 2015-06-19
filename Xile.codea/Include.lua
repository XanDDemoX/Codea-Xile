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
    