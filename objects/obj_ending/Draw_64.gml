draw_set_color(c_black);
draw_rectangle(0, 0, 960, 540, false);

if (shown_end) {
    draw_set_font(fnt_dialog);
    draw_set_halign(fa_center);
    draw_set_color(c_white);
    draw_text_transformed(480, 200, "จบ", 3, 3, 0);
    draw_text(480, 330, "ขอบคุณที่เล่น");
    draw_set_color(c_gray);
    draw_text(480, 420, "กด Enter เพื่อกลับเมนู");
    draw_set_halign(fa_left);
}
draw_set_color(c_white);