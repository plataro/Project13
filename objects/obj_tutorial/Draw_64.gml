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

// ===== หยุดรอกลิ้งหลบ (กลางจอ ไม่ทับช่องสกิล) =====
if (freeze) {
    var _fa = min(1, freeze_t / 10);
    draw_set_alpha(0.35 * _fa);
    draw_set_color(c_black);
    draw_rectangle(0, 0, 960, 540, false);
    draw_set_alpha(1);

    var _bob = sin(current_time / 150) * 3;
    var _py = 170 + (1 - _fa) * 20;
    ui_panel(270, _py, 690, _py + 120, _fa);
    draw_set_alpha(_fa);
    ui_text_bold(480, _py + 24, "ศัตรูกำลังจะโจมตี!", 0.8, make_color_rgb(255, 120, 100));

    // ปุ่ม Space
    draw_set_color(make_color_rgb(150, 120, 70));
    draw_rectangle(410, _py + 46 + _bob, 550, _py + 80 + _bob, false);
    draw_set_color(make_color_rgb(250, 235, 200));
    draw_rectangle(410, _py + 42 + _bob, 550, _py + 76 + _bob, false);
    draw_set_color(make_color_rgb(40, 30, 20));
    draw_text_transformed(480, _py + 59 + _bob, "Space", 0.7, 0.7, 0);

    ui_text(480, _py + 100, "กลิ้งหลบ  (กดทิศทางค้างไว้ = เลือกทางกลิ้ง)", 0.5, UI_MUTED);
    draw_set_alpha(1);
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
if (_slot_mode && ctx_a > 0.02 && is_undefined(global.boss_intro)) {
    var _r = hud_slot_rect(ctx.slot);
    var _scx = (_r[0] + _r[2]) / 2;
    var _done = (ctx_done > 0);
    var _gc = _done ? make_color_rgb(120, 240, 120) : UI_GOLD;
    var _pl = 0.5 + 0.5 * sin(current_time / 140);

    // กรอบเรืองรอบช่อง (ขยายเข้า-ออก)
    draw_set_alpha(ctx_a);
    draw_set_color(_gc);
    var _gr = 3 + 3 * _pl;
    draw_rectangle(_r[0] - _gr, _r[1] - _gr, _r[2] + _gr, _r[3] + _gr, true);
    draw_rectangle(_r[0] - _gr - 1, _r[1] - _gr - 1, _r[2] + _gr + 1, _r[3] + _gr + 1, true);
    gpu_set_blendmode(bm_add);
    draw_set_alpha(ctx_a * 0.18 * (0.6 + 0.4 * _pl));
    draw_rectangle(_r[0], _r[1], _r[2], _r[3], false);
    gpu_set_blendmode(bm_normal);

    // กล่องคำอธิบายเหนือช่อง + ลูกศรชี้ลง (เด้งขึ้นลง)
    var _s1 = 0.55;
    var _s2 = 0.42;
    var _kws = [];
    var _sumk = 0;
    for (var _k = 0; _k < array_length(ctx.keys); _k++) {
        _kws[_k] = max(26, string_width(ctx.keys[_k]) * _s1 + 14);
        _sumk += _kws[_k] + 6;
    }
    var _sub = variable_struct_exists(ctx, "sub") ? ctx.sub : "";
    var _w = max(_sumk + string_width(ctx.text) * _s1 + 30, string_width(_sub) * _s2 + 28);
    var _h = (_sub != "") ? 56 : 36;
    var _bob = sin(current_time / 200) * 3 * (1 - _done);
    var _ay = _r[1] - 12 + _bob - (1 - ctx_a) * 12;   // ปลายลูกศร
    var _by2 = _ay - 10;
    var _by1 = _by2 - _h;
    var _bx1 = clamp(_scx - _w / 2, 8, 952 - _w);
    ui_panel(_bx1, _by1, _bx1 + _w, _by2, ctx_a);
    draw_set_alpha(ctx_a);
    draw_set_color(_gc);
    draw_triangle(_scx - 9, _by2, _scx + 9, _by2, _scx, _ay, false);

    // ปุ่ม + ชื่อท่า
    var _ly = _by1 + 18;
    var _cx = _bx1 + 12;
    draw_set_valign(fa_middle);
    draw_set_halign(fa_center);
    for (var _k2 = 0; _k2 < array_length(ctx.keys); _k2++) {
        draw_set_color(_done ? make_color_rgb(40, 110, 50) : make_color_rgb(150, 120, 70));
        draw_rectangle(_cx, _ly - 10, _cx + _kws[_k2], _ly + 13, false);
        draw_set_color(_done ? make_color_rgb(150, 240, 150) : make_color_rgb(250, 235, 200));
        draw_rectangle(_cx, _ly - 12, _cx + _kws[_k2], _ly + 10, false);
        draw_set_color(make_color_rgb(40, 30, 20));
        draw_text_transformed(_cx + _kws[_k2] / 2, _ly - 1, ctx.keys[_k2], _s1, _s1, 0);
        _cx += _kws[_k2] + 6;
    }
    draw_set_halign(fa_left);
    ui_text_bold(_cx + 4, _ly, ctx.text, _s1, _done ? make_color_rgb(150, 255, 150) : UI_TEXT);
    if (_sub != "") ui_text(_bx1 + 12, _ly + 24, _sub, _s2, UI_MUTED);
    draw_set_halign(fa_center);
    draw_set_alpha(1);
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
