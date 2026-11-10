var _a = (age < life * 0.6) ? 1 : 1 - (age - life * 0.6) / (life * 0.4);
var _pop = 1 + max(0, 1 - age / 8) * 0.8;   // เด้งใหญ่ตอนเกิดแล้วหดลง
var _s = size * _pop;

draw_set_font(fnt_dialog);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_alpha(_a);

var _px = round(x);
var _py = round(y);

// ขอบดำ
draw_set_color(c_black);
draw_text_transformed(_px - 1, _py, txt, _s, _s, 0);
draw_text_transformed(_px + 1, _py, txt, _s, _s, 0);
draw_text_transformed(_px, _py - 1, txt, _s, _s, 0);
draw_text_transformed(_px, _py + 1, txt, _s, _s, 0);

draw_set_color(col);
draw_text_transformed(_px, _py, txt, _s, _s, 0);

draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);