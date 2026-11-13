// ==========================================
// ★ ตัวละครหลัก: ภาพนิ่ง 1 ภาพต่อทิศ + ท่าทางทำด้วยโค้ด
// ==========================================
var _s = global.pl_scale;
var _spd = point_distance(0, 0, mvx, mvy);
var _bd = pl_body(face);
var _spr = _bd[0];
var _flip = _bd[1];
var _ch = 10 * _s;              // ความสูงกลางลำตัวจากเท้า (ใช้หมุนตอนกลิ้ง)

if (!variable_instance_exists(id, "walk_t")) walk_t = 0;
if (_spd > 0.3 && state == PState.MOVE) walk_t += _spd * 0.09;
else walk_t = lerp(walk_t, round(walk_t / pi) * pi, 0.25);   // หยุดเดิน = กลับท่ายืนนุ่ม ๆ

// ค่าท่าทาง
var _bob = 0;      // ยกตัวขึ้น (px)
var _ang = 0;      // เอียงตัว (องศา)
var _xs = 1;       // ยืด/หดแนวนอน
var _ys = 1;       // ยืด/หดแนวตั้ง
var _ox = 0;       // เลื่อนตัวแนวนอน

var _running = (_spd > move_speed + 0.5);
if (state == PState.MOVE && _spd > 0.3) {
    // ★ เดิน = เด้งเป็นจังหวะก้าว + เอียงซ้ายขวา / วิ่ง = เด้งสูงขึ้นและเอนไปข้างหน้า
    _bob = abs(sin(walk_t)) * (_running ? 4 : 2.5) * _s * 0.5;
    _ang = sin(walk_t) * (_running ? 7 : 5);
    if (_running && (face == 0 || face == 2)) _ang -= 8 * _flip;
    _ys = 1 + abs(sin(walk_t)) * 0.05;
    _xs = 1 - abs(sin(walk_t)) * 0.04;
} else if (state == PState.MOVE) {
    // ยืนนิ่ง = หายใจเบา ๆ
    _ys = 1 + sin(current_time / 400) * 0.02;
}

// โดนตี: เอนหงาย + สั่น
var _hurt = (invuln_timer > invuln_time - 12);
if (_hurt) {
    _ang += 14 * -_flip;
    _ox = irandom_range(-2, 2);
}

// ฟัน: ย่อตัวตอนง้าง แล้วยืดพุ่งไปข้างหน้า
var _atk_k = (state == PState.ATTACK) ? clamp(1 - attack_timer / max(1, attack_total), 0, 1) : 0;
if (state == PState.ATTACK) {
    var _lean = (lengthdir_x(1, aim) >= 0) ? -1 : 1;
    if (_atk_k < 0.3) { _ys = 0.92; _xs = 1.06; }
    else { _ys = 1.05; _xs = 0.96; _ang = 8 * _lean * sin((_atk_k - 0.3) / 0.7 * pi); }
}
if (state == PState.CHARGE) {
    _ys = 0.9; _xs = 1.08;
    _ox = (charge_t >= charge_time) ? irandom_range(-1, 1) : 0;
}

// กลิ้ง: หมุนรอบกลางลำตัว 1 รอบ
var _roll = (state == PState.ROLL);
if (_roll) {
    var _rk = 1 - roll_timer / max(1, roll_time);
    _ang = -360 * _rk * ((dir_x >= 0) ? 1 : -1);
    _xs = 0.9; _ys = 0.9;
}

// ตำแหน่งวาด (หมุนรอบกลางลำตัว ไม่ใช่รอบเท้า)
var _cx = round(x) + _ox;
var _cy = round(y) - _ch - _bob;
var _dx = _cx + lengthdir_x(_ch * _ys, 270 + _ang);
var _dy = _cy + lengthdir_y(_ch * _ys, 270 + _ang);

// ==========================================
// AFTERIMAGE (กลิ้ง)
// ==========================================
if (_roll) {
    for (var i = 3; i >= 0; i--) {
        if (roll_echo_age[i] < 12) {
            var _alpha = 0.38 * (1 - roll_echo_age[i] / 12);
            draw_sprite_ext(_spr, 0, round(roll_echo_x[i]), round(roll_echo_y[i]),
                _s * _flip, _s, 0, make_color_rgb(175, 65, 255), _alpha);
        }
    }
}

// ==========================================
// SHADOW (เงาเล็กลงตอนตัวลอยขึ้น)
// ==========================================
var _sw = (bbox_right - bbox_left) * 0.75 * (1 - _bob / 40);
draw_shadow(x, y, _sw, _sw * 0.35);

if (global.debug) {
    var _r = player_hurt_rect(id);
    draw_set_color(c_lime);
    draw_rectangle(_r[0], _r[1], _r[2], _r[3], true);
    draw_set_color(c_white);
}

// INVULNERABILITY FLASH
if (invuln_timer > 0 && (invuln_timer div 4) mod 2 == 0) exit;

var _color = c_white;
if (_roll) _color = make_color_rgb(190, 115, 255);
if (_hurt) _color = make_color_rgb(255, 150, 150);

// ==========================================
// ★ อาวุธ: มุม + ระยะยื่น ตามท่า
// ==========================================
var _show_wpn = !_roll;
var _wang = (face == 2) ? 235 : 305;   // ถือห้อยไว้ข้างตัว
var _wreach = 0;
var _hside = -6;   // มือข้างที่ถืออาวุธ (หันขึ้น)
switch (face) {
    case 0: _hside = 5;  break;
    case 2: _hside = -5; break;
    case 3: _hside = 6;  break;
}
var _hx = _cx + _hside * _s;
var _hy = _cy + 2 * _s;
_wang += sin(walk_t) * 6;

if (state == PState.ATTACK) {
    _hx = _cx + lengthdir_x(4 * _s, aim);
    _hy = _cy + lengthdir_y(3 * _s, aim);
    var _k = _atk_k;
    if (combo == 0) {
        if (ult_fx > 0) {
            // ไม้ตาย: ชูอาวุธขึ้นฟ้า
            _wang = 90 + sin(current_time / 40) * 4;
            _hx = _cx; _hy = _cy - 4 * _s;
        } else {
            // สกิล 3 ดาบพายุหมุน: หมุนรอบตัวหลายรอบ
            _wang = aim - _k * 360 * max(1, skill3_spins);
            _wreach = 4 * _s;
        }
    } else {
        var _stepd = (global.save.weapon == "hammer") ? hammer_step_data(combo) : combo_step_data(combo);
        var _kind = _stepd.kind;
        var _sd = (combo mod 2 == 1) ? 1 : -1;   // ท่าคี่ฟันลง / ท่าคู่ฟันสวนขึ้น
        var _e = ease_out3((_k - 0.2) / 0.5);
        switch (_kind) {
            case "thrust":
                _wang = aim;
                _wreach = (_k < 0.25) ? -4 * _s : sin(clamp((_k - 0.25) / 0.6, 0, 1) * pi) * 14 * _s;
                break;
            case "spin":
                _wang = aim + 90 - ease_out3(_k / 0.8) * 400;
                _wreach = 3 * _s;
                break;
            case "smash":
                // ยกค้อนขึ้นหลังหัว แล้วทุบลงข้างหน้า
                var _up = 150;
                if (lengthdir_x(1, aim) < 0) _up = -150;
                if (_k < 0.45) _wang = lerp(aim, aim + _up, ease_out3(_k / 0.45));
                else _wang = lerp(aim + _up, aim - 10, ease_out3((_k - 0.45) / 0.15));
                break;
            case "hswing":
                _wang = (_k < 0.4) ? aim - 110 * ease_out3(_k / 0.4) : aim - 110 + 160 * ease_out3((_k - 0.4) / 0.2);
                break;
            case "quake":
                // ยกสูงเหนือหัว แล้วฟาดพื้นแรง ๆ
                _wang = (_k < 0.4) ? 90 : lerp(90, 270, ease_out3((_k - 0.4) / 0.12));
                _hx = _cx;
                break;
            default:   // slash
                _wang = aim + 100 * _sd - 200 * _sd * _e;
                if (_k < 0.2) _wang = aim + 100 * _sd + 15 * _sd * (_k / 0.2);
                _wreach = 2 * _s;
                break;
        }
    }
}
if (state == PState.CHARGE) {
    // ชาร์จค้อน: ยกค้างไว้หลังหัว สั่นเมื่อเต็ม
    var _cup = 150;
    if (lengthdir_x(1, aim) < 0) _cup = -150;
    _wang = aim + _cup;
    if (charge_t >= charge_time) _wang += irandom_range(-4, 4);
}

// หันขึ้น = อาวุธอยู่หลังตัว
var _wpn_behind = (face == 1 && state != PState.ATTACK) || (state == PState.ATTACK && lengthdir_y(1, _wang) < -0.3);
if (_show_wpn && _wpn_behind) pl_draw_weapon(_hx, _hy, _wang, _wreach, _color, 1);

// ==========================================
// DRAW PLAYER
// ==========================================
draw_sprite_ext(_spr, 0, _dx, _dy, _s * _flip * _xs, _s * _ys, _ang, _color, 1);

if (_show_wpn && !_wpn_behind) pl_draw_weapon(_hx, _hy, _wang, _wreach, _color, 1);

// ==========================================
// ★ เกจชาร์จค้อนบนหัว
// ==========================================
if (state == PState.CHARGE) {
    var _full = (charge_t >= charge_time);
    var _kk = charge_t / charge_time;
    var _gw = 56;
    var _gh = 8;
    var _gx = round(x - _gw / 2);
    var _gy = round(y - 26 * _s - 18);

    gpu_set_blendmode(bm_add);
    draw_sprite_ext(_spr, 0, _dx, _dy, _s * _flip * _xs, _s * _ys, _ang,
        _full ? c_yellow : c_orange, (_full ? 0.35 + 0.2 * sin(current_time / 60) : 0.25 * _kk));
    gpu_set_blendmode(bm_normal);

    draw_set_color(c_black);
    draw_rectangle(_gx - 2, _gy - 2, _gx + _gw + 1, _gy + _gh + 1, false);
    draw_set_color(c_dkgray);
    draw_rectangle(_gx, _gy, _gx + _gw - 1, _gy + _gh - 1, false);
    draw_set_color(_full ? ((current_time div 80) mod 2 == 0 ? c_white : c_yellow) : merge_color(c_orange, c_yellow, _kk));
    draw_rectangle(_gx, _gy, _gx + max(1, _gw * _kk) - 1, _gy + _gh - 1, false);
    if (_full) {
        draw_set_font(fnt_dialog);
        draw_set_halign(fa_center);
        draw_set_valign(fa_bottom);
        draw_set_color(c_yellow);
        draw_text_transformed(x, _gy - 2, L("ปล่อย!", "Release!"), 0.5, 0.5, 0);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
    draw_set_color(c_white);
}
