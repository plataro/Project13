// ★ เห็นเมื่อรอยเท้าอยู่ในโซนสว่างของหมอก (เช็กทุกเฟรม ใช้จุดตาเดียวกับหมอก)
// ค่อย ๆ จางเข้า/ออก ไม่โผล่/หายแบบกระตุก
var _show = (flash > 0) || enemy_visible(id);
if (!is_undefined(global.boss_intro) && global.boss_intro.boss == id) _show = true;   // ★ บอสที่กำลังเปิดตัว = เห็นเสมอ
if (!_show && instance_exists(obj_player) && point_distance(x, y, obj_player.x, obj_player.y) < 70) _show = true;
vis = clamp(vis + (_show ? 0.2 : -0.1), 0, 1);
if (vis <= 0.01) exit;

// ★ ลูกไฟของจอมเวท: วาดเป็นลูกไฟเรือง + วงนับถอยหลัง
if (variable_instance_exists(id, "is_orb")) {
    var _ok = orb_t / orb_t0;
    var _oy = y - 40 + sin(current_time / 150 + id) * 4;
    var _pul = 1 + 0.15 * sin(current_time / ((_ok < 0.3) ? 40 : 90));
    draw_set_alpha(0.35 * vis);
    draw_set_color(c_black);
    draw_ellipse(x - 14, y - 4, x + 14, y + 4, false);
    gpu_set_blendmode(bm_add);
    draw_set_alpha(0.5 * vis);
    draw_set_color(make_color_rgb(255, 120, 30));
    draw_circle(x, _oy, 22 * _pul, false);
    draw_set_alpha(vis);
    draw_set_color(make_color_rgb(255, 210, 120));
    draw_circle(x, _oy, 11 * _pul, false);
    gpu_set_blendmode(bm_normal);
    // วงเวลา: เหลือน้อย = แดง
    draw_set_color((_ok < 0.3) ? c_red : c_orange);
    draw_set_alpha(vis);
    for (var _ai = 0; _ai < 24 * _ok; _ai++) {
        var _aa = 90 - _ai * 15;
        draw_circle(x + lengthdir_x(30, _aa), _oy + lengthdir_y(30, _aa), 2, false);
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
    exit;
}

var _col = tint;
if (flash > 0) _col = c_red;
else if (telegraph) _col = c_yellow;

var _ox = telegraph ? irandom_range(-2, 2) : 0;

var _sw = (bbox_right - bbox_left) * 0.75;
if (vis > 0.5) draw_shadow(x, y, _sw, _sw * 0.35);

// ★ จุดปะทุบนพื้นของบอสใหญ่ (วงเตือนค่อย ๆ เข้ม แล้วระเบิด)
if (variable_instance_exists(id, "erupts")) {
    for (var _ei = 0; _ei < array_length(erupts); _ei++) {
        var _e = erupts[_ei];
        if (_e.t > 0) {
            var _k = 1 - _e.t / _e.t0;
            draw_set_color(c_red);
            draw_set_alpha(0.08 + 0.22 * _k);
            draw_ellipse(_e.x - _e.r, _e.y - _e.r * 0.6, _e.x + _e.r, _e.y + _e.r * 0.6, false);
            draw_set_alpha(0.35 + 0.45 * _k);
            draw_ellipse(_e.x - _e.r, _e.y - _e.r * 0.6, _e.x + _e.r, _e.y + _e.r * 0.6, true);
            // วงในหดเข้าหาขอบ = ใกล้ระเบิด
            var _ir = _e.r * _k;
            draw_ellipse(_e.x - _ir, _e.y - _ir * 0.6, _e.x + _ir, _e.y + _ir * 0.6, true);
        } else {
            var _f2 = 1 + _e.t / 12;
            draw_set_color(make_color_rgb(255, 150, 60));
            draw_set_alpha(0.7 * _f2);
            draw_ellipse(_e.x - _e.r, _e.y - _e.r * 0.6, _e.x + _e.r, _e.y + _e.r * 0.6, false);
            // หนามพุ่งขึ้น
            draw_set_color(make_color_rgb(255, 220, 160));
            for (var _sp = -2; _sp <= 2; _sp++) {
                var _sx2 = _e.x + _sp * _e.r * 0.3;
                draw_triangle(_sx2 - 5, _e.y, _sx2 + 5, _e.y, _sx2, _e.y - _e.r * (0.9 - abs(_sp) * 0.2) * _f2, false);
            }
        }
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// ★ ไม้ตาย: วงพลังหดเข้าหาบอส / มึนงง: ดาวหมุนเหนือหัว
if (variable_instance_exists(id, "ult_t")) {
    if (state == "ult") {
        var _uk = ult_t / ult_time;
        var _ur = 140 + 520 * _uk;
        draw_set_color(c_red);
        draw_set_alpha(0.25 + 0.2 * sin(current_time / 80));
        draw_ellipse(x - _ur, y - _ur * 0.6, x + _ur, y + _ur * 0.6, true);
        draw_ellipse(x - _ur + 3, y - _ur * 0.6 + 2, x + _ur - 3, y + _ur * 0.6 - 2, true);
        draw_set_alpha(0.12);
        draw_ellipse(x - 140, y - 84, x + 140, y + 84, false);
        draw_set_alpha(1);
    } else if (state == "stunned") {
        var _hr2 = enemy_hurt_rect(id);
        for (var _st = 0; _st < 3; _st++) {
            var _sa = current_time / 6 + _st * 120;
            var _stx = x + lengthdir_x(40, _sa);
            var _sty = _hr2[1] - 10 + lengthdir_y(12, _sa);
            draw_set_color(c_yellow);
            draw_circle(_stx, _sty, 5, false);
        }
        draw_set_color(c_white);
    }
}

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
fog_col = _col;   // ★ จำไว้ให้หมอกวาดตัวซ้ำทับ (ตัวไม่มืดตามขอบกำแพง)
fog_ox = _ox;

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

// ★ ไอคอนสถานะผิดปกติเหนือหัว
if (st_burn > 0 || st_poison > 0 || st_stun > 0) {
    var _sr = enemy_hurt_rect(id);
    var _ix = x - 14;
    var _iy = _sr[1] - 30 - z;
    if (st_burn > 0)   { draw_set_color(c_orange); draw_triangle(_ix - 6, _iy + 6, _ix + 6, _iy + 6, _ix, _iy - 8 + sin(current_time / 60) * 2, false); _ix += 16; }
    if (st_poison > 0) { draw_set_color(make_color_rgb(140, 220, 90)); draw_circle(_ix, _iy + 1, 6, false); _ix += 16; }
    if (st_stun > 0)   { draw_set_color(c_yellow); draw_circle(_ix + lengthdir_x(5, current_time / 4), _iy + lengthdir_y(3, current_time / 4), 4, false); }
    draw_set_color(c_white);
}

// ★ หลอดเลือดบนหัว (แสดงหลังโดนตี แล้วจางหายเมื่อไม่โดนต่อ 3 วินาที)
if (hp_shown < hp) hp_shown = hp;
else hp_shown = lerp(hp_shown, hp, 0.08);
if (hp_bar_timer > 0) hp_bar_timer--;

enemy_draw_hpbar();   // ★ ย้ายไปเป็นฟังก์ชัน (หมอกเรียกวาดซ้ำทับอีกรอบ หลอดจะได้อยู่หน้าตัวศัตรูเสมอ)