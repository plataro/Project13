if (!show_hitbox || is_undefined(atk)) exit;

draw_set_alpha(0.5);
draw_set_color(c_red);
for (var _i = 0; _i < array_length(atk.circles); _i++) {
    var _c = atk.circles[_i];
    var _cx = x + lengthdir_x(_c[0], image_angle) + lengthdir_x(_c[1], image_angle + 90);
    var _cy = y + lengthdir_y(_c[0], image_angle) + lengthdir_y(_c[1], image_angle + 90) - lift;
    draw_circle(round(_cx), round(_cy), _c[2], false);
}
draw_set_alpha(1);
draw_set_color(c_white);