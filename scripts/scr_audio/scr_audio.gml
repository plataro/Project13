// =====================================================================
// ★ ระบบเสียง
// ---------------------------------------------------------------------
// ทั้งเกมเรียกเสียงผ่าน "ชื่อสั้น" เช่น sfx("swing") / music_for_room()
// ถ้ายังไม่ได้ลงทะเบียนเสียงชื่อนั้นใน audio_register() = เงียบเฉย ๆ ไม่ error
//
// วิธีใส่เสียงใหม่:
//   1) import ไฟล์เป็น Sound asset (ชื่อ snd_xxx / mus_xxx)
//   2) เอา // ออกหน้าบรรทัดที่ตรงกันใน audio_register() ด้านล่าง
//      (ต้องอ้างชื่อ asset ตรง ๆ แบบนี้ เพราะเกมตั้ง "ลบ asset ที่ไม่ได้ใช้" ไว้
//       ถ้าเรียกด้วยชื่อเป็นข้อความ GameMaker จะตัดไฟล์เสียงทิ้งตอน build)
//   3) ใส่หลายไฟล์ใน [ ] = สุ่มเล่นไม่ให้ซ้ำซาก
// =====================================================================

global.set_music = 70;    // 0-100 ระดับเพลง
global.set_sfx = 100;     // 0-100 ระดับเสียงเอฟเฟกต์

global.snd = {};          // ชื่อสั้น -> [sound, sound, ...]
global.mus = {};          // ชื่อสั้น -> sound (เพลงวนลูป)
global.snd_last = {};     // ชื่อสั้น -> เวลาที่เล่นล่าสุด (กันเสียงเดียวกันซ้อนรัว ๆ ในเฟรมเดียว)

global.music_key = "";    // อยากให้เล่นเพลงไหน
global.music_now = "";    // เพลงที่เล่นอยู่จริง
global.music_inst = -1;
global.music_room = -1;
global.music_vol_now = -1;
global.music_dying = [];  // [[instance, เวลาหยุด], ...] เพลงเก่าที่กำลังเฟดออก

// ★ ใช้แทนเมื่อยังไม่มีไฟล์ของชื่อนั้น (หาไฟล์มาน้อยลงได้)
global.snd_alias = {
    hammer_swing:  "swing",
    swing_spin:    "swing",
    swing_thrust:  "swing",
    whirl:         "swing",
    shoot_spread:  "shoot",
    bolt:          "shoot",
    enemy_shoot:   "shoot",
    hit_boss:      "hit_enemy",
    boss_die:      "enemy_die",
    pickup_item:   "pickup_gold",
    sword_get:     "pickup_item",
    sell:          "buy",
    buff:          "potion",
    gate:          "door",
    lever:         "ui_select",
    plate:         "lever",
    target_hit:    "ui_select",
    checkpoint:    "ui_select",
    break_wood:    "hit_enemy",
    trial_start:   "enemy_alert",
    land:          "footstep",
};

function audio_register() {
    var S = global.snd;
    var M = global.mus;

    // ---------- ต่อสู้ (ผู้เล่น) ----------
    S.swing         = [snd_swing_1];   // ท่าฟัน (คอมโบท่า 1, 2 / ท่า 4 ถ้าคอมโบยาว)
    S.swing_thrust  = [snd_swing_2];   // ท่าแทง (คอมโบท่า 3 / ท่า 5 ถ้าคอมโบยาว)
    S.hammer_swing  = [snd_hammer_swing];
    S.hammer_smash  = [snd_hammer_smash];
    S.charge_start  = [snd_charge_start];   // เริ่มชาร์จค้อน (ยาวพอดีกับเวลาชาร์จเต็ม ~1.3 วิ)
    // S.charge_full   = [snd_charge_full];
    // S.roll          = [snd_roll];
    S.shoot         = [snd_shoot];
    // S.shoot_spread  = [snd_shoot_spread];
    // S.whirl         = [snd_whirl];
    S.swing_spin    = [snd_swing_3];   // ท่าจบคอมโบ ฟาดรอบตัว (ท่า 4 / ท่า 6 ถ้าปลดคอมโบยาว)
    // S.bolt          = [snd_bolt];
    // S.ult           = [snd_ult];
    S.player_hurt   = [snd_player_hurt];
    // S.gameover      = [snd_gameover];

    // ---------- ศัตรู ----------
    S.hit_enemy     = [snd_hit_flesh_1, snd_hit_flesh_2];
    S.hit_boss      = [snd_sword_clashhit, snd_hit_metal];   // บอสใส่เกราะ = เสียงโลหะ
    // S.enemy_die     = [snd_enemy_die];
    // S.enemy_alert   = [snd_enemy_alert];
    // S.enemy_windup  = [snd_enemy_windup];
    S.enemy_attack  = [snd_enemy_attack];
    // S.enemy_shoot   = [snd_enemy_shoot];
    S.boss_roar     = [snd_boss_roar];
    S.boss_phase    = [snd_boss_phase];
    S.boss_die      = [snd_boss_die];
    S.boss_shield   = [snd_shield_impact_from_sword];   // ฟันโดนเกราะบอส

    // ---------- ของ / ร้าน / สกิล ----------
    // S.pickup_gold   = [snd_pickup_gold];
    // S.pickup_item   = [snd_pickup_item];
    S.sword_get     = [snd_sword_get];   // เก็บดาบในวิหาร
    // S.potion        = [snd_potion];
    // S.buff          = [snd_buff];
    // S.buy           = [snd_buy];
    // S.sell          = [snd_sell];
    // S.skill_unlock  = [snd_skill_unlock];
    // S.chest_open    = [snd_chest_open];
    // S.trial_start   = [snd_trial_start];

    // ---------- ฉาก / พัซเซิล ----------
    // S.door          = [snd_door];          // เปลี่ยนฉาก
    // S.gate          = [snd_gate];
    // S.lever         = [snd_lever];
    // S.plate         = [snd_plate];
    // S.target_hit    = [snd_target_hit];
    // S.checkpoint    = [snd_checkpoint];
    // S.break_wood    = [snd_break_wood];
    // S.jump          = [snd_jump];
    // S.land          = [snd_land];
    // S.footstep      = [snd_footstep_1, snd_footstep_2];

    // ---------- UI ----------
    // S.ui_move       = [snd_ui_move];
    // S.ui_select     = [snd_ui_select];
    // S.ui_back       = [snd_ui_back];
    // S.ui_error      = [snd_ui_error];
    // S.blip          = [snd_dialogue_blip];
    // S.title_card    = [snd_title_card];

    // ---------- เพลง (วนลูป) ----------
    // (ตอนนี้มี 2 เพลง ใช้ซ้ำหลายฉากไปก่อน ได้เพลงใหม่ค่อยเปลี่ยนทีละบรรทัด)
    M.menu      = mus_journey_begins;
    M.sanctuary = mus_journey_begins;
    M.forest    = mus_misty_lands;
    M.village   = mus_journey_begins;
    M.mine      = mus_misty_lands;
    M.castle    = mus_misty_lands;
    // M.boss      = mus_boss;      // ยังไม่มี = ห้องบอสเงียบ
    M.ending    = mus_journey_begins;
    // snd_charge_long (เสียงชาร์จยาว 8 วิ) ยังไม่ได้ใช้ที่ไหน
}
audio_register();


// ---------------------------------------------------------------------
// หาเสียงจากชื่อสั้น (รวมชื่อสำรอง) คืน -1 ถ้าไม่มี
// ---------------------------------------------------------------------
function snd_resolve(_key) {
    for (var _k = 0; _k < 3; _k++) {
        if (variable_struct_exists(global.snd, _key)) {
            var _a = global.snd[$ _key];
            var _n = array_length(_a);
            if (_n > 0) return _a[irandom(_n - 1)];
        }
        if (!variable_struct_exists(global.snd_alias, _key)) return -1;
        _key = global.snd_alias[$ _key];
    }
    return -1;
}

// ★ เล่นเสียงเอฟเฟกต์
// _vol = ความดัง 0-1, _pvar = สุ่มระดับเสียงสูงต่ำ (ไม่ให้ซ้ำซาก), _gap = ms ขั้นต่ำก่อนเล่นชื่อเดิมซ้ำ
// _pitch = ระดับเสียงพื้นฐาน (1 = ปกติ, มากกว่า 1 = แหลมขึ้น)
function sfx(_key, _vol = 1, _pvar = 0.08, _gap = 35, _pitch = 1) {
    if (global.set_sfx <= 0) return -1;
    var _t = current_time;
    if (variable_struct_exists(global.snd_last, _key) && _t - global.snd_last[$ _key] < _gap) return -1;
    var _s = snd_resolve(_key);
    if (_s == -1) return -1;
    global.snd_last[$ _key] = _t;
    var _p = _pitch + random_range(-_pvar, _pvar);
    return audio_play_sound(_s, 5, false, _vol * global.set_sfx / 100, 0, _p);
}

// ★ เสียงที่มีตำแหน่ง: ไกลจากกลางจอ = เบาลง (ศัตรูนอกจอไม่ดังเท่าในจอ)
function sfx_at(_key, _x, _y, _vol = 1, _pvar = 0.08, _gap = 35) {
    var _cam = view_camera[0];
    if (_cam == -1 || !view_enabled) return sfx(_key, _vol, _pvar, _gap);
    var _cx = camera_get_view_x(_cam) + camera_get_view_width(_cam) / 2;
    var _cy = camera_get_view_y(_cam) + camera_get_view_height(_cam) / 2;
    var _d = point_distance(_x, _y, _cx, _cy);
    var _near = camera_get_view_width(_cam) * 0.55;   // ในจอ = ดังเต็ม
    var _far = _near * 2.2;                             // ไกลกว่านี้ = ไม่ได้ยิน
    var _f = 1 - clamp((_d - _near) / (_far - _near), 0, 1);
    if (_f <= 0.02) return -1;
    return sfx(_key, _vol * _f, _pvar, _gap);
}


// ---------------------------------------------------------------------
// ★ เพลง
// ---------------------------------------------------------------------
function music_for_room(_r) {
    switch (_r) {
        case rm_menu:                        return "menu";
        case rm_the_sanctuary_ss:            return "sanctuary";
        case rm_level_1_the_forest:          return "forest";
        case rm_the_village:
        case rm_shop_ss:                     return "village";
        case rm_level_2_the_abandoned_mine:  return "mine";
        case rm_level_3_the_castle:
        case rm_the_final_ss:                return "castle";
        case rm_boss:                        return "boss";
        case rm_end:                         return "ending";
    }
    return global.music_key;   // ห้องอื่น (ห้องทดสอบ) = เล่นเพลงเดิมต่อ
}

// สั่งเปลี่ยนเพลงเอง (เช่นตอนบอสโผล่) "" = เงียบ
function music_play(_key) { global.music_key = _key; }
function music_stop() { global.music_key = ""; }

// ★ เรียกทุกเฟรม (จาก obj_scaler) จัดการเปลี่ยนเพลงตามห้อง / เฟด / ปรับระดับเสียง
function audio_update() {
    // เพลงเก่าที่เฟดจบแล้ว = หยุด
    for (var _i = array_length(global.music_dying) - 1; _i >= 0; _i--) {
        var _m = global.music_dying[_i];
        if (current_time >= _m[1]) {
            audio_stop_sound(_m[0]);
            array_delete(global.music_dying, _i, 1);
        }
    }

    if (room != global.music_room) {
        global.music_room = room;
        global.music_key = music_for_room(room);
    }

    // เบราว์เซอร์ยังไม่ให้เล่นเสียง (ผู้เล่นยังไม่คลิก/กดปุ่ม) = รอก่อน
    if (!audio_system_is_available()) exit;

    var _vol = global.set_music / 100;
    var _want = global.music_key;
    if (!variable_struct_exists(global.mus, _want)) _want = "";

    // เพลงที่ควรเล่นอยู่หยุดไปเอง (เช่นเบราว์เซอร์บล็อกตอนแรก) = เริ่มใหม่
    var _alive = (global.music_inst != -1) && audio_is_playing(global.music_inst);

    if (_want != global.music_now || (_want != "" && !_alive)) {
        if (_alive) {
            audio_sound_gain(global.music_inst, 0, 700);
            array_push(global.music_dying, [global.music_inst, current_time + 750]);
        }
        global.music_inst = -1;
        global.music_now = _want;
        if (_want != "") {
            global.music_inst = audio_play_sound(global.mus[$ _want], 10, true, 0);
            audio_sound_gain(global.music_inst, _vol, 900);
            global.music_vol_now = _vol;
        }
    }
    // ปรับระดับเพลงในหน้าตั้งค่า
    else if (_alive && _vol != global.music_vol_now) {
        audio_sound_gain(global.music_inst, _vol, 0);
        global.music_vol_now = _vol;
    }
}


// ---------------------------------------------------------------------
// ★ เสียงหน้าเมนู: เรียกต้น Step ของหน้าเมนูนั้น ๆ
// เลื่อนตัวเลือก (_sel เปลี่ยน) = ติ๊ก, เปลี่ยนหน้า (_screen เปลี่ยน) = เสียงยืนยัน
// _none = ค่าที่แปลว่า "ไม่ได้ชี้อะไร" (ไม่ต้องติ๊กตอนเมาส์ออกนอกรายการ)
// ---------------------------------------------------------------------
function ui_sound_watch(_sel, _screen, _none = -1) {
    if (!variable_instance_exists(id, "ui_snd_sel")) {
        ui_snd_sel = _sel;
        ui_snd_scr = _screen;
        return;
    }
    if (_screen != ui_snd_scr) sfx("ui_select");
    else if (_sel != ui_snd_sel && _sel != _none) sfx("ui_move", 0.6, 0.03);
    ui_snd_sel = _sel;
    ui_snd_scr = _screen;
}
