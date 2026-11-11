if (hp <= 0 && !no_drop) spawn_drops(x, y, object_index);
if (hp <= 0) fx_kill(x, y, object_index == obj_enemy_boss);