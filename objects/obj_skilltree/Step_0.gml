if (open_delay > 0) open_delay--;
if (msg_timer > 0) {
    msg_timer--;
    if (msg_timer <= 0) msg = "";
}

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
var _on_close = point_in_rectangle(_mx, _my, close_x1, close_y1, close_x2, close_y2);

if (open_delay <= 0 && (input_pressed("tree") || input_ui_back()
    || (mouse_check_button_pressed(mb_left) && _on_close))) {
    global.tree_closed_at = current_time;   // กัน obj_player เปิดซ้ำในเฟรมเดียวกัน
    instance_destroy();
    exit;
}

hover_key = "";
for (var _i = 0; _i < array_length(nodes); _i++) {
    var _r = node_rect(nodes[_i]);
    if (point_in_rectangle(_mx, _my, _r[0], _r[1], _r[2], _r[3])) hover_key = nodes[_i].key;
}

if (open_delay <= 0 && mouse_check_button_pressed(mb_left) && hover_key != "") {
    var _res = skill_unlock(hover_key);
    msg = (_res == "") ? L("ปลดสกิลแล้ว!", "Skill unlocked!") : _res;
    msg_timer = 120;
}