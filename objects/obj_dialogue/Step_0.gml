// เลื่อนเข้า/จางเข้าของรูปตัวละคร
var _sides = ["left", "right"];
for (var _i = 0; _i < 2; _i++) {
    var _s = slots[$ _sides[_i]];
    _s.ax = lerp(_s.ax, 0, 0.2);
    _s.alpha = lerp(_s.alpha, (_s.who != "") ? 1 : 0, 0.2);
}

// อ่านต่อ: Enter / E / Space / คลิกซ้าย
var _next = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(ord("E"))
         || keyboard_check_pressed(vk_space) || mouse_check_button_pressed(mb_left)
         || input_pad_pressed(gp_face1) || input_pad_pressed(gp_face2);   // ★ จอย A / B
var _has_ch = variable_struct_exists(lines[index], "choices");

if (chars < total) {
    var _c0 = floor(chars);
    chars += type_speed;
    if (_next) chars = total;
    else if (floor(chars) div 3 != _c0 div 3) sfx("blip", 0.5, 0.06, 0);   // ★ เสียงติ๊กทุก 3 ตัวอักษร
} else if (_has_ch) {
    // ★ ตัวเลือก: คลิกเมาส์เท่านั้น (ไม่รับคีย์บอร์ด) และกดได้หลังตัวเลือกขึ้นครบ choice_delay เฟรม
    var _ch = lines[index].choices;
    var _cnt = array_length(_ch);
    choice_t++;

    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    var _click = false;
    sel = -1;
    for (var _k = 0; _k < _cnt; _k++) {
        if (point_in_rectangle(_mx, _my, choice_x1, choice_y0 + _k * choice_gap, choice_x2, choice_y0 + _k * choice_gap + choice_h)) {
            sel = _k;
            if (choice_t >= choice_delay && mouse_check_button_pressed(mb_left)) _click = true;
        }
    }
    // ★ จอย: ต้องกดลูกศร/สติ๊กเลือกก่อน แล้วค่อยกด A (กันกดข้ามไดอาล็อกแล้วเผลอเลือก)
    if (input_stick_edge("up") || input_pad_pressed(gp_padu)) pad_sel = (pad_sel <= 0) ? _cnt - 1 : pad_sel - 1;
    if (input_stick_edge("down") || input_pad_pressed(gp_padd)) pad_sel = (pad_sel < 0 || pad_sel >= _cnt - 1) ? 0 : pad_sel + 1;
    if (global.input_dev == "pad" && pad_sel >= 0) {
        sel = pad_sel;
        if (choice_t >= choice_delay && input_pad_pressed(gp_face1)) _click = true;
    }
    if (_click && sel >= 0) {
        global.choice = _ch[sel].v;
        index++;
        if (index >= array_length(lines)) finish();
        else load_line();
    }
} else if (_next) {
    index++;
    if (index >= array_length(lines)) finish();
    else load_line();
}
