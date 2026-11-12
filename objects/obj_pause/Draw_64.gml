draw_set_font(fnt_dialog);
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

// ★ ข้อความ "บันทึกแล้ว" มุมขวาล่าง หลังเซฟอัตโนมัติ
if (global.save_flash > 0) {
    global.save_flash--;
    if (!open) {
        draw_set_halign(fa_right);
        draw_set_valign(fa_bottom);
        draw_set_alpha(min(1, global.save_flash / 30));
        draw_set_color(c_black);
        draw_text_transformed(945, 529, "บันทึกแล้ว", 0.6, 0.6, 0);
        draw_set_color(make_color_rgb(150, 230, 150));
        draw_text_transformed(944, 528, "บันทึกแล้ว", 0.6, 0.6, 0);
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

// ★ แผงเล็กลง มีขอบ (placeholder)
var _items = get_items();
var _n = array_length(_items);
var _py1 = 120;
var _py2 = row_y(_n - 1) + 74;
ui_panel(310, _py1, 650, _py2);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
var _title = "หยุดเกม";
if (screen == 1) _title = "ตั้งค่า";
else if (screen == 2) _title = "กลับหน้าหลัก?";
ui_text_bold(480, 152, _title, 0.9, UI_GOLD);
draw_set_color(UI_GOLD_DARK);
draw_line_width(400, 176, 560, 176, 2);
if (screen == 2) ui_text(480, 194, "เล่นต่อได้จากจุดที่เข้าห้องนี้ (เซฟอัตโนมัติ)", 0.48, UI_MUTED);

for (var _i = 0; _i < _n; _i++) {
    var _y = row_y(_i);
    var _on = (_i == sel);
    if (_on) ui_highlight(326, _y - 4, 634, _y + 30);
    ui_text(480 + (_on ? 4 : 0), _y + 13, _items[_i], 0.6, _on ? c_white : UI_MUTED);
}

// คำแนะนำด้านล่าง
var _hint = (screen == 1)
    ? "คลิก หรือ A/D ปรับค่า  |  Esc / P กลับ"
    : "คลิก หรือ W/S + Enter  |  Esc / P " + ((screen == 0 && !menu_mode) ? "เล่นต่อ" : "กลับ");
ui_text(480, _py2 - 22, _hint, 0.42, UI_MUTED);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
