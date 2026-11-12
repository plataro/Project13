// สร้างเลขดาเมจลอย (พิกัดโลก)
function spawn_damage_text(_x, _y, _value) {
    var _t = instance_create_depth(_x, _y, -20000, obj_damage_text);
    _t.txt = string(_value);
    var _heavy = (_value >= 2);
    _t.col = _heavy ? c_yellow : c_white;
    _t.size = _heavy ? 1.4 : 1;
    return _t;
}

// ข้อมูลท่าโจมตีของศัตรู ปรับเวลาเตรียมโจมตีตามระดับความยาก
function enemy_attack_data(_name) {
    var _a = enemy_attack_base(_name);
    if (is_undefined(_a)) return undefined;
    _a.windup = max(8, round(_a.windup * difficulty_data().windup));
    _a.lock = min(_a.lock, _a.windup - 4);   // ★ ยากแล้ว windup สั้นลง ให้ยังมีช่วงเล็งตามก่อนล็อก
    return _a;
}

// =====================================================================
// FEEDBACK การโจมตี (hit-stop, กล้องสั่น, ประกายตอนโดน, วาบแดงตอนผู้เล่นเจ็บ)
// ปรับ/ปิดได้ที่ตัวแปรด้านล่าง
// =====================================================================
global.fx_hitstop_on = true;    // false = ปิดการหยุดเฟรมตอนตีโดน
global.fx_shake_scale = 2.5;    // 0 = ปิดกล้องสั่น, 1 = เบา, 2.5 = ปกติ (ค่าตอนนี้), 4 = แรงมาก
global.hitstop = 0;             // เฟรมที่เหลือของการหยุด
global.hitstop_cd = 0;          // กันหยุดถี่เกินไป
global.shake = 0;               // ความแรงกล้องสั่นปัจจุบัน (พิกเซล)
global.hurt_flash = 0;          // วาบแดงตอนผู้เล่นโดนตี (0-1)

function fx_hitstop(_n) {
    if (!global.fx_hitstop_on) return;
    if (global.hitstop <= 0 && global.hitstop_cd <= 0) {
        global.hitstop = _n;
        global.hitstop_cd = _n + 8;
    }
}

function fx_shake(_a) {
    global.shake = max(global.shake, _a * global.fx_shake_scale);
}

// ประกายเป็นเส้นสั้นๆ พุ่งออกจากจุดที่โดน (_dir = ทิศหลัก, _spread = องศาที่กระจาย)
function fx_spark(_x, _y, _dir, _n, _col, _spread = 55) {
    if (!instance_exists(obj_fx)) return;
    with (obj_fx) {
        if (array_length(parts) > 90) return;
        var _spr = asset_get_index("spr_fx_hit");   // ใส่ภาพจริงชื่อนี้ได้ ถ้าไม่มีจะใช้เส้นประกายจากโค้ด
        if (_spr != -1 && sprite_exists(_spr)) {
            array_push(parts, { kind: 1, x: _x, y: _y, spr: _spr, age: 0, life: sprite_get_number(_spr) * 2, rot: _dir });
        }
        for (var _i = 0; _i < _n; _i++) {
            var _a = _dir + random_range(-_spread, _spread);
            var _s = random_range(3, 8);
            array_push(parts, { kind: 0, x: _x, y: _y, vx: lengthdir_x(_s, _a), vy: lengthdir_y(_s, _a),
                                 age: 0, life: irandom_range(8, 16), len: random_range(0.8, 1.8), w: choose(1, 2), col: _col });
        }
    }
}

// ตีศัตรูโดน (เรียกจาก take_damage ของศัตรู)
function fx_enemy_hit(_e, _dmg, _dir) {
    var _r = enemy_hurt_rect(_e);
    var _cx = (_r[0] + _r[2]) / 2;
    var _cy = (_r[1] + _r[3]) / 2;
    var _big = (_e.object_index == obj_enemy_boss);
    var _p = clamp(_dmg, 1, 6);
    fx_hitstop(_big ? 2 : 2 + min(_p, 3));
    fx_shake((_big ? 1.5 : 1) + _p * 0.5);
    fx_spark(_cx, _cy, _dir, 4 + _p * 2, (_p >= 3) ? c_yellow : c_white);
}

// ศัตรูตาย
function fx_kill(_x, _y, _big) {
    fx_hitstop(_big ? 10 : 4);
    fx_shake(_big ? 9 : 3);
    fx_spark(_x, _y - 30, 0, _big ? 40 : 14, _big ? c_orange : c_ltgray, 180);
}

// ผู้เล่นโดนตี
function fx_player_hurt(_dmg) {
    fx_hitstop(5);
    fx_shake(5 + min(_dmg, 3) * 1.2);
    global.hurt_flash = 1;
    if (instance_exists(obj_player)) fx_spark(obj_player.x, obj_player.y - 40, irandom(359), 8, c_red, 180);
}
