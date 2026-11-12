var _solids = global.ss_solids;

// ล็อกตำแหน่งเป็นพิกเซลเต็ม + ตัวสะสมเศษความเร็ว
x = round(x);
y = round(y);
if (!variable_instance_exists(id, "hrem")) {
    hrem = 0;
    vrem = 0;
}

// ถ้าฝังอยู่ในพื้น/กำแพง/ลัง ให้ดันออกมา
if (place_meeting(x, y, _solids)) {
    var _fixed = false;
    for (var _d = 1; _d <= 48 && !_fixed; _d++) {
        if (!place_meeting(x, y - _d, _solids))      { y -= _d; _fixed = true; }
        else if (!place_meeting(x + _d, y, _solids)) { x += _d; _fixed = true; }
        else if (!place_meeting(x - _d, y, _solids)) { x -= _d; _fixed = true; }
    }
    vsp = 0;
    vrem = 0;
}

var _frozen = instance_exists(obj_fade) || instance_exists(obj_dialogue) || instance_exists(obj_skilltree) || instance_exists(obj_cutscene)
           || instance_exists(obj_shop) || instance_exists(obj_status) || respawn_timer > 0;
if (respawn_timer > 0) respawn_timer--;
if (!_frozen && keyboard_check_pressed(ord("T"))) skilltree_toggle();
if (!_frozen && keyboard_check_pressed(ord("I"))) status_toggle();

var _kx = 0;
var _run = false;
var _jp = false;
var _jh = false;

if (!_frozen) {
    _kx = (keyboard_check(ord("D")) || keyboard_check(vk_right))
        - (keyboard_check(ord("A")) || keyboard_check(vk_left));
    _run = keyboard_check(vk_shift);
    // ★ กระโดดด้วย Space เท่านั้น (W / ลูกศรขึ้น ใช้ขึ้นบันได)
    _jp = keyboard_check_pressed(vk_space);
    _jh = keyboard_check(vk_space);
}

if (atk_cd > 0) atk_cd--;
if (shot_cd > 0) shot_cd--;

// =====================================================================
// ★ บันไดเฉียง: ยืนที่ปลายบันไดแล้วกด W
// =====================================================================
if (!_frozen && on_stairs == noone && (keyboard_check_pressed(ord("W")) || keyboard_check_pressed(vk_up))) {
    var _me = id;
    with (obj_stairs_ss) {
        if (_me.on_stairs != noone) continue;
        var _tx = x + dir * run;
        var _ty = y - rise;
        if (abs(_me.x - x) < 28 && abs(_me.y - y) < 12) { _me.on_stairs = id; _me.stair_s = 0; }
        else if (abs(_me.x - _tx) < 28 && abs(_me.y - _ty) < 12) { _me.on_stairs = id; _me.stair_s = 1; }
    }
    if (on_stairs != noone) {
        _jp = false;
        jump_buffer = 0;
        hsp = 0;
        vsp = 0;
    }
}

// ★ ชั้นบน: เดินเข้าหาปลายบนของบันได = ก้าวลงบันไดอัตโนมัติ (ไม่ต้องกด W)
if (!_frozen && on_stairs == noone && grounded && _kx != 0) {
    var _me2 = id;
    with (obj_stairs_ss) {
        if (_me2.on_stairs != noone) continue;
        var _tx2 = x + dir * run;
        var _ty2 = y - rise;
        // เดินไปทางขาลง (ทิศตรงข้ามกับ dir) และถึงปลายบนพอดี
        if (_kx == -dir && abs(_me2.x - _tx2) < 10 && abs(_me2.y - _ty2) < 12) {
            _me2.on_stairs = id;
            _me2.stair_s = 1;
            _me2.hsp = 0;
            _me2.vsp = 0;
        }
    }
}

if (on_stairs != noone) {
    if (!instance_exists(on_stairs)) {
        on_stairs = noone;
    } else if (_jp && !_frozen) {
        // ★ กระโดดจากบันไดได้ (ตกลงมาโดนบันไดอีกก็ยืนต่อได้เหมือนพื้น)
        on_stairs = noone;
        vsp = -jump_speed;
        vrem = 0;
        hsp = _kx * (_run ? run_speed : walk_speed);
        jump_buffer = 0;
        coyote = 0;
        _jp = false;
        fx_dust(x, y - 2, 3, make_color_rgb(190, 180, 165));
    } else {
        var _st = on_stairs;
        var _spd = (_run ? run_speed : walk_speed) * 0.75;
        var _ds = _kx * _st.dir * _spd / _st.run;
        stair_s += _ds;
        if (_kx != 0) face = _kx;
        var _leave = false;
        // ★ ออกจากบันไดเฉพาะตอน "เดินเลยปลาย" (เดิมยืนที่ปลายแล้วหลุดออกทันทีในเฟรมที่กด W)
        if (stair_s <= 0) { stair_s = 0; if (_ds < 0) _leave = true; }
        if (stair_s >= 1) { stair_s = 1; if (_ds > 0) _leave = true; }
        x = round(lerp(_st.x, _st.x + _st.dir * _st.run, stair_s));
        y = round(lerp(_st.y, _st.y - _st.rise, stair_s));
        hsp = 0;
        vsp = 0;
        hrem = 0;
        vrem = 0;
        // ★ ออกจากบันไดได้ทางเดียว: เดินด้วย A/D จนสุดปลายบันได (ไม่มีกด S หรือกระโดดออก)
        if (_leave) on_stairs = noone;

        // แอนิเมชันเดิน + กล้อง แล้วจบ (บนบันไดไม่ใช้ฟิสิกส์ปกติ)
        sprite_index = (_kx != 0) ? spr_pl_ss_walk : spr_pl_ss_idle;
        anim_t += ((_kx != 0) ? 10 : 8) / 60;
        image_index = floor(anim_t) mod sprite_get_number(sprite_index);
        scr_camera_ss(x, y - 72, face);
        exit;
    }
}

// =====================================================================
// ★ ดาบ (คลิกซ้าย ต้องหยิบดาบแล้ว) / ยิง (ปุ่ม 1 ไปทางเมาส์ ยกเว้นในวิหาร)
// =====================================================================
if (!_frozen && flag_get("sword") && mouse_check_button_pressed(mb_left) && atk_cd <= 0) {
    atk_t = 16;
    atk_cd = 22;
    atk_id++;
    face = (mouse_x >= x) ? 1 : -1;
}
if (atk_t > 0) {
    atk_t--;
    if (atk_t <= 12 && atk_t >= 6) {
        var _ax1 = (face > 0) ? x + 4 : x - 80;
        var _ax2 = _ax1 + 76;
        var _ay1 = y - 84;
        var _ay2 = y - 4;
        var _sid = atk_id;
        with (obj_breakable_ss) {
            if (last_swing != _sid && rectangle_in_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, _ax1, _ay1, _ax2, _ay2) > 0) {
                last_swing = _sid;
                hit();
            }
        }
        with (obj_lever_ss) {
            if (last_swing != _sid && point_in_rectangle(x, y - 30, _ax1 - 10, _ay1, _ax2 + 10, _ay2 + 10)) {
                last_swing = _sid;
                hit();
            }
        }
        with (obj_target) {
            if (!hit && tink_id != _sid && point_in_rectangle(x, y - 48, _ax1, _ay1, _ax2, _ay2)) {
                tink_id = _sid;
                float_text(x, y - 90, "ฟันไม่ได้ ต้องยิง! [1]", c_orange, 0.9);
            }
        }
    }
}
if (!_frozen && room != rm_the_sanctuary_ss && keyboard_check_pressed(ord("1")) && shot_cd <= 0) {
    var _sa = point_direction(x, y - 40, mouse_x, mouse_y);
    var _b = instance_create_depth(x + lengthdir_x(20, _sa), y - 40 + lengthdir_y(20, _sa), depth - 1, obj_bullet_ss);
    _b.direction = _sa;
    _b.image_angle = _sa;
    _b.vx = lengthdir_x(11, _sa);   // ★ ขยับเองใน Step ของกระสุน (เดิมใช้ speed แล้วค้างอยู่กับที่)
    _b.vy = lengthdir_y(11, _sa);
    shot_cd = 26;
    face = (mouse_x >= x) ? 1 : -1;
}

// ---- สถานะพื้น / coyote / buffer ----
grounded = place_meeting(x, y + 1, _solids);
if (on_plat > 0) {   // ★ ยืนบนแท่นเลื่อน = นับว่าอยู่บนพื้น
    grounded = true;
    on_plat--;
}
if (grounded) coyote = coyote_max;
else if (coyote > 0) coyote--;

if (_jp) jump_buffer = buffer_max;
else if (jump_buffer > 0) jump_buffer--;

// ---- แนวนอน ----
var _target = _kx * (_run ? run_speed : walk_speed);
if (atk_t > 0) _target *= 0.4;   // ฟันอยู่ เดินช้าลง
var _acc;
if (_kx != 0) _acc = grounded ? accel_g : accel_a;
else _acc = grounded ? fric_g : fric_a;
hsp += clamp(_target - hsp, -_acc, _acc);
if (_kx != 0 && atk_t <= 0) face = _kx;

// ---- แนวตั้ง ----
vsp = min(vsp + grav, max_fall);

if (jump_buffer > 0 && coyote > 0) {
    fx_dust(x, y - 2, 3, make_color_rgb(190, 180, 165));   // ★ ฝุ่นตอนกระโดด
    vsp = -jump_speed;
    vrem = 0;
    jump_buffer = 0;
    coyote = 0;
    on_plat = 0;
}
if (!_jh && vsp < -jump_cut) vsp = -jump_cut;

// ---- ชน: ขยับทีละ 1px ----
hrem += hsp;
var _mx = round(hrem);
hrem -= _mx;
var _sx = sign(_mx);
repeat (abs(_mx)) {
    if (!place_meeting(x + _sx, y, _solids)) {
        x += _sx;
    } else {
        hsp = 0;
        hrem = 0;
        break;
    }
}

var _y_before = y;   // ★ ใช้เช็กการตกลงบนบันได
vrem += vsp;
var _my = round(vrem);
vrem -= _my;
var _sy = sign(_my);
repeat (abs(_my)) {
    if (!place_meeting(x, y + _sy, _solids)) {
        y += _sy;
    } else {
        vsp = 0;
        vrem = 0;
        break;
    }
}

// =====================================================================
// ★ บันไดรับตัวเหมือนพื้น: กระโดด/ตกลงมาโดนแนวบันได = ยืนบนบันไดตรงจุดนั้นเลย
//   (ทางเดียวจากด้านบน ขาขึ้นทะลุได้ / ไม่นับช่วงปลายสุดที่เป็นพื้นอยู่แล้ว)
// =====================================================================
if (on_stairs == noone && vsp >= 0 && !_frozen) {
    var _me3 = id;
    var _yb = _y_before;
    with (obj_stairs_ss) {
        if (_me3.on_stairs != noone) continue;
        var _t = (_me3.x - x) / (dir * run);
        if (_t < 0.04 || _t > 0.96) continue;
        var _ly = y - rise * _t;
        if (_yb <= _ly + 2 && _me3.y >= _ly - 1) {
            _me3.on_stairs = id;
            _me3.stair_s = _t;
            _me3.y = round(_ly);
            _me3.vsp = 0;
            _me3.vrem = 0;
            _me3.hsp = 0;
            _me3.hrem = 0;
            fx_dust(_me3.x, _me3.y - 2, 3, make_color_rgb(190, 180, 165));
        }
    }
}

grounded = place_meeting(x, y + 1, _solids);

// ★ ฝุ่น: ตอนวิ่งบนพื้น / ตอนลงพื้น
if (grounded && !ss_was_grounded) fx_dust(x, y - 2, 4, make_color_rgb(190, 180, 165));
ss_was_grounded = grounded;
if (grounded && abs(hsp) > 1.5) {
    ss_dust_t--;
    if (ss_dust_t <= 0) {
        ss_dust_t = _run ? 4 : 9;
        fx_dust(x - sign(hsp) * 8, y - 2, _run ? 2 : 1, make_color_rgb(190, 180, 165), -hsp * 0.15);
    }
} else ss_dust_t = 0;

// ---- ตกหลุม / โดนหนาม ----
if (respawn_timer <= 0 && (place_meeting(x, y, obj_hazard_ss) || y > room_height + 64)) {
    die();
}

// ---- แอนิเมชัน ----
var _new = "idle";
if (!grounded) _new = "jump";
else if (abs(hsp) > walk_speed + 0.8) _new = "run";
else if (abs(hsp) > 0.4) _new = "walk";

if (_new != anim_state) {
    anim_state = _new;
    anim_t = 0;
}

var _n;
switch (anim_state) {
    case "idle": sprite_index = spr_pl_ss_idle; anim_t += 8 / 60;  break;
    case "walk": sprite_index = spr_pl_ss_walk; anim_t += 10 / 60; break;
    case "run":  sprite_index = spr_pl_ss_run;  anim_t += 16 / 60; break;
    case "jump":
        sprite_index = spr_pl_ss_jump;
        _n = sprite_get_number(sprite_index);
        // เฟรมแรก = พุ่งขึ้น, เฟรมท้าย = ตกลง ตามความเร็วแนวตั้ง
        anim_t = clamp(((vsp + jump_speed) / (jump_speed + max_fall)) * (_n - 1), 0, _n - 1);
        break;
}
image_index = floor(anim_t) mod sprite_get_number(sprite_index);

// ---- กล้อง ----
scr_camera_ss(x, y - 72, face);