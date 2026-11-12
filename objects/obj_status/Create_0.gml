// ★ หน้าสถานะตัวละคร (ปุ่ม I): ค่าสถานะ อุปกรณ์ เครื่องประดับ (คลิกสวม/ถอด) บัฟ และสถานะผิดปกติ
depth = -12500;
open_delay = 5;
hover_acc = "";
// ★ เล็กลง (เดิม 840x480)
px = 110;
py = 44;
pw = 740;
ph = 452;
open_t = 0;
pad_i = 0;      // ★ เครื่องประดับที่เลือกด้วยจอย
pad_on = (global.input_dev == "pad");
pad_mx = device_mouse_x_to_gui(0);
pad_my = device_mouse_y_to_gui(0);

// รายการเครื่องประดับที่มี (ใช้ทั้ง Draw และ Step)
acc_x1 = px + 470;
acc_x2 = px + pw - 20;
acc_y0 = py + 184;
acc_rh = 26;
acc_cw = (acc_x2 - acc_x1 - 6) / 2;   // ★ 2 คอลัมน์
acc_rect = function(_row) {
    var _c = _row mod 2;
    var _r = _row div 2;
    var _x = acc_x1 + _c * (acc_cw + 6);
    var _y = acc_y0 + _r * acc_rh;
    return [_x, _y, _x + acc_cw, _y + acc_rh - 4];
}

close_x1 = px + pw - 120;
close_x2 = px + pw - 20;
close_y1 = py + ph - 40;
close_y2 = py + ph - 12;
