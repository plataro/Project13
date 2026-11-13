ui_sound_watch(sel, 0);
alpha = min(alpha + 0.03, 0.8);
if (alpha < 0.8) exit;
pop = min(1, pop + 0.08);

// ★ เลือก: W/S หรือลูกศร / เมาส์ชี้
if (input_ui_up()) sel = 0;
if (input_ui_down()) sel = 1;
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
var _hover = -1;
for (var _i = 0; _i < 2; _i++) if (point_in_rectangle(_mx, _my, 360, btn_y(_i) - 18, 600, btn_y(_i) + 18)) _hover = _i;
if ((_mx != last_mx || _my != last_my) && _hover >= 0) sel = _hover;
last_mx = _mx;
last_my = _my;

var _go = input_ui_confirm() || (mouse_check_button_pressed(mb_left) && _hover >= 0);
if (_go && pop >= 1) {
    if (sel == 0) {
        save_restore_snapshot();              // คืนเหรียญ/ของ/ยา เท่าตอนเข้าห้อง
        global.player_hp = global.max_hp;
        global.music_room = -1;   // ★ เริ่มห้องใหม่ = เพลงกลับไปเพลงประจำห้อง (ไม่ค้างเพลงบอส)
        room_restart();
    } else if (!instance_exists(obj_fade)) {
        // กลับเมนู (เซฟล่าสุดคือตอนเข้าห้องนี้ กด "เล่นต่อ" ได้)
        var _f = instance_create_depth(0, 0, -10000, obj_fade);
        _f.target_room = rm_menu;
    }
}
