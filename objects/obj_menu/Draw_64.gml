// ★ เมนูหลัก (placeholder): พื้นไล่สี + แผงกลางจอ มีขอบ ไม่กระจายเต็มจอ
draw_rectangle_color(0, 0, 960, 540, make_color_rgb(18, 16, 30), make_color_rgb(18, 16, 30), make_color_rgb(6, 6, 12), make_color_rgb(6, 6, 12), false);
// ฝุ่นแสงลอย ๆ
gpu_set_blendmode(bm_add);
for (var _d = 0; _d < 24; _d++) {
    var _dx = (_d * 97 + current_time / (40 + _d)) mod 960;
    var _dy = 540 - ((_d * 53 + current_time / (25 + _d * 2)) mod 600);
    draw_set_alpha(0.15 + 0.1 * sin(current_time / 500 + _d));
    draw_set_color(UI_GOLD);
    draw_circle(_dx, _dy, 1.5 + (_d mod 3), false);
}
draw_set_alpha(1);
gpu_set_blendmode(bm_normal);

draw_set_font(fnt_dialog);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

if (screen == 1 || screen == 2) {
    ui_panel(150, 40, 810, 500);
    var _lines;
    if (screen == 1) {
        ui_text_bold(480, 74, L("วิธีเล่น", "How to Play"), 0.95, UI_GOLD);
        var _K = function(_a) { return input_label(_a); };
        _lines = [
            [_K("move"), L("เดิน   |   ", "Move   |   ") + _K("run") + L(" ค้าง = วิ่ง", " (hold) = Run")],
            [_K("aim"), L("เล็งและหันตัว", "Aim and face direction")],
            [_K("attack"), L("โจมตี (กดต่อเนื่อง = คอมโบ) | ค้อน: กดค้างชาร์จ", "Attack (keep pressing = combo) | Hammer: hold to charge")],
            [_K("shoot1") + " / " + _K("shoot2"), L("ยิงลูกไฟ / ยิงกระจาย", "Fireball / Spread shot")],
            [_K("roll"), L("กลิ้งหลบ (ระหว่างกลิ้งไม่โดนโจมตี)", "Dodge roll (invincible while rolling)")],
            [_K("potion") + " / " + _K("buff_use") + " / " + _K("buff_next"), L("ดื่มยา / ใช้บัฟ / เปลี่ยนบัฟ", "Potion / Use buff / Switch buff")],
            [_K("interact"), L("คุย | เปิดหีบ | เข้าร้าน", "Talk | Open chest | Enter shop")],
            [_K("tree") + " / " + _K("status"), L("ต้นไม้สกิล / หน้าสถานะ", "Skill tree / Status")],
            [_K("pause"), L("หยุดเกม (ตั้งปุ่มเองได้ในตั้งค่า)", "Pause (rebind keys in Settings)")]
        ];
    } else {
        ui_text_bold(480, 74, L("เครดิต", "Credits"), 0.95, UI_GOLD);
        _lines = credits_lines();   // ★ แก้รายชื่อที่ scr_globals (ใช้ร่วมกับหน้าจบเกม)
    }
    for (var _l = 0; _l < array_length(_lines); _l++) {
        var _ly = 124 + _l * 38;
        draw_set_halign(fa_right);
        ui_text_bold(400, _ly, _lines[_l][0], ui_fit(_lines[_l][0], 0.55, 230), UI_GOLD);
        draw_set_halign(fa_left);
        ui_text(420, _ly, _lines[_l][1], ui_fit(_lines[_l][1], 0.55, 380), UI_TEXT);
    }
    draw_set_halign(fa_center);
    ui_text(480, 474, L("Enter / คลิก = กลับ", "Enter / Click = Back"), 0.5, UI_MUTED);
}
else {
    // หัวข้อ
    if (screen == 0) {
        var _ty = 104 + sin(current_time / 900) * 3;
        ui_text_bold(480, _ty, "THE UNKNOWN", 1.55, UI_GOLD);
        draw_set_color(UI_GOLD_DARK);
        draw_line_width(330, _ty + 36, 630, _ty + 36, 2);
        if (has_save) ui_text(480, _ty + 56, L("เซฟล่าสุด: ", "Last save: ") + save_text, 0.5, UI_MUTED);
    }
    else if (screen == 3) ui_text_bold(480, 120, L("เลือกฉาก (Debug)", "Scene Select (Debug)"), 0.95, UI_GOLD);
    else if (screen == 5) ui_text_bold(480, 120, "ภาษา / Language", 0.95, UI_GOLD);
    else ui_text_bold(480, 120, L("เลือกระดับความยาก", "Choose Difficulty"), 0.95, UI_GOLD);

    // แผงรายการ
    var _n = array_length(items);
    if (_n > 0) {
        var _py1 = item_y(0) - 18;
        var _py2 = item_y(_n - 1) + 40;
        ui_panel(320, _py1, 640, _py2, 0.9);
    }
    for (var _i = 0; _i < _n; _i++) {
        var _y = item_y(_i);
        var _on = (_i == sel);
        if (_on) ui_highlight(332, _y - 6, 628, _y + 30);
        ui_text(480 + (_on ? 4 : 0), _y + 12, items[_i], ui_fit(items[_i], 0.62, 280), _on ? c_white : UI_MUTED);
    }

    // คำอธิบายระดับความยาก
    if (screen == 4 && sel < 3) {
        ui_text(480, 446, difficulty_data(sel).desc, ui_fit(difficulty_data(sel).desc, 0.5, 900), UI_TEXT);
        if (has_save) ui_text(480, 474, L("เริ่มเกมใหม่จะเขียนทับเซฟเดิม", "Starting a new game will overwrite your save"), 0.5, make_color_rgb(255, 170, 80));
    }
    if (screen == 0 && msg_timer > 0) ui_text(480, 505, msg, 0.55, c_red);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);

// ★ ปุ่ม Debug มุมขวาบน: สี่เหลี่ยม + รูปแมลง (เขียว = เปิด)
if (SHOW_DEBUG_MENU) {
    var _b = dbg_btn;
    var _hov = point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), _b[0], _b[1], _b[2], _b[3]);
    var _on = global.debug;
    var _ic = _on ? make_color_rgb(120, 240, 120) : (_hov ? UI_TEXT : UI_MUTED);
    draw_set_alpha(0.85);
    draw_set_color(_on ? make_color_rgb(20, 60, 24) : UI_BG);
    draw_rectangle(_b[0], _b[1], _b[2], _b[3], false);
    draw_set_alpha(1);
    draw_set_color(_on ? make_color_rgb(120, 240, 120) : (_hov ? UI_GOLD : UI_GOLD_DARK));
    draw_rectangle(_b[0], _b[1], _b[2], _b[3], true);
    // แมลง
    var _cx = (_b[0] + _b[2]) / 2;
    var _cy = (_b[1] + _b[3]) / 2 + 2;
    draw_set_color(_ic);
    draw_ellipse(_cx - 7, _cy - 9, _cx + 7, _cy + 11, false);          // ตัว
    draw_circle(_cx, _cy - 12, 5, false);                               // หัว
    for (var _lg = -1; _lg <= 1; _lg++) {                               // ขา 3 คู่
        draw_line_width(_cx - 7, _cy + _lg * 6, _cx - 14, _cy + _lg * 7 - 2, 2);
        draw_line_width(_cx + 7, _cy + _lg * 6, _cx + 14, _cy + _lg * 7 - 2, 2);
    }
    draw_line_width(_cx - 2, _cy - 16, _cx - 7, _cy - 21, 2);           // หนวด
    draw_line_width(_cx + 2, _cy - 16, _cx + 7, _cy - 21, 2);
    draw_set_color(_on ? make_color_rgb(20, 60, 24) : UI_BG);
    draw_line_width(_cx, _cy - 8, _cx, _cy + 10, 2);                    // เส้นกลางปีก
    if (_hov) {
        draw_set_halign(fa_right);
        draw_set_valign(fa_middle);
        ui_text(_b[0] - 8, (_b[1] + _b[3]) / 2, _on ? "Debug: ON" : "Debug: OFF", 0.45, _ic);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
    draw_set_color(c_white);
}
