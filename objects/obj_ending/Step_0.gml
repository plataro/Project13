if (shown_end && !instance_exists(obj_fade) && !instance_exists(obj_cutscene) && keyboard_check_pressed(vk_enter)) {
    var _f = instance_create_depth(0, 0, -10000, obj_fade);
    _f.target_room = rm_menu;
}