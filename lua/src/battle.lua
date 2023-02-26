require "meta"
require "test"
require "log"

--- @brief enum: StatLevel
rat_game.StatLevel = {}

rat_game.StatLevel.NEGATIVE_4 = -4
rat_game.StatLevel.NEGATIVE_3 = -3
rat_game.StatLevel.NEGATIVE_2 = -2
rat_game.StatLevel.NEGATIVE_1 = -1
rat_game.StatLevel.NONE = 0
rat_game.StatLevel.PLUS_1 = 1
rat_game.StatLevel.PLUS_2 = 2
rat_game.StatLevel.PLUS_3 = 3
rat_game.StatLevel.PLUS_4 = 4

rat_game.BattleEntity = meta.new_type_from("BattleEntity", {

    private = {
        attack = 0,
        defense = 0,
        speed = 0,

        attack_level = 0,
        defense_level = 0,
        speed_level = 0
    }
});

