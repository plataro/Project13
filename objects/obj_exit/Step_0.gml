locked = (instance_number(obj_enemy_boss) > 0) || (next_room == noone)
      || (req_flag != "" && !flag_get(req_flag));

if (!locked && !instance_exists(obj_fade) && place_meeting(x, y, obj_player)) {
    global.player_hp = obj_player.hp;
    if (set_flag != "") flag_set(set_flag);
    // จำจุดกลับ: ถ้าออกจากหมู่บ้าน คราวหน้ากลับมาจะเกิดหน้าประตูนี้
    if (room == rm_the_village) global.village_return = { x: x, y: y + 120 };
    var _f = instance_create_depth(0, 0, -10000, obj_fade);
    _f.target_room = next_room;
}