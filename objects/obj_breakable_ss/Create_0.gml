// ★ สิ่งกีดขวางไม้ (side-scroll): ตันเหมือนพื้น ฟันด้วยดาบให้พัง (กระสุนไม่มีผล)
sprite_index = spr_ground_ss;
mask_index = spr_ground_ss;
depth = -40;
hp = 3;            // ★ ฟันกี่ที
last_swing = -1;
flash = 0;

hit = function() {
    hp--;
    sfx_at("break_wood", x, y, 1, 0.1);
    flash = 6;
    fx_spark(x + sprite_width / 2, y + sprite_height / 2, 90, 8, make_color_rgb(200, 150, 90), 160);
    fx_shake(2);
    if (hp <= 0) {
        fx_spark(x + sprite_width / 2, y + sprite_height / 2, 90, 22, make_color_rgb(170, 120, 70), 180);
        fx_shake(4);
        instance_destroy();
    }
}
