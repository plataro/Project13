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

// 2) กรอบข้อความ
draw_set_alpha(0.88);
draw_set_color(c_black);
draw_roundrect_ext(box[0], box[1], box[2], box[3], 10, 10, false);
draw_set_alpha(1);
draw_set_color(c_white);
draw_roundrect_ext(box[0], box[1], box[2], box[3], 10, 10, true);

// 3) ชื่อผู้พูด (ฝั่งขวาชิดขวา)
draw_set_color(c_yellow);
if (speaker == "right") {
    draw_set_halign(fa_right);
    draw_text_transformed(box[2] - 20, box[1] + 8, lines[index].name, 0.68, 0.68, 0);
    draw_set_halign(fa_left);
} else {
    draw_text_transformed(box[0] + 20, box[1] + 8, lines[index].name, 0.68, 0.68, 0);
}

// 4) ข้อความ
draw_set_color(c_white);
draw_text_transformed(box[0] + 20, box[1] + 34, string_copy(wrapped, 1, floor(chars)), text_scale, text_scale, 0);

// 5) ตัวเลือก
if (chars >= total && variable_struct_exists(lines[index], "choices")) {
    var _chs = lines[index].choices;
    var _ready = (choice_t >= choice_delay);
    var _fa = min(1, choice_t / choice_delay);   // ค่อย ๆ ปรากฏ (ช่วงนี้ยังกดไม่ได้)
    for (var _k = 0; _k < array_length(_chs); _k++) {
        var _by = choice_y0 + _k * choice_gap;
        var _on = _ready && (sel == _k);
        draw_set_alpha(0.92 * _fa);
        draw_set_color(_on ? make_color_rgb(60, 52, 20) : c_black);
        draw_roundrect_ext(choice_x1, _by, choice_x2, _by + choice_h, 10, 10, false);
        draw_set_alpha(_fa);
        draw_set_color(_on ? c_yellow : c_white);
        draw_roundrect_ext(choice_x1, _by, choice_x2, _by + choice_h, 10, 10, true);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text_transformed(480, _by + choice_h / 2, _chs[_k].t, 0.8, 0.8, 0);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
    draw_set_alpha(1);
    if (_ready) {
        draw_set_color(c_gray);
        draw_set_halign(fa_center);
        draw_text_transformed(480, choice_y0 + array_length(_chs) * choice_gap + 2, "คลิกเพื่อเลือก", 0.55, 0.55, 0);
        draw_set_halign(fa_left);
    }
    draw_set_color(c_white);
} else if (chars >= total && (current_time div 400) mod 2 == 0) {
    draw_text_transformed(box[2] - 22, box[3] - 26, ">", 0.7, 0.7, 0);
}