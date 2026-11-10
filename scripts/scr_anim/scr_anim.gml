
function anim_config() {
    return {
        idle: {
            spr: [
                spr_pl_idle_right,
                spr_pl_idle_up,
                spr_pl_idle_left,
                spr_pl_idle_down
            ],
            fps: 8
        },

        walk: {
            spr: [
                spr_pl_walk_right,
                spr_pl_walk_up,
                spr_pl_walk_left,
                spr_pl_walk_down
            ],
            fps: 10
        },

        run: {
            spr: [
                spr_pl_run_right,
                spr_pl_run_up,
                spr_pl_run_left,
                spr_pl_run_down
            ],
            fps: 16
        },

        attack: {
            spr: [
                spr_pl_attack_right,
                spr_pl_attack_up,
                spr_pl_attack_left,
                spr_pl_attack_down
            ],
            fps: 0
        },

        hurt: {
            spr: [
                spr_pl_hurt_right,
                spr_pl_hurt_up,
                spr_pl_hurt_left,
                spr_pl_hurt_down
            ],
            fps: 0
        }
    };
}

// face:
// 0 = Right
// 1 = Up
// 2 = Left
// 3 = Down

global.pl_scale = 2;
