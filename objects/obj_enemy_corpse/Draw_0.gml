if (spr < 0) exit;
// ล้มไปด้านหลัง (ตรงข้ามกับทิศที่หัน) แบบเด้งนิดหน่อยตอนกระแทกพื้น
var _k = min(1, t / fall_time);
var _e = 1 - power(1 - _k, 2);
var _ang = 90 * _e * flip;
var _hop = sin(_k * pi) * 6;
// สีมืดลงเมื่อตาย
var _c = merge_color(col, c_dkgray, 0.35 * _e);
draw_sprite_ext(spr, 0, round(x), round(y - _hop), dscale * flip, dscale * (1 - 0.15 * _e), _ang, _c, alpha);
