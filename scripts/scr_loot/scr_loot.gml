// ข้อมูลของสะสม (ขายกลับได้) สี/ภาพชั่วคราว ใส่ภาพจริงที่ช่อง spr ทีหลัง
function item_data(_kind) {
    switch (_kind) {
        case "fang":  return { name: "เขี้ยวป่า",    price: 4,  col: c_white,                       spr: -1 };
        case "ore":   return { name: "แร่เหมือง",     price: 9,  col: make_color_rgb(110, 150, 220), spr: -1 };
        case "shard": return { name: "เศษคริสตัล",   price: 16, col: make_color_rgb(190, 90, 255),  spr: -1 };
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
            return true;

        case "potion":
            if (_s.potions >= _s.potion_max) return false;
            _s.potions++;
            float_text(_x, _y - 30, "+ยา", c_red, 0.8);
            return true;

        default:
            _d = item_data(_kind);
            if (is_undefined(_d)) return true;
            _n = variable_struct_exists(_s.items, _kind) ? _s.items[$ _kind] : 0;
            _s.items[$ _kind] = _n + 1;
            float_text(_x, _y - 30, "+" + _d.name, _d.col, 0.7);
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

// HUD เหรียญและยา มุมขวาบน (ใช้ทั้งโหมด top-down และ side-scroll)
function draw_hud_money() {
    var _s = global.save;
    draw_set_font(fnt_dialog);
    draw_set_halign(fa_right);
    draw_set_valign(fa_middle);

    // เหรียญ
    draw_set_color(c_black);
    draw_circle(932, 36, 10, false);
    draw_set_color(c_yellow);
    draw_circle(932, 36, 8, false);
    draw_set_color(c_orange);
    draw_circle(932, 36, 3, false);
    draw_set_color(c_white);
    draw_text_transformed(914, 36, string(_s.gold), 1, 1, 0);

    // ยา (ช่องแดง) ปุ่ม Q
    for (var _i = 0; _i < _s.potion_max; _i++) {
        var _px = 932 - _i * 22;
        draw_set_color(c_black);
        draw_rectangle(_px - 17, 62, _px, 80, false);
        draw_set_color((_i < _s.potions) ? c_red : c_dkgray);
        draw_rectangle(_px - 16, 63, _px - 1, 79, false);
    }
    draw_set_color(c_white);
    draw_text_transformed(932 - _s.potion_max * 22 - 6, 71, "Q", 0.6, 0.6, 0);


    if (_s.sp > 0) {
        draw_set_halign(fa_right);
        draw_set_color(make_color_rgb(255, 220, 90));
        draw_text_transformed(932, 96, "[T] สกิล  SP " + string(_s.sp), 0.6, 0.6, 0);
    }
    // อาวุธ/เกราะ (กด 1-3 สลับอาวุธ)
    draw_set_halign(fa_right);
    draw_set_color(c_ltgray);
    draw_text_transformed(932, 116, "[1-3] " + weapon_data(_s.weapon).name + ((_s.armor > 0) ? ("  เกราะ " + string(_s.armor)) : ""), 0.6, 0.6, 0);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}