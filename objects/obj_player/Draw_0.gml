
var _cfg = anim_config();
var _spd = point_distance(0, 0, mvx, mvy);

// ==========================================
// SELECT ANIMATION
// ==========================================

var _name = "idle";

if (state == PState.ROLL) {
    _name = "run";
}
else if (state == PState.ATTACK || state == PState.CHARGE) {
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
        if (state == PState.CHARGE) _f = 0;   // ชาร์จ = ค้างท่ายกค้อน
        else _f = floor(
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

// ==========================================
// ★ เกจชาร์จค้อนบนหัว
// ==========================================
if (state == PState.CHARGE) {
    var _full = (charge_t >= charge_time);
    var _k = charge_t / charge_time;
    var _gw = 56;
    var _gh = 8;
    var _gx = round(x - _gw / 2);
    var _gy = round(y - sprite_get_yoffset(_spr) * global.pl_scale - 18);

    // ตัวละครเรืองส้มขึ้นเรื่อย ๆ ตอนชาร์จ
    gpu_set_blendmode(bm_add);
    draw_sprite_ext(_spr, _f, round(x), round(y), global.pl_scale, global.pl_scale, 0,
        _full ? c_yellow : c_orange, (_full ? 0.35 + 0.2 * sin(current_time / 60) : 0.25 * _k));
    gpu_set_blendmode(bm_normal);

    draw_set_color(c_black);
    draw_rectangle(_gx - 2, _gy - 2, _gx + _gw + 1, _gy + _gh + 1, false);
    draw_set_color(c_dkgray);
    draw_rectangle(_gx, _gy, _gx + _gw - 1, _gy + _gh - 1, false);
    draw_set_color(_full ? ((current_time div 80) mod 2 == 0 ? c_white : c_yellow) : merge_color(c_orange, c_yellow, _k));
    draw_rectangle(_gx, _gy, _gx + max(1, _gw * _k) - 1, _gy + _gh - 1, false);
    if (_full) {
        draw_set_font(fnt_dialog);
        draw_set_halign(fa_center);
        draw_set_valign(fa_bottom);
        draw_set_color(c_yellow);
        draw_text_transformed(x, _gy - 2, "ปล่อย!", 0.5, 0.5, 0);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
    draw_set_color(c_white);
}
