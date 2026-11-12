var _cy = y - body_h * 0.5;
var _k = min(1, t / t_burst);

// ---- ลำแสงหมุนพุ่งออกจากตัว (ก่อนระเบิด) ----
if (t < t_burst + 10) {
    var _n = is_final ? 18 : 10;
    var _len = (80 + 520 * _k) * (is_final ? 1.4 : 1);
    var _a0 = t * 1.2;
    gpu_set_blendmode(bm_add);
    for (var _i = 0; _i < _n; _i++) {
        if (_i / _n > _k * 1.4) continue;   // ค่อย ๆ เพิ่มจำนวนลำ
        var _a = _a0 + _i * (360 / _n) + sin(t / 10 + _i) * 6;
        var _w = 5 + 6 * _k;
        draw_set_alpha(0.25 + 0.3 * _k);
        draw_set_color(make_color_rgb(255, 200, 120));
        draw_triangle(x, _cy, x + lengthdir_x(_len, _a - _w), _cy + lengthdir_y(_len, _a - _w), x + lengthdir_x(_len, _a + _w), _cy + lengthdir_y(_len, _a + _w), false);
    }
    // แสงกลางตัว
    draw_set_alpha(0.3 + 0.5 * _k);
    draw_set_color(make_color_rgb(255, 160, 80));
    draw_circle(x, _cy, 40 + 60 * _k + sin(t / 3) * 6, false);
    draw_set_color(c_white);
    draw_circle(x, _cy, 16 + 30 * _k, false);
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
}

// ---- ตัวบอส: สั่นแรงขึ้น วาบขาว/แดง แล้วพองออกจางหายตอนระเบิด ----
if (spr != -1 && sprite_exists(spr) && t < t_burst + 14) {
    var _sh = 1 + 7 * _k;
    var _ox = irandom_range(-_sh, _sh);
    var _oy = irandom_range(-_sh, _sh) * 0.5;
    var _blink = ((t div max(2, round(8 - 6 * _k))) mod 2 == 0);
    var _c = _blink ? c_white : make_color_rgb(255, 80, 60);
    var _sc = 1;
    var _al = 1;
    if (t >= t_burst) { var _p = (t - t_burst) / 14; _sc = 1 + 0.6 * _p; _al = 1 - _p; _c = c_white; }
    draw_sprite_ext(spr, img, x + _ox, y + _oy, xs * _sc, ys * _sc, 0, col, _al);
    gpu_set_blendmode(bm_add);
    draw_sprite_ext(spr, img, x + _ox, y + _oy, xs * _sc, ys * _sc, 0, _c, _al * (0.4 + 0.5 * _k));
    gpu_set_blendmode(bm_normal);
}

// ---- ระเบิดย่อย ----
gpu_set_blendmode(bm_add);
for (var _b = 0; _b < array_length(booms); _b++) {
    var _bm = booms[_b];
    var _q = 1 - _bm.l / _bm.l0;
    draw_set_alpha(1 - _q);
    draw_set_color(make_color_rgb(255, 140, 50));
    draw_circle(_bm.x, _bm.y, _bm.r * (0.4 + _q), false);
    draw_set_color(c_white);
    draw_circle(_bm.x, _bm.y, _bm.r * 0.4 * (1 - _q), false);
}
gpu_set_blendmode(bm_normal);

// ---- คลื่นกระแทก (วงรีบนพื้น + วงอากาศ) ----
if (t >= t_burst && ring < 1400) {
    var _ra = clamp(1 - ring / 1400, 0, 1);
    draw_set_alpha(_ra);
    draw_set_color(make_color_rgb(255, 220, 160));
    for (var _w2 = 0; _w2 < 4; _w2++) draw_ellipse(x - ring - _w2, y - ring * 0.5 - _w2, x + ring + _w2, y + ring * 0.5 + _w2, true);
    draw_set_alpha(_ra * 0.6);
    draw_set_color(c_white);
    var _r2 = ring * 0.7;
    for (var _w3 = 0; _w3 < 3; _w3++) draw_circle(x, _cy, _r2 + _w3, true);
    draw_set_alpha(1);
}

// ---- ★ คลื่นกระแทกหลายวง ----
for (var _rr = 0; _rr < array_length(rings); _rr++) {
    var _rg = rings[_rr];
    if (_rg.r <= 0) continue;
    draw_set_alpha(clamp(_rg.a, 0, 1));
    draw_set_color(make_color_rgb(255, 210, 150));
    for (var _w4 = 0; _w4 < 3; _w4++) draw_ellipse(x - _rg.r - _w4, y - _rg.r * 0.5 - _w4, x + _rg.r + _w4, y + _rg.r * 0.5 + _w4, true);
}
draw_set_alpha(1);

// ---- ★ เสาแสงพุ่งขึ้นฟ้า (บอสสุดท้าย) ----
if (pillar > 0) {
    var _pw = 30 + 50 * pillar + sin(t / 3) * 6;
    gpu_set_blendmode(bm_add);
    draw_set_alpha(0.5 * pillar);
    draw_set_color(make_color_rgb(255, 190, 110));
    draw_rectangle(x - _pw, y - 2000, x + _pw, y, false);
    draw_set_alpha(0.7 * pillar);
    draw_set_color(c_white);
    draw_rectangle(x - _pw * 0.35, y - 2000, x + _pw * 0.35, y, false);
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
}

// ---- เศษ ----
for (var _s = 0; _s < array_length(shards); _s++) {
    var _sd = shards[_s];
    draw_set_alpha(min(1, _sd.l / 20));
    draw_set_color((_s mod 3 == 0) ? make_color_rgb(255, 200, 120) : make_color_rgb(90, 40, 60));
    var _cs = _sd.s;
    draw_triangle(_sd.x + lengthdir_x(_cs, _sd.rot), _sd.y + lengthdir_y(_cs, _sd.rot),
                  _sd.x + lengthdir_x(_cs, _sd.rot + 130), _sd.y + lengthdir_y(_cs, _sd.rot + 130),
                  _sd.x + lengthdir_x(_cs * 0.6, _sd.rot + 240), _sd.y + lengthdir_y(_cs * 0.6, _sd.rot + 240), false);
}

// ---- ถ่านไฟ ----
gpu_set_blendmode(bm_add);
for (var _e = 0; _e < array_length(embers); _e++) {
    var _em = embers[_e];
    draw_set_alpha(min(1, _em.l / 30) * 0.8);
    draw_set_color((_e mod 2 == 0) ? make_color_rgb(255, 170, 70) : make_color_rgb(255, 230, 160));
    draw_circle(_em.x, _em.y, 2, false);
}
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);
draw_set_color(c_white);
