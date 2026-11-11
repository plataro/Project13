draw_self();

// โหมด debug (F3): โชว์สถานะประตูเหนือประตู
if (global.debug) {
    var _p = instance_find(obj_player_ss, 0);
    var _ov = place_meeting(x, y, obj_player_ss);
    draw_set_font(fnt_dialog);
    draw_set_color(c_yellow);
    draw_text_transformed(x - 90, y - 150,
        "locked=" + string(locked) + " req=" + req_flag + " sword=" + string(flag_get("sword"))
        + "\nnext=" + ((next_room == noone) ? "NONE" : room_get_name(next_room))
        + "\nfade=" + string(instance_exists(obj_fade)) + " dlg=" + string(instance_exists(obj_dialogue)) + " cut=" + string(instance_exists(obj_cutscene))
        + "\noverlap=" + string(_ov), 0.6, 0.6, 0);
    draw_set_color(c_white);
    draw_rectangle_color(x - 40, y - 80, x + 104, y + 140, c_yellow, c_yellow, c_yellow, c_yellow, true);
}
