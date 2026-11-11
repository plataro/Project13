// แสดงเฉพาะโหมด debug
if (!global.debug || !show_hitbox || is_undefined(atk)) exit;

draw_set_alpha(0.5);
draw_set_color(c_red);
if (variable_struct_exists(atk, "rects")) {
    for (var _k = 0; _k < array_length(atk.rects); _k++) {
        var _r = atk.rects[_k];
        draw_oriented_rect(x, y - lift, image_angle, _r[0], _r[1], _r[2], _r[3]);
    }
}
for (var _i = 0; _i < array_length(atk.circles); _i++) {
    var _c = atk.circles[_i];
    var _cx = x + lengthdir_x(_c[0], image_angle) + lengthdir_x(_c[1], image_angle + 90);
    var _cy = y + lengthdir_y(_c[0], image_angle) + lengthdir_y(_c[1], image_angle + 90) - lift;
    draw_circle(round(_cx), round(_cy), _c[2], false);
}
draw_set_alpha(1);
draw_set_color(c_white);