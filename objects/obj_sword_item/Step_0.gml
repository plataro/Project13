t++;
if (picked) exit;

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

if (_near && keyboard_check_pressed(ord("E"))) {
    flag_set("sword");
    picked = true;
    start_t = 3;
}
