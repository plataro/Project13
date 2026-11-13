if (spr < 0) { instance_destroy(); exit; }
if (global.hitstop > 0) exit;   // hit-stop = ค้างท่าด้วย

t++;
var _play = sprite_get_number(spr) / anim_fps * 60;   // เล่นท่าตายจบในกี่เฟรม
if (t > _play + hold) {
    alpha = 1 - (t - _play - hold) / fade;
    if (alpha <= 0) instance_destroy();
}
