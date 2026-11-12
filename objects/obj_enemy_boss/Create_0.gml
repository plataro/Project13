event_inherited();

is_final = (room == rm_boss);      // บอสสุดท้าย = 3 เฟส / มินิบอส = 2 เฟส
hp = is_final ? 200 : 40;          // มินิบอสตั้งเลือดใหม่ใน Creation Code ของห้อง
max_hp = hp;
move_speed = 1.5;
tint = c_ltgray;
sep_radius = 120;
sep_strength = 0.3;
engage_range = 220;             // บอสถูกดันยาก แต่ดันตัวเล็กออกได้แรง
sight_range = is_final ? 3000 : 1000;   // บอสไล่เมื่อเห็นผู้เล่นในถิ่นตัวเอง

phase = 1;
phase_total = is_final ? 3 : 2;
state = "chase";      // chase, trans, burst_windup, burst, spiral_windup, spiral, leap_windup, leap_air, volley_windup, volley, recover
state_timer = 0;
attack_cd = 100;
last_attack = "";
invuln = 0;           // ตอนเปลี่ยนเฟสจะอมตะชั่วคราว
burst_wave = 0;
burst_a0 = 0;
spiral_a = 0;

// ---- ★ กันผู้เล่นยืนยิงตอดจากไกล ----
far_range = 300;      // ไกลกว่านี้ = นับว่ายิงตอด
far_timer = 0;        // เกจยิงตอด เต็มแล้วบอสกระโดดตกใส่
leap_sx = x;
leap_sy = y;
leap_tx = x;
leap_ty = y;
leap_t = 0;
airborne = false;     // ลอยกลางอากาศ = ไม่โดนดาเมจ
volley_n = 0;

// ---- ★ เกราะกันกระสุน: โดนยิงเยอะ หรือสุ่มตั้งเอง กระสุนไม่เข้า ต้องฟันด้วยดาบให้แตก ----
bullet_heat = 0;      // นับกระสุนที่โดนช่วงนี้ (ค่อย ๆ ลดลงเอง)
shield_cd = 240;      // ห้ามตั้งเกราะซ้ำจนกว่าจะหมดเวลานี้
shield_time = 330;    // ★ เกราะอยู่ได้นานสุด (เฟรม)

raise_shield = function() {
    if (shield > 0) return;
    shield = shield_time;
    shield_hp = 3 + phase;   // ★ ฟันกี่ทีแตก (เฟส 1 = 4, 2 = 5, 3 = 6)
    bullet_heat = 0;
    float_text(x, y - 200, "เกราะ!", make_color_rgb(110, 190, 255), 1.3);
    fx_spark(x, y - 70, 0, 18, make_color_rgb(110, 190, 255), 180);
}

end_shield = function(_broken) {
    shield = 0;
    shield_cd = (phase >= 3) ? 420 : 600;
    if (_broken) {
        float_text(x, y - 200, "เกราะแตก!", c_yellow, 1.4);
        fx_shake(6);
        fx_spark(x, y - 70, 0, 30, make_color_rgb(110, 190, 255), 180);
        // เสียหลัก = ช่วงรางวัลให้รุมฟัน (ถ้าไม่ได้ออกท่า/กระโดดอยู่)
        if (atk_state == "" && (state == "chase" || state == "recover")) {
            state = "recover";
            state_timer = 55;
            telegraph = false;
        }
    }
}

// ---- อมตะช่วงเปลี่ยนเฟส ----
base_take_damage = take_damage;
take_damage = function(_dmg, _dir, _crit = false, _src = "melee") {
    if (invuln > 0 || airborne) return;

    if (_src == "bullet") {
        // ★ เกราะอยู่ = กระสุนเด้งออก ไม่เสียเลือด
        if (shield > 0) {
            fx_spark(x, y - 70, _dir + 180, 6, make_color_rgb(110, 190, 255));
            if (dist_to_player() > far_range) far_timer += 25;
            return;
        }
        // โดนยิงเยอะเกิน = ตั้งเกราะ
        bullet_heat++;
        var _limit = (phase == 1) ? 9 : ((phase == 2) ? 8 : 7);   // ★ โดนกี่นัดถึงตั้งเกราะ
        if (bullet_heat >= _limit && shield_cd <= 0 && state != "trans") raise_shield();
    } else if (shield > 0) {
        // ฟันด้วยดาบ = เข้าเลือดปกติ และกะเทาะเกราะ
        shield_hp--;
        if (shield_hp <= 0) end_shield(true);
    }

    // โดนยิงจากไกล = เกจยิงตอดขึ้นเร็ว และไม่มีช่วงรอจังหวะแรก (ผู้เล่นเลือกตีจากไกลเอง)
    if (dist_to_player() > far_range) {
        far_timer += 25;
        engage_grace = 0;
    }
    base_take_damage(_dmg, _dir, _crit, _src);
}

// ---- ★ ท่ากระโดดตกใส่ (ไล่ระยะผู้เล่นที่หนีไปยิงจากไกล) ----
start_leap = function() {
    if (!instance_exists(obj_player)) return;
    state = "leap_windup";
    state_timer = (phase >= 3) ? 24 : 30;
    telegraph = true;
    far_timer = 0;
    last_attack = "leap";
    leap_tx = obj_player.x;
    leap_ty = obj_player.y;
    marker = [leap_tx, leap_ty, 115, false];
}

leap_land = function() {
    z = 0;
    airborne = false;
    marker = undefined;
    var _h = instance_create_depth(x, y, depth, obj_enemy_hitbox);
    _h.owner = id;
    _h.atk = enemy_attack_data("boss_leap");
    _h.lift = _h.atk.lift;
    fx_shake(8);
    fx_spark(x, y - 20, 0, 24, c_ltgray, 180);
    // เฟส 2 ขึ้นไป: ลงแล้วมีวงกระสุนกระจาย
    if (phase >= 2) {
        var _n = (phase >= 3) ? 12 : 8;
        var _a0 = irandom(359);
        for (var _j = 0; _j < _n; _j++) {
            var _b = instance_create_depth(x, y, depth, obj_enemy_bullet);
            _b.direction = _a0 + _j * (360 / _n);
            _b.image_angle = _b.direction;
            _b.speed = 4.5;
        }
    }
    state = "recover";
    state_timer = 30;
    attack_cd = 20;   // ลงแล้วถ้าผู้เล่นอยู่ใกล้ ฟาดต่อได้ไว
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
    z = 0;
    airborne = false;
    marker = undefined;
    far_timer = 0;
    shield = 0;
    shield_cd = 120;
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

    // เกราะ / เกจกระสุน
    if (shield > 0) {
        shield--;
        if (shield <= 0) end_shield(false);
    } else if (shield_cd > 0) {
        shield_cd--;
    }
    bullet_heat = max(0, bullet_heat - 1 / 45);   // ★ ลด 1 นัดทุก ~0.75 วิ

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

            // ★ เกจยิงตอด: ผู้เล่นอยู่ไกลสะสมขึ้น เข้ามาใกล้ลดลง เต็มแล้วกระโดดใส่ทันที (ไม่สนคูลดาวน์)
            if (_d > far_range) far_timer++;
            else far_timer = max(0, far_timer - 2);
            var _far_limit = (phase == 1) ? 150 : ((phase == 2) ? 110 : 80);
            if (far_timer >= _far_limit) {
                start_leap();
                break;
            }

            if (attack_cd > 0) {
                attack_cd--;
            } else if (can_attack() || _d > far_range) {
                // เลือกท่าตามระยะและเฟส ไม่ซ้ำท่าเดิมถ้ามีตัวเลือกอื่น
                var _opts = [];
                if (_d < 170) {
                    array_push(_opts, "swing");
                    if (phase >= 2) array_push(_opts, "slam");
                } else {
                    array_push(_opts, "dash");
                    array_push(_opts, "volley");   // ★ ยิงกระสุนเล็งใส่ผู้เล่น (ทุกเฟส)
                    if (phase >= 2) array_push(_opts, "burst");
                    if (_d > far_range) array_push(_opts, "leap");
                }
                if (phase >= 3) array_push(_opts, "spiral");
                // ★ สุ่มตั้งเกราะเองบ้าง (ผู้เล่นใช้แต่ดาบก็เจอได้)
                if (shield <= 0 && shield_cd <= 0 && irandom(3) == 0) array_push(_opts, "guard");

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
                    case "leap":  start_leap(); break;
                    case "guard":
                        raise_shield();
                        break;
                    case "volley":
                        state = "volley_windup";
                        state_timer = 24;
                        break;
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
                if (_pick == "guard") attack_cd = 25;   // ตั้งเกราะแล้วเดินหน้าบุกต่อเลย
            }
            break;

        // ---- ★ กระโดด: ตามจุดผู้เล่นจนเหลือ 10 เฟรมแล้วล็อก ----
        case "leap_windup":
            state_timer--;
            if (state_timer > 10 && instance_exists(obj_player)) {
                leap_tx = obj_player.x;
                leap_ty = obj_player.y;
            } else {
                marker[3] = true;
            }
            marker[0] = leap_tx;
            marker[1] = leap_ty;
            if (state_timer <= 0) {
                telegraph = false;
                // จุดตกอยู่ในกำแพง = หาที่ว่างใกล้ ๆ
                if (place_meeting(leap_tx, leap_ty, obj_wall)) {
                    var _found = false;
                    for (var _lr = 16; _lr <= 96 && !_found; _lr += 16) {
                        for (var _aa = 0; _aa < 360 && !_found; _aa += 45) {
                            if (!place_meeting(leap_tx + lengthdir_x(_lr, _aa), leap_ty + lengthdir_y(_lr, _aa), obj_wall)) {
                                leap_tx += lengthdir_x(_lr, _aa);
                                leap_ty += lengthdir_y(_lr, _aa);
                                _found = true;
                            }
                        }
                    }
                    marker[0] = leap_tx;
                    marker[1] = leap_ty;
                }
                state = "leap_air";
                leap_sx = x;
                leap_sy = y;
                leap_t = 0;
                airborne = true;
            }
            break;

        case "leap_air":
            leap_t++;
            var _air = (phase >= 3) ? 28 : 34;
            var _lk = min(1, leap_t / _air);
            x = lerp(leap_sx, leap_tx, _lk);
            y = lerp(leap_sy, leap_ty, _lk);
            z = sin(_lk * pi) * 170;
            hsp = 0;
            vsp = 0;
            kb_x = 0;
            kb_y = 0;
            if (_lk >= 1) leap_land();
            break;

        // ---- ★ ยิงเล็ง: 3 ชุด ชุดละ 3 ลูก (เฟส 3 = 5 ลูก) ไม่เล็งดักตอนกลิ้ง ----
        case "volley_windup":
            telegraph = true;
            state_timer--;
            if (state_timer <= 0) {
                telegraph = false;
                volley_n = 0;
                state = "volley";
                state_timer = 0;
            }
            break;

        case "volley":
            state_timer--;
            if (state_timer <= 0 && instance_exists(obj_player)) {
                var _vn = (phase >= 3) ? 5 : 3;
                var _va = point_direction(x, y, obj_player.x, obj_player.y);
                for (var _v = 0; _v < _vn; _v++) {
                    var _vb = instance_create_depth(x, y, depth, obj_enemy_bullet);
                    _vb.direction = _va + (_v - (_vn - 1) / 2) * 14;
                    _vb.image_angle = _vb.direction;
                    _vb.speed = 6.5;
                }
                volley_n++;
                state_timer = 16;
                if (volley_n >= 3) {
                    state = "recover";
                    state_timer = 40;
                }
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

// มินิบอสที่เคยปราบแล้วจะไม่เกิดใหม่ (ฟาร์มศัตรูทั่วไปได้ แต่บอสไม่กลับมาขวางทาง)
if (room != rm_boss && flag_get("boss_" + room_get_name(room))) {
    no_drop = true;
    instance_destroy();
}
