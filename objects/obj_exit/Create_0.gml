next_room = level_next_room();
req_flag  = "";     // ถ้าใส่ชื่อธง ประตูจะล็อกจนกว่าธงนั้นจะเป็น true
set_flag  = "";     // ธงที่จะตั้งตอนเดินผ่านประตูนี้

// ระบบประตูเชื่อมห้อง
door_id    = "";    // ชื่อประตูนี้ ใช้เป็นจุดเกิดของคนที่เดินมาจากอีกฝั่ง (เช่น "village")
to_door    = "";    // ชื่อประตูปลายทางที่จะไปเกิด (ตรงกับ door_id ของประตูในห้องถัดไป) ว่าง = เกิดที่จุดเริ่มห้อง
spawn_dx   = 0;     // จุดเกิดเมื่อมาถึงประตูนี้ = ตำแหน่งประตู + (spawn_dx, spawn_dy)
spawn_dy   = 0;
ignore_boss = false; // true = ประตูกลับหมู่บ้าน ใช้ได้แม้บอสยังไม่ตาย
// ===== ★ ทางออกขอบฉาก (แทนประตู) =====
// เปิดช่องกำแพงจากจุดนี้ไปถึงขอบห้องอัตโนมัติ เดินเลยจุดนี้ไปทางขอบ = ไปพื้นที่ถัดไป
side = -1;          // ทิศขอบฉาก 0 = ขวา 1 = บน 2 = ซ้าย 3 = ล่าง (-1 = เลือกขอบที่ใกล้สุดเอง)
path_w = 96;        // ★ ครึ่งความกว้างทางเดิน
carved = false;
depth = 50;         // ทางเดินอยู่ใต้ตัวละคร
corr = [0, 0, 0, 0];
blocker = noone;
locked = false;
lock_msg = "";

// ตัดกำแพงที่ทับสี่เหลี่ยม _r ออก (แบ่งกำแพงเดิมเป็นชิ้นรอบ ๆ)
carve_rect = function(_r) {
    var _list = ds_list_create();
    var _n = collision_rectangle_list(_r[0] + 1, _r[1] + 1, _r[2] - 1, _r[3] - 1, obj_wall, false, true, _list, false);
    for (var _i = 0; _i < _n; _i++) {
        var _w = _list[| _i];
        if (_w.object_index != obj_wall) continue;   // ประตูกั้น/ตัวบล็อกไม่ตัด
        var _bl = _w.bbox_left;
        var _bt = _w.bbox_top;
        var _br = _w.bbox_right + 1;
        var _bb = _w.bbox_bottom + 1;
        var _pieces = [];
        if (_bt < _r[1]) array_push(_pieces, [_bl, _bt, _br, _r[1]]);
        if (_bb > _r[3]) array_push(_pieces, [_bl, _r[3], _br, _bb]);
        var _mt = max(_bt, _r[1]);
        var _mb = min(_bb, _r[3]);
        if (_mb > _mt) {
            if (_bl < _r[0]) array_push(_pieces, [_bl, _mt, _r[0], _mb]);
            if (_br > _r[2]) array_push(_pieces, [_r[2], _mt, _br, _mb]);
        }
        for (var _k = 0; _k < array_length(_pieces); _k++) {
            var _p = _pieces[_k];
            if (_p[2] - _p[0] < 2 || _p[3] - _p[1] < 2) continue;
            var _nw = instance_create_depth(_p[0], _p[1], 0, obj_wall);
            _nw.image_xscale = (_p[2] - _p[0]) / 64;
            _nw.image_yscale = (_p[3] - _p[1]) / 64;
            _nw.depth = -(_p[3]);
        }
        instance_destroy(_w);
    }
    ds_list_destroy(_list);
    global.fog_room = -1;   // ให้หมอกคำนวณกำแพงใหม่
}

carve = function() {
    carved = true;
    var _W = room_width;
    var _H = room_height;
    if (side < 0) {
        var _d = [_W - x, y, x, _H - y];
        side = 0;
        for (var _i = 1; _i < 4; _i++) if (_d[_i] < _d[side]) side = _i;
    }
    switch (side) {
        case 0: corr = [x - 40, y - path_w, _W, y + path_w]; break;
        case 1: corr = [x - path_w, 0, x + path_w, y + 40]; break;
        case 2: corr = [0, y - path_w, x + 40, y + path_w]; break;
        default: corr = [x - path_w, y - 40, x + path_w, _H]; break;
    }
    carve_rect(corr);
}

// ผู้เล่นเดินเลยจุดนี้ไปทางขอบแล้วหรือยัง
past_exit = function(_p) {
    if (!point_in_rectangle(_p.x, _p.y, corr[0] - 8, corr[1] - 8, corr[2] + 8, corr[3] + 8)) return false;
    switch (side) {
        case 0: return _p.x > x;
        case 1: return _p.y < y;
        case 2: return _p.x < x;
    }
    return _p.y > y;
}
