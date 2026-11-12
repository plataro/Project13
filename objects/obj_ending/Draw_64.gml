// ★ หน้าจบเกม (placeholder): ชื่อตอนจบ + เครดิตเลื่อนขึ้น
draw_set_color(c_black);
draw_rectangle(0, 0, 960, 540, false);
if (!shown_end) exit;

var _kill = (global.ending == "kill");
var _t = end_t;
var _accent = _kill ? make_color_rgb(255, 210, 140) : make_color_rgb(170, 210, 255);

// พื้นหลัง: แสงจาง ๆ จากล่าง + ละอองลอยขึ้น
draw_set_alpha(min(1, _t / 90) * 0.35);
draw_rectangle_color(0, 300, 960, 540, c_black, c_black, _kill ? make_color_rgb(70, 40, 10) : make_color_rgb(20, 40, 70), _kill ? make_color_rgb(70, 40, 10) : make_color_rgb(20, 40, 70), false);
gpu_set_blendmode(bm_add);
for (var _d = 0; _d < 40; _d++) {
    var _dx = (_d * 131 + sin(_t / 80 + _d) * 24) mod 960;
    var _dy = 560 - ((_t * (0.3 + (_d mod 5) * 0.1) + _d * 53) mod 600);
    draw_set_alpha(min(1, _t / 60) * (0.2 + 0.25 * (0.5 + 0.5 * sin(_t / 25 + _d))));
    draw_set_color(_accent);
    draw_circle(_dx, _dy, 1 + (_d mod 3) * 0.6, false);
}
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);

draw_set_font(fnt_dialog);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// เครดิตเลื่อนขึ้นหลังหัวข้อขึ้นครบ (เริ่มเฟรม 240)
var _scroll = max(0, _t - 240) * 0.6;
var _top = 150 - _scroll;   // ตำแหน่งหัวข้อ (เลื่อนขึ้นไปพร้อมเครดิต)

// หัวข้อ "จบ"
var _a1 = clamp(_t / 50, 0, 1);
draw_set_alpha(_a1);
var _s1 = 2.4 + 0.4 * (1 - _a1);
ui_text_bold(480, _top, "จบ", _s1, _accent);
// เส้นประดับ
var _a2 = clamp((_t - 40) / 40, 0, 1);
draw_set_alpha(_a2);
var _lw = 200 * (1 - power(1 - _a2, 3));
draw_set_color(UI_GOLD);
draw_line_width(480 - _lw, _top + 58, 480 + _lw, _top + 58, 2);
draw_triangle(472, _top + 58, 488, _top + 58, 480, _top + 50, false);
draw_triangle(472, _top + 58, 488, _top + 58, 480, _top + 66, false);
// ชื่อตอนจบ
var _a3 = clamp((_t - 70) / 40, 0, 1);
draw_set_alpha(_a3);
ui_text_bold(480, _top + 100, _kill ? "ตอนจบที่ 1 : ผู้พิชิตมังกร" : "ตอนจบที่ 2 : เคียงข้างราชา", 0.8, make_color_rgb(255, 230, 170));
var _a4 = clamp((_t - 120) / 40, 0, 1);
draw_set_alpha(_a4);
ui_text(480, _top + 150, "ขอบคุณที่เล่น", 0.65, UI_TEXT);
ui_text(480, _top + 186, _kill ? "ลองเลือกอยู่เคียงข้างราชามังกรดูไหม?" : "ลองเลือกหยุดราชามังกรดูไหม?", 0.5, UI_MUTED);

// เครดิต
var _cl = credits_lines();
var _cy0 = _top + 320;
draw_set_alpha(clamp((_t - 200) / 40, 0, 1));
ui_text_bold(480, _cy0, "เครดิต", 0.75, UI_GOLD);
for (var _i = 0; _i < array_length(_cl); _i++) {
    var _ly = _cy0 + 60 + _i * 70;
    ui_text(480, _ly, _cl[_i][0], 0.48, UI_MUTED);
    ui_text_bold(480, _ly + 26, _cl[_i][1], 0.6, UI_TEXT);
}
// ปิดท้ายเครดิต: ชื่อเกม หยุดกลางจอ
var _ey = max(270, _cy0 + 60 + array_length(_cl) * 70 + 120);
ui_text_bold(480, _ey, "THE UNKNOWN", 1.2, UI_GOLD);
draw_set_alpha(1);

// ปุ่มกลับเมนู (กะพริบช้า)
if (_t > 60) {
    draw_set_alpha(0.4 + 0.4 * (0.5 + 0.5 * sin(current_time / 400)));
    ui_text(480, 516, "Enter / คลิก = กลับเมนู", 0.45, UI_MUTED);
    draw_set_alpha(1);
}
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
