sprite_index = spr_ground_ss;
mask_index = spr_ground_ss;
image_blend = c_orange;
depth = 10;               // ซ่อนหลังกระเบื้องตอนเลื่อนเข้าเพดาน
channel = 0;
open = false;
close_y = y;
open_y = y - sprite_height;
open_down = false;        // ★ true = เปิดโดยจมลงพื้น (ตั้งใน Creation Code) แทนการยกขึ้นเพดาน
inited = false;
move_spd = 6;
snd_open = -1;   // ★ จำสถานะเปิด/ปิดไว้เล่นเสียงตอนเปลี่ยน
