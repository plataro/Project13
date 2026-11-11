var _zz = z;
if (kind != "gold") _zz += 6 + sin(current_time / 220 + bob) * 2;   // ของสะสมลอยขึ้นลง

draw_shadow(x, y, 8, 3);

var _col = c_yellow;
var _spr = -1;
if (kind == "potion") {
    _col = c_red;
} else if (kind != "gold") {
    var _item = item_data(kind);
    if (!is_undefined(_item)) {
        _col = _item.col;
        _spr = _item.spr;
    }
}

if (_spr != -1) {
    draw_sprite(_spr, 0, round(x), round(y - _zz));
} else {
    var _r = (kind == "gold") ? 5 : 7;
    var _cx = round(x);
    var _cy = round(y - _zz - 6);
    draw_set_color(c_black);
    draw_circle(_cx, _cy, _r + 1, false);
    draw_set_color(_col);
    draw_circle(_cx, _cy, _r, false);
    if (kind == "gold") {
        draw_set_color(c_orange);
        draw_circle(_cx, _cy, 2, false);
    }
    draw_set_color(c_white);
}