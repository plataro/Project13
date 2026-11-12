sprite_index = spr_exit;
next_room = level_next_room();
locked = false;
channel = -1;     // -1 = ไม่ผูกกับแผ่นกด ตั้ง 0,1,2... ใน Creation Code เพื่อล็อกจนกว่าแผ่นนั้นถูกกด
req_flag = "";
arrive_to = "";   // ★ จุดเกิดในห้องถัดไป ("shop" = หน้าร้านที่เพิ่งออกมา)    // ถ้าใส่ชื่อ flag ประตูจะล็อกจนกว่า flag นั้นเป็นจริง (เช่น "sword")