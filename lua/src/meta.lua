--- @brief Type-system, formalizes private and public fields
meta = {}

--- @brief default value for function member
function meta.Function()
    return function() error("[ERROR] In meta.Function: Attempting to call an uninitialized function") end
end

--- @brief default value for string member
function meta.String()
    return ""
end

--- @brief default value for number member
function meta.Number(n)
    if n == nil then return 0 else return n end
end

--- @brief default value for table member
function meta.Table()
    return {}
end

--- @brief default value for boolean
function meta.Boolean()
    return false
end

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

--- @brief Get type of meta instantiated object
--- @param x any
--- @returns string
function meta.typeof(x)

    if not meta.is_table(x) or rawget(x, "__meta") == nil then
        return type(x)
    else
        return rawget(x, "__meta").typename
    end
end

--- @brief check if id can be used as a valid lua variable name
--- @param id string
function meta.is_valid_name(str)

    local before = _G[str]  -- prevent accidentally override global var
    local out, _ = pcall(load(str .. "=nil"))
    _G[str] = before
    return out
end

--- @class meta.Enum
meta.Enum = "Enum"

--- @brief generate new enum
--- @param values table
--- @returns meta.Enum
function meta.new_enum(values)

    local out = {}
    out.__meta = {}
    out.__meta.typename = meta.Enum
    out.__meta.values = {}

    local used_values = {}

    for name, value in pairs(values) do

        if not (meta.is_number(value) or meta.is_string(value)) then
            error("In meta.new_enum: Value is not a number or string")
        end

        if not meta.is_string(name) then
            error("In meta.new_enum: Key `" .. tostring(name) .. "` is not a string")
        end

        if used_values[value] ~= nil then
            error("In meta.new_enum: Duplicate value, key `" .. name .. "` and `" .. used_values[value] .. "` both have the same value `" .. tostring(value) .. "`")
        end

        used_values[value] = name
        out.__meta.values[name] = value
    end

    out.__meta.__newindex = function(instance, key, value)
        error("In enum.__newindex: Cannot modify an enum or its values")
    end

    out.__meta.__index = function(instance, key)
        return instance.__meta.values[key]
    end


    out.__meta.__pairs = function(this)
        return pairs(this.__meta.values)
    end

    out.__meta.__ipairs = function(this)
        return ipairs(this.__meta.values)
    end

    setmetatable(out, out.__meta)
    return out;
end

--- @brief check if object is an enum
--- @param object any
--- @return boolean
function meta.is_enum(enum)

    if not meta.is_table(enum) then
        return false
    end

    if rawget(enum, "__meta") == nil then
        return false
    end

    return rawget(enum, "__meta").typename == meta.Enum
end

--- @brief check if value is in enum
--- @param enum meta.Enum
--- @value any
--- @return boolean
function meta.is_enum_value(enum, value)

    if not meta.is_enum(enum) then
        error("[ERROR] In meta.is_enum_value: Argument #1 is not an enum")
    end

    if not (meta.is_number(value) or meta.is_string(value)) then
        return false
    end

    for _, enum_value in pairs(enum) do
        if value == enum_value then
            return true
        end
    end

    return false
end

--- @brief export all enum constants to table
--- @param enum meta.Enum
--- @param table table
function meta.export_enum(enum, table)

    if not meta.is_enum(enum) then
        error("[ERROR] In meta.export_enum: Argument #1 is not an enum")
    end

    if not meta.is_table(table) then
        error("[ERROR] In meta.export_enum: Argument #2 is not a table")
    end

    for name, value in pairs(enum) do

        if table[name] ~= nil then
            print("[WARNING] In meta.export_enum: Enum key `" .. name .. "` overrides an already existing assignment")
        end
        table[name] = value
    end
end

--- @class meta.Type
meta.Type = "Type"

--- @brief Create a new meta.Type
--- @param typename string
--- @returns meta.Type
function meta.new_type(typename)

    if typename == nil then
        error("[ERROR] In meta.new_type: typename cannot be nil")
    end

    if not meta.is_string(typename) then
        error("[ERROR] In meta.new_type: typename has to be string")
    end

    if not meta.is_valid_name(typename) then
        error("[ERROR] In meta.new_type: " .. typename .. " is not a valid variable identifier")
    end

    local x = {}
    x.__meta = {}
    x.__meta.name = typename
    x.__meta.typename = "Type"
    x.__meta.is_property_private = {}
    x.__meta.super = {}

    x.__meta.__call = function(this)
        return meta.new(this)
    end

    x.__meta.__tostring = function(this)

        local out = this.__meta.name .. " (Type):\n"

        local public = {}
        local private = {}

        for name, is_private in pairs(this.__meta.is_property_private) do
            if is_private then
                private[name] = this[name]
            else
                public[name] = this[name]
            end
        end

        if not is_empty(public) then

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

        if not is_empty(private) then

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

    setmetatable(x, x.__meta)
    return x
end

--- @brief Is x a meta.Type
--- @param x any
--- @returns boolean
function meta.is_type(x)

    if not meta.is_table(x) then
        return false
    end

    return x.__meta ~= nil and x.__meta.name ~= nil and x.__meta.is_property_private ~= nil and x.__meta.typename == meta.Type
end

--- @brief is object an instance of type
--- @param entity any
--- @param type meta.Type
function meta.isa(entity, type)

    if not meta.is_type(type) then
        error("[ERROR] in meta.isa: Argument #2 is not a type")
    end

    if not meta.is_table(entity) then
        return false
    end

    local m = rawget(entity, "__meta")
    if not meta.is_table(m) then
        return false
    end

    return m.type == type.name
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

    type[property_name] = initial_value
    type.__meta.is_property_private[property_name] = is_private
end

--- @brief Does meta instance have a property with given id?
--- @param x meta.Type
--- @returns boolean
function meta.has_property(type, property_name)

    if (type.__meta == nil or type.__meta.is_property_private == nil) then
        return false
    end

    return meta.is_boolean(type.__meta.is_property_private[property_name])
end

--- @brief Set whether property of meta.Type is declared private
--- @param type meta.Type
--- @param property_name string
--- @param is_private boolean
--- @returns void
function meta.set_property_is_private(type, property_name, is_private)

    if not meta.is_type(type) then
        error("[ERROR] In meta.set_property_is_private: Object is not a type")
    end

    if not meta.has_property(type, property_name) then
        error("[ERROR] In meta.set_property_is_private: Type `" .. type.name .. "` does not have a property `" .. property_name .. "`")
    end

    type.is_property_private[property_name] = is_private
end

--- @brief Was property of meta instance declared private?
--- @param x any
--- @returns boolean
function meta.is_property_private(type, property_name)
    return rawget(type, "__meta").is_property_private[property_name]
end

--- @brief Add super type, type will inherit all properties from all its supertypes
--- @param type meta.Type
--- @param super meta.Type
--- @returns void
function meta.add_super_type(type, super)

    if not meta.is_type(type) then
        error("[ERROR] In meta.add_super_type: Subtype Object is not a type")
    end

    if not meta.is_type(super) then
        error("[ERROR] In meta.add_super_type: Supertype Object is not a type")
    end

    local super_super = super.__meta.super
    if super_super ~= nil then
        for _, t in pairs(super_super) do
            if t.name == type.name then
                error("[ERROR] In meta.add_super_type: Cyclic inheritance detected, `" .. type.name .. "` is already a supertype of `" .. super.name .. "`")
            end
        end
    end

    type.__meta.super[#type.__meta.super + 1] = super
end

--- @brief Is a subtype of b
--- @param a meta.Type
--- @param b meta.Type
--- @returns boolean
function meta.is_subtype_of(a, b)

    if not meta.is_type(a) then
        error("[ERROR] In meta.is_subtype: Subtype Object is not a type")
    end

    if not meta.is_type(b) then
        error("[ERROR] In meta.is_subtype: Supertype Object is not a type")
    end

    if a.__meta.super == nil then return false end
    for _, super in pairs(a.__meta.super) do
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
    return meta.is_subtype_of(b, a)
end

meta._public_label = "public"
meta._private_label = "private"
meta._super_label = "super"
meta._is_property_private_by_default = false

--- @brief Create a new meta.Type from a table, syntactically convenient
--- @param typename string Name of type
--- @param table table table with properties
--- @returns meta.Type
function meta.new_type_from(typename, table)

    if not meta.is_string(typename) then
        error("[ERROR] In meta.new_type_from: Argument #1 has to be string")
    end

    if not meta.is_table(table) then
        error("[ERROR] In meta.new_type_from: Argument #2 has to be table")
    end

    local x = meta.new_type(typename)

    local public = table[meta._public_label]
    if public ~= nil then
        for name, value in pairs(public) do
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

    local x = {}
    x.__meta = {}
    x.__meta.typename = type.__meta.name
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

        if not is_empty(public) then

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

        if not is_empty(private) then

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

    x.__meta.__pairs = function(this)
        return pairs(this.__meta.properties)
    end

    x.__meta.__ipairs = function(this)
        return ipairs(this.__meta.properties)
    end

    collect_properties = function(type_in, properties, is_property_private)

        for name, value in pairs(type_in) do
            if name ~= "__meta" then
                properties[name] = value
                is_property_private[name] = type_in.__meta.is_property_private[name]
            end
        end

        local super = type_in.super

        if super ~= nil then
            for _, super_type in pairs(super) do
                collect_properties(super_type, properties, is_property_private)
            end
        end
    end
    collect_properties(type, x.__meta.properties, x.__meta.is_property_private)

    setmetatable(x, x.__meta)

    if args ~= nil then
        for name, value in pairs(args) do
            meta.rawset_property(x, name, value)
        end
    end

    return x
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

--- @brief Access the property of an object irregardless of scope
--- @param x any
--- @param property_name string
--- @returns value of property
function meta.rawget_property(x, property_name)

    if not meta.is_instance(x) then
        error("[ERROR] In meta.rawset_property: Object is not a Type instance")
    end

    return rawget(x, "__meta").properties[property_name]
end

--- @brief Mutate property of an object irregardless of scope
--- @param x any
--- @param property_name string
--- @param value any
--- @returns void
function meta.rawset_property(x, property_name, new_value)

    if not meta.is_instance(x) then
        error("[ERROR] In meta.rawget_property: Object is not a Type instance")
    end

    if not meta.has_property(x, property_name) then
        error("[ERROR] In meta.rawset_property: Object does not have a property called `" .. property_name .. "`")
    end

    x.__meta.properties[property_name] = new_value
end

--- @brief manually add a property, works on types and instance
--- @param x any
--- @param name string
--- @param value any
--- @return void
function meta.rawadd_property(x, property_name, value)

    if not meta.is_instance(x) then
        error("[ERROR] In meta.rawget_property: Object is not a Type instance")
    end

    x.__meta.properties[property_name] = value
    x.__meta.is_property_private[property_name] = false
end


--- @brief unit test
function meta._test()
    test.start_test("meta")

    test.assert_that("is_string", meta.is_string("abcdef"))
    test.assert_that("is_table", meta.is_table({}))
    test.assert_that("is_number", meta.is_number(1234))
    test.assert_that("is_boolean", meta.is_boolean(true))
    test.assert_that("is_nil", meta.is_nil(nil))

    local Type = meta.new_type("Type")

    test.assert_that("type: is_type", meta.is_type(Type))
    test.assert_that("type: typeof", meta.typeof(Type) == "Type")

    local Super = meta.new_type("Super")
    meta.add_super_type(Type, Super)
    test.assert_that("type: is_supertype_of", meta.is_supertype_of(Super, Type))
    test.assert_that("type: is_subtype_of", meta.is_subtype_of(Type, Super))

    meta.add_property(Type, "public_property", 1234, false)
    meta.add_property(Type, "private_property", {}, true)

    local instance = meta.new(Type)

    test.assert_that("instance: is_instance", meta.is_instance(instance))
    test.assert_that("instance: typeof", meta.typeof(instance) == "Type")
    test.assert_that("instance: has_property", meta.has_property(instance, "public_property"))
    test.assert_that("instance: is_property_private", meta.is_property_private(instance, "private_property"))
    test.assert_that("instance: property access", instance.public_property == 1234)
    test.assert_that_errors("instance: private access", function() return instance.private_property end)

    local enum = meta.new_enum({
        A = 12,
        B = 13,
        C = 14
    })

    test.assert_that("enum: type", meta.typeof(enum) == "Enum")
    test.assert_that("enum: value", enum.A == 12)
    test.assert_that_errors("enum: constness", function() enum.A = 19 end)
    test.assert_that_errors("enum: value type", function() local test = meta.new_enum({A = {}}) end)
    test.assert_that_errors("enum: duplicate", function() local test = meta.new_enum({A = 13, B = 13}) end)
    test.assert_that("is_enum_value reject", not meta.is_enum_value(enum, -1))
    test.assert_that("is_enum_value accept", meta.is_enum_value(enum, 12))

    test.end_test()
end
