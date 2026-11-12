if (global.hitstop > 0) exit;   // hit-stop
age++;

// ตามตัวเจ้าของ ให้ท่าพุ่งฟันไปพร้อมตัวละคร
if (instance_exists(owner)) {
    x = owner.x;
    y = owner.y;
}

if (is_undefined(step_data)) {
    instance_destroy();
    exit;
}

// ★ ค้อนกระแทกพื้น: กล้องสั่นตอนทุบลง (โดนหรือไม่โดนก็สั่น)
if (age == step_data.active_from && variable_struct_exists(step_data, "shake")) {
    fx_shake(step_data.shake);
    if (step_data.shake >= 8) fx_spark(x, y - 10, 0, 30, make_color_rgb(230, 190, 130), 180);
}

if (age >= step_data.active_from && age <= step_data.active_to) {
    var _me = id;
    var _ang = image_angle;
    var _lift = lift;
    var _d = step_data;
    var _px = x;
    var _py = y;

    // ★ ฟันเป้ายิง = ไม่ได้ผล บอกใบ้ให้ใช้ปุ่มยิง
    with (obj_target) {
        if (!hit && tink_id != _me) {
            for (var _ti = 0; _ti < array_length(_d.circles); _ti++) {
                var _tc = _d.circles[_ti];
                var _tx = _px + lengthdir_x(_tc[0], _ang) + lengthdir_x(_tc[1], _ang + 90);
                var _ty = _py + lengthdir_y(_tc[0], _ang) + lengthdir_y(_tc[1], _ang + 90) - _lift;
                if (point_distance(_tx, _ty, x, y - 48) < _tc[2] + 18) {
                    tink_id = _me;
                    if (mode == "sword") { on_hit(); break; }   // ★ คริสตัล: ฟันได้
                    float_text(x, y - 90, L("ฟันไม่ได้ ต้องยิง! [", "Can't cut it, shoot it! [") + input_label("shoot1") + "]", c_orange, 0.9);
                    fx_spark(x, y - 48, _ang + 180, 4, c_white);
                    break;
                }
            }
        }
    }

    with (obj_enemy) {
        // ★ ศัตรูที่อยู่หลังกำแพงไม่โดน
        if (last_hit_id != _me && !wall_between(_px, _py, x, y)) {
            for (var _i = 0; _i < array_length(_d.circles); _i++) {
                var _c = _d.circles[_i];
                var _gx = _px + lengthdir_x(_c[0], _ang) + lengthdir_x(_c[1], _ang + 90);
                var _gy = _py + lengthdir_y(_c[0], _ang) + lengthdir_y(_c[1], _ang + 90);

                // ★ วงกลมที่ยื่นไปหลังกำแพงไม่นับ
                if (!wall_between(_px, _py, _gx, _gy) && enemy_hit_by_circle(id, _gx, _gy - _lift, _c[2])) {
                    var _kd = _d.radial ? point_direction(_px, _py, x, y) : _ang;
                    last_hit_id = _me;
                    var _hr = player_hit(_d.dmg);
                    take_damage(_hr[0], _kd, _hr[1]);
                    player_on_hit(id);   // ★ ติดสถานะตามเครื่องประดับ/บัฟ
                    var _m = max(1, sqrt(mass));   // ตัวหนัก (บอส) กระเด็นน้อยกว่า
                    kb_x = lengthdir_x(_d.kb / _m, _kd);
                    kb_y = lengthdir_y(_d.kb / _m, _kd);
                    break;
                }
            }
        }
    }
}

if (age > step_data.active_to) instance_destroy();