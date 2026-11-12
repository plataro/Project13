// ★ ลูกไฟ (placeholder วาดด้วยโค้ด): หางไฟ + แสงเรือง + แกนสว่าง
var _cx = x;
var _cy = y - lift;
var _fl = (1 + 0.12 * sin(current_time / 40 + id)) * size;   // ★ ขนาดตามระดับ
gpu_set_blendmode(bm_add);
for (var _i = 5; _i >= 1; _i--) {
    var _tx = _cx - lengthdir_x(_i * 6, direction);
    var _ty = _cy - lengthdir_y(_i * 6, direction);
    draw_set_alpha(0.22 * (1 - _i / 6));
    draw_set_color(make_color_rgb(255, 110, 30));
    draw_circle(_tx, _ty, (9 - _i) * _fl, false);
}
draw_set_alpha(0.35);
draw_set_color(make_color_rgb(255, 120, 40));
draw_circle(_cx, _cy, 15 * _fl, false);
draw_set_alpha(0.9);
draw_set_color(make_color_rgb(255, 190, 80));
draw_circle(_cx, _cy, 8 * _fl, false);
draw_set_color(make_color_rgb(255, 250, 220));
draw_circle(_cx, _cy, 4 * size, false);
draw_set_alpha(1);
gpu_set_blendmode(bm_normal);
draw_set_color(c_white);
