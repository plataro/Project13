locked = false;   // คำนวณใหม่ทุกเฟรม (เดิมค้างเป็น true ตลอดหลังโดนล็อกด้วย req_flag)
if (channel >= 0) {
    locked = true;
    with (obj_plate_ss) {
        if (channel == other.channel && pressed) other.locked = false;
    }
}

if (req_flag != "" && !flag_get(req_flag)) locked = true;

image_blend = locked ? c_gray : c_white;

if (!locked && next_room != noone && !instance_exists(obj_fade) && !instance_exists(obj_dialogue) && !instance_exists(obj_cutscene)) {
    // เช็กทั้งมาสก์ชนกัน และระยะใกล้ประตู (กันกรณีมาสก์ของ sprite ไม่ทับกับตัวผู้เล่น)
    var _p = instance_find(obj_player_ss, 0);
    var _hit = place_meeting(x, y, obj_player_ss);
    if (!_hit && _p != noone) _hit = point_in_rectangle(_p.x, _p.y, x - 40, y - 80, x + 104, y + 140);
    if (_hit) {
        global.arrive = "";   // ออกจากฉาก side-scroll = เกิดที่จุดเริ่มห้องถัดไป
        var _f = instance_create_depth(0, 0, -10000, obj_fade);
        _f.target_room = next_room;
    }
}
