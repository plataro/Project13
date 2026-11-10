if (place_meeting(x, y, obj_wall)) instance_destroy();
if (!point_in_rectangle(x, y, 0, 0, room_width, room_height)) instance_destroy();

if (place_meeting(x, y, obj_player)) {
    obj_player.take_damage(ceil(damage * difficulty_data().enemy_dmg), x, y);   // ★ ดาเมจตามระดับความยาก
    instance_destroy();
}