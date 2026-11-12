// Begin Step: ทำก่อนทุก object (เปิดเมนูแล้วผู้เล่นจะไม่ฟัน/กลิ้งตามคลิกนั้น)
input_update();   // ★ อ่านจอย/อุปกรณ์ล่าสุด ครั้งเดียวต่อเฟรม
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
var _click = mouse_check_button_pressed(mb_left);

// ---- ตรวจออกจากจอเต็ม / สลับหน้าต่าง (เฉพาะในเบราว์เซอร์) ----
var _lost = false;
if (os_browser != browser_not_a_browser) {
    var _bw = browser_width;
    var _bh = browser_height;
    if (last_bw > 0 && _bw * _bh < last_bw * last_bh * 0.85) _lost = true;   // จอเล็กลงมาก = ออกจากจอเต็ม
    last_bw = _bw;
    last_bh = _bh;

    var _focus = window_has_focus();
    if (had_focus && !_focus) _lost = true;
    had_focus = _focus;
}

// =========================
// ยังไม่ได้เปิดเมนู
// =========================
if (!open) {
    if (!can_pause()) exit;

    var _key = input_pressed("pause");
    // Esc: ไม่แย่งกับร้านค้า / ต้นไม้สกิล / คัตซีน ที่ใช้ Esc ปิดอยู่แล้ว
    if (keyboard_check_pressed(vk_escape)
        && !instance_exists(obj_shop) && !instance_exists(obj_skilltree) && !instance_exists(obj_cutscene)) _key = true;

    var _btn_show = !instance_exists(obj_dialogue) && !instance_exists(obj_shop) && !instance_exists(obj_skilltree);
    var _btn = _btn_show && _click && point_in_rectangle(_mx, _my, btn[0], btn[1], btn[2], btn[3]);

    if (_key || _btn || _lost) do_pause();
    exit;
}

// =========================
// เปิดเมนูอยู่
// =========================
var _items = get_items();
var _n = array_length(_items);

// ★ รอกดปุ่มใหม่ (หน้าตั้งค่าปุ่ม)
if (bind_wait != "") {
    if (bind_delay > 0) { bind_delay--; exit; }
    if (keyboard_check_pressed(vk_escape)) { bind_wait = ""; io_clear(); exit; }   // ยกเลิก (Esc ตั้งเป็นปุ่มไม่ได้)
    var _got = false;
    if (keyboard_check_pressed(vk_anykey) && keyboard_lastkey != vk_escape && keyboard_lastkey > 0) {
        global.bind_kb[$ bind_wait][0] = keyboard_lastkey;
        _got = true;
    }
    else if (mouse_check_button_pressed(mb_left))   { global.bind_kb[$ bind_wait][0] = -1; _got = true; }
    else if (mouse_check_button_pressed(mb_right))  { global.bind_kb[$ bind_wait][0] = -2; _got = true; }
    else if (mouse_check_button_pressed(mb_middle)) { global.bind_kb[$ bind_wait][0] = -3; _got = true; }
    else if (global.pad >= 0) {
        for (var _pb = gp_face1; _pb <= gp_padr; _pb++) {
            if (gamepad_button_check_pressed(global.pad, _pb)) {
                if (_pb == gp_start && bind_wait != "pause") break;   // Start สงวนไว้หยุดเกม
                global.bind_pad[$ bind_wait] = _pb;
                _got = true;
                break;
            }
        }
    }
    if (_got) { bind_wait = ""; input_save(); io_clear(); }
    exit;
}

// ปิด / ย้อนกลับ
if (keyboard_check_pressed(vk_escape) || input_pressed("pause") || input_pad_pressed(gp_face2)) {
    if (screen == 1) close_settings();
    else if (screen == 3) { input_save(); screen = 1; sel = 5; }
    else if (screen == 2) { screen = 0; sel = 2; }
    else if (!menu_mode) do_resume();
    exit;
}

// เลื่อนด้วยคีย์บอร์ด
if (input_ui_down()) sel = (sel + 1) mod _n;
if (input_ui_up()) sel = (sel - 1 + _n) mod _n;
if (screen == 1 && sel < 5) {
    if (input_ui_right()) change_setting(sel, 1);
    if (input_ui_left()) change_setting(sel, -1);
}

// เมาส์
var _moved = (_mx != last_mx || _my != last_my);
last_mx = _mx;
last_my = _my;
var _hit = -1;
for (var _i = 0; _i < _n; _i++) {
    var _y = row_y(_i);
    var _hx1 = (screen == 3) ? 200 : 320;
    var _hx2 = (screen == 3) ? 760 : 640;
    var _hh = (screen == 3) ? 22 : 32;
    if (_mx > _hx1 && _mx < _hx2 && _my > _y - 4 && _my < _y + _hh) {
        if (_moved) sel = _i;
        if (_click) _hit = _i;
    }
}
sel = clamp(sel, 0, _n - 1);

if (_hit >= 0) {
    sel = _hit;
    confirm(_hit);
} else if (input_ui_confirm()) {
    confirm(sel);
}
