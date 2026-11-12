lines = [];
index = 0;
chars = 0;
total = 0;
wrapped = "";
type_speed = 0.8;
on_done = undefined;   // ฟังก์ชันที่เรียกหลังบทสนทนาจบ
sel = -1;             // ตัวเลือกที่เมาส์ชี้อยู่ (-1 = ไม่ได้ชี้) เฉพาะบรรทัดที่มี choices
choice_t = 0;         // นับเฟรมตั้งแต่ตัวเลือกขึ้น
choice_delay = 45;    // ★ ตัวเลือกกดได้หลังขึ้นมาแล้วกี่เฟรม (กันกดรัวแล้วเลือกพลาด)
closing = false;      // true ตอนกำลังจะจบ (ให้ฟังก์ชันหลังจบเปิดบทสนทนาต่อได้)

portrait_h = 400;   // ★ ความสูงของรูปตัวละครบนจอ (ปรับได้)

pdata = portrait_data();

// ช่องตัวละคร 2 ฝั่ง
slots = {
    left:  { who: "", emo: "normal", ax: -140, alpha: 0 },
    right: { who: "", emo: "normal", ax: 140,  alpha: 0 }
};
speaker = "";   // "left", "right" หรือ "" (ผู้บรรยาย)

// จบบทสนทนา: ล้างปุ่ม/คลิกเฟรมนี้ ไม่ให้ไปโดนฟันหรือกลิ้งต่อ
finish = function() {
    closing = true;
    if (is_callable(on_done)) on_done();
    instance_destroy();
    io_clear();
}

load_line = function() {
    var _l = lines[index];
    wrapped = text_wrap_thai(_l.text, 840);
    chars = 0;
    total = string_length(wrapped);
    choice_t = 0;
    sel = -1;

    // ให้ตัวละครออกจากฉาก
    if (variable_struct_exists(_l, "hide")) {
        if (_l.hide == "left" || _l.hide == "both") slots.left.who = "";
        if (_l.hide == "right" || _l.hide == "both") slots.right.who = "";
    }

    speaker = "";
    if (variable_struct_exists(_l, "who") && variable_struct_exists(_l, "side")) {
        var _slot = (_l.side == "right") ? slots.right : slots.left;
        if (_slot.who != _l.who) {   // ตัวใหม่ เลื่อนเข้ามาจากข้างจอ
            _slot.ax = (_l.side == "right") ? 140 : -140;
            _slot.alpha = 0;
        }
        _slot.who = _l.who;
        _slot.emo = variable_struct_exists(_l, "emo") ? _l.emo : "normal";
        speaker = _l.side;
    }
}