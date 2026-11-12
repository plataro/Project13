// ★ ป้าย [W] ขึ้นบันได วาดใน Draw End = อยู่หน้าตัวละครเสมอ (บันไดเป็นฉากหลัง depth 60)
// ลูกศรบอกตรงปลายบันไดเมื่อผู้เล่นอยู่ใกล้
var _p = instance_find(obj_player_ss, 0);
if (_p != noone && _p.on_stairs == noone) {
    var _near = (abs(_p.x - x) < 28 && abs(_p.y - y) < 12);   // ★ ป้ายเฉพาะปลายล่าง (ปลายบนเดินลงเองอยู่แล้ว)
    if (!variable_instance_exists(id, "pr_a")) pr_a = 0;
    pr_a = lerp(pr_a, _near ? 1 : 0, 0.2);
    ui_prompt(_p.x, _p.y - 92, "W", L("ขึ้นบันได", "Climb stairs"), pr_a);
}
draw_set_color(c_white);
