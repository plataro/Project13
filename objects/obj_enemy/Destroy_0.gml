if (hp <= 0 && !no_drop) spawn_drops(x, y, object_index);
if (hp <= 0) fx_kill(x, y, object_index == obj_enemy_boss);

// ★ Chaser: ทิ้งร่างเล่นท่าตายตามทิศที่หันอยู่
if (hp <= 0 && is_chaser && !variable_instance_exists(id, "is_orb")) {
    var _c = instance_create_depth(x, y, depth, obj_enemy_corpse);
    _c.spr = chaser_sprites().death[face];
    _c.dscale = dscale;
}