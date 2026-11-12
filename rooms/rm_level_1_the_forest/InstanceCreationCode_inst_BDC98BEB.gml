tut_dodge = true;        // ★ บทเรียนกลิ้งหลบ (obj_tutorial หยุดเกมตอนมันกำลังจะฟัน)
engage_grace_time = 30;
hp = 5;
max_hp = 5;
hp_shown = 5;
no_drop = true;
zone = [700, 140, 1300, 880];   // ★ ย้ายมาใกล้วิหาร: ไล่เฉพาะตอนผู้เล่นเดินเข้ามาช่วงนี้

// ★ ผ่านบทสอนหลบแล้ว (โหลดเซฟ/กลับมาป่าอีก) = ไม่ต้องเกิดใหม่
if (variable_struct_exists(global.story_seen, "tut_dodge")) instance_destroy();
