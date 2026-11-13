alpha = 0;
sel = 0;            // ★ 0 = ลองใหม่, 1 = กลับเมนู
last_mx = -1;
last_my = -1;
pop = 0;            // แอนิเมชันแผงเด้งเข้า
// ตำแหน่งปุ่ม (ใช้ทั้ง Step และ Draw)
btn_y = function(_i) { return 300 + _i * 46; };
sfx("gameover");
music_stinger("gameover", id);   // ★ เพลงตาย (ปิดหน้านี้ = ตัดเพลง กลับเพลงด่าน)
