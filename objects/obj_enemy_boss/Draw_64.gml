// หลอดเลือดบอส (แสดงเมื่อกำลังสู้ หรือเลือดไม่เต็ม)
if (alert_timer <= 0 && state == "chase" && hp >= max_hp) exit;

var _x = 280;
var _y = 30;
var _w = 400;

// ★ ชื่อบอสเหนือหลอด
draw_set_font(fnt_dialog);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(c_black);
draw_text_transformed(_x + _w / 2 + 1, _y - 3, boss_name, 0.6, 0.6, 0);
draw_set_color(make_color_rgb(255, 210, 200));
draw_text_transformed(_x + _w / 2, _y - 4, boss_name, 0.6, 0.6, 0);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

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

// =====================================================================
// ★ ไม้ตาย / มึนงง
// =====================================================================
if (state == "ult" || state == "ult_boom" || ult_flash > 0) {
    var _uk = (state == "ult") ? (1 - ult_t / ult_time) : 1;
    draw_set_alpha(0.1 + 0.25 * _uk + 0.05 * sin(current_time / 70));
    draw_set_color(c_red);
    draw_rectangle(0, 0, 960, 540, false);
    draw_set_alpha(1);
}
if (state == "ult") {
    draw_set_font(fnt_dialog);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    var _pulse = 1 + 0.06 * sin(current_time / 90);
    draw_set_color(c_black);
    draw_text_transformed(481, 91, "ไม้ตาย! เข้าไปฟันขัดจังหวะ (กระสุนไม่เข้า)", 0.85 * _pulse, 0.85 * _pulse, 0);
    draw_set_color(c_red);
    draw_text_transformed(480, 90, "ไม้ตาย! เข้าไปฟันขัดจังหวะ (กระสุนไม่เข้า)", 0.85 * _pulse, 0.85 * _pulse, 0);

    // เกจขัดจังหวะ
    var _gx = 330;
    var _gy = 118;
    var _gw = 300;
    draw_set_color(c_black);
    draw_rectangle(_gx - 2, _gy - 2, _gx + _gw + 2, _gy + 14, false);
    draw_set_color(c_yellow);
    draw_rectangle(_gx, _gy, _gx + _gw * min(1, ult_gauge / ult_need), _gy + 12, false);
    // เวลาที่เหลือ
    draw_set_color(c_black);
    draw_rectangle(_gx - 2, _gy + 18, _gx + _gw + 2, _gy + 24, false);
    draw_set_color(c_red);
    draw_rectangle(_gx, _gy + 19, _gx + _gw * (ult_t / ult_time), _gy + 23, false);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
if (ult_flash > 0) {
    draw_set_alpha(ult_flash / 30);
    draw_set_color(c_white);
    draw_rectangle(0, 0, 960, 540, false);
    draw_set_alpha(1);
}
if (state == "stunned") {
    draw_set_font(fnt_dialog);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_yellow);
    draw_text_transformed(480, 96, "มึนงง! รุมเลย", 0.8, 0.8, 0);
    draw_set_color(c_black);
    draw_rectangle(378, 110, 582, 117, false);
    draw_set_color(c_yellow);
    draw_rectangle(380, 111, 380 + 200 * (stun_t / stun_time), 116, false);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
draw_set_color(c_white);
