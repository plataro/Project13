// ★ ลูกไฟ (ฉาก side-scroll)
var _fl = 1 + 0.12 * sin(current_time / 40 + id);
var _dir = point_direction(0, 0, vx, vy);
gpu_set_blendmode(bm_add);
for (var _i = 5; _i >= 1; _i--) {
    draw_set_alpha(0.22 * (1 - _i / 6));
    draw_set_color(make_color_rgb(255, 110, 30));
    draw_circle(x - lengthdir_x(_i * 6, _dir), y - lengthdir_y(_i * 6, _dir), (9 - _i) * _fl, false);
}
draw_set_alpha(0.35);
draw_set_color(make_color_rgb(255, 120, 40));
draw_circle(x, y, 15 * _fl, false);
draw_set_alpha(0.9);
draw_set_color(make_color_rgb(255, 190, 80));
draw_circle(x, y, 8 * _fl, false);
draw_set_color(make_color_rgb(255, 250, 220));
draw_circle(x, y, 4, false);
draw_set_alpha(1);
gpu_set_blendmode(bm_normal);
draw_set_color(c_white);
