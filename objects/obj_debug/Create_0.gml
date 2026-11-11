// Debug ปิดอยู่ตั้งแต่เริ่ม: เปิดได้จากเมนู "Debug Mode" เท่านั้น (เมนูเป็นคนสร้าง obj_debug ตอนเปิด)
if (!global.debug || instance_number(obj_debug) > 1) {
    instance_destroy();
    exit;
}
persistent = true;
show = true;
stats = true;                   // F3 สลับแผงสถิติ
hist = array_create(120, 0);    // ประวัติเวลาต่อเฟรม (ms)
hpos = 0;