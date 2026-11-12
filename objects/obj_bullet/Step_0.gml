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
var _target = noone;
with (obj_enemy) {
    if (enemy_hit_by_circle(id, _vx, _vy, 8) && !array_contains(_me.hit_ids, id)) {
        _target = id;
        break;
    }
}
if (_target != noone) {
    var _hr = player_hit(damage);
    _target.take_damage(_hr[0], direction, _hr[1]);
    if (pierce > 0) {
        pierce--;
        array_push(hit_ids, _target);
    } else {
        instance_destroy();
    }
}