// เงาวงรีใต้ตัวละคร _w, _h คือรัศมี
function draw_shadow(_x, _y, _w, _h) {
    var _a = draw_get_alpha();
    var _c = draw_get_color();
    draw_set_alpha(0.3);
    draw_set_color(c_black);
    draw_ellipse(round(_x - _w), round(_y - _h), round(_x + _w), round(_y + _h), false);
    draw_set_alpha(_a);
    draw_set_color(_c);
}
// =====================================================================
// ★ UI กลาง (placeholder): สีธีม + กรอบ + ตัวหนา
// =====================================================================
#macro UI_GOLD make_color_rgb(222, 186, 112)
#macro UI_GOLD_DARK make_color_rgb(120, 92, 48)
#macro UI_BG make_color_rgb(22, 20, 32)
#macro UI_BG2 make_color_rgb(36, 32, 52)
#macro UI_TEXT make_color_rgb(236, 230, 218)
#macro UI_MUTED make_color_rgb(150, 144, 160)

// กรอบแผง: พื้นไล่สีเข้ม + ขอบทองสองชั้น + มุมเพชร   _a = ความทึบ
function ui_panel(_x1, _y1, _x2, _y2, _a = 1) {
    var _oa = draw_get_alpha();
    draw_set_alpha(0.93 * _a);
    draw_rectangle_color(_x1, _y1, _x2, _y2, UI_BG2, UI_BG2, UI_BG, UI_BG, false);
    draw_set_alpha(_a);
    draw_set_color(UI_GOLD_DARK);
    draw_rectangle(_x1, _y1, _x2, _y2, true);
    draw_set_color(UI_GOLD);
    draw_rectangle(_x1 + 3, _y1 + 3, _x2 - 3, _y2 - 3, true);
    // มุมเพชร
    var _pts = [[_x1, _y1], [_x2, _y1], [_x1, _y2], [_x2, _y2]];
    for (var _i = 0; _i < 4; _i++) {
        var _px = _pts[_i][0];
        var _py = _pts[_i][1];
        draw_set_color(UI_GOLD);
        draw_triangle(_px - 6, _py, _px + 6, _py, _px, _py - 6, false);
        draw_triangle(_px - 6, _py, _px + 6, _py, _px, _py + 6, false);
    }
    draw_set_alpha(_oa);
}

// ตัวหนาปลอม (วาดซ้อน 2 ครั้ง) + เงา
function ui_text_bold(_x, _y, _txt, _s, _col, _shadow = true) {
    var _oc = draw_get_color();
    if (_shadow) {
        draw_set_color(c_black);
        draw_text_transformed(_x + 1, _y + 2, _txt, _s, _s, 0);
        draw_text_transformed(_x + 2, _y + 2, _txt, _s, _s, 0);
    }
    draw_set_color(_col);
    draw_text_transformed(_x, _y, _txt, _s, _s, 0);
    draw_text_transformed(_x + 1, _y, _txt, _s, _s, 0);
    draw_set_color(_oc);
}

// ตัวธรรมดา + เงาบาง
function ui_text(_x, _y, _txt, _s, _col) {
    var _oc = draw_get_color();
    var _oa = draw_get_alpha();
    draw_set_color(c_black);
    draw_set_alpha(_oa * 0.6);
    draw_text_transformed(_x + 1, _y + 1, _txt, _s, _s, 0);
    draw_set_alpha(_oa);
    draw_set_color(_col);
    draw_text_transformed(_x, _y, _txt, _s, _s, 0);
    draw_set_color(_oc);
}

// แถบไฮไลต์รายการเมนู (ทองจาง + ขีดซ้าย)
function ui_highlight(_x1, _y1, _x2, _y2, _t = 1) {
    var _oa = draw_get_alpha();
    draw_set_alpha(0.22 * _t);
    draw_set_color(UI_GOLD);
    draw_rectangle(_x1, _y1, _x2, _y2, false);
    draw_set_alpha(_t);
    draw_rectangle(_x1, _y1, _x1 + 3, _y2, false);
    draw_set_alpha(_oa);
}

// ช่องสกิลสี่เหลี่ยม (HUD ล่างกลาง)
// _cd = 0 พร้อม .. 1 เพิ่งใช้ · _pop = เด้งตอนพร้อม (0-1) · _icon = ชนิดไอคอน · _locked = ยังใช้ไม่ได้
function ui_slot(_x, _y, _sz, _key, _icon, _cd, _pop, _locked, _count, _active) {
    var _s = _sz * (1 + 0.22 * sin(_pop * pi));
    var _cx = _x + _sz / 2;
    var _cy = _y + _sz / 2;
    var _x1 = _cx - _s / 2;
    var _y1 = _cy - _s / 2;
    var _x2 = _cx + _s / 2;
    var _y2 = _cy + _s / 2;
    // พื้น
    draw_set_alpha(0.85);
    draw_rectangle_color(_x1, _y1, _x2, _y2, UI_BG2, UI_BG2, UI_BG, UI_BG, false);
    draw_set_alpha(1);
    // ไอคอน
    var _ic = _locked ? make_color_rgb(70, 66, 80) : (_active ? c_yellow : UI_TEXT);
    ui_icon(_icon, _cx, _cy, _s * 0.34, _ic);
    // ทึบตามคูลดาวน์ (ไล่จากบนลงล่าง)
    if (_cd > 0 && !_locked) {
        draw_set_alpha(0.62);
        draw_set_color(c_black);
        draw_rectangle(_x1, _y1, _x2, _y1 + (_y2 - _y1) * _cd, false);
        draw_set_alpha(1);
    }
    // ขอบ + หลอดรอบ ๆ (เติมตามเวลาที่ฟื้นแล้ว)
    draw_set_color(_locked ? make_color_rgb(60, 56, 70) : UI_GOLD_DARK);
    draw_rectangle(_x1, _y1, _x2, _y2, true);
    if (!_locked) {
        var _prog = (_cd > 0) ? (1 - _cd) : 1;
        draw_set_color((_cd > 0) ? make_color_rgb(255, 170, 60) : (_active ? c_yellow : UI_GOLD));
        ui_rect_progress(_x1 - 2, _y1 - 2, _x2 + 2, _y2 + 2, _prog, 3);
    }
    // ปุ่ม
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_black);
    draw_rectangle(_cx - 15, _y2 - 2, _cx + 15, _y2 + 13, false);
    draw_set_color(_locked ? UI_MUTED : UI_GOLD);
    draw_text_transformed(_cx, _y2 + 5, _key, 0.42, 0.42, 0);
    // จำนวน
    if (_count != "") {
        draw_set_halign(fa_right);
        ui_text_bold(_x2 - 3, _y1 + 10, _count, 0.45, c_white);
    }
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}

// เส้นรอบสี่เหลี่ยมตามสัดส่วน (เริ่มมุมบนกลาง วนตามเข็ม)
function ui_rect_progress(_x1, _y1, _x2, _y2, _p, _w) {
    var _W = _x2 - _x1;
    var _H = _y2 - _y1;
    var _per = 2 * (_W + _H);
    var _len = _per * clamp(_p, 0, 1);
    var _cx = (_x1 + _x2) / 2;
    var _segs = [
        [_cx, _y1, _x2, _y1], [_x2, _y1, _x2, _y2], [_x2, _y2, _x1, _y2], [_x1, _y2, _x1, _y1], [_x1, _y1, _cx, _y1]
    ];
    for (var _i = 0; _i < 5 && _len > 0; _i++) {
        var _sg = _segs[_i];
        var _sl = point_distance(_sg[0], _sg[1], _sg[2], _sg[3]);
        var _k = min(1, _len / _sl);
        draw_line_width(_sg[0], _sg[1], lerp(_sg[0], _sg[2], _k), lerp(_sg[1], _sg[3], _k), _w);
        _len -= _sl;
    }
}

// ไอคอนวาดด้วยโค้ด (placeholder)
function ui_icon(_kind, _x, _y, _r, _c) {
    draw_set_color(_c);
    switch (_kind) {
        case "sword":
            draw_line_width(_x - _r * 0.8, _y + _r * 0.8, _x + _r * 0.8, _y - _r * 0.8, 4);
            draw_line_width(_x - _r * 0.6, _y + _r * 0.1, _x - _r * 0.1, _y + _r * 0.6, 4);
            break;
        case "hammer":
            draw_line_width(_x - _r * 0.6, _y + _r * 0.8, _x + _r * 0.3, _y - _r * 0.2, 4);
            draw_rectangle(_x - _r * 0.1, _y - _r * 0.9, _x + _r * 0.9, _y - _r * 0.1, false);
            break;
        case "charge":
            draw_circle(_x, _y, _r * 0.9, true);
            draw_circle(_x, _y, _r * 0.55, true);
            draw_circle(_x, _y, _r * 0.2, false);
            break;
        case "fire":
            draw_circle(_x - _r * 0.15, _y + _r * 0.2, _r * 0.55, false);
            draw_triangle(_x - _r * 0.7, _y + _r * 0.1, _x + _r * 0.4, _y + _r * 0.1, _x + _r * 0.6, _y - _r * 0.9, false);
            break;
        case "fire3":
            draw_circle(_x - _r * 0.6, _y + _r * 0.3, _r * 0.3, false);
            draw_circle(_x, _y - _r * 0.3, _r * 0.3, false);
            draw_circle(_x + _r * 0.6, _y + _r * 0.3, _r * 0.3, false);
            break;
        case "roll":
            draw_circle(_x, _y, _r * 0.75, true);
            draw_circle(_x, _y, _r * 0.7, true);
            draw_triangle(_x + _r * 0.5, _y - _r * 0.9, _x + _r * 1.0, _y - _r * 0.4, _x + _r * 0.35, _y - _r * 0.3, false);
            break;
        case "potion":
            draw_rectangle(_x - _r * 0.2, _y - _r * 0.9, _x + _r * 0.2, _y - _r * 0.45, false);
            draw_circle(_x, _y + _r * 0.2, _r * 0.62, false);
            break;
    }
}
