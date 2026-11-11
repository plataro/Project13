t++;
if (t < 30) alpha = 0;                       // รอให้ fade เข้าห้องเสร็จ
else if (t < 70) alpha = (t - 30) / 40;      // ค่อย ๆ ชัด
else if (t < 170) alpha = 1;                 // คงไว้ ~1.7 วินาที
else if (t < 220) alpha = 1 - (t - 170) / 50; // จางหาย
else instance_destroy();