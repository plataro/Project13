// สายที่ 0 = ดาบ, 1 = ยิง, 2 = ร่างกาย  (tier = แถวจากบนลงล่าง, req = ต้องปลดตัวนี้ก่อน)
function skill_nodes() {
    return [
        { key: "b1", branch: 0, tier: 0, name: "ฟันหนัก",     desc: "ท่าฟันที่ 3 และ 4 แรงขึ้น +1",             cost: 1, req: "" },
        { key: "b2", branch: 0, tier: 1, name: "คมดาบกว้าง",   desc: "วงฟันทุกท่ากว้างขึ้น 25%",                 cost: 1, req: "b1" },
        { key: "b3", branch: 0, tier: 2, name: "พุ่งทะลวง",    desc: "ท่าพุ่งไกลขึ้น และต่อคอมโบได้ง่ายขึ้น",    cost: 2, req: "b2" },

        { key: "a1", branch: 1, tier: 0, name: "แม็กใหญ่",     desc: "สกิล 1 บรรจุ 8 นัด (จาก 6)",               cost: 1, req: "" },
        { key: "a2", branch: 1, tier: 1, name: "รีโหลดไว",     desc: "รีโหลดสกิล 1 เร็วขึ้นเกือบครึ่ง",           cost: 1, req: "a1" },
        { key: "a3", branch: 1, tier: 2, name: "กระสุนทะลุ",   desc: "กระสุนทะลุศัตรู 1 ตัว",                    cost: 2, req: "a2" },
        { key: "a4", branch: 1, tier: 3, name: "ห้าทิศ",       desc: "สกิล 2 ยิง 5 ลูก และคูลดาวน์สั้นลง",       cost: 1, req: "a3" },

        { key: "g1", branch: 2, tier: 0, name: "เท้าเบา",      desc: "กลิ้งได้ถี่ขึ้น (คูลดาวน์ลดเกือบครึ่ง)",     cost: 1, req: "" },
        { key: "g2", branch: 2, tier: 1, name: "กลิ้งยาว",     desc: "กลิ้งนานและไกลขึ้น หลบได้นานขึ้น",          cost: 1, req: "g1" },
        { key: "g3", branch: 2, tier: 2, name: "ลมใต้เท้า",    desc: "วิ่งเร็วขึ้นและออกตัวไวขึ้น",               cost: 1, req: "g2" },
        { key: "g4", branch: 2, tier: 3, name: "ยาแรง",        desc: "ยาฟื้นเลือดฟื้น 3 หัวใจ (จาก 2)",           cost: 1, req: "g3" }
    ];
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

    if (is_undefined(_n)) return "ไม่พบสกิล";
    if (skill_has(_key)) return "ปลดแล้ว";
    if (_n.req != "" && !skill_has(_n.req)) return "ต้องปลดสกิลก่อนหน้า";
    if (_s.sp < _n.cost) return "แต้มสกิลไม่พอ";

    _s.sp -= _n.cost;
    _s.skills[$ _key] = true;

    if (instance_exists(obj_player)) {
        with (obj_player) player_apply_skills();
    }
    return "";
}

// เรียกใน obj_player: ตั้งค่าตัวแปรตามสกิลที่ปลดแล้ว (เรียกซ้ำได้เสมอ)
function player_apply_skills() {
    var _old_max = shot1_max;

    shot1_max         = skill_has("a1") ? 8 : 6;
    shot1_reload      = skill_has("a2") ? 90 : 150;
    bullet_pierce     = skill_has("a3") ? 1 : 0;
    skill2_count      = skill_has("a4") ? 5 : 3;
    skill2_cooldown   = skill_has("a4") ? 120 : 150;

    roll_cooldown     = skill_has("g1") ? 16 : 30;
    roll_time         = skill_has("g2") ? 24 : 18;
    run_speed         = skill_has("g3") ? 7.3 : 6.5;
    run_accel         = skill_has("g3") ? 0.4 : 0.28;
    potion_heal       = skill_has("g4") ? 3 : 2;

    combo_window_time = skill_has("b3") ? 28 : 18;

    // แม็กใหญ่ขึ้น = เติมกระสุนส่วนที่เพิ่มให้เลย
    shot1_ammo = clamp(shot1_ammo + max(0, shot1_max - _old_max), 0, shot1_max);
}

// ปรับข้อมูลท่าฟันตามสกิลดาบ (เรียกจาก start_attack)
function skills_modify_combo(_d, _n) {
    if (skill_has("b1") && _n >= 3) _d.dmg += 1;

    if (skill_has("b2")) {
        for (var _i = 0; _i < array_length(_d.circles); _i++) {
            _d.circles[_i][2] *= 1.25;
        }
    }

    if (skill_has("b3") && _d.lunge_frames > 0) {
        _d.lunge_speed *= 1.5;
        _d.lunge_frames += 2;
    }
    return _d;
}

function skilltree_toggle() {
    if (instance_exists(obj_skilltree)) return;
    if (variable_global_exists("tree_closed_at") && current_time - global.tree_closed_at < 250) return;
    if (instance_exists(obj_dialogue) || instance_exists(obj_fade)
        || instance_exists(obj_shop) || instance_exists(obj_gameover)) return;
    instance_create_depth(0, 0, -12500, obj_skilltree);
}