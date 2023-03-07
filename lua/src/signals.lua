signals = {}

--- @class signals.ID
signals.ID = string


instance = {}
instance.__signals = {}

--- @brief initialize signal component
--- @param entity table
--- @param signal_name signals.ID
function signals._initialize(x, signal_name)

    if not meta.is_instance(x) then
        error("[ERROR] In signals._initialize: Argument #1 is not an instance")
    end

    if not meta.is_string(signal_name) then
        error("[ERROR] In signals._initialize: Argument #2 is not a signals.ID")
    end

    if not meta.is_table(rawget(x, "__signals")) then
        rawset(x, "__signals", {})
    end

    if not meta.is_table(rawget(rawget(x, "__signals"), signal_name)) then
        rawset(rawget(x, "__signals"), signal_name, {
            f = function() end,
            data = 0,
            blocked = false
        })
    end

    meta.rawadd_property(x, "set_signal_" .. signal_name .. "_blocked", function(instance, b)
        instance.__signals[signal_name].blocked = b
    end)

    meta.rawadd_property(x, "get_signal_" .. signal_name .. "_blocked", function(instance)
        return instance.__signals[signal_name].blocked
    end)

    meta.rawadd_property(x, "connect_signal_" .. signal_name, function(instance, f, data)
        instance.__signals[signal_name].f = f
        instance.__signals[signal_name].data = data
        instance.__signals[signal_name].blocked = false
    end)

    meta.rawadd_property(x, "disconnect_signal_" .. signal_name, function(instance)
        instance.__signals[signal_name].f = function() end
        instance.__signals[signal_name].data = 0
        instance.__signals[signal_name].blocked = false
    end)

    meta.rawadd_property(x, "emit_signal_" .. signal_name, function(instance)

        local f = instance.__signals[signal_name].f
        local data = instance.__signals[signal_name].data
        local blocked = instance.__signals[signal_name].blocked

        if not blocked then
            f(data)
        end
    end)

    return x
end

e = meta.new(meta.new_type_from("Test_t", {}))
signals._initialize(e, "test")
e:set_signal_test_blocked(true)
