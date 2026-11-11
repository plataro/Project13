// ★ ปรับตามระดับความยากครั้งเดียวตอนเกิด (ศัตรูลูกที่ตั้งค่าเลือดเองก็ถูกปรับด้วย)
if (!variable_instance_exists(id, "diff_applied")) {
    diff_applied = true;
    var _df = difficulty_data();
    hp = max(1, round(hp * _df.enemy_hp));
    max_hp = hp;
    hp_shown = hp;
    move_speed *= _df.enemy_speed;
    max_attackers = _df.attackers;
}

if (instance_exists(obj_dialogue) || instance_exists(obj_gameover) || instance_exists(obj_fade) || instance_exists(obj_skilltree)) exit;

if (flash > 0) flash--;

// ถ้ากล่องชนจมอยู่ในกำแพง ให้ดันออกมา
if (place_meeting(x, y, obj_wall)) {
    var _fixed = false;
    for (var _r = 2; _r <= 32 && !_fixed; _r += 2) {
        for (var _a = 0; _a < 360 && !_fixed; _a += 45) {
            var _tx = x + lengthdir_x(_r, _a);
            var _ty = y + lengthdir_y(_r, _a);
            if (!place_meeting(_tx, _ty, obj_wall)) {
                x = _tx;
                y = _ty;
                _fixed = true;
            }
        }
    }
}

hsp = 0;
vsp = 0;

ai();

// เลี้ยวหลบกำแพง (ไม่ทำตอนกำลังพุ่งโจมตี)
var _spd = point_distance(0, 0, hsp, vsp);
if (_spd > 0.1 && atk_state != "active") {
    var _look = _spd * 6;
    var _d0 = point_direction(0, 0, hsp, vsp);
    if (place_meeting(x + lengthdir_x(_look, _d0), y + lengthdir_y(_look, _d0), obj_wall)) {
        var _offs = [45, 90, 135];
        var _turned = false;
        for (var _i = 0; _i < 3 && !_turned; _i++) {
            for (var _sg = 0; _sg < 2 && !_turned; _sg++) {
                var _sign = (_sg == 0) ? strafe_sign : -strafe_sign;
                var _d1 = _d0 + _offs[_i] * _sign;
                if (!place_meeting(x + lengthdir_x(_look, _d1), y + lengthdir_y(_look, _d1), obj_wall)) {
                    hsp = lengthdir_x(_spd, _d1);
                    vsp = lengthdir_y(_spd, _d1);
                    _turned = true;
                }
            }
        }
    }
}

// แรงดันนุ่ม ๆ ให้กระจายตัวเป็นธรรมชาติ
var _px = 0;
var _py = 0;
with (obj_enemy) {
    if (id != other.id) {
        var _dd = point_distance(x, y, other.x, other.y);
        var _rr = max(sep_radius, other.sep_radius);
        if (_dd < _rr) {
            var _aa = (_dd == 0) ? irandom(359) : point_direction(x, y, other.x, other.y);
            var _w = (_rr - _dd) / _rr;
            _px += lengthdir_x(_w, _aa);
            _py += lengthdir_y(_w, _aa);
        }
    }
}
var _pm = point_distance(0, 0, _px, _py);
if (_pm > 1) {
    _px /= _pm;
    _py /= _pm;
}
hsp += _px * sep_strength;
vsp += _py * sep_strength;

move_and_collide(hsp + kb_x, vsp + kb_y, obj_wall);

// ไม่ยืนทับผู้เล่น (ยังชนทางกายภาพกับผู้เล่นไม่ได้ แต่ดันออกเบา ๆ)
if (instance_exists(obj_player)) {
    var _pd = point_distance(x, y, obj_player.x, obj_player.y);
    if (_pd < 40) {
        var _pa = point_direction(obj_player.x, obj_player.y, x, y);
        move_and_collide(lengthdir_x(2, _pa), lengthdir_y(2, _pa), obj_wall);
    }
}

// แยกตัวแบบแข็ง: ห้ามทับกัน ตัวหนักถูกดันน้อย ตัวเบาถูกดันมาก
var _me = id;
with (obj_enemy) {
    if (id != _me) {
        var _dist = point_distance(x, y, _me.x, _me.y);
        var _min = body_r + _me.body_r;
        if (_dist < _min) {
            var _ang = (_dist < 0.01) ? irandom(359) : point_direction(x, y, _me.x, _me.y);
            var _ov = _min - _dist;
            var _tm = mass + _me.mass;
            var _push_me = _ov * (mass / _tm);
            var _push_them = _ov * (_me.mass / _tm);

            move_and_collide(-lengthdir_x(_push_them, _ang), -lengthdir_y(_push_them, _ang), obj_wall);
            with (_me) {
                move_and_collide(lengthdir_x(_push_me, _ang), lengthdir_y(_push_me, _ang), obj_wall);
            }
        }
    }
}

// กันหลุดนอกห้อง
x = clamp(x, 0, room_width);
y = clamp(y, 0, room_height);

kb_x *= 0.8;
kb_y *= 0.8;
if (abs(kb_x) < 0.1) kb_x = 0;
if (abs(kb_y) < 0.1) kb_y = 0;

depth = -y;
if (hp <= 0) instance_destroy();