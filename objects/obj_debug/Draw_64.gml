if (!show) exit;

draw_set_font(fnt_dialog);

// ★ แผงปุ่มลัด Debug: ซ้ายกลางจอ หลายบรรทัด ไม่ล้นจอ ไม่ทับ HUD
var _hx = 8;
var _hy = 214;
var _hs = 0.42;
var _help = [
    "DEBUG  (H = hide)",
    "Z heal   X god: " + (global.god ? "ON" : "OFF"),
    "Del kill all   G +100 gold",
    "O +potion   K +SP   L +shot",
    "PgUp / PgDn  room   N  menu",
    "F3 stats"
];
draw_set_alpha(0.55);
draw_set_color(c_black);
draw_rectangle(_hx, _hy, _hx + 200, _hy + array_length(_help) * 15 + 8, false);
draw_set_alpha(1);
for (var _hl = 0; _hl < array_length(_help); _hl++) {
    draw_set_color((_hl == 0) ? c_lime : make_color_rgb(190, 255, 190));
    draw_text_transformed(_hx + 6, _hy + 4 + _hl * 15, _help[_hl], _hs, _hs, 0);
}

if (stats) {
    // แผงสถิติ: ซ้ายล่าง ใต้แผงปุ่มลัด (เหนือปุ่มหยุดเกม)
    var _ox = 8;
    var _oy = _hy + array_length(_help) * 15 + 14;
    var _ow = 250;
    var _ls = 0.42;
    var _lh = 13;
    // ---- นับของในห้อง ----
    var _en = instance_number(obj_enemy);
    var _awake = 0;
    with (obj_enemy) if (alert_timer > 0) _awake++;
    var _bul = instance_number(obj_enemy_bullet) + instance_number(obj_bullet);

    // ---- กรอบ ----
    draw_set_alpha(0.6);
    draw_set_color(c_black);
    draw_rectangle(_ox, _oy, _ox + _ow, _oy + 150, false);
    draw_set_alpha(1);

    // ---- ตัวเลข ----
    var _f = fps;
    draw_set_color(_f >= 55 ? c_lime : (_f >= 40 ? c_yellow : c_red));
    var _ty = _oy + 4;
    draw_text_transformed(_ox + 6, _ty, "FPS " + string(_f) + "  (real " + string(round(fps_real)) + ")", 0.5, 0.5, 0);
    draw_set_color(c_white);
    _ty += 16; draw_text_transformed(_ox + 6, _ty, "Room: " + room_get_name(room), _ls, _ls, 0);
    _ty += _lh; draw_text_transformed(_ox + 6, _ty, "Inst: " + string(instance_count) + "  Walls: " + string(instance_number(obj_wall)), _ls, _ls, 0);
    _ty += _lh; draw_text_transformed(_ox + 6, _ty, "Enemies: " + string(_en) + " (awake " + string(_awake) + ")  Bullets: " + string(_bul), _ls, _ls, 0);
    if (instance_exists(obj_player)) {
        _ty += _lh; draw_text_transformed(_ox + 6, _ty, "Player: " + string(round(obj_player.x)) + ", " + string(round(obj_player.y)) + "  HP " + string(obj_player.hp) + "/" + string(obj_player.max_hp), _ls, _ls, 0);
    }
    _ty += _lh; draw_text_transformed(_ox + 6, _ty, "Gold " + string(global.save.gold) + "  SP " + string(global.save.sp) + "  Potion " + string(global.save.potions), _ls, _ls, 0);
    _ty += _lh; draw_text_transformed(_ox + 6, _ty, "Input: " + global.input_dev + "  Pad: " + string(global.pad), _ls, _ls, 0);

    // ---- กราฟเวลาต่อเฟรม (เส้นขาว = 16.7ms = 60fps) ----
    var _gx = _ox + 6;
    var _gy = _oy + 146;     // ฐานกราฟ
    for (var _i = 0; _i < 120; _i++) {
        var _v = hist[(hpos + _i) mod 120];
        var _h = clamp(_v * 1.2, 0, 26);   // 20ms = สูง 24px
        draw_set_color(_v < 18 ? c_lime : (_v < 25 ? c_yellow : c_red));
        draw_rectangle(_gx + _i * 1.95, _gy - _h, _gx + _i * 1.95 + 1.2, _gy, false);
    }
    draw_set_color(c_white);
    draw_line(_gx, _gy - 20, _gx + 234, _gy - 20);
}

draw_set_color(c_white);