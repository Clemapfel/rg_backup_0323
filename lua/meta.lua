meta = {}


function meta.new_type(typename)

    local x = {}
    x.__meta = {}
    x.__meta.typename = "Type"
    x.name = typename
    x.properties = {}
    x.is_property_mutable = {}

    return x
end

function meta.is_type(x)
    return x.__meta ~= nil and x.name ~= nil and x.properties ~= nil and x.is_property_mutable ~= nil
end

function meta.isa(x, type)

    if not meta.is_type(x) then
        error("In meta.isa: Argument is not a type")
    end
    return x.__meta.typename == x.name
end

function meta.typeof(x)
    return x.__meta.typename
end

function meta.add_property(x, property_name, default_value)

    if not meta.is_type(x) then
        error("In meta.add_property: Argument is not a type")
    end

    for i = 1, #property_name do
        if (i == " ") then
            error("In meta.add_property: Property names cannot contain a spacer");
        end
    end

    x.properties[property_name] = default_value
    x.is_property_mutable[property_name] = true
end

function meta.has_property(x, property_name)

    if (x.__meta.typename == nil) then
        error("In meta.has_property: Value " .. x .." is not a type instance")
    end

    return x.__meta.is_property_mutable[property_name] == true or x.__meta.is_property_mutable[property_name] == false
end

function meta.add_const_property(x, property_name, default_value)

    if not meta.is_type(x) then
        error("In meta.add_const_property: Argument is not a type")
    end

    for i = 1, #property_name do
        if (i == " ") then
            error("In meta.add_const_property: Property names cannot contain a spacer");
        end
    end

    x.properties[property_name] = default_value
    x.is_property_mutable[property_name] = false
end

function meta.new(type)

    if not meta.is_type(type) then
        error("In meta.new: Argument is not a type")
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
            error("In " .. this.__meta.typename .. ".__index: " .. "No property named " .. key)
        else
            return this.__meta.properties[key]
        end
    end

    x.__meta.__newindex = function(this, key, value)

        if not meta.has_property(this, key) then
            error("In " .. this.__meta.typename .. ".__newindex: " .. "No property named " .. key)
        elseif this.__meta.is_property_mutable[key] == false then
            error("In " .. this.__meta.typename .. ".__newindex: " .. "Property `" .. key .. "` was declared immutable")
        else
            this.__meta.properties[key] = value
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
meta.add_property(Entity_t, "property_01", 12)
meta.add_property(Entity_t, "property_02", {})
meta.add_const_property(Entity_t, "const_property", 1234)

instance = meta.new(Entity_t)
instance:set_property_01(15)
instance["property_02"] = {{}}

for key, value in pairs(instance) do
    print(key .. " -> " .. tostring(value))
end

print(instance)
instance["const_property"] = 4321