x += vx;
y += vy;
life--;
if (life <= 0 || place_meeting(x, y, global.ss_solids) || !point_in_rectangle(x, y, 0, 0, room_width, room_height)) {
    fx_spark(x, y, direction + 180, 4, c_white);
    instance_destroy();
    exit;
}
var _hit = false;
var _bx = x;
var _by = y;
with (obj_target) {
    if (!hit && point_distance(_bx, _by, x, y - 48) < 24) {
        if (mode == "sword") fx_spark(x, y - 48, 90, 4, c_white);   // ★ คริสตัล: กระสุนเด้ง
        else on_hit();
        _hit = true;
    }
}
if (_hit) instance_destroy();
