if (!active && place_meeting(x, y, obj_player_ss)) {
    active = true;
    image_blend = c_lime;
    with (obj_player_ss) {
        check_x = other.bbox_left + (other.bbox_right - other.bbox_left) / 2;
        check_y = other.bbox_bottom - 2;
    }
}