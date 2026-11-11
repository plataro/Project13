if (global.hitstop > 0) global.hitstop--;
else if (global.hitstop_cd > 0) global.hitstop_cd--;

global.shake *= 0.86;
if (global.shake < 0.15) global.shake = 0;
global.hurt_flash = max(0, global.hurt_flash - 0.04);

// ประกาย: ค้างนิ่งตอน hit-stop แล้วค่อยพุ่งต่อ
var _n = array_length(parts);
for (var _i = _n - 1; _i >= 0; _i--) {
    var _p = parts[_i];
    if (global.hitstop <= 0) {
        _p.age++;
        if (_p.kind == 0) {
            _p.x += _p.vx;
            _p.y += _p.vy;
            _p.vx *= 0.86;
            _p.vy *= 0.86;
        }
    }
    if (_p.age >= _p.life) array_delete(parts, _i, 1);
}