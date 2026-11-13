draw_set_font(fnt_dialog);
draw_set_color(c_black);
draw_rectangle(0, 0, 960, 540, false);

if (idx < array_length(slides)) {
    var _sl = slides[idx];
    // ★ คัทซีนแบบข้อความบรรยายอย่างเดียว (ไม่มีภาพประกอบ)

    // ละอองแสงลอยขึ้นช้า ๆ
    for (var _m = 0; _m < 24; _m++) {
        var _mx = (_m * 137 + sin(t / 90 + _m) * 30) mod 960;
        var _my = 540 - ((t * (0.25 + (_m mod 5) * 0.08) + _m * 61) mod 580);
        draw_set_alpha(0.15 + 0.2 * (0.5 + 0.5 * sin(t / 30 + _m)));
        draw_set_color(UI_GOLD);
        draw_circle(_mx, _my, 1 + (_m mod 3) * 0.6, false);
    }
    draw_set_alpha(1);

    // ตัวคั่นลายเพชร
    var _dy = 200;
    draw_set_color(UI_GOLD_DARK);
    draw_line(330, _dy, 460, _dy);
    draw_line(500, _dy, 630, _dy);
    draw_set_color(UI_GOLD);
    draw_triangle(480 - 7, _dy, 480 + 7, _dy, 480, _dy - 7, false);
    draw_triangle(480 - 7, _dy, 480 + 7, _dy, 480, _dy + 7, false);

    // ★ ข้อความเล็กลง กึ่งกลาง สีกระดาษเก่า มีเงานุ่ม ๆ
    var _ts = 0.7;
    var _txt = string_copy(wrapped, 1, floor(chars));
    draw_set_halign(fa_center);
    draw_set_color(c_black);
    draw_set_alpha(0.7);
    draw_text_ext_transformed(481, 226, _txt, 40, 2000, _ts, _ts, 0);
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(232, 220, 190));
    draw_text_ext_transformed(480, 225, _txt, 40, 2000, _ts, _ts, 0);

    // ไปต่อ: เพชรเล็ก ๆ กะพริบช้า
    if (chars >= total) {
        var _pa = 0.4 + 0.6 * (0.5 + 0.5 * sin(current_time / 300));
        draw_set_alpha(_pa);
        draw_set_color(UI_GOLD);
        var _py = 510 + sin(current_time / 300) * 2;
        draw_triangle(474, _py, 486, _py, 480, _py - 6, false);
        draw_triangle(474, _py, 486, _py, 480, _py + 6, false);
        draw_set_alpha(1);
    }

    draw_set_halign(fa_right);
    ui_text(944, 8, ((global.input_dev == "pad") ? L("Start ข้าม", "Start skip") : L("Backspace / Esc ข้าม", "Backspace / Esc skip")), 0.45, UI_MUTED);
    draw_set_halign(fa_left);
}

// ม่านดำ
if (black > 0) {
    draw_set_alpha(black);
    draw_set_color(c_black);
    draw_rectangle(0, 0, 960, 540, false);
}
draw_set_alpha(1);
draw_set_color(c_white);
