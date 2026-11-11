for (var _i = 0; _i < array_length(parts); _i++) {
    var _p = parts[_i];
    var _t = _p.age / _p.life;
    if (_p.kind == 0) {
        draw_set_alpha(1 - _t);
        draw_set_color(_p.col);
        draw_line_width(_p.x, _p.y, _p.x - _p.vx * _p.len, _p.y - _p.vy * _p.len, _p.w);
    } else {
        draw_sprite_ext(_p.spr, floor(_t * sprite_get_number(_p.spr)), _p.x, _p.y, 1, 1, _p.rot, c_white, 1);
    }
}
draw_set_alpha(1);
draw_set_color(c_white);