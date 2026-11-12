draw_set_alpha(alpha);
draw_set_color(c_black);
draw_rectangle(0, 0, 960, 540, false);
draw_set_alpha(1);

if (alpha >= 0.8) {
    draw_set_font(fnt_dialog);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    ui_panel(300, 170, 660, 360);
    ui_text_bold(480, 230, "GAME OVER", 1.3, make_color_rgb(230, 60, 60));
    draw_set_color(UI_GOLD_DARK);
    draw_line_width(400, 266, 560, 266, 2);
    ui_text(480, 310, "Enter / คลิก = ลองใหม่จากจุดเข้าห้อง", 0.5, UI_TEXT);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
draw_set_color(c_white);
