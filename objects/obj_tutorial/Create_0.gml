// ===== สอนเล่นตามสถานการณ์ (persistent สร้างจาก obj_pause) =====
// 1) บทเรียนกลิ้งหลบ: ศัตรูที่ตั้ง tut_dodge = true ใน Creation Code
//    พอมันกำลังจะฟัน เกมจะหยุดค้าง ให้ผู้เล่นกด Space กลิ้งหลบ
// 2) ป้ายปุ่มที่โผล่เมื่อได้ใช้จริงครั้งแรก (ยา, สกิล 2, สลับอาวุธ, ต้นไม้สกิล, หยุดเกม)

// ---- บทเรียนกลิ้งหลบ ----
freeze = false;      // กำลังหยุดรอให้กด Space
freeze_t = 0;
watch = 0;           // นับเฟรมดูผลหลังกลิ้ง
watch_hp = 0;

// ---- ข้อความสั้น ๆ กลางจอ ----
msg = "";
msg_col = c_white;
msg_t = 0;

show_msg = function(_txt, _col = c_white) {
    msg = _txt;
    msg_col = _col;
    msg_t = 150;
}

seen = function(_key) {
    return variable_struct_exists(global.story_seen, _key);
}

// ---- ป้ายปุ่มตามสถานการณ์ ----
// key = จำว่าเรียนแล้ว, keys = ป้ายที่โชว์, codes = ปุ่มที่ต้องกด (-2 = ล้อเมาส์), text = คำอธิบาย
// when = เงื่อนไขที่ทำให้โผล่, timeout = หายเองหลังกี่เฟรม (0 = รอจนกด)
ctx_list = [
    { key: "ctx_potion", keys: ["Q"], codes: [ord("Q")], text: "ดื่มยาฟื้นเลือด", timeout: 0,
      when: function() { return instance_exists(obj_player) && obj_player.hp <= obj_player.max_hp - 2 && global.save.potions > 0; } },
    { key: "ctx_skill2", keys: ["2"], codes: [ord("2")], text: "ยิงกระจายสามทิศ (ปลดแล้ว)", timeout: 0,
      when: function() { return global.save.shot_lv >= 2 && instance_exists(obj_player); } },
    { key: "ctx_weapon", keys: ["R", "ล้อเมาส์"], codes: [ord("R"), -2], text: "สลับอาวุธ", timeout: 0,
      when: function() { return array_length(variable_struct_get_names(global.save.weapons)) > 0 && instance_exists(obj_player); } },
    { key: "ctx_tree", keys: ["T"], codes: [ord("T")], text: "เปิดต้นไม้สกิล (ใช้แต้ม SP อัปพลัง)", timeout: 0,
      when: function() { return flag_get("tree_unlocked") && instance_exists(obj_player); } },
    { key: "ctx_pause", keys: ["P"], codes: [ord("P")], text: "หยุดเกม / ตั้งค่า", timeout: 300,
      when: function() { return variable_struct_exists(global.story_seen, "tut_dodge") && instance_exists(obj_player); } }
];
ctx = undefined;     // ป้ายที่กำลังโชว์
ctx_t = 0;
ctx_a = 0;
ctx_done = 0;        // นับเฟรมโชว์เครื่องหมายถูกก่อนหาย
