event_inherited();
// ★ ประตูกั้นทาง (top-down) เปิดเมื่อยิงเป้า obj_target ช่องเดียวกันครบทุกอัน
// ตั้งใน Creation Code: channel = 0;
channel = 0;
opening = false;
checked = false;   // ★ เช็กว่าเคยเปิดแล้วหรือยัง (เฟรมแรก หลัง Creation Code ตั้ง channel)
open_t = 0;
