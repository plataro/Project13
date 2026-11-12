draw_set_font(fnt_dialog);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// ===== ★ การ์ดเปิดตัวบอส: แถบดำบนล่าง + แสงแดงเข้ม + ชื่อทอง + ลายประดับ =====
if (!is_undefined(global.boss_intro)) {
    var _bt = global.boss_intro.t;
    var _bk = clamp(min(_bt / 20, (180 - _bt) / 20), 0, 1);
    var _bar = 76 * _bk;
    var _crim = make_color_rgb(150, 20, 40);

    // ขอบจอมืด + แสงแดงจากล่าง
    draw_set_alpha(0.35 * _bk);
    draw_rectangle_color(0, 270, 960, 540, c_black, c_black, _crim, _crim, false);
    draw_set_alpha(1);

    // แถบดำ + เส้นทองบาง ๆ ที่ขอบใน
    draw_set_color(c_black);
    draw_rectangle(0, 0, 960, _bar, false);
    draw_rectangle(0, 540 - _bar, 960, 540, false);
    if (_bar > 2) {
        draw_set_alpha(_bk);
        draw_set_color(UI_GOLD_DARK);
        draw_line(0, _bar, 960, _bar);
        draw_line(0, 540 - _bar, 960, 540 - _bar);
        draw_set_alpha(1);
    }

    // ถ่านไฟลอยขึ้น
    for (var _e = 0; _e < 30; _e++) {
        var _ex = (_e * 97 + sin(_bt / 20 + _e) * 20) mod 960;
        var _ey = 540 - _bar - ((_bt * (1.2 + (_e mod 4) * 0.5) + _e * 43) mod (540 - _bar * 2));
        draw_set_alpha(_bk * (0.3 + 0.4 * (0.5 + 0.5 * sin(_bt / 6 + _e))));
        draw_set_color((_e mod 3 == 0) ? make_color_rgb(255, 200, 120) : make_color_rgb(255, 80, 50));
        draw_circle(_ex, _ey, 1 + (_e mod 3) * 0.7, false);
    }
    draw_set_alpha(1);

    var _ta = clamp(min((_bt - 35) / 15, (150 - _bt) / 15), 0, 1);
    if (_ta > 0) {
        var _ny = 392;
        var _spread = 1 - power(1 - _ta, 3);
        // แถบแสงหลังชื่อ
        draw_set_alpha(0.55 * _ta);
        draw_rectangle_color(0, _ny - 36, 480, _ny + 66, c_black, make_color_rgb(70, 10, 24), make_color_rgb(70, 10, 24), c_black, false);
        draw_rectangle_color(480, _ny - 36, 960, _ny + 66, make_color_rgb(70, 10, 24), c_black, c_black, make_color_rgb(70, 10, 24), false);
        draw_set_alpha(_ta);

        // เส้นประดับขยายออกจากกลาง + เพชร
        var _lw = 260 * _spread;
        draw_set_color(UI_GOLD);
        draw_line_width(480 - _lw, _ny + 30, 480 - 14, _ny + 30, 2);
        draw_line_width(480 + 14, _ny + 30, 480 + _lw, _ny + 30, 2);
        draw_triangle(480 - 8, _ny + 30, 480 + 8, _ny + 30, 480, _ny + 22, false);
        draw_triangle(480 - 8, _ny + 30, 480 + 8, _ny + 30, 480, _ny + 38, false);
        draw_triangle(480 - _lw - 6, _ny + 30, 480 - _lw, _ny + 26, 480 - _lw, _ny + 34, false);
        draw_triangle(480 + _lw + 6, _ny + 30, 480 + _lw, _ny + 26, 480 + _lw, _ny + 34, false);

        // ชื่อ: ตัวใหญ่สีทอง มีแสงแดงเรือง (ซูมเข้านิด ๆ)
        var _ns = 1.35 + 0.25 * (1 - _spread);
        gpu_set_blendmode(bm_add);
        draw_set_alpha(0.35 * _ta * (0.7 + 0.3 * sin(current_time / 140)));
        draw_set_color(make_color_rgb(200, 30, 40));
        for (var _g = 0; _g < 4; _g++) draw_text_transformed(480 + lengthdir_x(3, _g * 90), _ny + lengthdir_y(3, _g * 90), global.boss_intro.name, _ns, _ns, 0);
        gpu_set_blendmode(bm_normal);
        draw_set_alpha(_ta);
        ui_text_bold(480, _ny, global.boss_intro.name, _ns, make_color_rgb(255, 225, 160));

        // ฉายา
        draw_set_alpha(_ta * clamp((_bt - 50) / 15, 0, 1));
        ui_text(480, _ny + 52, "~  " + global.boss_intro.title + "  ~", 0.6, make_color_rgb(220, 170, 170));
        draw_set_alpha(1);
    }
}

// ===== ★ หยุดรอกลิ้งหลบ: ศัตรูกำลังฟัน เกมหยุด แล้วชี้ที่ช่อง Space ในแถบสกิล =====
if (freeze) {
    var _fa = min(1, freeze_t / 10);
    // ★ จอมืดทั้งจอ (ช่อง Space ยังเรืองเด่นจากกรอบที่ชี้)
    draw_set_alpha(0.4 * _fa);
    draw_set_color(c_black);
    draw_rectangle(0, 0, 960, 540, false);
    draw_set_alpha(1);
    ui_text_bold(480, 150, "ศัตรูกำลังจะโจมตี!", 0.85, make_color_rgb(255, 120, 100));
    tut_slot_callout(5, ["Space"], "กลิ้งหลบ", "ระหว่างกลิ้งจะไม่โดนโจมตี (กดทิศค้าง = เลือกทาง)", UI_MUTED, false, _fa, 0);
}

// ===== ข้อความสั้น =====
if (msg_t > 0 && is_undefined(global.boss_intro)) {
    var _ma = min(1, msg_t / 30);
    draw_set_alpha(_ma);
    ui_text_bold(480, 150, msg, 0.8, msg_col);
    draw_set_alpha(1);
}

// ===== ★ ป้ายสอนเล่น: ย้ายมาบนกลางจอ (ไม่ทับช่องสกิลด้านล่าง) =====
// ===== ★ สอนใช้สกิล: ชี้ที่ช่องสกิลล่างจอทีละอัน =====
var _slot_mode = !is_undefined(ctx) && variable_struct_exists(ctx, "slot") && ctx.slot >= 0 && instance_exists(obj_player);
if (_slot_mode && ctx_a > 0.02 && is_undefined(global.boss_intro) && !freeze) {
    var _sub = variable_struct_exists(ctx, "sub") ? ctx.sub : "";
    var _subc = UI_MUTED;
    if (ctx_tries > 0 && variable_struct_exists(ctx, "retry")) { _sub = ctx.retry; _subc = make_color_rgb(255, 150, 120); }
    tut_slot_callout(ctx.slot, ctx.keys, ctx.text, _sub, _subc, ctx_done > 0, ctx_a, ctx_shake);
}

if (!_slot_mode && !is_undefined(ctx) && ctx_a > 0.02 && is_undefined(global.boss_intro)) {
    var _y = 34 + (1 - ctx_a) * -16;
    var _s = 0.55;
    var _done = (ctx_done > 0);
    // ความกว้าง: ปุ่มแต่ละอัน + ข้อความ
    var _kws = [];
    var _sumk = 0;
    for (var _k = 0; _k < array_length(ctx.keys); _k++) {
        var _kw = max(26, string_width(ctx.keys[_k]) * _s + 14);
        _kws[_k] = _kw;
        _sumk += _kw + 6;
    }
    var _w = _sumk + string_width(ctx.text) * _s + 40;
    var _x1 = 480 - _w / 2;
    ui_panel(_x1, _y - 18, _x1 + _w, _y + 18, ctx_a);
    draw_set_alpha(ctx_a);
    var _cx = _x1 + 14;
    for (var _k2 = 0; _k2 < array_length(ctx.keys); _k2++) {
        draw_set_color(_done ? make_color_rgb(40, 110, 50) : make_color_rgb(150, 120, 70));
        draw_rectangle(_cx, _y - 10, _cx + _kws[_k2], _y + 13, false);
        draw_set_color(_done ? make_color_rgb(150, 240, 150) : make_color_rgb(250, 235, 200));
        draw_rectangle(_cx, _y - 12, _cx + _kws[_k2], _y + 10, false);
        draw_set_color(make_color_rgb(40, 30, 20));
        draw_text_transformed(_cx + _kws[_k2] / 2, _y - 1, ctx.keys[_k2], _s, _s, 0);
        _cx += _kws[_k2] + 6;
    }
    draw_set_halign(fa_left);
    ui_text(_cx + 6, _y, ctx.text, _s, _done ? make_color_rgb(150, 255, 150) : UI_TEXT);
    draw_set_halign(fa_center);
    draw_set_alpha(1);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
