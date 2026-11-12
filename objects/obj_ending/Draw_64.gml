draw_set_color(c_black);
draw_rectangle(0, 0, 960, 540, false);

if (shown_end) {
    var _kill = (global.ending == "kill");
    draw_set_font(fnt_dialog);
    draw_set_halign(fa_center);
    draw_set_color(c_white);
    draw_text_transformed(480, 140, "จบ", 3, 3, 0);
    draw_set_color(c_yellow);
    draw_text(480, 270, _kill ? "ตอนจบที่ 1 : ผู้พิชิตมังกร" : "ตอนจบที่ 2 : เคียงข้างราชา");
    draw_set_color(c_white);
    draw_text(480, 330, "ขอบคุณที่เล่น");
    draw_set_color(c_gray);
    draw_text_transformed(480, 385, _kill ? "ลองเลือกอยู่เคียงข้างราชามังกรดูไหม?" : "ลองเลือกหยุดราชามังกรดูไหม?", 0.8, 0.8, 0);
    draw_text(480, 440, "กด Enter หรือคลิกเพื่อกลับเมนู");
    draw_set_halign(fa_left);
}
draw_set_color(c_white);