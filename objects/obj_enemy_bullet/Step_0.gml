if (global.hitstop > 0) exit;   // hit-stop
if (place_meeting(x, y, obj_wall)) instance_destroy();
if (!point_in_rectangle(x, y, 0, 0, room_width, room_height)) instance_destroy();

// ★ กลิ้งอยู่ = กระสุนทะลุตัวไปเลย (เดิมกระสุนหายตอนกลิ้ง ดูเหมือนโดน)
if (place_meeting(x, y, obj_player) && !obj_player.is_invulnerable()) {
    obj_player.take_damage(enemy_damage_calc(damage, from_boss), x, y);   // ★ ดาเมจตามระดับความยาก
    if (fx != "") player_add_status(fx);
    instance_destroy();
}