function item_kinds() {
    return ["fang", "ore", "shard"];
}

// ---------- อาวุธ ----------
function weapon_data(_id) {
    switch (_id) {
        case "greatsword":
            return { name: "ดาบใหญ่", dmg: 2, time: 1.3, rad: 1.25, kb: 1.4, lunge: 0.8, price: 220,
                     desc: "ดาเมจ x2 · ช้าลงนิดหน่อย · กวาดกว้างและไกลขึ้น" };
        case "hammer":
            return { name: "ค้อน", dmg: 4, time: 2.2, rad: 1.5, kb: 2.5, lunge: 0.4, price: 520,
                     desc: "ดาเมจ x4 · ช้ามาก · ทุบกว้าง กระเด็นไกล" };
    }
    return { name: "ดาบ", dmg: 1, time: 1, rad: 1, kb: 1, lunge: 1, price: 0, desc: "สมดุล เร็ว" };
}

function weapon_owned(_id) {
    return (_id == "sword") || variable_struct_exists(global.save.weapons, _id);
}

function weapon_equip(_id) {
    if (!weapon_owned(_id) || global.save.weapon == _id) return;
    global.save.weapon = _id;
    if (instance_exists(obj_player)) float_text(obj_player.x, obj_player.y - 110, weapon_data(_id).name, c_white, 1);
}

// ปรับท่าฟันตามอาวุธ (เรียกก่อน skills_modify_combo)
function weapon_modify_combo(_d, _n) {
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
    var _b = _s.hp_bonus;
    var _bag = _s.potion_max - 3;

    switch (_id) {
        case "potion":
            return { name: "ยาฟื้นเลือด",
                     desc: "ฟื้น 2 หัวใจ กด Q ใช้ · ถืออยู่ " + string(_s.potions) + "/" + string(_s.potion_max),
                     price: 15, ok: _s.potions < _s.potion_max, why: "ถือเต็มแล้ว" };
        case "heart":
            return { name: "หัวใจเพิ่ม",
                     desc: "เลือดสูงสุด +1 (ซื้อแล้ว " + string(_b) + "/3)",
                     price: 60 + 40 * _b, ok: _b < 3, why: "ซื้อครบแล้ว" };
        case "bag":
            return { name: "กระเป๋ายา",
                     desc: "ถือยาได้เพิ่ม +1 (ซื้อแล้ว " + string(_bag) + "/2)",
                     price: 50 + 30 * _bag, ok: _bag < 2, why: "ขยายสุดแล้ว" };
        case "greatsword":
        case "hammer":
            var _w = weapon_data(_id);
            var _own = weapon_owned(_id);
            return { name: _w.name,
                     desc: _own ? ("มีแล้ว · คลิกเพื่อสวมใส่" + ((_s.weapon == _id) ? " (ใช้อยู่)" : "")) : _w.desc,
                     price: _own ? 0 : _w.price, ok: true, why: "" };
        case "armor1":
            return { name: "เกราะหนัง", desc: "ลดดาเมจที่ได้รับ -1 (ขั้นต่ำ 1)",
                     price: 300, ok: _s.armor < 1, why: "มีแล้ว" };
        case "armor2":
            return { name: "เกราะเหล็ก", desc: "ลดดาเมจที่ได้รับ -2 (ขั้นต่ำ 1)",
                     price: 650, ok: _s.armor == 1, why: (_s.armor >= 2) ? "มีแล้ว" : "ต้องมีเกราะหนังก่อน" };
    }
    return undefined;
}

// ซื้อ คืนข้อความผิดพลาด หรือ "" ถ้าซื้อสำเร็จ
function shop_buy(_id) {
    var _info = shop_item_info(_id);
    var _s = global.save;

    if (is_undefined(_info)) return "ไม่มีสินค้า";
    if (!_info.ok) return _info.why;
    if (_s.gold < _info.price) return "เหรียญไม่พอ";

    _s.gold -= _info.price;

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
    return _gain;
}
