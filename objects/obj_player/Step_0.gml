// มาจากประตูอีกฝั่ง: ไปเกิดหน้าประตูที่ชื่อตรงกัน (ทำครั้งเดียวในเฟรมแรก)
if (arrive_pending) {
    arrive_pending = false;
    // ★ ออกจากร้าน = เกิดหน้าร้านนั้น
    if (global.arrive == "shop" && variable_global_exists("shop_visit") && is_struct(global.shop_visit)) {
        x = global.shop_visit.rx;
        y = global.shop_visit.ry;
    }
    with (obj_exit) {
        if (door_id == global.arrive) {
            other.x = x + spawn_dx;
            other.y = y + spawn_dy;
        }
    }
}


// ★ กล้องตามตัวทุกเฟรม แม้เฟรมที่ออกจาก Step ก่อน (จอหยุด / บทสนทนา / เฟด)
update_camera(false);

if (hp <= 0) {
    if (!instance_exists(obj_gameover)) instance_create_depth(0, 0, -9000, obj_gameover);
    hsp = 0;
    vsp = 0;
    mvx = 0;
    mvy = 0;
    exit;
}

// ★ จำปุ่มกลิ้งไว้ก่อนเช็ก hit-stop (เดิมกดตอนจอหยุดตอนโดนตี ปุ่มหายเลย = กดแล้วไม่กลิ้ง)
if (input_pressed("roll")) roll_buffer = roll_buffer_time;

if (global.hitstop > 0) exit;   // hit-stop

if (instance_exists(obj_fade) || instance_exists(obj_dialogue) || instance_exists(obj_shop) || instance_exists(obj_skilltree) || instance_exists(obj_status)) {
    roll_buffer = 0;
    hsp = 0;
    vsp = 0;
    mvx = 0;
    mvy = 0;
    sliding = false;
    exit;
}

var _kx = input_move_x();   // ★ คีย์บอร์ด / สติ๊กซ้าย
var _ky = input_move_y();
var _len = point_distance(0, 0, _kx, _ky);

aim = input_aim(x, y - aim_height, point_direction(0, 0, dir_x, dir_y));   // ★ เมาส์ / สติ๊กขวา (+ช่วยเล็ง)

// ตัวจับเวลา
if (roll_cd_timer > 0) roll_cd_timer--;
if (invuln_timer > 0) invuln_timer--;
if (dodge_timer > 0) dodge_timer--;
if (roll_buffer > 0) roll_buffer--;
if (attack_cd > 0) attack_cd--;
if (shot1_timer > 0) shot1_timer--;
if (skill2_timer > 0) skill2_timer--;
if (skill3_timer > 0) skill3_timer--;   // ★ ดาบพายุหมุน
if (skill4_timer > 0) skill4_timer--;   // ★ สายฟ้า
if (ult_fx > 0) {
    ult_fx--;
    if (ult_fx == 42) { fx_hitstop(6); fx_spark(x, y - 30, 0, 40, make_color_rgb(255, 230, 150), 180); }   // ★ จังหวะระเบิด
}
for (var _bi2 = array_length(bolts) - 1; _bi2 >= 0; _bi2--) {
    bolts[_bi2].life--;
    if (bolts[_bi2].life <= 0) array_delete(bolts, _bi2, 1);
}
if (input_pressed("potion")) player_use_potion();
if (input_pressed("status")) status_toggle();   // ★ หน้าสถานะ

// ★ บัฟ: F ใช้ไอเท็มที่เลือก / V เปลี่ยน
var _bl = buff_list();
if (input_pressed("buff_next")) global.buff_sel = (global.buff_sel + 1) mod array_length(_bl);
if (input_pressed("buff_use")) {
    if (buff_use(_bl[global.buff_sel]) == "") float_text(x, y - 120, L("ไม่มี ", "No ") + buff_data(_bl[global.buff_sel]).name, c_gray, 0.8);
}
// เวลาบัฟ
var _bchg = false;
for (var _bi = array_length(global.buffs) - 1; _bi >= 0; _bi--) {
    global.buffs[_bi].t--;
    if (global.buffs[_bi].t <= 0) { array_delete(global.buffs, _bi, 1); _bchg = true; }
}
if (_bchg) player_apply_skills();

// ★ สถานะผิดปกติ
if (st_poison > 0) st_poison--;
if (st_burn > 0) {
    if (state == PState.ROLL) {
        st_burn = 0;
        float_text(x, y - 110, L("ดับไฟ!", "Fire out!"), c_aqua, 0.8);
    } else {
        st_burn--;
        if (st_burn mod 10 == 0) fx_spark(x, y - 40, 90, 2, c_orange, 60);
        if (st_burn <= 0) {
            invuln_timer = 0;
            take_damage(1, x, y + 1);
        }
    }
}
if (st_stun > 0) {
    st_stun--;
    mvx *= 0.8;
    mvy *= 0.8;
    move_and_collide(mvx + kb_x, mvy + kb_y, obj_wall);
    kb_x *= 0.8;
    kb_y *= 0.8;
    update_camera(true);
    exit;
}
if (input_pressed("tree")) skilltree_toggle();
if (input_pressed("weapon")) weapon_cycle(1);
if (mouse_wheel_up()) weapon_cycle(-1);

// ★ ยิงโดนเป้าปริศนา = รีโหลดทันที (ดูใน obj_bullet)
if (shot1_reload_timer > 0) {
    shot1_reload_timer--;
    if (shot1_reload_timer <= 0) shot1_ammo = shot1_max;
}

switch (state) {

    // ==========================================
    // MOVE
    // ==========================================
    case PState.MOVE:

        // เดินอยู่ = หันตามทิศทางเดิน
        if (_len > 0) {
            if (abs(_kx) > abs(_ky)) {
                face = (_kx > 0) ? 0 : 2;
            } else {
                face = (_ky < 0) ? 1 : 3;
            }
        }
        // หยุดสนิทแล้ว = หันตามเมาส์
        else if (point_distance(0, 0, mvx, mvy) <= 0.3) {
            face = round(aim / 90) mod 4;
        }

        // หมดหน้าต่างต่อคอมโบ = รีเซ็ต
        if (combo_window > 0) {
            combo_window--;
            if (combo_window <= 0) combo = 0;
        }

        // เดิน / วิ่ง พร้อมแรงเฉื่อย
        var _running = input_check("run") && _len > 0;
        var _spd = point_distance(0, 0, mvx, mvy);

        if (_len > 0) {
            dir_x = _kx / _len;
            dir_y = _ky / _len;

            var _tspeed = _running ? run_speed : move_speed;
            if (st_poison > 0) _tspeed *= 0.7;   // ★ ติดพิษ = ช้าลง
            var _step = _running
                ? run_accel
                : ((_spd > move_speed + 0.2) ? slide_friction : walk_accel);

            // หักเลี้ยวเกิน 60 องศาตอนมีแรงเฉื่อย
            if (_spd > 1 && abs(angle_difference(
                point_direction(0, 0, mvx, mvy),
                point_direction(0, 0, dir_x, dir_y)
            )) > 60) {
                _step *= turn_boost;
            }

            steer(dir_x * _tspeed, dir_y * _tspeed, _step);

        } else {
            steer(0, 0, sliding ? slide_friction : walk_friction);
        }

        if (_running) sliding = true;
        if (point_distance(0, 0, mvx, mvy) < 0.3) sliding = false;

        hsp = mvx;
        vsp = mvy;

        // ★ ฝุ่นตอนวิ่ง (วิ่งเร็ว = ถี่ขึ้น)
        _spd = point_distance(0, 0, mvx, mvy);
        if (_spd > 1.2) {
            dust_t--;
            if (dust_t <= 0) {
                dust_t = _running ? 4 : 9;
                fx_dust(x - sign(mvx) * 6, y - 2, _running ? 2 : 1, make_color_rgb(200, 190, 170), -mvx * 0.15);
            }
        } else dust_t = 0;

        // กลิ้ง (ใช้ปุ่มที่จำไว้ กดล่วงหน้าได้)
        if (roll_buffer > 0 && roll_cd_timer <= 0) {
            start_roll(_kx, _ky, _len);
        }

        // ★ ค้อน: กดค้างอยู่ (ยังไม่ตัดสินว่าทุบธรรมดาหรือชาร์จ)
        else if (charge_hold > 0) {
            if (global.save.weapon != "hammer") {
                charge_hold = 0;
            } else if (input_check("attack")) {
                charge_hold++;
                if (charge_hold >= charge_hold_need) {
                    charge_hold = 0;
                    charge_t = 0;
                    state = PState.CHARGE;
                }
            } else {
                charge_hold = 0;
                start_attack(1);   // ปล่อยเร็ว = ทุบธรรมดา
            }
        }

        // โจมตี
        else if (input_pressed("attack") && attack_cd <= 0) {
            if (global.save.weapon == "hammer" && combo_window <= 0) charge_hold = 1;   // รอดูว่าจะกดค้างไหม
            else start_attack((combo_window > 0) ? min(combo + 1, weapon_combo_max()) : 1);
        }

        // สกิล 1
		else if (input_check("shoot1") && shot1_timer <= 0 && shot1_ammo > 0) {

			var _b = instance_create_depth(x, y, depth, obj_bullet);

			_b.direction = aim;
			_b.image_angle = aim;
			_b.speed = bullet_speed;
			_b.lift = aim_height;
			_b.pierce = bullet_pierce;
			_b.damage = shot1_dmg;   // ★ แรงตามระดับพลังยิง
			_b.size = shot1_size;    // ★ ใหญ่ขึ้นตามหีบพลัง

			shot1_ammo--;
			shot1_timer = shot1_gap;

			if (shot1_ammo <= 0) {
				shot1_reload_timer = shot1_reload;
			}
		}

                // สกิล 2
		else if (input_check("shoot2") && skill2_timer <= 0 && skill2_unlocked) {

			for (var _i = 0; _i < skill2_count; _i++) {

				var _a = aim + (_i - (skill2_count - 1) / 2) * 15;
				var _b2 = instance_create_depth(x, y, depth, obj_bullet);

				_b2.direction = _a;
				_b2.image_angle = _a;
				_b2.speed = bullet_speed;
				_b2.lift = aim_height;
				_b2.pierce = bullet_pierce;
				_b2.size = 0.75 * shot1_size;   // ★ ใหญ่ขึ้นตามระดับลูกไฟ
			}

			skill2_timer = skill2_cooldown;
		}

		// ★ ท่าไม้ตาย (เกจเต็ม)
		else if (input_pressed("ult") && ult_unlocked && global.ult_charge >= 100) {
			cast_ult();
		}

		// ★ สกิล 3: ดาบพายุหมุน
		else if (input_pressed("skill3") && skill3_unlocked && skill3_timer <= 0) {
			start_whirl();
		}

		// ★ สกิล 4: สายฟ้าลูกโซ่
		else if (input_pressed("skill4") && skill4_unlocked && skill4_timer <= 0) {
			cast_bolt();
		}

		// กดสกิลที่ยังไม่ปลด / ยังไม่พร้อม = บอกเบา ๆ
		else if (input_pressed("ult") && ult_unlocked) {
			float_text(x, y - 110, L("เกจไม้ตายยังไม่เต็ม", "Ultimate not ready"), c_gray, 0.7);
		}

        break;


    // ==========================================
    // ROLL
    // ==========================================
    case PState.ROLL:

        hsp = dir_x * roll_speed;
        vsp = dir_y * roll_speed;

        roll_timer--;

        if (roll_timer <= 0) {

            state = PState.MOVE;
            roll_cd_timer = roll_cooldown;

            // ไถลต่อนิดหน่อยหลังกลิ้งจบ
            mvx = dir_x * roll_speed * 0.5;
            mvy = dir_y * roll_speed * 0.5;

            sliding = true;
        }

        break;


    // ==========================================
    // CHARGE (ค้อน): เดินช้ามาก ปล่อยตอนเต็ม = ทุ่มรอบตัว
    // ==========================================
    case PState.CHARGE:

        face = round(aim / 90) mod 4;

        var _ctx = 0;
        var _cty = 0;
        if (_len > 0) {
            _ctx = (_kx / _len) * move_speed * 0.25;
            _cty = (_ky / _len) * move_speed * 0.25;
        }
        steer(_ctx, _cty, walk_friction);
        hsp = mvx;
        vsp = mvy;

        var _was_full = (charge_t >= charge_time);
        charge_t = min(charge_t + 1, charge_time);
        if (!_was_full && charge_t >= charge_time) {
            fx_shake(1.5);
            fx_spark(x, y - 60, 90, 12, c_yellow, 160);
        }

        // กลิ้ง = ยกเลิกชาร์จ
        if (roll_buffer > 0 && roll_cd_timer <= 0) {
            start_roll(_kx, _ky, _len);
            break;
        }
        // เปลี่ยนอาวุธระหว่างชาร์จ = ยกเลิก
        if (global.save.weapon != "hammer") {
            state = PState.MOVE;
            charge_t = 0;
            break;
        }

        if (!input_check("attack")) {
            if (charge_t >= charge_time) {
                start_attack(9);                 // ทุ่มชาร์จเต็ม
            } else {
                start_attack(1);                 // ชาร์จไม่เต็ม = ทุบธรรมดา
            }
            charge_t = 0;
        }
        break;

    // ==========================================
    // ATTACK
    // ==========================================
    case PState.ATTACK:

        // ขณะโจมตี = หันตามเมาส์
        face = round(aim / 90) mod 4;

        // ตอนฟัน เดินช้า ๆ แต่แรงเฉื่อยยังพาไปต่อ
        var _atx = 0;
        var _aty = 0;

        if (_len > 0) {
            _atx = (_kx / _len) * move_speed * attack_move_mult;
            _aty = (_ky / _len) * move_speed * attack_move_mult;
        }

        steer(_atx, _aty, slide_friction);

        // พุ่งตามท่า
        var _lx = 0;
        var _ly = 0;

        if (lunge_timer > 0) {
            _lx = lengthdir_x(lunge_speed, lunge_dir);
            _ly = lengthdir_y(lunge_speed, lunge_dir);
            lunge_timer--;
        }

        hsp = mvx + _lx;
        vsp = mvy + _ly;

        // กลิ้งตัดจังหวะ (คอมโบรีเซ็ต)
        if (roll_buffer > 0 && roll_cd_timer <= 0) {
            start_roll(_kx, _ky, _len);
            break;
        }

        // คลิกระหว่างฟันอยู่ = จองท่าถัดไป
        if (input_pressed("attack")) {
            combo_buffer = true;
        }

        attack_timer--;

        if (attack_timer <= 0) {

            if (combo_buffer && combo < weapon_combo_max()) {

                start_attack(combo + 1);

            } else {

                state = PState.MOVE;
                combo_buffer = false;

                if (combo >= weapon_combo_max()) {

                    attack_cd = (combo == 9) ? charge_end_lag : attack_end_lag;   // ทุ่มชาร์จ = พักนานกว่า
                    combo = 0;
                    combo_window = 0;

                } else {

                    combo_window = combo_window_time;
                }
            }
        }

        break;
}

// ==========================================
// COLLISION
// ==========================================

move_and_collide(hsp + kb_x, vsp + kb_y, obj_wall);
fog_eye = fog_eye_calc(id);

// ชนกำแพงแล้วแรงเฉื่อยในทิศนั้นหาย
if (mvx != 0 && place_meeting(x + sign(mvx), y, obj_wall)) {
    mvx = 0;
}

if (mvy != 0 && place_meeting(x, y + sign(mvy), obj_wall)) {
    mvy = 0;
}

kb_x *= 0.8;
kb_y *= 0.8;

if (abs(kb_x) < 0.1) kb_x = 0;
if (abs(kb_y) < 0.1) kb_y = 0;

// ==========================================
// ROLL AFTERIMAGE
// ==========================================

// เพิ่มอายุให้เงาทุกดวง
for (var i = 0; i < 4; i++) {
    roll_echo_age[i]++;
}

// เก็บตำแหน่งเฉพาะตอน Roll
if (state == PState.ROLL) {

    roll_echo_timer--;

    if (roll_echo_timer <= 0) {

        // เลื่อนเงาเก่าออกไป
        for (var i = 3; i > 0; i--) {
            roll_echo_x[i] = roll_echo_x[i - 1];
            roll_echo_y[i] = roll_echo_y[i - 1];
            roll_echo_frame[i] = roll_echo_frame[i - 1];
            roll_echo_age[i] = roll_echo_age[i - 1];
        }

        // บันทึกตำแหน่งล่าสุด
        roll_echo_x[0] = x;
        roll_echo_y[0] = y;

        roll_echo_frame[0] = floor(
            ((roll_time - roll_timer) / roll_time) * 8
        ) mod 8;

        roll_echo_age[0] = 0;

        // สร้างเงาทุก 3 เฟรม
        roll_echo_timer = 3;
    }
}

depth = -y;


// ==========================================
// CAMERA (ฟังก์ชันอยู่ใน Create: update_camera)
// ==========================================
update_camera(true);
