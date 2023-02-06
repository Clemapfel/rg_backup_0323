--- @module meta
meta = {}
meta.types = {}

--- @brief Check if an object is a lua table
--- @return boolean
function meta.is_table(x)
    return type(x) == "table"
end

--- @brief Check if an object is a lua number
--- @return boolean
function meta.is_number(x)
    return type(x) == "number"
end

--- @brief Check if an object is a lua string
--- @return boolean
function meta.is_string(x)
    return type(x) == "string"
end

--- @brief Check if an object is a lua string
--- @return boolean
function meta.is_boolean(x)
    return type(x) == "boolean"
end

--- @brief Check if an object is a lua nil
--- @return boolean
function meta.is_nil(x)
    return type(x) == "nil"
end

--- @brief Check if an object is a meta.Type
--- @return boolean
function meta.is_type(x)
    return meta.is_table(x) and rawget(x, "__meta").typename == "Type"
end

--- @brief Check if object is an instance
--- @return boolean
function meta.is_instance(x)
    return meta.is_table(x) and x.__meta ~= nil and x.__meta.typename ~= nil
end

--- @brief Check if object is an instance of a type
--- @param x any
--- @param type meta.Type
--- @return boolean
function meta.isa(x, type)

    if not meta.is_type(type) then
        error("[ERROR] In meta.isa: Argument is not a type")
    end

    if type == meta.Type then
        return meta.is_type(x)
    end

    return x.__meta.typename == x.name
end

--- @brief Get type of instance
--- @param x any
--- @return meta.Type
function meta.typeof(x)
    return meta.types[x.__meta.typename]
end

--- @brief Add mutable property to type
--- @param x meta.Type
--- @param property_name string
--- @param default_value any
--- @return void
function meta.add_property(x, property_name, default_value)

    if not meta.is_type(x) then
        error("[ERROR] In meta.add_property: Argument is not a type")
    end

    for i = 1, #property_name do
        if (property_name:sub(i, i) == " ") then
            error("[ERROR] In meta.add_property: Property names cannot contain a spacer");
        end
    end

    do
        if load("local " .. property_name .. " = 1234") == nil then
            error("[ERROR] In met.add_property: Name `" .. property_name .. "` is not a valid identifier")
        end
    end

    if (x.is_property_mutable[property_name] ~= nil) then
        print("[WARNING] In meta.add_propery: Type aready has a property name `" .. property_name .. "`" )
    end

    x.properties[property_name] = default_value
    x.is_property_mutable[property_name] = true
end

--- @brief Add immutable property to type
--- @param x meta.Type
--- @param property_name string
--- @param default_value any
--- @return void
function meta.add_const_property(x, property_name, default_value)

    if not meta.is_type(x) then
        error("[ERROR] In meta.add_const_property: Argument is not a type")
    end

    for i = 1, #property_name do
        if (i == " ") then
            error("[ERROR] In meta.add_const_property: Property names cannot contain a spacer");
        end
    end

    if (x.is_property_mutable[property_name] ~= nil) then
        print("[WARNING] In meta.add_const_propery: Type aready has a property name `" .. property_name .. "`" )
    end

    x.properties[property_name] = default_value
    x.is_property_mutable[property_name] = false
end

--- @brief Test if type or type isntance has property
--- @param x meta.Instance
--- @param property_name string
--- @return boolean
function meta.has_property(x, property_name)

    if not (meta.is_instance(x) or meta.is_type(x)) then
        error("[ERROR] In meta.has_property: Value " .. x .." is not a type instance or type")
    end

    return x.__meta.is_property_mutable[property_name] == true or x.__meta.is_property_mutable[property_name] == false
end

--- @brief Get value of property
--- @param x meta.Instance
--- @param propertyname string
--- @return any
function meta.get_property(x, property_name)

    if not meta.is_instance then
        error("[ERROR] In meta.get_property: Value " .. x .." is not a type instance")
    elseif x.__meta.is_property_mutable[property_name] == nil then
        error("[ERROR] In meta.get_property: Instance has no property name `" .. property_name .. "`")
    end

    return x.__meta.properties[property_name]
end

--- @brief Set value of property, fails if the property was declared const
--- @param x meta.Instance
--- @param property_name string
--- @param value any
--- @return void
function meta.set_property(x, property_name, value)

    if not meta.is_instance(x) then
        error("[ERROR] In meta.get_property: Value " .. tostring(x) .." is not a type")
    elseif x.meta.has_property(x, property_name) then
        error("[ERROR] In meta.get_property: Instance has no property with identifier `" .. property_name .. "`")
    elseif x.__meta.is_property_mutable[property_name] == false then
        error("[ERROR] In meta.get_property: Property `" .. property_name .. "` was declared const")
    end

    x.__meta.properties[property_name] = value
end

--- @brief Set wether a property is mutable
--- @param type meta.Type
--- @param property_name string
--- @param is_mutable boolean
--- @return void
function meta.set_property_mutable(type, property_name, is_mutable)

    if not meta.is_type(type) then
        error("[ERROR] In meta.get_property: Value " .. tostring(x) .." is not a type")
    elseif meta.has_property(x, propery_name) then
        error("[ERROR] In meta.get_property: Instance has no property with identifier `" .. property_name .. "`")
    end

    x.__meta.is_property_mutable[property_name] = is_mutable
end

--- @brief Query wether a property is mutable
--- @param type meta.Type
--- @param property_name string
--- @return boolean
function meta.get_property_mutable(type, property_name, is_mutable)

    if not meta.is_type(type) then
        error("[ERROR] In meta.get_property: Value " .. tostring(x) .." is not a type")
    elseif meta.has_property(x, propery_name) then
        error("[ERROR] In meta.get_property: Instance has no property with identifier `" .. property_name .. "`")
    end

    return x.__meta.is_property_mutable[property_name]
end

--- @brief declare a new type
--- @param typename string
--- @returns type
function meta.new_type(typename)
    x = {}
    x.__meta = {}

    x.__meta.name = typename
    x.__meta.properties = {}
    x.__meta.is_property_mutable = {}
    x.__meta.typename = "Type"

    x.__meta.__index = function(this, key)
        if key == "name" then
            return rawget(this.__meta.name)
        else
            error("[ERROR] In meta.Type.__index: Object has no property with identifier " + key)
        end
    end

    x.__meta.__newindex = function(this, key)
        error("[ERROR] In meta.Type.__newindex: Type properties cannot be assigned")
    end

    x.__meta.__tostring = function(this)
        t = rawget(this, "__meta")
        out = t.name .. " (Type)"

        if #t.properties == 0 then return out end
        out = out .. ":\n"

        for name, value in pairs(t.properties) do
            local prefix = "  "
            if t.is_property_mutable[name] then
                prefix = prefix .. "const "
            end
            out = out .. prefix .. name .. " = " .. tostring(value) .. "\n"
        end
        return out
    end

    setmetatable(x, x.__meta)
    return x
end

--- @brief Instantiate a type
--- @param type meta.Type
--- @return meta.Instance
function meta.new(type)

    if not meta.is_type(type) then
        error("[ERROR] In meta.new: Argument is not a type")
    end

    local x = {}
    x.__meta = {}
    x.__meta.properties = type.properties
    x.__meta.typename = type.name

    x.__meta.__index = function(this, key)

        if rawget(this, key) ~= nil then
            return rawget(this, key)
        end

        if not meta.has_property(this, key) then
            error("[ERROR] In " .. this.__meta.typename .. ".__index: " .. "No property with identifier `" .. key .. "`")
        else
            return meta.get_property(this, key)
        end
    end

    x.__meta.__newindex = function(this, key, value)

        if not meta.has_property(this, key) then
            error("[ERROR] In " .. this.__meta.typename .. ".__index: " .. "No property with identifier `" .. key .. "`")
        elseif this.__meta.is_property_mutable[key] == false then
            error("[ERROR] In " .. this.__meta.typename .. ".__newindex: " .. "Property `" .. key .. "` was declared immutable")
        else
            meta.set_property(this, key, value)
        end
    end

    x.__meta.__tostring = function(this)

        local out = this.__meta.typename .. ":\n"
        for name, value in pairs(this.__meta.properties) do
            out = out .. "  " .. name .. " = " .. tostring(value) .. "\n"
        end
        return out
    end

    x.__meta.__pairs = function(this) return pairs(this.__meta.properties) end
    x.__meta.__ipairs = function(this) return ipairs(this.__meta.properties) end

    for name, _ in pairs(x.__meta.properties) do

        if x.__meta.is_property_mutable[name] then
            rawset(x, "set_" .. name, function(this) return this.__meta.properties[name] end)
        end

        rawset(x, "get_" .. name, function(this, value) this.__meta.properties[name] = value end)
    end

    setmetatable(x, x.__meta)
    return x
end

Type = meta.new_type("Test_t")
meta.add_property(Type, "test_property", 12)
print(Type)

instance = meta.new(Type)
print(instance)


