if (shown_end) end_t++;
// ★ กดได้หลังหน้าจบขึ้นมาแล้วสักพัก (กันกดข้ามจากสไลด์สุดท้ายติดมา)
if (shown_end && end_t > 60 && !instance_exists(obj_fade) && !instance_exists(obj_cutscene)
    && (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || mouse_check_button_pressed(mb_left))) {
    var _f = instance_create_depth(0, 0, -10000, obj_fade);
    _f.target_room = rm_menu;
}
