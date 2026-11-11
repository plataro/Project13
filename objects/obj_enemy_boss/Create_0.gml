event_inherited();

is_final = (room == rm_boss);      // บอสสุดท้าย = 3 เฟส / มินิบอส = 2 เฟส
hp = is_final ? 200 : 40;          // มินิบอสตั้งเลือดใหม่ใน Creation Code ของห้อง
max_hp = hp;
move_speed = 1.5;
tint = c_ltgray;
sep_radius = 120;
sep_strength = 0.3;             // บอสถูกดันยาก แต่ดันตัวเล็กออกได้แรง
sight_range = is_final ? 3000 : 1000;   // บอสไล่เมื่อเห็นผู้เล่นในถิ่นตัวเอง

phase = 1;
phase_total = is_final ? 3 : 2;
state = "chase";      // chase, trans, burst_windup, burst, spiral_windup, spiral, recover
state_timer = 0;
attack_cd = 100;
last_attack = "";
invuln = 0;           // ตอนเปลี่ยนเฟสจะอมตะชั่วคราว
burst_wave = 0;
burst_a0 = 0;
spiral_a = 0;

// ---- อมตะช่วงเปลี่ยนเฟส ----
base_take_damage = take_damage;
take_damage = function(_dmg, _dir) {
    if (invuln > 0) return;
    base_take_damage(_dmg, _dir);
}

// ---- เรียกลูกน้อง (หาจุดที่ไม่ติดกำแพง) ----
summon = function(_obj, _n, _drop) {
    if (instance_number(obj_enemy) > 9) return;
    for (var _i = 0; _i < _n; _i++) {
        var _a = irandom(359);
        for (var _t = 0; _t < 12; _t++) {
            var _sx = x + lengthdir_x(150 + _t * 10, _a + _t * 30);
            var _sy = y + lengthdir_y(150 + _t * 10, _a + _t * 30);
            if (collision_rectangle(_sx - 32, _sy - 32, _sx + 32, _sy + 32, obj_wall, false, true) == noone) {
                var _m = instance_create_depth(_sx, _sy, depth, _obj);
                _m.master = id;
                _m.no_drop = !_drop;
                _m.alert_timer = 400;
                break;
            }
        }
    }
}

// ---- เข้าเฟสใหม่ ----
enter_phase = function(_n) {
    phase = _n;
    state = "trans";
    state_timer = 60;
    invuln = 60;
    telegraph = true;
    flash = 30;
    atk_state = "";
    atk_cur = undefined;
    with (obj_enemy_bullet) instance_destroy();
    with (obj_enemy_hitbox) instance_destroy();

    if (_n == 2) {
        move_speed = 2.2;
        if (is_final) summon(obj_enemy_shooter, 2, false);
        else summon(obj_enemy, 2, true);
    }
    if (_n == 3) {
        move_speed = 2.7;
        summon(obj_enemy_dasher, 2, false);
    }
    float_text(x, y - 200, is_final ? ("เฟส " + string(_n)) : "โกรธแล้ว!", c_red, 1.6);
}

ai = function() {
    if (invuln > 0) invuln--;

    // ตรวจเงื่อนไขเปลี่ยนเฟส
    if (is_final) {
        if (phase == 1 && hp <= max_hp * 2 / 3) enter_phase(2);
        else if (phase == 2 && hp <= max_hp / 3) enter_phase(3);
    } else if (phase == 1 && hp <= max_hp / 2) {
        enter_phase(2);
    }

    // ท่าที่มี hitbox (swing, slam, dash) กำลังทำงานอยู่
    if (run_attack()) exit;

    var _d = dist_to_player();

    switch (state) {
        case "trans":
            // ยืนนิ่ง ตัวสั่น อมตะ
            state_timer--;
            if (state_timer <= 0) {
                telegraph = false;
                state = "chase";
                attack_cd = 40;
            }
            break;

        case "chase":
            telegraph = false;

            strafe_timer--;
            if (strafe_timer <= 0) {
                strafe_sign *= -1;
                strafe_timer = irandom_range(60, 150);
            }
            if (_d > 110) {
                var _dir = dir_to_player() + 25 * strafe_sign * clamp((_d - 150) / 250, 0, 1);
                hsp = lengthdir_x(move_speed, _dir);
                vsp = lengthdir_y(move_speed, _dir);
            }

            if (attack_cd > 0) {
                attack_cd--;
            } else {
                // เลือกท่าตามระยะและเฟส ไม่ซ้ำท่าเดิมถ้ามีตัวเลือกอื่น
                var _opts = [];
                if (_d < 170) {
                    array_push(_opts, "swing");
                    if (phase >= 2) array_push(_opts, "slam");
                } else {
                    array_push(_opts, "dash");
                    if (phase >= 2) array_push(_opts, "burst");
                }
                if (phase >= 3) array_push(_opts, "spiral");

                var _pick = _opts[irandom(array_length(_opts) - 1)];
                if (_pick == last_attack && array_length(_opts) > 1) {
                    for (var _k = 0; _k < array_length(_opts); _k++) {
                        if (_opts[_k] != last_attack) {
                            _pick = _opts[_k];
                            break;
                        }
                    }
                }
                last_attack = _pick;

                switch (_pick) {
                    case "swing": begin_attack("boss_swing"); break;
                    case "slam":  begin_attack("boss_slam"); break;
                    case "dash":  begin_attack("boss_dash"); break;
                    case "burst":
                        state = "burst_windup";
                        state_timer = 30;
                        break;
                    case "spiral":
                        state = "spiral_windup";
                        state_timer = 40;
                        break;
                }
                attack_cd = (phase == 1) ? 90 : ((phase == 2) ? 50 : 35);
            }
            break;

        case "burst_windup":
            telegraph = true;
            state_timer--;
            if (state_timer <= 0) {
                telegraph = false;
                burst_a0 = irandom(359);
                burst_wave = 0;
                state = "burst";
                state_timer = 0;
            }
            break;

        case "burst":
            // วงกระสุน เหลื่อมกันครึ่งช่อง (เฟส 3 = 12 ทิศ 3 ชั้น)
            state_timer--;
            if (state_timer <= 0) {
                var _dirs = (phase >= 3) ? 12 : 8;
                var _waves = (phase >= 3) ? 3 : 2;
                var _step = 360 / _dirs;
                for (var _j = 0; _j < _dirs; _j++) {
                    var _b = instance_create_depth(x, y, depth, obj_enemy_bullet);
                    _b.direction = burst_a0 + burst_wave * (_step / 2) + _j * _step;
                    _b.image_angle = _b.direction;
                    _b.speed = (phase >= 3) ? 5.5 : 5;
                }
                burst_wave++;
                state_timer = 18;
                if (burst_wave >= _waves) {
                    state = "recover";
                    state_timer = 45;
                }
            }
            break;

        case "spiral_windup":
            telegraph = true;
            state_timer--;
            if (state_timer <= 0) {
                telegraph = false;
                spiral_a = irandom(359);
                state = "spiral";
                state_timer = 150;
            }
            break;

        case "spiral":
            // หมุนยิงกระสุน 2 ทางสวนกัน ยืนนิ่ง
            if (state_timer mod 5 == 0) {
                for (var _s = 0; _s < 2; _s++) {
                    var _sb = instance_create_depth(x, y, depth, obj_enemy_bullet);
                    _sb.direction = spiral_a + _s * 180;
                    _sb.image_angle = _sb.direction;
                    _sb.speed = 4.5;
                }
                spiral_a += 14;
            }
            state_timer--;
            if (state_timer <= 0) {
                state = "recover";
                state_timer = 50;
            }
            break;

        case "recover":
            state_timer--;
            if (state_timer <= 0) state = "chase";
            break;
    }
}
