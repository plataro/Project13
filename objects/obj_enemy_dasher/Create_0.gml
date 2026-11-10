event_inherited();

hp = 4;
max_hp = hp;
move_speed = 1.8;
tint = c_fuchsia;
ring_dist = 240;
attack_token_cd = 150;   // พุ่งเสร็จพักนานกว่าตัวอื่น

ai = function() {
    if (run_attack()) exit;

    var _d = dist_to_player();
    if (_d > sight_range) exit;

    if (token_cd > 0) token_cd--;
    try_get_token();

    // ไม่ได้คิว: วนรอบรอ
    if (!has_token) {
        strafe(ring_dist, move_speed);
        exit;
    }

    var _dir = dir_to_player() + flank * clamp((_d - 150) / 200, 0, 1);
    if (_d > 280) {
        hsp = lengthdir_x(move_speed * 1.3, _dir);
        vsp = lengthdir_y(move_speed * 1.3, _dir);
    } else if (has_los()) {
        begin_attack("dash");
    } else {
        strafe(ring_dist, move_speed);   // กำแพงบัง ขยับหามุม
    }
}