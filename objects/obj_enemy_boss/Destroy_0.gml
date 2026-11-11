event_inherited();

// มินิบอสให้ 2 SP ครั้งเดียวต่อห้อง (ห้อง rm_boss เป็นบอสจริง ไม่ให้ SP)
if (hp <= 0 && room != rm_boss) {
    award_sp_once(room_get_name(room), 2, x, y);
    flag_set("boss_" + room_get_name(room));   // จำว่าปราบแล้ว (ใช้ปลดล็อกทางและกันเกิดซ้ำ)
}

// ตายตามบอส (ไม่ดรอป): ลูกน้องที่บอสเรียกมา และทุกตัวในห้องบอสสุดท้าย
// ศัตรูตัวอื่นในด่านไม่ถูกลบ ต้องสู้เองถึงจะได้ของ
var _me = id;
with (obj_enemy) {
    if (id != _me && (room == rm_boss || master == _me)) {
        no_drop = true;
        hp = 0;
    }
}
with (obj_enemy_bullet) instance_destroy();
with (obj_enemy_hitbox) instance_destroy();
