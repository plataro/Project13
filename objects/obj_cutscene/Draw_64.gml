draw_set_font(fnt_dialog);
draw_set_color(c_black);
draw_rectangle(0, 0, 960, 540, false);

if (idx < array_length(slides)) {
    var _sl = slides[idx];
    var _spr = asset_get_index(_sl.img);
    // ★ กรอบภาพเล็กลง ให้มีพื้นที่ดำรอบ ๆ ดูขลังขึ้น
    var _ix1 = 130;
    var _iy1 = 36;
    var _ix2 = 830;
    var _iy2 = 360;

    if (_spr != -1 && sprite_exists(_spr)) {
        var _sc = max((_ix2 - _ix1) / sprite_get_width(_spr), (_iy2 - _iy1) / sprite_get_height(_spr));
        var _sw = (_ix2 - _ix1) / _sc;
        var _sh = (_iy2 - _iy1) / _sc;
        draw_sprite_part_ext(_spr, 0, max(0, (sprite_get_width(_spr) - _sw) / 2), max(0, (sprite_get_height(_spr) - _sh) / 2), _sw, _sh, _ix1, _iy1, _sc, _sc, c_white, img_a);
    } else {
        // placeholder: พื้นหลังไล่สี + ชื่อ sprite ที่ต้องวาดมาใส่
        var _h = (idx * 47 + 20) mod 255;
        var _c1 = make_color_hsv(_h, 90, 70);
        var _c2 = make_color_hsv((_h + 30) mod 255, 120, 25);
        draw_set_alpha(img_a);
        draw_rectangle_color(_ix1, _iy1, _ix2, _iy2, _c1, _c1, _c2, _c2, false);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(c_ltgray);
        draw_text_transformed(480, 180, "[ ภาพประกอบ ]", 0.7, 0.7, 0);
        draw_set_color(c_gray);
        draw_text_transformed(480, 210, _sl.img, 0.5, 0.5, 0);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_alpha(1);
    }
    // ขอบภาพจางเข้าหาดำ (vignette)
    var _vw = 40;
    draw_set_alpha(img_a);
    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_color(_ix1, _iy1, c_black, 1); draw_vertex_color(_ix1, _iy2, c_black, 1);
    draw_vertex_color(_ix1 + _vw, _iy1, c_black, 0); draw_vertex_color(_ix1 + _vw, _iy2, c_black, 0);
    draw_primitive_end();
    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_color(_ix2, _iy1, c_black, 1); draw_vertex_color(_ix2, _iy2, c_black, 1);
    draw_vertex_color(_ix2 - _vw, _iy1, c_black, 0); draw_vertex_color(_ix2 - _vw, _iy2, c_black, 0);
    draw_primitive_end();
    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_color(_ix1, _iy2, c_black, 1); draw_vertex_color(_ix2, _iy2, c_black, 1);
    draw_vertex_color(_ix1, _iy2 - _vw, c_black, 0); draw_vertex_color(_ix2, _iy2 - _vw, c_black, 0);
    draw_primitive_end();
    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_color(_ix1, _iy1, c_black, 1); draw_vertex_color(_ix2, _iy1, c_black, 1);
    draw_vertex_color(_ix1, _iy1 + _vw, c_black, 0); draw_vertex_color(_ix2, _iy1 + _vw, c_black, 0);
    draw_primitive_end();
    // เส้นทองบาง ๆ
    draw_set_alpha(img_a * 0.6);
    draw_set_color(UI_GOLD_DARK);
    draw_rectangle(_ix1 - 6, _iy1 - 6, _ix2 + 6, _iy2 + 6, true);
    draw_set_alpha(1);

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
    var _dy = 386;
    draw_set_color(UI_GOLD_DARK);
    draw_line(330, _dy, 460, _dy);
    draw_line(500, _dy, 630, _dy);
    draw_set_color(UI_GOLD);
    draw_triangle(480 - 7, _dy, 480 + 7, _dy, 480, _dy - 7, false);
    draw_triangle(480 - 7, _dy, 480 + 7, _dy, 480, _dy + 7, false);

    // ★ ข้อความเล็กลง กึ่งกลาง สีกระดาษเก่า มีเงานุ่ม ๆ
    var _ts = 0.6;
    var _txt = string_copy(wrapped, 1, floor(chars));
    draw_set_halign(fa_center);
    draw_set_color(c_black);
    draw_set_alpha(0.7);
    draw_text_ext_transformed(481, 406, _txt, 40, 2000, _ts, _ts, 0);
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(232, 220, 190));
    draw_text_ext_transformed(480, 405, _txt, 40, 2000, _ts, _ts, 0);

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
    ui_text(944, 8, "Tab / Esc ข้าม", 0.45, UI_MUTED);
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
