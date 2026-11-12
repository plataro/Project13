if (open_delay > 0) open_delay--;
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
var _close_btn = point_in_rectangle(_mx, _my, close_x1, close_y1, close_x2, close_y2);

if (open_delay <= 0 && (input_pressed("status") || input_ui_back()
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
// ★ จอย / ลูกศร: เลือกเครื่องประดับในตาราง 2 คอลัมน์, A สวม/ถอด
var _owned = [];
for (var _oi = 0; _oi < array_length(_list); _oi++) if (acc_owned(_list[_oi])) array_push(_owned, _list[_oi]);
var _no = array_length(_owned);
var _nav = false;
if (input_ui_left())  { pad_i -= 1; _nav = true; }
if (input_ui_right()) { pad_i += 1; _nav = true; }
if (input_ui_up())    { pad_i -= 2; _nav = true; }
if (input_ui_down())  { pad_i += 2; _nav = true; }
if (_nav) pad_on = true;
if (global.input_dev == "kb" && (abs(_mx - pad_mx) + abs(_my - pad_my) > 4)) pad_on = false;
pad_mx = _mx;
pad_my = _my;
pad_i = clamp(pad_i, 0, max(0, _no - 1));
var _pad_toggle = false;
if (pad_on && _no > 0) {
    hover_acc = _owned[pad_i];
    if (open_delay <= 0 && (keyboard_check_pressed(vk_enter) || input_pad_pressed(gp_face1))) _pad_toggle = true;
}
if (open_delay <= 0 && hover_acc != "" && (mouse_check_button_pressed(mb_left) || _pad_toggle)) {
    acc_toggle(hover_acc);
    apply_difficulty();
    if (instance_exists(obj_player)) { obj_player.max_hp = global.max_hp; obj_player.hp = min(obj_player.hp, obj_player.max_hp); }
}
