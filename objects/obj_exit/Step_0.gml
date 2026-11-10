locked = (instance_number(obj_enemy) > 0) || (next_room == noone);

if (!locked && !instance_exists(obj_fade) && place_meeting(x, y, obj_player)) {
    global.player_hp = obj_player.hp;   // เก็บเลือดไปด่านหน้า
    var _f = instance_create_depth(0, 0, -10000, obj_fade);
    _f.target_room = next_room;
}