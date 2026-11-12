// ===== หมอกมืดนอกสายตา (obj_player > Post Draw = Draw_77.gml) =====
if (!fog_room()) exit;
if (instance_exists(obj_gameover)) exit;

var _fog_dark = 0.88;     // ★ ความมืดของโซนที่มองไม่เห็น (0-1)
// ★ ตอนเปิดตัวบอส: หมอกจางลงตามจังหวะกล้อง จะได้เห็นบอสแม้อยู่นอกสายตา
if (!is_undefined(global.boss_intro)) _fog_dark *= 1 - global.boss_intro.k;
with (obj_boss_death) _fog_dark *= 1 - 0.8 * clamp(min(t / 30, (t_end - t) / 40), 0, 1);   // ★ ตอนบอสตาย หมอกจาง เห็นเอฟเฟกต์ชัด
if (_fog_dark <= 0.01) exit;
var _rays = 256;          // ★ จำนวนเรย์ (เยอะขึ้น = ขอบเนียนขึ้น)
var _radius = FOG_RADIUS; // ★ ระยะมองไกลสุด (แก้ที่ scr_combat)
var _soft = 48;           // ★ ความกว้างขอบนุ่ม (px)
var _far = 1800;

// เก็บกรอบกำแพงทั้งห้องไว้ครั้งเดียวต่อห้อง
if (!variable_global_exists("fog_room") || global.fog_room != room) {
    global.fog_room = room;
    global.fog_walls = [];
    with (obj_wall) {
        array_push(global.fog_walls, [bbox_left, bbox_top, bbox_right + 1, bbox_bottom + 1]);
    }
}

fog_eye = fog_eye_calc(id);   // ชิดกำแพงบนแล้วไม่มองทะลุ
// ★ ตาที่ใช้วาดหมอก: ไหลตามนุ่ม ๆ (กันหมอกกระตุกตอนเปลี่ยนทิศ/ชิดกำแพง)
if (!variable_instance_exists(id, "fog_draw_eye") || fog_draw_room != room) {
    fog_draw_eye = [fog_eye[0], fog_eye[1]];
    fog_draw_room = room;
    fog_hd_prev = undefined;
}
var _ex = lerp(fog_draw_eye[0], fog_eye[0], 0.5);
var _ey = lerp(fog_draw_eye[1], fog_eye[1], 0.35);
if (point_distance(_ex, _ey, fog_eye[0], fog_eye[1]) > 40
    || collision_rectangle(_ex - 2, _ey - 2, _ex + 2, _ey + 2, obj_wall, false, true) != noone) {
    _ex = fog_eye[0];   // ห่างเกิน (วาร์ป) หรือไหลเข้าไปในกำแพง = ใช้ตาจริงเลย
    _ey = fog_eye[1];
}
fog_draw_eye = [_ex, _ey];
var _px = _ex;
var _py = _ey;

// เลือกเฉพาะกำแพงที่อยู่ใกล้
var _near = [];
var _wn = array_length(global.fog_walls);
for (var _w = 0; _w < _wn; _w++) {
    var _b = global.fog_walls[_w];
    if (_b[2] > _px - _radius && _b[0] < _px + _radius && _b[3] > _py - _radius && _b[1] < _py + _radius) {
        array_push(_near, _b);
    }
}
var _nn = array_length(_near);

var _hx = array_create(_rays + 1);
var _hy = array_create(_rays + 1);
var _hd = array_create(_rays + 1);

for (var _i = 0; _i <= _rays; _i++) {
    var _a = (_i / _rays) * 360;
    var _dx = lengthdir_x(1, _a);
    var _dy = lengthdir_y(1, _a);
    var _best = _radius;

    for (var _k = 0; _k < _nn; _k++) {
        var _r = _near[_k];
        var _t0 = 0;
        var _t1 = _best;
        var _ok = true;

        if (abs(_dx) < 0.00001) {
            if (_px < _r[0] || _px > _r[2]) _ok = false;
        } else {
            var _ta = (_r[0] - _px) / _dx;
            var _tb = (_r[2] - _px) / _dx;
            _t0 = max(_t0, min(_ta, _tb));
            _t1 = min(_t1, max(_ta, _tb));
        }
        if (_ok) {
            if (abs(_dy) < 0.00001) {
                if (_py < _r[1] || _py > _r[3]) _ok = false;
            } else {
                var _tc = (_r[1] - _py) / _dy;
                var _td = (_r[3] - _py) / _dy;
                _t0 = max(_t0, min(_tc, _td));
                _t1 = min(_t1, max(_tc, _td));
            }
        }
        if (_ok && _t0 <= _t1 && _t0 > 0.5 && _t0 < _best) _best = _t0;
    }

    // ★ ขยายออกนุ่ม ๆ (หดเข้าทันที กันมองทะลุกำแพง) = ขอบไม่กระพริบแตก
    if (is_array(fog_hd_prev) && array_length(fog_hd_prev) == _rays + 1 && _best > fog_hd_prev[_i]) {
        _best = lerp(fog_hd_prev[_i], _best, 0.45);
    }
    _hd[_i] = _best;
    _hx[_i] = _px + _dx * _best;
    _hy[_i] = _py + _dy * _best;
}

fog_hd_prev = _hd;

// แถบที่ 1: ขอบที่มองเห็น -> ความมืดเต็มที่ (ขอบนุ่ม)
draw_primitive_begin(pr_trianglestrip);
for (var _i = 0; _i <= _rays; _i++) {
    var _a2 = (_i / _rays) * 360;
    var _t = _hd[_i] / _radius;
    draw_vertex_color(_hx[_i], _hy[_i], c_black, _fog_dark * 0.9 * _t * _t);
    draw_vertex_color(_hx[_i] + lengthdir_x(_soft, _a2), _hy[_i] + lengthdir_y(_soft, _a2), c_black, _fog_dark);
}
draw_primitive_end();

// แถบที่ 2: มืดเต็มที่ไปจนสุดจอ
draw_primitive_begin(pr_trianglestrip);
for (var _i = 0; _i <= _rays; _i++) {
    var _a3 = (_i / _rays) * 360;
    draw_vertex_color(_hx[_i] + lengthdir_x(_soft, _a3), _hy[_i] + lengthdir_y(_soft, _a3), c_black, _fog_dark);
    draw_vertex_color(_px + lengthdir_x(_far, _a3), _py + lengthdir_y(_far, _a3), c_black, _fog_dark);
}
draw_primitive_end();

// ★ ศัตรูที่ "มองเห็นแล้ว" วาดตัวซ้ำทับหมอก
//   (เดิมยืนชิดกำแพงด้านบน ส่วนหัวเลยเส้นกำแพงเข้าไปในโซนมืด ตัวเลยมืดตามไปด้วย)
var _pl = id;
with (obj_enemy) {
    if (vis <= 0.02 || !variable_instance_exists(id, "fog_col")) continue;
    // ยืนซ้อนอยู่หลังผู้เล่น = ไม่วาดตัวซ้ำ (ตรงนั้นสว่างอยู่แล้ว และจะได้ไม่ทับตัวผู้เล่น)
    if (!(abs(x - _pl.x) < 60 && y < _pl.y && y > _pl.y - 140)) {
        draw_sprite_ext(sprite_index, image_index, round(x) + fog_ox, round(y - z), image_xscale, image_yscale, 0, fog_col, vis);
        if (flash > 3) {
            gpu_set_blendmode(bm_add);
            draw_sprite_ext(sprite_index, image_index, round(x) + fog_ox, round(y - z), image_xscale, image_yscale, 0, c_white, vis * 0.85);
            gpu_set_blendmode(bm_normal);
        }
    }
    enemy_draw_hpbar();   // ★ หลอดเลือดอยู่หน้าตัวศัตรูเสมอ
}
