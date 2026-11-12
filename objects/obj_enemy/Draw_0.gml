// ไม่มีเส้นสายตา = ไม่วาดเลย (กันหัวยื่นพ้นกำแพงเข้าโซนสว่าง)
var _show = los_clear || flash > 0;
if (!_show && instance_exists(obj_player) && point_distance(x, y, obj_player.x, obj_player.y) < 70) _show = true;
vis = clamp(vis + (_show ? 0.5 : -0.5), 0, 1);
if (vis <= 0.01) exit;

var _col = tint;
if (flash > 0) _col = c_red;
else if (telegraph) _col = c_yellow;

var _ox = telegraph ? irandom_range(-2, 2) : 0;

var _sw = (bbox_right - bbox_left) * 0.75;
if (vis > 0.5) draw_shadow(x, y, _sw, _sw * 0.35);

// ★ วงเตือนจุดตกของท่ากระโดด (เข้มขึ้นตอนล็อกจุดแล้ว)
if (is_array(marker)) {
    draw_set_alpha(marker[3] ? 0.42 : 0.15 + 0.1 * sin(current_time / 60));
    draw_set_color(marker[3] ? make_color_rgb(255, 60, 40) : c_red);
    draw_circle(round(marker[0]), round(marker[1]) - 40, marker[2], false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// วงเตือนพื้นที่โจมตีตอนเตรียมท่า
if (atk_state == "windup" && !is_undefined(atk_cur)) {
    // ★ ล็อกทิศแล้ว = วงเข้มขึ้นชัด ๆ (สัญญาณว่า "กลิ้งตอนนี้")
    var _locked = (atk_timer <= atk_cur.lock);
    draw_set_alpha(_locked ? 0.42 : 0.15 + 0.1 * sin(current_time / 60));
    draw_set_color(_locked ? make_color_rgb(255, 60, 40) : c_red);
    if (variable_struct_exists(atk_cur, "rects")) {
        for (var _k = 0; _k < array_length(atk_cur.rects); _k++) {
            var _r = atk_cur.rects[_k];
            // เตือนตลอดเส้นทางที่จะพุ่งไป (ระยะพุ่ง + ระยะเอื้อม)
            draw_oriented_rect(x, y - atk_cur.lift, atk_dir, _r[0], _r[1] + atk_cur.lunge_speed * atk_cur.lunge_frames, _r[2], _r[3]);
        }
    }
    for (var _i = 0; _i < array_length(atk_cur.circles); _i++) {
        var _c = atk_cur.circles[_i];
        var _cx = x + lengthdir_x(_c[0], atk_dir) + lengthdir_x(_c[1], atk_dir + 90);
        var _cy = y + lengthdir_y(_c[0], atk_dir) + lengthdir_y(_c[1], atk_dir + 90) - atk_cur.lift;
        draw_circle(round(_cx), round(_cy), _c[2], false);
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
}

draw_sprite_ext(sprite_index, image_index, round(x) + _ox, round(y - z), image_xscale, image_yscale, 0, _col, vis);

// ★ เกราะกันกระสุน: วงฟ้าเรือง ๆ รอบตัว (กะพริบตอนใกล้หมด)
if (shield > 0 && (shield > 60 || (shield div 5) mod 2 == 0)) {
    var _sr = enemy_hurt_rect(id);
    var _scx = (_sr[0] + _sr[2]) / 2;
    var _scy = (_sr[1] + _sr[3]) / 2 - z;
    var _srad = max(_sr[2] - _sr[0], _sr[3] - _sr[1]) * 0.62;
    gpu_set_blendmode(bm_add);
    draw_set_color(make_color_rgb(70, 160, 255));
    draw_set_alpha(0.18 * vis);
    draw_circle(_scx, _scy, _srad, false);
    draw_set_alpha((0.55 + 0.25 * sin(current_time / 90)) * vis);
    draw_circle(_scx, _scy, _srad, true);
    draw_circle(_scx, _scy, _srad - 2, true);
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// แฟลชขาวช่วงแรกที่โดนตี (บวกสีขาวทับตัวศัตรู)
if (flash > 3) {
    gpu_set_blendmode(bm_add);
    draw_sprite_ext(sprite_index, image_index, round(x) + _ox, round(y - z), image_xscale, image_yscale, 0, c_white, vis * 0.85);
    gpu_set_blendmode(bm_normal);
}

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