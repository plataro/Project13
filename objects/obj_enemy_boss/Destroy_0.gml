event_inherited();

// ★ ฉากตายอลังการ (ตัวบอสหายไปแล้ว obj_boss_death วาดต่อให้)
if (hp <= 0) {
    var _d = instance_create_depth(x, y, -100000, obj_boss_death);
    _d.spr = sprite_index;
    _d.img = image_index;
    _d.xs = image_xscale;
    _d.ys = image_yscale;
    _d.col = tint;
    _d.body_h = max(60, y - bbox_top);
    _d.boss_name = boss_name;
    _d.is_final = is_final;
}

// มินิบอสให้ 2 SP ครั้งเดียวต่อห้อง (ห้อง rm_boss เป็นบอสจริง ไม่ให้ SP)
if (hp <= 0 && room != rm_boss) {
    award_sp_once(room_get_name(room), 2, x, y);
    var _atk0 = player_atk();
    flag_set("boss_" + room_get_name(room));   // จำว่าปราบแล้ว (ใช้ปลดล็อกทางและกันเกิดซ้ำ)
    if (player_atk() > _atk0) float_text(x, y - 230, L("พลังโจมตี ", "Attack ") + string(_atk0) + " > " + string(player_atk()), c_yellow, 1.4);
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
