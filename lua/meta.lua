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

--- @brief Set whether property of meta.Type is declared private
--- @param type meta.Type
--- @param property_name string
--- @param is_private boolean
--- @returns void
function meta.set_property_is_private(type, property_name, is_private)

    if not meta.is_type(type) then
        error("[ERROR] In meta.add_property: Object is not a type")
    end

    type.is_property_private[property_name] = is_private
end

--- @brief Add super type, type will inherit all properties from all its supertypes
--- @param type meta.Type
--- @param super meta.Type
--- @returns void
function meta.add_super_type(type, super)

    if not meta.is_type(type) then
        error("[ERROR] In meta.add_property: Subtype Object is not a type")
    end

    if not meta.is_type(super) then
        error("[ERROR] In meta.add_property: Supertype Object is not a type")
    end

    type.super[#type.super + 1] = super
end

--- @brief Is a subtype of b
--- @param a meta.Type
--- @param b meta.Type
--- @returns boolean
function meta.is_subtype_of(a, b)

    if not meta.is_type(a) then
        error("[ERROR] In meta.is_subtype_of: Subtype Object is not a type")
    end

    if not meta.is_type(b) then
        error("[ERROR] In meta.is_subtype_of: Supertype Object is not a type")
    end

    if a.super == nil then return false end
    for _, super in pairs(a.super) do
        if super.name == b.name then
            return true
        end
    end

    return false
end

--- @brief Is b sutype of a
--- @param a meta.Type
--- @param b meta.Type
--- @returns boolean
function meta.is_supertype_of(a, b)
    return mea.is_subtype_of(b, a)
end

--- @brief Instantiate a typeless, empty object
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
            error("[ERROR] In " .. m.typename .. ".__index: Object has no property named `" .. key .. "`")
        elseif key == "__meta" or m.is_property_private[key] == true then
            error("[ERROR] In " .. m.typename .. ".__index: Property `" .. key .. "` was declared private")
        end

        return m.properties[key]
    end

    x.__meta.__newindex = function(this, key, value)

        local m = rawget(this, "__meta")

        if m.is_property_private[key] == nil then
            error("[ERROR] In " .. m.typename .. ".__newindex: Object has no property named `" .. key .. "`")
        elseif key == "__meta" or m.is_property_private[key] == true then
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

meta._types = {}

--- @brief Create a new meta.Type
--- @param typename string
--- @returns meta.Type
function meta.new_type(typename)

    if typename == nil then
        error("[ERROR] In meta.new_type: typename cannot be nil")
    end

    local x = meta._new()
    local m = rawget(x, "__meta")

    m.typename = "Type"

    m.properties["name"] = typename
    m.is_property_private["name"] = false

    for _, property in pairs({"properties", "is_property_private", "super"}) do
        m.properties[property] = {}
        m.is_property_private[property] = false
    end

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

meta._public_label = "public"
meta._private_label = "private"
meta._super_label = "super"
meta._is_property_private_by_default = true

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

    local public = table[meta._public_label]
    if public ~= nil then
        for name, value in pairs() do
            meta.add_property(x, name, value, false)
        end
    end

    local private = table[meta._private_label]
    if private ~= nil then
        for name, value in pairs(private) do
            meta.add_property(x, name, value, true)
        end
    end

    local super = table[meta._super_label]
    if super ~= nil then
        for _, value in pairs(super) do
            meta.add_super_type(x, value)
        end
    end

    for name, value in pairs(table) do
        if name ~= meta._public_label and name ~= meta._private_label and name ~= meta._super_label then
            meta.add_property(x, name, value, meta._is_property_private_by_default)
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

    collect_properties = function(type_in, properties, is_property_private)

        for name, value in pairs(type_in.__meta.properties.properties) do
            properties[name] = value
            is_property_private[name] = type_in.__meta.properties.is_property_private[name]
        end

        local super = type_in.super

        if super ~= nil then
            for _, super_type in pairs(super) do
                collect_properties(super_type, properties, is_property_private)
            end
        end
    end
    collect_properties(type, x_meta.properties, x_meta.is_property_private)

    setmetatable(x, x.__meta)
    return x
end

--- @brief Access the property of an object irregardless of scope
--- @param x meta.Object
--- @param property_name string
--- @returns value of property
function meta.rawget_property(x, property_name)

    if not meta.is_instance(x) then
        error("[ERROR] In meta.rawset_property: Object is not a Type instance")
    end

    return rawget(x.__meta.properties)[property_name]
end

--- @brief Mutate property of an object irregardless of scope
--- @param x meta.Object
--- @param property_name string
--- @param value any
--- @returns void
function meta.rawset_property(x, property_name, new_value)

    if not meta.is_instance(x) then
        error("[ERROR] In meta.rawget_property: Object is not a Type instance")
    end

    x.__meta.properties[property_name] = new_value
end


Super1 = meta.new_type_from("Super1", {
    super1_property = "super1"
})

Super2 = meta.new_type_from("Super2", {
    super2_property = "super2"
})

Type = meta.new_type_from("Type",{
    super = {Super1, Super2},
    type_property = "Type"
})

instance = meta.new(Type)
print(meta.is_subtype_of(Type, Super1))



