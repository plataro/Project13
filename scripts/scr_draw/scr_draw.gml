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