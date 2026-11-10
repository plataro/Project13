// สร้างเลขดาเมจลอย (พิกัดโลก)
function spawn_damage_text(_x, _y, _value) {
    var _t = instance_create_depth(_x, _y, -20000, obj_damage_text);
    _t.txt = string(_value);
    var _heavy = (_value >= 2);
    _t.col = _heavy ? c_yellow : c_white;
    _t.size = _heavy ? 1.4 : 1;
    return _t;
}

// ข้อมูลท่าโจมตีของศัตรู ปรับเวลาเตรียมโจมตีตามระดับความยาก
function enemy_attack_data(_name) {
    var _a = enemy_attack_base(_name);
    if (is_undefined(_a)) return undefined;
    _a.windup = max(8, round(_a.windup * difficulty_data().windup));
    return _a;
}