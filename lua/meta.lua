
--- @brief print warning to cerr
--- @param message string
function warning(message)
    io.stderr.write("[WARNING]" .. message)
end

---
function new_prototype(name, table)

    if _G["mousetrap"] == nil then
        _G["mousetrap"] = {}
    end

    if _G["mousetrap"]["types"] == nil then
        _G["mousetrap"]["types"] = []
    end

    _G["mousetrap"]["types"]

end


BattleEntity_t = {
    health = 0,
    ap = 0,

    attack = 0,
    defense = 0,
    speed = 0
}

function new_battle_entity()

    out = {}
    out.__meta = {
        __index = BatteEntity_t,
        __newindex = function(instance, key, value)
            warning("Attempting to write ")
        end
    }
end