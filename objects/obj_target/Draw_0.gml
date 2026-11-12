if (hit_t > 0) hit_t--;
var _cy = y - 48;
// เงา
draw_set_alpha(0.3);
draw_set_color(c_black);
draw_ellipse(x - 18, y - 5, x + 18, y + 5, false);
draw_set_alpha(1);
var _s = 1 + hit_t / 40;

if (mode == "sword") {
    // ★ คริสตัล (ต้องฟัน): ฐานหิน + ผลึกเพชรลอย
    draw_set_color(make_color_rgb(80, 80, 96));
    draw_rectangle(x - 12, y - 12, x + 12, y, false);
    var _bob = sin(t / 20) * 3;
    var _cc = hit ? make_color_rgb(110, 255, 160) : make_color_rgb(140, 200, 255);
    gpu_set_blendmode(bm_add);
    draw_set_alpha(hit ? 0.5 : 0.25 + 0.1 * sin(t / 15));
    draw_set_color(_cc);
    draw_circle(x, _cy + _bob, 26 * _s, false);
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_color(_cc);
    draw_triangle(x, _cy - 22 * _s + _bob, x - 13 * _s, _cy + _bob, x + 13 * _s, _cy + _bob, false);
    draw_triangle(x - 13 * _s, _cy + _bob, x + 13 * _s, _cy + _bob, x, _cy + 18 * _s + _bob, false);
    draw_set_color(c_white);
    draw_triangle(x - 3, _cy - 12 + _bob, x - 8, _cy + _bob, x, _cy + _bob, false);
} else {
    // เป้ายิง: เสา + แผ่นเป้า
    draw_set_color(make_color_rgb(110, 75, 40));
    draw_rectangle(x - 4, _cy, x + 4, y, false);
    if (hit) {
        draw_set_color(make_color_rgb(90, 200, 90));
        draw_circle(x, _cy, 20 * _s, false);
        draw_set_color(c_white);
        draw_circle(x, _cy, 8, false);
    } else {
        draw_set_color(c_white);
        draw_circle(x, _cy, 20, false);
        draw_set_color(c_red);
        draw_circle(x, _cy, 14, false);
        draw_set_color(c_white);
        draw_circle(x, _cy, 8, false);
        draw_set_color(c_red);
        draw_circle(x, _cy, 3, false);
    }
}
// ★ เป้าจับเวลา: วงนับถอยหลังรอบเป้า (ใกล้หมด = แดง)
if (relock > 0 && hit && !locked_open) {
    var _k = lock_t / relock;
    draw_set_color((_k < 0.3) ? c_red : c_yellow);
    for (var _i = 0; _i < 20 * _k; _i++) {
        var _a = 90 - _i * 18;
        draw_circle(x + lengthdir_x(30, _a), _cy + lengthdir_y(30, _a), 2, false);
    }
}
// ★ ป้ายบอกวิธี (ยังไม่โดน): ไอคอนเล็ก ๆ ว่าต้องฟันหรือยิง
if (!hit && !locked_open) {
    var _iy = _cy - 40 + sin(t / 25) * 2;
    draw_set_alpha(0.85);
    ui_icon((mode == "sword") ? "sword" : "fire", x, _iy, 8, (mode == "sword") ? make_color_rgb(150, 220, 255) : make_color_rgb(255, 160, 80));
    draw_set_alpha(1);
}
draw_set_color(c_white);
