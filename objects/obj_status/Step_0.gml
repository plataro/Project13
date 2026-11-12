if (open_delay > 0) open_delay--;
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
var _close_btn = point_in_rectangle(_mx, _my, close_x1, close_y1, close_x2, close_y2);

if (open_delay <= 0 && (keyboard_check_pressed(ord("I")) || keyboard_check_pressed(vk_escape)
    || (mouse_check_button_pressed(mb_left) && _close_btn))) {
    global.status_closed_at = current_time;
    io_clear();
    instance_destroy();
    exit;
}

// รายการเครื่องประดับที่มี (คลิก = สวม/ถอด)
hover_acc = "";
var _list = acc_list();
var _row = 0;
for (var _i = 0; _i < array_length(_list); _i++) {
    if (!acc_owned(_list[_i])) continue;
    var _rr = acc_rect(_row);
    if (point_in_rectangle(_mx, _my, _rr[0], _rr[1], _rr[2], _rr[3])) hover_acc = _list[_i];
    _row++;
}
if (open_delay <= 0 && hover_acc != "" && mouse_check_button_pressed(mb_left)) {
    acc_toggle(hover_acc);
    apply_difficulty();
    if (instance_exists(obj_player)) { obj_player.max_hp = global.max_hp; obj_player.hp = min(obj_player.hp, obj_player.max_hp); }
}
