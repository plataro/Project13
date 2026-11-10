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
    var _bx = (_side == "left") ? 230 : 730;

    draw_sprite_ext(_spr, _emo, _bx + _s.ax, 450 + _bob, _sc * _fit * _mir, _sc * _fit, 0, _col, _s.alpha);
}

// 2) กรอบข้อความ
draw_set_alpha(0.88);
draw_set_color(c_black);
draw_rectangle(40, 360, 920, 520, false);
draw_set_alpha(1);
draw_set_color(c_white);
draw_rectangle(40, 360, 920, 520, true);

// 3) ชื่อผู้พูด (ฝั่งขวาชิดขวา)
draw_set_color(c_yellow);
if (speaker == "right") {
    draw_set_halign(fa_right);
    draw_text(900, 372, lines[index].name);
    draw_set_halign(fa_left);
} else {
    draw_text(60, 372, lines[index].name);
}

// 4) ข้อความ
draw_set_color(c_white);
draw_text(60, 408, string_copy(wrapped, 1, floor(chars)));

if (chars >= total && (current_time div 400) mod 2 == 0) {
    draw_text(890, 485, ">");
}