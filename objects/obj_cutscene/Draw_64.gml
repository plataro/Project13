draw_set_font(fnt_dialog);
draw_set_color(c_black);
draw_rectangle(0, 0, 960, 540, false);

if (idx < array_length(slides)) {
    var _sl = slides[idx];
    var _spr = asset_get_index(_sl.img);

    if (_spr != -1 && sprite_exists(_spr)) {
        // มีภาพจริง: ขยายให้เต็มจอ
        var _sc = max(960 / sprite_get_width(_spr), 540 / sprite_get_height(_spr));
        draw_sprite_ext(_spr, 0, 480, 270 - 20, _sc, _sc, 0, c_white, img_a);
    } else {
        // placeholder: พื้นหลังไล่สี + ชื่อ sprite ที่ต้องวาดมาใส่
        var _h = (idx * 47 + 20) mod 255;
        var _c1 = make_color_hsv(_h, 90, 70);
        var _c2 = make_color_hsv((_h + 30) mod 255, 120, 25);
        draw_set_alpha(img_a);
        draw_rectangle_color(40, 30, 920, 390, _c1, _c1, _c2, _c2, false);
        draw_set_color(c_white);
        draw_rectangle(40, 30, 920, 390, true);
        draw_set_halign(fa_center);
        draw_set_color(c_ltgray);
        draw_text(480, 180, "[ ภาพประกอบ ]");
        draw_set_color(c_gray);
        draw_text_transformed(480, 225, _sl.img, 0.7, 0.7, 0);
        draw_set_halign(fa_left);
        draw_set_alpha(1);
    }

    // กรอบข้อความ
    draw_set_alpha(0.8);
    draw_set_color(c_black);
    draw_rectangle(40, 400, 920, 520, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_text(60, 414, string_copy(wrapped, 1, floor(chars)));

    if (chars >= total && (current_time div 400) mod 2 == 0) draw_text(890, 485, ">");

    draw_set_color(c_gray);
    draw_set_halign(fa_right);
    draw_text_transformed(940, 6, "Esc ข้าม", 0.6, 0.6, 0);
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
