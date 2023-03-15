--- @brief signaling system
signals = {}

--- @class signals.ID
signals.ID = "string"

--- @brief check if object has a signal
--- @param instance any
--- @param signal_name signals.ID
--- @return boolean
function signals.has_signal(instance, signal_name)

    if not meta.is_string(signal_name) then
        error("[ERROR] In signals.has_signal: Argument #2 is not a signal id")
    end

    return meta.is_table(rawget(instance, "__signals")[signal_name])
end

--- @brief block a signal
--- @param instance any
--- @param signal_name signals.ID
--- @param blocked boolean
--- @return void
function signals.set_signal_blocked(instance, signal_name, blocked)

    if not signals.has_signal(instance, signal_name) then
        error("[ERROR] In signals.set_signal_blocked: Object has no signal \"" .. signal_name .. "\"")
    end

    rawget(instance, "__signals")[signal_name].blocked = blocked
end

--- @brief check wether signal is blocked
--- @param instance any
--- @param signal_name signals.ID
--- @return boolean
function signals.get_signal_blocked(instance, signal_name)

    if not signals.has_signal(instance, signal_name) then
        error("[ERROR] In signals.get_signal_blocked: Object has no signal \"" .. signal_name .. "\"")
    end

    return rawget(instance, "__signals")[signal_name].blocked
end

--- @brief connect command to signal
--- @param instance any
--- @param signal_name signals.ID
--- @param data any
--- @return void
function signals.connect_signal(instance, signal_name, f, data)

    if not signals.has_signal(instance, signal_name) then
        error("[ERROR] In signals.connect_signal: Object has no signal \"" .. signal_name .. "\"")
    end

    local s = rawget(instance, "__signals")
    s[signal_name].f = f
    s[signal_name].data = data
end

--- @brief associate noop action with signal
--- @param instance any
--- @param signal_name signals.ID
--- @retrun void
function signals.disconnect_signal(instance, signal_name)

    if not signals.has_signal(instance, signal_name) then
        error("[ERROR] In signals.disconnect_signal: Object has no signal \"" .. signal_name .. "\"")
    end

    local s = rawget(instance, "__signals")
    s[signal_name].f = function()  end
    s[signal_name].data = nil
    s[signal_name].blocked = false
end

--- @brief emit a signal, if it not blocked its associated action will be called
--- @param instance any
--- @param signal_name signals.ID
--- @return void
function signals.emit_signal(instance, signal_name)

    if not signals.has_signal(instance, signal_name) then
        error("[ERROR] In signals.emit_signal: Object has no signal \"" .. signal_name .. "\"")
    end

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
--- @return void
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
end

--- @brief add signal infrastructure to object
--- @param x any
--- @param signal_name signals.ID
--- @return void
function signals.add_signal(x, signal_name)
    signals._initialize(x, signal_name)
    return x
end

--- @brief add signal infrastructure to object
--- @param x any
--- @param signal_name signals.ID
--- @return void
function signals.add_signals(x, signals)

    for _, signal_name in ipairs(signals) do
        signals._initialize(x, signal_name)
    end
    return x
end

--- @brief unit test
function signals._test()

    test.start_test("signals")
    local instance = meta.new(meta.new_type_from("Test", {}))

    signals.add_signal(instance, "test")
    test.assert_that("has_signal", signals.has_signal(instance, "test"))

    instance:set_signal_test_blocked(true)
    test.assert_that("blocked", instance:get_signal_test_blocked())

    local count = 0
    instance:connect_signal_test(function (x)
        count = count + 1
    end, true)

    instance:emit_signal_test()
    test.assert_that("blocked emission",  count == 0)

    instance:set_signal_test_blocked(false)
    instance:emit_signal_test()
    test.assert_that("unblocked emission", count == 1)

    test.end_test()
end

