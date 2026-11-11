var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
var _gold = make_color_rgb(200, 170, 110);

draw_set_alpha(0.7);
draw_set_color(c_black);
draw_rectangle(0, 0, _gw, _gh, false);
draw_set_alpha(1);

draw_set_color(make_color_rgb(40, 34, 52));
draw_rectangle(px, py, px + pw, py + ph, false);
draw_set_color(_gold);
draw_rectangle(px, py, px + pw, py + ph, true);
draw_rectangle(px + 3, py + 3, px + pw - 3, py + ph - 3, true);

draw_set_font(fnt_dialog);
draw_set_valign(fa_middle);

// หัวข้อและแต้ม
draw_set_halign(fa_left);
draw_set_color(c_white);
draw_text(px + 24, py + 30, "ต้นไม้สกิล");
draw_set_halign(fa_right);
draw_set_color(c_yellow);
draw_text(px + pw - 24, py + 30, "แต้มสกิล: " + string(global.save.sp));

// หัวแต่ละสาย
draw_set_halign(fa_center);
for (var _b = 0; _b < 3; _b++) {
    draw_set_color(_gold);
    draw_text(col_x[_b], py + 72, branch_names[_b]);
}

// เส้นเชื่อม
for (var _i = 0; _i < array_length(nodes); _i++) {
    var _n1 = nodes[_i];
    if (_n1.req == "") continue;
    var _p1 = skill_find(_n1.req);
    var _ra = node_rect(_p1);
    var _rb = node_rect(_n1);
    if (skill_has(_n1.key)) draw_set_color(_gold);
    else if (skill_has(_n1.req)) draw_set_color(c_white);
    else draw_set_color(c_dkgray);
    draw_line_width((_ra[0] + _ra[2]) / 2, _ra[3], (_rb[0] + _rb[2]) / 2, _rb[1], 3);
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

    if (_has) draw_set_color(make_color_rgb(110, 90, 40));
    else if (_afford) draw_set_color(_hov ? make_color_rgb(90, 80, 112) : make_color_rgb(66, 58, 84));
    else draw_set_color(make_color_rgb(44, 40, 52));
    draw_rectangle(_rc[0], _rc[1], _rc[2], _rc[3], false);

    if (_has) draw_set_color(_gold);
    else if (_avail) draw_set_color(c_white);
    else draw_set_color(c_dkgray);
    draw_rectangle(_rc[0], _rc[1], _rc[2], _rc[3], true);

    draw_set_color((_has || _avail) ? c_white : c_gray);
    draw_text(_cx2, _rc[1] + 24, _nn.name);

    if (_has) draw_set_color(_gold);
    else draw_set_color(_afford ? c_yellow : c_gray);
    draw_text_transformed(_cx2, _rc[1] + 50, _has ? "ปลดแล้ว" : (string(_nn.cost) + " SP"), 0.65, 0.65, 0);
}

// คำอธิบายและข้อความแจ้งผล
if (hover_key != "") {
    var _hn = skill_find(hover_key);
    draw_set_color(c_white);
    draw_text_transformed(px + pw / 2, py + ph - 46, _hn.desc, 0.8, 0.8, 0);
} else {
    draw_set_color(c_gray);
    draw_text_transformed(px + pw / 2, py + ph - 46, "ชี้ที่สกิลเพื่อดูรายละเอียด · คลิกเพื่อปลด · T / Esc ปิด", 0.7, 0.7, 0);
}
if (msg != "") {
    draw_set_color(c_yellow);
    draw_text_transformed(px + pw / 2, py + ph - 20, msg, 0.8, 0.8, 0);
}


// ปุ่มปิด
draw_set_color(make_color_rgb(110, 60, 60));
draw_rectangle(px + pw - 164, py + ph - 52, px + pw - 24, py + ph - 14, false);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_text_transformed(px + pw - 94, py + ph - 33, "ปิด (T)", 0.8, 0.8, 0);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);