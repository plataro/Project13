display_set_gui_size(960, 540);

mask_index = spr_mask_small;
chest = 56;
aim_height = 10; // จุดอ้างอิงการเล็งและ Hitbox

state = PState.MOVE;

// ---- การเคลื่อนที่: เดิน / วิ่ง พร้อมแรงเฉื่อย ----
move_speed = 4;         // ความเร็วเดิน
run_speed = 6.5;        // ความเร็ววิ่ง (กด Shift ค้าง วิ่งได้ไม่จำกัด)
walk_accel = 1.2;       // เดินออกตัว (ค่ามาก = ออกตัวไว)
run_accel = 0.28;       // วิ่งออกตัวช้า ๆ ถึงความเร็วเต็มใน ~23 เฟรม (ค่าน้อย = ออกตัวช้า)
walk_friction = 1.0;    // เดินแล้วหยุด หยุดไว
slide_friction = 0.32;  // วิ่งแล้วหยุด ไถลต่อ (ค่าน้อย = ไถลไกล ~65px)
turn_boost = 2.5;       // หักเลี้ยวระหว่างวิ่งตอบสนองไวขึ้นกี่เท่า
mvx = 0;                // ความเร็วจริงที่สะสมอยู่ (แรงเฉื่อย)
mvy = 0;
sliding = false;

roll_speed = 10;
roll_time = 18;
roll_cooldown = 22;       // พักหลังกลิ้ง (เดิม 30 = กดซ้ำแล้วไม่ออก)
roll_timer = 0;
roll_cd_timer = 0;

// ---- i-frame ตอนกลิ้ง (แยกจาก i-frame หลังโดนตี) ----
roll_iframes = roll_time + 8;   // ★ อมตะนานกว่าตัวกลิ้ง 8 เฟรม (ช่วงไถลหลังกลิ้งยังไม่โดน)
dodge_timer = 0;
roll_buffer_time = 10;          // ★ กดกลิ้งล่วงหน้าได้กี่เฟรม (กดตอนติดคูลดาวน์/ตอนจอหยุดก็ยังออก)
roll_buffer = 0;

roll_echo_timer = 0;

// เก็บตำแหน่งเงา 4 ชุด
roll_echo_x = array_create(4, x);
roll_echo_y = array_create(4, y);
roll_echo_frame = array_create(4, 0);
roll_echo_age = array_create(4, 999);


// ---- คอมโบฟัน 4 ท่า (รายละเอียดแต่ละท่าอยู่ใน combo_step_data) ----
attack_move_mult = 0.4;   // เดินช้า ๆ ระหว่างฟัน
combo = 0;                // ท่าปัจจุบัน 0 = ไม่ได้อยู่ในคอมโบ
combo_window = 0;
combo_window_time = 18;   // ช่วงเวลาต่อคอมโบหลังท่าจบ (เฟรม)
combo_buffer = false;     // คลิกล่วงหน้าไว้
attack_timer = 0;
attack_total = 1;
attack_cd = 0;
attack_end_lag = 24;      // พักหลังท่าจบ (เฟรม)
lunge_dir = 0;
lunge_timer = 0;
lunge_speed = 0;

// ---- ★ ค้อน: กดคลิกค้างเพื่อชาร์จ ----
charge_hold = 0;          // นับเฟรมที่กดค้างก่อนเข้าโหมดชาร์จ
charge_hold_need = 12;    // ★ กดค้างกี่เฟรมถึงเริ่มชาร์จ (ปล่อยก่อน = ทุบธรรมดา)
charge_t = 0;
charge_time = 80;         // ★ ชาร์จเต็มใช้กี่เฟรม (~1.3 วิ)
charge_end_lag = 40;      // ★ พักหลังทุ่มชาร์จ

// ---- สกิล 1: ลูกไฟ (1 นัด, +1 จากแม็กเสริม) ยิงหมดต้องรอรีโหลด ----
bullet_speed = 10;
shot1_max = 6;
shot1_ammo = shot1_max;
shot1_gap = 45;           // ★ ระยะห่างระหว่างนัด (เฟรม) ไม่ให้ยิงรัว
shot1_size = 1;
sp_rem_t = 0;      // ★ ป้ายเตือนอัปสกิล: เวลาที่แสดง (เฟรม)
sp_rem_last = -1;  // SP ล่าสุด (SP เพิ่ม = ป้ายใหญ่อีกรอบ)
shot1_timer = 0;
shot1_reload = 150;       // เวลารอหลังครบ 6 นัด (เฟรม)
shot1_reload_timer = 0;

// ---- สกิล 2: ยิง 3 ทิศ ----
skill2_cooldown = 150;
skill2_timer = 0;

// ---- ★ สกิล 3: ดาบพายุหมุน / สกิล 4: สายฟ้าลูกโซ่ / ท่าไม้ตาย (ค่าจริงตั้งใน player_apply_skills) ----
skill3_unlocked = false; skill3_spins = 3; skill3_rad = 92; skill3_cooldown = 270; skill3_timer = 0;
skill4_unlocked = false; skill4_jumps = 3; skill4_dmg = 2;  skill4_cooldown = 300; skill4_timer = 0;
ult_unlocked = false; ult_gain = 5; ult_dmg = 8; ult_rad = 240;
ult_fx = 0;          // เวลาเอฟเฟกต์ไม้ตาย (นับถอยหลัง)
bolts = [];          // เส้นสายฟ้าที่กำลังวาด
if (!variable_global_exists("ult_charge")) global.ult_charge = 0;   // เกจไม้ตาย 0-100 (ติดตัวข้ามห้อง)

max_hp = global.max_hp;
hp = global.player_hp;
invuln_time = 90;          // ★ อมตะหลังโดนตี 1.5 วิ (เดิม 1 วิ)
invuln_timer = 0;
kb_x = 0;
kb_y = 0;

aim = 0;

// ★ สถานะผิดปกติ (จากท่าศัตรู)
st_burn = 0;      // ไฟติดตัว: หมดเวลาแล้วเสีย 1 หัวใจ (กลิ้งเพื่อดับ)
st_poison = 0;    // พิษ: ช้าลง
st_stun = 0;      // สตัน: ขยับไม่ได้
fog_eye = [x, y - 32];   // ★ จุดตาสำหรับหมอก/มองเห็นศัตรู (อัปเดตทุกเฟรมใน Step)
hsp = 0;
vsp = 0;
dir_x = 0;
dir_y = 1;
face = 3;   // 0=ขวา 1=บน 2=ซ้าย 3=ล่าง

// อมตะอยู่ไหม (กลิ้ง / เพิ่งโดนตี / โหมดอมตะ) ศัตรูใช้เช็กว่า "หลบผ่าน" หรือเปล่า
is_invulnerable = function() {
    return global.god || invuln_timer > 0 || dodge_timer > 0 || state == PState.ROLL;
}

take_damage = function(_dmg, _sx, _sy) {
    if (is_invulnerable()) exit;
    hp -= _dmg;
    fx_player_hurt(_dmg);
    sfx("player_hurt");
    invuln_timer = invuln_time;
    var _d = point_direction(_sx, _sy, x, y);
    kb_x = lengthdir_x(8, _d);
    kb_y = lengthdir_y(8, _d);
}

// ปรับความเร็วจริง (mvx, mvy) เข้าหาเป้าหมายทีละ _step ต่อเฟรม
steer = function(_tx, _ty, _step) {
    var _dx = _tx - mvx;
    var _dy = _ty - mvy;
    var _d = point_distance(0, 0, _dx, _dy);
    if (_d <= _step) {
        mvx = _tx;
        mvy = _ty;
    } else {
        mvx += _dx / _d * _step;
        mvy += _dy / _d * _step;
    }
}

// เริ่มท่าฟันที่ _n (1-4)
start_attack = function(_n) {
    combo = _n;
    combo_window = 0;
    combo_buffer = false;
    face = round(aim / 90) mod 4;

    var _d = combo_step_data(_n);
	_d = weapon_modify_combo(_d, _n);
	_d = skills_modify_combo(_d, _n);
    state = PState.ATTACK;
    attack_timer = _d.time;
    attack_total = _d.time;
    lunge_dir = aim;
    lunge_timer = _d.lunge_frames;
    lunge_speed = _d.lunge_speed;

    // ★ เสียงฟัน (ค้อน / ทุ่มชาร์จ / ดาบ)
    if (_n == 9) sfx("hammer_smash");
    else if (global.save.weapon == "hammer") sfx("hammer_swing", 1, 0.06);
    else sfx("swing", 1, 0.06 + _n * 0.02);

    var _h = instance_create_depth(x, y, depth, obj_hitbox);
	_h.owner = id;
	_h.image_angle = aim;
	_h.lift = aim_height;
	_h.step_data = _d;
	_h.damage = _d.dmg;
}

// เริ่มกลิ้ง: มีปุ่มเดิน = กลิ้งตามทิศเดิน, ไม่มี = กลิ้งตามเมาส์
start_roll = function(_kx, _ky, _len) {
    state = PState.ROLL;
    sfx("roll");
    fx_dust(x, y - 2, 5, make_color_rgb(200, 190, 170));   // ★ ฝุ่นตอนกลิ้ง
    roll_timer = roll_time;
    dodge_timer = roll_iframes;
    roll_buffer = 0;

    roll_echo_timer = 0;
    for (var i = 0; i < 4; i++) roll_echo_age[i] = 999;

    combo = 0;
    combo_window = 0;
    combo_buffer = false;
    charge_hold = 0;
    charge_t = 0;

    if (_len > 0) {
        dir_x = _kx / _len;
        dir_y = _ky / _len;
        if (abs(_kx) > abs(_ky)) face = (_kx > 0) ? 0 : 2;
        else face = (_ky < 0) ? 1 : 3;
    } else {
        dir_x = lengthdir_x(1, aim);
        dir_y = lengthdir_y(1, aim);
        face = round(aim / 90) mod 4;
    }
}


// ★ อัปเดตกล้อง: _zoom = true ปรับซูมด้วย (เรียกครั้งเดียวต่อเฟรม), false = แค่ตามตำแหน่ง
// ไม่ล็อกกล้องที่ขอบห้องแล้ว (นอกห้องมีกำแพงกรอบไว้ให้เห็นเต็มจอ) ตัวละครจะอยู่กลางจอเสมอ
update_camera = function(_zoom) {
    if (!is_undefined(global.boss_intro)) return;   // ระหว่างเปิดตัวบอส obj_tutorial คุมกล้อง
    var _cam = view_camera[0];

    if (!variable_instance_exists(id, "camera_base_w")) {
        camera_base_w = camera_get_view_width(_cam);
        camera_base_h = camera_get_view_height(_cam);
        camera_zoom = 1;
    }

    if (_zoom) {
        var _camera_spd = point_distance(0, 0, mvx, mvy);
        var _zoom_target = 1.0;
        // ★ ปิดซูมตอนวิ่ง: ขนาดกล้องเปลี่ยนทีละพิกเซลทุกเฟรม ภาพพิกเซลเลยสั่นแตกตอนวิ่ง
        // if (state == PState.MOVE && _camera_spd > move_speed + 0.5) _zoom_target = 1.03;
        var _zspd = (_zoom_target > camera_zoom) ? 0.035 : 0.05;
        camera_zoom = lerp(camera_zoom, _zoom_target, _zspd);
        if (abs(camera_zoom - _zoom_target) < 0.0005) camera_zoom = _zoom_target;
    }

    var _cw = round(camera_base_w * camera_zoom);
    var _ch = round(_cw * camera_base_h / camera_base_w);
    camera_set_view_size(_cam, _cw, _ch);

    // ★ ปัดแบบเดียวกับที่วาดตัวละคร (round) ตัวละครจะไม่สั่นไปมา 1px ตอนวิ่ง
    var _cam_x = round(x) - (_cw div 2);
    var _cam_y = round(y) - round(chest) - (_ch div 2);

    var _shk = global.shake;
    camera_set_view_pos(_cam, _cam_x + round(random_range(-_shk, _shk)), _cam_y + round(random_range(-_shk, _shk)));
}

// =====================================================================
// ★ สกิล 3: ดาบพายุหมุน — หมุนตัวพุ่งไปทางที่เล็ง ฟันรอบตัวหลายรอบ (แต่ละรอบโดนได้ 1 ครั้ง)
// =====================================================================
start_whirl = function() {
    sfx("whirl");
    skill3_timer = skill3_cooldown;
    combo = 0;
    combo_window = 0;
    combo_buffer = false;
    charge_hold = 0;
    var _per = 9;
    state = PState.ATTACK;
    attack_timer = 8 + skill3_spins * _per;
    attack_total = attack_timer;
    lunge_dir = aim;
    lunge_timer = attack_timer - 6;
    lunge_speed = 4.2;
    dodge_timer = max(dodge_timer, 10);   // หลบได้แวบแรกตอนเริ่มหมุน
    for (var _i = 0; _i < skill3_spins; _i++) {
        var _h = instance_create_depth(x, y, depth, obj_hitbox);
        _h.owner = id;
        _h.image_angle = aim + _i * 120;
        _h.lift = aim_height;
        _h.step_data = { kind: "spin", time: 0, active_from: 4 + _i * _per, active_to: 8 + _i * _per, dmg: 1, kb: 9, radial: true,
                         lunge_speed: 0, lunge_frames: 0, circles: [ [0, 0, skill3_rad] ] };
        _h.damage = 1;
    }
    fx_dust(x, y - 2, 6, make_color_rgb(200, 190, 170));
    fx_spark(x, y - 30, aim, 8, make_color_rgb(200, 230, 255), 180);
}

// =====================================================================
// ★ สกิล 4: สายฟ้าลูกโซ่ — ผ่าเป้าแรกที่อยู่ทางที่เล็ง แล้วกระโดดไปตัวใกล้สุดต่อไปเรื่อย ๆ
//   โดนเป้าปริศนาแบบยิง (obj_target mode "shot") ได้ด้วย
// =====================================================================
cast_bolt = function() {
    sfx("bolt");
    var _cands = [];   // [id, x, y(จุดวาด), เป็นเป้า?]
    with (obj_enemy) if (hp > 0) array_push(_cands, [id, x, y - ((object_index == obj_enemy_boss) ? 90 : 40), false]);
    with (obj_target) if (!hit && mode != "sword") array_push(_cands, [id, x, y - 48, true]);

    // เป้าแรก: อยู่ในกรวยทางที่เล็ง ใกล้ + ตรงแนวที่สุด
    var _first = -1;
    var _bs = 1000000;
    for (var _i = 0; _i < array_length(_cands); _i++) {
        var _c = _cands[_i];
        if (!instance_exists(_c[0])) continue;
        var _d = point_distance(x, y, _c[0].x, _c[0].y);
        var _ad = abs(angle_difference(point_direction(x, y, _c[0].x, _c[0].y), aim));
        if (_d < 430 && _ad < 55 && !wall_between(x, y, _c[0].x, _c[0].y)) {
            var _sc = _d + _ad * 4;
            if (_sc < _bs) { _bs = _sc; _first = _i; }
        }
    }

    var _sx = x + lengthdir_x(14, aim);
    var _sy = y - aim_height - 30;
    if (_first < 0) {   // ไม่มีเป้า: ฟ้าแลบไปข้างหน้าเฉย ๆ คูลดาวน์สั้น
        array_push(bolts, { x1: _sx, y1: _sy, x2: _sx + lengthdir_x(200, aim), y2: _sy + lengthdir_y(200, aim), life: 14 });
        skill4_timer = 40;
        return;
    }
    skill4_timer = skill4_cooldown;

    var _used = [];
    var _cur = _first;
    var _px = _sx, _py = _sy;
    for (var _n = 0; _n < skill4_jumps && _cur >= 0; _n++) {
        var _c2 = _cands[_cur];
        array_push(_used, _cur);
        var _o = _c2[0];
        if (instance_exists(_o)) {
            var _tx = _o.x;
            var _ty = _c2[2];
            array_push(bolts, { x1: _px, y1: _py, x2: _tx, y2: _ty, life: 20 + _n * 2 });
            if (_c2[3]) {
                with (_o) on_hit();
                with (obj_player) { shot1_reload_timer = 0; shot1_ammo = shot1_max; shot1_timer = 0; skill4_timer = min(skill4_timer, 20); }   // ★ เป้าปริศนา = ใช้ต่อได้ทันที
            } else {
                var _hr = player_hit(skill4_dmg);
                var _dir = point_direction(_px, _py, _tx, _ty);
                _o.take_damage(_hr[0], _dir, _hr[1], "bullet");   // เวท = นับแบบกระสุน (บอสตั้งเกราะกันได้)
                player_on_hit(_o);
            }
            fx_spark(_tx, _ty, 90, 8, make_color_rgb(170, 220, 255), 180);
            _px = _tx;
            _py = _ty;
        }
        // หาตัวถัดไปที่ใกล้ที่สุด (ยังไม่โดน)
        var _next = -1;
        var _nd = 230;
        for (var _j = 0; _j < array_length(_cands); _j++) {
            if (array_contains(_used, _j) || !instance_exists(_cands[_j][0])) continue;
            var _cj = _cands[_j][0];
            if (!instance_exists(_o)) continue;
            var _dd = point_distance(_o.x, _o.y, _cj.x, _cj.y);
            if (_dd < _nd && !wall_between(_o.x, _o.y, _cj.x, _cj.y)) { _nd = _dd; _next = _j; }
        }
        _cur = _next;
    }
    fx_shake(2);
}

// =====================================================================
// ★ ท่าไม้ตาย: รวมพลังแป๊บนึง (อมตะ) แล้วระเบิดแสงรอบตัววงใหญ่
// =====================================================================
cast_ult = function() {
    sfx("ult");
    global.ult_charge = 0;
    combo = 0;
    combo_window = 0;
    combo_buffer = false;
    charge_hold = 0;
    state = PState.ATTACK;
    attack_timer = 46;
    attack_total = 46;
    lunge_timer = 0;
    lunge_speed = 0;
    mvx = 0;
    mvy = 0;
    invuln_timer = max(invuln_timer, 70);
    ult_fx = 60;
    var _h = instance_create_depth(x, y, depth, obj_hitbox);
    _h.owner = id;
    _h.image_angle = aim;
    _h.lift = aim_height;
    _h.step_data = { kind: "ult", shake: 12, time: 0, active_from: 18, active_to: 22, dmg: ult_dmg, kb: 34, radial: true,
                     lunge_speed: 0, lunge_frames: 0, circles: [ [0, 0, ult_rad] ] };
    _h.damage = ult_dmg;
    float_text(x, y - 130, L("ไม้ตาย!", "ULTIMATE!"), make_color_rgb(255, 220, 120), 1.4);
}

// ★ วาดเอฟเฟกต์สายฟ้า / ไม้ตาย (เรียกจาก Draw End หลังหมอก)
draw_skill_fx = function() {
    // =====================================================================
    // ★ สายฟ้าลูกโซ่ (วาดหลังหมอก เห็นชัดเสมอ) — เส้นหยักสุ่มใหม่ทุกเฟรม = แลบ ๆ
    // =====================================================================
    if (array_length(bolts) > 0) {
        gpu_set_blendmode(bm_add);
        for (var _bi = 0; _bi < array_length(bolts); _bi++) {
            var _bo = bolts[_bi];
            var _ba = clamp(_bo.life / 12, 0, 1);
            var _bd = point_distance(_bo.x1, _bo.y1, _bo.x2, _bo.y2);
            var _bang = point_direction(_bo.x1, _bo.y1, _bo.x2, _bo.y2);
            var _seg = max(3, ceil(_bd / 26));
            var _lx = _bo.x1, _ly = _bo.y1;
            for (var _si = 1; _si <= _seg; _si++) {
                var _k = _si / _seg;
                var _off = (_si == _seg) ? 0 : random_range(-12, 12);
                var _nx = lerp(_bo.x1, _bo.x2, _k) + lengthdir_x(_off, _bang + 90);
                var _ny = lerp(_bo.y1, _bo.y2, _k) + lengthdir_y(_off, _bang + 90);
                draw_set_alpha(0.45 * _ba);
                draw_set_color(make_color_rgb(90, 150, 255));
                draw_line_width(_lx, _ly, _nx, _ny, 7);
                draw_set_alpha(0.95 * _ba);
                draw_set_color(make_color_rgb(200, 235, 255));
                draw_line_width(_lx, _ly, _nx, _ny, 2);
                _lx = _nx;
                _ly = _ny;
            }
            draw_set_alpha(0.5 * _ba);
            draw_set_color(make_color_rgb(150, 200, 255));
            draw_circle(_bo.x2, _bo.y2, 14 + 6 * (1 - _ba), false);
        }
        gpu_set_blendmode(bm_normal);
        draw_set_alpha(1);
    }

    // =====================================================================
    // ★ ท่าไม้ตาย: ช่วงรวมพลัง (แสงดูดเข้า) -> ระเบิดวงแหวนทองขยายออก
    // =====================================================================
    if (ult_fx > 0) {
        var _ut = 60 - ult_fx;            // 0..60
        var _ucx = x;
        var _ucy = y - aim_height;
        gpu_set_blendmode(bm_add);
        if (_ut < 18) {
            var _gk = _ut / 18;
            draw_set_alpha(0.25 + 0.5 * _gk);
            draw_set_color(make_color_rgb(255, 210, 120));
            draw_circle(_ucx, _ucy - 20, 10 + 26 * _gk, false);
            draw_set_alpha(0.6 * _gk);
            draw_circle(_ucx, _ucy, ult_rad * (1 - _gk) + 20, true);
            draw_circle(_ucx, _ucy, ult_rad * (1 - _gk) + 22, true);
            for (var _ri = 0; _ri < 10; _ri++) {   // แสงพุ่งเข้าหาตัว
                var _ra = _ri * 36 + current_time / 6;
                var _rr = ult_rad * (1 - _gk);
                draw_line_width(_ucx + lengthdir_x(_rr, _ra), _ucy + lengthdir_y(_rr, _ra),
                                _ucx + lengthdir_x(_rr * 0.6, _ra), _ucy + lengthdir_y(_rr * 0.6, _ra), 2);
            }
        } else {
            var _ek = clamp((_ut - 18) / 24, 0, 1);
            var _ee = 1 - power(1 - _ek, 3);
            var _rr2 = ult_rad * _ee;
            draw_set_alpha(0.35 * (1 - _ek));
            draw_set_color(make_color_rgb(255, 230, 160));
            draw_circle(_ucx, _ucy, _rr2, false);
            draw_set_alpha(0.9 * (1 - _ek));
            draw_set_color(c_white);
            for (var _w = 0; _w < 4; _w++) draw_circle(_ucx, _ucy, _rr2 - _w, true);
            draw_set_color(make_color_rgb(255, 200, 90));
            for (var _w2 = 0; _w2 < 3; _w2++) draw_circle(_ucx, _ucy, _rr2 * 0.7 - _w2, true);
            for (var _ri2 = 0; _ri2 < 16; _ri2++) {   // รังสีพุ่งออก
                var _ra2 = _ri2 * 22.5;
                draw_set_alpha(0.7 * (1 - _ek));
                draw_line_width(_ucx + lengthdir_x(_rr2 * 0.3, _ra2), _ucy + lengthdir_y(_rr2 * 0.3, _ra2),
                                _ucx + lengthdir_x(_rr2 * 1.05, _ra2), _ucy + lengthdir_y(_rr2 * 1.05, _ra2), 3);
            }
        }
        gpu_set_blendmode(bm_normal);
        draw_set_alpha(1);
        draw_set_color(c_white);
    }
}

player_apply_skills();
save_snapshot_new_room();
arrive_pending = (global.arrive != "");   // ย้ายไปจุดเกิดของประตูใน Step (รอให้ประตูถูกสร้างครบก่อน)
instance_create_depth(0, 0, -15000, obj_title_card);
if (!instance_exists(obj_fx)) instance_create_depth(0, 0, -19000, obj_fx);
if (!instance_exists(obj_pause)) instance_create_depth(0, 0, -14000, obj_pause);   // เผื่อเริ่มเทสจากห้องอื่นที่ไม่ใช่เมนู
update_camera(false);   // ★ เข้าห้องมากล้องอยู่ที่ตัวละครทันที (เดิมเริ่มที่มุมซ้ายบน)

dust_t = 0;   // ★ ตัวนับเวลาฝุ่นตอนวิ่ง
last_potion_t = -1;   // ★ เวลาที่ดื่มยาล่าสุด (คูลดาวน์ช่อง Q)
