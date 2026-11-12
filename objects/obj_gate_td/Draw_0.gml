// ประตูไม้ซี่กรงกั้นทาง (จมลงพื้นตอนเปิด)
var _k = opening ? (1 - open_t / 30) : 1;
var _x1 = bbox_left;
var _x2 = bbox_right + 1;
var _y2 = bbox_bottom + 1;
var _y1 = _y2 - (_y2 - bbox_top) * _k;
draw_set_alpha(0.35 * _k);
draw_set_color(c_black);
draw_rectangle(_x1 + 6, _y1 + 6, _x2 + 6, _y2 + 6, false);
draw_set_alpha(_k);
draw_set_color(make_color_rgb(95, 60, 30));
draw_rectangle(_x1, _y1, _x2, _y2, false);
draw_set_color(make_color_rgb(150, 100, 50));
var _bars = max(2, floor((_x2 - _x1) / 24));
for (var _i = 0; _i <= _bars; _i++) {
    var _bx = _x1 + (_x2 - _x1) * _i / _bars;
    draw_rectangle(_bx - 4, _y1, _bx + 4, _y2, false);
}
for (var _yy = _y1 + 40; _yy < _y2; _yy += 96) {
    draw_rectangle(_x1, _yy, _x2, _yy + 10, false);
}
// สัญลักษณ์เป้าบนประตู = บอกใบ้ว่าต้องยิงเป้า
var _cx = (_x1 + _x2) / 2;
var _cy = (_y1 + _y2) / 2;
draw_set_color(c_white);
draw_circle(_cx, _cy, 14 * _k, false);
draw_set_color(c_red);
draw_circle(_cx, _cy, 9 * _k, false);
draw_set_color(c_white);
draw_circle(_cx, _cy, 4 * _k, false);
draw_set_alpha(1);
