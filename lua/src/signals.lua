signals = {}

--- @class signals.ID
signals.ID = "string"

signals.set_signal_blocked = function(instance, signal_name, b)
    rawget(instance, "__signals")[signal_name].blocked = b
end

signals.get_signal_blocked = function(instance, signal_name)
    return rawget(instance, "__signals")[signal_name].blocked
end

signals.connect_signal = function(instance, signal_name, f, data)
    local s = rawget(instance, "__signals")
    s[signal_name].f = f
    s[signal_name].data = data
    s[signal_name].blocked = false
end

signals.disconnect_signal = function(instance, signal_name)
    local s = rawget(instance, "__signals")
    s[signal_name].f = function()  end
    s[signal_name].data = nil
    s[signal_name].blocked = false
end

signals.emit_signal = function(instance, signal_name)

    local s = rawget(instance, "__signals")
    local f = s[signal_name].f
    local data = s[signal_name].data
    local blocked = s[signal_name].blocked

    if not blocked then
        f(data)
    end
end

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

    if not meta.is_valid_name(signal_name) then
        error("[ERROR] In signals._initialize: \"" .. signal_name .. "\" is not a valid identifier")
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
        signals.set_signal_blocked(instance, signal_name, b)
    end)

    meta.rawadd_property(x, "get_signal_" .. signal_name .. "_blocked", function(instance)
        return signals.get_signal_blocked(instance, signal_name)
    end)

    meta.rawadd_property(x, "connect_signal_" .. signal_name, function(instance, f, data)
        signals.connect_signal(instance, signal_name, f, data)
    end)

    meta.rawadd_property(x, "disconnect_signal_" .. signal_name, function(instance)
        signals.disconnect_signal(instance, signal_name)
    end)

    meta.rawadd_property(x, "emit_signal_" .. signal_name, function(instance)
        signals.emit_signal(instance, signal_name)
    end)

    return x
end

--- @brief add signal infrastructure to object
--- @param x any
--- @param signal_name signals.ID
function signals.add_signal(x, signal_name)
    signals._initialize(x, signal_name)
    return x
end

--- @brief unit test
function signals._test()

    test.start_test("signals")
    local instance = meta.new(meta.new_type_from("Test", {}))

    signals.add_signal(instance, "test")

    local res = false
    instance:connect_signal_test(function(x)
        res = x
    end, true)

    instance:emit_signal_test()
    test.assert_that("emit result", res)

    test.end_test()
end
signals._test()


