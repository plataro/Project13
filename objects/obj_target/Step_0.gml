t++;
// ★ เป้าเลื่อนไปมา
if (move_r > 0 && !hit) {
    var _o = sin(t * 0.02 * move_spd) * move_r;
    if (move_axis == 0) x = xstart + _o; else y = ystart + _o;
    depth = -y;
}
// ★ จับเวลา: หมดเวลาแล้วกลับมาล็อก (ถ้าประตูยังไม่เปิด)
if (hit && relock > 0 && !locked_open) {
    lock_t--;
    if (lock_t <= 0) {
        hit = false;
        fx_spark(x, y - 48, 90, 6, c_gray, 180);
    }
}
