var _bx = 24;
var _by = 24;
var _bw = 200;
var _bh = 20;

// เลือด
draw_set_color(c_black);
draw_rectangle(_bx - 2, _by - 2, _bx + _bw + 2, _by + _bh + 2, false);
draw_set_color(c_red);
draw_rectangle(_bx, _by, _bx + _bw * (max(hp, 0) / max_hp), _by + _bh, false);

draw_set_font(fnt_dialog);

// สกิล 1: ช่องกระสุน 6 ช่อง
var _sy = 60;
draw_set_color(c_white);
draw_text_transformed(_bx, _sy - 5, "1", 0.6, 0.6, 0);
for (var _i = 0; _i < shot1_max; _i++) {
    var _px = _bx + 24 + _i * 22;
    draw_set_color(c_black);
    draw_rectangle(_px - 1, _sy - 1, _px + 16, _sy + 16, false);
    draw_set_color((_i < shot1_ammo) ? c_aqua : c_dkgray);
    draw_rectangle(_px, _sy, _px + 15, _sy + 15, false);
}
// แถบรีโหลด
if (shot1_reload_timer > 0) {
    var _rw = shot1_max * 22 - 6;
    draw_set_color(c_black);
    draw_rectangle(_bx + 23, _sy + 20, _bx + 25 + _rw, _sy + 26, false);
    draw_set_color(c_orange);
    draw_rectangle(_bx + 24, _sy + 21, _bx + 24 + _rw * (1 - shot1_reload_timer / shot1_reload), _sy + 25, false);
}

// สกิล 2: แถบคูลดาวน์
var _s2y = 96;
var _s2w = shot1_max * 22 - 6;
draw_set_color(c_white);
draw_text_transformed(_bx, _s2y - 5, "2", 0.6, 0.6, 0);
draw_set_color(c_black);
draw_rectangle(_bx + 23, _s2y - 1, _bx + 25 + _s2w, _s2y + 16, false);
var _ready = (skill2_timer <= 0);
draw_set_color(_ready ? c_yellow : c_gray);
draw_rectangle(_bx + 24, _s2y, _bx + 24 + _s2w * (_ready ? 1 : 1 - skill2_timer / skill2_cooldown), _s2y + 15, false);

draw_set_color(c_white);

// เหรียญ + ยา
draw_hud_money();