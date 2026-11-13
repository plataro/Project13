// ==========================================
// ★ แอนิเมชันศัตรู Chaser (ก็อบลิน)
// ==========================================
// ลำดับทิศใน array เหมือนผู้เล่น: 0 = ขวา, 1 = บน, 2 = ซ้าย, 3 = ล่าง
// หมายเหตุ: สไปรต์เดินชื่อ walk_down_left / walk_down_right / walk_down_up
//           จริง ๆ คือเดินซ้าย / ขวา / ขึ้น (ถ้าเปลี่ยนชื่อใน GameMaker แก้ตรงนี้ด้วย)

function chaser_sprites() {
    static _s = {
        idle: [
            spr_enemy_chaser_idle_right,
            spr_enemy_chaser_idle_up,
            spr_enemy_chaser_idle_left,
            spr_enemy_chaser_idle_down
        ],
        walk: [
            spr_enemy_chaser_walk_down_right,
            spr_enemy_chaser_walk_down_up,
            spr_enemy_chaser_walk_down_left,
            spr_enemy_chaser_walk_down
        ],
        attack: [
            spr_enemy_chaser_attack_right,
            spr_enemy_chaser_attack_up,
            spr_enemy_chaser_attack_left,
            spr_enemy_chaser_attack_down
        ],
        hurt: [
            spr_enemy_chaser_hurt_right,
            spr_enemy_chaser_hurt_up,
            spr_enemy_chaser_hurt_left,
            spr_enemy_chaser_hurt_down
        ],
        death: [
            spr_enemy_chaser_death_right,
            spr_enemy_chaser_death_up,
            spr_enemy_chaser_death_left,
            spr_enemy_chaser_death_down
        ]
    };
    return _s;
}

// ความเร็วเล่น (เฟรมต่อวินาที) ปรับได้
#macro CHASER_IDLE_FPS 6
#macro CHASER_WALK_FPS 10

// เรียกใน Draw ของ obj_enemy: เลือก sprite_index / image_index ให้ Chaser
function chaser_anim() {
    if (!is_chaser || variable_instance_exists(id, "is_orb")) return;

    var _S = chaser_sprites();
    var _run = (global.hitstop <= 0);   // hit-stop = ค้างเฟรม

    // ระยะที่ขยับจริงในเฟรมนี้ (หยุดตอนบทสนทนา/เมนู = ยืนเฉย ๆ)
    var _mx = x - xprevious;
    var _my = y - yprevious;
    var _spd = point_distance(0, 0, _mx, _my);

    // ---- หันหน้า ----
    // ออกท่า = หันตามทิศฟัน / ไล่ผู้เล่นอยู่ = หันหาผู้เล่น / เดินกลับบ้าน = หันตามทางเดิน
    var _want = -1;
    if (atk_state != "") _want = atk_dir;
    else if (alert_timer > 0 && instance_exists(obj_player)) _want = dir_to_player();
    else if (_spd > 0.3) _want = point_direction(0, 0, _mx, _my);

    // หน่วงไว้นิดนึง (เกิน 52° จากทิศเดิมถึงเปลี่ยน) จะได้ไม่สลับซ้าย/ล่างกระพริบตอนอยู่แนวทแยง
    if (_want >= 0 && abs(angle_difference(_want, face * 90)) > 52) {
        face = ((round(_want / 90) mod 4) + 4) mod 4;
    }

    // ---- เลือกท่า ----
    var _name = "idle";
    if (atk_state != "") _name = "attack";
    else if (hurt_t > 0) _name = "hurt";
    else if (_spd > 0.4) _name = "walk";

    if (_name != anim_name) {
        anim_name = _name;
        anim_t = 0;
    }

    var _spr = _S[$ _name][face];
    var _n = sprite_get_number(_spr);
    var _f = 0;

    switch (_name) {
        case "attack":
            // แบ่งเฟรมตามช่วงท่า: ง้าง 25% แรก / ฟัน 50% กลาง / เก็บท่า 25% ท้าย
            // (สไปรต์ 8 เฟรม = ง้าง 0-1, ฟัน 2-5, เก็บ 6-7)
            var _a = floor(_n * 0.25);
            var _b = _n - _a;
            var _k = 0;
            switch (atk_state) {
                case "windup":
                    _k = 1 - atk_timer / max(1, atk_cur.windup);
                    _f = floor(_k * _a);
                    break;
                case "active":
                    _k = 1 - atk_timer / max(1, atk_cur.active);
                    _f = _a + floor(_k * (_b - _a));
                    break;
                default:   // recover
                    _k = 1 - atk_timer / max(1, atk_cur.recover);
                    _f = _b + floor(_k * (_n - _b));
                    break;
            }
            break;

        case "hurt":
            _f = floor((1 - hurt_t / hurt_time) * _n);
            break;

        case "walk":
            // เดินเร็ว = ก้าวถี่ขึ้น
            if (_run) anim_t += CHASER_WALK_FPS * clamp(_spd / 2, 0.6, 1.6) / 60;
            _f = floor(anim_t) mod _n;
            break;

        default:   // idle
            if (_run) anim_t += CHASER_IDLE_FPS / 60;
            _f = floor(anim_t) mod _n;
            break;
    }

    if (_run && hurt_t > 0) hurt_t--;

    sprite_index = _spr;
    image_index = clamp(_f, 0, _n - 1);
}
