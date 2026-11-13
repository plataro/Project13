// ==========================================
// ★ ตัวละครหลัก: ภาพนิ่งทิศละ 1 ภาพ (ไม่มีเฟรมแอนิเมชัน)
//   ท่าเดิน / กลิ้ง / ฟัน / โดนตี ทำในโค้ดทั้งหมด (เด้ง เอียง หมุน ยืดหด)
// face: 0 = ขวา, 1 = บน, 2 = ซ้าย (ใช้ภาพขวากลับด้าน), 3 = ล่าง
// ==========================================

global.pl_scale = 2;

// คืน [sprite, flip] ของตัวละครตามทิศ
function pl_body(_face) {
    switch (_face) {
        case 1: return [spr_pl_up, 1];
        case 2: return [spr_pl_right, -1];
        case 3: return [spr_pl_down, 1];
    }
    return [spr_pl_right, 1];
}

// sprite อาวุธที่ถืออยู่ (วาดแนวนอน ด้ามซ้าย ปลายชี้ขวา origin = ด้าม)
function pl_weapon_sprite() {
    switch (global.save.weapon) {
        case "hammer":     return spr_wpn_hammer;
        case "greatsword": return spr_wpn_greatsword;
    }
    return spr_wpn_sword;
}

// ★ วาดอาวุธ: _hx,_hy = ตำแหน่งมือ, _ang = ทิศที่อาวุธชี้, _reach = ยื่นออกไปข้างหน้า (px)
function pl_draw_weapon(_hx, _hy, _ang, _reach, _col, _alpha) {
    var _w = pl_weapon_sprite();
    var _s = global.pl_scale;
    // ชี้ไปทางซ้าย = กลับภาพแนวตั้ง กันการ์ดดาบกลับหัว
    var _ys = (lengthdir_x(1, _ang) < 0) ? -_s : _s;
    draw_sprite_ext(_w, 0, round(_hx + lengthdir_x(_reach, _ang)), round(_hy + lengthdir_y(_reach, _ang)), _s, _ys, _ang, _col, _alpha);
}

function ease_out3(_k) {
    _k = clamp(_k, 0, 1);
    return 1 - power(1 - _k, 3);
}
