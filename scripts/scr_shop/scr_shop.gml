function item_kinds() {
    return ["fang", "ore", "shard"];
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
                     price: 12, ok: _s.potions < _s.potion_max, why: "ถือเต็มแล้ว" };
        case "heart":
            return { name: "หัวใจเพิ่ม",
                     desc: "เลือดสูงสุด +1 (ซื้อแล้ว " + string(_b) + "/3)",
                     price: 40 + 20 * _b, ok: _b < 3, why: "ซื้อครบแล้ว" };
        case "bag":
            return { name: "กระเป๋ายา",
                     desc: "ถือยาได้เพิ่ม +1 (ซื้อแล้ว " + string(_bag) + "/2)",
                     price: 35 + 20 * _bag, ok: _bag < 2, why: "ขยายสุดแล้ว" };
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
    }
    return "";
}

// ขายของสะสม คืนจำนวนเหรียญที่ได้
function shop_sell(_kind, _all = false) {
    var _s = global.save;
    var _n = variable_struct_exists(_s.items, _kind) ? _s.items[$ _kind] : 0;
    if (_n <= 0) return 0;

    var _cnt = _all ? _n : 1;
    var _d = item_data(_kind);
    _s.items[$ _kind] = _n - _cnt;
    _s.gold += _d.price * _cnt;
    return _d.price * _cnt;
}