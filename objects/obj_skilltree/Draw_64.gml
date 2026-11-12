// ★ ต้นไม้สกิล (สไตล์ UI ใหม่ เล็กลง) — placeholder
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
open_t = min(1, open_t + 1 / 12);
var _ok = 1 - power(1 - open_t, 3);

draw_set_alpha(0.7 * _ok);
draw_set_color(c_black);
draw_rectangle(0, 0, _gw, _gh, false);
draw_set_alpha(1);

ui_panel(px, py, px + pw, py + ph, _ok);
draw_set_alpha(_ok);
draw_set_font(fnt_dialog);
draw_set_valign(fa_middle);

// หัวข้อ + แต้ม
draw_set_halign(fa_left);
ui_text_bold(px + 22, py + 24, L("ต้นไม้สกิล", "Skill Tree"), 0.66, UI_GOLD);
draw_set_halign(fa_right);
var _spp = 1 + 0.04 * sin(current_time / 200) * (global.save.sp > 0);
ui_text_bold(px + pw - 46, py + 24, L("แต้มสกิล  ", "Skill Points  ") + string(global.save.sp), 0.55 * _spp, make_color_rgb(255, 220, 90));
ui_icon("star", px + pw - 30, py + 24, 9, make_color_rgb(255, 220, 90));
draw_set_color(UI_GOLD_DARK);
draw_line(px + 20, py + 42, px + pw - 20, py + 42);

// หัวแต่ละสาย (ไอคอน + ชื่อ) และเส้นแนวตั้งจาง ๆ
draw_set_halign(fa_center);
for (var _b = 0; _b < 3; _b++) {
    var _bx = col_x[_b];
    draw_set_alpha(0.12 * _ok);
    draw_set_color(branch_col[_b]);
    draw_rectangle(_bx - node_w / 2 - 8, py + 54, _bx + node_w / 2 + 8, row_y0 + 4 * row_gap + node_h + 8, false);
    draw_set_alpha(_ok);
    ui_icon(branch_icon[_b], _bx - string_width(branch_names()[_b]) * 0.28 - 16, py + 68, 8, branch_col[_b]);
    ui_text_bold(_bx + 6, py + 68, branch_names()[_b], 0.55, branch_col[_b]);
}

// เส้นเชื่อม (ปลดแล้ว = ทองมีแสงวิ่ง)
for (var _i = 0; _i < array_length(nodes); _i++) {
    var _n1 = nodes[_i];
    if (_n1.req == "") continue;
    var _ra = node_rect(skill_find(_n1.req));
    var _rb = node_rect(_n1);
    var _lx = (_ra[0] + _ra[2]) / 2;
    if (skill_has(_n1.key)) {
        draw_set_color(UI_GOLD);
        draw_line_width(_lx, _ra[3], _lx, _rb[1], 3);
        var _fy = lerp(_ra[3], _rb[1], frac(current_time / 900 + _i * 0.17));
        draw_set_color(c_white);
        draw_circle(_lx, _fy, 2, false);
    } else {
        draw_set_color(skill_has(_n1.req) ? make_color_rgb(150, 140, 120) : make_color_rgb(50, 46, 60));
        draw_line_width(_lx, _ra[3], _lx, _rb[1], 2);
    }
}

// โหนด
for (var _j = 0; _j < array_length(nodes); _j++) {
    var _nn = nodes[_j];
    var _rc = node_rect(_nn);
    var _has = skill_has(_nn.key);
    var _avail = !_has && (_nn.req == "" || skill_has(_nn.req));
    var _afford = _avail && global.save.sp >= _nn.cost;
    var _hov = (hover_key == _nn.key);
    var _cx2 = (_rc[0] + _rc[2]) / 2;
    var _bc = branch_col[_nn.branch];

    // พื้น
    var _c1, _c2;
    if (_has) { _c1 = make_color_rgb(96, 76, 36); _c2 = make_color_rgb(60, 46, 22); }
    else if (_avail) { _c1 = _hov ? make_color_rgb(70, 62, 92) : UI_BG2; _c2 = UI_BG; }
    else { _c1 = make_color_rgb(26, 24, 32); _c2 = make_color_rgb(18, 16, 24); }
    draw_rectangle_color(_rc[0], _rc[1], _rc[2], _rc[3], _c1, _c1, _c2, _c2, false);

    // ขอบ: ปลดได้และพอแต้ม = เต้นเบา ๆ
    if (_has) draw_set_color(UI_GOLD);
    else if (_afford) draw_set_color(merge_color(UI_GOLD_DARK, c_white, 0.3 + 0.3 * sin(current_time / 180)));
    else if (_avail) draw_set_color(UI_GOLD_DARK);
    else draw_set_color(make_color_rgb(54, 50, 64));
    draw_rectangle(_rc[0], _rc[1], _rc[2], _rc[3], true);
    if (_hov) ui_highlight(_rc[0] + 1, _rc[1] + 1, _rc[2] - 1, _rc[3] - 1, 0.8);

    // แถบสีสายด้านซ้าย
    draw_set_color(_has ? _bc : merge_color(_bc, c_black, 0.6));
    draw_rectangle(_rc[0] + 1, _rc[1] + 1, _rc[0] + 4, _rc[3] - 1, false);

    ui_text_bold(_cx2, _rc[1] + 14, _nn.name, ui_fit(_nn.name, 0.48, node_w - 14), (_has || _avail) ? UI_TEXT : make_color_rgb(110, 105, 120), false);
    var _cc = _has ? UI_GOLD : (_afford ? make_color_rgb(255, 220, 90) : make_color_rgb(110, 105, 120));
    ui_text(_cx2, _rc[1] + 31, _has ? L("ปลดแล้ว", "Unlocked") : (string(_nn.cost) + " SP"), 0.4, _cc);
    if (!_has && !_avail) {   // ล็อก
        draw_set_color(make_color_rgb(90, 85, 100));
        draw_rectangle(_rc[2] - 16, _rc[1] + 8, _rc[2] - 8, _rc[1] + 15, false);
        draw_circle(_rc[2] - 12, _rc[1] + 8, 3, true);
    }
}

// คำอธิบาย
var _dy = py + ph - 64;
draw_set_color(UI_GOLD_DARK);
draw_line(px + 20, _dy - 16, px + pw - 20, _dy - 16);
draw_set_halign(fa_center);
if (hover_key != "") {
    var _hn = skill_find(hover_key);
    ui_text(px + pw / 2, _dy, _hn.desc, ui_fit(_hn.desc, 0.52, pw - 40), UI_TEXT);
} else {
    ui_text(px + pw / 2, _dy, L("ชี้ที่สกิลเพื่อดูรายละเอียด | คลิกเพื่อปลด | T / Esc ปิด", "Hover a skill for details | Click to unlock | T / Esc close"), 0.46, UI_MUTED);
}
if (msg != "") ui_text_bold(px + pw / 2 - 40, py + ph - 26, msg, 0.5, make_color_rgb(255, 225, 120));

// ปุ่มปิด
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
var _ch = point_in_rectangle(_mx, _my, close_x1, close_y1, close_x2, close_y2);
draw_set_color(_ch ? make_color_rgb(110, 54, 58) : make_color_rgb(80, 40, 44));
draw_rectangle(close_x1, close_y1, close_x2, close_y2, false);
draw_set_color(_ch ? UI_GOLD : UI_GOLD_DARK);
draw_rectangle(close_x1, close_y1, close_x2, close_y2, true);
ui_text((close_x1 + close_x2) / 2, (close_y1 + close_y2) / 2, L("ปิด (T)", "Close (T)"), 0.5, UI_TEXT);

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
