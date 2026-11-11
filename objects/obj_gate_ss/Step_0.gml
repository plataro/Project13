open = false;
with (obj_plate_ss) {
    if (channel == other.channel && pressed) other.open = true;
}

var _ty = open ? open_y : close_y;
var _dy = clamp(_ty - y, -move_spd, move_spd);

// ไม่ปิดทับผู้เล่นหรือลัง
if (_dy > 0 && (place_meeting(x, y + _dy, obj_player_ss) || place_meeting(x, y + _dy, obj_crate_ss))) _dy = 0;

y += _dy;