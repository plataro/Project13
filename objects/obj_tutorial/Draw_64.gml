draw_set_font(fnt_dialog);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// ===== ★ การ์ดเปิดตัวบอส: แถบดำบนล่าง + ชื่อ =====
if (!is_undefined(global.boss_intro)) {
    var _bt = global.boss_intro.t;
    var _bar = 70 * clamp(min(_bt / 20, (180 - _bt) / 20), 0, 1);
    draw_set_color(c_black);
    draw_rectangle(0, 0, 960, _bar, false);
    draw_rectangle(0, 540 - _bar, 960, 540, false);

    var _ta = clamp(min((_bt - 35) / 15, (150 - _bt) / 15), 0, 1);
    if (_ta > 0) {
        var _slide = (1 - _ta) * 40;
        draw_set_alpha(_ta);
        draw_set_color(c_black);
        draw_text_transformed(482 - _slide, 402, global.boss_intro.name, 1.6, 1.6, 0);
        draw_set_color(c_red);
        draw_text_transformed(480 - _slide, 400, global.boss_intro.name, 1.6, 1.6, 0);
        draw_set_color(c_ltgray);
        draw_text_transformed(480 + _slide, 448, global.boss_intro.title, 0.8, 0.8, 0);
        draw_set_color(c_red);
        draw_line_width(300 + _slide, 428, 660 - _slide, 428, 2);
        draw_set_alpha(1);
    }
}

// ===== หยุดรอกลิ้งหลบ =====
if (freeze) {
    var _fa = min(1, freeze_t / 10);
    draw_set_alpha(0.35 * _fa);
    draw_set_color(c_black);
    draw_rectangle(0, 0, 960, 540, false);

    var _bob = sin(current_time / 150) * 3;
    draw_set_alpha(0.9 * _fa);
    draw_set_color(make_color_rgb(20, 16, 28));
    draw_roundrect_ext(250, 380, 710, 500, 14, 14, false);
    draw_set_alpha(_fa);
    draw_set_color(c_yellow);
    draw_roundrect_ext(250, 380, 710, 500, 14, 14, true);

    draw_set_color(make_color_rgb(255, 110, 90));
    draw_text_transformed(480, 404, "ศัตรูกำลังจะโจมตี!", 0.9, 0.9, 0);

    // ปุ่ม Space
    draw_set_color(c_white);
    draw_roundrect_ext(400, 432 + _bob, 560, 468 + _bob, 8, 8, false);
    draw_set_color(c_black);
    draw_text_transformed(480, 450 + _bob, "Space", 0.8, 0.8, 0);

    draw_set_color(c_ltgray);
    draw_text_transformed(480, 484, "กลิ้งหลบ  (กดทิศทางค้างไว้ = เลือกทางกลิ้ง)", 0.55, 0.55, 0);
    draw_set_alpha(1);
}

// ===== ข้อความสั้น =====
if (msg_t > 0) {
    draw_set_alpha(min(1, msg_t / 30));
    draw_set_color(c_black);
    draw_text_transformed(481, 151, msg, 0.9, 0.9, 0);
    draw_set_color(msg_col);
    draw_text_transformed(480, 150, msg, 0.9, 0.9, 0);
    draw_set_alpha(1);
}

// ===== ป้ายปุ่มตามสถานการณ์ (กลางจอด้านล่าง) =====
if (!is_undefined(ctx) && ctx_a > 0.02) {
    var _y = 470;
    var _keys = "";
    for (var _k = 0; _k < array_length(ctx.keys); _k++) {
        _keys += ((_k > 0) ? " / " : "") + ctx.keys[_k];
    }
    var _txt = _keys + "   " + ctx.text;
    var _w = string_width(_txt) * 0.7 + 60;

    draw_set_alpha(0.8 * ctx_a);
    draw_set_color(c_black);
    draw_roundrect_ext(480 - _w / 2, _y - 22, 480 + _w / 2, _y + 22, 12, 12, false);
    draw_set_alpha(ctx_a);
    draw_set_color((ctx_done > 0) ? make_color_rgb(120, 230, 120) : c_yellow);
    draw_roundrect_ext(480 - _w / 2, _y - 22, 480 + _w / 2, _y + 22, 12, 12, true);
    draw_set_color((ctx_done > 0) ? make_color_rgb(150, 255, 150) : c_white);
    draw_text_transformed(480, _y, _txt, 0.7, 0.7, 0);
    draw_set_alpha(1);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
