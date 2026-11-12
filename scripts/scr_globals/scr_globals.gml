global.max_hp = 5;
global.player_hp = global.max_hp;
global.debug = false;
#macro SHOW_DEBUG_MENU true   // ★ ก่อนอัปโหลดขึ้น itch ให้เปลี่ยนเป็น false (ซ่อนปุ่ม Debug Mode ในเมนูหลัก)
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
                     desc: "เลือด 8 | ศัตรูอ่อนและช้ากว่า ดาเมจน้อย เตรียมโจมตีนาน หลบง่าย" };
        case 2:   // ยาก
            return { name: "ยาก", player_hp: 4,
                     enemy_hp: 1.5, enemy_dmg: 1, windup: 0.8, enemy_speed: 1.15, attackers: 3,
                     desc: "เลือด 4 | ศัตรูทนและเร็วกว่า บุกพร้อมกัน 3 ตัว สัญญาณเตือนสั้นลง" };
        default:  // ปานกลาง
            return { name: "ปานกลาง", player_hp: 5,
                     enemy_hp: 1, enemy_dmg: 1, windup: 1, enemy_speed: 1, attackers: 2,
                     desc: "เลือด 5 | สมดุล เล่นตามที่ออกแบบไว้" };
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
        acc: {},           // ★ เครื่องประดับที่มี
        acc_eq: [],        // ★ ที่สวมอยู่ (สูงสุด 2)
        buff_items: {},    // ★ ไอเท็มบัฟที่ถืออยู่ { buff_atk: 2 }
        shot_lv: 0,        // ★ ระดับพลังยิง 0-3 (ได้จากหีบบททดสอบ ด่านละ 1)
        quests: {},        // สถานะเควส
        flags: {}          // ธงเนื้อเรื่อง เช่น mine_done
    };
}

function apply_difficulty() {
    global.max_hp = difficulty_data().player_hp + global.save.hp_bonus + (skill_has("g5") ? 1 : 0) + player_stats().hp;
}

// เริ่มเกมใหม่ (เลือดเต็มตามระดับความยาก บทสนทนาเล่นใหม่ได้) ไม่แตะสถานะ debug
function game_reset() {
    global.save = save_default();
    global.snap = "";
    global.snap_room = noone;
    apply_difficulty();
    global.player_hp = global.max_hp;
    global.story_seen = {};
    global.buffs = [];
}

// เก็บภาพเซฟตอนเข้าห้องใหม่ (ตายแล้วเริ่มห้องซ้ำ ไม่เก็บซ้ำ) + ★ เซฟลงเบราว์เซอร์อัตโนมัติ
function save_snapshot_new_room() {
    if (global.snap_room != room) {
        global.snap = json_stringify(global.save);
        global.snap_room = room;
        global.snap_seen = json_stringify(global.story_seen);
        save_write_file(global.player_hp);
    }
}

// =====================================================================
// ★ เซฟลงเครื่อง/เบราว์เซอร์ (save.ini → localStorage บนเว็บ)
// เซฟอัตโนมัติทุกครั้งที่เข้าห้องใหม่ และตอนปิดร้านค้า
// โหลดแล้วจะเกิดที่ประตูที่เข้าห้องนั้นมา ด้วยของ/เงิน/สกิล ณ ตอนนั้น
// =====================================================================
#macro SAVE_FILE "save.ini"
#macro SAVE_VERSION 1
global.snap_seen = "{}";
global.save_flash = 0;   // นับถอยหลังแสดงข้อความ "บันทึกแล้ว"

// ห้องนี้เซฟได้ไหม (เฉพาะห้องในลำดับด่าน ไม่รวมฉากจบ และไม่เซฟตอนเปิด Debug กันทับเซฟจริง)
function save_room_ok() {
    if (global.debug || room == rm_menu || room == rm_end) return false;
    return level_index() >= 0;
}

function save_write_file(_hp) {
    if (!save_room_ok()) return;
    var _d = {
        v: SAVE_VERSION,
        room: room_get_name(room),
        arrive: global.arrive,
        difficulty: global.difficulty,
        hp: _hp,
        save: global.snap,
        seen: global.snap_seen,
        ending: global.ending
    };
    ini_open(SAVE_FILE);
    ini_write_string("save", "data", base64_encode(json_stringify(_d)));
    ini_close();
    global.save_flash = 120;
}

// เซฟสถานะปัจจุบันกลางห้อง (เช่น ปิดร้านค้า) ตายแล้วก็จะไม่เสียของที่ซื้อ
function save_commit() {
    global.snap = json_stringify(global.save);
    global.snap_seen = json_stringify(global.story_seen);
    var _hp = instance_exists(obj_player) ? obj_player.hp : global.player_hp;
    save_write_file(_hp);
}

// ★ เซฟเฉพาะ "สิ่งที่ดู/ผ่านแล้ว" (บทสอน เนื้อเรื่อง) กลางห้อง
//   ของ/เงินยังเป็นของตอนเข้าห้องเหมือนเดิม แค่โหลดใหม่แล้วไม่ต้องทำบทสอนซ้ำ
function save_commit_seen() {
    if (!save_room_ok()) return;
    global.snap_seen = json_stringify(global.story_seen);
    save_write_file(global.player_hp);
}

function save_exists() {
    ini_open(SAVE_FILE);
    var _e = ini_key_exists("save", "data");
    ini_close();
    return _e;
}

function save_delete() {
    ini_open(SAVE_FILE);
    ini_section_delete("save");
    ini_close();
}

// ข้อความสรุปเซฟสำหรับเมนู ("" = อ่านไม่ได้)
function save_summary() {
    var _d = save_read_raw();
    if (is_undefined(_d)) return "";
    var _r = asset_get_index(_d.room);
    var _nm = (_r != -1 && room_exists(_r)) ? room_title(_r) : "";
    if (_nm == "") _nm = _d.room;
    return difficulty_data(_d.difficulty).name + "  |  " + _nm;
}

function save_read_raw() {
    ini_open(SAVE_FILE);
    var _s = ini_read_string("save", "data", "");
    ini_close();
    if (_s == "") return undefined;
    try {
        var _d = json_parse(base64_decode(_s));
        if (!is_struct(_d) || !variable_struct_exists(_d, "room")) return undefined;
        return _d;
    } catch (_e) {
        return undefined;
    }
}

// โหลดเซฟเข้าตัวแปรเกม คืนค่าห้องที่ต้องไป (-1 = โหลดไม่ได้)
function save_load() {
    var _d = save_read_raw();
    if (is_undefined(_d)) return -1;
    var _r = asset_get_index(_d.room);
    if (_r == -1 || !room_exists(_r)) return -1;

    global.difficulty = _d.difficulty;
    try {
        global.save = json_parse(_d.save);
        global.story_seen = json_parse(_d.seen);
    } catch (_e) {
        return -1;
    }
    // เซฟเก่าก่อนมีระบบพลังยิง = ให้ระดับตามความคืบหน้า
    if (!variable_struct_exists(global.save, "shot_lv")) global.save.shot_lv = power_stage();
    global.save.shot_lv = min(3, global.save.shot_lv);   // ระบบเดิมมี 4 ระดับ
    // เซฟเก่าที่ขาดช่องใหม่ ๆ = เติมค่าเริ่มต้น
    var _def = save_default();
    var _keys = variable_struct_get_names(_def);
    for (var _i = 0; _i < array_length(_keys); _i++) {
        if (!variable_struct_exists(global.save, _keys[_i])) global.save[$ _keys[_i]] = _def[$ _keys[_i]];
    }

    global.ending = _d.ending;
    global.arrive = _d.arrive;
    global.buffs = [];
    global.snap = "";
    global.snap_room = noone;
    global.hitstop = 0;
    apply_difficulty();
    global.player_hp = clamp(_d.hp, 1, global.max_hp);
    return _r;
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

// boss_hp = คูณเลือดมินิบอสในด่าน (เพิ่มเติมจากตัวเลขใน Creation Code)
// hp = คูณเลือดศัตรูตัวเล็ก, dmg = คูณดาเมจ, speed = คูณความเร็ว, coin = มูลค่าเหรียญที่ดรอปต่อเหรียญ, attackers = บุกพร้อมกันเพิ่ม
function tier_data(_t = level_tier()) {
    switch (_t) {
        // ★ ด่าน 2-3 ยากขึ้นนิดหน่อย (เดิม ด่าน2 hp 2.2 speed 1.1 / ด่าน3 hp 3.5 speed 1.2)
        case 2:  return { hp: 2.4, dmg: 1,   speed: 1.13, coin: 3, attackers: 0, boss_hp: 1.1 };
        case 3:  return { hp: 3.8, dmg: 1.5, speed: 1.23, coin: 5, attackers: 1, boss_hp: 1.1 };
        case 4:  return { hp: 3.5, dmg: 1.5, speed: 1.2,  coin: 5, attackers: 1, boss_hp: 1 };
    }
    return { hp: 1, dmg: 1, speed: 1, coin: 2, attackers: 0, boss_hp: 1 };
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
    var _st = player_stats();
    var _d = _base * player_atk() * _st.atk * random_range(0.9, 1.1);   // ★ ATK จากเครื่องประดับ/บัฟ
    var _crit = (random(1) < _st.crit);
    if (_crit) _d *= _st.critdmg;
    return [max(1, round(_d)), _crit];
}

// ดาเมจที่ผู้เล่นได้รับจริง: ความยาก x ด่าน แล้วหักเกราะ (ขั้นต่ำ 1)
function enemy_damage_calc(_base) {
    var _d = ceil(_base * difficulty_data().enemy_dmg * tier_data().dmg);
    return max(1, _d - player_stats().def);   // ★ เกราะ + เครื่องประดับ + บัฟ
}

// =====================================================================
// ★ ตั้งค่า (เก็บไว้ในเบราว์เซอร์/เครื่อง ผ่าน settings.ini)
// =====================================================================
global.set_volume = 100;   // 0-100
global.show_dmg = true;    // แสดงตัวเลขดาเมจ

function settings_apply() {
    audio_master_gain(global.set_volume / 100);
}

function settings_load() {
    ini_open("settings.ini");
    global.set_volume = ini_read_real("settings", "volume", 100);
    global.fx_shake_scale = ini_read_real("settings", "shake", 2.5);
    global.fx_hitstop_on = ini_read_real("settings", "hitstop", 1) > 0;
    global.show_dmg = ini_read_real("settings", "dmg_numbers", 1) > 0;
    ini_close();
    settings_apply();
}

function settings_save() {
    ini_open("settings.ini");
    ini_write_real("settings", "volume", global.set_volume);
    ini_write_real("settings", "shake", global.fx_shake_scale);
    ini_write_real("settings", "hitstop", global.fx_hitstop_on ? 1 : 0);
    ini_write_real("settings", "dmg_numbers", global.show_dmg ? 1 : 0);
    ini_close();
}


// ★ ชื่อพื้นที่ (ป้ายบอกทางออก)
function room_title(_r) {
    if (_r == noone || _r == -1) return "";
    switch (_r) {
        case rm_the_sanctuary_ss:            return "วิหาร";
        case rm_level_1_the_forest:          return "ป่า";
        case rm_the_village:                 return "หมู่บ้าน";
        case rm_level_2_the_abandoned_mine:  return "เหมืองร้าง";
        case rm_level_3_the_castle:          return "ปราสาท";
        case rm_the_final_ss:                return "ทางสู่บัลลังก์";
        case rm_boss:                        return "บัลลังก์มังกร";
        case rm_end:                         return "";
    }
    return "";
}
