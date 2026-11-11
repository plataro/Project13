// ===== หมอกมืดนอกสายตา (obj_player > Post Draw = Draw_77.gml) =====
if (room != rm_level_1_the_forest && room != rm_level_2_the_abandoned_mine && room != rm_level_3_the_castle) exit;
if (instance_exists(obj_gameover)) exit;

var _fog_dark = 0.88;     // ★ ความมืดของโซนที่มองไม่เห็น (0-1)
var _rays = 160;          // ★ จำนวนเรย์
var _radius = 720;        // ★ ระยะมองไกลสุด
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

var _px = x;
var _py = y - 32;

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

    _hd[_i] = _best;
    _hx[_i] = _px + _dx * _best;
    _hy[_i] = _py + _dy * _best;
}

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