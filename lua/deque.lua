function Vector()
    
    out = {}
    
    out.push_back = function(this, value)
        current = this.__priv.i
        this.__priv.data[current] = value
        this.__priv.i = current + 1
        this.__priv.size = this.__priv.size + 1
    end

    out.resize = function(this, n)
        for i = this.__priv.size, n, 1 do
            this.__priv.data[i] = 0
        end
        this.__priv.size = n
    end

    out.size = function(this)
        return this.__priv.size
    end

    out.clear = function(this)
        this.__priv.i = 1
        this.__priv.size = 1
        this.__priv.data = {}
    end
    
    meta = {}
    meta.i = 1
    meta.size = 0
    meta.data = {}

    meta.__index = function(this, key)

        if (type(key) ~= "number") then return nil end
        if (key > this.__priv.size or key < 1) then
            error("Key " .. tostring(key) .. " is out of bounds for a vector of size " .. this.__priv.size)
            return nil
        end

        return this.__priv.data[key]
    end
    
    meta.__newindex = function(this, key, value)

        if (type(key) ~= "number" or (type(key) == "number" and math.floor(key) ~= key)) then
            return nil
        end
        if (key > this.__priv.size or key < 1) then
            error("Key " .. tostring(key) .. " is out of bounds for a vector of size " .. this.__priv.size)
            return nil
        end

        this.__priv.data[key] = value
    end

    meta.__len = function(this)
        return this.__priv.size
    end

    meta.__pairs = function(this)

        local function stateless_iterator(this, i)

            if i == this.__priv.size then
                return nil, nil
            else
                return i+1, this.__priv.data[i+1]
            end
        end

        return stateless_iterator, this, 0
    end

    meta.__ipairs = ipairs(meta.data)

    out.__priv = meta
    setmetatable(out, out.__priv)
    
    return out
end

vector = Vector()
vector:push_back(12)
vector:push_back(13)
vector:push_back(14)
vector:resize(10)

for i, v in pairs(vector) do
    print(tostring(i) .. " " .. tostring(v))
end

print("done.")

