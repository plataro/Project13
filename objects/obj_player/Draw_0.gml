
var _cfg = anim_config();
var _spd = point_distance(0, 0, mvx, mvy);

// ==========================================
// SELECT ANIMATION
// ==========================================

var _name = "idle";

if (state == PState.ROLL) {
    _name = "run";
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

// เลือก Sprite ตามทิศทาง
var _spr = _a.spr[face];

// จำนวนเฟรมจริงของ Sprite
var _frames = sprite_get_number(_spr);

// ==========================================
// ANIMATION TIMER
// ==========================================

if (!variable_instance_exists(id, "anim_t")) {
    anim_t = 0;
}

anim_t += _a.fps / 60;

var _f = 0;

switch (_name) {

    case "attack":
        _f = floor(
            ((attack_total - attack_timer) / attack_total) * _frames
        );
        break;

    case "hurt":
        _f = floor(
            ((invuln_time - invuln_timer) / 12) * _frames
        );
        break;

    default:
        _f = floor(anim_t) mod _frames;
        break;
}

_f = clamp(_f, 0, _frames - 1);

// ==========================================
// AFTERIMAGE
// ==========================================

if (state == PState.ROLL) {

    var _run_spr = _cfg.run.spr[face];

    for (var i = 3; i >= 0; i--) {

        if (roll_echo_age[i] < 12) {

            var _alpha = 0.38 * (
                1 - roll_echo_age[i] / 12
            );

            draw_sprite_ext(
                _run_spr,
                roll_echo_frame[i],
                round(roll_echo_x[i]),
                round(roll_echo_y[i]),
                global.pl_scale,
                global.pl_scale,
                0,
                make_color_rgb(175, 65, 255),
                _alpha
            );
        }
    }
}

// ==========================================
// SHADOW
// ==========================================

var _sw = (bbox_right - bbox_left) * 0.75;

draw_shadow(
    x,
    y,
    _sw,
    _sw * 0.35
);

// ==========================================
// DEBUG
// ==========================================

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

// ==========================================
// INVULNERABILITY FLASH
// ==========================================

if (invuln_timer > 0 && (invuln_timer div 4) mod 2 == 0) {
    exit;
}

// ==========================================
// PLAYER COLOR
// ==========================================

var _color = c_white;

// Roll = Violet
if (state == PState.ROLL) {
    _color = make_color_rgb(190, 115, 255);
}

// ==========================================
// DRAW PLAYER
// ==========================================

draw_sprite_ext(
    _spr,
    _f,
    round(x),
    round(y),
    global.pl_scale,
    global.pl_scale,
    0,
    _color,
    1
);
