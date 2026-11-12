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

// ===== หยุดรอกลิ้งหลบ (กลางจอ ไม่ทับช่องสกิล) =====
if (freeze) {
    var _fa = min(1, freeze_t / 10);
    draw_set_alpha(0.35 * _fa);
    draw_set_color(c_black);
    draw_rectangle(0, 0, 960, 540, false);
    draw_set_alpha(1);

    var _bob = sin(current_time / 150) * 3;
    var _py = 170 + (1 - _fa) * 20;
    ui_panel(270, _py, 690, _py + 120, _fa);
    draw_set_alpha(_fa);
    ui_text_bold(480, _py + 24, "ศัตรูกำลังจะโจมตี!", 0.8, make_color_rgb(255, 120, 100));

    // ปุ่ม Space
    draw_set_color(make_color_rgb(150, 120, 70));
    draw_rectangle(410, _py + 46 + _bob, 550, _py + 80 + _bob, false);
    draw_set_color(make_color_rgb(250, 235, 200));
    draw_rectangle(410, _py + 42 + _bob, 550, _py + 76 + _bob, false);
    draw_set_color(make_color_rgb(40, 30, 20));
    draw_text_transformed(480, _py + 59 + _bob, "Space", 0.7, 0.7, 0);

    ui_text(480, _py + 100, "กลิ้งหลบ  (กดทิศทางค้างไว้ = เลือกทางกลิ้ง)", 0.5, UI_MUTED);
    draw_set_alpha(1);
}

// ===== ข้อความสั้น =====
if (msg_t > 0) {
    var _ma = min(1, msg_t / 30);
    draw_set_alpha(_ma);
    ui_text_bold(480, 150, msg, 0.8, msg_col);
    draw_set_alpha(1);
}

// ===== ★ ป้ายสอนเล่น: ย้ายมาบนกลางจอ (ไม่ทับช่องสกิลด้านล่าง) =====
if (!is_undefined(ctx) && ctx_a > 0.02) {
    var _y = 34 + (1 - ctx_a) * -16;
    var _s = 0.55;
    var _done = (ctx_done > 0);
    // ความกว้าง: ปุ่มแต่ละอัน + ข้อความ
    var _kws = [];
    var _sumk = 0;
    for (var _k = 0; _k < array_length(ctx.keys); _k++) {
        var _kw = max(26, string_width(ctx.keys[_k]) * _s + 14);
        _kws[_k] = _kw;
        _sumk += _kw + 6;
    }
    var _w = _sumk + string_width(ctx.text) * _s + 40;
    var _x1 = 480 - _w / 2;
    ui_panel(_x1, _y - 18, _x1 + _w, _y + 18, ctx_a);
    draw_set_alpha(ctx_a);
    var _cx = _x1 + 14;
    for (var _k2 = 0; _k2 < array_length(ctx.keys); _k2++) {
        draw_set_color(_done ? make_color_rgb(40, 110, 50) : make_color_rgb(150, 120, 70));
        draw_rectangle(_cx, _y - 10, _cx + _kws[_k2], _y + 13, false);
        draw_set_color(_done ? make_color_rgb(150, 240, 150) : make_color_rgb(250, 235, 200));
        draw_rectangle(_cx, _y - 12, _cx + _kws[_k2], _y + 10, false);
        draw_set_color(make_color_rgb(40, 30, 20));
        draw_text_transformed(_cx + _kws[_k2] / 2, _y - 1, ctx.keys[_k2], _s, _s, 0);
        _cx += _kws[_k2] + 6;
    }
    draw_set_halign(fa_left);
    ui_text(_cx + 6, _y, ctx.text, _s, _done ? make_color_rgb(150, 255, 150) : UI_TEXT);
    draw_set_halign(fa_center);
    draw_set_alpha(1);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
