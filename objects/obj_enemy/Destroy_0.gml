if (hp <= 0 && !no_drop) spawn_drops(x, y, object_index);
if (hp <= 0) fx_kill(x, y, object_index == obj_enemy_boss);

// ★ ศัตรูตัวเล็ก: ทิ้งร่างล้มลงตามทิศที่หันอยู่ (บอสมีฉากตายของตัวเอง)
if (hp <= 0 && object_index != obj_enemy_boss && !variable_instance_exists(id, "is_orb")) {
    var _c = instance_create_depth(x, y, depth, obj_enemy_corpse);
    _c.spr = sprite_index;
    _c.dscale = dscale;
    _c.flip = dflip;
    _c.col = tint;
}
