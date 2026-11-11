// เห็นเฉพาะตอนไม่มีกำแพงบัง (จางเข้า/ออกนุ่ม ๆ)
var _show = los_clear || flash > 0;
if (!_show && instance_exists(obj_player) && point_distance(x, y, obj_player.x, obj_player.y) < 70) _show = true;
vis = clamp(vis + (_show ? 0.2 : -0.2), 0, 1);
if (vis <= 0.01) exit;

var _col = tint;
if (flash > 0) _col = c_red;
else if (telegraph) _col = c_yellow;

var _ox = telegraph ? irandom_range(-2, 2) : 0;

var _sw = (bbox_right - bbox_left) * 0.75;
if (vis > 0.5) draw_shadow(x, y, _sw, _sw * 0.35);

// วงเตือนพื้นที่โจมตีตอนเตรียมท่า
if (atk_state == "windup" && !is_undefined(atk_cur)) {
    draw_set_alpha(0.15 + 0.1 * sin(current_time / 60));
    draw_set_color(c_red);
    for (var _i = 0; _i < array_length(atk_cur.circles); _i++) {
        var _c = atk_cur.circles[_i];
        var _cx = x + lengthdir_x(_c[0], atk_dir) + lengthdir_x(_c[1], atk_dir + 90);
        var _cy = y + lengthdir_y(_c[0], atk_dir) + lengthdir_y(_c[1], atk_dir + 90) - atk_cur.lift;
        draw_circle(round(_cx), round(_cy), _c[2], false);
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
}

draw_sprite_ext(sprite_index, image_index, round(x) + _ox, round(y), image_xscale, image_yscale, 0, _col, vis);

// โหมด Debug: กรอบเขียว = กล่องโดนตี, กรอบแดง = กล่องชนที่เท้า
if (global.debug) {
    var _r = enemy_hurt_rect(id);
    draw_set_color(c_lime);
    draw_rectangle(_r[0], _r[1], _r[2], _r[3], true);
    draw_set_color(c_red);
    draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);
    draw_set_color(c_white);
}

// ★ หลอดเลือดบนหัว (แสดงหลังโดนตี แล้วจางหายเมื่อไม่โดนต่อ 3 วินาที)
if (hp_shown < hp) hp_shown = hp;
else hp_shown = lerp(hp_shown, hp, 0.08);
if (hp_bar_timer > 0) hp_bar_timer--;

if (show_bar && hp_bar_timer > 0 && hp > 0) {
    var _hr = enemy_hurt_rect(id);
    var _bw = 52;
    var _bh = 6;
    var _bx = round(x - _bw / 2);
    var _by = round(_hr[1] - 16);
    var _fa = min(1, hp_bar_timer / 30);

    draw_set_alpha(_fa);
    draw_set_color(c_black);
    draw_rectangle(_bx - 2, _by - 2, _bx + _bw + 1, _by + _bh + 1, false);
    draw_set_color(c_dkgray);
    draw_rectangle(_bx, _by, _bx + _bw - 1, _by + _bh - 1, false);
    draw_set_color(c_white);   // แถบขาวไหลตามหลัง
    draw_rectangle(_bx, _by, _bx + max(1, _bw * (hp_shown / max_hp)) - 1, _by + _bh - 1, false);
    draw_set_color(c_red);     // เลือดจริง
    draw_rectangle(_bx, _by, _bx + max(1, _bw * (hp / max_hp)) - 1, _by + _bh - 1, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}