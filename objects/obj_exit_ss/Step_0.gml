image_blend = locked ? c_gray : c_white;

if (!locked && next_room != noone && !instance_exists(obj_fade) && place_meeting(x, y, obj_player_ss)) {
    var _f = instance_create_depth(0, 0, -10000, obj_fade);
    _f.target_room = next_room;
}