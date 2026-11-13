// ---------- สี่เหลี่ยมหมุนตามทิศโจมตี (ใช้กับท่าพุ่ง) ----------
// _f0.._f1 = ช่วงระยะไปข้างหน้าจากตีน, _s0.._s1 = ช่วงเบี่ยงข้าง (ลบ = ซ้าย บวก = ขวา)
// แปลงมุมกล่องผู้เล่นเข้าพิกัดของสี่เหลี่ยม แล้วเช็กทับกัน
function obb_hits_rect(_ox, _oy, _ang, _f0, _f1, _s0, _s1, _rx1, _ry1, _rx2, _ry2) {
    var _c = dcos(_ang);
    var _sn = dsin(_ang);
    var _minf = 1000000;
    var _maxf = -1000000;
    var _mins = 1000000;
    var _maxs = -1000000;
    for (var _i = 0; _i < 4; _i++) {
        var _dx = ((_i mod 2) == 0 ? _rx1 : _rx2) - _ox;
        var _dy = (_i < 2 ? _ry1 : _ry2) - _oy;
        var _f = _dx * _c - _dy * _sn;
        var _s = -_dx * _sn - _dy * _c;
        _minf = min(_minf, _f);
        _maxf = max(_maxf, _f);
        _mins = min(_mins, _s);
        _maxs = max(_maxs, _s);
    }
    return (_maxf >= _f0 && _minf <= _f1 && _maxs >= _s0 && _mins <= _s1);
}

// วาดสี่เหลี่ยมหมุน (ใช้สี/ความโปร่งใสที่ตั้งไว้)
function draw_oriented_rect(_ox, _oy, _ang, _f0, _f1, _s0, _s1) {
    var _fx = lengthdir_x(1, _ang);
    var _fy = lengthdir_y(1, _ang);
    var _sx = lengthdir_x(1, _ang + 90);
    var _sy = lengthdir_y(1, _ang + 90);
    draw_primitive_begin(pr_trianglestrip);
    draw_vertex(_ox + _fx * _f0 + _sx * _s0, _oy + _fy * _f0 + _sy * _s0);
    draw_vertex(_ox + _fx * _f1 + _sx * _s0, _oy + _fy * _f1 + _sy * _s0);
    draw_vertex(_ox + _fx * _f0 + _sx * _s1, _oy + _fy * _f0 + _sy * _s1);
    draw_vertex(_ox + _fx * _f1 + _sx * _s1, _oy + _fy * _f1 + _sy * _s1);
    draw_primitive_end();
}

// วงกลม (จุดกลาง cx,cy รัศมี r) ชนสี่เหลี่ยมหรือไม่
function circle_hits_rect(_cx, _cy, _r, _x1, _y1, _x2, _y2) {
    var _nx = clamp(_cx, _x1, _x2);
    var _ny = clamp(_cy, _y1, _y2);
    return point_distance(_cx, _cy, _nx, _ny) <= _r;
}

// กล่องโดนตีของศัตรู: [ซ้าย, บน, ขวา, ล่าง] (ล่าง = ตีน)
function enemy_hurt_rect(_e) {
    if (variable_instance_exists(_e, "is_orb")) return [_e.x - 22, _e.y - 64, _e.x + 22, _e.y - 18];   // ลูกไฟลอย
    var _big = (_e.object_index == obj_enemy_boss);
    var _w = _big ? 110 : 40;
    var _h = _big ? 170 : 58;   // ★ ตัวเล็ก: ภาพ x2 สูงราว 52px / บอส: ภาพ x2 สูงราว 170px
    return [_e.x - _w / 2, _e.y - _h, _e.x + _w / 2, _e.y];
}

function enemy_hit_by_circle(_e, _cx, _cy, _r) {
    var _b = enemy_hurt_rect(_e);
    return circle_hits_rect(_cx, _cy, _r, _b[0], _b[1], _b[2], _b[3]);
}

// กล่องโดนตีของผู้เล่น (ปรับตามขนาดตัวละครจริงได้)

function player_hurt_rect(_p) {

    // ขนาด Hitbox อิงจาก Scale ของตัวละคร
    var _scale = global.pl_scale;

    var _w = 12 * _scale;
    var _h = 22 * _scale;

    return [
        _p.x - _w,
        _p.y - _h,
        _p.x + _w,
        _p.y
    ];
}


function player_hit_by_circle(_p, _cx, _cy, _r) {
    var _b = player_hurt_rect(_p);
    return circle_hits_rect(_cx, _cy, _r, _b[0], _b[1], _b[2], _b[3]);
}

// มีกำแพงขวางระหว่างสองจุดบนพื้นหรือไม่
function wall_between(_x1, _y1, _x2, _y2) {
    var _dist = point_distance(_x1, _y1, _x2, _y2);
    if (_dist < 14) return false;
    var _a = point_direction(_x1, _y1, _x2, _y2);
    var _sx = _x1 + lengthdir_x(6, _a);
    var _sy = _y1 + lengthdir_y(6, _a);
    var _ex = _x2 - lengthdir_x(6, _a);
    var _ey = _y2 - lengthdir_y(6, _a);
    return collision_line(_sx, _sy, _ex, _ey, obj_wall, false, true) != noone;
}

// ข้อมูลท่าฟันของผู้เล่นแต่ละท่า
function combo_step_data(_n) {
    // ★ ท่าสุดท้ายของคอมโบ = ฟาดรอบตัวเสมอ (คอมโบ 6 ท่า = วงใหญ่ + แรงกว่า)
    var _max = weapon_combo_max();
    if (_n >= _max && _n != 9 && _n != 99) {
        if (_max >= 6) return { kind: "spin", time: 28, active_from: 6, active_to: 15, dmg: 3, kb: 24, radial: true,
                                lunge_speed: 0, lunge_frames: 0, shake: 4,
                                circles: [ [0, 0, 124] ] };
        return combo_step_data(99);
    }
    switch (_n) {
        case 1:   // ฟันตรง เร็ว
            return { kind: "slash", time: 14, active_from: 3, active_to: 8, dmg: 1, kb: 8, radial: false,
                     lunge_speed: 2, lunge_frames: 5,
                     circles: [ [56, 0, 40] ] };
        case 2:   // ฟันกวาดกว้าง
            return { kind: "slash", time: 16, active_from: 4, active_to: 10, dmg: 1, kb: 9, radial: false,
                     lunge_speed: 1, lunge_frames: 4,
                     circles: [ [40, -44, 32], [58, 0, 34], [40, 44, 32] ] };
        case 3:   // แทงพุ่งไกล
            return { kind: "thrust", time: 18, active_from: 4, active_to: 12, dmg: 1, kb: 10, radial: false,
                     lunge_speed: 7, lunge_frames: 8,
                     circles: [ [50, 0, 26], [90, 0, 26], [130, 0, 26] ] };
        case 4:   // ★ (คอมโบ 6) ฟันเฉียงสวนกลับ กว้างกว่าท่า 2
            return { kind: "slash", time: 16, active_from: 4, active_to: 10, dmg: 1, kb: 10, radial: false,
                     lunge_speed: 3, lunge_frames: 5,
                     circles: [ [34, 50, 30], [62, 10, 36], [48, -40, 32] ] };
        case 5:   // ★ (คอมโบ 6) แทงคู่พุ่งไกล
            return { kind: "thrust", time: 20, active_from: 5, active_to: 13, dmg: 2, kb: 12, radial: false,
                     lunge_speed: 8, lunge_frames: 9,
                     circles: [ [50, 0, 30], [96, 0, 30], [142, 0, 28] ] };
        default:  // ท่าจบ ฟาดรอบตัว
            return { kind: "spin", time: 26, active_from: 6, active_to: 14, dmg: 2, kb: 18, radial: true,
                     lunge_speed: 0, lunge_frames: 0,
                     circles: [ [0, 0, 100] ] };
    }
}

// ★ ท่าค้อน (คอมโบ 3 ท่า รูป hitbox ไม่ซ้ำดาบ)
function hammer_step_data(_n) {
    switch (_n) {
        case 1:   // ทุบลงตรงหน้า: วงกลมใหญ่ก้อนเดียว ไกลกว่าดาบ
            return { kind: "smash", shake: 3, time: 32, active_from: 14, active_to: 18, dmg: 4, kb: 20, radial: false,
                     lunge_speed: 1.5, lunge_frames: 4,
                     circles: [ [84, 0, 54] ] };
        case 2:   // เหวี่ยงตีข้าง: ตั้งใจให้กวาดจากข้างตัวเข้ามาด้านหน้าฝั่งเดียว (ไม่สมมาตรเหมือนดาบ)
            return { kind: "hswing", time: 34, active_from: 13, active_to: 19, dmg: 4, kb: 24, radial: false,
                     lunge_speed: 1, lunge_frames: 4,
                     circles: [ [24, -78, 36], [70, -48, 40], [96, 6, 40] ] };
        case 9:   // ★ ท่าชาร์จเต็ม: ทุ่มลงพื้นรอบตัววงใหญ่ (ชาร์จนาน + พักหลังท่านาน = ช้ามาก)
            return { kind: "quake", shake: 11, time: 64, active_from: 4, active_to: 12, dmg: 16, kb: 40, radial: true,
                     lunge_speed: 0, lunge_frames: 0,
                     circles: [ [0, 0, 175] ] };
        default:  // ท่าจบ: ทุบพื้น รอบตัว + คลื่นกระแทกวิ่งไปข้างหน้า
            return { kind: "quake", shake: 6, time: 52, active_from: 20, active_to: 28, dmg: 7, kb: 30, radial: true,
                     lunge_speed: 0, lunge_frames: 0,
                     circles: [ [0, 0, 74], [122, 0, 46], [180, 0, 38] ] };
    }
}

// ข้อมูลท่าโจมตีของศัตรู
// windup  = เวลาเตรียม (ตัวสั่น + เห็นวงเตือน), active = เวลาที่ hitbox ทำงาน, recover = เวลาพักหลังโจมตี (เฟรม)
// lock    = กี่เฟรมสุดท้ายของ windup ที่ล็อกทิศ (น้อย = ตามผู้เล่นทันนานขึ้น)
// lead    = เล็งล่วงหน้ากี่เฟรมตามความเร็วที่ผู้เล่นกำลังเดิน (0 = เล็งตำแหน่งปัจจุบัน)
// turn    = องศาต่อเฟรมที่หมุนตามผู้เล่นระหว่าง active (0 = พุ่งตรงไม่หมุน)
// rects   = [จากระยะ, ถึงระยะ, เบี่ยงซ้าย, เบี่ยงขวา] สี่เหลี่ยมหมุนตามทิศ (ท่าพุ่ง ใช้แทนวงกลม)
// circles = [ระยะไปข้างหน้า, ระยะเบี่ยงข้าง, รัศมี] วัดจากตีนตามทิศที่ล็อกไว้, lift = ความสูงที่วางวงกลม
function enemy_attack_base(_name) {
    switch (_name) {
        case "slash":        // ศัตรูทั่วไป: ฟันกวาดโค้งหน้าตัว ตามผู้เล่นทัน
            return { windup: 20, active: 8, recover: 26, dmg: 1, lift: 40,
                     lock: 9, lead: 4, turn: 2,      // ★ เดิม windup 16 / lock 3 / lead 10 / turn 6 (ตามแรงจนหลบไม่ได้)
                     lunge_speed: 5, lunge_frames: 8,
                     circles: [ [44, -38, 32], [56, 0, 38], [44, 38, 32] ] };
        case "dash":         // Dasher: พุ่งชนเป็นเส้นตรง
            return { windup: 30, active: 18, recover: 50, dmg: 2, lift: 40,
                     lock: 12, lead: 0, turn: 0,     // ★ เดิม lock 8
                     lunge_speed: 10, lunge_frames: 18,
                     circles: [],
                     rects: [ [0, 130, -34, 34] ] };   // [หน้าสุด-หลังสุด ระยะ, เบี่ยงซ้าย, เบี่ยงขวา] สี่เหลี่ยมยาวไปข้างหน้า
        case "boss_swing":   // บอส: ฟาดกวาดกว้าง
            return { windup: 34, active: 8, recover: 40, dmg: 2, lift: 70,
                     lock: 12, lead: 3, turn: 1.5,   // ★ เดิม lock 8 / lead 6 / turn 3
                     lunge_speed: 2, lunge_frames: 6,
                     circles: [ [70, -70, 55], [90, 0, 60], [70, 70, 55] ] };
        case "boss_slam":    // บอส: ทุบพื้นรอบตัว (เฟส 2)
            return { windup: 46, active: 8, recover: 55, dmg: 2, lift: 40,
                     lock: 0, lead: 0, turn: 0,
                     lunge_speed: 0, lunge_frames: 0,
                     circles: [ [0, 0, 120] ] };     // ★ เดิม 130 (กลิ้ง 1 ครั้งออกไม่พ้น)
        case "boss_leap":    // บอส: กระโดดตกใส่ (ใช้ตอนลง ไม่มี windup ในนี้ บอสคุมเอง)
            return { windup: 1, active: 8, recover: 0, dmg: 2, lift: 40,
                     lock: 0, lead: 0, turn: 0,
                     lunge_speed: 0, lunge_frames: 0,
                     circles: [ [0, 0, 115] ] };
        // ===== เจ้าป่า: ข่วนเร็ว ๆ สลับซ้ายขวา =====
        // ★ กรงเล็บ: ใหญ่ขึ้นและห่างตัวบอสขึ้น เห็นวงเตือนชัด (เดิมเล็กและชิดตัวจนมองไม่ทัน)
        case "beast_claw_r":
            return { windup: 18, active: 6, recover: 10, dmg: 1, lift: 50,
                     lock: 6, lead: 2, turn: 2,
                     lunge_speed: 6, lunge_frames: 6,
                     circles: [ [70, 34, 52], [110, -8, 56] ] };
        case "beast_claw_l":
            return { windup: 18, active: 6, recover: 10, dmg: 1, lift: 50,
                     lock: 6, lead: 2, turn: 2,
                     lunge_speed: 6, lunge_frames: 6,
                     circles: [ [70, -34, 52], [110, 8, 56] ] };
        case "beast_rake":   // หมุนตัวข่วนรอบตัว
            return { windup: 26, active: 8, recover: 34, dmg: 1, lift: 40,
                     lock: 0, lead: 0, turn: 0,
                     lunge_speed: 0, lunge_frames: 0,
                     circles: [ [0, 0, 150] ] };   // ★ วงใหญ่ขึ้น (เดิม 108) เตือนนานขึ้น
        case "beast_lunge":  // กระโจนตะครุบระยะกลาง
            return { windup: 22, active: 14, recover: 30, dmg: 1, lift: 50,
                     lock: 8, lead: 3, turn: 0,
                     lunge_speed: 11, lunge_frames: 14,
                     circles: [],
                     rects: [ [0, 170, -56, 56] ] };   // ★ ยาว/กว้างขึ้น
        // ===== ยักษ์ค้อน: ช้าแต่หนัก =====
        case "brute_smash":  // ทุบค้อนลงข้างหน้า (โดน = มึน)
            return { fx: "stun", windup: 40, active: 8, recover: 50, dmg: 3, lift: 50,
                     lock: 12, lead: 0, turn: 0,
                     lunge_speed: 2, lunge_frames: 6,
                     circles: [ [96, 0, 78] ] };
        case "brute_pound":  // ทุบพื้นรอบตัว (โดน = มึน)
            return { fx: "stun", windup: 50, active: 8, recover: 60, dmg: 2, lift: 40,
                     lock: 0, lead: 0, turn: 0,
                     lunge_speed: 0, lunge_frames: 0,
                     circles: [ [0, 0, 150] ] };
        case "boss_dash_fast":   // ★ บอสใหญ่: พุ่งต่อเนื่อง 3 ครั้ง (เตรียมสั้น พักสั้น)
            return { windup: 24, active: 18, recover: 12, dmg: 2, lift: 70,
                     lock: 10, lead: 0, turn: 0,
                     lunge_speed: 12, lunge_frames: 18,
                     circles: [],
                     rects: [ [0, 190, -58, 58] ] };
        case "boss_dash":    // บอส: พุ่งชน
            return { windup: 40, active: 22, recover: 50, dmg: 2, lift: 70,
                     lock: 12, lead: 0, turn: 0,     // ★ เดิม lock 8
                     lunge_speed: 11, lunge_frames: 22,
                     circles: [],
                     rects: [ [0, 190, -62, 62] ] };
    }
    return undefined;
}

// =====================================================================
// ★ หมอก / การมองเห็น (ใช้ร่วมกันระหว่างหมอกของผู้เล่นและการวาดศัตรู ให้ตรงกันเป๊ะ)
// =====================================================================
#macro FOG_RADIUS 720

function fog_room() {
    return room == rm_level_1_the_forest || room == rm_level_2_the_abandoned_mine || room == rm_level_3_the_castle;
}

// จุดตาของผู้เล่น: ปกติสูงจากเท้า 32px แต่ถ้าชิดกำแพงด้านบนจนจุดนั้นจมในกำแพง ให้ลดลงมา
// (เดิมจุดตาจมในกำแพง = เรย์มองทะลุกำแพงนั้น หมอกหาย)
function fog_eye_calc(_p) {
    // ★ ไล่ทีละ 2px และเว้นระยะจากกำแพงอย่างน้อย 3px รอบจุด
    //   (เดิมกระโดดทีละ 8px และเช็กแค่จุดเดียว ตาไปแตะขอบกำแพงพอดี เรย์ทะลุ = หมอกแวบหาย)
    for (var _o = 32; _o >= 0; _o -= 2) {
        var _ey = _p.y - _o;
        if (collision_rectangle(_p.x - 3, _ey - 3, _p.x + 3, _ey + 3, obj_wall, false, true) == noone) return [_p.x, _ey];
    }
    return [_p.x, _p.y];
}

// จุดบนพื้นนี้อยู่ในโซนสว่างไหม
function fog_point_lit(_eye, _px, _py) {
    if (point_distance(_eye[0], _eye[1], _px, _py) > FOG_RADIUS) return false;
    return collision_line(_eye[0], _eye[1], _px, _py, obj_wall, false, true) == noone;
}

// ศัตรูตัวนี้ควรเห็นไหม: เช็กหลายจุดทั้งรอยเท้าและลำตัวขึ้นไปถึงหัว (ตามที่วาดบนจอ)
// จุดใดจุดหนึ่งอยู่ในโซนสว่าง = วาดทั้งตัว แล้วปล่อยให้หมอกทับส่วนที่อยู่ในเงาเอง
// (เดิมเช็กแค่เท้า เท้าเข้าเงานิดเดียวทั้งตัวหายทั้งที่ลำตัวยังอยู่ในที่สว่าง)
function enemy_visible(_e) {
    if (!fog_room() || !instance_exists(obj_player)) return true;
    var _eye = obj_player.fog_eye;
    var _r = enemy_hurt_rect(_e);
    var _hw = (_r[2] - _r[0]) * 0.4;
    var _h = _r[3] - _r[1];
    var _z = variable_instance_exists(_e, "z") ? _e.z : 0;
    var _fy = _e.y - 4;

    // รอยเท้า
    if (fog_point_lit(_eye, _e.x, _fy)) return true;
    if (fog_point_lit(_eye, _e.x - _hw, _fy)) return true;
    if (fog_point_lit(_eye, _e.x + _hw, _fy)) return true;

    // ลำตัวขึ้นไปถึงหัว (ตำแหน่งบนจอ)
    var _k = [0.3, 0.55, 0.8, 0.97];
    for (var _i = 0; _i < 4; _i++) {
        var _py = _e.y - _z - _h * _k[_i];
        if (fog_point_lit(_eye, _e.x, _py)) return true;
        if (_k[_i] == 0.55) {
            if (fog_point_lit(_eye, _e.x - _hw, _py)) return true;
            if (fog_point_lit(_eye, _e.x + _hw, _py)) return true;
        }
    }
    return false;
}


// ★ AI ลูกไฟของจอมเวท (ผูกกับ obj_enemy ด้วย method ตอนเรียก): ลอยนิ่ง นับถอยหลัง ครบแล้วระเบิดเป็นกระสุนรอบทิศ
function orb_ai() {
    hsp = 0;
    vsp = 0;
    orb_t--;
    if (orb_t <= 0) {
        var _a0 = irandom(359);
        for (var _i = 0; _i < 8; _i++) {
            var _b = instance_create_depth(x, y, depth, obj_enemy_bullet);
            sfx_at("enemy_shoot", x, y, 0.7, 0.1, 60);
            _b.direction = _a0 + _i * 45;
            _b.image_angle = _b.direction;
            _b.speed = 4;
            _b.fx = "burn";   // ★ ลูกไฟ
        }
        fx_spark(x, y - 40, 0, 18, c_orange, 180);
        fx_shake(2);
        no_drop = true;
        hp = 0;
        instance_destroy();
    }
}

// =====================================================================
// ★ เปิดตัวบอส: หยุดเกม กล้องเลื่อนไปที่บอส ขึ้นชื่อ แล้วกลับมาที่ผู้เล่น
// =====================================================================
function boss_intro_start(_boss, _name, _title) {
    var _key = "intro_" + room_get_name(room);
    if (variable_struct_exists(global.story_seen, _key)) return;   // ดูแล้วไม่ขึ้นซ้ำ (ตายแล้วเริ่มใหม่ก็ไม่ขึ้น)
    global.story_seen[$ _key] = true;
    global.boss_intro = { boss: _boss, name: _name, title: _title, t: 0, k: 0 };
    sfx("boss_roar");
    music_play(_boss.is_final ? "boss" : "miniboss");   // ★ เพลงสู้บอส
}
global.boss_intro = undefined;

// ★ หลอดเลือดบนหัวศัตรู (เรียกในบริบทของศัตรู)
function enemy_draw_hpbar() {
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
}
