t++;
if (picked && start_t < 0) exit;

var _p = instance_find(obj_player_ss, 0);
var _near = (_p != noone) && point_distance(x, y - 30, _p.x, _p.y - 30) < 110;
if (instance_exists(obj_dialogue) || instance_exists(obj_cutscene) || instance_exists(obj_fade)) _near = false;
prompt_a = lerp(prompt_a, _near ? 1 : 0, 0.15);

if (start_t >= 0) {
    // รอ 3 เฟรมก่อนเปิดบทสนทนา กัน Enter/E ที่กดหยิบไปเด้งข้ามบรรทัดแรก
    start_t--;
    if (start_t < 0) dialogue_start(story_lines("sword_found"));
    exit;
}

// กด E ตอนอยู่ใกล้ หรือเดินทับดาบก็หยิบได้เลย
var _touch = (_p != noone) && !instance_exists(obj_fade) && !instance_exists(obj_dialogue) && abs(_p.x - x) < 36 && abs(_p.y - y) < 80;
if ((_near && keyboard_check_pressed(ord("E"))) || _touch) {
    flag_set("sword");
    picked = true;
    loot_toast("ดาบ", c_white, "sword");
    start_t = 3;
}
