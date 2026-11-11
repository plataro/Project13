// หลอดเลือดบอส (แสดงเมื่อกำลังสู้ หรือเลือดไม่เต็ม)
if (alert_timer <= 0 && state == "chase" && hp >= max_hp) exit;

var _x = 280;
var _y = 30;
var _w = 400;

draw_set_color(c_black);
draw_rectangle(_x - 2, _y - 2, _x + _w + 2, _y + 18, false);
draw_set_color((invuln > 0) ? c_gray : c_purple);
draw_rectangle(_x, _y, _x + _w * (max(hp, 0) / max_hp), _y + 16, false);

// ขีดแบ่งเฟส
draw_set_color(c_white);
if (is_final) {
    draw_line(_x + _w / 3, _y, _x + _w / 3, _y + 16);
    draw_line(_x + _w * 2 / 3, _y, _x + _w * 2 / 3, _y + 16);
} else {
    draw_line(_x + _w / 2, _y, _x + _w / 2, _y + 16);
}
