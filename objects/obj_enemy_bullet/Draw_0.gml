// ★ กระสุนศัตรู: ลูกพลังสีตามสถานะ (ไฟ = ส้ม, พิษ = เขียว, ปกติ = ม่วง)
var _c1 = make_color_rgb(170, 70, 255);
var _c2 = make_color_rgb(230, 190, 255);
if (fx == "burn")   { _c1 = make_color_rgb(255, 100, 30); _c2 = make_color_rgb(255, 220, 140); }
if (fx == "poison") { _c1 = make_color_rgb(90, 200, 60);  _c2 = make_color_rgb(200, 255, 170); }
var _cy = y - lift;
var _p = 1 + 0.15 * sin(current_time / 50 + id);
gpu_set_blendmode(bm_add);
draw_set_alpha(0.3);
draw_set_color(_c1);
draw_circle(x, _cy, 14 * _p, false);
draw_set_alpha(0.9);
draw_circle(x, _cy, 7 * _p, false);
draw_set_color(_c2);
draw_circle(x, _cy, 3.5, false);
draw_set_alpha(1);
gpu_set_blendmode(bm_normal);
draw_set_color(c_white);
