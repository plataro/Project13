t++;
var _s = (1 - cos(2 * pi * t / period)) / 2;   // 0 -> 1 -> 0 แบบนุ่ม
var _nx = xstart + range_x * _s;
var _ny = ystart + range_y * _s;
var _dx = _nx - x;
var _dy = _ny - y;

// จดว่าใครยืนอยู่บนแท่นก่อนขยับ
var _me = id;
with (obj_player_ss) carry_by = place_meeting(x, y + 1, _me) ? _me : noone;
with (obj_crate_ss)  carry_by = place_meeting(x, y + 1, _me) ? _me : noone;

// ขึ้น: พาคนไปก่อนแล้วแท่นตาม / ลงหรือแนวนอน: แท่นไปก่อนแล้วพาคนตาม
if (_dy < 0) {
    carry_riders(_dx, _dy);
    x = _nx;
    y = _ny;
} else {
    x = _nx;
    y = _ny;
    carry_riders(_dx, _dy);
}