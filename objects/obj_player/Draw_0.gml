var _cfg = anim_config();
var _spd = point_distance(0, 0, mvx, mvy);

// เลือกท่าตามสถานะ
var _name = "idle";
if (state == PState.ROLL) _name = "roll";
else if (state == PState.ATTACK) _name = "attack";
else if (invuln_timer > invuln_time - 12) _name = "hurt";   // สะดุ้ง 12 เฟรมแรกหลังโดนตี
else if (_spd > move_speed + 0.5) _name = "run";
else if (_spd > 0.3) _name = "walk";
var _a = _cfg[$ _name];

// ตัวนับเฟรมของท่าที่วนซ้ำ
if (!variable_instance_exists(id, "anim_t")) anim_t = 0;
anim_t += _a.fps / 60;

// หาเฟรมในท่า (0 ถึง n-1)
var _f = 0;
switch (_name) {
    case "attack":   // เล่นให้จบพอดีกับเวลาท่าฟัน
        _f = floor(((attack_total - attack_timer) / attack_total) * _a.n);
        break;
    case "roll":
        _f = floor(((roll_time - roll_timer) / roll_time) * _a.n);
        break;
    case "hurt":
        _f = floor(((invuln_time - invuln_timer) / 12) * _a.n);
        break;
    default:
        _f = floor(anim_t) mod _a.n;
        break;
}
_f = clamp(_f, 0, _a.n - 1);

var _frame = global.face_row[face] * _a.n + _f;

// เงา
var _sw = (bbox_right - bbox_left) * 0.75;
draw_shadow(x, y, _sw, _sw * 0.35);

// โหมด Debug: กรอบเขียว = กล่องโดนตีของผู้เล่น
if (global.debug) {
    var _r = player_hurt_rect(id);
    draw_set_color(c_lime);
    draw_rectangle(_r[0], _r[1], _r[2], _r[3], true);
    draw_set_color(c_white);
}

// กะพริบตอนอมตะหลังโดนตี
if (invuln_timer > 0 && (invuln_timer div 4) mod 2 == 0) exit;

draw_sprite_ext(_a.spr, _frame, round(x), round(y), global.pl_scale, global.pl_scale, 0, c_white, 1);