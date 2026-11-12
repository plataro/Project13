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
        _lines = [
            [L("WASD / ลูกศร", "WASD / Arrows"), L("เดิน   |   Shift ค้าง = วิ่ง", "Move   |   Hold Shift = Run")],
            [L("เมาส์", "Mouse"), L("เล็งและหันตัว", "Aim and face direction")],
            [L("คลิกซ้าย", "Left Click"), L("โจมตี (คลิกต่อเนื่อง = คอมโบ) | ค้อน: กดค้างชาร์จ", "Attack (keep clicking = combo) | Hammer: hold to charge")],
            ["1 / 2", L("ยิงลูกไฟ / ยิงกระจาย", "Fireball / Spread shot")],
            ["Space", L("กลิ้งหลบ (ระหว่างกลิ้งไม่โดนโจมตี)", "Dodge roll (invincible while rolling)")],
            ["Q / F / V", L("ดื่มยา / ใช้บัฟ / เปลี่ยนบัฟ", "Potion / Use buff / Switch buff")],
            ["E", L("คุย | เปิดหีบ | เข้าร้าน", "Talk | Open chest | Enter shop")],
            ["T / I", L("ต้นไม้สกิล / หน้าสถานะ", "Skill tree / Status")],
            ["P / Esc", L("หยุดเกม", "Pause")]
        ];
    } else {
        ui_text_bold(480, 74, L("เครดิต", "Credits"), 0.95, UI_GOLD);
        _lines = credits_lines();   // ★ แก้รายชื่อที่ scr_globals (ใช้ร่วมกับหน้าจบเกม)
    }
    for (var _l = 0; _l < array_length(_lines); _l++) {
        var _ly = 124 + _l * 38;
        draw_set_halign(fa_right);
        ui_text_bold(400, _ly, _lines[_l][0], 0.55, UI_GOLD);
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
