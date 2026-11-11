t++;
var _s = (1 - cos(2 * pi * t / period)) / 2;   // 0 -> 1 -> 0 แบบนุ่ม
var _nx = round(xstart + range_x * _s);
var _ny = round(ystart + range_y * _s);
var _dx = _nx - x;

// 1) จดว่าใครยืนอยู่บนแท่น:
//    ซ้อนกันในแนวนอน, เท้าอยู่ใกล้ผิวบน (ไม่เกิน 4-5px), และไม่ได้กระโดดขึ้น
var _me = id;

with (obj_player_ss) {
    carry_by = noone;
    if (vsp >= 0
        && bbox_right > _me.bbox_left && bbox_left < _me.bbox_right
        && bbox_bottom >= _me.bbox_top - 5 && bbox_bottom <= _me.bbox_top + 4) {
        carry_by = _me;
    }
}

with (obj_crate_ss) {
    carry_by = noone;
    if (vsp >= 0
        && bbox_right > _me.bbox_left && bbox_left < _me.bbox_right
        && bbox_bottom >= _me.bbox_top - 5 && bbox_bottom <= _me.bbox_top + 4) {
        carry_by = _me;
    }
}

// 2) ขยับแท่น
x = _nx;
y = _ny;

// 3) ให้คนบนแท่นเท้าติดผิวแท่นพอดี แล้วพาไปด้านข้างด้วย
with (obj_player_ss) {
    if (carry_by == _me) {
        y += _me.bbox_top - 1 - bbox_bottom;
        if (_dx != 0) move_and_collide(_dx, 0, global.ss_solids);
    }
}

with (obj_crate_ss) {
    if (carry_by == _me) {
        y += _me.bbox_top - 1 - bbox_bottom;
        if (_dx != 0) move_and_collide(_dx, 0, global.ss_solids);
    }
}