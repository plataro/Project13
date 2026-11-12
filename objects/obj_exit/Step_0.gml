if (!carved) carve();

locked = ((!ignore_boss) && (instance_number(obj_enemy_boss) > 0 || instance_exists(obj_boss_death))) || (next_room == noone)
      || (req_flag != "" && !flag_get(req_flag));
lock_msg = "";
if (locked) {
    if (next_room == noone) lock_msg = "";
    else if ((!ignore_boss) && instance_number(obj_enemy_boss) > 0) lock_msg = "ปราบบอสก่อน";
    else lock_msg = "ยังไปไม่ได้";
}

// ล็อกอยู่ = มีหินกั้นปากทาง (กันเดินออกนอกฉาก)
if (locked && !instance_exists(blocker)) {
    var _bx = x - 40;
    var _by = y - path_w;
    var _bw = 80;
    var _bh = path_w * 2;
    if (side == 1 || side == 3) { _bx = x - path_w; _by = y - 40; _bw = path_w * 2; _bh = 80; }
    blocker = instance_create_depth(_bx, _by, 0, obj_wall);
    blocker.image_xscale = _bw / 64;
    blocker.image_yscale = _bh / 64;
    blocker.visible = false;   // วาดเองด้านล่าง
    global.fog_room = -1;
} else if (!locked && instance_exists(blocker)) {
    instance_destroy(blocker);
    blocker = noone;
    global.fog_room = -1;
}

if (!locked && !instance_exists(obj_fade) && !instance_exists(obj_dialogue) && instance_exists(obj_player) && past_exit(obj_player)) {
    global.player_hp = obj_player.hp;
    if (set_flag != "") flag_set(set_flag);
    global.arrive = to_door;     // ห้องถัดไปจะให้ผู้เล่นเกิดที่ทางออกชื่อนี้
    var _f = instance_create_depth(0, 0, -10000, obj_fade);
    _f.target_room = next_room;
}
