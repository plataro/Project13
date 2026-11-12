if (global.hitstop > 0) exit;   // hit-stop
if (place_meeting(x, y, obj_wall)) {
    instance_destroy();
    exit;
}
if (!point_in_rectangle(x, y, 0, 0, room_width, room_height)) {
    instance_destroy();
    exit;
}

// โดนศัตรู: เช็กที่ตำแหน่งที่เห็นบนจอ (ยกขึ้นตามความสูงอก)
var _vx = x;
var _vy = y - lift;
var _me = id;

// ★ เป้ายิง (พัซเซิล): โดนแล้วกระสุนหายไป
var _tg_hit = false;
with (obj_target) {
    if (!hit && point_distance(_vx, _vy, x, y - 48) < 20 + 6 * _me.size) {
        if (mode == "sword") {   // ★ คริสตัล: กระสุนเด้ง ต้องฟัน
            if (tink_id != _me) { tink_id = _me; float_text(x, y - 90, L("ยิงไม่เข้า ต้องฟัน!", "Shots bounce off, use your blade!"), make_color_rgb(150, 220, 255), 0.9); }
            fx_spark(x, y - 48, 90, 4, c_white);
        } else {
            on_hit();
            // ★ ยิงโดนเป้าปริศนา = ลูกไฟพร้อมยิงต่อทันที
            with (obj_player) { shot1_reload_timer = 0; shot1_ammo = shot1_max; shot1_timer = 0; }
        }
        _tg_hit = true;
    }
}
if (_tg_hit) {
    instance_destroy();
    exit;
}

var _target = noone;
with (obj_enemy) {
    if (enemy_hit_by_circle(id, _vx, _vy, 8 * _me.size) && !array_contains(_me.hit_ids, id)) {
        _target = id;
        break;
    }
}
if (_target != noone) {
    var _hr = player_hit(damage);
    _target.take_damage(_hr[0], direction, _hr[1], "bullet");
    player_on_hit(_target);
    // ★ ไฟบรรลัย (สกิล a6): ระเบิดโดนศัตรูรอบ ๆ ครึ่งดาเมจ
    if (skill_has("a6")) {
        var _ex = _target.x;
        var _ey = _target.y;
        var _er = 70 + 20 * size;
        var _edmg = max(1, damage * 0.5);
        var _dir0 = direction;
        with (obj_enemy) {
            if (id != _target && hp > 0 && point_distance(x, y, _ex, _ey) < _er && !wall_between(_ex, _ey, x, y)) {
                var _hr2 = player_hit(_edmg);
                take_damage(_hr2[0], point_direction(_ex, _ey, x, y), _hr2[1], "bullet");
            }
        }
        fx_spark(_ex, _ey - 40, _dir0, 18, make_color_rgb(255, 150, 50), 180);
        fx_shake(2);
    }
    if (pierce > 0) {
        pierce--;
        array_push(hit_ids, _target);
    } else {
        instance_destroy();
    }
}