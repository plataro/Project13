alpha = min(alpha + 0.03, 0.8);

if (alpha >= 0.8 && (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || mouse_check_button_pressed(mb_left))) {
    save_restore_snapshot();              // คืนเหรียญ/ของ/ยา เท่าตอนเข้าห้อง
    global.player_hp = global.max_hp;
    room_restart();
}