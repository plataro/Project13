var _solids = global.ss_solids;

// ผู้เล่นยืนข้างลังแล้วกดเดินเข้าหา = ดัน
if (place_meeting(x, y + 1, _solids)) {
    var _kd = keyboard_check(ord("D")) || keyboard_check(vk_right);
    var _ka = keyboard_check(ord("A")) || keyboard_check(vk_left);
    var _push = 0;

    if (_kd && !_ka && instance_place(x - 2, y, obj_player_ss) != noone) _push = push_speed;
    else if (_ka && !_kd && instance_place(x + 2, y, obj_player_ss) != noone) _push = -push_speed;

    if (_push != 0) move_and_collide(_push, 0, _solids);
}

vsp = min(vsp + 0.55, 14);
move_and_collide(0, vsp, _solids);
if (vsp > 0 && place_meeting(x, y + 1, _solids)) vsp = 0;

// ตกหลุม = กลับที่เดิม
if (y > room_height + 100) {
    x = xstart;
    y = ystart;
    vsp = 0;
}