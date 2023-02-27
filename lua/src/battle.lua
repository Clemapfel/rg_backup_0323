--- @brief enum: StatLevel
rt.StatLevel = meta.new_enum({
    MINUS_4 = -4,
    MINUS_3 = -3,
    MINUS_2 = -2,
    MINUS_1 = -1,
    ZERO = 0,
    PLUS_1 = 1,
    PLUS_2 = 2,
    PLUS_3 = 3,
    PLUS_4 = 4
})

--- @brief convert stat level enum to numerical factor
function rt._stat_level_to_factor(level)

    if not meta.is_enum_value(rt.StatLevel, level) then
        error("[ERROR] In stat_level_to_factor: Argument is not a StatLevel")
    end

    if level == rt.StatLevel.MINUS_4 then
        return 0.1;
    elseif level == rt.StatLevel.MINUS_3 then
        return 0.25;
    elseif level == rt.StatLevel.MINUS_2 then
        return 0.5;
    elseif level == rt.StatLevel.MINUS_1 then
        return 0.75
    elseif level == rt.StatLevel.ZERO then
        return 1
    elseif level == rt.StatLevel.PLUS_1 then
        return 1.25
    elseif level == rt.StatLevel.PLUS_2 then
        return 1.5
    elseif level == rt.StatLevel.PLUS_3 then
        return 2
    elseif level == rt.StatLevel.PLUS_4 then
        return 3
    end
end

--- @brief
rt.BattleEntity = meta.new_type_from("BattleEntity", {

    private =
    {
        _id = meta.String(),

        _base_attack = meta.Number(0),
        _base_defense = meta.Number(0),
        _base_speed = meta.Number(0),

        _attack_level = rt.StatLevel.ZERO,
        _defense_level = rt.StatLevel.ZERO,
        _speed_level = rt.StatLevel.ZERO
    },

    get_attack = meta.Function(),
    get_attack_level = meta.Function(),
    get_attack_base = meta.Function(),
});

--- @brief get attack base
rt.BattleEntity.get_attack_base = function(entity)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rt.get_base_attack: Argument is not a BattleEntity")
    end

    return meta.rawget_property(entity, "_base_attack")
end

--- @brief get attack level
rt.BattleEntity.get_attack_level = function(entity)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rt.get_attack_level: Argument is not a BattleEntity")
    end

    return meta.rawget_property(entity, "_attack_level")
end

--- @brief get attack, takes level into account
rt.BattleEntity.get_attack = function(entity)

    if meta.typeof(entity) ~= "BattleEntity" then
        error("[ERROR] In rt.get_attack: Argument is not a BattleEntity")
    end

    return rt._stat_level_to_factor(entity:get_attack_level()) * entity:get_attack_base()
end


