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