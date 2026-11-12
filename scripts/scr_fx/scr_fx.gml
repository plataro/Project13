// สร้างเลขดาเมจลอย (พิกัดโลก)
function spawn_damage_text(_x, _y, _value, _crit = false) {
    if (!global.show_dmg) return noone;   // ปิดในหน้าตั้งค่า
    var _t = instance_create_depth(_x, _y, -20000, obj_damage_text);
    _t.txt = string(_value) + (_crit ? "!" : "");
    var _heavy = (_value >= player_atk() * 2);   // แรงเกิน 2 เท่าของพลังโจมตี = ตัวใหญ่สีเหลือง
    _t.col = _crit ? make_color_rgb(255, 120, 30) : (_heavy ? c_yellow : c_white);
    _t.size = _crit ? 1.6 : (_heavy ? 1.4 : 1);
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

// ★ ฝุ่นตอนวิ่ง (วงกลมฟุ้ง ๆ ค่อยขยายแล้วจาง)
function fx_dust(_x, _y, _n = 1, _col = make_color_rgb(200, 190, 170), _vx = 0) {
    if (!instance_exists(obj_fx)) return;
    with (obj_fx) {
        if (array_length(parts) > 120) return;
        repeat (_n) {
            array_push(parts, { kind: 2, x: _x + random_range(-6, 6), y: _y + random_range(-2, 2),
                                vx: _vx + random_range(-0.5, 0.5), vy: random_range(-0.7, -0.2),
                                age: 0, life: irandom_range(18, 28), r: random_range(3, 6), col: _col });
        }
    }
}

// ตีศัตรูโดน (เรียกจาก take_damage ของศัตรู)
function fx_enemy_hit(_e, _dmg, _dir) {
    var _r = enemy_hurt_rect(_e);
    var _cx = (_r[0] + _r[2]) / 2;
    var _cy = (_r[1] + _r[3]) / 2;
    var _big = (_e.object_index == obj_enemy_boss);
    var _p = clamp(_dmg / max(1, player_atk()), 1, 6);   // วัดความแรงเทียบพลังโจมตี (ตัวเลขใหญ่แล้ว)
    fx_hitstop(_big ? 2 : 2 + min(_p, 3));
    fx_shake((_big ? 1.5 : 1) + _p * 0.5);
    fx_spark(_cx, _cy, _dir, 4 + _p * 2, (_p >= 3) ? c_yellow : c_white);
}

// =====================================================================
// ★ คอมโบ + ดาเมจรวม (ตีโดนต่อเนื่องภายใน ~2.5 วิ / โดนตีแล้วคอมโบขาด)
// =====================================================================
#macro COMBO_TIME 150
global.combo = { n: 0, dmg: 0, t: 0, pop: 0, fade: 0, brk: 0, best: 0 };
function combo_add(_dmg, _hit = true) {
    var _c = global.combo;
    if (!_hit) {   // ดาเมจต่อเนื่อง (ไฟ/พิษ): บวกเข้ายอดรวมเฉพาะตอนคอมโบยังไม่หมด ไม่ต่อเวลา
        if (_c.t > 0) _c.dmg += max(0, round(_dmg));
        return;
    }
    // ★ ตีโดน = เติมเกจไม้ตาย (ยกเว้นตอนกำลังปล่อยไม้ตายอยู่)
    if (variable_global_exists("ult_charge") && instance_exists(obj_player)) {
        with (obj_player) if (ult_unlocked && ult_fx <= 0) {
            var _was = global.ult_charge;
            global.ult_charge = min(100, global.ult_charge + ult_gain);
            if (_was < 100 && global.ult_charge >= 100) float_text(x, y - 120, L("ไม้ตายพร้อม! [", "Ultimate ready! [") + input_label("ult") + "]", make_color_rgb(255, 220, 120), 1.1);
        }
    }
    if (_c.t <= 0) { _c.n = 0; _c.dmg = 0; }   // คอมโบใหม่
    _c.n++;
    _c.pop = 1;
    _c.dmg += max(0, round(_dmg));
    _c.t = COMBO_TIME;
    _c.fade = 30;
    _c.brk = 0;
    _c.best = max(_c.best, _c.n);
}
function combo_break() {
    var _c = global.combo;
    if (_c.n >= 2 && _c.t > 0) _c.brk = 45;   // โชว์ "คอมโบขาด"
    _c.t = 0;
}
function combo_step() {
    var _c = global.combo;
    if (_c.t > 0) _c.t--;
    else if (_c.fade > 0) _c.fade--;
    if (_c.brk > 0) _c.brk--;
    _c.pop = max(0, _c.pop - 0.1);
}
// ใส่จุลภาคหลักพัน 12345 -> 12,345
function num_commas(_v) {
    var _s = string(floor(_v));
    var _out = "";
    var _n = string_length(_s);
    for (var _i = 1; _i <= _n; _i++) {
        _out += string_char_at(_s, _i);
        if ((_n - _i) mod 3 == 0 && _i < _n) _out += ",";
    }
    return _out;
}
// วาดตัวนับคอมโบ (ซ้ายกลางจอ ใต้ HUD ซ้ายบน ไม่ทับอะไร)
function draw_combo_hud() {
    var _c = global.combo;
    var _a = (_c.t > 0) ? 1 : _c.fade / 30;
    if (_c.brk > 0) _a = 1;
    if (_c.n < 2 || _a <= 0.01) return;
    draw_set_font(fnt_dialog);
    var _x = 22;
    var _y = 176;
    var _col = c_white;
    if (_c.n >= 50) _col = make_color_rgb(255, 90, 140);
    else if (_c.n >= 25) _col = make_color_rgb(255, 140, 60);
    else if (_c.n >= 10) _col = make_color_rgb(255, 220, 90);
    if (_c.brk > 0) _col = make_color_rgb(150, 150, 160);
    var _sh = (_c.brk > 0) ? irandom_range(-2, 2) : 0;
    var _s = 1.15 + 0.35 * _c.pop + min(0.35, _c.n * 0.006);
    var _oa = draw_get_alpha();
    draw_set_alpha(_a);
    draw_set_halign(fa_left);
    draw_set_valign(fa_bottom);
    // ตัวเลขใหญ่ + เรืองตอนเด้ง
    var _num = string(_c.n);
    if (_c.pop > 0.3) {
        gpu_set_blendmode(bm_add);
        draw_set_alpha(_a * 0.4 * _c.pop);
        draw_set_color(_col);
        draw_text_transformed(_x + _sh - 1, _y + 1, _num, _s * 1.06, _s * 1.06, 0);
        gpu_set_blendmode(bm_normal);
        draw_set_alpha(_a);
    }
    ui_text_bold(_x + _sh, _y, _num, _s, _col);
    var _nw = string_width(_num) * _s;
    ui_text_bold(_x + _nw + 8 + _sh, _y - 6, (_c.brk > 0) ? L("คอมโบขาด", "Combo broken") : L("คอมโบ", "Combo"), 0.5, (_c.brk > 0) ? make_color_rgb(255, 110, 110) : UI_GOLD);
    // เวลาที่เหลือ
    var _bw = 120;
    var _k = _c.t / COMBO_TIME;
    draw_set_color(c_black);
    draw_rectangle(_x, _y + 3, _x + _bw, _y + 7, false);
    draw_set_color(_col);
    if (_k > 0) draw_rectangle(_x, _y + 4, _x + _bw * _k, _y + 6, false);
    // ดาเมจรวม
    draw_set_valign(fa_top);
    ui_text(_x, _y + 11, L("ดาเมจรวม", "Total dmg"), 0.42, UI_MUTED);
    ui_text_bold(_x + 62, _y + 9, num_commas(_c.dmg), 0.5, make_color_rgb(255, 225, 160));
    draw_set_alpha(_oa);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}

// ศัตรูตาย
function fx_kill(_x, _y, _big) {
    fx_hitstop(_big ? 10 : 4);
    fx_shake(_big ? 9 : 3);
    fx_spark(_x, _y - 30, 0, _big ? 40 : 14, _big ? c_orange : c_ltgray, 180);
}

// ผู้เล่นโดนตี
function fx_player_hurt(_dmg) {
    combo_break();
    fx_hitstop(5);
    fx_shake(5 + min(_dmg, 3) * 1.2);
    global.hurt_flash = 1;
    if (instance_exists(obj_player)) fx_spark(obj_player.x, obj_player.y - 40, irandom(359), 8, c_red, 180);
}
