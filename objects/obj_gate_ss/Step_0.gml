if (!inited) {
    inited = true;
    close_y = y;
    open_y = open_down ? y + sprite_height : y - sprite_height;
}
open = false;
with (obj_plate_ss) {
    if (channel == other.channel && pressed) other.open = true;
}
// ★ เปิดได้ด้วยเป้ายิง หรือคันโยก ช่องเดียวกันด้วย
with (obj_target) {
    if (channel == other.channel && hit) other.open = true;
}
with (obj_lever_ss) {
    if (channel == other.channel && on) other.open = true;
}

if (snd_open != -1 && open != snd_open) sfx_at("gate", x, y);
snd_open = open;

var _ty = open ? open_y : close_y;
var _dy = clamp(_ty - y, -move_spd, move_spd);

// ไม่ปิดทับผู้เล่นหรือลัง
if (_dy > 0 && (place_meeting(x, y + _dy, obj_player_ss) || place_meeting(x, y + _dy, obj_crate_ss))) _dy = 0;

y += _dy;