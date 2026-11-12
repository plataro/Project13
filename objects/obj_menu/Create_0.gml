display_set_gui_size(960, 540);
screen = 0;    // 0=เมนูหลัก 1=วิธีเล่น 2=เครดิต 3=เลือกฉาก (Debug)
sel = 0;
items = [];
last_mx = -1;
last_my = -1;
acts = [];     // การทำงานของแต่ละแถวในหน้าหลัก (รายการเปลี่ยนตามว่ามีเซฟไหม)

// ★ เซฟในเบราว์เซอร์
has_save = save_exists();
save_text = has_save ? save_summary() : "";
if (has_save && save_text == "") has_save = false;   // เซฟเสีย = ทำเหมือนไม่มี
msg = "";
msg_timer = 0;

// ตำแหน่งแถวเมนู (ใช้ทั้งวาดและเช็กเมาส์)
item_y = function(_i) {
    if (screen == 3) return 175 + _i * 38;   // หน้าเลือกฉาก (Debug) รายการยาว
    return 214 + _i * 40;
}

// ตัวปรับขนาดแคนวาสสำหรับ HTML5 (persistent สร้างครั้งเดียว)
if (!instance_exists(obj_scaler)) instance_create_depth(0, 0, 0, obj_scaler);
// เมนูหยุดเกม + ตั้งค่า (persistent)
if (!instance_exists(obj_pause)) instance_create_depth(0, 0, -14000, obj_pause);
