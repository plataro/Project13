if (hit_t > 0) hit_t--;
var _cy = y - 48;
// เสา + เงา
draw_set_alpha(0.3);
draw_set_color(c_black);
draw_ellipse(x - 18, y - 5, x + 18, y + 5, false);
draw_set_alpha(1);
draw_set_color(make_color_rgb(110, 75, 40));
draw_rectangle(x - 4, _cy, x + 4, y, false);
// แผ่นเป้า
var _s = 1 + hit_t / 40;
if (hit) {
    draw_set_color(make_color_rgb(90, 200, 90));
    draw_circle(x, _cy, 20 * _s, false);
    draw_set_color(c_white);
    draw_circle(x, _cy, 8, false);
} else {
    draw_set_color(c_white);
    draw_circle(x, _cy, 20, false);
    draw_set_color(c_red);
    draw_circle(x, _cy, 14, false);
    draw_set_color(c_white);
    draw_circle(x, _cy, 8, false);
    draw_set_color(c_red);
    draw_circle(x, _cy, 3, false);
}
draw_set_color(c_white);
