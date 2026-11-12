draw_set_font(fnt_dialog);
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

// ★ ข้อความ L("บันทึกแล้ว", "Saved") มุมขวาล่าง หลังเซฟอัตโนมัติ
if (global.save_flash > 0) {
    global.save_flash--;
    if (!open) {
        draw_set_halign(fa_right);
        draw_set_valign(fa_bottom);
        draw_set_alpha(min(1, global.save_flash / 30));
        draw_set_color(c_black);
        draw_text_transformed(945, 529, L("บันทึกแล้ว", "Saved"), 0.6, 0.6, 0);
        draw_set_color(make_color_rgb(150, 230, 150));
        draw_text_transformed(944, 528, L("บันทึกแล้ว", "Saved"), 0.6, 0.6, 0);
        draw_set_alpha(1);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_color(c_white);
    }
}

// =========================
// ปุ่มหยุด (ตอนเล่นอยู่)
// =========================
if (!open) {
    if (!can_pause()) exit;
    if (instance_exists(obj_dialogue) || instance_exists(obj_shop) || instance_exists(obj_skilltree)) exit;

    var _over = point_in_rectangle(_mx, _my, btn[0], btn[1], btn[2], btn[3]);
    draw_set_alpha(_over ? 0.85 : 0.5);
    draw_set_color(c_black);
    draw_roundrect_ext(btn[0], btn[1], btn[2], btn[3], 8, 8, false);
    draw_set_color(_over ? c_yellow : c_white);
    draw_roundrect_ext(btn[0], btn[1], btn[2], btn[3], 8, 8, true);
    var _cx = (btn[0] + btn[2]) / 2;
    var _cy = (btn[1] + btn[3]) / 2;
    draw_rectangle(_cx - 6, _cy - 7, _cx - 3, _cy + 7, false);
    draw_rectangle(_cx + 3, _cy - 7, _cx + 6, _cy + 7, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    exit;
}

// =========================
// เมนู
// =========================
// ภาพเกมนิ่ง + มืดลง (จากเมนูหลักไม่ต้อง เพราะหน้าเมนูอยู่ข้างหลังอยู่แล้ว)
if (!menu_mode && snap != -1 && sprite_exists(snap)) {
    draw_sprite_stretched(snap, 0, 0, 0, 960, 540);
}
draw_set_alpha(menu_mode ? 0.85 : 0.6);
draw_set_color(c_black);
draw_rectangle(0, 0, 960, 540, false);
draw_set_alpha(1);

// ★ หน้าตั้งค่าปุ่ม (แผงกว้าง 2 คอลัมน์: คีย์บอร์ด / จอย)
if (screen == 3) {
    var _items3 = get_items();
    var _n3 = array_length(_items3);
    var _rl = input_rebind_list();
    var _py2b = row_y(_n3 - 1) + 52;
    ui_panel(190, 30, 770, _py2b);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    ui_text_bold(480, 54, L("ตั้งค่าปุ่ม", "Controls"), 0.75, UI_GOLD);
    ui_text_bold(560, 80, L("คีย์บอร์ด", "Keyboard"), 0.45, UI_GOLD, false);
    ui_text_bold(690, 80, L("จอย", "Gamepad"), 0.45, UI_GOLD, false);
    for (var _i3 = 0; _i3 < _n3; _i3++) {
        var _y3 = row_y(_i3);
        var _on3 = (_i3 == sel);
        if (_on3) ui_highlight(204, _y3 - 2, 756, _y3 + 21);
        var _yc = _y3 + 10;
        if (_i3 < array_length(_rl)) {
            var _act = _rl[_i3];
            draw_set_halign(fa_left);
            ui_text(216, _yc, _items3[_i3], 0.48, _on3 ? c_white : UI_TEXT);
            draw_set_halign(fa_center);
            var _waiting = (bind_wait == _act);
            var _blink = (current_time div 300) mod 2 == 0;
            var _kbl = _waiting ? (_blink ? L("กดปุ่ม...", "Press...") : "") : input_key_name(global.bind_kb[$ _act][0]);
            var _pdl = _waiting ? (_blink ? L("กดปุ่ม...", "Press...") : "") : input_pad_name(global.bind_pad[$ _act]);
            // กล่องปุ่ม
            draw_set_color(UI_BG);
            draw_rectangle(500, _y3 + 1, 620, _y3 + 19, false);
            draw_rectangle(630, _y3 + 1, 750, _y3 + 19, false);
            draw_set_color(_waiting ? UI_GOLD : UI_GOLD_DARK);
            draw_rectangle(500, _y3 + 1, 620, _y3 + 19, true);
            draw_rectangle(630, _y3 + 1, 750, _y3 + 19, true);
            ui_text(560, _yc, _kbl, ui_fit(_kbl, 0.44, 112), _waiting ? UI_GOLD : UI_TEXT);
            ui_text(690, _yc, _pdl, ui_fit(_pdl, 0.44, 112), _waiting ? UI_GOLD : UI_TEXT);
        } else {
            ui_text(480, _yc, _items3[_i3], 0.5, _on3 ? c_white : UI_MUTED);
        }
    }
    var _h3 = (bind_wait != "")
        ? L("กดปุ่มคีย์บอร์ด/เมาส์ หรือปุ่มจอยที่ต้องการ  |  Esc ยกเลิก", "Press a key/mouse button or a gamepad button  |  Esc cancel")
        : L("เลือกแถวแล้วกดปุ่มใหม่  |  Esc / B กลับ", "Select a row, then press the new button  |  Esc / B back");
    ui_text(480, _py2b - 16, _h3, ui_fit(_h3, 0.4, 540), UI_MUTED);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    exit;
}

// ★ แผงเล็กลง มีขอบ (placeholder)
var _items = get_items();
var _n = array_length(_items);
var _py1 = 120;
var _py2 = row_y(_n - 1) + 74;
ui_panel(310, _py1, 650, _py2);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
var _title = L("หยุดเกม", "Paused");
if (screen == 1) _title = L("ตั้งค่า", "Settings");
else if (screen == 2) _title = L("กลับหน้าหลัก?", "Return to title?");
ui_text_bold(480, 152, _title, 0.9, UI_GOLD);
draw_set_color(UI_GOLD_DARK);
draw_line_width(400, 176, 560, 176, 2);
var _wt = L("เล่นต่อได้จากจุดที่เข้าห้องนี้ (เซฟอัตโนมัติ)", "Continue later from this area's entrance (autosave)");
if (screen == 2) ui_text(480, 194, _wt, ui_fit(_wt, 0.48, 316), UI_MUTED);

for (var _i = 0; _i < _n; _i++) {
    var _y = row_y(_i);
    var _on = (_i == sel);
    if (_on) ui_highlight(326, _y - 4, 634, _y + 30);
    ui_text(480 + (_on ? 4 : 0), _y + 13, _items[_i], ui_fit(_items[_i], 0.6, 300), _on ? c_white : UI_MUTED);
}

// คำแนะนำด้านล่าง
var _hint = (screen == 1)
    ? L("คลิก หรือ A/D ปรับค่า  |  Esc / P กลับ", "Click or A/D to change  |  Esc / P back")
    : L("คลิก หรือ W/S + Enter  |  Esc / P ", "Click or W/S + Enter  |  Esc / P ") + ((screen == 0 && !menu_mode) ? L("เล่นต่อ", "resume") : L("กลับ", "back"));
ui_text(480, _py2 - 22, _hint, ui_fit(_hint, 0.42, 320), UI_MUTED);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
