if (global.hitstop > 0) exit;   // hit-stop
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
        var _hit = false;

        // สี่เหลี่ยม (ท่าพุ่ง)
        if (variable_struct_exists(atk, "rects")) {
            var _pr = player_hurt_rect(_p);
            for (var _k = 0; _k < array_length(atk.rects); _k++) {
                var _r = atk.rects[_k];
                if (obb_hits_rect(x, y - lift, image_angle, _r[0], _r[1], _r[2], _r[3], _pr[0], _pr[1], _pr[2], _pr[3])) { _hit = true; break; }
            }
        }

        // วงกลม (ท่าอื่น)
        if (!_hit) {
            for (var _i = 0; _i < array_length(atk.circles); _i++) {
                var _c = atk.circles[_i];
                var _gx = x + lengthdir_x(_c[0], image_angle) + lengthdir_x(_c[1], image_angle + 90);
                var _gy = y + lengthdir_y(_c[0], image_angle) + lengthdir_y(_c[1], image_angle + 90);
                if (!wall_between(x, y, _gx, _gy) && player_hit_by_circle(_p, _gx, _gy - lift, _c[2])) { _hit = true; break; }
            }
        }

        if (_hit) {
            if (_p.is_invulnerable()) {
                // ★ กลิ้งผ่าน/อมตะตอนโดนท่านี้ = ท่านี้ "พลาด" ไปแล้ว ไม่โดนซ้ำตอน i-frame หมด
                // (เดิม hitbox ยังอยู่ต่อ พอกลิ้งจบแต่ท่ายังไม่จบก็โดน = หลบแล้วยังโดน)
                hit_done = true;
            } else {
                _p.take_damage(enemy_damage_calc(atk.dmg), owner.x, owner.y);   // ★ ดาเมจตามความยาก x ด่าน - เกราะ
                if (variable_struct_exists(atk, "fx")) player_add_status(atk.fx);   // ★ ติดสถานะ
                hit_done = true;
                owner.on_hit_player();
            }
        }
    }
}

if (age >= atk.active) instance_destroy();