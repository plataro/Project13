// ★ ต้นไม้สกิล 4 สาย x 6 ขั้น: 0 = ดาบ, 1 = ยิง, 2 = เวท/ไม้ตาย, 3 = ร่างกาย (อัปโดยรวม)
//   tier = แถวจากบนลงล่าง, req = ต้องปลดตัวนี้ก่อน, slot = ช่องสกิลที่อัป (ใช้นับ Lv บนแถบสกิล)
//   (key เดิมจากเวอร์ชันก่อนยังใช้ต่อ เซฟเก่าไม่หาย บางตัวเปลี่ยนความสามารถ)
function skill_nodes() {
    return [
        // ---- ดาบ ----
        { key: "s1", branch: 0, tier: 0, slot: "skill3", name: L("ดาบพายุหมุน", "Blade Whirl"),   desc: L("ปลดสกิล 3: หมุนตัวพุ่งฟันรอบตัว 3 ครั้ง", "Unlocks Skill 3: a spinning dash that hits all around 3 times"), cost: 1, req: "" },
        { key: "b1", branch: 0, tier: 1, slot: "attack", name: L("คมกริบ", "Keen Edge"),          desc: L("ท่าสุดท้ายของคอมโบแรงขึ้น +1", "Combo finisher damage +1"),            cost: 1, req: "s1" },
        { key: "b2", branch: 0, tier: 2, slot: "attack", name: L("วงดาบกว้าง", "Wide Arc"),       desc: L("ระยะฟันกว้างขึ้น 15% และต่อคอมโบได้นานขึ้น", "Swings reach 15% wider, longer window to chain"), cost: 1, req: "b1" },
        { key: "b4", branch: 0, tier: 3, slot: "skill3", name: L("พายุคมดาบ", "Storm Whirl"),     desc: L("สกิล 3: หมุนเพิ่ม 1 รอบ วงใหญ่ขึ้น คูลดาวน์สั้นลง", "Skill 3: +1 spin, bigger area, shorter cooldown"), cost: 1, req: "b2" },
        { key: "b3", branch: 0, tier: 4, slot: "attack", name: L("มือไว", "Quick Hands"),         desc: L("ทุกท่าฟันเร็วขึ้น 10%", "All swings 10% faster"),                     cost: 1, req: "b4" },
        { key: "b5", branch: 0, tier: 5, slot: "attack", name: L("ระบำหกกระบวน", "Six-Step Dance"), desc: L("ดาบ: คอมโบเพิ่มเป็น 6 ท่า (ท่าที่ 5-6 ใหม่ ท่าจบแรงขึ้น)", "Swords: combo becomes 6 hits (new 5th-6th, stronger finisher)"), cost: 2, req: "b3" },

        // ---- ยิง ----
        { key: "a1", branch: 1, tier: 0, slot: "shoot1", name: L("แม็กเสริม", "Extra Mag"),      desc: L("สกิล 1 ยิงได้เพิ่ม 1 นัด (รวม 2)", "Skill 1 gets +1 shot (2 total)"),     cost: 1, req: "" },
        { key: "a2", branch: 1, tier: 1, slot: "shoot1", name: L("รีโหลดไว", "Fast Reload"),      desc: L("รอรีโหลดสกิล 1 สั้นลง 25%", "Skill 1 reloads 25% faster"),                 cost: 1, req: "a1" },
        { key: "a3", branch: 1, tier: 2, slot: "shoot",  name: L("กระสุนไว", "Swift Shot"),       desc: L("กระสุนพุ่งเร็วขึ้น 30% เล็งโดนง่ายขึ้น", "Shots fly 30% faster, easier to hit"),       cost: 1, req: "a2" },
        { key: "a4", branch: 1, tier: 3, slot: "shoot",  name: L("กระสุนทะลุ", "Piercing Shot"),  desc: L("กระสุนทะลุศัตรูได้ 1 ตัว", "Shots pierce 1 enemy"),                  cost: 1, req: "a3" },
        { key: "a5", branch: 1, tier: 4, slot: "shoot2", name: L("ห้าทิศ", "Five Ways"),          desc: L("สกิล 2 ยิง 5 ลูก (จาก 3)", "Skill 2 fires 5 shots (was 3)"),                  cost: 1, req: "a4" },
        { key: "a6", branch: 1, tier: 5, slot: "shoot",  name: L("ไฟบรรลัย", "Inferno"),          desc: L("ลูกไฟระเบิดเมื่อโดนศัตรู โดนตัวรอบ ๆ ด้วย", "Fireballs explode on hit, damaging nearby foes"), cost: 2, req: "a5" },

        // ---- เวท / ไม้ตาย ----
        { key: "m1", branch: 2, tier: 0, slot: "skill4", name: L("สายฟ้าลูกโซ่", "Chain Lightning"), desc: L("ปลดสกิล 4: ฟ้าผ่าศัตรูแล้วกระโดดต่อ 3 ตัว (ยิงเป้าได้)", "Unlocks Skill 4: lightning jumps across 3 foes (hits targets too)"), cost: 1, req: "" },
        { key: "m2", branch: 2, tier: 1, slot: "ult",    name: L("ตื่นรู้", "Awakening"),          desc: L("ปลดท่าไม้ตาย: ตีโดนเพื่อสะสมเกจ เต็มแล้วปลดพลังรอบตัว", "Unlocks Ultimate: hit foes to fill the gauge, then unleash a blast"), cost: 1, req: "m1" },
        { key: "m3", branch: 2, tier: 2, slot: "skill4", name: L("ฟ้าแยกสาย", "Forked Bolt"),     desc: L("สกิล 4: กระโดดเพิ่มอีก 2 ตัว", "Skill 4: jumps to 2 more foes"),          cost: 1, req: "m2" },
        { key: "m4", branch: 2, tier: 3, slot: "ult",    name: L("โทสะ", "Fury"),                  desc: L("เกจไม้ตายเต็มไวขึ้น 40%", "Ultimate gauge fills 40% faster"),            cost: 1, req: "m3" },
        { key: "m5", branch: 2, tier: 4, slot: "skill4", name: L("ผู้เรียกพายุ", "Storm Caller"),   desc: L("สกิล 4: แรงขึ้น +1 คูลดาวน์สั้นลง 35%", "Skill 4: damage +1, cooldown 35% shorter"), cost: 1, req: "m4" },
        { key: "m6", branch: 2, tier: 5, slot: "ult",    name: L("มหาวินาศ", "Cataclysm"),        desc: L("ไม้ตายแรงขึ้น 50% และวงใหญ่ขึ้น", "Ultimate deals 50% more damage, bigger blast"), cost: 2, req: "m5" },

        // ---- ร่างกาย (อัปโดยรวม) ----
        { key: "g1", branch: 3, tier: 0, slot: "roll",   name: L("เท้าเบา", "Light Feet"),        desc: L("คูลดาวน์กลิ้งสั้นลง 30%", "Roll cooldown 30% shorter"),                   cost: 1, req: "" },
        { key: "g2", branch: 3, tier: 1, slot: "run",    name: L("ลมใต้เท้า", "Tailwind"),        desc: L("วิ่งเร็วขึ้นและออกตัวไวขึ้น", "Run faster and accelerate quicker"),                 cost: 1, req: "g1" },
        { key: "g3", branch: 3, tier: 2, slot: "potion", name: L("ยาแรง", "Strong Brew"),          desc: L("ยาฟื้นเลือดเพิ่ม 1 หัวใจ (เป็น 3)", "Potions heal +1 heart (3 total)"),          cost: 1, req: "g2" },
        { key: "g4", branch: 3, tier: 3, slot: "potion", name: L("กระเป๋ายา", "Potion Pouch"),     desc: L("ถือยาได้เพิ่ม 1 ขวด", "Carry +1 potion"),                       cost: 1, req: "g3" },
        { key: "g5", branch: 3, tier: 4, slot: "",       name: L("ใจสู้", "Fighting Spirit"),      desc: L("หัวใจสูงสุด +1", "Max hearts +1"),                            cost: 1, req: "g4" },
        { key: "g6", branch: 3, tier: 5, slot: "all",    name: L("สมาธิ", "Focus"),                desc: L("คูลดาวน์ทุกสกิลสั้นลง 15% (ยิง เวท ดาบหมุน)", "All skill cooldowns 15% shorter"), cost: 2, req: "g5" }
    ];
}

// ★ ระดับของช่องสกิล (1 = ยังไม่อัป) ใช้โชว์ "Lv" บนแถบสกิล
//   _slot: "attack", "shoot1", "shoot2", "skill3", "skill4", "ult", "roll", "run", "potion"
function skill_slot_level(_slot) {
    var _all = skill_nodes();
    var _lv = 1;
    for (var _i = 0; _i < array_length(_all); _i++) {
        var _n = _all[_i];
        if (!skill_has(_n.key)) continue;
        if (_n.key == "s1" || _n.key == "m1" || _n.key == "m2") continue;   // ตัวปลดสกิลไม่นับเป็นเลเวล
        var _hit = (_n.slot == _slot)
            || (_n.slot == "shoot" && (_slot == "shoot1" || _slot == "shoot2"))
            || (_n.slot == "all" && (_slot == "shoot1" || _slot == "shoot2" || _slot == "skill3" || _slot == "skill4"));
        if (_hit) _lv++;
    }
    if (_slot == "shoot1") _lv += global.save.shot_lv;   // หีบพลังลูกไฟ
    return _lv;
}

// ★ พลังยิง (สกิล 1) ตามระดับที่เก็บจากหีบพลัง: เริ่ม 1 นัดแรงมากแต่รอนาน -> นัดเยอะขึ้น รอสั้นลง
// lv 2 ขึ้นไปปลดสกิล 2 (ยิงสามทิศ)
// ระดับ 1/2/3 ได้จากหีบบททดสอบของป่า/เหมือง/ปราสาท (ลูกไฟใหญ่+แรงขึ้น)
function shot_data(_lv) {
    // ★ หีบพลัง (บททดสอบ) ไม่เพิ่มจำนวนนัดแล้ว แต่ทำให้ลูกไฟ "ใหญ่ขึ้น + แรงขึ้น"
    //   จำนวนนัดได้จากต้นไม้สกิล "แม็กเสริม" เท่านั้น (สูงสุด 2 นัด)
    switch (clamp(_lv, 0, 3)) {
        case 0: return { ammo: 1, dmg: 3,   reload: 240, size: 1 };
        case 1: return { ammo: 1, dmg: 4,   reload: 225, size: 1.25 };
        case 2: return { ammo: 1, dmg: 5.5, reload: 210, size: 1.5 };
    }
    return { ammo: 1, dmg: 7, reload: 195, size: 1.8 };
}

// ถือยาได้สูงสุด (ร้านค้า + สกิลกระเป๋ายา)
function potion_cap() {
    return global.save.potion_max + (skill_has("g4") ? 1 : 0);
}

// ★ มีสกิลที่ปลดได้ตอนนี้ไหม (ใช้กับป้ายเตือนอัปสกิล)
function skill_affordable() {
    if (!flag_get("tree_unlocked") || global.save.sp <= 0) return false;
    var _all = skill_nodes();
    for (var _i = 0; _i < array_length(_all); _i++) {
        var _n = _all[_i];
        if (!skill_has(_n.key) && (_n.req == "" || skill_has(_n.req)) && global.save.sp >= _n.cost) return true;
    }
    return false;
}

function skill_has(_key) {
    return variable_struct_exists(global.save.skills, _key);
}

function skill_find(_key) {
    var _all = skill_nodes();
    for (var _i = 0; _i < array_length(_all); _i++) {
        if (_all[_i].key == _key) return _all[_i];
    }
    return undefined;
}

// ปลดสกิล คืนข้อความผิดพลาด หรือ "" ถ้าสำเร็จ
function skill_unlock(_key) {
    var _n = skill_find(_key);
    var _s = global.save;

    if (is_undefined(_n)) { sfx("ui_error"); return L("ไม่พบสกิล", "Skill not found"); }
    if (skill_has(_key)) { sfx("ui_error"); return L("ปลดแล้ว", "Already unlocked"); }
    if (_n.req != "" && !skill_has(_n.req)) { sfx("ui_error"); return L("ต้องปลดสกิลก่อนหน้า", "Unlock the previous skill first"); }
    if (_s.sp < _n.cost) { sfx("ui_error"); return L("แต้มสกิลไม่พอ", "Not enough skill points"); }

    _s.sp -= _n.cost;
    sfx("skill_unlock");
    _s.skills[$ _key] = true;

    if (instance_exists(obj_player)) {
        with (obj_player) player_apply_skills();
    }
    return "";
}

// เรียกใน obj_player: ตั้งค่าตัวแปรตามสกิลที่ปลดแล้ว (เรียกซ้ำได้เสมอ)
function player_apply_skills() {
    var _old_max = shot1_max;

    var _sd = shot_data(global.save.shot_lv);
    shot1_max         = _sd.ammo + (skill_has("a1") ? 1 : 0);
    shot1_reload      = round(_sd.reload * (skill_has("a2") ? 0.75 : 1));
    shot1_dmg         = _sd.dmg;
    shot1_size        = _sd.size;   // ★ ขนาดลูกไฟ
    skill2_unlocked   = (global.save.shot_lv >= 2);
    bullet_speed      = skill_has("a3") ? 13 : 10;
    bullet_pierce     = skill_has("a4") ? 1 : 0;
    skill2_count      = skill_has("a5") ? 5 : 3;
    var _cdm = skill_has("g6") ? 0.85 : 1;   // ★ สมาธิ: คูลดาวน์ทุกสกิลสั้นลง
    skill2_cooldown   = round(150 * _cdm);
    shot1_reload      = round(shot1_reload * _cdm);

    // ★ สกิล 3: ดาบพายุหมุน
    skill3_unlocked   = skill_has("s1");
    skill3_spins      = skill_has("b4") ? 4 : 3;
    skill3_rad        = skill_has("b4") ? 115 : 92;
    skill3_cooldown   = round((skill_has("b4") ? 200 : 270) * _cdm);
    // ★ สกิล 4: สายฟ้าลูกโซ่
    skill4_unlocked   = skill_has("m1");
    skill4_jumps      = skill_has("m3") ? 5 : 3;
    skill4_dmg        = skill_has("m5") ? 3 : 2;
    skill4_cooldown   = round((skill_has("m5") ? 200 : 300) * _cdm);
    // ★ ท่าไม้ตาย
    ult_unlocked      = skill_has("m2");
    ult_gain          = skill_has("m4") ? 7 : 5;      // เกจต่อการตีโดน 1 ครั้ง (เต็ม 100)
    ult_dmg           = skill_has("m6") ? 12 : 8;
    ult_rad           = skill_has("m6") ? 300 : 240;

    roll_cooldown     = round(22 * (skill_has("g1") ? 0.7 : 1));
    var _ps = player_stats();   // ★ ความเร็วจากเครื่องประดับ/บัฟ
    move_speed        = 4 * _ps.spd;
    run_speed         = (skill_has("g2") ? 7.3 : 6.5) * _ps.spd;
    run_accel         = skill_has("g2") ? 0.4 : 0.28;
    potion_heal       = skill_has("g3") ? 3 : 2;

    combo_window_time = skill_has("b2") ? 28 : 18;

    // หัวใจสูงสุด (สกิลใจสู้)
    apply_difficulty();
    var _gain = global.max_hp - max_hp;
    max_hp = global.max_hp;
    if (_gain > 0) hp += _gain;
    hp = min(hp, max_hp);

    // แม็กใหญ่ขึ้น = เติมกระสุนส่วนที่เพิ่มให้เลย
    shot1_ammo = clamp(shot1_ammo + max(0, shot1_max - _old_max), 0, shot1_max);
}

// ปรับข้อมูลท่าฟันตามสกิลดาบ (เรียกจาก start_attack)
function skills_modify_combo(_d, _n) {
    if (skill_has("b1") && _n >= weapon_combo_max()) _d.dmg += 1;

    if (skill_has("b2")) {
        for (var _i = 0; _i < array_length(_d.circles); _i++) {
            _d.circles[_i][2] *= 1.15;
        }
    }

    if (skill_has("b3")) {   // ★ มือไว
        _d.time = max(6, round(_d.time * 0.9));
        _d.active_from = round(_d.active_from * 0.9);
        _d.active_to = round(_d.active_to * 0.9);
    }
    return _d;
}

function skilltree_toggle() {
    if (!flag_get("tree_unlocked")) return;   // ★ ปลดตอนถึงหมู่บ้านครั้งแรก
    if (instance_exists(obj_skilltree)) return;
    if (variable_global_exists("tree_closed_at") && current_time - global.tree_closed_at < 250) return;
    if (instance_exists(obj_dialogue) || instance_exists(obj_fade)
        || instance_exists(obj_shop) || instance_exists(obj_gameover)) return;
    instance_create_depth(0, 0, -12500, obj_skilltree);
}