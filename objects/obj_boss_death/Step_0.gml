t++;
var _cy = y - body_h * 0.5;

// ---- ช่วงดิ้น ----
if (t < t_burst) {
    var _k = t / t_burst;
    // ระเบิดย่อยถี่ขึ้นเรื่อย ๆ
    var _every = max(3, round(14 - 11 * _k));
    if (t mod _every == 0) {
        var _bx = x + random_range(-60, 60);
        var _by = _cy + random_range(-body_h * 0.5, body_h * 0.4);
        array_push(booms, { x: _bx, y: _by, r: random_range(18, 36) * (1 + _k), l: 18, l0: 18 });
        fx_spark(_bx, _by, random(360), 6, choose(c_orange, c_yellow, c_white), 180);
        fx_shake(1.5 + 3 * _k);
    }
    if (t mod 20 == 0) fx_shake(2);
}

// ---- ระเบิดใหญ่ ----
if (t == t_burst) {
    gui_flash = 1;
    fx_shake(16);
    fx_hitstop(14);
    fx_spark(x, _cy, 0, 60, c_white, 180);
    fx_spark(x, _cy, 0, 40, c_orange, 180);
    repeat (40) {
        var _a = random(360);
        var _s = random_range(4, 13);
        array_push(shards, { x: x, y: _cy, vx: lengthdir_x(_s, _a), vy: lengthdir_y(_s, _a) - 3, rot: random(360), vr: random_range(-14, 14), s: random_range(4, 10), l: irandom_range(60, 110) });
    }
}
if (t >= t_burst) ring += max(2, (t_burst + 60 - t) * 0.5);

// ---- ถ่านไฟ ----
if (t > t_burst && t < t_end - 40 && t mod 2 == 0) {
    repeat (2) array_push(embers, { x: x + random_range(-120, 120), y: y + random_range(-20, 10), vx: random_range(-0.4, 0.4), vy: random_range(-2.2, -0.8), l: irandom_range(50, 90) });
}

// ---- อัปเดตอนุภาค ----
for (var _i = array_length(booms) - 1; _i >= 0; _i--) { booms[_i].l--; if (booms[_i].l <= 0) array_delete(booms, _i, 1); }
for (var _j = array_length(shards) - 1; _j >= 0; _j--) {
    var _s2 = shards[_j];
    _s2.x += _s2.vx; _s2.y += _s2.vy; _s2.vy += 0.25; _s2.vx *= 0.98; _s2.rot += _s2.vr; _s2.l--;
    if (_s2.l <= 0) array_delete(shards, _j, 1);
}
for (var _e = array_length(embers) - 1; _e >= 0; _e--) {
    var _em = embers[_e];
    _em.x += _em.vx + sin((t + _e) / 12) * 0.3; _em.y += _em.vy; _em.l--;
    if (_em.l <= 0) array_delete(embers, _e, 1);
}
gui_flash = max(0, gui_flash - 0.025);

if (t >= t_end) instance_destroy();
