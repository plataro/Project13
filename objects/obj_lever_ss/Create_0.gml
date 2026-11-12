// ★ คันโยก (side-scroll): ฟันด้วยดาบ = เปิด (ค้าง) แล้วประตู obj_gate_ss ช่องเดียวกันเปิด
// (x, y) = ฐานคันโยก ตรงระดับพื้น   ตั้งใน Creation Code: channel = 0;
channel = 0;
on = false;
last_swing = -1;
anim = 0;
depth = -30;

hit = function() {
    if (on) return;
    on = true;
    fx_spark(x, y - 30, 90, 12, c_yellow, 160);
    fx_shake(2);
    float_text(x, y - 90, "แกร๊ก!", c_yellow, 1);
}
