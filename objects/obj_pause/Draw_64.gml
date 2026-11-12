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

// กรอบ
draw_set_alpha(0.9);
draw_set_color(make_color_rgb(18, 16, 24));
draw_roundrect_ext(250, 110, 710, 470, 16, 16, false);
draw_set_alpha(1);
draw_set_color(c_white);
draw_roundrect_ext(250, 110, 710, 470, 16, 16, true);

draw_set_halign(fa_center);
draw_set_valign(fa_top);

var _title = "หยุดเกม";
if (screen == 1) _title = "ตั้งค่า";
else if (screen == 2) _title = "กลับหน้าหลัก?";
draw_set_color(c_yellow);
draw_text_transformed(480, 130, _title, 1.3, 1.3, 0);

if (screen == 2) {
    draw_set_color(c_ltgray);
    draw_text_transformed(480, 178, "เล่นต่อได้จากจุดที่เข้าห้องนี้ (เซฟอัตโนมัติ)", 0.7, 0.7, 0);
}

var _items = get_items();
for (var _i = 0; _i < array_length(_items); _i++) {
    var _y = row_y(_i);
    var _on = (_i == sel);
    if (_on) {
        draw_set_alpha(0.25);
        draw_set_color(c_yellow);
        draw_roundrect_ext(290, _y - 4, 670, _y + 36, 10, 10, false);
        draw_set_alpha(1);
    }
    draw_set_color(_on ? c_yellow : c_white);
    draw_text(480, _y, _items[_i]);
}

// คำแนะนำด้านล่าง
draw_set_color(c_gray);
var _hint = (screen == 1)
    ? "คลิก หรือ A/D ปรับค่า   ·   Esc / P กลับ"
    : "คลิก หรือ W/S + Enter   ·   Esc / P " + ((screen == 0 && !menu_mode) ? "เล่นต่อ" : "กลับ");
draw_text_transformed(480, 440, _hint, 0.6, 0.6, 0);

draw_set_halign(fa_left);
draw_set_color(c_white);
