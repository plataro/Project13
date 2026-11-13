function item_kinds() {
    return ["fang", "ore", "shard"];
}

// ---------- อาวุธ ----------
function weapon_data(_id) {
    switch (_id) {
        case "greatsword":
            return { name: L("ดาบใหญ่", "Greatsword"), combo: 4, dmg: 2, time: 1.3, rad: 1.25, kb: 1.4, lunge: 0.8, price: 220,
                     desc: L("ดาเมจ x2 | ช้าลงนิดหน่อย | กวาดกว้างและไกลขึ้น", "Damage x2 | A bit slower | Wider, longer sweeps") };
        case "hammer":
            return { name: L("ค้อน", "Hammer"), combo: 3, dmg: 1, time: 1, rad: 1, kb: 1, lunge: 1, price: 520,
                     desc: L("คอมโบ 3 ท่า | ทุบหนัก ช้า | ท่าจบทุบพื้นเป็นคลื่นกระแทก", "3-hit combo | Heavy, slow | Finisher slams a shockwave") };
    }
    return { name: L("ดาบ", "Sword"), combo: 4, dmg: 1, time: 1, rad: 1, kb: 1, lunge: 1, price: 0, desc: L("สมดุล เร็ว", "Balanced, fast") };
}

function weapon_owned(_id) {
    return (_id == "sword") || variable_struct_exists(global.save.weapons, _id);
}

function weapon_equip(_id) {
    if (!weapon_owned(_id) || global.save.weapon == _id) return;
    global.save.weapon = _id;
    if (instance_exists(obj_player)) float_text(obj_player.x, obj_player.y - 110, weapon_data(_id).name, c_white, 1);
}

// จำนวนท่าในคอมโบของอาวุธที่ถืออยู่
function weapon_combo_max() {
    var _c = weapon_data(global.save.weapon).combo;
    if (global.save.weapon != "hammer" && skill_has("b5")) _c += 2;   // ★ ระบำหกกระบวน: คอมโบ 6 ท่า
    return _c;
}

// ปรับท่าฟันตามอาวุธ (เรียกก่อน skills_modify_combo)
function weapon_modify_combo(_d, _n) {
    if (global.save.weapon == "hammer") return hammer_step_data(_n);   // ★ ค้อนมีชุดท่าของตัวเอง
    var _w = weapon_data(global.save.weapon);
    _d.dmg = max(1, round(_d.dmg * _w.dmg));
    _d.time = max(6, round(_d.time * _w.time));
    _d.active_from = round(_d.active_from * _w.time);
    _d.active_to = round(_d.active_to * _w.time);
    _d.kb *= _w.kb;
    _d.lunge_speed *= _w.lunge;
    for (var _i = 0; _i < array_length(_d.circles); _i++) {
        _d.circles[_i][0] *= _w.rad;
        _d.circles[_i][1] *= _w.rad;
        _d.circles[_i][2] *= _w.rad;
    }
    return _d;
}

// ข้อมูลสินค้า (ราคาและเงื่อนไขขึ้นกับสถานะปัจจุบัน)
function shop_item_info(_id) {
    var _s = global.save;
    // ★ เครื่องประดับ
    var _ac = acc_data(_id);
    if (!is_undefined(_ac)) {
        var _own = acc_owned(_id);
        return { name: _ac.name + (acc_equipped(_id) ? L("  [สวมอยู่]", "  [Equipped]") : ""),
                 desc: _own ? (_ac.desc + L(" | คลิกเพื่อ", " | Click to ") + (acc_equipped(_id) ? L("ถอด", "remove") : L("สวม", "equip"))) : _ac.desc,
                 price: _own ? 0 : _ac.price, ok: true, why: "" };
    }
    // ★ ไอเท็มบัฟ
    var _bf = buff_data(_id);
    if (!is_undefined(_bf)) {
        var _n = variable_struct_exists(_s.buff_items, _id) ? _s.buff_items[$ _id] : 0;
        return { name: _bf.name, desc: _bf.desc + L(" | มี ", " | Have ") + string(_n) + L("/5 (F ใช้ | V เลือก)", "/5 (F use | V select)"),
                 price: _bf.price, ok: _n < 5, why: L("ถือได้สูงสุด 5", "Max 5") };
    }
    var _b = _s.hp_bonus;
    var _bag = _s.potion_max - 3;

    switch (_id) {
        case "potion":
            return { name: L("ยาฟื้นเลือด", "Healing Potion"),
                     desc: L("ฟื้น 2 หัวใจ กด Q ใช้ | ถืออยู่ ", "Heals 2 hearts, press Q | Carrying ") + string(_s.potions) + "/" + string(potion_cap()),
                     price: 15, ok: _s.potions < potion_cap(), why: L("ถือเต็มแล้ว", "Full") };
        case "heart":
            return { name: L("หัวใจเพิ่ม", "Extra Heart"),
                     desc: L("เลือดสูงสุด +1 (ซื้อแล้ว ", "Max HP +1 (bought ") + string(_b) + "/3)",
                     price: 60 + 40 * _b, ok: _b < 3, why: L("ซื้อครบแล้ว", "Sold out") };
        case "bag":
            return { name: L("กระเป๋ายา", "Potion Bag"),
                     desc: L("ถือยาได้เพิ่ม +1 (ซื้อแล้ว ", "Carry +1 potion (bought ") + string(_bag) + "/2)",
                     price: 50 + 30 * _bag, ok: _bag < 2, why: L("ขยายสุดแล้ว", "Maxed") };
        case "greatsword":
        case "hammer":
            var _w = weapon_data(_id);
            var _own = weapon_owned(_id);
            return { name: _w.name,
                     desc: _own ? (L("มีแล้ว | คลิกเพื่อสวมใส่", "Owned | Click to equip") + ((_s.weapon == _id) ? L(" (ใช้อยู่)", " (in use)") : "")) : _w.desc,
                     price: _own ? 0 : _w.price, ok: true, why: "" };
        case "armor1":
            return { name: L("เกราะหนัง", "Leather Armor"), desc: L("ลดดาเมจที่ได้รับ -1 (ขั้นต่ำ 1)", "Damage taken -1 (min 1)"),
                     price: 300, ok: _s.armor < 1, why: L("มีแล้ว", "Owned") };
        case "armor2":
            return { name: L("เกราะเหล็ก", "Iron Armor"), desc: L("ลดดาเมจที่ได้รับ -2 (ขั้นต่ำ 1)", "Damage taken -2 (min 1)"),
                     price: 650, ok: _s.armor == 1, why: (_s.armor >= 2) ? L("มีแล้ว", "Owned") : L("ต้องมีเกราะหนังก่อน", "Need Leather Armor first") };
    }
    return undefined;
}

// ซื้อ คืนข้อความผิดพลาด หรือ "" ถ้าซื้อสำเร็จ
function shop_buy(_id) {
    var _info = shop_item_info(_id);
    var _s = global.save;

    if (is_undefined(_info)) { sfx("ui_error"); return L("ไม่มีสินค้า", "No such item"); }
    if (!_info.ok) { sfx("ui_error"); return _info.why; }
    if (_s.gold < _info.price) { sfx("ui_error"); return L("เหรียญไม่พอ", "Not enough gold"); }

    _s.gold -= _info.price;
    sfx("buy");

    // ★ เครื่องประดับ: ซื้อแล้วสวมเลยถ้าช่องว่าง / มีแล้ว = สวมหรือถอด
    if (!is_undefined(acc_data(_id))) {
        if (acc_owned(_id)) acc_toggle(_id);
        else {
            _s.acc[$ _id] = true;
            if (array_length(_s.acc_eq) < 2) acc_toggle(_id);
        }
        apply_difficulty();
        if (instance_exists(obj_player)) { obj_player.max_hp = global.max_hp; obj_player.hp = min(obj_player.hp, obj_player.max_hp); }
        return "";
    }
    // ★ ไอเท็มบัฟ
    if (!is_undefined(buff_data(_id))) {
        _s.buff_items[$ _id] = (variable_struct_exists(_s.buff_items, _id) ? _s.buff_items[$ _id] : 0) + 1;
        return "";
    }

    switch (_id) {
        case "potion":
            _s.potions++;
            break;
        case "heart":
            _s.hp_bonus++;
            apply_difficulty();
            if (instance_exists(obj_player)) {
                obj_player.max_hp = global.max_hp;
                obj_player.hp = min(obj_player.hp + 1, obj_player.max_hp);
            }
            break;
        case "bag":
            _s.potion_max++;
            break;
        case "greatsword":
        case "hammer":
            _s.weapons[$ _id] = true;
            _s.weapon = _id;
            break;
        case "armor1":
            _s.armor = 1;
            break;
        case "armor2":
            _s.armor = 2;
            break;
    }
    return "";
}

// ขายของสะสม คืนจำนวนเหรียญที่ได้ (_mul = ตัวคูณราคาของร้านนั้น)
function shop_sell(_kind, _all = false, _mul = 1) {
    var _s = global.save;
    var _n = variable_struct_exists(_s.items, _kind) ? _s.items[$ _kind] : 0;
    if (_n <= 0) return 0;

    var _cnt = _all ? _n : 1;
    var _d = item_data(_kind);
    _s.items[$ _kind] = _n - _cnt;
    var _gain = round(_d.price * _mul) * _cnt;
    _s.gold += _gain;
    if (_gain > 0) sfx("sell");
    return _gain;
}

// สลับอาวุธตามลำดับ (_dir = 1 ถัดไป, -1 ก่อนหน้า) ข้ามอันที่ยังไม่มี
function weapon_cycle(_dir) {
    var _list = ["sword", "greatsword", "hammer"];
    var _n = array_length(_list);
    var _i = array_get_index(_list, global.save.weapon);
    for (var _k = 1; _k <= _n; _k++) {
        var _id = _list[((_i + _dir * _k) mod _n + _n) mod _n];
        if (weapon_owned(_id)) {
            weapon_equip(_id);
            return;
        }
    }
}

// =====================================================================
// ★ เครื่องประดับ (ร้านช่างอัญมณี) สวมได้ 2 ช่อง เปลี่ยนที่หน้าสถานะ (ปุ่ม I)
// atk = ATK +% · crit = คริ +% · critdmg = แรงคริ +% · spd = ความเร็ว +% · def = ลดดาเมจ · hp = หัวใจ
// burn / poison / stun = โอกาสติดสถานะให้ศัตรูตอนตีโดน
// =====================================================================
function acc_list() {
    return ["ring_power", "neck_hunter", "ear_slayer", "brace_wind", "charm_stone", "heart_stone", "amulet_fire", "fang_snake", "seal_thunder",
            "eye_hawk", "scale_guard", "ember_crown", "feather_moon"];
}
// ★ ของที่ขายในร้านอัญมณี (ของพิเศษจากหีบปริศนาไม่ขาย)
function acc_shop_list() {
    return ["ring_power", "neck_hunter", "ear_slayer", "brace_wind", "charm_stone", "heart_stone", "amulet_fire", "fang_snake", "seal_thunder"];
}
function acc_is_special(_id) {
    return (_id == "eye_hawk" || _id == "scale_guard" || _id == "ember_crown" || _id == "feather_moon");
}

function acc_data(_id) {
    switch (_id) {
        case "ring_power":   return { name: L("แหวนพละกำลัง", "Ring of Might"),   desc: "ATK +15%",                    price: 180, atk: 0.15 };
        case "neck_hunter":  return { name: L("สร้อยนักล่า", "Hunter's Necklace"),     desc: L("โอกาสคริ +10%", "Crit chance +10%"),                price: 160, crit: 0.10 };
        case "ear_slayer":   return { name: L("ต่างหูพิฆาต", "Slayer's Earring"),     desc: L("ดาเมจคริ +40%", "Crit damage +40%"),                price: 200, critdmg: 0.4 };
        case "brace_wind":   return { name: L("กำไลสายลม", "Wind Bracelet"),       desc: L("ความเร็ว +10%", "Speed +10%"),                price: 150, spd: 0.10 };
        case "charm_stone":  return { name: L("เครื่องรางหินผา", "Stone Charm"), desc: L("ลดดาเมจที่ได้รับ -1 (ขั้นต่ำ 1)", "Damage taken -1 (min 1)"), price: 420, def: 1 };
        case "heart_stone":  return { name: L("หัวใจศิลา", "Stone Heart"),        desc: L("หัวใจสูงสุด +1", "Max hearts +1"),               price: 380, hp: 1 };
        case "amulet_fire":  return { name: L("จี้เพลิง", "Flame Pendant"),          desc: L("ตีโดน 20% ติดไฟไหม้", "20% on hit: Burn"),           price: 240, burn: 0.20 };
        case "fang_snake":   return { name: L("เขี้ยวอสรพิษ", "Serpent Fang"),     desc: L("ตีโดน 25% ติดพิษ (ช้าลง)", "25% on hit: Poison (slow)"),       price: 220, poison: 0.25 };
        case "seal_thunder": return { name: L("ตราสายฟ้า", "Thunder Seal"),       desc: L("ตีโดน 10% ทำให้ศัตรูสตัน", "10% on hit: Stun"),      price: 320, stun: 0.10 };
        // ★ ของพิเศษจากหีบปริศนา (หลายค่ารวมกัน หาซื้อไม่ได้)
        case "eye_hawk":     return { name: L("ดวงตาเหยี่ยว", "Hawk's Eye"),      desc: L("โอกาสคริ +15% | ดาเมจคริ +30%", "Crit chance +15% | Crit damage +30%"), price: 0, crit: 0.15, critdmg: 0.3 };
        case "scale_guard":  return { name: L("เกล็ดพิทักษ์", "Guardian Scale"),   desc: L("หัวใจ +1 | ลดดาเมจ -1", "Max hearts +1 | Damage taken -1"),       price: 0, hp: 1, def: 1 };
        case "ember_crown":  return { name: L("มงกุฎถ่านเพลิง", "Ember Crown"),   desc: L("ATK +20% | ตีโดน 15% ติดไฟไหม้", "ATK +20% | 15% on hit: Burn"),     price: 0, atk: 0.20, burn: 0.15 };
        case "feather_moon": return { name: L("ขนนกจันทรา", "Moon Feather"),     desc: L("ความเร็ว +15% | ตีโดน 10% สตัน", "Speed +15% | 10% on hit: Stun"),    price: 0, spd: 0.15, stun: 0.10 };
    }
    return undefined;
}

function acc_owned(_id) {
    return variable_struct_exists(global.save.acc, _id);
}
function acc_equipped(_id) {
    return array_contains(global.save.acc_eq, _id);
}
// สวม/ถอด (ช่องเต็มแล้ว = แทนที่ช่องแรก)
function acc_toggle(_id) {
    var _eq = global.save.acc_eq;
    var _i = array_get_index(_eq, _id);
    if (_i >= 0) array_delete(_eq, _i, 1);
    else {
        if (array_length(_eq) >= 2) array_delete(_eq, 0, 1);
        array_push(_eq, _id);
    }
    if (instance_exists(obj_player)) with (obj_player) player_apply_skills();
}

// =====================================================================
// ★ บัฟชั่วคราว (ร้านนักปรุงยา) กด F ใช้ / V เลือก   ใช้แล้วอยู่ 60 วิ
// =====================================================================
function buff_list() {
    return ["buff_atk", "buff_def", "buff_spd", "buff_fire", "cleanse"];
}

function buff_data(_id) {
    switch (_id) {
        case "buff_atk":  return { name: L("ยาพละกำลัง", "Might Tonic"),  desc: L("ATK +25% 60 วิ", "ATK +25% for 60s"),                  price: 40, t: 3600, col: make_color_rgb(255, 120, 80) };
        case "buff_def":  return { name: L("ยาผิวเหล็ก", "Ironskin Tonic"),  desc: L("ลดดาเมจที่ได้รับ -1 60 วิ", "Damage taken -1 for 60s"),         price: 55, t: 3600, col: make_color_rgb(150, 170, 200) };
        case "buff_spd":  return { name: L("ยาสายลม", "Swift Tonic"),     desc: L("ความเร็ว +20% 60 วิ", "Speed +20% for 60s"),              price: 35, t: 3600, col: make_color_rgb(140, 230, 200) };
        case "buff_fire": return { name: L("น้ำมันเพลิง", "Fire Oil"), desc: L("ตีโดน 50% ติดไฟไหม้ 60 วิ", "50% on hit: Burn for 60s"),         price: 45, t: 3600, col: make_color_rgb(255, 170, 40) };
        case "cleanse":   return { name: L("ยาล้างพิษ", "Antidote"),   desc: L("ล้างไฟไหม้ พิษ ทันที", "Instantly cures Burn & Poison"),               price: 20, t: 0,    col: make_color_rgb(200, 255, 200) };
    }
    return undefined;
}

function buff_active(_id) {
    for (var _i = 0; _i < array_length(global.buffs); _i++) if (global.buffs[_i].id == _id) return true;
    return false;
}

// ใช้ไอเท็มบัฟ คืนข้อความ
function buff_use(_id) {
    var _s = global.save;
    var _n = variable_struct_exists(_s.buff_items, _id) ? _s.buff_items[$ _id] : 0;
    if (_n <= 0) return "";
    _s.buff_items[$ _id] = _n - 1;
    sfx("buff");
    var _d = buff_data(_id);
    if (_id == "cleanse") {
        if (instance_exists(obj_player)) with (obj_player) { st_burn = 0; st_poison = 0; }
    } else {
        // ใช้ซ้ำ = รีเวลา ไม่ซ้อน
        for (var _i = array_length(global.buffs) - 1; _i >= 0; _i--) if (global.buffs[_i].id == _id) array_delete(global.buffs, _i, 1);
        array_push(global.buffs, { id: _id, t: _d.t, t0: _d.t });
    }
    if (instance_exists(obj_player)) {
        with (obj_player) player_apply_skills();
        float_text(obj_player.x, obj_player.y - 120, _d.name + "!", _d.col, 1.1);
    }
    return _d.name;
}
global.buffs = [];
global.buff_sel = 0;

// =====================================================================
// ★ สถานะรวมของผู้เล่น (อาวุธ + เครื่องประดับ + บัฟ)
// =====================================================================
function player_stats() {
    var _st = { atk: 1, crit: 0.08, critdmg: 1.6, spd: 1, def: global.save.armor, hp: 0, burn: 0, poison: 0, stun: 0 };
    var _eq = global.save.acc_eq;
    for (var _i = 0; _i < array_length(_eq); _i++) {
        var _a = acc_data(_eq[_i]);
        if (is_undefined(_a)) continue;
        if (variable_struct_exists(_a, "atk"))     _st.atk += _a.atk;
        if (variable_struct_exists(_a, "crit"))    _st.crit += _a.crit;
        if (variable_struct_exists(_a, "critdmg")) _st.critdmg += _a.critdmg;
        if (variable_struct_exists(_a, "spd"))     _st.spd += _a.spd;
        if (variable_struct_exists(_a, "def"))     _st.def += _a.def;
        if (variable_struct_exists(_a, "hp"))      _st.hp += _a.hp;
        if (variable_struct_exists(_a, "burn"))    _st.burn += _a.burn;
        if (variable_struct_exists(_a, "poison"))  _st.poison += _a.poison;
        if (variable_struct_exists(_a, "stun"))    _st.stun += _a.stun;
    }
    if (buff_active("buff_atk"))  _st.atk += 0.25;
    if (buff_active("buff_def"))  _st.def += 1;
    if (buff_active("buff_spd"))  _st.spd += 0.20;
    if (buff_active("buff_fire")) _st.burn += 0.5;
    return _st;
}

// ตีโดนศัตรู: สุ่มติดสถานะตามเครื่องประดับ/บัฟ
function player_on_hit(_e) {
    if (!instance_exists(_e) || variable_instance_exists(_e, "is_orb")) return;
    var _st = player_stats();
    if (_st.burn > 0 && random(1) < _st.burn) enemy_add_status(_e, "burn");
    if (_st.poison > 0 && random(1) < _st.poison) enemy_add_status(_e, "poison");
    if (_st.stun > 0 && random(1) < _st.stun) enemy_add_status(_e, "stun");
}

// =====================================================================
// ★ สถานะผิดปกติของศัตรู
// burn = ไฟไหม้ 3 ครั้ง ทุก 0.5 วิ (25% ATK) · poison = พิษ 5 ครั้ง ทุก 0.75 วิ (15% ATK) + ช้าลง 30%
// stun = หยุดทำอะไร 1 วิ (บอก 0.4 วิ)
// =====================================================================
function enemy_add_status(_e, _kind) {
    with (_e) {
        var _boss = (object_index == obj_enemy_boss);
        switch (_kind) {
            case "burn":   st_burn = 90;  break;
            case "poison": st_poison = 225; break;
            case "stun":
                if (_boss && variable_instance_exists(id, "state") && (state == "ult" || state == "ult_boom")) break;
                st_stun = _boss ? 24 : 60;
                if (atk_state == "windup") { atk_state = ""; atk_cur = undefined; telegraph = false; }
                float_text(x, y - 120, L("สตัน!", "Stunned!"), c_yellow, 0.9);
                break;
        }
    }
}

// ดาเมจจากสถานะ (ไม่มีคริ ไม่สะดุ้ง) ตัวเลขสีตามสถานะ
function enemy_status_damage(_e, _mul, _col) {
    with (_e) {
        if (variable_instance_exists(id, "shield") && shield > 0) return;
        if (variable_instance_exists(id, "invuln") && invuln > 0) return;
        var _d = max(1, round(player_atk() * _mul));
        hp -= _d;
        combo_add(_d, false);   // ★ บวกเข้าดาเมจรวม
        hp_bar_timer = 180;
        if (global.show_dmg) {
            var _r = enemy_hurt_rect(id);
            var _t = spawn_damage_text((_r[0] + _r[2]) / 2 + irandom_range(-10, 10), _r[1] + 10, _d);
            if (_t != noone) { _t.col = _col; _t.size = 0.8; }
        }
    }
}

// =====================================================================
// ★ สถานะผิดปกติของผู้เล่น (จากท่าโจมตีศัตรู)
// burn = ไฟติดตัว 2.5 วิ แล้วเสีย 1 หัวใจ (กลิ้งเพื่อดับไฟ) · poison = ช้าลง 30% 4 วิ · stun = ขยับไม่ได้ 0.5 วิ
// =====================================================================
function player_add_status(_kind) {
    if (!instance_exists(obj_player)) return;
    with (obj_player) {
        switch (_kind) {
            case "burn":   if (st_burn <= 0) float_text(x, y - 120, L("ไฟไหม้! กลิ้งเพื่อดับ", "Burning! Roll to put out"), c_orange, 0.9); st_burn = 150; break;
            case "poison": st_poison = 240; float_text(x, y - 120, L("ติดพิษ! ช้าลง", "Poisoned! Slowed"), make_color_rgb(140, 220, 90), 0.9); break;
            case "stun":   st_stun = 30; break;
        }
    }
}

// ★ เปิด/ปิดหน้าสถานะ (ปุ่ม I)
function status_toggle() {
    if (instance_exists(obj_status)) return;
    if (variable_global_exists("status_closed_at") && current_time - global.status_closed_at < 250) return;
    if (instance_exists(obj_dialogue) || instance_exists(obj_fade) || instance_exists(obj_shop)
        || instance_exists(obj_skilltree) || instance_exists(obj_gameover)) return;
    instance_create_depth(0, 0, -12500, obj_status);
}

// ★ ชื่อร้านตามชนิด (2 ภาษา)
function shop_type_name(_type) {
    switch (_type) {
        case "smith":     return L("ช่างตีเหล็ก", "Blacksmith");
        case "alchemist": return L("นักปรุงยา", "Alchemist");
        case "jeweler":   return L("ร้านอัญมณี", "Jeweler");
        case "buyer":     return L("ของเก่า (รับซื้อ)", "Antiques (Buyer)");
    }
    return L("พ่อค้า", "Merchant");
}
