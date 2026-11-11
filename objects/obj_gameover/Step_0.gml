alpha = min(alpha + 0.03, 0.8);

if (alpha >= 0.8 && keyboard_check_pressed(vk_enter)) {
    save_restore_snapshot();              // คืนเหรียญ/ของ/ยา เท่าตอนเข้าห้อง
    global.player_hp = global.max_hp;
    room_restart();
}