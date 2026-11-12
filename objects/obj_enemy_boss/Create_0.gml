event_inherited();

is_final = (room == rm_boss);      // บอสสุดท้าย = 3 เฟส / มินิบอส = 2 เฟส
hp = is_final ? 320 : 40;          // ★ บอสใหญ่เลือดเยอะขึ้น (เดิม 200) / มินิบอสตั้งเลือดใหม่ใน Creation Code ของห้อง
max_hp = hp;
move_speed = 1.5;
tint = c_ltgray;
sep_radius = 120;
sep_strength = 0.3;
engage_range = 220;             // บอสถูกดันยาก แต่ดันตัวเล็กออกได้แรง
sight_range = is_final ? 3000 : 1000;   // บอสไล่เมื่อเห็นผู้เล่นในถิ่นตัวเอง

// =====================================================================
// ★ บอสแต่ละตัว (เลือกตามห้องอัตโนมัติ)
// beast = เจ้าป่า (ป่า): ว่องไว กรงเล็บ หลายท่า
// brute = ยักษ์ค้อน (เหมือง): ช้า เลือดเยอะ ตีหนัก
// mage  = จอมเวท (ปราสาท): รักษาระยะ วาร์ป เกราะเวท ลูกไฟ
// dragon = ราชามังกร (บอสสุดท้าย)
// =====================================================================
variant = "dragon";
if (!is_final) {
    if (room == rm_level_1_the_forest) variant = "beast";
    else if (room == rm_level_2_the_abandoned_mine) variant = "brute";
    else variant = "mage";
}
hp_mult = 1;
boss_name = L("ราชามังกร", "The Dragon King");                  // ★ ชื่อที่ขึ้นตอนเปิดตัว
boss_title = L("ผู้ปกครองท้องฟ้าสีเลือด", "Ruler of the Crimson Sky");
intro_done = false;
claw_chain = 0;
claw_side = 1;
tp_cd = 0;
tp_x = x;
tp_y = y;
switch (variant) {
    case "beast":
        boss_name = L("พยัคฆ์ทมิฬ", "Shadow Tiger");
        boss_title = L("เจ้าป่าผู้กระหายเลือด", "Bloodthirsty Lord of the Forest");
        move_speed = 2.4;
        tint = make_color_rgb(215, 150, 110);
        break;
    case "brute":
        boss_name = L("กุมภัณฑ์ศิลา", "Stone Ogre");
        boss_title = L("ยักษ์ค้อนแห่งเหมืองร้าง", "Hammer Giant of the Abandoned Mine");
        move_speed = 1.0;
        hp_mult = 1.6;               // ★ เลือดเยอะกว่าตัวอื่น
        tint = make_color_rgb(170, 140, 120);
        break;
    case "mage":
        boss_name = L("เวทารุณ", "Vetharun");
        boss_title = L("จอมเวทผู้เฝ้าหอคอย", "Archmage of the Tower");
        move_speed = 1.4;
        tint = make_color_rgb(165, 150, 255);
        engage_range = 100000;       // รักษาระยะอยู่แล้ว ช่วงรอจังหวะแรกนับตลอด
        break;
}

phase = 1;
phase_total = is_final ? 3 : 2;
state = "chase";      // chase, trans, burst_windup, burst, spiral_windup, spiral, leap_windup, leap_air, volley_windup, volley, recover
state_timer = 0;
attack_cd = 100;
last_attack = "";
invuln = 0;           // ตอนเปลี่ยนเฟสจะอมตะชั่วคราว
burst_wave = 0;
burst_a0 = 0;
spiral_a = 0;

// ---- ★ กันผู้เล่นยืนยิงตอดจากไกล ----
far_range = 300;      // ไกลกว่านี้ = นับว่ายิงตอด
far_timer = 0;        // เกจยิงตอด เต็มแล้วบอสกระโดดตกใส่
if (variant == "mage") far_range = 99999;   // จอมเวทยิงจากไกลเองอยู่แล้ว ไม่ต้องไล่กระโดด
leap_sx = x;
leap_sy = y;
leap_tx = x;
leap_ty = y;
leap_t = 0;
airborne = false;     // ลอยกลางอากาศ = ไม่โดนดาเมจ
volley_n = 0;

// ---- ★ ท่าเฉพาะบอสใหญ่ + ท่าตอนมีเกราะ ----
erupts = [];          // จุดปะทุบนพื้นที่รอระเบิด {x, y, r, t, t0, dmg} (วาดวงเตือนใน obj_enemy Draw)
dash_chain = 0;       // พุ่งต่อเนื่องอีกกี่ครั้ง
nova_cd = 0;          // คูลดาวน์ระเบิดเกราะ

// ---- ★ ไม้ตาย (บอสใหญ่ เฟส 3 เลือด 20%) ----
ult_used = false;
ult_time = [360, 300, 240][clamp(global.difficulty, 0, 2)];   // ★ เวลาให้ขัดจังหวะ (ง่าย/กลาง/ยาก)
ult_t = 0;
ult_gauge = 0;
ult_need = 1;         // ดาเมจระยะประชิดที่ต้องทำให้ถึงเพื่อขัดจังหวะ (ตั้งตอนเริ่มท่า)
ult_flash = 0;
stun_t = 0;
stun_time = 300;      // ★ ขัดจังหวะสำเร็จ = บอสมึนกี่เฟรม (5 วิ)

// ---- ★ เกราะกันกระสุน: โดนยิงเยอะ หรือสุ่มตั้งเอง กระสุนไม่เข้า ต้องฟันด้วยดาบให้แตก ----
bullet_heat = 0;      // นับกระสุนที่โดนช่วงนี้ (ค่อย ๆ ลดลงเอง)
shield_cd = 240;      // ห้ามตั้งเกราะซ้ำจนกว่าจะหมดเวลานี้
shield_time = 1800;   // ★ เกราะอยู่ได้นานสุด 30 วิ (ลดช้ามาก = ต้องเข้าไปฟันให้แตกเอง)
shield_hp_max = 4;

raise_shield = function() {
    if (shield > 0) return;
    shield = shield_time;
    shield_hp = 3 + phase;   // ★ ฟันกี่ทีแตก (เฟส 1 = 4, 2 = 5, 3 = 6)
    shield_hp_max = shield_hp;
    bullet_heat = 0;
    float_text(x, y - 200, L("เกราะ!", "Shield!"), make_color_rgb(110, 190, 255), 1.3);
    fx_spark(x, y - 70, 0, 18, make_color_rgb(110, 190, 255), 180);
}

end_shield = function(_broken) {
    shield = 0;
    shield_cd = (phase >= 3) ? 420 : 600;
    if (_broken) {
        float_text(x, y - 200, L("เกราะแตก!", "Shield broken!"), c_yellow, 1.4);
        fx_shake(6);
        fx_spark(x, y - 70, 0, 30, make_color_rgb(110, 190, 255), 180);
        // เสียหลัก = ช่วงรางวัลให้รุมฟัน (ถ้าไม่ได้ออกท่า/กระโดดอยู่)
        if (atk_state == "" && (state == "chase" || state == "recover")) {
            state = "recover";
            state_timer = 55;
            telegraph = false;
        }
    }
}

// ---- อมตะช่วงเปลี่ยนเฟส ----
base_take_damage = take_damage;
take_damage = function(_dmg, _dir, _crit = false, _src = "melee") {
    if (invuln > 0 || airborne) return;

    // ★ ระหว่างร่ายไม้ตาย: กระสุนไม่เข้า ฟันระยะประชิดสะสมเกจขัดจังหวะ
    if (state == "ult") {
        if (_src == "bullet") {
            fx_spark(x, y - 70, _dir + 180, 6, c_red);
            return;
        }
        ult_gauge += _dmg;
        if (ult_gauge >= ult_need) ult_interrupt();
        base_take_damage(_dmg, _dir, _crit, _src);
        return;
    }

    if (_src == "bullet") {
        // ★ เกราะอยู่ = กระสุนเด้งออก ไม่เสียเลือด
        if (shield > 0) {
            fx_spark(x, y - 70, _dir + 180, 6, make_color_rgb(110, 190, 255));
            if (dist_to_player() > far_range) far_timer += 25;
            return;
        }
        // โดนยิงเยอะเกิน = ตั้งเกราะ
        bullet_heat++;
        var _limit = (phase == 1) ? 9 : ((phase == 2) ? 8 : 7);   // ★ โดนกี่นัดถึงตั้งเกราะ
        if (bullet_heat >= _limit && shield_cd <= 0 && state != "trans") raise_shield();
    } else if (shield > 0) {
        // ★ ฟันด้วยดาบ = เข้าเลือดน้อยมาก (10%) แต่กะเทาะเกราะ ต้องฟันให้แตกก่อนถึงจะตีเข้าเต็ม
        _dmg = max(1, round(_dmg * 0.1));
        _crit = false;
        fx_spark(x, y - 70, _dir, 8, make_color_rgb(110, 190, 255));
        shield_hp--;
        if (shield_hp <= 0) end_shield(true);
    }

    // โดนยิงจากไกล = เกจยิงตอดขึ้นเร็ว และไม่มีช่วงรอจังหวะแรก (ผู้เล่นเลือกตีจากไกลเอง)
    if (dist_to_player() > far_range) {
        far_timer += 25;
        engage_grace = 0;
    }

    // =====================================================================
    // ★ บังคับให้เรียนรู้ "หลบ แล้วสวน" (เดิมยืนฟันรัว + กินยาก็ผ่าน)
    //   - ช่วงบอสเพิ่งออกท่าเสร็จ / มึน = ช่องสวน: ฟันเข้าแรงขึ้น x1.4
    //   - ช่วงอื่น (บอสพร้อมสู้) = บอสตั้งรับ: ฟันเข้าแค่ x0.6
    //   - ยืนฟันใส่ตอนบอสพร้อมสู้ 4 ครั้งติด = บอสสวนกลับทันที (ต้องหลบ)
    // =====================================================================
    if (_src != "bullet" && shield <= 0) {
        var _open = (atk_state == "recover") || (state == "recover") || (state == "stunned");
        if (_open) {
            _dmg = max(1, round(_dmg * 1.4));
            if (!counter_shown) {
                counter_shown = true;
                float_text(x, y - 170, L("สวน!", "Counter!"), make_color_rgb(255, 220, 90), 1.2);
            }
        } else {
            counter_shown = false;
            if (atk_state == "") _dmg = max(1, round(_dmg * 0.6));
            if (current_time - poke_time > 1500) poke = 0;
            poke_time = current_time;
            if (state == "chase" && atk_state == "") {
                poke++;
                if (poke >= 4 && hp - _dmg > 0) {
                    poke = 0;
                    boss_counter();
                }
            }
        }
    }
    base_take_damage(_dmg, _dir, _crit, _src);
}

// ★ สวนกลับคนที่ยืนฟันรัว: ท่ากวาดรอบตัวของแต่ละบอส (มีวงเตือนปกติ หลบได้)
poke = 0;
poke_time = 0;
counter_shown = false;
boss_counter = function() {
    float_text(x, y - 200, L("สวนกลับ!", "Counterattack!"), c_red, 1.3);
    switch (variant) {
        case "beast": begin_attack("beast_rake"); break;
        case "brute": begin_attack("brute_pound"); break;
        case "mage":  if (nova_cd <= 0) start_nova(); else begin_attack("beast_rake"); break;
        default:      begin_attack(phase >= 2 ? "boss_slam" : "beast_rake"); break;
    }
    attack_cd = max(attack_cd, 30);
}

// ---- ★ ท่ากระโดดตกใส่ (ไล่ระยะผู้เล่นที่หนีไปยิงจากไกล) ----
start_leap = function() {
    if (!instance_exists(obj_player)) return;
    state = "leap_windup";
    state_timer = (phase >= 3) ? 24 : 30;
    telegraph = true;
    far_timer = 0;
    last_attack = "leap";
    leap_tx = obj_player.x;
    leap_ty = obj_player.y;
    marker = [leap_tx, leap_ty, 115, false];
}

leap_land = function() {
    z = 0;
    airborne = false;
    marker = undefined;
    var _h = instance_create_depth(x, y, depth, obj_enemy_hitbox);
    _h.owner = id;
    _h.atk = enemy_attack_data("boss_leap");
    _h.lift = _h.atk.lift;
    fx_shake(8);
    fx_spark(x, y - 20, 0, 24, c_ltgray, 180);
    // เฟส 2 ขึ้นไป: ลงแล้วมีวงกระสุนกระจาย
    if (phase >= 2) {
        var _n = (phase >= 3) ? 12 : 8;
        var _a0 = irandom(359);
        for (var _j = 0; _j < _n; _j++) {
            var _b = instance_create_depth(x, y, depth, obj_enemy_bullet); _b.from_boss = true;
            _b.direction = _a0 + _j * (360 / _n);
            _b.image_angle = _b.direction;
            _b.speed = 4.5;
        }
    }
    state = "recover";
    state_timer = 30;
    attack_cd = 20;   // ลงแล้วถ้าผู้เล่นอยู่ใกล้ ฟาดต่อได้ไว
}

// =====================================================================
// ★ จุดปะทุบนพื้น (ใช้กับหนามพุ่ง / อุกกาบาต / คลื่นวงแหวน)
// =====================================================================
add_erupt = function(_x, _y, _r, _delay, _dmg, _fx = "") {
    if (position_meeting(_x, _y, obj_wall)) return;
    if (!point_in_rectangle(_x, _y, 0, 0, room_width, room_height)) return;
    array_push(erupts, { x: _x, y: _y, r: _r, t: _delay, t0: _delay, dmg: _dmg, fx: _fx });
}

process_erupts = function() {
    var _big = false;
    for (var _i = array_length(erupts) - 1; _i >= 0; _i--) {
        var _e = erupts[_i];
        _e.t--;
        if (_e.t == 0) {
            fx_spark(_e.x, _e.y - 10, 90, 6, c_orange, 120);
            if (_e.r >= 60) _big = true;
            if (instance_exists(obj_player) && player_hit_by_circle(obj_player, _e.x, _e.y - 10, _e.r)) {
                var _hp0 = obj_player.hp;
                obj_player.take_damage(enemy_damage_calc(_e.dmg, true), _e.x, _e.y);
                if (_e.fx != "" && obj_player.hp < _hp0) player_add_status(_e.fx);   // ★ ติดสถานะ
            }
        }
        if (_e.t <= -12) array_delete(erupts, _i, 1);
    }
    if (_big) fx_shake(2);
}

// ท่า: หนามพุ่ง 3 แนวเป็นพัดไปหาผู้เล่น ปะทุไล่จากใกล้ไปไกล
start_spikes = function() {
    var _a = dir_to_player();
    var _n = 8;
    for (var _l = -1; _l <= 1; _l++) {
        for (var _i = 0; _i < _n; _i++) {
            var _d = 90 + _i * 65;
            add_erupt(x + lengthdir_x(_d, _a + _l * 24), y + lengthdir_y(_d, _a + _l * 24), 40, 36 + _i * 5, 1);
        }
    }
    state = "cast";
    state_timer = 36 + _n * 5 + 12;
    telegraph = true;
}

// ท่า: อุกกาบาตตกรอบตัวผู้เล่น (1 ลูกตรงตัว ที่เหลือสุ่มรอบ ๆ)
start_meteor = function() {
    if (!instance_exists(obj_player)) return;
    var _n = (phase >= 3) ? 9 : 7;
    for (var _i = 0; _i < _n; _i++) {
        var _tx = obj_player.x;
        var _ty = obj_player.y;
        if (_i > 0) {
            var _ra = irandom(359);
            var _rd = random_range(90, 260);
            _tx += lengthdir_x(_rd, _ra);
            _ty += lengthdir_y(_rd, _ra);
        }
        add_erupt(_tx, _ty, 64, 46 + _i * 8, 2, "burn");   // ★ อุกกาบาตไฟ
    }
    state = "cast";
    state_timer = 46 + _n * 8 + 12;
    telegraph = true;
}

// ท่า: คลื่นวงแหวนขยายออก 4 ชั้น แต่ละชั้นมีช่องว่าง (หาช่อง หรือกลิ้งผ่าน)
start_rings = function() {
    var _gap = irandom(359);
    for (var _ring = 0; _ring < 4; _ring++) {
        var _rad = 130 + _ring * 100;
        var _cnt = ceil(2 * pi * _rad / 76);
        for (var _i = 0; _i < _cnt; _i++) {
            var _ang = _i * 360 / _cnt;
            if (abs(angle_difference(_ang, _gap)) < 32) continue;   // ช่องว่าง
            add_erupt(x + lengthdir_x(_rad, _ang), y + lengthdir_y(_rad, _ang), 38, 34 + _ring * 18, 1);
        }
        _gap += choose(-50, 50);   // ช่องของชั้นถัดไปเลื่อนไป
    }
    state = "cast";
    state_timer = 34 + 3 * 18 + 14;
    telegraph = true;
}

// ★ ท่าตอนมีเกราะ (บอสทุกตัว): ผู้เล่นเข้ามาฟันใกล้ ๆ = ระเบิดเกราะดันออก (มีวงเตือน)
start_nova = function() {
    state = "nova";
    state_timer = 28;
    telegraph = true;
    nova_cd = 200;
    marker = [x, y, 150, false];
}

// =====================================================================
// ★ ไม้ตาย: ร่ายพลังกลางห้อง ขัดจังหวะไม่ทัน = ตายทันที / ทัน = บอสมึนนาน
// =====================================================================
start_ult = function() {
    ult_used = true;
    state = "ult";
    ult_t = ult_time;
    ult_gauge = 0;
    ult_need = player_atk() * 9;   // ★ ประมาณฟันดาบ 9 ที (ค้อนน้อยครั้งกว่า)
    shield = 0;
    erupts = [];
    marker = undefined;
    telegraph = true;
    with (obj_enemy_bullet) instance_destroy();
    with (obj_enemy_hitbox) instance_destroy();
    float_text(x, y - 220, L("ไม้ตาย!", "Ultimate!"), c_red, 1.8);
    fx_shake(6);
}

ult_interrupt = function() {
    state = "stunned";
    stun_t = stun_time;
    telegraph = false;
    tint = c_gray;
    flash = 12;
    fx_shake(9);
    fx_spark(x, y - 80, 90, 36, c_yellow, 180);
    float_text(x, y - 220, L("ขัดจังหวะสำเร็จ! บอสมึนงง", "Interrupted! Boss stunned"), c_yellow, 1.5);
}

// ---- เรียกลูกน้อง (หาจุดที่ไม่ติดกำแพง) ----
summon = function(_obj, _n, _drop) {
    if (instance_number(obj_enemy) > 9) return;
    for (var _i = 0; _i < _n; _i++) {
        var _a = irandom(359);
        for (var _t = 0; _t < 12; _t++) {
            var _sx = x + lengthdir_x(150 + _t * 10, _a + _t * 30);
            var _sy = y + lengthdir_y(150 + _t * 10, _a + _t * 30);
            if (collision_rectangle(_sx - 32, _sy - 32, _sx + 32, _sy + 32, obj_wall, false, true) == noone) {
                var _m = instance_create_depth(_sx, _sy, depth, _obj);
                _m.master = id;
                _m.no_drop = !_drop;
                _m.alert_timer = 400;
                break;
            }
        }
    }
}

// =====================================================================
// ★ ท่าของบอสเล็กแต่ละตัว
// =====================================================================
// เจ้าป่า: ข่วนต่อเนื่องหลายที สลับซ้ายขวา เล็งใหม่ทุกที
start_claws = function(_n) {
    claw_chain = _n - 1;
    claw_side = choose(-1, 1);
    begin_attack(claw_side > 0 ? "beast_claw_r" : "beast_claw_l");
}

// ยักษ์: รอยแยกพื้นพุ่งเป็นเส้นไปหาผู้เล่น
start_fissure = function() {
    var _a = dir_to_player();
    for (var _i = 0; _i < 8; _i++) {
        var _d = 80 + _i * 70;
        add_erupt(x + lengthdir_x(_d, _a), y + lengthdir_y(_d, _a), 54, 42 + _i * 4, 2);
    }
    state = "cast";
    state_timer = 42 + 8 * 4 + 14;
    telegraph = true;
}

// ยักษ์: ขว้างก้อนหินใหญ่ใส่ (เฟส 2 = 3 ก้อน)
start_boulder = function() {
    if (!instance_exists(obj_player)) return;
    var _n = (phase >= 2) ? 3 : 1;
    for (var _i = 0; _i < _n; _i++) {
        var _tx = obj_player.x + ((_i == 0) ? 0 : lengthdir_x(150, irandom(359)));
        var _ty = obj_player.y + ((_i == 0) ? 0 : lengthdir_y(150, irandom(359)));
        add_erupt(_tx, _ty, 82, 56 + _i * 14, 3, "stun");   // ★ หินทับ = มึน
    }
    state = "cast";
    state_timer = 56 + _n * 14 + 12;
    telegraph = true;
}

// จอมเวท: วาร์ปไปจุดที่ห่างผู้เล่นพอดี ๆ
start_teleport = function() {
    if (!instance_exists(obj_player)) return;
    var _found = false;
    for (var _k = 0; _k < 20 && !_found; _k++) {
        var _a = irandom(359);
        var _d = random_range(280, 380);
        var _tx = obj_player.x + lengthdir_x(_d, _a);
        var _ty = obj_player.y + lengthdir_y(_d, _a);
        if (!is_undefined(zone) && !point_in_rectangle(_tx, _ty, zone[0] + 40, zone[1] + 40, zone[2] - 40, zone[3] - 40)) continue;
        if (collision_rectangle(_tx - 50, _ty - 50, _tx + 50, _ty + 10, obj_wall, false, true) != noone) continue;
        tp_x = _tx;
        tp_y = _ty;
        _found = true;
    }
    if (!_found) return;
    state = "tp";
    state_timer = 18;
    telegraph = true;
    tp_cd = (phase >= 2) ? 130 : 170;
}

// จอมเวท: เรียกลูกไฟลอยรอบผู้เล่น ไม่ทำลายภายในเวลา = ระเบิดเป็นกระสุนรอบทิศ
start_orbs = function() {
    if (!instance_exists(obj_player)) return;
    var _n = (phase >= 2) ? 3 : 2;
    var _a0 = irandom(359);
    for (var _i = 0; _i < _n; _i++) {
        var _a = _a0 + _i * (360 / _n);
        var _ox = obj_player.x + lengthdir_x(230, _a);
        var _oy = obj_player.y + lengthdir_y(230, _a);
        if (collision_rectangle(_ox - 24, _oy - 24, _ox + 24, _oy + 24, obj_wall, false, true) != noone) {
            _ox = x + lengthdir_x(120, _a);
            _oy = y + lengthdir_y(120, _a);
        }
        var _o = instance_create_depth(_ox, _oy, depth, obj_enemy);
        _o.is_orb = true;
        _o.orb_t = 240;               // ★ เวลาก่อนระเบิด (4 วิ)
        _o.orb_t0 = 240;
        _o.diff_applied = true;       // ไม่คูณเลือด = ตีทีเดียวแตก
        _o.hp = 1;
        _o.max_hp = 1;
        _o.hp_shown = 1;
        _o.show_bar = false;
        _o.no_drop = true;
        _o.master = id;
        _o.alert_timer = 999;
        _o.ai = method(_o, orb_ai);
        fx_spark(_ox, _oy - 40, 90, 10, c_orange, 180);
    }
    float_text(x, y - 200, L("ลูกไฟ! ทำลายก่อนมันระเบิด", "Fire orb! Destroy it before it explodes"), c_orange, 1.1);
    state = "recover";
    state_timer = 30;
}

// เลือกท่าตามชนิดบอส ระยะ และเฟส
attack_options = function(_d) {
    var _o = [];
    switch (variant) {
        case "beast":
            if (_d < 170) {
                array_push(_o, "claws", "claws", "rake");
            } else {
                array_push(_o, "lunge", "pounce");
                if (_d < 320) array_push(_o, "claws");
            }
            if (phase >= 2) array_push(_o, "lunge");
            break;
        case "brute":
            if (_d < 190) {
                array_push(_o, "smash", "pound");
            } else {
                array_push(_o, "fissure", "boulder");
            }
            if (phase >= 2) array_push(_o, (_d < 190) ? "pound" : "fissure");
            break;
        case "mage":
            array_push(_o, "bolts", "orbs", "arcane_rings");
            if (phase >= 2) array_push(_o, "arcane_rain");
            break;
        default:   // ราชามังกร: ท่าครบชุด
            if (_d < 170) {
                array_push(_o, "swing");
                if (phase >= 2) array_push(_o, "slam");
            } else {
                array_push(_o, "dash", "bolts");
                if (phase >= 2) array_push(_o, "burst");
                if (_d > far_range) array_push(_o, "leap");
            }
            if (phase >= 3) array_push(_o, "spiral");
            array_push(_o, "spikes");
            if (phase >= 2) array_push(_o, "meteor", "rings");
            if (phase >= 3 && _d >= 170) array_push(_o, "dash_chain");
            break;
    }
    // สุ่มตั้งเกราะเองบ้าง (จอมเวทตั้งบ่อยกว่า)
    var _gchance = (variant == "mage") ? 2 : 3;
    if (shield <= 0 && shield_cd <= 0 && irandom(_gchance) == 0) array_push(_o, "guard");
    return _o;
}

// ---- เข้าเฟสใหม่ ----
enter_phase = function(_n) {
    phase = _n;
    state = "trans";
    state_timer = 60;
    invuln = 60;
    telegraph = true;
    flash = 30;
    atk_state = "";
    atk_cur = undefined;
    z = 0;
    airborne = false;
    marker = undefined;
    far_timer = 0;
    shield = 0;
    shield_cd = 120;
    erupts = [];
    dash_chain = 0;
    with (obj_enemy_bullet) instance_destroy();
    with (obj_enemy_hitbox) instance_destroy();

    if (_n == 2) {
        move_speed = 2.2;
        if (variant == "beast") move_speed = 3.0;
        if (variant == "brute") move_speed = 1.3;
        if (variant == "mage")  move_speed = 1.7;
        if (is_final) summon(obj_enemy_shooter, 2, false);
        else if (variant != "mage") summon(obj_enemy, 2, true);
        if (variant == "mage") { shield = 0; shield_cd = 0; raise_shield(); }   // จอมเวทเข้าเฟส 2 พร้อมเกราะ
    }
    if (_n == 3) {
        move_speed = 2.7;
        summon(obj_enemy_dasher, 2, false);
    }
    float_text(x, y - 200, is_final ? (L("เฟส ", "Phase ") + string(_n)) : L("โกรธแล้ว!", "Enraged!"), c_red, 1.6);
}

ai = function() {
    if (invuln > 0) invuln--;
    if (nova_cd > 0) nova_cd--;
    if (tp_cd > 0) tp_cd--;

    // ★ เปิดตัวบอส (ครั้งแรกที่เห็นผู้เล่น)
    if (!intro_done) {
        intro_done = true;
        boss_intro_start(id, boss_name, boss_title);
    }
    if (ult_flash > 0) ult_flash--;
    process_erupts();

    // เกราะ / เกจกระสุน
    if (shield > 0) {
        shield--;
        if (shield <= 0) end_shield(false);
    } else if (shield_cd > 0) {
        shield_cd--;
    }
    bullet_heat = max(0, bullet_heat - 1 / 45);   // ★ ลด 1 นัดทุก ~0.75 วิ

    // ตรวจเงื่อนไขเปลี่ยนเฟส
    if (is_final) {
        if (phase == 1 && hp <= max_hp * 2 / 3) enter_phase(2);
        else if (phase == 2 && hp <= max_hp / 3) enter_phase(3);
    } else if (phase == 1 && hp <= max_hp / 2) {
        enter_phase(2);
    }

    // ★ ไม้ตาย: เลือดเหลือ 20% ในเฟส 3 (ครั้งเดียว)
    if (is_final && !ult_used && phase >= 3 && hp <= max_hp * 0.2 && state == "chase" && atk_state == "") {
        start_ult();
    }

    // ท่าที่มี hitbox (swing, slam, dash) กำลังทำงานอยู่
    if (run_attack()) exit;

    // ★ เจ้าป่า: ข่วนต่อทันที สลับซ้ายขวา
    if (claw_chain > 0 && state == "chase") {
        claw_chain--;
        claw_side *= -1;
        begin_attack(claw_side > 0 ? "beast_claw_r" : "beast_claw_l");
        if (!is_undefined(atk_cur) && claw_chain == 0) atk_cur.recover = 34;   // ทีสุดท้ายพักนาน = ช่องสวน
        exit;
    }

    // ★ พุ่งต่อเนื่อง: จบครั้งหนึ่งแล้วเล็งใหม่พุ่งต่อทันที
    if (dash_chain > 0 && state == "chase") {
        dash_chain--;
        begin_attack("boss_dash_fast");
        if (!is_undefined(atk_cur) && dash_chain == 0) atk_cur.recover = 45;   // ครั้งสุดท้ายพักนานขึ้น
        exit;
    }

    var _d = dist_to_player();

    switch (state) {
        case "trans":
            // ยืนนิ่ง ตัวสั่น อมตะ
            state_timer--;
            if (state_timer <= 0) {
                telegraph = false;
                state = "chase";
                attack_cd = 40;
            }
            break;

        case "chase":
            telegraph = false;

            strafe_timer--;
            if (strafe_timer <= 0) {
                strafe_sign *= -1;
                strafe_timer = irandom_range(60, 150);
            }
            if (variant == "mage") {
                strafe(320, move_speed);   // จอมเวทวนรักษาระยะ ไม่เดินเข้าหา
            } else if (_d > 110) {
                var _dir = dir_to_player() + 25 * strafe_sign * clamp((_d - 150) / 250, 0, 1);
                hsp = lengthdir_x(move_speed, _dir);
                vsp = lengthdir_y(move_speed, _dir);
            }

            // ★ จอมเวท: ผู้เล่นเข้ามาใกล้ = วาร์ปหนี (ถ้ามีเกราะจะระเบิดเกราะก่อน)
            if (variant == "mage" && _d < 170 && tp_cd <= 0 && !(shield > 0 && nova_cd <= 0)) {
                start_teleport();
                if (state == "tp") break;
            }

            // ★ เกจยิงตอด: ผู้เล่นอยู่ไกลสะสมขึ้น เข้ามาใกล้ลดลง เต็มแล้วกระโดดใส่ทันที (ไม่สนคูลดาวน์)
            if (_d > far_range) far_timer++;
            else far_timer = max(0, far_timer - 2);
            var _far_limit = (phase == 1) ? 150 : ((phase == 2) ? 110 : 80);
            if (far_timer >= _far_limit) {
                start_leap();
                break;
            }

            // ★ มีเกราะ + ผู้เล่นมาฟันใกล้ ๆ = ระเบิดเกราะ
            if (shield > 0 && _d < 170 && nova_cd <= 0) {
                start_nova();
                break;
            }

            if (attack_cd > 0) {
                attack_cd--;
            } else if (can_attack() || _d > far_range) {
                // เลือกท่าตามระยะและเฟส ไม่ซ้ำท่าเดิมถ้ามีตัวเลือกอื่น
                var _opts = attack_options(_d);

                var _pick = _opts[irandom(array_length(_opts) - 1)];
                if (_pick == last_attack && array_length(_opts) > 1) {
                    for (var _k = 0; _k < array_length(_opts); _k++) {
                        if (_opts[_k] != last_attack) {
                            _pick = _opts[_k];
                            break;
                        }
                    }
                }
                last_attack = _pick;

                switch (_pick) {
                    case "swing": begin_attack("boss_swing"); break;
                    case "slam":  begin_attack("boss_slam"); break;
                    case "dash":  begin_attack("boss_dash"); break;
                    case "leap":  start_leap(); break;
                    case "spikes": start_spikes(); break;
                    case "meteor": start_meteor(); break;
                    case "rings":  start_rings(); break;
                    case "dash_chain":
                        dash_chain = 2;   // รวม 3 ครั้ง
                        begin_attack("boss_dash_fast");
                        break;
                    case "guard":
                        raise_shield();
                        break;
                    case "volley":
                    case "bolts":
                        state = "volley_windup";
                        state_timer = 24;
                        break;
                    // เจ้าป่า
                    case "claws":  start_claws((phase >= 2) ? 4 : 3); break;
                    case "rake":   begin_attack("beast_rake"); break;
                    case "lunge":  begin_attack("beast_lunge"); break;
                    case "pounce": start_leap(); break;
                    // ยักษ์
                    case "smash":  begin_attack("brute_smash"); break;
                    case "pound":
                        begin_attack("brute_pound");
                        // เฟส 2: ทุบแล้วมีคลื่นหินแตกออกเป็นวง
                        if (phase >= 2 && !is_undefined(atk_cur)) {
                            for (var _pi = 0; _pi < 14; _pi++) {
                                var _pa2 = _pi * 360 / 14;
                                add_erupt(x + lengthdir_x(240, _pa2), y + lengthdir_y(240, _pa2), 44, atk_cur.windup + 16, 2);
                            }
                        }
                        break;
                    case "fissure": start_fissure(); break;
                    case "boulder": start_boulder(); break;
                    // จอมเวท
                    case "orbs":         start_orbs(); break;
                    case "arcane_rings": start_rings(); break;
                    case "arcane_rain":  start_meteor(); break;
                    case "burst":
                        state = "burst_windup";
                        state_timer = 30;
                        break;
                    case "spiral":
                        state = "spiral_windup";
                        state_timer = 40;
                        break;
                }
                attack_cd = (phase == 1) ? 90 : ((phase == 2) ? 50 : 35);
                if (variant == "beast") attack_cd = (phase == 1) ? 50 : 34;    // ★ เจ้าป่าบุกถี่
                if (variant == "brute") attack_cd = (phase == 1) ? 105 : 80;   // ★ ยักษ์ช้าแต่หนัก
                if (variant == "mage")  attack_cd = (phase == 1) ? 75 : 55;
                if (_pick == "guard") attack_cd = 25;   // ตั้งเกราะแล้วเดินหน้าบุกต่อเลย
            }
            break;

        // ---- ★ กระโดด: ตามจุดผู้เล่นจนเหลือ 10 เฟรมแล้วล็อก ----
        case "leap_windup":
            state_timer--;
            if (state_timer > 10 && instance_exists(obj_player)) {
                leap_tx = obj_player.x;
                leap_ty = obj_player.y;
            } else {
                marker[3] = true;
            }
            marker[0] = leap_tx;
            marker[1] = leap_ty;
            if (state_timer <= 0) {
                telegraph = false;
                // จุดตกอยู่ในกำแพง = หาที่ว่างใกล้ ๆ
                if (place_meeting(leap_tx, leap_ty, obj_wall)) {
                    var _found = false;
                    for (var _lr = 16; _lr <= 96 && !_found; _lr += 16) {
                        for (var _aa = 0; _aa < 360 && !_found; _aa += 45) {
                            if (!place_meeting(leap_tx + lengthdir_x(_lr, _aa), leap_ty + lengthdir_y(_lr, _aa), obj_wall)) {
                                leap_tx += lengthdir_x(_lr, _aa);
                                leap_ty += lengthdir_y(_lr, _aa);
                                _found = true;
                            }
                        }
                    }
                    marker[0] = leap_tx;
                    marker[1] = leap_ty;
                }
                state = "leap_air";
                leap_sx = x;
                leap_sy = y;
                leap_t = 0;
                airborne = true;
            }
            break;

        case "leap_air":
            leap_t++;
            var _air = (phase >= 3) ? 28 : 34;
            var _lk = min(1, leap_t / _air);
            x = lerp(leap_sx, leap_tx, _lk);
            y = lerp(leap_sy, leap_ty, _lk);
            z = sin(_lk * pi) * 170;
            hsp = 0;
            vsp = 0;
            kb_x = 0;
            kb_y = 0;
            if (_lk >= 1) leap_land();
            break;

        // ---- ★ ยิงเล็ง: 3 ชุด ชุดละ 3 ลูก (เฟส 3 = 5 ลูก) ไม่เล็งดักตอนกลิ้ง ----
        case "volley_windup":
            telegraph = true;
            state_timer--;
            if (state_timer <= 0) {
                telegraph = false;
                volley_n = 0;
                state = "volley";
                state_timer = 0;
            }
            break;

        case "volley":
            state_timer--;
            if (state_timer <= 0 && instance_exists(obj_player)) {
                var _vn = (phase >= 3) ? 5 : 3;
                var _va = point_direction(x, y, obj_player.x, obj_player.y);
                for (var _v = 0; _v < _vn; _v++) {
                    var _vb = instance_create_depth(x, y, depth, obj_enemy_bullet); _vb.from_boss = true;
                    _vb.direction = _va + (_v - (_vn - 1) / 2) * 14;
                    _vb.image_angle = _vb.direction;
                    _vb.speed = 6.5;
                    if (variant == "mage") _vb.fx = "burn";   // ★ เวทไฟ
                }
                volley_n++;
                state_timer = 16;
                if (volley_n >= 3) {
                    state = "recover";
                    state_timer = 40;
                }
            }
            break;

        // ---- ★ จอมเวทวาร์ป ----
        case "tp":
            state_timer--;
            flash = (state_timer mod 4 < 2) ? 2 : 0;
            if (state_timer <= 0) {
                fx_spark(x, y - 60, 90, 16, make_color_rgb(165, 150, 255), 180);
                x = tp_x;
                y = tp_y;
                fx_spark(x, y - 60, 90, 16, make_color_rgb(165, 150, 255), 180);
                telegraph = false;
                state = "chase";
                attack_cd = min(attack_cd, 20);
            }
            break;

        // ---- ★ ยืนร่าย (หนาม / อุกกาบาต / วงแหวน) รอให้ปะทุจนจบ ----
        case "cast":
            state_timer--;
            if (state_timer <= 0) {
                telegraph = false;
                state = "recover";
                state_timer = 30;
            }
            break;

        // ---- ★ ระเบิดเกราะ ----
        case "nova":
            state_timer--;
            marker[0] = x;
            marker[1] = y;
            if (state_timer <= 10) marker[3] = true;
            if (state_timer <= 0) {
                telegraph = false;
                marker = undefined;
                fx_shake(5);
                fx_spark(x, y - 40, 0, 26, make_color_rgb(110, 190, 255), 180);
                if (instance_exists(obj_player) && player_hit_by_circle(obj_player, x, y - 40, 150)) {
                    var _p = obj_player;
                    var _hp0 = _p.hp;
                    _p.take_damage(enemy_damage_calc(1, true), x, y);
                    if (_p.hp < _hp0) {   // ดันกระเด็นแรงกว่าปกติ
                        var _pa = point_direction(x, y, _p.x, _p.y);
                        _p.kb_x = lengthdir_x(15, _pa);
                        _p.kb_y = lengthdir_y(15, _pa);
                    }
                }
                state = "recover";
                state_timer = 25;
            }
            break;

        // ---- ★ ไม้ตาย: ร่ายพลัง ----
        case "ult":
            hsp = 0;
            vsp = 0;
            ult_t--;
            if (ult_t mod 30 == 0) fx_shake(1 + 3 * (1 - ult_t / ult_time));
            if (ult_t <= 0) {
                state = "ult_boom";
                state_timer = 40;
                ult_flash = 30;
                fx_shake(14);
                fx_spark(x, y - 80, 0, 60, c_red, 180);
            }
            break;

        // ระเบิดทั้งห้อง 40 เฟรม (กลิ้งหลบไม่พ้น)
        case "ult_boom":
            state_timer--;
            if (instance_exists(obj_player) && !global.god) {
                with (obj_player) {
                    invuln_timer = 0;
                    dodge_timer = 0;
                    if (state != PState.ROLL && hp > 0) take_damage(hp + 99, other.x, other.y);
                }
            }
            if (state_timer <= 0) {
                telegraph = false;
                state = "recover";
                state_timer = 60;
            }
            break;

        // ---- ★ มึนงงหลังโดนขัดจังหวะ ----
        case "stunned":
            hsp = 0;
            vsp = 0;
            stun_t--;
            if (stun_t <= 0) {
                tint = c_ltgray;
                state = "chase";
                attack_cd = 30;
            }
            break;

        case "burst_windup":
            telegraph = true;
            state_timer--;
            if (state_timer <= 0) {
                telegraph = false;
                burst_a0 = irandom(359);
                burst_wave = 0;
                state = "burst";
                state_timer = 0;
            }
            break;

        case "burst":
            // วงกระสุน เหลื่อมกันครึ่งช่อง (เฟส 3 = 12 ทิศ 3 ชั้น)
            state_timer--;
            if (state_timer <= 0) {
                var _dirs = (phase >= 3) ? 12 : 8;
                var _waves = (phase >= 3) ? 3 : 2;
                var _step = 360 / _dirs;
                for (var _j = 0; _j < _dirs; _j++) {
                    var _b = instance_create_depth(x, y, depth, obj_enemy_bullet); _b.from_boss = true;
                    _b.direction = burst_a0 + burst_wave * (_step / 2) + _j * _step;
                    _b.image_angle = _b.direction;
                    _b.speed = (phase >= 3) ? 5.5 : 5;
                }
                burst_wave++;
                state_timer = 18;
                if (burst_wave >= _waves) {
                    state = "recover";
                    state_timer = 45;
                }
            }
            break;

        case "spiral_windup":
            telegraph = true;
            state_timer--;
            if (state_timer <= 0) {
                telegraph = false;
                spiral_a = irandom(359);
                state = "spiral";
                state_timer = 150;
            }
            break;

        case "spiral":
            // หมุนยิงกระสุน 2 ทางสวนกัน ยืนนิ่ง
            if (state_timer mod 5 == 0) {
                for (var _s = 0; _s < 2; _s++) {
                    var _sb = instance_create_depth(x, y, depth, obj_enemy_bullet);
                    _sb.direction = spiral_a + _s * 180;
                    _sb.image_angle = _sb.direction;
                    _sb.speed = 4.5;
                }
                spiral_a += 14;
            }
            state_timer--;
            if (state_timer <= 0) {
                state = "recover";
                state_timer = 50;
            }
            break;

        case "recover":
            state_timer--;
            if (state_timer <= 0) state = "chase";
            break;
    }
}

// มินิบอสที่เคยปราบแล้วจะไม่เกิดใหม่ (ฟาร์มศัตรูทั่วไปได้ แต่บอสไม่กลับมาขวางทาง)
if (room != rm_boss && flag_get("boss_" + room_get_name(room))) {
    no_drop = true;
    instance_destroy();
}
