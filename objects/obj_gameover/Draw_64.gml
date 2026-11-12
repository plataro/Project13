draw_set_alpha(alpha);
draw_set_color(c_black);
draw_rectangle(0, 0, 960, 540, false);
// ขอบแดงจาง ๆ
draw_set_alpha(alpha * 0.35);
draw_rectangle_color(0, 0, 960, 540, make_color_rgb(80, 0, 10), make_color_rgb(80, 0, 10), c_black, c_black, false);
draw_set_alpha(1);

if (alpha >= 0.8) {
    var _k = 1 - power(1 - pop, 3);
    var _oy = (1 - _k) * 30;
    draw_set_font(fnt_dialog);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    ui_panel(300, 150 + _oy, 660, 410 + _oy, _k);
    draw_set_alpha(_k);
    ui_text_bold(480, 208 + _oy, "GAME OVER", 1.3, make_color_rgb(230, 60, 60));
    draw_set_color(UI_GOLD_DARK);
    draw_line_width(400, 244 + _oy, 560, 244 + _oy, 2);

    var _opts = [L("ลองใหม่จากจุดเข้าห้อง", "Retry from area entrance"), L("กลับเมนูหลัก", "Back to Main Menu")];
    for (var _i = 0; _i < 2; _i++) {
        var _by = btn_y(_i) + _oy;
        var _on = (sel == _i);
        if (_on) ui_highlight(360, _by - 18, 600, _by + 18, _k);
        if (_on) {
            draw_set_color(UI_GOLD);
            var _ax = 372 + sin(current_time / 150) * 3;
            draw_triangle(_ax, _by - 7, _ax, _by + 7, _ax + 9, _by, false);
        }
        if (_on) ui_text_bold(480, _by, _opts[_i], 0.6, make_color_rgb(255, 235, 180));
        else ui_text(480, _by, _opts[_i], 0.58, UI_MUTED);
    }
    ui_text(480, 392 + _oy, L("W/S เลือก | Enter / คลิก ยืนยัน", "W/S select | Enter / Click confirm"), 0.42, UI_MUTED);
    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
draw_set_color(c_white);
