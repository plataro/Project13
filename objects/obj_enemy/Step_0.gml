if (hit_recover > 0) hit_recover--;

// ★ ปรับตามระดับความยากครั้งเดียวตอนเกิด (ศัตรูลูกที่ตั้งค่าเลือดเองก็ถูกปรับด้วย)
if (!variable_instance_exists(id, "diff_applied")) {
    diff_applied = true;
    var _df = difficulty_data();
    var _tr = tier_data();
    var _hpm = (object_index == obj_enemy_boss) ? _tr.boss_hp : _tr.hp;
    if (variable_instance_exists(id, "hp_mult")) _hpm *= hp_mult;   // ★ ยักษ์เลือดเยอะกว่า   // บอสตั้งเลือดเองใน Creation Code
    if (object_index == obj_enemy_boss) _hpm *= _df.boss_hp;   // ★ บอสเลือดเยอะขึ้นตามความยาก
    hp = max(1, round(hp * _df.enemy_hp * _hpm * DMG_UNIT * enemy_power_mult()));   // ★ เลือดคูณตัวเลขดาเมจใหม่
    max_hp = hp;
    hp_shown = hp;
    move_speed *= _df.enemy_speed * _tr.speed;
    max_attackers = _df.attackers + _tr.attackers;
}

if (instance_exists(obj_dialogue) || instance_exists(obj_gameover) || instance_exists(obj_fade) || instance_exists(obj_skilltree) || instance_exists(obj_status)) exit;
if (global.hitstop > 0) exit;   // hit-stop
if (object_index == obj_enemy_boss) {
    boss_check_intro();   // ★ เปิดตัวบอสตอนผู้เล่นเข้าห้องบอส
    // ★ แก้บัค: ก่อนคัทซีนเปิดตัว บอสต้องยืนนิ่งรอในห้องตัวเอง
    //   (เดิม zone ใน Creation Code กว้างกว่า arena ที่ใช้เช็กเปิดตัว -> ผู้เล่นยืนแก้พัซเซิลคริสตัล
    //    อยู่ในเขต zone แต่ยังไม่เข้า arena = บอสตื่นมาเดินไล่ แล้วกระโดดใส่ก่อนคัทซีน/หลอดเลือดขึ้น)
    if (!intro_done) {
        alert_timer = 0;
        engaged = false;
        far_timer = 0;
        wall_t = 0;
        hsp = 0;
        vsp = 0;
        kb_x = 0;
        kb_y = 0;
        if (flash > 0) flash--;
        depth = -y;
        exit;
    }
}

if (flash > 0) flash--;

// ---- หลับ: ไกลผู้เล่นมากและไม่ได้ไล่อยู่ = ไม่ทำอะไรเลย (ประหยัดเฟรมมาก) ----
var _pdist = dist_to_player();
if (_pdist > 1200 && alert_timer <= 0 && atk_state == "") {
    los_clear = false;
    vis = 0;
    hsp = 0;
    vsp = 0;
    depth = -y;
    if (hp <= 0) instance_destroy();
    exit;
}

var _in_zone = true;
if (!is_undefined(zone) && instance_exists(obj_player)) {
    _in_zone = point_in_rectangle(obj_player.x, obj_player.y, zone[0], zone[1], zone[2], zone[3]);
}

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

// ---- เช็กสายตา (แคช) + ความจำ ----
los_timer--;
if (los_timer <= 0) {
        los_timer = (_pdist < 700) ? 2 : 8;
    los_clear = (_pdist < 1200) && los_check();
}
if (los_clear && _pdist <= sight_range && _in_zone) {
    alert_timer = 150;
    engage();   // เพิ่งเห็นผู้เล่น = เริ่มช่วงรอจังหวะแรก
}
else if (alert_timer > 0) alert_timer--;
if (!_in_zone) alert_timer = 0;   // ผู้เล่นอยู่นอกถิ่นของตัวนี้ = เลิกไล่

hsp = 0;
vsp = 0;

// นับถอยหลังช่วงรอเฉพาะตอนผู้เล่นประชิดแล้ว (เดินเข้าหาอยู่ = ยังไม่นับ)
if (engage_grace > 0 && alert_timer > 0 && _pdist <= engage_range) engage_grace--;

// ★ สถานะผิดปกติ: ไฟไหม้/พิษ ดาเมจต่อเนื่อง
if (st_burn > 0) {
    st_burn--;
    if (st_burn mod 30 == 0) enemy_status_damage(id, 0.25, c_orange);
}
if (st_poison > 0) {
    st_poison--;
    if (st_poison mod 45 == 0) enemy_status_damage(id, 0.15, make_color_rgb(140, 220, 90));
}

var _busy = (atk_state != "") || (variable_instance_exists(id, "state") && state != "chase");
if (st_stun > 0) {
    st_stun--;   // ★ สตัน: ไม่ทำอะไร
} else if (alert_timer > 0 || _busy) {
    ai();
    if (st_poison > 0) { hsp *= 0.7; vsp *= 0.7; }   // ★ พิษ = ช้าลง
} else {
    // ไม่เห็นผู้เล่น: คืนคิวโจมตี แล้วเดินกลับจุดเกิด
    if (has_token) release_token(60);
    engaged = false;   // เจอกันใหม่รอบหน้า = ได้ช่วงรอจังหวะแรกอีกครั้ง
    var _hd = point_distance(x, y, home_x, home_y);
    if (_hd > 40) {
        var _hdir = point_direction(x, y, home_x, home_y);
        hsp = lengthdir_x(move_speed * 0.7, _hdir);
        vsp = lengthdir_y(move_speed * 0.7, _hdir);
    }
}

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
    if (id != other.id && abs(x - other.x) < 220 && abs(y - other.y) < 220) {
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

// ★ ศัตรูจากหีบบททดสอบ: อยู่ในวงเสมอ (เดิมถอย/วนรอบจนหลุดวง ผู้เล่นต้องตามออกไปตี)
if (variable_instance_exists(id, "trial_owner") && instance_exists(trial_owner)) {
    var _lr = trial_owner.trial_r - 60;
    var _ld = point_distance(trial_owner.x, trial_owner.y, x, y);
    if (_ld > _lr) {
        var _la = point_direction(trial_owner.x, trial_owner.y, x, y);
        var _nx = trial_owner.x + lengthdir_x(_lr, _la);
        var _ny = trial_owner.y + lengthdir_y(_lr, _la);
        if (!place_meeting(_nx, _ny, obj_wall)) { x = _nx; y = _ny; }
        // ตัดแรงที่พาออกนอกวง
        var _ox = lengthdir_x(1, _la);
        var _oy = lengthdir_y(1, _la);
        var _out = kb_x * _ox + kb_y * _oy;
        if (_out > 0) { kb_x -= _out * _ox; kb_y -= _out * _oy; }
    }
}

// ไม่ยืนทับผู้เล่น (ยังชนทางกายภาพกับผู้เล่นไม่ได้ แต่ดันออกเบา ๆ)
if (instance_exists(obj_player)) {
    var _pd2 = point_distance(x, y, obj_player.x, obj_player.y);
    if (_pd2 < 40) {
        var _pa = point_direction(obj_player.x, obj_player.y, x, y);
        move_and_collide(lengthdir_x(2, _pa), lengthdir_y(2, _pa), obj_wall);
    }
}

// แยกตัวแบบแข็ง: ห้ามทับกัน ตัวหนักถูกดันน้อย ตัวเบาถูกดันมาก
var _me = id;
with (obj_enemy) {
    if (id != _me && abs(x - _me.x) < 220 && abs(y - _me.y) < 220) {
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
if (!is_undefined(zone)) {
    x = clamp(x, zone[0], zone[2]);
    y = clamp(y, zone[1], zone[3]);
}

kb_x *= 0.8;
kb_y *= 0.8;
if (abs(kb_x) < 0.1) kb_x = 0;
if (abs(kb_y) < 0.1) kb_y = 0;

depth = -y;
if (hp <= 0) instance_destroy();