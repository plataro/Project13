// ข้อมูลของสะสม (ขายกลับได้) สี/ภาพชั่วคราว ใส่ภาพจริงที่ช่อง spr ทีหลัง
function item_data(_kind) {
    switch (_kind) {
        case "fang":  return { name: L("เขี้ยวป่า", "Wild Fang"),    price: 4,  col: c_white,                       spr: -1 };
        case "ore":   return { name: L("แร่เหมือง", "Mine Ore"),     price: 9,  col: make_color_rgb(110, 150, 220), spr: -1 };
        case "shard": return { name: L("เศษคริสตัล", "Crystal Shard"),   price: 16, col: make_color_rgb(190, 90, 255),  spr: -1 };
    }
    return undefined;
}

// ศัตรูในห้องนี้ดรอปของสะสมอะไร
function loot_kind_for_room() {
    switch (room) {
        case rm_level_2_the_abandoned_mine: return "ore";
        case rm_level_3_the_castle:
        case rm_boss: return "shard";
    }
    return "fang";
}

function float_text(_x, _y, _txt, _col = c_white, _size = 1) {
    var _t = instance_create_depth(_x, _y, -20000, obj_damage_text);
    _t.txt = _txt;
    _t.col = _col;
    _t.size = _size;
}

// ปล่อยของเด้งออกมา
function pickup_spawn(_x, _y, _kind, _value = 1) {
    var _p = instance_create_depth(_x, _y, -_y, obj_pickup);
    _p.kind = _kind;
    _p.value = _value;
    var _a = random(360);
    var _s = random_range(1.5, 4);
    _p.hsp = lengthdir_x(_s, _a);
    _p.vsp = lengthdir_y(_s, _a);
    _p.zv = random_range(3, 5);
    return _p;
}

// ศัตรูตายแล้วดรอปอะไร _obj คือ object_index ของศัตรู
function spawn_drops(_x, _y, _obj) {
    var _tr = tier_data();
    var _n = irandom_range(2, 4);   // จำนวนเหรียญ
    var _v = _tr.coin;               // มูลค่าเหรียญละ (ด่านลึกได้มากกว่า)
    var _loot = 0.3;                 // โอกาสดรอปของสะสม

    switch (_obj) {
        case obj_enemy_boss:
            _n = 5; _v = _tr.coin * 5; _loot = 1;
            break;
        case obj_enemy_dasher:
        case obj_enemy_shooter:
            _n = irandom_range(3, 6); _loot = 0.4;
            break;
    }

    repeat (_n) pickup_spawn(_x, _y, "gold", _v);
    if (random(1) < _loot) pickup_spawn(_x, _y, loot_kind_for_room());
    if (random(1) < 0.08) pickup_spawn(_x, _y, "potion");
}

// เก็บของ คืน true ถ้าเก็บได้ (ยาเต็มแล้วเก็บไม่ได้)
function pickup_collect(_kind, _value, _x, _y) {
    var _s = global.save;
    var _d;
    var _n;

    switch (_kind) {
        case "gold":
            _s.gold += _value;
            loot_toast("G", make_color_rgb(255, 210, 80), "coin", _value);
            return true;

        case "potion":
            if (_s.potions >= potion_cap()) return false;
            _s.potions++;
            loot_toast(L("ยาฟื้นเลือด", "Healing Potion"), make_color_rgb(255, 110, 110), "potion");
            return true;

        default:
            _d = item_data(_kind);
            if (is_undefined(_d)) return true;
            _n = variable_struct_exists(_s.items, _kind) ? _s.items[$ _kind] : 0;
            _s.items[$ _kind] = _n + 1;
            loot_toast(_d.name, _d.col, "gem");
            return true;
    }
}

// เรียกจาก obj_player (ปุ่ม Q) ใช้ยา ฟื้น 2 หัวใจ
function player_use_potion() {
    var _s = global.save;
    if (hp <= 0 || hp >= max_hp || _s.potions <= 0) return false;
    if (variable_instance_exists(id, "last_potion") && current_time - last_potion < 600) return false;

    last_potion = current_time;
    _s.potions--;
    var _heal = variable_instance_exists(id, "potion_heal") ? potion_heal : 2;
    hp = min(max_hp, hp + _heal);
    float_text(x, y - 90, "+" + string(_heal), c_lime, 1.2);
    return true;
}

// HUD เหรียญ ยา SP อาวุธ มุมขวาบน (ใช้ทั้งโหมด top-down และ side-scroll)
function draw_hud_money() {
    var _s = global.save;
    draw_set_font(fnt_dialog);
    var _x2 = 946;
    var _x1 = 760;
    var _y1 = 12;
    var _lines = 2 + ((_s.sp > 0) ? 1 : 0);
    var _y2 = _y1 + 16 + _lines * 22;
    ui_panel(_x1, _y1, _x2, _y2, 0.85);

    // เหรียญ
    var _cy = _y1 + 20;
    draw_set_color(c_black);
    draw_circle(_x1 + 20, _cy, 9, false);
    draw_set_color(make_color_rgb(250, 210, 70));
    draw_circle(_x1 + 20, _cy, 7, false);
    draw_set_color(make_color_rgb(200, 140, 30));
    draw_circle(_x1 + 20, _cy, 3, false);
    draw_set_valign(fa_middle);
    ui_text_bold(_x1 + 36, _cy, string(_s.gold), 0.55, make_color_rgb(255, 225, 120));
    // ยา
    draw_set_halign(fa_right);
    ui_text(_x2 - 12, _cy, L("ยา ", "Potion ") + string(_s.potions) + "/" + string(potion_cap()), 0.45, make_color_rgb(255, 130, 130));
    draw_set_halign(fa_left);

    // อาวุธ / เกราะ
    var _multi = array_length(variable_struct_get_names(_s.weapons)) > 0;   // มีอาวุธมากกว่า 1 ชิ้นถึงโชว์ [R]
    ui_text(_x1 + 14, _cy + 22, (_multi ? "[" + input_label("weapon") + "] " : "") + weapon_data(_s.weapon).name + ((_s.armor > 0) ? (L("  |  เกราะ ", "  |  Armor ") + string(_s.armor)) : ""), 0.45, UI_TEXT);

    // แต้มสกิล
    if (_s.sp > 0) {
        ui_text(_x1 + 14, _cy + 44, (flag_get("tree_unlocked") ? "[" + input_label("tree") + "] " + L("แต้มสกิล ", "Skill Points ") : L("แต้มสกิล ", "Skill Points ")) + string(_s.sp), 0.45, make_color_rgb(255, 220, 90));
    }
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);

    // ★ ของที่ได้รับ (ใต้แผง)
    draw_loot_feed(_y2 + 10);
}
