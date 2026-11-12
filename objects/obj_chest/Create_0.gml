// ตั้งค่าใน Creation Code ของแต่ละหีบ
key = "";        // ชื่อไม่ซ้ำ (ใช้จำว่าเปิดแล้ว)
gold = 0;
sp = 0;
potion = 0;
shot_up = 0;     // ★ เพิ่มระดับพลังยิงกี่ขั้น (ใช้กับหีบบททดสอบ)
trial = false;   // ★ หีบบททดสอบ: กด E แล้วต้องชนะศัตรูที่ถูกเรียกมา 3 รอบถึงได้ของ

opened = false;
inited = false;
near = false;

// ---- บททดสอบ ----
trial_state = 0;     // 0 = รอเริ่ม, 1 = กำลังสู้
trial_wave = 0;
trial_waves = 3;     // ★ จำนวนรอบ
trial_t = 0;
trial_r = 520;       // ★ รัศมีเขตบททดสอบ ออกนอกเขต = ล้มเหลว เริ่มใหม่ได้

// เปิดหีบ แจกของทั้งหมด
open_chest = function() {
    opened = true;
    if (key != "") flag_set("chest_" + key);

    if (gold > 0) {
        global.save.gold += gold;
        loot_toast("G", make_color_rgb(255, 210, 80), "coin", gold);
    }
    if (sp > 0) {
        global.save.sp += sp;
        loot_toast("SP", c_aqua, "star", sp);
    }
    repeat (potion) pickup_collect("potion", 1, x, y - 20);

    if (shot_up > 0) {
        var _lv0 = global.save.shot_lv;
        global.save.shot_lv = min(3, global.save.shot_lv + shot_up);
        var _sd = shot_data(global.save.shot_lv);
        with (obj_player) {
            player_apply_skills();
            shot1_ammo = shot1_max;
            shot1_reload_timer = 0;
        }
        float_text(x, y - 130, "พลังยิงเพิ่มขึ้น!", make_color_rgb(200, 120, 255), 1.4);
        loot_toast("ลูกไฟ " + string(_sd.ammo) + " นัด", make_color_rgb(255, 150, 60), "fire");
        if (_lv0 < 2 && global.save.shot_lv >= 2) loot_toast("ปลดสกิล 2: ยิงสามทิศ", c_yellow, "fire3");
        fx_spark(x, y - 30, 90, 22, make_color_rgb(200, 120, 255), 120);
    }
}

// จำนวนศัตรูของบททดสอบที่ยังอยู่
trial_alive = function() {
    var _me = id;
    var _n = 0;
    with (obj_enemy) {
        if (variable_instance_exists(id, "trial_owner") && trial_owner == _me) _n++;
    }
    return _n;
}

// ล้มเหลว: ศัตรูของบททดสอบหายไป กลับไปรอเริ่มใหม่
trial_fail = function() {
    var _me = id;
    with (obj_enemy) {
        if (variable_instance_exists(id, "trial_owner") && trial_owner == _me) {
            fx_spark(x, y - 30, 90, 10, make_color_rgb(150, 70, 255), 180);
            no_drop = true;
            instance_destroy();
        }
    }
    trial_state = 0;
    trial_wave = 0;
    float_text(x, y - 110, "ออกนอกเขต บททดสอบล้มเหลว", c_orange, 1.1);
}

// เรียกศัตรูรอบที่ _w (1-3) จำนวนเพิ่มตามด่าน
trial_spawn = function(_w) {
    var _t = level_tier();
    var _list;
    switch (_w) {
        case 1:  _list = [obj_enemy, obj_enemy]; if (_t >= 2) array_push(_list, obj_enemy_shooter); break;
        case 2:  _list = [obj_enemy, obj_enemy_shooter, obj_enemy_dasher]; if (_t >= 3) array_push(_list, obj_enemy); break;
        default: _list = [obj_enemy, obj_enemy, obj_enemy_dasher, obj_enemy_shooter]; if (_t >= 2) array_push(_list, obj_enemy_dasher); break;
    }
    var _a0 = irandom(359);
    for (var _i = 0; _i < array_length(_list); _i++) {
        var _sx = x;
        var _sy = y;
        // หาจุดว่างรอบหีบ (ไม่ติดกำแพง)
        for (var _k = 0; _k < 16; _k++) {
            var _a = _a0 + _i * (360 / array_length(_list)) + _k * 23;
            var _d = 170 + (_k mod 4) * 30;
            var _tx = x + lengthdir_x(_d, _a);
            var _ty = y + lengthdir_y(_d, _a);
            if (collision_rectangle(_tx - 30, _ty - 30, _tx + 30, _ty + 30, obj_wall, false, true) == noone
                && point_in_rectangle(_tx, _ty, 40, 40, room_width - 40, room_height - 40)) {
                _sx = _tx;
                _sy = _ty;
                break;
            }
        }
        var _e = instance_create_depth(_sx, _sy, depth, _list[_i]);
        _e.trial_owner = id;
        _e.no_drop = true;
        _e.alert_timer = 400;
        fx_spark(_sx, _sy - 30, 90, 14, make_color_rgb(150, 70, 255), 180);
    }
    fx_shake(4);
    float_text(x, y - 120, "รอบ " + string(_w) + " / " + string(trial_waves), make_color_rgb(200, 120, 255), 1.3);
}
