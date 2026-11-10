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
    return [_p.x - 22, _p.y - 88, _p.x + 22, _p.y];
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
            return { time: 14, active_from: 3, active_to: 8, dmg: 1, kb: 8, radial: false,
                     lunge_speed: 2, lunge_frames: 5,
                     circles: [ [56, 0, 40] ] };
        case 2:   // ฟันกวาดกว้าง
            return { time: 16, active_from: 4, active_to: 10, dmg: 1, kb: 9, radial: false,
                     lunge_speed: 1, lunge_frames: 4,
                     circles: [ [40, -44, 32], [58, 0, 34], [40, 44, 32] ] };
        case 3:   // แทงพุ่งไกล
            return { time: 18, active_from: 4, active_to: 12, dmg: 1, kb: 10, radial: false,
                     lunge_speed: 7, lunge_frames: 8,
                     circles: [ [50, 0, 26], [90, 0, 26], [130, 0, 26] ] };
        default:  // ท่าจบ ฟาดรอบตัว
            return { time: 26, active_from: 6, active_to: 14, dmg: 2, kb: 18, radial: true,
                     lunge_speed: 0, lunge_frames: 0,
                     circles: [ [0, 0, 100] ] };
    }
}

// ข้อมูลท่าโจมตีของศัตรู
// windup  = เวลาเตรียม (ตัวสั่น + เห็นวงเตือน), active = เวลาที่ hitbox ทำงาน, recover = เวลาพักหลังโจมตี (เฟรม)
// lock    = กี่เฟรมสุดท้ายของ windup ที่ล็อกทิศ (น้อย = ตามผู้เล่นทันนานขึ้น)
// lead    = เล็งล่วงหน้ากี่เฟรมตามความเร็วที่ผู้เล่นกำลังเดิน (0 = เล็งตำแหน่งปัจจุบัน)
// turn    = องศาต่อเฟรมที่หมุนตามผู้เล่นระหว่าง active (0 = พุ่งตรงไม่หมุน)
// circles = [ระยะไปข้างหน้า, ระยะเบี่ยงข้าง, รัศมี] วัดจากตีนตามทิศที่ล็อกไว้, lift = ความสูงที่วางวงกลม
function enemy_attack_base(_name) {
    switch (_name) {
        case "slash":        // ศัตรูทั่วไป: ฟันกวาดโค้งหน้าตัว ตามผู้เล่นทัน
            return { windup: 16, active: 8, recover: 26, dmg: 1, lift: 40,
                     lock: 3, lead: 10, turn: 6,
                     lunge_speed: 5, lunge_frames: 8,
                     circles: [ [44, -38, 32], [56, 0, 38], [44, 38, 32] ] };
        case "dash":         // Dasher: พุ่งชนเป็นเส้นตรง
            return { windup: 30, active: 18, recover: 50, dmg: 2, lift: 40,
                     lock: 8, lead: 0, turn: 0,
                     lunge_speed: 10, lunge_frames: 18,
                     circles: [ [30, 0, 40] ] };
        case "boss_swing":   // บอส: ฟาดกวาดกว้าง
            return { windup: 34, active: 8, recover: 40, dmg: 2, lift: 70,
                     lock: 8, lead: 6, turn: 3,
                     lunge_speed: 2, lunge_frames: 6,
                     circles: [ [70, -70, 55], [90, 0, 60], [70, 70, 55] ] };
        case "boss_slam":    // บอส: ทุบพื้นรอบตัว (เฟส 2)
            return { windup: 46, active: 8, recover: 55, dmg: 2, lift: 40,
                     lock: 0, lead: 0, turn: 0,
                     lunge_speed: 0, lunge_frames: 0,
                     circles: [ [0, 0, 130] ] };
        case "boss_dash":    // บอส: พุ่งชน
            return { windup: 40, active: 22, recover: 50, dmg: 2, lift: 70,
                     lock: 8, lead: 0, turn: 0,
                     lunge_speed: 11, lunge_frames: 22,
                     circles: [ [50, 0, 60] ] };
    }
    return undefined;
}