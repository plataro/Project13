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
// ★ slot = ชี้ไปที่ช่องสกิลล่างจอ (0 วิ่ง, 1 คลิก, 2 ค้าง, 3 ยิง, 4 สกิล 2, 5 กลิ้ง, 6 ยา, 7 แผงบัฟ) / -1 = ป้ายบนกลางจอ
//   sub = บรรทัดอธิบายเพิ่ม
//   goal = เงื่อนไขว่า "ผ่านจริง" (ไม่มี = กดปุ่มก็ผ่าน) ยังไม่ผ่าน = ค้างป้ายไว้ / retry = ข้อความย้ำตอนกดแล้วแต่ยังไม่ผ่าน
// ★ สร้างรายการใหม่ทุกครั้งที่เปลี่ยนภาษา (ข้อความใช้ L())
build_ctx = function() {
    ctx_list = [
        { key: "ctx_move", slot: 0, acts: ["run"], text: L("วิ่ง", "Run"), sub: L("เดินด้วย W A S D แล้วกด Shift ค้างไว้", "Move with W A S D and hold Shift"), timeout: 0,
          run_only: true,   // นับระยะเฉพาะตอนกด Shift
          goal: function() { return ctx_dist >= 220; },
          when: function() { return instance_exists(obj_player); } },
        { key: "ctx_atk", slot: 1, acts: ["attack"], text: L("โจมตี", "Attack"), sub: L("คลิกต่อเนื่อง = คอมโบ 4 ท่า", "Keep clicking = 4-hit combo"), timeout: 0,
          when: function() { return instance_exists(obj_player) && variable_struct_exists(global.story_seen, "tut_dodge"); } },   // ★ สอนตีหลังสอนหลบ (ตีศัตรูตัวที่เพิ่งหลบได้เลย)
        { key: "ctx_shot", slot: 3, acts: ["shoot1"], text: L("ยิงลูกไฟไปทางเมาส์", "Shoot a fireball at the mouse"), sub: L("ยิงเป้าให้โดนทุกอันเพื่อเปิดประตู", "Hit every target to open the gate"), timeout: 0,
          retry: L("ยังไม่โดนครบ! เล็งเมาส์ที่เป้าแล้วกด 1 อีกที", "Not all hit! Aim at a target and press 1 again"),
          goal: function() {
              if (!instance_exists(obj_target)) return true;
              var _all = true;
              with (obj_target) if (channel == 0 && !hit) _all = false;   // ★ เฉพาะเป้าบทสอน (ช่อง 0) ไม่นับปริศนาห้องรางวัล
              return _all;
          },
          when: function() { return instance_exists(obj_player) && variable_struct_exists(global.story_seen, "ctx_atk"); } },
        { key: "ctx_potion", slot: 6, acts: ["potion"], text: L("ดื่มยาฟื้นเลือด", "Drink a potion"), sub: L("ฟื้น 2 หัวใจ ซื้อเพิ่มได้ที่ร้าน", "Heals 2 hearts. Buy more at shops"), timeout: 0,
          when: function() { return instance_exists(obj_player) && obj_player.hp <= obj_player.max_hp - 2 && global.save.potions > 0; } },
        { key: "ctx_skill2", slot: 4, acts: ["shoot2"], text: L("ยิงกระจายสามทิศ", "Triple spread shot"), sub: L("ปลดสกิลแล้ว! คูลดาวน์นานกว่าปุ่ม 1", "Unlocked! Longer cooldown than 1"), timeout: 0,
          when: function() { return global.save.shot_lv >= 2 && instance_exists(obj_player); } },
        { key: "ctx_weapon", slot: 1, acts: ["weapon"], text: L("ได้อาวุธใหม่! สลับอาวุธ", "New weapon! Switch weapon"), sub: L("ช่องโจมตีจะเปลี่ยนตามอาวุธที่ถือ", "Your attack slot changes with the weapon"), timeout: 0,
          when: function() { return array_length(variable_struct_get_names(global.save.weapons)) > 0 && instance_exists(obj_player); } },
        { key: "ctx_charge", slot: 2, acts: ["charge"], text: L("ชาร์จค้อน", "Charge hammer"), sub: L("ค้างจนเกจเต็มแล้วปล่อย ทุ่มลงพื้นรอบตัว", "Hold until full, release to slam around you"), timeout: 0,
          when: function() { return global.save.weapon == "hammer" && instance_exists(obj_player); } },
        { key: "ctx_tree", acts: ["tree"], text: L("เปิดต้นไม้สกิล (ใช้แต้ม SP อัปพลัง)", "Open the skill tree (spend SP to power up)"), timeout: 0,
          when: function() { return flag_get("tree_unlocked") && instance_exists(obj_player); } },
        { key: "ctx_status", acts: ["status"], text: L("ดูสถานะ / สวมเครื่องประดับ", "Status / equip accessories"), timeout: 0,
          when: function() { return room == rm_the_village && instance_exists(obj_player); } },
        { key: "ctx_buff", slot: 7, acts: ["buff_use"], text: L("ใช้ไอเท็มบัฟ", "Use buff item"), sub: L("กด V เพื่อเปลี่ยนชนิดบัฟ", "Press V to switch buff type"), timeout: 0,
          when: function() {
              var _bl = buff_list();
              for (var _i = 0; _i < array_length(_bl); _i++) if (variable_struct_exists(global.save.buff_items, _bl[_i]) && global.save.buff_items[$ _bl[_i]] > 0) return instance_exists(obj_player);
              return false;
          } },
        { key: "ctx_pause", acts: ["pause"], text: L("หยุดเกม / ตั้งค่า", "Pause / settings"), timeout: 300,
          when: function() { return variable_struct_exists(global.story_seen, "tut_dodge") && instance_exists(obj_player); } }
    ];
}
build_ctx();
ctx_lang = global.lang;
ctx = undefined;     // ป้ายที่กำลังโชว์
ctx_t = 0;
ctx_a = 0;
ctx_done = 0;        // นับเฟรมโชว์เครื่องหมายถูกก่อนหาย

seen_count = -1;   // ★ จำนวนบทสอน/เนื้อเรื่องที่ผ่านแล้ว (เปลี่ยน = เซฟ)
ctx_dist = 0;    // ★ ระยะที่เดินไปแล้วระหว่างบทสอนเดิน
ctx_tries = 0;   // ★ กดแล้วแต่ยังไม่ผ่านกี่ครั้ง (โชว์ข้อความย้ำ)
ctx_shake = 0;
ctx_px = 0;
ctx_py = 0;
