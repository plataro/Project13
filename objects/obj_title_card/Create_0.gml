text = room_title_text();
if (global.arrive == "shop") text = "";   // ★ ออกจากร้านไม่ต้องขึ้นชื่อหมู่บ้านซ้ำ
t = 0;
alpha = 0;
if (text == "") instance_destroy();
if (text != "") sfx("title_card");
