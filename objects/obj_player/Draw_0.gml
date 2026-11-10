
var _cfg = anim_config();
var _spd = point_distance(0, 0, mvx, mvy);

// เลือก Animation ตามสถานะ
var _name = "idle";

if (state == PState.ROLL) {
    _name = "roll";
}
else if (state == PState.ATTACK) {
    _name = "attack";
}
else if (invuln_timer > invuln_time - 12) {
    _name = "hurt";
}
else if (_spd > move_speed + 0.5) {
    _name = "run";
}
else if (_spd > 0.3) {
    _name = "walk";
}

var _a = _cfg[$ _name];

// เลือก Sprite
var _spr;

if (_name == "idle") {
    _spr = _a.spr[face];
}
else {
    _spr = _a.spr;
}

// ตัวนับ Animation
if (!variable_instance_exists(id, "anim_t")) {
    anim_t = 0;
}

anim_t += _a.fps / 60;

// คำนวณเฟรม
var _f = 0;

switch (_name) {

    case "attack":
        _f = floor(
            ((attack_total - attack_timer) / attack_total) * _a.n
        );
        break;

    case "roll":
        _f = floor(
            ((roll_time - roll_timer) / roll_time) * _a.n
        );
        break;

    case "hurt":
        _f = floor(
            ((invuln_time - invuln_timer) / 12) * _a.n
        );
        break;

    default:
        _f = floor(anim_t) mod _a.n;
        break;
}

_f = clamp(_f, 0, _a.n - 1);

// เงา
var _sw = (bbox_right - bbox_left) * 0.75;

draw_shadow(
    x,
    y,
    _sw,
    _sw * 0.35
);

// Debug
if (global.debug) {
    var _r = player_hurt_rect(id);

    draw_set_color(c_lime);
    draw_rectangle(
        _r[0], _r[1],
        _r[2], _r[3],
        true
    );

    draw_set_color(c_white);
}

// กะพริบเมื่อได้รับความเสียหาย
if (invuln_timer > 0 && (invuln_timer div 4) mod 2 == 0) {
    exit;
}

// วาด Idle จาก Sprite แยกทิศทาง
if (_name == "idle") {

    draw_sprite_ext(
        _spr,
        _f,
        round(x),
        round(y),
        global.pl_scale,
        global.pl_scale,
        0,
        c_white,
        1
    );

}

// วาด Animation อื่นจาก Sprite Sheet 4 ทิศทาง
else {

    var _row = global.face_row[face];

    draw_sprite_part_ext(
        _spr,
        _f,
        0,
        _row * 64,
        64,
        64,
        round(x),
        round(y - _row * 64 * global.pl_scale),
        global.pl_scale,
        global.pl_scale,
        c_white,
        1
    );

}
