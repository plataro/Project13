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
roll_cooldown = 30;
roll_timer = 0;
roll_cd_timer = 0;

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
invuln_time = 60;
invuln_timer = 0;
kb_x = 0;
kb_y = 0;

aim = 0;
hsp = 0;
vsp = 0;
dir_x = 0;
dir_y = 1;
face = 3;   // 0=ขวา 1=บน 2=ซ้าย 3=ล่าง

take_damage = function(_dmg, _sx, _sy) {
    if (global.god || invuln_timer > 0 || state == PState.ROLL) exit;
    hp -= _dmg;
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

save_snapshot_new_room();
instance_create_depth(0, 0, -15000, obj_title_card);