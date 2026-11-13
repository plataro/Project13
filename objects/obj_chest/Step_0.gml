if (!inited) {
    inited = true;
    opened = (key != "" && flag_get("chest_" + key));
}

var _p = noone;
if (instance_exists(obj_player)) _p = obj_player.id;
else if (instance_exists(obj_player_ss)) _p = obj_player_ss.id;

near = (_p != noone) && !opened && trial_state == 0 && point_distance(x, y, _p.x, _p.y) < 90;
// ★ มีกำแพง/ประตูกั้นระหว่างผู้เล่นกับหีบ = เปิดไม่ได้ (หีบในห้องรางวัลต้องเปิดประตูก่อน)
if (near && collision_line(x, y - 12, _p.x, _p.y - 8, obj_wall, false, true) != noone) near = false;

var _press = near && input_pressed("interact")
    && !instance_exists(obj_dialogue) && !instance_exists(obj_fade)
    && !instance_exists(obj_shop) && !instance_exists(obj_skilltree);

if (!trial) {
    if (_press) open_chest();
}
// ===== หีบบททดสอบ =====
else if (!opened) {
    if (trial_state == 0) {
        if (_press) {
            trial_state = 1;
            sfx("trial_start");
            trial_wave = 0;
            trial_t = 45;
            float_text(x, y - 110, L("บททดสอบเริ่ม!", "Trial begins!"), make_color_rgb(200, 120, 255), 1.4);
        }
    } else if (global.hitstop <= 0 && !instance_exists(obj_dialogue) && !instance_exists(obj_fade)) {
        if (_p == noone || point_distance(x, y, _p.x, _p.y) > trial_r) {
            trial_fail();
        } else if (trial_alive() == 0) {
            if (trial_t > 0) {
                trial_t--;
            } else if (trial_wave >= trial_waves) {
                trial_state = 0;
                fx_shake(6);
                open_chest();
                float_text(x, y - 200, L("ผ่านบททดสอบ!", "Trial cleared!"), c_yellow, 1.5);
            } else {
                trial_wave++;
                trial_spawn(trial_wave);
                trial_t = 75;   // พักหลังเคลียร์รอบนี้ก่อนรอบถัดไป
            }
        }
    }
}

depth = -y;
