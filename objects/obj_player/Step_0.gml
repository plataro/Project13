// มาจากประตูอีกฝั่ง: ไปเกิดหน้าประตูที่ชื่อตรงกัน (ทำครั้งเดียวในเฟรมแรก)
if (arrive_pending) {
    arrive_pending = false;
    with (obj_exit) {
        if (door_id == global.arrive) {
            other.x = x + spawn_dx;
            other.y = y + spawn_dy;
        }
    }
}


if (hp <= 0) {
    if (!instance_exists(obj_gameover)) instance_create_depth(0, 0, -9000, obj_gameover);
    hsp = 0;
    vsp = 0;
    mvx = 0;
    mvy = 0;
    exit;
}

// ★ จำปุ่มกลิ้งไว้ก่อนเช็ก hit-stop (เดิมกดตอนจอหยุดตอนโดนตี ปุ่มหายเลย = กดแล้วไม่กลิ้ง)
if (keyboard_check_pressed(vk_space)) roll_buffer = roll_buffer_time;

if (global.hitstop > 0) exit;   // hit-stop

if (instance_exists(obj_fade) || instance_exists(obj_dialogue) || instance_exists(obj_shop) || instance_exists(obj_skilltree)) {
    roll_buffer = 0;
    hsp = 0;
    vsp = 0;
    mvx = 0;
    mvy = 0;
    sliding = false;
    exit;
}

var _kx = (keyboard_check(ord("D")) || keyboard_check(vk_right))
        - (keyboard_check(ord("A")) || keyboard_check(vk_left));
var _ky = (keyboard_check(ord("S")) || keyboard_check(vk_down))
        - (keyboard_check(ord("W")) || keyboard_check(vk_up));
var _len = point_distance(0, 0, _kx, _ky);

aim = point_direction(x, y - aim_height, mouse_x, mouse_y);

// ตัวจับเวลา
if (roll_cd_timer > 0) roll_cd_timer--;
if (invuln_timer > 0) invuln_timer--;
if (dodge_timer > 0) dodge_timer--;
if (roll_buffer > 0) roll_buffer--;
if (attack_cd > 0) attack_cd--;
if (shot1_timer > 0) shot1_timer--;
if (skill2_timer > 0) skill2_timer--;
if (keyboard_check_pressed(ord("Q"))) player_use_potion();
if (keyboard_check_pressed(ord("T"))) skilltree_toggle();
if (keyboard_check_pressed(ord("R")) || mouse_wheel_down()) weapon_cycle(1);
if (mouse_wheel_up()) weapon_cycle(-1);

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
        var _running = keyboard_check(vk_shift) && _len > 0;
        var _spd = point_distance(0, 0, mvx, mvy);

        if (_len > 0) {
            dir_x = _kx / _len;
            dir_y = _ky / _len;

            var _tspeed = _running ? run_speed : move_speed;
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

        // กลิ้ง (ใช้ปุ่มที่จำไว้ กดล่วงหน้าได้)
        if (roll_buffer > 0 && roll_cd_timer <= 0) {
            start_roll(_kx, _ky, _len);
        }

        // โจมตี
        else if (mouse_check_button_pressed(mb_left) && attack_cd <= 0) {
            start_attack((combo_window > 0) ? min(combo + 1, weapon_combo_max()) : 1);
        }

        // สกิล 1
		else if (keyboard_check(ord("1")) && shot1_timer <= 0 && shot1_ammo > 0) {

			var _b = instance_create_depth(x, y, depth, obj_bullet);

			_b.direction = aim;
			_b.image_angle = aim;
			_b.speed = bullet_speed;
			_b.lift = aim_height;
			_b.pierce = bullet_pierce;
			_b.damage = shot1_dmg;   // ★ แรงตามระดับพลังยิง

			shot1_ammo--;
			shot1_timer = shot1_gap;

			if (shot1_ammo <= 0) {
				shot1_reload_timer = shot1_reload;
			}
		}

                // สกิล 2
		else if (keyboard_check(ord("2")) && skill2_timer <= 0 && skill2_unlocked) {

			for (var _i = 0; _i < skill2_count; _i++) {

				var _a = aim + (_i - (skill2_count - 1) / 2) * 15;
				var _b2 = instance_create_depth(x, y, depth, obj_bullet);

				_b2.direction = _a;
				_b2.image_angle = _a;
				_b2.speed = bullet_speed;
				_b2.lift = aim_height;
				_b2.pierce = bullet_pierce;
			}

			skill2_timer = skill2_cooldown;
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
        if (mouse_check_button_pressed(mb_left)) {
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

                    combo = 0;
                    combo_window = 0;
                    attack_cd = attack_end_lag;

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
// CAMERA + DYNAMIC ZOOM
// ==========================================

var _cam = view_camera[0];

// เก็บขนาดกล้องตั้งต้นเพียงครั้งเดียว
if (!variable_instance_exists(id, "camera_base_w")) {
    camera_base_w = camera_get_view_width(_cam);
    camera_base_h = camera_get_view_height(_cam);
    camera_zoom = 1;
}

// ตรวจจับความเร็ว
var _camera_spd = point_distance(0, 0, mvx, mvy);

// เป้าหมายการซูม
// 1.00 = ระยะปกติ
// 1.06 = ซูมออก 6%
var _zoom_target = 1.0;   // ซูมออกตอนวิ่งแค่เล็กน้อย (เดิม 1.06)

if (state == PState.MOVE && _camera_spd > move_speed + 0.5) {
    _zoom_target = 1.03;
}

// ค่อย ๆ เปลี่ยนระยะซูมให้นุ่ม: เข้าช้ากว่าออกเล็กน้อย + ทำให้ความเร็วซูมสมูท (ease)
var _zspd = (_zoom_target > camera_zoom) ? 0.035 : 0.05;
camera_zoom = lerp(camera_zoom, _zoom_target, _zspd);
if (abs(camera_zoom - _zoom_target) < 0.0005) camera_zoom = _zoom_target;

// คงสัดส่วนภาพ: คำนวณความกว้างแล้วหาความสูงจากสัดส่วนเดิม (กันขอบสั่นเพราะปัดเศษคนละทาง)
var _cw = round(camera_base_w * camera_zoom);
var _ch = round(_cw * camera_base_h / camera_base_w);

camera_set_view_size(_cam, _cw, _ch);

// ติดตามตำแหน่งผู้เล่นเหมือนเดิม
var _cam_x = floor(x - _cw / 2);
var _cam_y = floor(y - chest - _ch / 2);

// จำกัดขอบเขตห้อง
_cam_x = clamp(_cam_x, 0, max(0, room_width - _cw));
_cam_y = clamp(_cam_y, 0, max(0, room_height - _ch));

// กล้องสั่น (global.shake ลดลงเองใน obj_fx)
var _shk = global.shake;
camera_set_view_pos(_cam, _cam_x + round(random_range(-_shk, _shk)), _cam_y + round(random_range(-_shk, _shk)));

