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

// ---- สกิล 1: กดค้างยิงรัว ครบ 6 นัดต้องรอรีโหลด ----
bullet_speed = 10;
shot1_max = 6;
shot1_ammo = shot1_max;
shot1_gap = 8;            // ระยะห่างระหว่างนัด (เฟรม)
shot1_timer = 0;
shot1_reload = 150;       // เวลารอหลังครบ 6 นัด (เฟรม)
shot1_reload_timer = 0;

// ---- สกิล 2: ยิง 3 ทิศ ----
skill2_cooldown = 150;
skill2_timer = 0;

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
        if (state == PState.MOVE && _camera_spd > move_speed + 0.5) _zoom_target = 1.03;
        var _zspd = (_zoom_target > camera_zoom) ? 0.035 : 0.05;
        camera_zoom = lerp(camera_zoom, _zoom_target, _zspd);
        if (abs(camera_zoom - _zoom_target) < 0.0005) camera_zoom = _zoom_target;
    }

    var _cw = round(camera_base_w * camera_zoom);
    var _ch = round(_cw * camera_base_h / camera_base_w);
    camera_set_view_size(_cam, _cw, _ch);

    var _cam_x = floor(x - _cw / 2);
    var _cam_y = floor(y - chest - _ch / 2);

    var _shk = global.shake;
    camera_set_view_pos(_cam, _cam_x + round(random_range(-_shk, _shk)), _cam_y + round(random_range(-_shk, _shk)));
}

player_apply_skills();
save_snapshot_new_room();
arrive_pending = (global.arrive != "");   // ย้ายไปจุดเกิดของประตูใน Step (รอให้ประตูถูกสร้างครบก่อน)
instance_create_depth(0, 0, -15000, obj_title_card);
if (!instance_exists(obj_fx)) instance_create_depth(0, 0, -19000, obj_fx);
if (!instance_exists(obj_pause)) instance_create_depth(0, 0, -14000, obj_pause);   // เผื่อเริ่มเทสจากห้องอื่นที่ไม่ใช่เมนู
update_camera(false);   // ★ เข้าห้องมากล้องอยู่ที่ตัวละครทันที (เดิมเริ่มที่มุมซ้ายบน)

dust_t = 0;   // ★ ตัวนับเวลาฝุ่นตอนวิ่ง
