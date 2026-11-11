locked = ((!ignore_boss) && instance_number(obj_enemy_boss) > 0) || (next_room == noone)
      || (req_flag != "" && !flag_get(req_flag));

if (!locked && !instance_exists(obj_fade) && !instance_exists(obj_dialogue) && place_meeting(x, y, obj_player)) {
    global.player_hp = obj_player.hp;
    if (set_flag != "") flag_set(set_flag);
    global.arrive = to_door;     // ห้องถัดไปจะให้ผู้เล่นเกิดที่ประตูชื่อนี้
    var _f = instance_create_depth(0, 0, -10000, obj_fade);
    _f.target_room = next_room;
}