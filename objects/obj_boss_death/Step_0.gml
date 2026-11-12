if (!inited) {
    inited = true;
    if (is_final) {
        t_burst = 280;                 // ดิ้นนานกว่า
        mini_bursts = [100, 190];      // ระเบิดกลางทาง 2 ครั้งก่อนระเบิดใหญ่
        t_text = t_burst + 70;
        t_fade = t_text + 170;         // ★ ข้อความ "ชัยชนะ" ค้างแล้วค่อย ๆ เฟดดำ
        t_end = t_fade + 130;
    } else {
        t_text = t_burst + 30;
        t_fade = -1;
    }
}
t++;
var _cy = y - body_h * 0.5;

// ---- ★ บอสสุดท้าย: ระเบิดกลางทาง + เสาแสง + พื้นสั่นตลอด ----
if (is_final && t < t_burst) {
    for (var _m = 0; _m < array_length(mini_bursts); _m++) {
        if (t == mini_bursts[_m]) {
            gui_flash = 0.55;
            fx_shake(9);
            fx_hitstop(8);
            array_push(rings, { r: 10, spd: 16, a: 0.8 });
            fx_spark(x, _cy, 0, 30, c_white, 180);
        }
    }
    if (t > t_burst - 90) pillar = min(1, pillar + 1 / 60);
    if (t mod 6 == 0) fx_shake(1 + 2 * (t / t_burst));
}

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
    fx_shake(is_final ? 24 : 16);
    fx_hitstop(is_final ? 24 : 14);
    array_push(rings, { r: 10, spd: 26, a: 1 });
    if (is_final) {
        array_push(rings, { r: -120, spd: 20, a: 1 });   // วงตามหลัง
        array_push(rings, { r: -260, spd: 15, a: 1 });
        repeat (40) {
            var _a2 = random(360);
            var _s2b = random_range(5, 16);
            array_push(shards, { x: x, y: _cy, vx: lengthdir_x(_s2b, _a2), vy: lengthdir_y(_s2b, _a2) - 4, rot: random(360), vr: random_range(-14, 14), s: random_range(5, 12), l: irandom_range(80, 140) });
        }
    }
    fx_spark(x, _cy, 0, 60, c_white, 180);
    fx_spark(x, _cy, 0, 40, c_orange, 180);
    repeat (40) {
        var _a = random(360);
        var _s = random_range(4, 13);
        array_push(shards, { x: x, y: _cy, vx: lengthdir_x(_s, _a), vy: lengthdir_y(_s, _a) - 3, rot: random(360), vr: random_range(-14, 14), s: random_range(4, 10), l: irandom_range(60, 110) });
    }
}
if (t >= t_burst) ring += max(2, (t_burst + 60 - t) * 0.5);
for (var _ri = array_length(rings) - 1; _ri >= 0; _ri--) {
    var _rg = rings[_ri];
    _rg.r += _rg.spd;
    _rg.spd = max(3, _rg.spd * 0.96);
    if (_rg.r > 0) _rg.a -= 0.012;
    if (_rg.a <= 0) array_delete(rings, _ri, 1);
}
if (is_final && t >= t_burst) pillar = max(0, pillar - 1 / 40);

// ---- ★ บอสสุดท้าย: เฟดดำแล้วไปฉากจบ ----
if (t_fade > 0 && t >= t_fade) {
    black = min(1, (t - t_fade) / 120);
    if (t >= t_end && !instance_exists(obj_fade)) {
        var _f = instance_create_depth(0, 0, -10000, obj_fade);
        _f.target_room = rm_end;
        _f.alpha = 1;   // มืดอยู่แล้ว ไปห้องจบเลย แล้วค่อยสว่างขึ้น
    }
}

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

if (t >= t_end && t_fade <= 0) instance_destroy();
