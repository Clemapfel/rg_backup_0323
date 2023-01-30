--- @module meta
meta = {}

meta.types = {}
meta.types["Type"] = true
meta.Type = "Type"

--- @brief Create new type
--- @param typename string name of type, usually capitalized
--- @return meta.Type
function meta.new_type(typename)

    local x = {}
    x.__meta = {}
    x.__meta.typename = "Type"
    x.name = typename
    x.properties = {}
    x.is_property_mutable = {}

    if meta.types[typename] then
        print("[WARNING] In meta.new_type: Redefining type `" .. typename .. "`")
    end
    meta.types[typename] = true

    return x
end

--- @brief Check if an object is a meta.Type
--- @return boolean
function meta.is_type(x)
    return x.__meta ~= nil and x.name ~= nil and x.properties ~= nil and x.is_property_mutable ~= nil
end

--- @brief Check if object is an instance
--- @return boolean
function meta.is_instance(x)
    return x.__meta ~= nil and x.__meta.typename ~= nil
end

--- @brief Check if object is an instance of a type
--- @param x any
--- @param type meta.Type
--- @return boolean
function meta.isa(x, type)

    if not meta.is_type(x) then
        error("[ERROR] In meta.isa: Argument is not a type")
    end
    return x.__meta.typename == x.name
end

--- @brief Get type of instance
--- @param x any
--- @return meta.Type
function meta.typeof(x)
    return x.__meta.typename
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

    if not meta.is_instance then
        error("[ERROR] In meta.get_property: Value " .. x .." is not a type instance")
    elseif x.__meta.is_property_mutable[property_name] == nil then
        error("[ERROR] In meta.get_property: Instance has no property name `" .. property_name .. "`")
    elseif x.__meta.is_property_mutable[property_name] == false then
        error("[ERROR] In meta.get_property: Property `" .. property_name .. "` was declared const")
    end

    x.__meta.properties[property_name] = value
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
    x.__meta.is_property_mutable = type.is_property_mutable

    x.__meta.__index = function(this, key)

        if rawget(this, key) ~= nil then
            return rawget(this, key)
        end

        if not meta.has_property(this, key) then
            error("[ERROR] In " .. this.__meta.typename .. ".__index: " .. "No property named " .. key)
        else
            return meta.get_property(this, key)
        end
    end

    x.__meta.__newindex = function(this, key, value)

        if not meta.has_property(this, key) then
            error("[ERROR] In " .. this.__meta.typename .. ".__newindex: " .. "No property named " .. key)
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

-- TEST
Entity_t = meta.new_type("Entity")
meta.add_property(Entity_t, "_01", 12)
meta.add_property(Entity_t, "_02", {})
meta.add_const_property(Entity_t, "_03", 1234)

instance = meta.new(Entity_t)
instance:set_property_01(15)
instance["property_02"] = {{}}

for key, value in pairs(instance) do
    print(key .. " -> " .. tostring(value))
end

print(instance)
instance["const_property"] = 4321