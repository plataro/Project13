// แสดงเฉพาะโหมด debug
if (!global.debug || !show_hitbox || is_undefined(step_data)) exit;

var _active = (age >= step_data.active_from && age <= step_data.active_to);
draw_set_alpha(_active ? 0.45 : 0.1);
draw_set_color(_active ? c_white : c_aqua);
for (var _i = 0; _i < array_length(step_data.circles); _i++) {
    var _c = step_data.circles[_i];
    var _cx = x + lengthdir_x(_c[0], image_angle) + lengthdir_x(_c[1], image_angle + 90);
    var _cy = y + lengthdir_y(_c[0], image_angle) + lengthdir_y(_c[1], image_angle + 90) - lift;
    draw_circle(round(_cx), round(_cy), _c[2], false);
}
draw_set_alpha(1);
draw_set_color(c_white);