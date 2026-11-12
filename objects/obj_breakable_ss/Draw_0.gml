if (flash > 0) flash--;
var _x1 = bbox_left;
var _y1 = bbox_top;
var _x2 = bbox_right;
var _y2 = bbox_bottom;
draw_set_color((flash > 0) ? c_white : make_color_rgb(120, 80, 45));
draw_rectangle(_x1, _y1, _x2, _y2, false);
draw_set_color(make_color_rgb(165, 115, 65));
for (var _yy = _y1 + 4; _yy < _y2; _yy += 22) draw_rectangle(_x1 + 2, _yy, _x2 - 2, _yy + 14, false);
// ไม้ไขว้ + รอยแตกตามความเสียหาย
draw_set_color(make_color_rgb(90, 60, 35));
draw_line_width(_x1, _y1, _x2, _y2, 4);
draw_line_width(_x2, _y1, _x1, _y2, 4);
if (hp <= 2) { draw_set_color(c_black); draw_line_width(_x1 + 8, _y1 + 10, _x1 + 30, _y1 + 40, 2); }
if (hp <= 1) { draw_set_color(c_black); draw_line_width(_x2 - 6, _y2 - 20, _x2 - 30, _y2 - 60, 2); }
draw_set_color(c_white);
