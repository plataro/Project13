if (!inited) {
    inited = true;
    top_x = x + dir * run;
    top_y = y - rise;
}
var _n = max(4, round(rise / 16));
var _sw = run / _n;
var _sh = rise / _n;
// คานข้าง
draw_set_color(make_color_rgb(70, 62, 58));
draw_line_width(x, y + 6, top_x, top_y + 6, 8);
// ขั้นบันได
for (var _i = 0; _i < _n; _i++) {
    var _x1 = x + dir * _sw * _i;
    var _y1 = y - _sh * (_i + 1);
    var _x2 = _x1 + dir * _sw;
    draw_set_color(make_color_rgb(110, 100, 92));
    draw_rectangle(min(_x1, _x2), _y1, max(_x1, _x2), _y1 + _sh, false);
    draw_set_color(make_color_rgb(150, 140, 128));
    draw_rectangle(min(_x1, _x2), _y1, max(_x1, _x2), _y1 + 3, false);
}
// ลูกศรบอกตรงปลายบันไดเมื่อผู้เล่นอยู่ใกล้
var _p = instance_find(obj_player_ss, 0);
if (_p != noone && _p.on_stairs == noone) {
    var _near = (abs(_p.x - x) < 28 && abs(_p.y - y) < 12);   // ★ ป้ายเฉพาะปลายล่าง (ปลายบนเดินลงเองอยู่แล้ว)
    if (_near) {
        draw_set_font(fnt_dialog);
        draw_set_halign(fa_center);
        draw_set_color(c_yellow);
        draw_text_transformed(_p.x, _p.y - 110, "[W] ขึ้น/ลงบันได", 0.55, 0.55, 0);
        draw_set_halign(fa_left);
    }
}
draw_set_color(c_white);
