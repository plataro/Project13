// ===== หยุดเกม + ตั้งค่า (persistent สร้างครั้งเดียวจาก obj_menu / obj_player) =====
// เปิดด้วย P / Esc / ปุ่ม II มุมซ้ายล่าง
// ใน itch.io ตอนจอเต็ม Esc ถูกเบราว์เซอร์ใช้ออกจากจอเต็มเสมอ (เกมห้ามไม่ได้)
// เลยทำให้ "ออกจากจอเต็ม" หรือ "สลับไปหน้าต่างอื่น" = หยุดเกมอัตโนมัติแทน
open = false;
menu_mode = false;     // เปิดจากหน้าเมนูหลัก (เฉพาะหน้าตั้งค่า ไม่ต้องหยุดเกม)
screen = 0;            // 0 = เมนูหยุด, 1 = ตั้งค่า, 2 = ยืนยันกลับหน้าหลัก
sel = 0;
snap = -1;             // ภาพนิ่งของเกมตอนกดหยุด
last_mx = -1;
last_my = -1;

last_bw = browser_width;
last_bh = browser_height;
had_focus = true;

btn = [8, 500, 40, 532];   // ★ ปุ่มหยุด (พิกัด GUI)

settings_load();
if (!instance_exists(obj_tutorial)) instance_create_depth(0, 0, -13900, obj_tutorial);   // สอนเล่นตามสถานการณ์ (persistent)

// หยุดได้ตอนนี้ไหม
can_pause = function() {
    if (room == rm_menu) return false;
    if (!instance_exists(obj_player) && !instance_exists(obj_player_ss)) return false;
    if (instance_exists(obj_fade) || instance_exists(obj_gameover) || instance_exists(obj_ending)) return false;
    return true;
}

do_pause = function() {
    open = true;
    menu_mode = false;
    screen = 0;
    sel = 0;
    if (surface_exists(application_surface)) {
        snap = sprite_create_from_surface(application_surface, 0, 0,
            surface_get_width(application_surface), surface_get_height(application_surface),
            false, false, 0, 0);
    }
    instance_deactivate_all(true);
    instance_activate_object(obj_scaler);   // ปรับขนาดจอยังต้องทำงาน
    io_clear();
}

free_snap = function() {
    if (snap != -1 && sprite_exists(snap)) sprite_delete(snap);
    snap = -1;
}

do_resume = function() {
    instance_activate_all();
    free_snap();
    open = false;
    io_clear();   // กันคลิก/ปุ่มที่ใช้ปิดเมนู ไปโดนฟันหรือกลิ้งต่อ
}

go_title = function() {
    instance_activate_all();
    free_snap();
    open = false;
    global.hitstop = 0;
    io_clear();
    var _f = instance_create_depth(0, 0, -10000, obj_fade);
    _f.target_room = rm_menu;
}

// เปิดหน้าตั้งค่าจากเมนูหลัก
open_settings_menu = function() {
    open = true;
    menu_mode = true;
    screen = 1;
    sel = 0;
    io_clear();
}

close_settings = function() {
    settings_save();
    if (menu_mode) {
        open = false;
        menu_mode = false;
        io_clear();
    } else {
        screen = 0;
        sel = 1;
    }
}

// รายการบนหน้าจอปัจจุบัน
get_items = function() {
    switch (screen) {
        case 1:
            var _on = L("เปิด", "On");
            var _off = L("ปิด", "Off");
            return [
                L("ภาษา:  ไทย", "Language:  English"),
                L("เสียงรวม:  ", "Master volume:  ") + string(global.set_volume) + "%",
                L("เพลง:  ", "Music:  ") + string(global.set_music) + "%",
                L("เสียงเอฟเฟกต์:  ", "Sound effects:  ") + string(global.set_sfx) + "%",
                L("กล้องสั่น:  ", "Screen shake:  ") + shake_name(),
                L("หยุดจังหวะตอนตีโดน:  ", "Hit-stop:  ") + (global.fx_hitstop_on ? _on : _off),
                L("ตัวเลขดาเมจ:  ", "Damage numbers:  ") + (global.show_dmg ? _on : _off),
                L("ตั้งค่าปุ่ม / จอย", "Controls"),
                L("กลับ", "Back")
            ];
        case 3:   // ★ ตั้งค่าปุ่ม
            var _rl = input_rebind_list();
            var _out = [];
            for (var _ri = 0; _ri < array_length(_rl); _ri++) array_push(_out, input_action_name(_rl[_ri]));
            array_push(_out, L("คืนค่าเดิมทั้งหมด", "Reset to defaults"));
            array_push(_out, L("กลับ", "Back"));
            return _out;
        case 2:
            return [L("ยืนยัน กลับหน้าหลัก", "Yes, return to title"), L("ยกเลิก", "Cancel")];
    }
    return [L("เล่นต่อ", "Resume"), L("ตั้งค่า", "Settings"), L("กลับหน้าหลัก", "Return to Title")];
}

shake_vals = [0, 1, 2.5, 4];
shake_names = function() { return [L("ปิด", "Off"), L("เบา", "Light"), L("ปกติ", "Normal"), L("แรง", "Strong")]; };
shake_index = function() {
    var _best = 0;
    for (var _i = 0; _i < 4; _i++) {
        if (abs(shake_vals[_i] - global.fx_shake_scale) < abs(shake_vals[_best] - global.fx_shake_scale)) _best = _i;
    }
    return _best;
}
shake_name = function() {
    return shake_names()[shake_index()];
}

// ปรับค่าตั้งค่าแถว _row ไป _d (+1 / -1)
change_setting = function(_row, _d) {
    switch (_row) {
        case 0:   // ★ ภาษา
            lang_set((global.lang == "en") ? "th" : "en");
            break;
        case 1:
            global.set_volume = clamp(global.set_volume + _d * 10, 0, 100);
            break;
        case 2:
            global.set_music = clamp(global.set_music + _d * 10, 0, 100);
            break;
        case 3:
            global.set_sfx = clamp(global.set_sfx + _d * 10, 0, 100);
            sfx("ui_move");   // ★ ให้ได้ยินว่าดังแค่ไหน
            break;
        case 4:
            global.fx_shake_scale = shake_vals[(shake_index() + _d + 4) mod 4];
            break;
        case 5:
            global.fx_hitstop_on = !global.fx_hitstop_on;
            break;
        case 6:
            global.show_dmg = !global.show_dmg;
            break;
    }
    settings_apply();
}

// ยืนยันเลือกแถว _row
confirm = function(_row) {
    switch (screen) {
        case 0:
            if (_row == 0) do_resume();
            else if (_row == 1) { screen = 1; sel = 0; }
            else { screen = 2; sel = 1; }
            break;
        case 1:
            if (_row == 8) close_settings();
            else if (_row == 7) { screen = 3; sel = 0; bind_wait = ""; }
            else if (_row >= 1 && _row <= 3) {
                // เสียง: กดวนขึ้นทีละ 20% ถึง 100 แล้ววนกลับ 0
                var _v = (_row == 1) ? global.set_volume : ((_row == 2) ? global.set_music : global.set_sfx);
                _v = (_v >= 100) ? 0 : min(100, _v + 20);
                if (_row == 1) global.set_volume = _v;
                else if (_row == 2) global.set_music = _v;
                else { global.set_sfx = _v; sfx("ui_move"); }
                settings_apply();
            }
            else change_setting(_row, 1);
            break;
        case 3:   // ★ ตั้งค่าปุ่ม: เลือกแถวแล้วกดปุ่มใหม่ (คีย์บอร์ด/เมาส์ = ปุ่มคีย์บอร์ด, จอย = ปุ่มจอย)
            var _rl2 = input_rebind_list();
            var _nr = array_length(_rl2);
            if (_row < _nr) { bind_wait = _rl2[_row]; bind_delay = 8; }
            else if (_row == _nr) input_reset_defaults();
            else { input_save(); screen = 1; sel = 7; }
            break;
        case 2:
            if (_row == 0) go_title();
            else { screen = 0; sel = 2; }
            break;
    }
}

// ตำแหน่งแถวบนจอ (ใช้ทั้งวาดและเช็กเมาส์)
row_y = function(_i) {
    if (screen == 3) return 90 + _i * 22;   // ★ หน้าตั้งค่าปุ่ม รายการยาว (18 แถว)
    if (screen == 1) return 188 + _i * 34;  // ★ หน้าตั้งค่า 9 แถว (เพิ่มเพลง/เอฟเฟกต์) บีบให้พอดีจอ
    return 214 + _i * 40;
}
bind_wait = "";   // ★ การกระทำที่กำลังรอให้กดปุ่มใหม่
bind_delay = 0;
