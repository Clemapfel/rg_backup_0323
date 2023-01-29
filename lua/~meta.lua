meta = {}


function meta.detail.get_type(id)
    return meta.detail.type_ids[id]
end

function meta.typeof(object)
    return meta.detail.type_ids[object.__meta.type]
end

function meta.isa(object, type)
    return meta.detail.type_ids[object.__meta.type] == type
end

function meta.add_property(type, property_name, property_value)

    type.__meta.properties[property_name] = property_value
    rawset(type, "set_" .. property_name, function(this, x) this.__meta.properties[property_name] = x end)
    rawset(type, "get_" .. property_name, function(this) return this.__meta.properties[property_name] end)
end

function meta.add_const_property(type, property_name, property_value)

    type.__meta.const_properties[property_name] = property_value
    rawset(type, "get_" .. property_name, function(this) return this.__meta.const_properties[property_name] end)
end

function meta.new_type(type_name)

    out = {}
    out.__meta = {}

    out.__meta.const_properties = {}
    out.__meta.properties = {}
    out.__meta.type = meta.detail.add_type(type_name)

    out.__meta.__index = function(this, key)

        x = this.__meta.properties[key]
        if (x == nil) then
            return this.__meta.const_properties
        else
            return x
        end
    end

    out.__meta.__newindex = function(this, key, value)

        if (this.__meta.properties[key] ~= nil) then
            this.__meta.properties[key] = value
        elseif this.__meta.const_properties[key] ~= nil then
            error("In __newindex for object of type " .. meta.typeof(this) .. ": Trying to assign property \"" .. key .. "\" but it is declared const")
        else
            error("In __newindex for object of type " .. meta.typeof(this) .. ": No property with name \"" .. key .. "\". Use meta.add_property instead")
        end
    end

    setmetatable(out, out.__meta)
    meta.detail.type_instances[]
end

-- TEST
instance = meta.new_type("Test_t")
meta.add_property(instance, "mutable", 12)
meta.add_const_property(instance, "immutable", 13)

print(instance:get_mutable())
instance:set_mutable(19)
print(instance:get_mutable())

print(instance:get_immutable())
instance["immutable"] = 12