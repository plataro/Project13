sprite_index = spr_ground_ss;
mask_index = spr_ground_ss;
image_blend = make_color_rgb(110, 130, 170);
range_x = 0;       // ระยะเลื่อนซ้าย-ขวา (px) ตั้งใน Creation Code
range_y = 0;       // ระยะเลื่อนขึ้น-ลง
period = 240;      // เฟรมต่อ 1 รอบ
t = 0;

carry_riders = function(_dx, _dy) {
    var _me = id;
    with (obj_player_ss) { if (carry_by == _me) move_and_collide(_dx, _dy, global.ss_solids); }
    with (obj_crate_ss)  { if (carry_by == _me) move_and_collide(_dx, _dy, global.ss_solids); }
}