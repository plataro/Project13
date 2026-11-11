event_inherited();

hp = 40;
max_hp = hp;
move_speed = 1.5;
tint = c_ltgray;
sep_radius = 120;
sep_strength = 0.3;
sight_range = (room == rm_boss) ? 3000 : 1000;   // บอสไล่เมื่อเห็นผู้เล่นในถิ่นตัวเอง   // บอสถูกดันยาก แต่ดันตัวเล็กออกได้แรง

phase = 1;
state = "chase";      // chase, burst_windup, burst, recover (ท่ายิงกระสุน)
state_timer = 0;
attack_cd = 100;
last_attack = "";
summoned = false;
burst_wave = 0;
burst_a0 = 0;

ai = function() {
    // เข้าเฟส 2 เมื่อเลือดเหลือครึ่งหนึ่ง
    if (phase == 1 && hp <= max_hp / 2) {
        phase = 2;
        move_speed = 2.2;
        flash = 20;
        if (!summoned) {
            summoned = true;
            for (var _i = -1; _i <= 1; _i += 2) {
                var _sx = x + _i * 110;
                if (collision_rectangle(_sx - 32, y - 32, _sx + 32, y + 32, obj_wall, false, true) == noone) {
                    var _m = instance_create_depth(_sx, y, depth, obj_enemy);
                    _m.master = id;
                }
            }
        }
    }

    // ท่าที่มี hitbox (swing, slam, dash) กำลังทำงานอยู่
    if (run_attack()) exit;

    var _d = dist_to_player();

    switch (state) {
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
                // เลือกท่าตามระยะ ไม่ซ้ำท่าเดิมถ้ามีตัวเลือกอื่น
                var _opts = [];
                if (_d < 170) {
                    array_push(_opts, "swing");
                    if (phase == 2) array_push(_opts, "slam");
                } else {
                    array_push(_opts, "dash");
                    if (phase == 2) array_push(_opts, "burst");
                }
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
                }
                attack_cd = (phase == 2) ? 50 : 90;
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
            // ยิงวง 2 ชั้น เหลื่อมกัน 22.5 องศา
            state_timer--;
            if (state_timer <= 0) {
                for (var _j = 0; _j < 8; _j++) {
                    var _b = instance_create_depth(x, y, depth, obj_enemy_bullet);
                    _b.direction = burst_a0 + burst_wave * 22.5 + _j * 45;
                    _b.image_angle = _b.direction;
                    _b.speed = 5;
                }
                burst_wave++;
                state_timer = 18;
                if (burst_wave >= 2) {
                    state = "recover";
                    state_timer = 45;
                }
            }
            break;

        case "recover":
            state_timer--;
            if (state_timer <= 0) state = "chase";
            break;
    }
}