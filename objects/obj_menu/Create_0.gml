display_set_gui_size(960, 540);
screen = 0;    // 0=เมนูหลัก 1=วิธีเล่น 2=เครดิต 3=เลือกฉาก (Debug)
sel = 0;
items = [];
last_mx = -1;
last_my = -1;

// ตัวปรับขนาดแคนวาสสำหรับ HTML5 (persistent สร้างครั้งเดียว)
if (!instance_exists(obj_scaler)) instance_create_depth(0, 0, 0, obj_scaler);
// เมนูหยุดเกม + ตั้งค่า (persistent)
if (!instance_exists(obj_pause)) instance_create_depth(0, 0, -14000, obj_pause);
