draw_set_alpha(alpha);
draw_set_color(c_black);
draw_rectangle(0, 0, 960, 540, false);
draw_set_alpha(1);

if (alpha >= 0.8) {
    draw_set_font(fnt_dialog);
    draw_set_halign(fa_center);
    draw_set_color(c_red);
    draw_text_transformed(480, 190, "GAME OVER", 2.5, 2.5, 0);
    draw_set_color(c_white);
    draw_text(480, 320, "กด Enter หรือคลิกเพื่อลองใหม่");
    draw_set_halign(fa_left);
}
draw_set_color(c_white);