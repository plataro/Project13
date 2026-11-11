// เลื่อนเข้า/จางเข้าของรูปตัวละคร
var _sides = ["left", "right"];
for (var _i = 0; _i < 2; _i++) {
    var _s = slots[$ _sides[_i]];
    _s.ax = lerp(_s.ax, 0, 0.2);
    _s.alpha = lerp(_s.alpha, (_s.who != "") ? 1 : 0, 0.2);
}

var _next = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(ord("E"));
var _has_ch = variable_struct_exists(lines[index], "choices");

if (chars < total) {
    chars += type_speed;
    if (_next) chars = total;
} else if (_has_ch) {
    // ตัวเลือก: W/S หรือ ลูกศร หรือเมาส์ แล้วกด Enter/E/คลิก
    var _ch = lines[index].choices;
    var _cnt = array_length(_ch);
    if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))) sel = (sel - 1 + _cnt) mod _cnt;
    if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) sel = (sel + 1) mod _cnt;
    if (keyboard_check_pressed(ord("1"))) { sel = 0; _next = true; }
    if (keyboard_check_pressed(ord("2")) && _cnt > 1) { sel = 1; _next = true; }

    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    var _click = false;
    for (var _k = 0; _k < _cnt; _k++) {
        if (point_in_rectangle(_mx, _my, 220, 150 + _k * 70, 740, 150 + _k * 70 + 56)) {
            sel = _k;
            if (mouse_check_button_pressed(mb_left)) _click = true;
        }
    }
    if (_next || _click) {
        global.choice = _ch[sel].v;
        sel = 0;
        index++;
        if (index >= array_length(lines)) {
            closing = true;
            if (is_callable(on_done)) on_done();
            instance_destroy();
        } else load_line();
    }
} else if (_next) {
    index++;
    if (index >= array_length(lines)) {
        closing = true;
        if (is_callable(on_done)) on_done();
        instance_destroy();
    } else load_line();
}
