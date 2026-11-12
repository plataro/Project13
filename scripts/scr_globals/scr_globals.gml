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
        weapon: "sword",   // อาวุธที่ถืออยู่ (sword, greatsword, hammer)
        weapons: {},       // อาวุธที่ซื้อแล้ว (ดาบเริ่มต้นมีอยู่แล้วเสมอ)
        armor: 0,          // เกราะ 0-2 (ลดดาเมจที่ได้รับ)
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
global.village_return = undefined;

// ---------- ระดับความแรงของศัตรูตามด่าน (ไม่ล็อกด่าน แต่ของน้อยจะสู้ยาก) ----------
function level_tier() {
    switch (room) {
        case rm_level_1_the_forest:         return 1;
        case rm_level_2_the_abandoned_mine: return 2;
        case rm_level_3_the_castle:         return 3;
        case rm_boss:                       return 4;
    }
    return 1;
}

// hp = คูณเลือดศัตรูตัวเล็ก, dmg = คูณดาเมจ, speed = คูณความเร็ว, coin = มูลค่าเหรียญที่ดรอปต่อเหรียญ, attackers = บุกพร้อมกันเพิ่ม
function tier_data(_t = level_tier()) {
    switch (_t) {
        case 2:  return { hp: 2.2, dmg: 1,   speed: 1.1,  coin: 3, attackers: 0 };
        case 3:  return { hp: 3.5, dmg: 1.5, speed: 1.2,  coin: 5, attackers: 1 };
        case 4:  return { hp: 3.5, dmg: 1.5, speed: 1.2,  coin: 5, attackers: 1 };
    }
    return { hp: 1, dmg: 1, speed: 1, coin: 2, attackers: 0 };
}

// =====================================================================
// ★ พลังโจมตี / ตัวเลขดาเมจ
// ดาเมจจริง = ดาเมจท่า (1,2,..) x อาวุธ x DMG_UNIT x พลังตามความคืบหน้า (ปราบมินิบอสแต่ละด่าน = โตขึ้น)
// เลือดศัตรูคูณ DMG_UNIT x พลังตามด่าน เท่ากัน ด่านที่ตั้งใจให้เล่นตอนนั้นจึงสมดุลเหมือนเดิม
// =====================================================================
#macro DMG_UNIT 12

// ★ ตัวคูณพลังแต่ละขั้น (0 = เริ่มเกม, 1 = ปราบมินิบอสป่า, 2 = เหมือง, 3 = ปราสาท)
function power_mult(_stage) {
    return [1, 1.4, 1.9, 2.5][clamp(_stage, 0, 3)];
}

// ความคืบหน้าของผู้เล่น = ปราบมินิบอสไปกี่ด่าน
function power_stage() {
    var _n = 0;
    if (flag_get("boss_rm_level_1_the_forest")) _n++;
    if (flag_get("boss_rm_level_2_the_abandoned_mine")) _n++;
    if (flag_get("boss_rm_level_3_the_castle")) _n++;
    return _n;
}

// พลังโจมตีพื้นฐานของผู้เล่น (แสดงบน HUD)
function player_atk() {
    return round(DMG_UNIT * power_mult(power_stage()));
}

// ความแรงศัตรูในด่านนี้: ตามด่านเป็นหลัก แต่ถ้าผู้เล่นเก่งเกินด่านแล้ว ศัตรูโตตามครึ่งหนึ่ง
// = กลับมาด่านเก่าง่ายขึ้น แต่ไม่ง่ายจนตีทีเดียวตาย
function enemy_power_mult(_tier = level_tier()) {
    var _base = power_mult(_tier - 1);
    var _pl = power_mult(power_stage());
    return _base + max(0, _pl - _base) * 0.5;
}

// ★ สุ่มดาเมจจากผู้เล่น: แกว่ง ±10% และคริติคอล 8% (x1.6) คืนค่า [ดาเมจ, คริไหม]
function player_hit(_base) {
    var _d = _base * player_atk() * random_range(0.9, 1.1);
    var _crit = (random(1) < 0.08);
    if (_crit) _d *= 1.6;
    return [max(1, round(_d)), _crit];
}

// ดาเมจที่ผู้เล่นได้รับจริง: ความยาก x ด่าน แล้วหักเกราะ (ขั้นต่ำ 1)
function enemy_damage_calc(_base) {
    var _d = ceil(_base * difficulty_data().enemy_dmg * tier_data().dmg);
    return max(1, _d - global.save.armor);
}
