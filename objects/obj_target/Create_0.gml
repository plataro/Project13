// ★ เป้ายิง: โดนกระสุนแล้วติดค้าง (ฟันไม่ได้ ต้องยิง) เปิด obj_gate_td ช่องเดียวกัน
// ตั้งใน Creation Code: channel = 0;
channel = 0;
hit = false;
hit_t = 0;
tink_id = noone;   // กันขึ้นข้อความ "ต้องยิง" ซ้ำจากการฟันครั้งเดียว
depth = -y;

on_hit = function() {
    if (hit) return;
    hit = true;
    hit_t = 20;
    fx_spark(x, y - 48, 90, 14, c_yellow, 180);
    fx_shake(2);
}
