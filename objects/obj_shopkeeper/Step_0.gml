near = instance_exists(obj_player) && point_distance(x, y, obj_player.x, obj_player.y) < 100;

if (near && keyboard_check_pressed(ord("E"))
    && !instance_exists(obj_shop) && !instance_exists(obj_dialogue) && !instance_exists(obj_fade)) {
    instance_create_depth(0, 0, -12000, obj_shop);
}

depth = -y;