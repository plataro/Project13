if (!show) exit;

draw_set_font(fnt_dialog);
draw_set_color(c_lime);
var _s = "DEBUG  Z:heal  X:god(" + (global.god ? "ON" : "OFF") + ")  C:kill all  G:+100g  P:+potion  K:+SP  V/B:room  N:menu  H:hide  F3:stats";
draw_text_transformed(10, 512, _s, 0.6, 0.6, 0);

if (stats) {
    // แผงสถิติอยู่มุมขวาล่าง ไม่ทับหลอดเลือดผู้เล่น (ซ้ายบน) และหลอดบอส (กลางบน)
    var _ox = 624;
    var _oy = 318;
    // ---- นับของในห้อง ----
    var _en = instance_number(obj_enemy);
    var _awake = 0;
    with (obj_enemy) if (alert_timer > 0) _awake++;
    var _bul = instance_number(obj_enemy_bullet) + instance_number(obj_bullet);

    // ---- กรอบ ----
    draw_set_alpha(0.6);
    draw_set_color(c_black);
    draw_rectangle(_ox, _oy, _ox + 324, _oy + 184, false);
    draw_set_alpha(1);

    // ---- ตัวเลข ----
    var _f = fps;
    draw_set_color(_f >= 55 ? c_lime : (_f >= 40 ? c_yellow : c_red));
    var _ty = _oy + 6;
    draw_text_transformed(_ox + 6, _ty, "FPS " + string(_f) + "  (real " + string(round(fps_real)) + ")", 0.7, 0.7, 0);
    draw_set_color(c_white);
    _ty += 18; draw_text_transformed(_ox + 6, _ty, "Room: " + room_get_name(room), 0.6, 0.6, 0);
    _ty += 15; draw_text_transformed(_ox + 6, _ty, "Instances: " + string(instance_count) + "   Walls: " + string(instance_number(obj_wall)), 0.6, 0.6, 0);
    _ty += 15; draw_text_transformed(_ox + 6, _ty, "Enemies: " + string(_en) + " (ตื่น " + string(_awake) + ")   Bullets: " + string(_bul), 0.6, 0.6, 0);
    if (instance_exists(obj_player)) {
        _ty += 15; draw_text_transformed(_ox + 6, _ty, "Player: " + string(round(obj_player.x)) + ", " + string(round(obj_player.y)) + "   HP " + string(obj_player.hp) + "/" + string(obj_player.max_hp), 0.6, 0.6, 0);
    }
    _ty += 15; draw_text_transformed(_ox + 6, _ty, "Gold " + string(global.save.gold) + "  SP " + string(global.save.sp) + "  ยา " + string(global.save.potions), 0.6, 0.6, 0);
    _ty += 15; draw_text_transformed(_ox + 6, _ty, "Browser: " + string(os_browser != browser_not_a_browser) + "   Debug hitbox: " + string(global.debug), 0.6, 0.6, 0);

    // ---- กราฟเวลาต่อเฟรม (เส้นขาว = 16.7ms = 60fps) ----
    var _gx = _ox + 6;
    var _gy = _oy + 178;     // ฐานกราฟ
    for (var _i = 0; _i < 120; _i++) {
        var _v = hist[(hpos + _i) mod 120];
        var _h = clamp(_v * 2, 0, 40);   // 20ms = สูง 40px
        draw_set_color(_v < 18 ? c_lime : (_v < 25 ? c_yellow : c_red));
        draw_rectangle(_gx + _i * 2.6, _gy - _h, _gx + _i * 2.6 + 1.8, _gy, false);
    }
    draw_set_color(c_white);
    draw_line(_gx, _gy - 33.4, _gx + 312, _gy - 33.4);
}

draw_set_color(c_white);