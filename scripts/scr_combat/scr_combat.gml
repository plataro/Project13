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
    var _big = (_e.object_index == obj_enemy_boss);
    var _w = _big ? 110 : 44;
    var _h = _big ? 180 : 84;
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
            return { kind: "smash", time: 32, active_from: 14, active_to: 18, dmg: 4, kb: 20, radial: false,
                     lunge_speed: 1.5, lunge_frames: 4,
                     circles: [ [84, 0, 54] ] };
        case 2:   // เหวี่ยงตีข้าง: ตั้งใจให้กวาดจากข้างตัวเข้ามาด้านหน้าฝั่งเดียว (ไม่สมมาตรเหมือนดาบ)
            return { kind: "hswing", time: 34, active_from: 13, active_to: 19, dmg: 4, kb: 24, radial: false,
                     lunge_speed: 1, lunge_frames: 4,
                     circles: [ [24, -78, 36], [70, -48, 40], [96, 6, 40] ] };
        default:  // ท่าจบ: ทุบพื้น รอบตัว + คลื่นกระแทกวิ่งไปข้างหน้า
            return { kind: "quake", time: 52, active_from: 20, active_to: 28, dmg: 7, kb: 30, radial: true,
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
    var _offs = [32, 24, 16, 8, 2];
    for (var _i = 0; _i < 5; _i++) {
        if (!position_meeting(_p.x, _p.y - _offs[_i], obj_wall)) return [_p.x, _p.y - _offs[_i]];
    }
    return [_p.x, _p.y];
}

// จุดบนพื้นนี้อยู่ในโซนสว่างไหม
function fog_point_lit(_eye, _px, _py) {
    if (point_distance(_eye[0], _eye[1], _px, _py) > FOG_RADIUS) return false;
    return collision_line(_eye[0], _eye[1], _px, _py, obj_wall, false, true) == noone;
}

// ศัตรูตัวนี้ควรเห็นไหม: เช็กหลายจุดรอบรอยเท้า (เท้ากลาง ซ้าย ขวา และเหนือเท้านิดหน่อย)
// จุดใดจุดหนึ่งอยู่ในโซนสว่าง = เห็น (ไม่ใช้จุดหัว กันหัวยื่นข้ามกำแพงมาโผล่ฝั่งผู้เล่น)
function enemy_visible(_e) {
    if (!fog_room() || !instance_exists(obj_player)) return true;
    var _eye = obj_player.fog_eye;
    var _hw = max(6, (_e.bbox_right - _e.bbox_left) * 0.5 - 2);
    var _fy = _e.y - 4;
    if (fog_point_lit(_eye, _e.x, _fy)) return true;
    if (fog_point_lit(_eye, _e.x - _hw, _fy)) return true;
    if (fog_point_lit(_eye, _e.x + _hw, _fy)) return true;
    if (fog_point_lit(_eye, _e.x, _fy - _hw)) return true;
    return false;
}
