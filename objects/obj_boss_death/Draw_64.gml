// ---- จอค่อย ๆ แดง/มืดตอนดิ้น ----
if (t < t_burst) {
    var _k = t / t_burst;
    draw_set_alpha(0.25 * _k);
    draw_set_color(make_color_rgb(60, 0, 10));
    draw_rectangle(0, 0, 960, 540, false);
}
// ---- วาบขาว ----
if (gui_flash > 0) {
    draw_set_alpha(gui_flash);
    draw_set_color(c_white);
    draw_rectangle(0, 0, 960, 540, false);
}
draw_set_alpha(1);

// ---- ข้อความ "ปราบแล้ว" ----
var _ta = is_final ? clamp((t - t_text) / 30, 0, 1) : clamp(min((t - t_text) / 20, (t_end - t) / 30), 0, 1);
if (_ta > 0) {
    draw_set_font(fnt_dialog);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    var _y = 200;
    var _sp = 1 - power(1 - _ta, 3);
    // แถบแสงหลังข้อความ
    draw_set_alpha(0.6 * _ta);
    draw_rectangle_color(0, _y - 46, 480, _y + 50, c_black, make_color_rgb(60, 40, 10), make_color_rgb(60, 40, 10), c_black, false);
    draw_rectangle_color(480, _y - 46, 960, _y + 50, make_color_rgb(60, 40, 10), c_black, c_black, make_color_rgb(60, 40, 10), false);
    draw_set_alpha(_ta);
    // เส้นทองขยายออก
    var _lw = 240 * _sp;
    draw_set_color(UI_GOLD);
    draw_line_width(480 - _lw, _y + 26, 480 + _lw, _y + 26, 2);
    draw_triangle(474, _y + 26, 486, _y + 26, 480, _y + 20, false);
    draw_triangle(474, _y + 26, 486, _y + 26, 480, _y + 32, false);
    var _s = 1.25 + 0.3 * (1 - _sp);
    ui_text_bold(480, _y - 8, is_final ? L("ชัยชนะ", "Victory") : L("ปราบแล้ว", "Defeated"), _s, make_color_rgb(255, 225, 150));
    ui_text(480, _y + 46, boss_name, 0.6, make_color_rgb(230, 200, 190));
    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
draw_set_color(c_white);

// ★ บอสสุดท้าย: ค่อย ๆ มืดลงทั้งจอ (ข้อความ "ชัยชนะ" จมหายไปกับความมืด) แล้วไปคัทซีนจบ
if (black > 0) {
    draw_set_alpha(black);
    draw_set_color(c_black);
    draw_rectangle(0, 0, 960, 540, false);
    draw_set_alpha(1);
}
