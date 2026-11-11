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

var _frozen = instance_exists(obj_fade) || instance_exists(obj_dialogue) || respawn_timer > 0;
if (respawn_timer > 0) respawn_timer--;

var _kx = 0;
var _run = false;
var _jp = false;
var _jh = false;

if (!_frozen) {
    _kx = (keyboard_check(ord("D")) || keyboard_check(vk_right))
        - (keyboard_check(ord("A")) || keyboard_check(vk_left));
    _run = keyboard_check(vk_shift);
    _jp = keyboard_check_pressed(vk_space) || keyboard_check_pressed(ord("W")) || keyboard_check_pressed(vk_up);
    _jh = keyboard_check(vk_space) || keyboard_check(ord("W")) || keyboard_check(vk_up);
}

// ---- สถานะพื้น / coyote / buffer ----
grounded = place_meeting(x, y + 1, _solids);
if (grounded) coyote = coyote_max;
else if (coyote > 0) coyote--;

if (_jp) jump_buffer = buffer_max;
else if (jump_buffer > 0) jump_buffer--;

// ---- แนวนอน ----
var _target = _kx * (_run ? run_speed : walk_speed);
var _acc;
if (_kx != 0) _acc = grounded ? accel_g : accel_a;
else _acc = grounded ? fric_g : fric_a;
hsp += clamp(_target - hsp, -_acc, _acc);
if (_kx != 0) face = _kx;

// ---- แนวตั้ง ----
vsp = min(vsp + grav, max_fall);

if (jump_buffer > 0 && coyote > 0) {
    vsp = -jump_speed;
    vrem = 0;
    jump_buffer = 0;
    coyote = 0;
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

grounded = place_meeting(x, y + 1, _solids);

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