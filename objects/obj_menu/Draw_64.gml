draw_set_color(c_black);
draw_rectangle(0, 0, 960, 540, false);

draw_set_font(fnt_dialog);
draw_set_halign(fa_center);

if (screen == 1) {
    draw_set_color(c_yellow);
    draw_text(480, 50, "วิธีเล่น");
    draw_set_color(c_white);
    draw_text(480, 120, "WASD / ลูกศร   เดิน");
    draw_text(480, 165, "เมาส์   เล็งและหันตัว");
    draw_text(480, 210, "คลิกซ้าย   โจมตีระยะใกล้ (คลิกต่อเนื่องเพื่อต่อคอมโบ)");
    draw_text(480, 255, "1   ยิงกระสุน     2   ยิงสามทิศ");
    draw_text(480, 300, "Space   กลิ้งหลบ (ตอนกลิ้งไม่โดนโจมตี)");
    draw_text(480, 345, "ปราบศัตรูให้หมดเพื่อเปิดประตูไปด่านต่อไป");
    draw_text(480, 390, "Enter / E   อ่านบทสนทนาต่อ");
    draw_text(480, 435, "Shift   วิ่ง (กดค้าง)");
    draw_set_color(c_gray);
    draw_text(480, 490, "กด Enter เพื่อกลับ");
}
else if (screen == 2) {
    draw_set_color(c_yellow);
    draw_text(480, 50, "เครดิต");
    draw_set_color(c_white);
    draw_text(480, 140, "โค้ดและระบบเกม: [ใส่ชื่อ]");
    draw_text(480, 190, "ภาพและเนื้อเรื่อง: [ใส่ชื่อ]");
    draw_text(480, 240, "เสียงและเพลง: [ใส่ชื่อและแหล่งที่มา]");
    draw_text(480, 290, "ฟอนต์ Mitr (Cadson Demak, SIL Open Font License)");
    draw_set_color(c_gray);
    draw_text(480, 480, "กด Enter เพื่อกลับ");
}
else {
    draw_set_color(c_white);
    if (screen == 0) draw_text_transformed(480, 120, "THE UNKNOWN", 2.5, 2.5, 0);
    else if (screen == 3) draw_text_transformed(480, 120, "เลือกฉาก (Debug)", 1.5, 1.5, 0);
    else draw_text_transformed(480, 120, "เลือกระดับความยาก", 1.5, 1.5, 0);

    for (var _i = 0; _i < array_length(items); _i++) {
        var _y = 250 + _i * 50;
        if (_i == sel) {
            draw_set_color(c_yellow);
            draw_text(480, _y, "> " + items[_i] + " <");
        } else {
            draw_set_color(c_white);
            draw_text(480, _y, items[_i]);
        }
    }

    // คำอธิบายของระดับที่เลือกอยู่
    if (screen == 4 && sel < 3) {
        draw_set_color(c_gray);
        draw_text(480, 470, difficulty_data(sel).desc);
    }
}

draw_set_halign(fa_left);
draw_set_color(c_white);