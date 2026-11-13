// ★ เป้าพัซเซิล: โดนแล้วติดค้าง เปิด obj_gate_td / obj_gate_ss ช่องเดียวกัน
// ตั้งใน Creation Code:
//   channel = 0;          ช่องประตูที่จะเปิด
//   mode = "shot";        "shot" = ต้องยิง (ฟันไม่ได้) / "sword" = คริสตัล ต้องฟัน (ยิงไม่เข้า)
//   relock = 0;           > 0 = กี่เฟรมแล้วกลับมาล็อก (ต้องโดนทุกอันในช่องให้ทันเวลา)
//   move_r = 0;           > 0 = เป้าเลื่อนไปมา ระยะ move_r พิกเซล
//   move_axis = 0;        0 = แนวนอน, 1 = แนวตั้ง
//   move_spd = 1;         ความเร็วการเลื่อน
channel = 0;
mode = "shot";
relock = 0;
move_r = 0;
move_axis = 0;
move_spd = 1;
hit = false;
hit_t = 0;
lock_t = 0;
tink_id = noone;   // กันขึ้นข้อความซ้ำจากการฟัน/ยิงครั้งเดียว
depth = -y;
t = random(1000);
locked_open = false;   // ประตูเปิดแล้ว = ค้างถาวร

on_hit = function() {
    if (hit) return;
    hit = true;
    sfx_at("target_hit", x, y);
    hit_t = 20;
    lock_t = relock;
    fx_spark(x, y - 48, 90, 14, (mode == "sword") ? make_color_rgb(150, 220, 255) : c_yellow, 180);
    fx_shake(2);
}
