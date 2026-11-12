if (!inited) {
    inited = true;
    opened = (key != "" && flag_get("chest_" + key));
}

var _p = noone;
if (instance_exists(obj_player)) _p = obj_player.id;
else if (instance_exists(obj_player_ss)) _p = obj_player_ss.id;

near = (_p != noone) && !opened && point_distance(x, y, _p.x, _p.y) < 90;

if (near && keyboard_check_pressed(ord("E"))
    && !instance_exists(obj_dialogue) && !instance_exists(obj_fade)
    && !instance_exists(obj_shop) && !instance_exists(obj_skilltree)) {
    opened = true;
    if (key != "") flag_set("chest_" + key);

    if (gold > 0) {
        global.save.gold += gold;
        float_text(x, y - 70, "+" + string(gold) + " G", c_yellow, 1);
    }
    if (sp > 0) {
        global.save.sp += sp;
        float_text(x, y - 100, "+" + string(sp) + " SP", c_aqua, 1.3);
    }
    repeat (potion) pickup_collect("potion", 1, x, y - 20);

    // ★ หีบพลัง: ยิงได้มากขึ้น รอสั้นลง
    if (shot_up > 0) {
        var _lv0 = global.save.shot_lv;
        global.save.shot_lv = min(4, global.save.shot_lv + shot_up);
        var _sd = shot_data(global.save.shot_lv);
        with (obj_player) {
            player_apply_skills();
            shot1_ammo = shot1_max;
            shot1_reload_timer = 0;
        }
        float_text(x, y - 130, "พลังยิงเพิ่มขึ้น!  " + string(_sd.ammo) + " นัด", make_color_rgb(200, 120, 255), 1.4);
        if (_lv0 < 2 && global.save.shot_lv >= 2) float_text(x, y - 165, "ปลดสกิล 2: ยิงสามทิศ", c_yellow, 1.2);
        fx_spark(x, y - 30, 90, 22, make_color_rgb(200, 120, 255), 120);
    }
}

depth = -y;
