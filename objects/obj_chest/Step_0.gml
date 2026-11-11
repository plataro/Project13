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
}

depth = -y;
