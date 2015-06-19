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