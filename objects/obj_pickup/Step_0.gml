timer++;

// เด้งออกด้านข้าง ชนกำแพงแล้วหยุด
if (abs(hsp) > 0.05 || abs(vsp) > 0.05) {
    if (collision_point(x + hsp, y, obj_wall, false, true) == noone) x += hsp; else hsp = 0;
    if (collision_point(x, y + vsp, obj_wall, false, true) == noone) y += vsp; else vsp = 0;
    hsp *= 0.92;
    vsp *= 0.92;
}

// กระดอนขึ้นลง
zv -= 0.35;
z += zv;
if (z <= 0) {
    z = 0;
    zv = (abs(zv) > 1) ? -zv * 0.5 : 0;
}

// ดูดเข้าหาผู้เล่น (ยาเต็มมือแล้วไม่ดูด)
if (timer > 20 && instance_exists(obj_player) && obj_player.hp > 0) {
    var _can = !(kind == "potion" && global.save.potions >= global.save.potion_max);
    if (_can) {
        var _d = point_distance(x, y, obj_player.x, obj_player.y);
        var _r = (kind == "gold") ? 90 : 50;

        if (_d < _r) {
            var _a = point_direction(x, y, obj_player.x, obj_player.y);
            var _sp = 3 + (1 - _d / _r) * 5;
            x += lengthdir_x(_sp, _a);
            y += lengthdir_y(_sp, _a);
        }

        if (_d < 24) {
            if (pickup_collect(kind, value, x, y)) instance_destroy();
        }
    }
}

depth = -y;