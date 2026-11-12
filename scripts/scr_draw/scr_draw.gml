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
        case "run":    // รองเท้า + เส้นความเร็ว
            draw_triangle(_x - _r * 0.2, _y - _r * 0.6, _x + _r * 0.5, _y - _r * 0.6, _x + _r * 0.15, _y + _r * 0.3, false);
            draw_rectangle(_x - _r * 0.3, _y + _r * 0.2, _x + _r * 0.9, _y + _r * 0.6, false);
            draw_line_width(_x - _r * 1.0, _y - _r * 0.3, _x - _r * 0.45, _y - _r * 0.3, 2);
            draw_line_width(_x - _r * 0.9, _y + _r * 0.05, _x - _r * 0.45, _y + _r * 0.05, 2);
            draw_line_width(_x - _r * 1.0, _y + _r * 0.4, _x - _r * 0.5, _y + _r * 0.4, 2);
            break;
        case "move":   // ลูกศร 4 ทิศ
            draw_triangle(_x, _y - _r, _x - _r * 0.35, _y - _r * 0.5, _x + _r * 0.35, _y - _r * 0.5, false);
            draw_triangle(_x, _y + _r, _x - _r * 0.35, _y + _r * 0.5, _x + _r * 0.35, _y + _r * 0.5, false);
            draw_triangle(_x - _r, _y, _x - _r * 0.5, _y - _r * 0.35, _x - _r * 0.5, _y + _r * 0.35, false);
            draw_triangle(_x + _r, _y, _x + _r * 0.5, _y - _r * 0.35, _x + _r * 0.5, _y + _r * 0.35, false);
            draw_circle(_x, _y, _r * 0.22, false);
            break;
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
        case "coin":
            draw_circle(_x, _y, _r * 0.8, false);
            draw_set_color(merge_color(_c, c_black, 0.35));
            draw_circle(_x, _y, _r * 0.5, true);
            break;
        case "gem":
            draw_triangle(_x, _y - _r * 0.9, _x - _r * 0.7, _y - _r * 0.2, _x + _r * 0.7, _y - _r * 0.2, false);
            draw_triangle(_x - _r * 0.7, _y - _r * 0.2, _x + _r * 0.7, _y - _r * 0.2, _x, _y + _r * 0.9, false);
            break;
        case "star":
            for (var _st = 0; _st < 5; _st++) {
                var _sa = 90 + _st * 72;
                draw_triangle(_x, _y, _x + lengthdir_x(_r, _sa), _y + lengthdir_y(_r, _sa), _x + lengthdir_x(_r * 0.4, _sa + 36), _y + lengthdir_y(_r * 0.4, _sa + 36), false);
                draw_triangle(_x, _y, _x + lengthdir_x(_r, _sa), _y + lengthdir_y(_r, _sa), _x + lengthdir_x(_r * 0.4, _sa - 36), _y + lengthdir_y(_r * 0.4, _sa - 36), false);
            }
            break;
        case "burn":
            draw_set_color(make_color_rgb(255, 120, 30));
            draw_circle(_x, _y + _r * 0.3, _r * 0.6, false);
            draw_triangle(_x - _r * 0.6, _y + _r * 0.2, _x + _r * 0.6, _y + _r * 0.2, _x, _y - _r, false);
            draw_set_color(make_color_rgb(255, 230, 120));
            draw_circle(_x, _y + _r * 0.4, _r * 0.3, false);
            break;
        case "poison":
            draw_set_color(make_color_rgb(140, 220, 90));
            draw_circle(_x, _y + _r * 0.3, _r * 0.6, false);
            draw_triangle(_x - _r * 0.55, _y + _r * 0.1, _x + _r * 0.55, _y + _r * 0.1, _x, _y - _r * 0.9, false);
            draw_set_color(make_color_rgb(40, 80, 30));
            draw_circle(_x - _r * 0.2, _y + _r * 0.3, _r * 0.12, false);
            draw_circle(_x + _r * 0.2, _y + _r * 0.3, _r * 0.12, false);
            break;
        case "stun":
            draw_set_color(c_yellow);
            var _sp = current_time / 4;
            for (var _sn = 0; _sn < 3; _sn++) {
                var _sa2 = _sp + _sn * 120;
                draw_circle(_x + lengthdir_x(_r * 0.7, _sa2), _y + lengthdir_y(_r * 0.35, _sa2), _r * 0.25, false);
            }
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


// =====================================================================
// ★ ป้ายกดปุ่มในโลก (หยิบดาบ / เปิดหีบ / บันได / ร้าน)  วาดใน Draw ปกติ
// =====================================================================
function ui_prompt(_x, _y, _key, _txt, _a = 1, _col = UI_GOLD) {
    if (_a < 0.02) return;
    draw_set_font(fnt_dialog);
    var _s = 0.5;
    var _kw = max(24, string_width(_key) * _s + 14);
    var _tw = string_width(_txt) * _s;
    var _w = _kw + _tw + 24;
    var _h = 30;
    var _bob = sin(current_time / 260) * 2;
    var _x1 = round(_x - _w / 2);
    var _y1 = round(_y - _h + _bob - (1 - _a) * 8);
    var _oa = draw_get_alpha();
    draw_set_alpha(0.85 * _a);
    draw_rectangle_color(_x1, _y1, _x1 + _w, _y1 + _h, UI_BG2, UI_BG2, UI_BG, UI_BG, false);
    draw_set_alpha(_a);
    draw_set_color(_col);
    draw_rectangle(_x1, _y1, _x1 + _w, _y1 + _h, true);
    draw_triangle(_x - 6, _y1 + _h, _x + 6, _y1 + _h, _x, _y1 + _h + 7, false);
    // ปุ่ม (นูนนิด ๆ)
    var _kx = _x1 + 7;
    var _ky = _y1 + 5;
    draw_set_color(make_color_rgb(150, 120, 70));
    draw_rectangle(_kx, _ky + 2, _kx + _kw, _ky + 21, false);
    draw_set_color(make_color_rgb(250, 235, 200));
    draw_rectangle(_kx, _ky, _kx + _kw, _ky + 18, false);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(make_color_rgb(40, 30, 20));
    draw_text_transformed(_kx + _kw / 2, _ky + 9, _key, _s, _s, 0);
    draw_set_halign(fa_left);
    ui_text(_kx + _kw + 8, _y1 + _h / 2, _txt, _s, UI_TEXT);
    draw_set_valign(fa_top);
    draw_set_alpha(_oa);
    draw_set_color(c_white);
}

// =====================================================================
// ★ ของที่ได้รับ: ป้ายเด้งเข้ามาขวาจอ ใต้แผงเงิน (ของชนิดเดียวกันรวมเป็น xN)
// =====================================================================
global.loot_feed = [];
function loot_toast(_txt, _col = c_white, _icon = "gem", _amt = 0) {
    for (var _i = 0; _i < array_length(global.loot_feed); _i++) {
        var _f = global.loot_feed[_i];
        if (_f.key == _txt && _f.t > 30) {
            _f.n++;
            _f.amt += _amt;
            _f.t = 200;
            _f.pop = 1;
            return;
        }
    }
    array_push(global.loot_feed, { key: _txt, txt: _txt, col: _col, icon: _icon, t: 200, n: 1, amt: _amt, pop: 1, sx: 1 });
    if (array_length(global.loot_feed) > 6) array_delete(global.loot_feed, 0, 1);
}
function draw_loot_feed(_ytop) {
    draw_set_font(fnt_dialog);
    var _y = _ytop;
    for (var _i = array_length(global.loot_feed) - 1; _i >= 0; _i--) {
        var _f = global.loot_feed[_i];
        _f.t--;
        _f.sx = lerp(_f.sx, 0, 0.2);
        _f.pop = max(0, _f.pop - 0.08);
        if (_f.t <= 0) { array_delete(global.loot_feed, _i, 1); continue; }
    }
    for (var _j = array_length(global.loot_feed) - 1; _j >= 0; _j--) {
        var _f2 = global.loot_feed[_j];
        var _a = min(1, _f2.t / 25);
        var _txt = (_f2.amt > 0) ? ("+" + string(_f2.amt) + " " + _f2.txt) : (_f2.txt + ((_f2.n > 1) ? "  x" + string(_f2.n) : ""));
        var _w = string_width(_txt) * 0.48 + 50;
        var _x2 = 946 + _f2.sx * 220;
        var _x1 = _x2 - _w;
        draw_set_alpha(0.8 * _a);
        draw_rectangle_color(_x1, _y, _x2, _y + 26, UI_BG, UI_BG2, UI_BG2, UI_BG, false);
        draw_set_alpha(_a);
        draw_set_color(_f2.col);
        draw_rectangle(_x1, _y, _x1 + 3, _y + 26, false);
        var _ir = 8 * (1 + 0.35 * sin(_f2.pop * pi));
        ui_icon(_f2.icon, _x1 + 20, _y + 13, _ir, _f2.col);
        draw_set_valign(fa_middle);
        ui_text(_x1 + 36, _y + 13, _txt, 0.48, merge_color(UI_TEXT, c_white, _f2.pop));
        draw_set_valign(fa_top);
        _y += 30;
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
}


// ★ ตำแหน่งช่องสกิลล่างจอ (ต้องตรงกับ obj_player Draw_64: ช่อง 48 ห่าง 12 จำนวน 7)
//   0 วิ่ง (Shift), 1 คลิก, 2 ค้าง, 3 ยิง, 4 สกิล 2, 5 กลิ้ง, 6 ยา, 7 แผงบัฟด้านขวา
function hud_slot_rect(_i) {
    var _sz = 48;
    var _gap = 12;
    var _x0 = 480 - (7 * _sz + 6 * _gap) / 2;
    var _y0 = 540 - _sz - 26;
    if (_i == 7) {
        var _fx = _x0 + 7 * (_sz + _gap) + 8;
        return [_fx, _y0 + 4, _fx + 150, _y0 + _sz - 4];
    }
    var _x = _x0 + _i * (_sz + _gap);
    return [_x, _y0, _x + _sz, _y0 + _sz];
}

// ★ กล่องสอนชี้ที่ช่องสกิล (กรอบเรือง + กล่องคำอธิบาย + ลูกศรชี้ลง)  วาดใน Draw GUI
function tut_slot_callout(_slot, _keys, _text, _sub, _subc, _done, _a, _shake = 0) {
    if (_a <= 0.02) return;
    draw_set_font(fnt_dialog);
    var _r = hud_slot_rect(_slot);
    var _scx = (_r[0] + _r[2]) / 2;
    var _gc = _done ? make_color_rgb(120, 240, 120) : UI_GOLD;
    var _pl = 0.5 + 0.5 * sin(current_time / 140);
    var _sx = (_shake > 0) ? irandom_range(-3, 3) : 0;

    // กรอบเรืองรอบช่อง
    draw_set_alpha(_a);
    draw_set_color(_gc);
    var _gr = 3 + 3 * _pl;
    draw_rectangle(_r[0] - _gr, _r[1] - _gr, _r[2] + _gr, _r[3] + _gr, true);
    draw_rectangle(_r[0] - _gr - 1, _r[1] - _gr - 1, _r[2] + _gr + 1, _r[3] + _gr + 1, true);
    gpu_set_blendmode(bm_add);
    draw_set_alpha(_a * 0.18 * (0.6 + 0.4 * _pl));
    draw_rectangle(_r[0], _r[1], _r[2], _r[3], false);
    gpu_set_blendmode(bm_normal);

    // กล่องเหนือช่อง
    var _s1 = 0.55;
    var _s2 = 0.42;
    var _kws = [];
    var _sumk = 0;
    for (var _k = 0; _k < array_length(_keys); _k++) {
        _kws[_k] = max(26, string_width(_keys[_k]) * _s1 + 14);
        _sumk += _kws[_k] + 6;
    }
    var _w = max(_sumk + string_width(_text) * _s1 + 30, string_width(_sub) * _s2 + 28);
    var _h = (_sub != "") ? 56 : 36;
    var _bob = _done ? 0 : sin(current_time / 200) * 3;
    var _ay = _r[1] - 12 + _bob - (1 - _a) * 12;
    var _by2 = _ay - 10;
    var _by1 = _by2 - _h;
    var _bx1 = clamp(_scx - _w / 2, 8, 952 - _w) + _sx;
    ui_panel(_bx1, _by1, _bx1 + _w, _by2, _a);
    draw_set_alpha(_a);
    draw_set_color(_gc);
    draw_triangle(_scx - 9, _by2, _scx + 9, _by2, _scx, _ay, false);

    var _ly = _by1 + 18;
    var _cx = _bx1 + 12;
    draw_set_valign(fa_middle);
    draw_set_halign(fa_center);
    for (var _k2 = 0; _k2 < array_length(_keys); _k2++) {
        draw_set_color(_done ? make_color_rgb(40, 110, 50) : make_color_rgb(150, 120, 70));
        draw_rectangle(_cx, _ly - 10, _cx + _kws[_k2], _ly + 13, false);
        draw_set_color(_done ? make_color_rgb(150, 240, 150) : make_color_rgb(250, 235, 200));
        draw_rectangle(_cx, _ly - 12, _cx + _kws[_k2], _ly + 10, false);
        draw_set_color(make_color_rgb(40, 30, 20));
        draw_text_transformed(_cx + _kws[_k2] / 2, _ly - 1, _keys[_k2], _s1, _s1, 0);
        _cx += _kws[_k2] + 6;
    }
    draw_set_halign(fa_left);
    ui_text_bold(_cx + 4, _ly, _text, _s1, _done ? make_color_rgb(150, 255, 150) : UI_TEXT);
    if (_sub != "") ui_text(_bx1 + 12, _ly + 24, _sub, _s2, _subc);
    draw_set_halign(fa_center);
    draw_set_alpha(1);
}
