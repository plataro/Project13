if (keyboard_check_pressed(ord("H"))) show = !show;
if (keyboard_check_pressed(ord("X"))) global.god = !global.god;

if (keyboard_check_pressed(ord("Z")) && instance_exists(obj_player)) {
    obj_player.hp = obj_player.max_hp;
}

if (keyboard_check_pressed(ord("C"))) {
    with (obj_enemy) hp = 0;
}

// ทดสอบระบบเงิน/ยา/แต้มสกิล
if (keyboard_check_pressed(ord("G"))) global.save.gold += 100;
if (keyboard_check_pressed(ord("O"))) global.save.potions = min(global.save.potions + 1, global.save.potion_max);
if (keyboard_check_pressed(ord("K"))) global.save.sp += 1;
if (keyboard_check_pressed(ord("L"))) {   // พลังยิง +1 และปลดต้นไม้สกิล
    global.save.shot_lv = min(4, global.save.shot_lv + 1);
    flag_set("tree_unlocked");
    with (obj_player) player_apply_skills();
}

var _go = noone;
if (keyboard_check_pressed(ord("B"))) {
    var _i = level_index();   // อยู่เมนูจะได้ -1 แล้วไปด่าน 1
    _go = global.levels[min(_i + 1, array_length(global.levels) - 1)];
}
if (keyboard_check_pressed(ord("V"))) {
    var _i2 = level_index();
    _go = global.levels[max(_i2 - 1, 0)];
}
if (keyboard_check_pressed(ord("N"))) {
    _go = rm_menu;
}

if (_go != noone && !instance_exists(obj_fade)) {
    if (instance_exists(obj_player)) global.player_hp = obj_player.hp;
    var _f = instance_create_depth(0, 0, -10000, obj_fade);
    _f.target_room = _go;
}

if (keyboard_check_pressed(vk_f3)) stats = !stats;
hist[hpos] = delta_time / 1000;
hpos = (hpos + 1) mod 120;