// Begin Step: ทำก่อนทุก object (เปิดเมนูแล้วผู้เล่นจะไม่ฟัน/กลิ้งตามคลิกนั้น)
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

    var _key = keyboard_check_pressed(ord("P"));
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

// ปิด / ย้อนกลับ
if (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(ord("P"))) {
    if (screen == 1) close_settings();
    else if (screen == 2) { screen = 0; sel = 2; }
    else if (!menu_mode) do_resume();
    exit;
}

// เลื่อนด้วยคีย์บอร์ด
if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) sel = (sel + 1) mod _n;
if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))) sel = (sel - 1 + _n) mod _n;
if (screen == 1 && sel < 4) {
    if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) change_setting(sel, 1);
    if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) change_setting(sel, -1);
}

// เมาส์
var _moved = (_mx != last_mx || _my != last_my);
last_mx = _mx;
last_my = _my;
var _hit = -1;
for (var _i = 0; _i < _n; _i++) {
    var _y = row_y(_i);
    if (_mx > 320 && _mx < 640 && _my > _y - 6 && _my < _y + 32) {
        if (_moved) sel = _i;
        if (_click) _hit = _i;
    }
}
sel = clamp(sel, 0, _n - 1);

if (_hit >= 0) {
    sel = _hit;
    confirm(_hit);
} else if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
    confirm(sel);
}
