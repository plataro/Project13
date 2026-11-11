global.max_hp = 5;
global.player_hp = global.max_hp;
global.debug = false;
global.god = false;
global.difficulty = 1;   // 0 = ง่าย, 1 = ปานกลาง, 2 = ยาก

// ลำดับด่าน (ไม่รวม rm_menu)
global.levels = [
    rm_the_sanctuary_ss,
    rm_level_1_the_forest,
    rm_the_village,
    rm_level_2_the_abandoned_mine,
    rm_level_3_the_castle,
    rm_the_final_ss,
    rm_boss,
    rm_end
];

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

// ---------- ข้อมูลเซฟ (เหรียญ ของ ยา สกิล เควส) ----------
function save_default() {
    return {
        gold: 0,
        potions: 1,        // ยาที่ถืออยู่
        potion_max: 3,     // ถือได้สูงสุด
        hp_bonus: 0,       // หัวใจที่ซื้อเพิ่ม
        items: {},         // ของสะสม เช่น { fang: 2, ore: 1 }
        sp: 0,             // แต้มสกิลที่ยังไม่ได้ใช้
        skills: {},        // สกิลที่ปลดแล้ว
        quests: {},        // สถานะเควส
        flags: {}          // ธงเนื้อเรื่อง เช่น mine_done
    };
}

function apply_difficulty() {
    global.max_hp = difficulty_data().player_hp + global.save.hp_bonus;
}

// เริ่มเกมใหม่ (เลือดเต็มตามระดับความยาก บทสนทนาเล่นใหม่ได้) ไม่แตะสถานะ debug
function game_reset() {
    global.save = save_default();
    global.snap = "";
    global.snap_room = noone;
    apply_difficulty();
    global.player_hp = global.max_hp;
    global.story_seen = {};
}

// เก็บภาพเซฟตอนเข้าห้องใหม่ (ตายแล้วเริ่มห้องซ้ำ ไม่เก็บซ้ำ)
function save_snapshot_new_room() {
    if (global.snap_room != room) {
        global.snap = json_stringify(global.save);
        global.snap_room = room;
    }
}

// ตายแล้วคืนเงิน/ของ/ยา กลับไปเท่าตอนเข้าห้อง กันฟาร์ม
function save_restore_snapshot() {
    if (global.snap != "") global.save = json_parse(global.snap);
    apply_difficulty();
}

global.save = save_default();
global.snap = "";
global.snap_room = noone;