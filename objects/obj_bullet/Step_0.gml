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
var _target = noone;
with (obj_enemy) {
    if (enemy_hit_by_circle(id, _vx, _vy, 8)) {
        _target = id;
        break;
    }
}
if (_target != noone) {
    _target.take_damage(damage, direction);
    instance_destroy();
}