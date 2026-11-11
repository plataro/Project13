if (alpha <= 0) exit;

var _w = display_get_gui_width();
var _h = display_get_gui_height();
var _cy = _h * 0.38;

draw_set_font(fnt_dialog);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_alpha(alpha);

draw_set_color(c_black);
draw_text_transformed(_w / 2 + 2, _cy + 2, text, 1.8, 1.8, 0);
draw_set_color(c_white);
draw_text_transformed(_w / 2, _cy, text, 1.8, 1.8, 0);

var _tw = string_width(text) * 1.8;
draw_line_width(_w / 2 - _tw / 2, _cy + 36, _w / 2 + _tw / 2, _cy + 36, 2);

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);