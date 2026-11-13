ui_sound_watch(hover_key, 0, "");   // ★ เสียงเลื่อนไปสกิลอื่น
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

// ★ จอย / ลูกศร: เลื่อนตามสาย (ซ้าย/ขวา) และขั้น (ขึ้น/ลง), A ปลด
var _nav = false;
if (input_ui_left())  { pad_b = max(0, pad_b - 1); _nav = true; }
if (input_ui_right()) { pad_b = min(3, pad_b + 1); _nav = true; }
if (input_ui_up())    { pad_t = max(0, pad_t - 1); _nav = true; }
if (input_ui_down())  { pad_t = min(5, pad_t + 1); _nav = true; }
if (_nav) pad_on = true;
if (global.input_dev == "kb" && (abs(_mx - pad_mx) + abs(_my - pad_my) > 4)) pad_on = false;   // ขยับเมาส์ = กลับไปใช้เมาส์
pad_mx = _mx;
pad_my = _my;
if (pad_on) {
    for (var _pi = 0; _pi < array_length(nodes); _pi++) if (nodes[_pi].branch == pad_b && nodes[_pi].tier == pad_t) hover_key = nodes[_pi].key;
    if (open_delay <= 0 && hover_key != "" && (keyboard_check_pressed(vk_enter) || input_pad_pressed(gp_face1))) {
        var _resp = skill_unlock(hover_key);
        msg = (_resp == "") ? L("ปลดสกิลแล้ว!", "Skill unlocked!") : _resp;
        msg_timer = 120;
    }
}

if (open_delay <= 0 && mouse_check_button_pressed(mb_left) && hover_key != "") {
    var _res = skill_unlock(hover_key);
    msg = (_res == "") ? L("ปลดสกิลแล้ว!", "Skill unlocked!") : _res;
    msg_timer = 120;
}