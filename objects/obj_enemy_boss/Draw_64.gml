// หลอดเลือดบอส (แสดงเมื่อกำลังสู้ หรือเลือดไม่เต็ม)
if (alert_timer <= 0 && state == "chase" && hp >= max_hp) exit;
if (instance_exists(obj_dialogue) || instance_exists(obj_cutscene)) exit;   // ★ ไม่ทับกล่องไดอาล็อก

// ★ หลอดอยู่ล่างจอ เหนือช่องสกิล / ชื่อบอสอยู่บนหลอด
var _w = 440;
var _x = 480 - _w / 2;
var _y = 430;
var _h = 14;
if (!variable_instance_exists(id, "hud_hp")) { hud_hp = hp; hud_trail = hp; }
hud_hp = lerp(hud_hp, max(hp, 0), 0.18);
if (hud_trail > hud_hp) hud_trail = max(hud_hp, hud_trail - max_hp * 0.006); else hud_trail = hud_hp;
var _k = max(hud_hp, 0) / max_hp;
var _kt = hud_trail / max_hp;

// กรอบ
ui_panel(_x - 10, _y - 30, _x + _w + 10, _y + _h + 8, 0.85);

// ชื่อบอส
draw_set_font(fnt_dialog);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
ui_text_bold(480, _y - 14, boss_name, 0.55, make_color_rgb(255, 200, 190));
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// หลอด: พื้น / แถบขาวไล่ตาม / เลือดไล่สี
draw_set_color(make_color_rgb(20, 10, 18));
draw_rectangle(_x, _y, _x + _w, _y + _h, false);
draw_set_color(make_color_rgb(240, 220, 220));
draw_rectangle(_x, _y, _x + _w * _kt, _y + _h, false);
var _c1 = (invuln > 0) ? c_gray : make_color_rgb(170, 40, 140);
var _c2 = (invuln > 0) ? c_dkgray : make_color_rgb(90, 20, 80);
if (_k > 0) draw_rectangle_color(_x, _y, _x + _w * _k, _y + _h, _c1, _c1, _c2, _c2, false);
draw_set_alpha(0.25);
draw_set_color(c_white);
draw_rectangle(_x, _y + 1, _x + _w * _k, _y + 4, false);
draw_set_alpha(1);

// ★ มีเกราะ: เลือดเป็นสีฟ้าซีด + กรอบฟ้าเรือง + ช่องเกราะเหนือกรอบ
if (shield > 0) {
    var _scol = make_color_rgb(110, 190, 255);
    var _pulse = 0.6 + 0.4 * sin(current_time / 120);

    draw_set_alpha(0.45);
    draw_set_color(_scol);
    draw_rectangle(_x, _y, _x + _w * _k, _y + _h, false);

    draw_set_alpha(_pulse);
    draw_rectangle(_x - 3, _y - 3, _x + _w + 3, _y + _h + 3, true);
    draw_rectangle(_x - 4, _y - 4, _x + _w + 4, _y + _h + 4, true);
    draw_set_alpha(1);

    // ช่องเกราะ (ต้องฟันอีกกี่ที)
    var _py = _y - 52;
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

    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    ui_text(_x + _tw + 10, _py + 8, "เกราะ - ใช้ดาบฟันให้แตก", 0.48, _scol);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}

// ขีดแบ่งเฟส
draw_set_color(UI_GOLD);
if (is_final) {
    draw_line(_x + _w / 3, _y - 2, _x + _w / 3, _y + _h + 2);
    draw_line(_x + _w * 2 / 3, _y - 2, _x + _w * 2 / 3, _y + _h + 2);
} else {
    draw_line(_x + _w / 2, _y - 2, _x + _w / 2, _y + _h + 2);
}

// ★ ตัวเลขเลือด
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
ui_text(480, _y + _h / 2, string(max(0, ceil(hp))) + " / " + string(max_hp), 0.42, c_white);
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
