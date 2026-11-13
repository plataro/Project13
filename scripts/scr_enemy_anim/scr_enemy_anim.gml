// ==========================================
// ★ แอนิเมชันศัตรูทุกตัว (ภาพนิ่งทิศละ 1 ภาพ ท่าทางทำด้วยโค้ด)
// ลำดับทิศเหมือนผู้เล่น: 0 = ขวา, 1 = บน, 2 = ซ้าย (ภาพขวากลับด้าน), 3 = ล่าง
// ศัตรูตัวเล็กทุกชนิดใช้ภาพเดียวกัน แยกกันด้วยสี (tint)
// ==========================================

// [ขวา, บน, ล่าง] ของศัตรูตัวนี้
function enemy_sprite_set() {
    if (object_index == obj_enemy_boss) {
        switch (variant) {
            case "beast": return [spr_tiger_right, spr_tiger_up, spr_tiger_down];
            case "brute": return [spr_orge_right, spr_orge_up, spr_orge_down];
            case "mage":  return [spr_mage_right, spr_mage_up, spr_mage_down];
        }
        return [spr_dragon_right, spr_dragon_up, spr_dragon_down];
    }
    return [spr_enemy_right, spr_enemy_up, spr_enemy_down];
}

// เรียกใน Draw ของ obj_enemy: ตั้ง sprite_index, dflip, dbob, dang, dsx, dsy
function enemy_anim() {
    if (variable_instance_exists(id, "is_orb")) return;

    var _run = (global.hitstop <= 0);
    var _mx = x - xprevious;
    var _my = y - yprevious;
    var _spd = point_distance(0, 0, _mx, _my);

    // ---- หันหน้า ----
    // ออกท่า = หันตามทิศฟัน / ไล่ผู้เล่นอยู่ = หันหาผู้เล่น / เดินกลับบ้าน = หันตามทางเดิน
    var _want = -1;
    if (atk_state != "") _want = atk_dir;
    else if (alert_timer > 0 && instance_exists(obj_player)) _want = dir_to_player();
    else if (_spd > 0.3) _want = point_direction(0, 0, _mx, _my);

    // หน่วงไว้นิดนึง (เกิน 52° จากทิศเดิมถึงเปลี่ยน) จะได้ไม่สลับทิศกระพริบตอนอยู่แนวทแยง
    if (_want >= 0 && abs(angle_difference(_want, face * 90)) > 52) {
        face = ((round(_want / 90) mod 4) + 4) mod 4;
    }

    var _set = enemy_sprite_set();
    switch (face) {
        case 1:  sprite_index = _set[1]; dflip = 1;  break;
        case 2:  sprite_index = _set[0]; dflip = -1; break;
        case 3:  sprite_index = _set[2]; dflip = 1;  break;
        default: sprite_index = _set[0]; dflip = 1;  break;
    }
    image_index = 0;

    // ---- ท่าทาง ----
    dbob = 0; dang = 0; dsx = 1; dsy = 1;
    var _big = (object_index == obj_enemy_boss);

    if (_run && _spd > 0.4) anim_t += 0.06 + _spd * 0.07;

    if (atk_state == "windup") {
        // ง้าง: ย่อตัว เอนถอยหลัง
        var _k = 1 - atk_timer / max(1, atk_cur.windup);
        dsy = 1 - 0.1 * _k;
        dsx = 1 + 0.08 * _k;
        dang = 8 * _k * ((lengthdir_x(1, atk_dir) >= 0) ? 1 : -1);
    } else if (atk_state == "active") {
        // ฟาด: ยืดพุ่งไปข้างหน้า
        dsy = 1.08;
        dsx = 0.94;
        dang = -12 * ((lengthdir_x(1, atk_dir) >= 0) ? 1 : -1);
    } else if (hurt_t > 0) {
        dang = 10 * sin(hurt_t * 0.8);
    } else if (_spd > 0.4) {
        // เดิน: เด้งตามจังหวะก้าว + เอียงซ้ายขวา (ตัวใหญ่ = ก้าวหนัก ช้ากว่า)
        dbob = abs(sin(anim_t)) * (_big ? 5 : 4);
        dang = sin(anim_t) * (_big ? 3 : 6);
        dsy = 1 + abs(sin(anim_t)) * 0.04;
    } else {
        // ยืน: หายใจ
        dsy = 1 + sin(current_time / 380 + x * 0.1) * 0.025;
    }

    if (_run && hurt_t > 0) hurt_t--;
}
