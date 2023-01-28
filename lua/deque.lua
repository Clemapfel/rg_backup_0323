function Vector()
    
    out = {}
    
    out.push_back = function(this, value)
        current = this.__priv.n
        this.__priv.data[current] = value
        this.__priv.n = current + 1
    end

    out.size = function(this)
        return this.__priv.n
    end

    out.clear = function(this)
        this.__priv.n = 0
        this.__priv.data = {}
    end
    
    meta = {}
    meta.n = 0
    meta.data = {}

    meta.__index = function(this, key)

        if (type(key) ~= "number") then return nil end
        if (key >= this.__priv.n) then
            error("Key " .. tostring(key) .. " is out of bounds for a vector of size " .. this.__priv.n)
            return nil
        end

        return this.__priv.data[key]
    end
    
    meta.__newindex = function(this, key, value)

        if (type(key) ~= "number") then return nil end
        error("Key " .. tostring(key) .. " is out of bounds for a vector of size " .. this.__priv.n)
        return nil
    end

    meta.__len = function(this)
        return this.__priv.n
    end

    meta.__pairs = function(this)

        local function stateless_iterator(this, i)

            if i == this.__priv.n then
                return nil, nil
            else
                return i+1, this.__priv.data[i]
            end
        end

        return stateless_iterator, this, 0
    end
   
    out.__priv = meta
    setmetatable(out, out.__priv)
    
    return out
end

vector = Vector()
vector:push_back(12)
vector:push_back(13)
vector:push_back(14)

for i, v in pairs(vector) do
    print(tostring(i) .. " " .. tostring(v))
end

print("done.")

