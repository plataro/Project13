// ธงเนื้อเรื่อง เก็บใน global.save.flags (ถูกเซฟ/snapshot ไปกับ save อยู่แล้ว)
function flag_get(_name) {
    return variable_struct_exists(global.save.flags, _name) && global.save.flags[$ _name];
}
function flag_set(_name, _v = true) {
    global.save.flags[$ _name] = _v;
}

// ให้ SP ครั้งเดียวต่อ key (กันได้ซ้ำเวลาโหลดใหม่/ตายแล้วกลับมาฆ่าอีก)
function award_sp_once(_key, _n, _x, _y) {
    if (flag_get("sp_" + _key)) return;
    flag_set("sp_" + _key);
    global.save.sp += _n;
    if (!instance_exists(obj_boss_death)) sfx("sp_gain");   // มินิบอสมีเสียงชนะในฉากตายอยู่แล้ว
    float_text(_x, _y - 80, "+" + string(_n) + " SP", c_yellow, 1.5);
    loot_toast("SP", c_aqua, "star", _n);
}