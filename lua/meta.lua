--- @brief Type-system, formalizes private and public fields
meta = {}

--- @class meta.Object
--- @class meta.Type

--- @brief Is x a lua string?
--- @param x any
--- @returns boolean
function meta.is_string(x)
    return type(x) == "string"
end

--- @brief Is x a lua table?
--- @param x any
--- @returns boolean
function meta.is_table(x)
    return type(x) == "table"
end

--- @brief Is x a lua number?
--- @param x any
--- @returns boolean
function meta.is_number(x)
    return type(x) == "number"
end

--- @brief Is x a lua boolean?
--- @param x any
--- @returns boolean
function meta.is_boolean(x)
    return type(x) == "boolean"
end

--- @brief Is x nil?
--- @param x any
--- @returns boolean
function meta.is_nil(x)
    return type(x) == "nil"
end

--- @brief Does table contain at least one entry
--- @param x table
--- @returns boolean
function meta.is_empty(x)

    if not meta.is_table(x) then
        return true
    else
        return next(x) == nil
    end
end

--- @brief Is x an instance of a meta.Type
--- @param x any
--- @returns boolean
function meta.is_instance(x)

    if not meta.is_table(x) then
        return false
    end

    local m = rawget(x, "__meta")
    return m ~= nil and meta.is_string(m.typename) and meta.is_table(m.properties) and meta.is_table(m.is_property_private)
end

--- @brief Is x a meta.Type
--- @param x any
--- @returns boolean
function meta.is_type(x)

    if not meta.is_table(x) then
        return false
    end

    return meta.is_instance(x) and
        meta.has_property(x, "properties") and
        meta.has_property(x, "is_property_private") and
        meta.has_property(x, "name")
end

--- @brief Get type of meta instantiated object
--- @param x meta.Object
--- @returns string
function meta.typeof(x)

    if not meta.is_table(x) or rawget(x, "__meta") == nil then
        return type(x)
    else
        return rawget(x, "__meta").typename
    end
end

--- @brief Does meta instance have a property with given id?
--- @param x meta.Object
--- @returns boolean
function meta.has_property(x, property)

    if not meta.is_table(x) then
        return false
    end

    local is_private = rawget(x, "__meta").is_property_private[property]
    return is_private == false or is_private == true
end

--- @brief Was property of meta instance declared private?
--- @param x meta.Object
--- @returns boolean
function meta.is_property_private(type, property_name)
    return rawget(type, "__meta").is_property_private[property_name]
end

--- @brief Add property to meta.Type
--- @param type meta.Type
--- @param property_name string
--- @param initial_value any
--- @param is_private boolean
--- @returns void
function meta.add_property(type, property_name, initial_value, is_private)

    if not meta.is_type(type) then
        error("[ERROR] In meta.add_property: Object is not a type")
    end

    type.properties[property_name] = initial_value
    type.is_property_private[property_name] =  is_private
end

--- @brief Instantiate a typeless object
--- @returns meta instance
function meta._new()

    local x = {}
    x.__meta = {}

    x.__meta.typename = ""
    x.__meta.properties = {}
    x.__meta.is_property_private = {}

    x.__meta.__index = function(this, key)

        local m = rawget(this, "__meta")

        if m.is_property_private[key] == nil then
            error("[ERROR] In " .. m.typename .. ".__newindex: Object has no property named `" .. key .. "`")
        end

        return m.properties[key]
    end

    x.__meta.__newindex = function(this, key, value)

        local m = rawget(this, "__meta")

        if m.is_property_private[key] == nil then
            error("[ERROR] In " .. m.typename .. ".__newindex: Object has no property named `" .. key .. "`")
        elseif m.is_property_private[key] == true then
            error("[ERROR] In " .. m.typename .. ".__newindex: Property `" .. key .. "` was declared private")
        end

        m.properties[key] = value
    end

    x.__meta.__tostring = function(this)

        local m = rawget(this, "__meta")

        local out = m.typename .. " (Instance):\n"

        local public = {}
        local private = {}

        for name, is_private in pairs(m.is_property_private) do
            if is_private then
                private[name] = m.properties[name]
            else
                public[name] = m.properties[name]
            end
        end

        if not meta.is_empty(public) then

            for name, value in pairs(public) do

                local str = ""
                if meta.is_string(value) then
                    str = "\"" .. value .. "\""
                else
                    str = tostring(value)
                end
                out = out .. "  " .. name .. " = " .. str .. "\n"
            end
        end

        if not meta.is_empty(private) then

            for name, value in pairs(private) do

                local str = ""
                if meta.is_string(value) then
                    str = "\"" .. value .. "\""
                else
                    str = tostring(value)
                end
                out = out .. "  (private) " .. name .. " = " .. str .. "\n"
            end
        end

        return out
    end

    x.__meta.__call = function(this)
        return meta.new(this)
    end

    x.__meta.__pairs = function(this)
        return pairs(this.__meta.properties)
    end

    x.__meta.__ipairs = function(this)
        return ipairs(this.__meta.properties)
    end

    setmetatable(x, x.__meta)
    return x
end

--- @brief Create a new meta.Type
--- @param typename string
--- @returns meta.Type
function meta.new_type(typename)

    local x = meta._new()
    local m = rawget(x, "__meta")

    m.typename = "Type"

    m.properties["properties"] = {}
    m.properties["is_property_private"] = {}
    m.properties["name"] = typename

    m.is_property_private["properties"] = false
    m.is_property_private["is_property_private"] = false
    m.is_property_private["name"] = false

    m.__tostring = function(this)

        local out = this.name .. " (Type):\n"

        local public = {}
        local private = {}
        local m = rawget(this, "__meta").properties

        for name, is_private in pairs(m.is_property_private) do
            if is_private then
                private[name] = m.properties[name]
            else
                public[name] = m.properties[name]
            end
        end

        if not meta.is_empty(public) then

            for name, value in pairs(public) do

                local str = ""
                if meta.is_string(value) then
                    str = "\"" .. value .. "\""
                else
                    str = tostring(value)
                end
                out = out .. "  " .. name .. " = " .. str .. "\n"
            end
        end

        if not meta.is_empty(private) then

            for name, value in pairs(private) do

                local str = ""
                if meta.is_string(value) then
                    str = "\"" .. value .. "\""
                else
                    str = tostring(value)
                end
                out = out .. "  (private) " .. name .. " = " .. str .. "\n"
            end
        end

        return out
    end

    return x
end

--- @brief Create a new meta.Type from a table, syntactically convenient
--- @param typename string Name of type
--- @param table table Table with properties, as well as `public` or `private` subtable
--- @returns meta.Type
function meta.new_type_from(typename, table)

    if not meta.is_table(table) then
        error("[ERROR] In meta.new_type_from: Function argument is not a table")
    end

    local x = meta.new_type(typename)
    rawset(x.__meta.properties, "name", typename)
    rawset(x.__meta.properties, "typename", "Type")

    if (table.public ~= nil) then
        for name, value in pairs(table.public) do
            meta.add_property(x, name, value, false)
        end
    end

    if (table.private ~= nil) then
        for name, value in pairs(table.private) do
            meta.add_property(x, name, value, true)
        end
    end

    for name, value in pairs(table) do

        if not (name == "public" or name == "private") then
            meta.add_property(x, name, value, false)
        end
    end

    return x
end

--- @brief Instantiate object from a meta.Type
--- @param type meta.Type
--- @returns instance
function meta.new(type)

    if not meta.is_type(type) then
        error("[ERROR] In meta.new: Argument is not a type")
    end

    local x = meta._new()
    local x_meta = rawget(x, "__meta")
    x_meta.typename = type.name

    for name, value in pairs(type.__meta.properties.properties) do
        x_meta.properties[name] = value
        x_meta.is_property_private[name] = type.__meta.properties.is_property_private[name]
    end

    setmetatable(x, x.__meta)
    return x
end

--- @brief Access the property of an object
--- @param x meta.Object
--- @param property_name string
--- @returns value of property
function meta.rawget_property(x, property_name)

    if not meta.is_instance(x) then
        error("[ERROR] In meta.rawset_property: Object is not a Type instance")
    end

    return rawget(x.__meta.properties)[property_name]
end

--- @brief Mutate property of an object
--- @param x meta.Object
--- @param property_name string
--- @param value any
--- @returns void
function meta.rawset_property(x, property_name, new_value)

    if not meta.is_instance(x) then
        error("[ERROR] In meta.rawset_property: Object is not a Type instance")
    end

    x.__meta.properties[property_name] = new_value
end

Inner_t = meta.new_type_from("Inner_t", {
    _a = 0,
    _b = "a"
})

Test_t = meta.new_type_from("Test_t", {

    public = {
        public_property = Inner_t()
    },

    private = {
        private_property = "abcd"
    },

    method = function(this)
        this.public_property = 1234
        meta.rawset_property(this, "private_property", "adwa")
    end
})

local instance = Test_t()
print(instance)