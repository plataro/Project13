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
// ★ slot = ชี้ไปที่ช่องสกิลล่างจอ (0 คลิก, 1 ค้าง, 2 ยิง, 3 สกิล 2, 4 กลิ้ง, 5 ยา, 6 แผงบัฟ) / -1 = ป้ายบนกลางจอ
//   sub = บรรทัดอธิบายเพิ่ม (โชว์ใต้ชื่อท่า)
ctx_list = [
    { key: "ctx_atk", slot: 0, keys: ["คลิกซ้าย"], codes: [-1], text: "โจมตี", sub: "คลิกต่อเนื่อง = คอมโบ 4 ท่า", timeout: 0,
      when: function() { return instance_exists(obj_player) && (room != rm_level_1_the_forest || variable_struct_exists(global.story_seen, "hint_move")); } },
    { key: "ctx_roll", slot: 4, keys: ["Space"], codes: [vk_space], text: "กลิ้งหลบ", sub: "ระหว่างกลิ้งจะไม่โดนโจมตี", timeout: 0,
      when: function() { return instance_exists(obj_player) && variable_struct_exists(global.story_seen, "ctx_atk"); } },
    { key: "ctx_shot", slot: 2, keys: ["1"], codes: [ord("1")], text: "ยิงลูกไฟไปทางเมาส์", sub: "กระสุนมีจำกัด หมดแล้วรอรีโหลดเอง", timeout: 0,
      when: function() { return instance_exists(obj_player) && variable_struct_exists(global.story_seen, "tut_dodge"); } },
    { key: "ctx_potion", slot: 5, keys: ["Q"], codes: [ord("Q")], text: "ดื่มยาฟื้นเลือด", sub: "ฟื้น 2 หัวใจ ซื้อเพิ่มได้ที่ร้าน", timeout: 0,
      when: function() { return instance_exists(obj_player) && obj_player.hp <= obj_player.max_hp - 2 && global.save.potions > 0; } },
    { key: "ctx_skill2", slot: 3, keys: ["2"], codes: [ord("2")], text: "ยิงกระจายสามทิศ", sub: "ปลดสกิลแล้ว! คูลดาวน์นานกว่าปุ่ม 1", timeout: 0,
      when: function() { return global.save.shot_lv >= 2 && instance_exists(obj_player); } },
    { key: "ctx_weapon", keys: ["R", "ล้อเมาส์"], codes: [ord("R"), -2], text: "สลับอาวุธ", timeout: 0,
      when: function() { return array_length(variable_struct_get_names(global.save.weapons)) > 0 && instance_exists(obj_player); } },
    { key: "ctx_charge", slot: 1, keys: ["คลิกซ้ายค้าง"], codes: [-3], text: "ชาร์จค้อน", sub: "ค้างจนเกจเต็มแล้วปล่อย ทุ่มลงพื้นรอบตัว", timeout: 0,
      when: function() { return global.save.weapon == "hammer" && instance_exists(obj_player); } },
    { key: "ctx_tree", keys: ["T"], codes: [ord("T")], text: "เปิดต้นไม้สกิล (ใช้แต้ม SP อัปพลัง)", timeout: 0,
      when: function() { return flag_get("tree_unlocked") && instance_exists(obj_player); } },
    { key: "ctx_status", keys: ["I"], codes: [ord("I")], text: "ดูสถานะ / สวมเครื่องประดับ", timeout: 0,
      when: function() { return room == rm_the_village && instance_exists(obj_player); } },
    { key: "ctx_buff", slot: 6, keys: ["F"], codes: [ord("F")], text: "ใช้ไอเท็มบัฟ", sub: "กด V เพื่อเปลี่ยนชนิดบัฟ", timeout: 0,
      when: function() {
          var _bl = buff_list();
          for (var _i = 0; _i < array_length(_bl); _i++) if (variable_struct_exists(global.save.buff_items, _bl[_i]) && global.save.buff_items[$ _bl[_i]] > 0) return instance_exists(obj_player);
          return false;
      } },
    { key: "ctx_pause", keys: ["P"], codes: [ord("P")], text: "หยุดเกม / ตั้งค่า", timeout: 300,
      when: function() { return variable_struct_exists(global.story_seen, "tut_dodge") && instance_exists(obj_player); } }
];
ctx = undefined;     // ป้ายที่กำลังโชว์
ctx_t = 0;
ctx_a = 0;
ctx_done = 0;        // นับเฟรมโชว์เครื่องหมายถูกก่อนหาย

seen_count = -1;   // ★ จำนวนบทสอน/เนื้อเรื่องที่ผ่านแล้ว (เปลี่ยน = เซฟ)
