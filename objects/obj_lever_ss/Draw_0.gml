anim = lerp(anim, on ? 1 : 0, 0.25);
draw_set_color(make_color_rgb(80, 75, 70));
draw_rectangle(x - 18, y - 12, x + 18, y, false);
var _a = 120 - 60 * anim;   // เอียงซ้าย -> เอียงขวา
draw_set_color(make_color_rgb(140, 110, 70));
draw_line_width(x, y - 8, x + lengthdir_x(46, _a), y - 8 + lengthdir_y(46, _a), 5);
draw_set_color(on ? c_lime : c_red);
draw_circle(x + lengthdir_x(46, _a), y - 8 + lengthdir_y(46, _a), 7, false);
draw_set_color(c_white);
