event_inherited();

// มินิบอสให้ 1 SP ครั้งเดียวต่อห้อง (ห้อง rm_boss เป็นบอสจริง ไม่ให้ SP)
if (hp <= 0 && room != rm_boss) award_sp_once(room_get_name(room), 1, x, y);

with (obj_enemy) {
    if (id != other.id) hp = 0;
}
with (obj_enemy_bullet) instance_destroy();
with (obj_enemy_hitbox) instance_destroy();