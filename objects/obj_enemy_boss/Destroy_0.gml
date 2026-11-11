event_inherited();

with (obj_enemy) {
    if (id != other.id) hp = 0;
}
with (obj_enemy_bullet) instance_destroy();
with (obj_enemy_hitbox) instance_destroy();