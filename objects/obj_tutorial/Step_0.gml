// =====================================================================
// ★ เปิดตัวบอส (ตั้งค่าโดย boss_intro_start)
// เวลา: 0-30 กล้องเลื่อนไปหาบอส · 30-150 ขึ้นชื่อ · 150-180 กล้องกลับ (คลิก/Space ข้ามได้)
// =====================================================================
if (!is_undefined(global.boss_intro)) {
    var _bi = global.boss_intro;
    if (!instance_exists(_bi.boss) || !instance_exists(obj_player) || room == rm_menu) {
        global.boss_intro = undefined;
    } else if (!instance_exists(obj_dialogue) && !instance_exists(obj_fade)) {
        _bi.t++;
        if (_bi.t > 40 && _bi.t < 150 && (keyboard_check_pressed(vk_space) || mouse_check_button_pressed(mb_left))) _bi.t = 150;
        global.hitstop = max(global.hitstop, 2);   // หยุดทุกอย่างระหว่างเปิดตัว

        // ตำแหน่งกล้อง: ผู้เล่น <-> บอส
        var _cam = view_camera[0];
        var _cw = camera_get_view_width(_cam);
        var _ch = camera_get_view_height(_cam);
        var _p = obj_player;
        var _px = floor(_p.x - _cw / 2);
        var _py = floor(_p.y - _p.chest - _ch / 2);
        var _bx = floor(_bi.boss.x - _cw / 2);
        var _by = floor(_bi.boss.y - 90 - _ch / 2);
        var _k;
        if (_bi.t < 30) _k = _bi.t / 30;
        else if (_bi.t < 150) _k = 1;
        else _k = 1 - (_bi.t - 150) / 30;
        _k = clamp(_k, 0, 1);
        _k = _k * _k * (3 - 2 * _k);   // ease
        _bi.k = _k;                    // หมอกจางตามนี้ (obj_player Draw_73)
        camera_set_view_pos(_cam, round(lerp(_px, _bx, _k)), round(lerp(_py, _by, _k)));

        if (_bi.t == 30) fx_shake(4);
        if (_bi.t >= 180) {
            global.boss_intro = undefined;
            global.hitstop = 0;
            io_clear();
        }
    }
}

if (msg_t > 0) msg_t--;

// ต้นไม้สกิลเปิดใช้ได้ตั้งแต่ถึงหมู่บ้านครั้งแรก
if (room == rm_the_village && !flag_get("tree_unlocked")) flag_set("tree_unlocked");

if (!instance_exists(obj_player)) {
    freeze = false;
    watch = 0;
    ctx = undefined;
    exit;
}

var _busy = instance_exists(obj_dialogue) || instance_exists(obj_cutscene) || instance_exists(obj_fade)
         || instance_exists(obj_shop) || instance_exists(obj_skilltree) || instance_exists(obj_gameover) || instance_exists(obj_status);

// =====================================================================
// บทเรียนกลิ้งหลบ
// =====================================================================
// ข้ามบทเรียนไปแล้ว (ฆ่าศัตรูบทเรียนก่อน หรือเดินเลยไป) = ถือว่าผ่าน ป้ายถัดไปจะได้โผล่
if (!seen("tut_dodge") && !freeze && watch <= 0 && room == rm_level_1_the_forest) {
    var _alive = false;
    with (obj_enemy) if (variable_instance_exists(id, "tut_dodge")) _alive = true;
    if (!_alive || obj_player.x > 2600) global.story_seen[$ "tut_dodge"] = true;
}

if (!seen("tut_dodge")) {
    if (freeze) {
        freeze_t++;
        global.hitstop = max(global.hitstop, 2);   // หยุดทุกอย่างค้างไว้ (ผู้เล่นยังจำปุ่มกลิ้งได้)
        if (keyboard_check_pressed(vk_space)) {
            freeze = false;
            global.hitstop = 0;
            watch = 50;
            watch_hp = obj_player.hp;
        }
    } else if (watch > 0) {
        watch--;
        if (obj_player.hp < watch_hp) {
            watch = 0;
            show_msg("โดนซะแล้ว! รอจังหวะใหม่แล้วกลิ้งอีกที", c_orange);
        } else if (watch <= 0) {
            global.story_seen[$ "tut_dodge"] = true;
            show_msg("หลบได้! ระหว่างกลิ้งจะไม่โดนโจมตี", make_color_rgb(150, 255, 150));
        }
    } else if (!_busy && global.hitstop <= 0) {
        // ศัตรูบทเรียนกำลังจะฟัน (ล็อกทิศแล้ว) = หยุดเกม
        var _hit = noone;
        with (obj_enemy) {
            if (variable_instance_exists(id, "tut_dodge") && tut_dodge
                && atk_state == "windup" && !is_undefined(atk_cur) && atk_timer <= atk_cur.lock + 1) {
                _hit = id;
            }
        }
        if (_hit != noone) {
            freeze = true;
            freeze_t = 0;
            io_clear();
        }
    }
} else {
    freeze = false;
}

// =====================================================================
// ป้ายปุ่มตามสถานการณ์ (ทีละอัน)
// =====================================================================
if (is_undefined(ctx)) {
    ctx_a = lerp(ctx_a, 0, 0.2);
    if (!_busy && !freeze) {
        for (var _i = 0; _i < array_length(ctx_list); _i++) {
            var _c = ctx_list[_i];
            if (!seen(_c.key) && _c.when()) {
                ctx = _c;
                ctx_t = 0;
                ctx_done = 0;
                break;
            }
        }
    }
} else {
    ctx_t++;
    ctx_a = lerp(ctx_a, _busy ? 0 : 1, 0.15);

    if (ctx_done > 0) {
        ctx_done++;
        if (ctx_done > 45) {
            global.story_seen[$ ctx.key] = true;
            ctx = undefined;
        }
    } else if (!_busy) {
        var _ok = false;
        for (var _k = 0; _k < array_length(ctx.codes); _k++) {
            var _code = ctx.codes[_k];
            if (_code == -2) { if (mouse_wheel_up() || mouse_wheel_down()) _ok = true; }
            else if (_code == -3) { if (obj_player.state == PState.CHARGE && obj_player.charge_t >= obj_player.charge_time) _ok = true; }   // ชาร์จเต็มสักครั้ง
            else if (keyboard_check_pressed(_code)) _ok = true;
        }
        if (ctx.timeout > 0 && ctx_t >= ctx.timeout) _ok = true;
        if (_ok) ctx_done = 1;
    }
}
