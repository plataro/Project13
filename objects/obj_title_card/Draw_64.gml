if (alpha <= 0) exit;
// ★ ชื่อพื้นที่ตอนเข้าห้อง (เล็กลง + เส้นทองสองข้าง)
var _cy = 150;
draw_set_font(fnt_dialog);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_alpha(alpha);
var _slide = (1 - alpha) * 20;
ui_text_bold(480, _cy - _slide, text, 1.05, UI_TEXT);
var _tw = string_width(text) * 1.05;
draw_set_color(UI_GOLD);
draw_line_width(480 - _tw / 2 - 70, _cy + 2, 480 - _tw / 2 - 16, _cy + 2, 2);
draw_line_width(480 + _tw / 2 + 16, _cy + 2, 480 + _tw / 2 + 70, _cy + 2, 2);
draw_triangle(480 - _tw / 2 - 10, _cy + 2, 480 - _tw / 2 - 16, _cy - 4, 480 - _tw / 2 - 16, _cy + 8, false);
draw_triangle(480 + _tw / 2 + 10, _cy + 2, 480 + _tw / 2 + 16, _cy - 4, 480 + _tw / 2 + 16, _cy + 8, false);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
