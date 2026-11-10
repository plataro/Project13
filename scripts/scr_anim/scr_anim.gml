
// ตาราง Animation ของผู้เล่น
// Idle แยก Sprite ตามทิศทาง
// Animation อื่นใช้ Sprite Sheet 4 ทิศทาง

function anim_config() {
    return {
        idle: {
            spr: [
                spr_pl_idle_right,
                spr_pl_idle_up,
                spr_pl_idle_left,
                spr_pl_idle_down
            ],
            n: 12,
            fps: 8
        },

        walk: {
            spr: spr_pl_walk,
            n: 6,
            fps: 10
        },

        run: {
            spr: spr_pl_walk,
            n: 6,
            fps: 16
        },

        roll: {
            spr: spr_pl_roll,
            n: 8,
            fps: 0
        },

        hurt: {
            spr: spr_pl_hurt,
            n: 5,
            fps: 0
        },

        attack: {
            spr: spr_pl_attack,
            n: 8,
            fps: 0
        }
    };
}

// face:
// 0 = Right
// 1 = Up
// 2 = Left
// 3 = Down

// ลำดับแถวใน Sprite Sheet:
// Row 0 = Down
// Row 1 = Left
// Row 2 = Right
// Row 3 = Up

global.face_row = [2, 3, 1, 0];

// ขนาดตัวละคร
global.pl_scale = 2;
