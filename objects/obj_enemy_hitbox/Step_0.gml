age++;

if (!instance_exists(owner) || is_undefined(atk)) {
    instance_destroy();
    exit;
}

x = owner.x;
y = owner.y;
image_angle = owner.atk_dir;   // วงฟันหมุนตามผู้ฟัน

if (!hit_done && instance_exists(obj_player)) {
    var _p = obj_player;
    if (!wall_between(x, y, _p.x, _p.y)) {
        for (var _i = 0; _i < array_length(atk.circles); _i++) {
            var _c = atk.circles[_i];
            var _gx = x + lengthdir_x(_c[0], image_angle) + lengthdir_x(_c[1], image_angle + 90);
            var _gy = y + lengthdir_y(_c[0], image_angle) + lengthdir_y(_c[1], image_angle + 90);

            if (!wall_between(x, y, _gx, _gy) && player_hit_by_circle(_p, _gx, _gy - lift, _c[2])) {
                var _hp0 = _p.hp;
                var _dmg = ceil(atk.dmg * difficulty_data().enemy_dmg);   // ★ ดาเมจตามระดับความยาก
                _p.take_damage(_dmg, owner.x, owner.y);
                if (_p.hp < _hp0) {   // กลิ้งหลบอยู่จะไม่เสียเลือด hitbox ยังอยู่ต่อ
                    hit_done = true;
                    owner.on_hit_player();
                }
                break;
            }
        }
    }
}

if (age >= atk.active) instance_destroy();