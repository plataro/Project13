sprite_index = spr_exit;
next_room = level_next_room();
locked = false;
channel = -1;     // -1 = ไม่ผูกกับแผ่นกด ตั้ง 0,1,2... ใน Creation Code เพื่อล็อกจนกว่าแผ่นนั้นถูกกด