var _x = round(x);
var _y = round(y);

draw_set_color(make_color_rgb(40, 30, 20));
draw_set_alpha(0.35);
draw_ellipse(_x - 26, _y - 6, _x + 26, _y + 6, false);
draw_set_alpha(1);

// ★ หีบพลัง: ออร่าม่วงกะพริบ
if (!opened && shot_up > 0) {
    gpu_set_blendmode(bm_add);
    draw_set_color(make_color_rgb(150, 70, 255));
    draw_set_alpha(0.25 + 0.15 * sin(current_time / 200));
    draw_circle(_x, _y - 22, 44, false);
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
}

if (!opened) {
    draw_set_color(make_color_rgb(150, 95, 40));
    draw_rectangle(_x - 24, _y - 34, _x + 24, _y - 2, false);
    draw_set_color(make_color_rgb(110, 65, 25));
    draw_rectangle(_x - 24, _y - 42, _x + 24, _y - 30, false);
    draw_set_color(c_yellow);
    draw_rectangle(_x - 4, _y - 30, _x + 4, _y - 20, false);
} else {
    draw_set_color(make_color_rgb(95, 60, 30));
    draw_rectangle(_x - 24, _y - 30, _x + 24, _y - 2, false);
    draw_set_color(make_color_rgb(60, 40, 20));
    draw_rectangle(_x - 24, _y - 52, _x + 24, _y - 44, false);
}

if (near) {
    draw_set_font(fnt_dialog);
    draw_set_halign(fa_center);
    draw_set_color(c_yellow);
    draw_text_transformed(_x, _y - 74, "[E] เปิดหีบ", 0.6, 0.6, 0);
    draw_set_halign(fa_left);
}
draw_set_color(c_white);
