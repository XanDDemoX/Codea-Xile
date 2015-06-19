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

