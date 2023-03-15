--- @class StatLevel
rat.StatLevel = meta.new_enum({
    MINIMUM = -4,
    MINUS_3 = -3,
    MINUS_2 = -2,
    MINUS_1 = -1,
    ZERO = 0,
    PLUS_1 = 1,
    PLUS_2 = 2,
    PLUS_3 = 3,
    MAXIMUM = 4
})

--- @class StatusAilment
rat.StatusAilment = meta.new_enum({
    DEAD = -1,
    KNOCKED_OUT = 0,
    NO_STATUS = 1,
    AT_RISK = 2,
    STUNNED = 3,
    ASLEEP = 4,
    POISONED = 5,
    BLINDED = 6,
    BURNED = 7,
    CHILLED = 8,
    FROZEN = 9
})
meta.export_enum(rat.StatusAilment, rat)

--- @brief convert stat level enum to numerical factor
--- @param level StatLevel
--- @return number
function rat._stat_level_to_factor(level)

    if not meta.is_enum_value(rat.StatLevel, level) then
        error("[ERROR] In stat_level_to_factor: Argument is not a StatLevel")
    end

    if level == rat.StatLevel.MINUS_4 then
        return 0.1;
    elseif level == rat.StatLevel.MINUS_3 then
        return 0.25;
    elseif level == rat.StatLevel.MINUS_2 then
        return 0.5;
    elseif level == rat.StatLevel.MINUS_1 then
        return 0.75
    elseif level == rat.StatLevel.ZERO then
        return 1
    elseif level == rat.StatLevel.PLUS_1 then
        return 1.25
    elseif level == rat.StatLevel.PLUS_2 then
        return 1.5
    elseif level == rat.StatLevel.PLUS_3 then
        return 2
    elseif level == rat.StatLevel.PLUS_4 then
        return 3
    end
end

--- @class rat.BattleEntity
rat._BattleEntity = meta.new_type_from("BattleEntity", {

    private = {
        _id = meta.String(),

        _base_attack = meta.Number(0),
        _base_defense = meta.Number(0),
        _base_speed = meta.Number(0),

        _hp_base = meta.Number(1),
        _hp_current = meta.Number(0),

        _ap_base = meta.Number(1),
        _ap_current = meta.Number(0),

        _attack_level = rat.StatLevel.ZERO,
        _defense_level = rat.StatLevel.ZERO,
        _speed_level = rat.StatLevel.ZERO,

        _status_ailments = {},
        _status_ailments_turn_count = {}
    },

    get_hp = meta.Function(),
    get_hp_base = meta.Function(),
    add_hp = meta.Function(),
    reduce_hp = meta.Function(),
    set_hp = meta.Function(),

    get_ap = meta.Function(),
    get_ap_base = meta.Function(),
    add_ap = meta.Function(),
    reduce_ap = meta.Function(),
    set_ap = meta.Function(),

    get_attack = meta.Function(),
    get_attack_level = meta.Function(),
    get_attack_base = meta.Function(),
    raise_attack = meta.Function(),
    lower_attack = meta.Function(),
    reset_attack = meta.Function(),

    get_defense = meta.Function(),
    get_defense_level = meta.Function(),
    get_defense_base = meta.Function(),
    raise_defense = meta.Function(),
    lower_defense = meta.Function(),
    reset_defense = meta.Function(),

    get_speed = meta.Function(),
    get_speed_level = meta.Function(),
    get_speed_base = meta.Function(),
    raise_speed = meta.Function(),
    lower_speed = meta.Function(),
    reset_speed = meta.Function(),

    add_status_ailment = meta.Function(),
    remove_status_ailment = meta.Function(),
    has_status_ailment = meta.Function()
});

--- @brief BattleEntity ctor
--- @param id string
function rat.BattleEntity(id)

    if not meta.is_string(id) then
        error("[ERROR] In BattleEntity.ctor: `id` argument has to be  string")
    end

    local out = rat._BattleEntity({
        _id = id
    })

    local status = {}
    local status_turn_count = {}
    for  _, ailment in pairs(rat.StatusAilment) do
        status[ailment] = false
        status_turn_count[ailment] = 0
    end

    meta.rawset_property(out, "_status_ailments", status)
    meta.rawset_property(out, "_status_ailments_turn_count", status)
    return out
end

--- @brief get id of BattleEntity
--- @param entity
function rat._BattleEntity.get_id(entity)
    return meta.rawget_property(entity, "_id")
end

--- @brief get attack base
--- @param entity rat.BattleEntity
--- @return number
function rat._BattleEntity.get_attack_base(entity)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.get_base_attack: Argument is not a BattleEntity")
    end

    return meta.rawget_property(entity, "_base_attack")
end

--- @brief get attack modification level
--- @param entity rat.BattleEntity
--- @return StatLevel
function rat._BattleEntity.get_attack_level(entity)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.get_attack_level: Argument is not a BattleEntity")
    end

    return meta.rawget_property(entity, "_attack_level")
end

--- @brief get attack, takes level into account
--- @param entity rat.BattleEntity
--- @return number
function rat._BattleEntity.get_attack(entity)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.get_attack: Argument is not a BattleEntity")
    end

    return rat._stat_level_to_factor(entity:get_attack_level()) * entity:get_attack_base()
end

--- @brief get defense base
--- @param entity rat.BattleEntity
--- @return number
function rat._BattleEntity.get_defense_base(entity)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.get_base_defense: Argument is not a BattleEntity")
    end

    return meta.rawget_property(entity, "_base_defense")
end

--- @brief get defense modification level
--- @param entity rat.BattleEntity
--- @return StatLevel
function rat._BattleEntity.get_defense_level(entity)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.get_defense_level: Argument is not a BattleEntity")
    end

    return meta.rawget_property(entity, "_defense_level")
end

--- @brief get defense, takes level into account
--- @param entity rat.BattleEntity
--- @return number
function rat._BattleEntity.get_defense(entity)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.get_defense: Argument is not a BattleEntity")
    end

    return rat._stat_level_to_factor(entity:get_defense_level()) * entity:get_defense_base()
end

--- @brief get speed base
--- @param entity rat.BattleEntity
--- @return number
function rat._BattleEntity.get_speed_base(entity)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.get_base_speed: Argument is not a BattleEntity")
    end

    return meta.rawget_property(entity, "_base_speed")
end

--- @brief get speed modification level
--- @param entity rat.BattleEntity
--- @return StatLevel
function rat._BattleEntity.get_speed_level(entity)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.get_speed_level: Argument is not a BattleEntity")
    end

    return meta.rawget_property(entity, "_speed_level")
end

--- @brief get speed, takes level into account
--- @param entity rat.BattleEntity
--- @return number
function rat._BattleEntity.get_speed(entity)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.get_speed: Argument is not a BattleEntity")
    end

    return rat._stat_level_to_factor(entity:get_speed_level()) * entity:get_speed_base()
end

--- @brief add to attack level
--- @param entity rat.BattleEntity
--- @param n_levels number
--- @return void
function rat._BattleEntity.raise_attack(entity, n_levels)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.raise_attack: Argument is not a BattleEntity")
    end

    if n_levels == nil then n_levels = 1 end

    local value = entity:get_attack_leve()
    value = clamp(value + n_levels, StatLevel.MINIMUM, StatLevel.MAXIMUM)

    meta.rawset_property(entity, "_attack_leve", value)
end

--- @brief subtract from attack level
--- @param entity rat.BattleEntity
--- @param n_levels number
--- @return void
function rat._BattleEntity.lower_attack(entity, n_levels)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.lower_attack: Argument is not a BattleEntity")
    end

    entity:raise_attack(-1 * n_levels)
end

--- @brief set attack level back to default
--- @param entity rat.BattleEntity
--- @return void
function rat._BattleEntity.reset_attack(entity)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.reset_attack: Argument is not a BattleEntity")
    end

    meta.rawset_property(entity, "_attack_level", value)
end

--- @brief add to defense level
--- @param entity rat.BattleEntity
--- @param n_levels number
--- @return void
function rat._BattleEntity.raise_defense(entity, n_levels)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.raise_defense: Argument is not a BattleEntity")
    end

    if n_levels == nil then n_levels = 1 end

    local value = entity:get_defense_leve()
    value = clamp(value + n_levels, StatLevel.MINIMUM, StatLevel.MAXIMUM)

    meta.rawset_property(entity, "_defense_leve", value)
end

--- @brief subtract from defense level
--- @param entity rat.BattleEntity
--- @param n_levels number
--- @return void
function rat._BattleEntity.lower_defense(entity, n_levels)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.lower_defense: Argument is not a BattleEntity")
    end

    entity:raise_defense(-1 * n_levels)
end

--- @brief set defense level back to default
--- @param entity rat.BattleEntity
--- @return void
function rat._BattleEntity.reset_defense(entity)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.reset_defense: Argument is not a BattleEntity")
    end

    meta.rawset_property(entity, "_defense_level", value)
end

--- @brief add to speed level
--- @param entity rat.BattleEntity
--- @param n_levels number
--- @return void
function rat._BattleEntity.raise_speed(entity, n_levels)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.raise_speed: Argument is not a BattleEntity")
    end

    if n_levels == nil then n_levels = 1 end

    local value = entity:get_speed_leve()
    value = clamp(value + n_levels, StatLevel.MINIMUM, StatLevel.MAXIMUM)

    meta.rawset_property(entity, "_speed_leve", value)
end

--- @brief subtract from speed level
--- @param entity rat.BattleEntity
--- @param n_levels number
--- @return void
function rat._BattleEntity.lower_speed(entity, n_levels)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.lower_speed: Argument is not a BattleEntity")
    end

    entity:raise_speed(-1 * n_levels)
end

--- @brief set speed level back to default
--- @param entity rat.BattleEntity
--- @return void
function rat._BattleEntity.reset_speed(entity)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.reset_speed: Argument is not a BattleEntity")
    end

    meta.rawset_property(entity, "_speed_level", value)
end

--- @brief raise hp of entity
--- @param entity rat.BattleEntity
--- @return number
function rat._BattleEntity.get_hp(entity)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.get_hp: Argument is not a BattleEntity")
    end

    return meta.rawget_property(entity, "_hp")
end

--- @brief raise hp of entity
--- @param entity rat.BattleEntity
--- @return number
function rat._BattleEntity.get_hp_base(entity)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.get_hp_base: Argument is not a BattleEntity")
    end

    return meta.rawget_property(entity, "_hp_base")
end

--- @brief raise hp of entity
--- @param entity rat.BattleEntity
--- @param value number
--- @return void
function rat._BattleEntity.add_hp(entity, value)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.add_hp: Argument is not a BattleEntity")
    end

    local value = meta.rawget_property(entity, "_hp") + value
    value = clamp(value, 0, entity:get_hp_base())

    meta.rawset_property(entity, "_hp_current", value)
end

--- @brief reduce hp of entity
--- @param entity rat.BattleEntity
--- @param value number
--- @return void
function rat._BattleEntity.reduce_hp(entity, value)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.reduce_hp: Argument is not a BattleEntity")
    end

    entity:add_hp(-1 * value)
end

--- @brief set hp of entity
--- @param entity rat.BattleEntity
--- @param value number
--- @return void
function rat._BattleEntity.set_hp(entity, value)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.set_hp: Argument is not a BattleEntity")
    end

    meta.rawset_property(entity, clamp(value, 0, entity:get_hp_base()))
end

--- @brief raise ap of entity
--- @param entity rat.BattleEntity
--- @return number
function rat._BattleEntity.get_ap(entity)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.get_ap: Argument is not a BattleEntity")
    end

    return meta.rawget_property(entity, "_ap")
end

--- @brief raise ap of entity
--- @param entity rat.BattleEntity
--- @return number
function rat._BattleEntity.get_ap_base(entity)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.get_ap_base: Argument is not a BattleEntity")
    end

    return meta.rawget_property(entity, "_ap_base")
end

--- @brief raise ap of entity
--- @param entity rat.BattleEntity
--- @param value number
--- @return void
function rat._BattleEntity.add_ap(entity, value)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.add_ap: Argument is not a BattleEntity")
    end

    local value = meta.rawget_property(entity, "_ap") + value
    value = clamp(value, 0, entity:get_ap_base())

    meta.rawset_property(entity, "_ap_current", value)
end

--- @brief reduce ap of entity
--- @param entity rat.BattleEntity
--- @param value number
--- @return void
function rat._BattleEntity.reduce_ap(entity, value)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.reduce_ap: Argument is not a BattleEntity")
    end

    entity:add_ap(-1 * value)
end

--- @brief set ap of entity
--- @param entity rat.BattleEntity
--- @param value number
--- @return void
function rat._BattleEntity.set_ap(entity, value)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.set_ap: Argument is not a BattleEntity")
    end

    meta.rawset_property(entity, clamp(value, 0, entity:get_ap_base()))
end

--- @brief add a status ailment to entity, respects status logic
--- @param entity rat.BattleEntity
--- @param new_status StatusAilment
--- @return void
function rat._BattleEntity.add_status_ailment(entity, new_status)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.add_status_ailment: Argument #1 is not a BattleEntity")
    end

    if not meta.is_enum_value(rat.StatusAilment, new_status) then
        error("[ERROR] In rat.add_status_ailment: Argument #2 is not a StatusAilment")
    end

    local has_status = function(which)
        return meta.rawget_property(entity, "_status_ailments")[which]
    end

    local set_status = function(which, bool)

        if has_status(which) then return end
        meta.rawget_property(entity, "_status_ailments")[which] = bool
    end

    local add_status = function(which)
        set_status(which, true)
    end

    local remove_status = function(which)
        set_status(which, false)
    end

    if new_status == rat.DEAD then

        for _, s in pairs(rat.StatusAilment) do
            set_status(s, false)
        end
        set_status(rat.StatusAilment)

    elseif new_status == rat.KNOCKED_OUT then

        if has_status(rat.DEAD) then
            return
        else
            for _, s in pairs(rat.StatusAilment) do
                set_status(s, false)
            end
        end
        set_status(rat.StatusAilment)

    elseif new_status == rat.CHILLED then

        if has_status(rat.CHILLED) then
            remove_status(rat.CHILLED)
            add_status(rat.FROZEN)
        elseif has_status(rat.BURNED) then
            remove_status(rat.BURNED)
        else
            add_status(rat.FROZEN)
        end

    elseif new_status == rat.FROZEN then

        if has_status(rat.CHILLED) then
            remove_status(rat.CHILLED)
            add_status(rat.FROZEN)
        elseif has_status(rat.BURNED) then
            remove_status(rat.BURNED)
        else
            add_status(rat.FROZEN)
        end

    elseif new_status == rat.BURNED then

        if has_status(rat.CHILLED) then
            remove_status(rat.CHILLED)
        elseif has_status(rat.FROZEN) then
            remove_status(rat.FROZEN)
        else
            add_status(rat.BURNED)
        end
    else
        add_status(new_status)
    end

    meta.rawget_property(entity, "_status_ailments")[new_status] = true
end

--- @brief does entity have a status ailment
--- @param entity rat.BattleEntity
--- @param status StatusAilment
--- @return boolean
function rat._BattleEntity.has_status_ailment(entity, status)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.has_status_ailment: Argument #1 is not a BattleEntity")
    end

    if not meta.is_enum_value(rat.StatusAilment, status) then
        error("[ERROR] In rat.has_status_ailment: Argument #2 is not a StatusAilment")
    end

    return meta.rawget_property(entity, "_status_ailments")[status]
end

--- @brief does entity have a status ailment
--- @param entity rat.BattleEntity
--- @param status StatusAilment
--- @return boolean
function rat._BattleEntity.remove_status_ailment(entity, status)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.remove_status_ailment: Argument #1 is not a BattleEntity")
    end

    if not meta.is_enum_value(rat.StatusAilment, status) then
        error("[ERROR] In rat.remove_status_ailment: Argument #2 is not a StatusAilment")
    end

    meta.rawget_property(entity, "_status_ailments")[status] = false
end

--- @brief apply turn count to status
--- @param entity rat.BattleEntity
function rat._resolve_status_ailment_turn_count_advance(entity)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.apply_turn_count_to_status_ailments: Argument #1 is not a BattleEntity")
    end

    rat._status_turn_count = (function ()
        local out = {}
        out[rat.DEAD] = INFINITY
        out[rat.KNOCKED_OUT] = INFINITY
        out[rat.NO_STATUS] = INFINITY
        out[rat.AT_RISK] = 3
        out[rat.STUNNED] = 1
        out[rat.ASLEEP] = INFINITY
        out[rat.POISONED] = INFINITY
        out[rat.BLINDED] = INFINITY
        out[rat.BURNED] = INFINITY
        out[rat.CHILLED] = INFINITY
        out[rat.FROZEN] = INFINITY
        return out
    end)()

    rat._status_ailment_effect = (function()
        local out = {}
        out[rat.DEAD] = nil
        out[rat.KNOCKED_OUT] = nil
        out[rat.NO_STATUS] = nil
        out[rat.AT_RISK] = 3
        out[rat.STUNNED] = 1
        out[rat.ASLEEP] = INFINITY
        out[rat.POISONED] = INFINITY
        out[rat.BLINDED] = INFINITY
        out[rat.BURNED] = INFINITY
        out[rat.CHILLED] = INFINITY
        out[rat.FROZEN] = INFINITY
    end)()

    local turn_counts = meta.rawget_property(entity, "_status_ailments_turn_count")
    for  _, ailment in pairs(rat.StatusAilment) do

        turn_counts[ailment] = turn_counts[ailment] + 1
        if turn_counts[ailment] > rat._status_turn_count[ailment] then
            rat.remove_status_ailment(entity, ailment)
        end
    end
end

rat.BattleContinuousEffect = meta.new_type_from("BattleContinuousEffect", {

    -- applied as base += factor * base
    attack_base_factor = meta.Number(0),
    defense_base_factor = meta.Number(0),
    speed_base_factor = meta.Number(0),

    -- applied as stat += factor * state
    attack_factor = meta.Number(0),
    defense_factor = meta.Number(0),
    speed_factor = meta.Number(0),

    -- applied at start of round

})


