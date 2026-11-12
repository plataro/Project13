draw_set_font(fnt_dialog);

var _talking = (chars < total);
var _sides = ["left", "right"];

// 1) รูปตัวละคร (วาดก่อน เพื่อให้กรอบข้อความทับด้านล่าง)
for (var _i = 0; _i < 2; _i++) {
    var _side = _sides[_i];
    var _s = slots[$ _side];
    if (_s.who == "" || _s.alpha < 0.02) continue;

    var _cd = pdata[$ _s.who];
    if (is_undefined(_cd)) continue;

    var _spr = _cd.sprite;

    var _emo = _cd.emotions[$ _s.emo];
    if (is_undefined(_emo)) _emo = 0;

    var _fit = portrait_h / sprite_get_height(_spr);   // ★ ปรับขนาดให้สูงเท่ากันทุกรูป
    var _active = (speaker == _side);
    var _bob = (_active && _talking) ? sin(current_time / 90) * 3 : 0;
    var _sc = _active ? 1 : 0.95;
    var _col = _active ? c_white : make_color_rgb(110, 110, 125);
    var _mir = (_side == "right" && _cd.mirror_on_right) ? -1 : 1;
    var _bx = (_side == "left") ? 250 : 710;

    draw_sprite_ext(_spr, _emo, _bx + _s.ax, 450 + _bob, _sc * _fit * _mir, _sc * _fit, 0, _col, _s.alpha);
}

// ★ แอนิเมชันเปิดกล่อง (ลอยขึ้น + จางเข้า)
if (!variable_instance_exists(id, "open_t")) open_t = 0;
open_t = min(1, open_t + 1 / 14);
var _ok = 1 - power(1 - open_t, 3);
var _oy = (1 - _ok) * 36;
var _x1 = box[0];
var _y1 = box[1] + _oy;
var _x2 = box[2];
var _y2 = box[3] + _oy;
draw_set_alpha(_ok);

// 2) กรอบข้อความ: พื้นไล่สี + ขอบทอง + ลายมุม
draw_set_alpha(0.9 * _ok);
draw_rectangle_color(_x1, _y1, _x2, _y2, make_color_rgb(30, 26, 44), make_color_rgb(30, 26, 44), make_color_rgb(12, 10, 20), make_color_rgb(12, 10, 20), false);
draw_set_alpha(_ok);
draw_set_color(UI_GOLD_DARK);
draw_rectangle(_x1, _y1, _x2, _y2, true);
draw_set_color(UI_GOLD);
draw_rectangle(_x1 + 4, _y1 + 4, _x2 - 4, _y2 - 4, true);
var _corners = [[_x1, _y1], [_x2, _y1], [_x1, _y2], [_x2, _y2]];
for (var _c = 0; _c < 4; _c++) {
    var _cx = _corners[_c][0];
    var _cy = _corners[_c][1];
    draw_triangle(_cx - 7, _cy, _cx + 7, _cy, _cx, _cy - 7, false);
    draw_triangle(_cx - 7, _cy, _cx + 7, _cy, _cx, _cy + 7, false);
}
// ประกายแสงวิ่งผ่านขอบบนตอนเปิด
if (open_t < 1) {
    var _gx = lerp(_x1, _x2, open_t);
    gpu_set_blendmode(bm_add);
    draw_set_color(c_white);
    draw_rectangle(_gx - 30, _y1 - 1, _gx + 30, _y1 + 1, false);
    gpu_set_blendmode(bm_normal);
}

// 3) ป้ายชื่อผู้พูด (แท็บเหนือกรอบ ฝั่งเดียวกับคนพูด)
var _nm = lines[index].name;
if (_nm != "") {
    var _nw = string_width(_nm) * 0.62 + 34;
    var _nx1 = (speaker == "right") ? _x2 - 18 - _nw : _x1 + 18;
    var _ncol = (speaker == "right") ? make_color_rgb(120, 40, 50) : ((speaker == "left") ? make_color_rgb(40, 70, 120) : make_color_rgb(60, 56, 70));
    draw_set_color(_ncol);
    draw_rectangle(_nx1, _y1 - 22, _nx1 + _nw, _y1 + 4, false);
    draw_set_color(UI_GOLD);
    draw_rectangle(_nx1, _y1 - 22, _nx1 + _nw, _y1 + 4, true);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    ui_text_bold(_nx1 + _nw / 2, _y1 - 9, _nm, 0.62, make_color_rgb(255, 235, 180));
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// 4) ข้อความ (มีเงา)
draw_set_color(c_black);
draw_set_alpha(0.6 * _ok);
draw_text_transformed(_x1 + 23, _y1 + 23, string_copy(wrapped, 1, floor(chars)), text_scale, text_scale, 0);
draw_set_alpha(_ok);
draw_set_color(UI_TEXT);
draw_text_transformed(_x1 + 22, _y1 + 22, string_copy(wrapped, 1, floor(chars)), text_scale, text_scale, 0);
draw_set_alpha(1);

// 5) ตัวเลือก
if (chars >= total && variable_struct_exists(lines[index], "choices")) {
    var _chs = lines[index].choices;
    var _ready = (choice_t >= choice_delay);
    var _fa = min(1, choice_t / choice_delay);   // ค่อย ๆ ปรากฏ (ช่วงนี้ยังกดไม่ได้)
    for (var _k = 0; _k < array_length(_chs); _k++) {
        var _by = choice_y0 + _k * choice_gap;
        var _on = _ready && (sel == _k);
        var _sl = (1 - _fa) * 40 * ((_k mod 2 == 0) ? -1 : 1);   // เลื่อนเข้าจากข้าง
        draw_set_alpha(0.92 * _fa);
        draw_rectangle_color(choice_x1 + _sl, _by, choice_x2 + _sl, _by + choice_h, UI_BG2, UI_BG2, UI_BG, UI_BG, false);
        draw_set_alpha(_fa);
        if (_on) ui_highlight(choice_x1 + _sl + 2, _by + 2, choice_x2 + _sl - 2, _by + choice_h - 2, _fa);
        draw_set_color(_on ? UI_GOLD : UI_GOLD_DARK);
        draw_rectangle(choice_x1 + _sl, _by, choice_x2 + _sl, _by + choice_h, true);
        if (_on) {
            var _ax = choice_x1 + _sl + 18 + sin(current_time / 150) * 3;
            draw_triangle(_ax, _by + choice_h / 2 - 7, _ax, _by + choice_h / 2 + 7, _ax + 9, _by + choice_h / 2, false);
        }
        draw_set_color(_on ? make_color_rgb(255, 235, 180) : UI_TEXT);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text_transformed(480 + _sl, _by + choice_h / 2, _chs[_k].t, 0.72, 0.72, 0);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
    draw_set_alpha(1);
    if (_ready) {
        draw_set_color(c_gray);
        draw_set_halign(fa_center);
        draw_text_transformed(480, choice_y0 + array_length(_chs) * choice_gap + 2, L("คลิกเพื่อเลือก", "Click to choose"), 0.55, 0.55, 0);
        draw_set_halign(fa_left);
    }
    draw_set_color(c_white);
} else if (chars >= total) {
    // ★ สามเหลี่ยมเด้งบอกว่ากดต่อได้
    var _bb = abs(sin(current_time / 180)) * 5;
    draw_set_color(UI_GOLD);
    draw_triangle(_x2 - 30, _y2 - 22 + _bb, _x2 - 18, _y2 - 22 + _bb, _x2 - 24, _y2 - 14 + _bb, false);
}