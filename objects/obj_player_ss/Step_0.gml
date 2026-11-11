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

var _solids = global.ss_solids;

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
    jump_buffer = 0;
    coyote = 0;
}
if (!_jh && vsp < -jump_cut) vsp = -jump_cut;

// ---- ชน ----
move_and_collide(hsp, 0, _solids);
if (hsp != 0 && place_meeting(x + sign(hsp), y, _solids)) hsp = 0;

move_and_collide(0, vsp, _solids);
if (vsp != 0 && place_meeting(x, y + sign(vsp), _solids)) vsp = 0;

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