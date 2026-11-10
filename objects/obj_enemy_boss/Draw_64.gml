var _x = 280;
var _y = 30;
var _w = 400;

draw_set_color(c_black);
draw_rectangle(_x - 2, _y - 2, _x + _w + 2, _y + 18, false);
draw_set_color(c_purple);
draw_rectangle(_x, _y, _x + _w * (max(hp, 0) / max_hp), _y + 16, false);
draw_set_color(c_white);