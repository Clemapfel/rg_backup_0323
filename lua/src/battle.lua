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

--- @class BattleEntity
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

        _status_ailments = {}
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
});

--- @brief BattleEntity ctor
--- @param id string
function rat.BattleEntity(id)

    if not meta.is_string(id) then
        error("[ERROR] In BattleEntity.ctor: `id` argument has to be  string")
    end

    return rat._BattleEntity({
        _id = id
    })
end

function rat._BattleEntity.get_id(entity)
    return meta.rawget_property(entity, "_id")
end

--- @brief get attack base
--- @param entity BattleEntity
--- @return number
function rat._BattleEntity.get_attack_base(entity)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.get_base_attack: Argument is not a BattleEntity")
    end

    return meta.rawget_property(entity, "_base_attack")
end

--- @brief get attack modification level
--- @param entity BattleEntity
--- @return StatLevel
function rat._BattleEntity.get_attack_level(entity)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.get_attack_level: Argument is not a BattleEntity")
    end

    return meta.rawget_property(entity, "_attack_level")
end

--- @brief get attack, takes level into account
--- @param entity BattleEntity
--- @return number
function rat._BattleEntity.get_attack(entity)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.get_attack: Argument is not a BattleEntity")
    end

    return rat._stat_level_to_factor(entity:get_attack_level()) * entity:get_attack_base()
end

--- @brief get defense base
--- @param entity BattleEntity
--- @return number
function rat._BattleEntity.get_defense_base(entity)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.get_base_defense: Argument is not a BattleEntity")
    end

    return meta.rawget_property(entity, "_base_defense")
end

--- @brief get defense modification level
--- @param entity BattleEntity
--- @return StatLevel
function rat._BattleEntity.get_defense_level(entity)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.get_defense_level: Argument is not a BattleEntity")
    end

    return meta.rawget_property(entity, "_defense_level")
end

--- @brief get defense, takes level into account
--- @param entity BattleEntity
--- @return number
function rat._BattleEntity.get_defense(entity)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.get_defense: Argument is not a BattleEntity")
    end

    return rat._stat_level_to_factor(entity:get_defense_level()) * entity:get_defense_base()
end

--- @brief get speed base
--- @param entity BattleEntity
--- @return number
function rat._BattleEntity.get_speed_base(entity)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.get_base_speed: Argument is not a BattleEntity")
    end

    return meta.rawget_property(entity, "_base_speed")
end

--- @brief get speed modification level
--- @param entity BattleEntity
--- @return StatLevel
function rat._BattleEntity.get_speed_level(entity)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.get_speed_level: Argument is not a BattleEntity")
    end

    return meta.rawget_property(entity, "_speed_level")
end

--- @brief get speed, takes level into account
--- @param entity BattleEntity
--- @return number
function rat._BattleEntity.get_speed(entity)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.get_speed: Argument is not a BattleEntity")
    end

    return rat._stat_level_to_factor(entity:get_speed_level()) * entity:get_speed_base()
end

--- @brief add to attack level
--- @param entity BattleEntity
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
--- @param entity BattleEntity
--- @param n_levels number
--- @return void
function rat._BattleEntity.lower_attack(entity, n_levels)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.lower_attack: Argument is not a BattleEntity")
    end

    entity:raise_attack(-1 * n_levels)
end

--- @brief set attack level back to default
--- @param entity BattleEntity
--- @return void
function rat._BattleEntity.reset_attack(entity)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.reset_attack: Argument is not a BattleEntity")
    end

    meta.rawset_property(entity, "_attack_level", value)
end

--- @brief add to defense level
--- @param entity BattleEntity
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
--- @param entity BattleEntity
--- @param n_levels number
--- @return void
function rat._BattleEntity.lower_defense(entity, n_levels)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.lower_defense: Argument is not a BattleEntity")
    end

    entity:raise_defense(-1 * n_levels)
end

--- @brief set defense level back to default
--- @param entity BattleEntity
--- @return void
function rat._BattleEntity.reset_defense(entity)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.reset_defense: Argument is not a BattleEntity")
    end

    meta.rawset_property(entity, "_defense_level", value)
end

--- @brief add to speed level
--- @param entity BattleEntity
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
--- @param entity BattleEntity
--- @param n_levels number
--- @return void
function rat._BattleEntity.lower_speed(entity, n_levels)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.lower_speed: Argument is not a BattleEntity")
    end

    entity:raise_speed(-1 * n_levels)
end

--- @brief set speed level back to default
--- @param entity BattleEntity
--- @return void
function rat._BattleEntity.reset_speed(entity)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.reset_speed: Argument is not a BattleEntity")
    end

    meta.rawset_property(entity, "_speed_level", value)
end

--- @brief raise hp of entity
--- @param entity BattleEntity
--- @return number
function rat._BattleEntity.get_hp(entity)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.get_hp: Argument is not a BattleEntity")
    end

    return meta.rawget_property(entity, "_hp")
end

--- @brief raise hp of entity
--- @param entity BattleEntity
--- @return number
function rat._BattleEntity.get_hp_base(entity)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.get_hp_base: Argument is not a BattleEntity")
    end

    return meta.rawget_property(entity, "_hp_base")
end

--- @brief raise hp of entity
--- @param entity BattleEntity
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
--- @param entity BattleEntity
--- @param value number
--- @return void
function rat._BattleEntity.reduce_hp(entity, value)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.reduce_hp: Argument is not a BattleEntity")
    end

    entity:add_hp(-1 * value)
end

--- @brief set hp of entity
--- @param entity BattleEntity
--- @param value number
--- @return void
function rat._BattleEntity.set_hp(entity, value)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.set_hp: Argument is not a BattleEntity")
    end

    meta.rawset_property(entity, clamp(value, 0, entity:get_hp_base()))
end

--- @brief raise ap of entity
--- @param entity BattleEntity
--- @return number
function rat._BattleEntity.get_ap(entity)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.get_ap: Argument is not a BattleEntity")
    end

    return meta.rawget_property(entity, "_ap")
end

--- @brief raise ap of entity
--- @param entity BattleEntity
--- @return number
function rat._BattleEntity.get_ap_base(entity)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.get_ap_base: Argument is not a BattleEntity")
    end

    return meta.rawget_property(entity, "_ap_base")
end

--- @brief raise ap of entity
--- @param entity BattleEntity
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
--- @param entity BattleEntity
--- @param value number
--- @return void
function rat._BattleEntity.reduce_ap(entity, value)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.reduce_ap: Argument is not a BattleEntity")
    end

    entity:add_ap(-1 * value)
end

--- @brief set ap of entity
--- @param entity BattleEntity
--- @param value number
--- @return void
function rat._BattleEntity.set_ap(entity, value)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rat.set_ap: Argument is not a BattleEntity")
    end

    meta.rawset_property(entity, clamp(value, 0, entity:get_ap_base()))
end


