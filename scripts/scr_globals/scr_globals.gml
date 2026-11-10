global.max_hp = 5;
global.player_hp = global.max_hp;
global.debug = false;
global.god = false;
global.difficulty = 1;   // 0 = ง่าย, 1 = ปานกลาง, 2 = ยาก

// ลำดับด่าน (ไม่รวม rm_menu)
global.levels = [rm_level_1, rm_level_2, rm_level_3, rm_end];

function level_next_room() {
    for (var _i = 0; _i < array_length(global.levels) - 1; _i++) {
        if (global.levels[_i] == room) return global.levels[_i + 1];
    }
    return noone;
}

function level_index() {
    for (var _i = 0; _i < array_length(global.levels); _i++) {
        if (global.levels[_i] == room) return _i;
    }
    return -1;
}

// ข้อมูลระดับความยาก (ไม่ใส่ _i = ระดับที่เลือกอยู่ตอนนี้)
function difficulty_data(_i = global.difficulty) {
    switch (_i) {
        case 0:   // ง่าย
            return { name: "ง่าย", player_hp: 8,
                     enemy_hp: 0.7, enemy_dmg: 0.5, windup: 1.3, enemy_speed: 0.9, attackers: 1,
                     desc: "เลือด 8 · ศัตรูอ่อนและช้ากว่า ดาเมจน้อย เตรียมโจมตีนาน หลบง่าย" };
        case 2:   // ยาก
            return { name: "ยาก", player_hp: 4,
                     enemy_hp: 1.5, enemy_dmg: 1, windup: 0.8, enemy_speed: 1.15, attackers: 3,
                     desc: "เลือด 4 · ศัตรูทนและเร็วกว่า บุกพร้อมกัน 3 ตัว สัญญาณเตือนสั้นลง" };
        default:  // ปานกลาง
            return { name: "ปานกลาง", player_hp: 5,
                     enemy_hp: 1, enemy_dmg: 1, windup: 1, enemy_speed: 1, attackers: 2,
                     desc: "เลือด 5 · สมดุล เล่นตามที่ออกแบบไว้" };
    }
}

function apply_difficulty() {
    global.max_hp = difficulty_data().player_hp;
}

// เริ่มเกมใหม่ (เลือดเต็มตามระดับความยาก บทสนทนาเล่นใหม่ได้) ไม่แตะสถานะ debug
function game_reset() {
    apply_difficulty();
    global.player_hp = global.max_hp;
    global.story_seen = {};
}