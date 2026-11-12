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
    if (pierce > 0) {
        pierce--;
        array_push(hit_ids, _target);
    } else {
        instance_destroy();
    }
}