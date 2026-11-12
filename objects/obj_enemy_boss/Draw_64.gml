// หลอดเลือดบอส (แสดงเมื่อกำลังสู้ หรือเลือดไม่เต็ม)
if (alert_timer <= 0 && state == "chase" && hp >= max_hp) exit;

var _x = 280;
var _y = 30;
var _w = 400;

draw_set_color(c_black);
draw_rectangle(_x - 2, _y - 2, _x + _w + 2, _y + 18, false);
draw_set_color((invuln > 0) ? c_gray : c_purple);
draw_rectangle(_x, _y, _x + _w * (max(hp, 0) / max_hp), _y + 16, false);

// ★ มีเกราะ: เลือดเป็นสีฟ้าซีด + กรอบฟ้าเรือง + ช่องเกราะใต้หลอด
if (shield > 0) {
    var _scol = make_color_rgb(110, 190, 255);
    var _pulse = 0.6 + 0.4 * sin(current_time / 120);

    draw_set_alpha(0.45);
    draw_set_color(_scol);
    draw_rectangle(_x, _y, _x + _w * (max(hp, 0) / max_hp), _y + 16, false);

    draw_set_alpha(_pulse);
    draw_rectangle(_x - 4, _y - 4, _x + _w + 4, _y + 20, true);
    draw_rectangle(_x - 5, _y - 5, _x + _w + 5, _y + 21, true);
    draw_set_alpha(1);

    // ช่องเกราะ (ต้องฟันอีกกี่ที)
    var _py = _y + 26;
    for (var _i = 0; _i < shield_hp_max; _i++) {
        var _px = _x + _i * 24;
        draw_set_color(c_black);
        draw_rectangle(_px - 1, _py - 1, _px + 20, _py + 10, false);
        draw_set_color((_i < shield_hp) ? _scol : c_dkgray);
        draw_rectangle(_px, _py, _px + 19, _py + 9, false);
    }
    // เวลาเกราะที่เหลือ
    var _tw = shield_hp_max * 24 - 4;
    draw_set_color(c_black);
    draw_rectangle(_x - 1, _py + 13, _x + _tw + 1, _py + 17, false);
    draw_set_color(_scol);
    draw_rectangle(_x, _py + 14, _x + _tw * (shield / shield_time), _py + 16, false);

    draw_set_font(fnt_dialog);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_set_color(c_black);
    draw_text_transformed(_x + _tw + 11, _py + 9, "เกราะ - ใช้ดาบฟันให้แตก", 0.5, 0.5, 0);
    draw_set_color(_scol);
    draw_text_transformed(_x + _tw + 10, _py + 8, "เกราะ - ใช้ดาบฟันให้แตก", 0.5, 0.5, 0);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}

// ขีดแบ่งเฟส
draw_set_color(c_white);
if (is_final) {
    draw_line(_x + _w / 3, _y, _x + _w / 3, _y + 16);
    draw_line(_x + _w * 2 / 3, _y, _x + _w * 2 / 3, _y + 16);
} else {
    draw_line(_x + _w / 2, _y, _x + _w / 2, _y + 16);
}


// ★ ตัวเลขเลือด
draw_set_font(fnt_dialog);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_black);
draw_text_transformed(_x + _w / 2 + 1, _y + 9, string(max(0, ceil(hp))) + " / " + string(max_hp), 0.5, 0.5, 0);
draw_set_color(c_white);
draw_text_transformed(_x + _w / 2, _y + 8, string(max(0, ceil(hp))) + " / " + string(max_hp), 0.5, 0.5, 0);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
