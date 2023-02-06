meta = {}

meta.Type = "Type"

function meta.is_string(x)
    return type(x) == "string"
end

function meta.is_table(x)
    return type(x) == "table"
end

function meta.is_empty(x)

    if not meta.is_table(x) then
        return true
    else
        return next(x) == nil
    end
end

function meta.is_instance(x)

    if not meta.is_table(x) then
        return false
    end

    local m = rawget(x, "__meta")
    return m ~= nil and meta.is_string(m.typename) and meta.is_table(m.properties) and meta.is_table(m.is_property_private)
end

function meta.typeof(x)

    if not meta.is_table(x) then
        return type(x)
    elseif rawget(x, "__meta") == nil then
        return type(x)
    else
        return rawget(x, "__meta").typename
    end
end

function meta.has_property(x, property)

    if not meta.is_table(x) then
        return false
    end

    local is_private = rawget(x, "__meta").is_property_private[property]
    return is_private == false or is_private == true
end

function meta.is_type(x)

    if not meta.is_table(x) then
        return false
    end

    return meta.has_property(x, "properties") and
        meta.has_property(x, "is_property_private") and
        meta.has_property(x, "name") and
        rawget(x, "__meta").typename ~= nil
end

function meta.is_property_private(type, property_name)
    return rawget(type, "__meta").is_property_private[property_name]
end

function meta.add_property(type, property_name, initial_value, is_private)

    if not meta.is_instance(type) then
        error("[ERROR] In meta.add_property: Object is not a type")
    end

    type.properties[property_name] = initial_value
    type.is_property_private[property_name] =  is_private
end

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

            out = out .. "  " .. "private:\n"
            for name, value in pairs(private) do

                local str = ""
                if meta.is_string(value) then
                    str = "\"" .. value .. "\""
                else
                    str = tostring(value)
                end
                out = out .. "    " .. name .. " = " .. str .. "\n"
            end
        end

        return out
    end

    return x
end

function meta.new_type_from(typename, table)

    if not meta.is_table(table) then
        error("[ERROR] In meta.new_type_from: Function argument is not a table")
    end

    local x = meta.new_type(typename)
    rawset(x.__meta.properties, "name", typename)
    rawset(x.__meta.properties, "typename", "Type")

    for name, value in pairs(table.public) do
        meta.add_property(x, name, value, false)
    end

    for name, value in pairs(table.private) do
        meta.add_property(x, name, value, true)
    end

    for name, value in pairs(table) do

        if not (name == "public" or name == "private") then
            meta.add_property(x, name, value, false)
        end
    end

    return x
end

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
        elseif m.is_property_private[key] == true then
            error("[ERROR] In " .. m.typename .. ".__newindex: Property `" .. key .. "` was declared private")
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
        local out = this.__meta.typename .. ":\n"

        for name, value in pairs(m.properties) do

            local str = ""
            if meta.is_string(value) then
                str = "\"" .. value .. "\""
            else
                str = tostring(value)
            end
            out = out .. "  " .. name .. " = " .. str .. "\n"
        end

        return out
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

function meta.rawget_property(x, property_name)

    if not meta.is_instance(x) then
        error("[ERROR] In meta.rawset_property: Object is not a Type instance")
    end

    return rawget(x.__meta.properties)[property_name]
end

function meta.rawset_property(x, property_name, new_value)

    if not meta.is_instance(x) then
        error("[ERROR] In meta.rawset_property: Object is not a Type instance")
    end

    rawset(x.__meta.properties)[property_name] = new_value
end

Test_t = meta.new_type_from("Test_t", {
    public = {
        public_property = 1234
    },

    private = {
        private_property = 4678
    },

    struct_property = "abcd"
})

print(Test_t)
instance = meta.new(Test_t)
print(instance.private_property)
