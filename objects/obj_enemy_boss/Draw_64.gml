// หลอดเลือดบอส: ขึ้นหลังคัทซีนเปิดตัวเท่านั้น และเฉพาะตอนผู้เล่นอยู่ในห้องบอส
// ★ แก้บัค: เดิมหลอดขึ้นตั้งแต่บอสเห็นผู้เล่น (ก่อนคัทซีน) และไม่หายตอนวิ่งหนีออกไปไกล
var _in_arena = instance_exists(obj_player)
    && point_in_rectangle(obj_player.x, obj_player.y, arena[0] - 96, arena[1] - 96, arena[2] + 96, arena[3] + 96);
if (!intro_done || !_in_arena) {
    bar_in = 0;          // กลับเข้าห้องใหม่ = หลอดเล่นแอนิเมชันเปิดอีกรอบ
    bar_sparks = [];
    exit;
}
if (instance_exists(obj_dialogue) || instance_exists(obj_cutscene)) exit;   // ★ ไม่ทับกล่องไดอาล็อก
if (!is_undefined(global.boss_intro)) exit;   // ★ ระหว่างเปิดตัว ยังไม่โชว์หลอด

// ★ หลอดอยู่ล่างจอ เหนือช่องสกิล / ชื่อบอสอยู่บนหลอด
var _w = 440;
var _x = 480 - _w / 2;
var _y = 430;
var _h = 14;
if (!variable_instance_exists(id, "hud_hp")) { hud_hp = hp; hud_trail = hp; }
hud_hp = lerp(hud_hp, max(hp, 0), 0.18);
if (hud_trail > hud_hp) hud_trail = max(hud_hp, hud_trail - max_hp * 0.006); else hud_trail = hud_hp;
var _k = max(hud_hp, 0) / max_hp;
var _kt = hud_trail / max_hp;

// ★ แอนิเมชันเปิดหลอด (หลังคัทซีนเปิดตัว): กรอบจางเข้า -> หลอดขยายจากกลางจนเต็ม -> ชื่อขึ้น
if (!variable_instance_exists(id, "bar_in")) { bar_in = 0; bar_sparks = []; }
var _was = bar_in;
bar_in = min(1, bar_in + 1 / 70);
var _fa = clamp(bar_in / 0.25, 0, 1);                       // กรอบ
var _gk = clamp((bar_in - 0.15) / 0.6, 0, 1);
_gk = 1 - power(1 - _gk, 3);                                 // ความยาวหลอด (ease out)
var _na = clamp((bar_in - 0.55) / 0.3, 0, 1);               // ชื่อ
if (_was < 0.75 && bar_in >= 0.75) {                         // เต็มแล้ว: ประกายพุ่งจากสองปลาย
    repeat (16) array_push(bar_sparks, { x: choose(_x, _x + _w), y: _y + _h / 2, vx: random_range(-3, 3), vy: random_range(-3, 1), l: irandom_range(20, 40) });
}
var _half = _w / 2 * _gk;
var _bx1 = 480 - _half;
var _bx2 = 480 + _half;
var _crim = make_color_rgb(120, 16, 36);

// กรอบ: แถบมืดไล่สี + ขอบทอง + ลายปีกสองข้าง
var _px1 = _x - 18;
var _px2 = _x + _w + 18;
var _py1 = _y - 32;
var _py2 = _y + _h + 10;
draw_set_alpha(0.85 * _fa);
draw_rectangle_color(_px1, _py1, 480, _py2, c_black, make_color_rgb(34, 10, 20), make_color_rgb(34, 10, 20), c_black, false);
draw_rectangle_color(480, _py1, _px2, _py2, make_color_rgb(34, 10, 20), c_black, c_black, make_color_rgb(34, 10, 20), false);
draw_set_alpha(_fa);
draw_set_color(UI_GOLD_DARK);
draw_line(_px1 + 20, _py1, _px2 - 20, _py1);
draw_line(_px1 + 20, _py2, _px2 - 20, _py2);
// ปีก: เส้นทองแหลม + เพชรที่ปลาย
draw_set_color(UI_GOLD);
draw_triangle(_px1 - 14, _y + _h / 2, _px1 + 6, _y + _h / 2 - 7, _px1 + 6, _y + _h / 2 + 7, false);
draw_triangle(_px2 + 14, _y + _h / 2, _px2 - 6, _y + _h / 2 - 7, _px2 - 6, _y + _h / 2 + 7, false);
draw_line_width(_px1 + 6, _y + _h / 2, _x - 4, _y + _h / 2, 2);
draw_line_width(_px2 - 6, _y + _h / 2, _x + _w + 4, _y + _h / 2, 2);

// ชื่อบอส: ทอง มีแสงแดงเรืองด้านหลัง + เพชรสองข้าง
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
var _nw = string_width(boss_name) * 0.55;
draw_set_alpha(_na);
gpu_set_blendmode(bm_add);
draw_set_alpha(0.3 * _na * (0.7 + 0.3 * sin(current_time / 200)));
draw_set_color(make_color_rgb(200, 30, 50));
draw_text_transformed(481, _y - 15, boss_name, 0.57, 0.57, 0);
draw_text_transformed(479, _y - 13, boss_name, 0.57, 0.57, 0);
gpu_set_blendmode(bm_normal);
draw_set_alpha(_na);
ui_text_bold(480, _y - 15, boss_name, 0.55, make_color_rgb(255, 225, 160));
draw_set_color(UI_GOLD);
var _dxl = 480 - _nw / 2 - 14;
var _dxr = 480 + _nw / 2 + 14;
draw_triangle(_dxl - 5, _y - 14, _dxl + 5, _y - 14, _dxl, _y - 19, false);
draw_triangle(_dxl - 5, _y - 14, _dxl + 5, _y - 14, _dxl, _y - 9, false);
draw_triangle(_dxr - 5, _y - 14, _dxr + 5, _y - 14, _dxr, _y - 19, false);
draw_triangle(_dxr - 5, _y - 14, _dxr + 5, _y - 14, _dxr, _y - 9, false);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// หลอด: พื้น / แถบขาวไล่ตาม / เลือดไล่สีแดงเลือดหมู-ม่วง (ตัดตามความยาวที่ขยายอยู่)
draw_set_alpha(_fa);
draw_set_color(make_color_rgb(14, 6, 12));
draw_rectangle(_bx1, _y, _bx2, _y + _h, false);
var _vis_k = min(_k, _gk);   // ตอนกำลังขยาย เติมตามความยาว
var _vis_t = min(_kt, _gk);
draw_set_color(make_color_rgb(240, 220, 220));
if (_vis_t > 0) draw_rectangle(_x, _y, _x + _w * _vis_t, _y + _h, false);
var _c1 = (invuln > 0) ? c_gray : make_color_rgb(200, 40, 70);
var _c2 = (invuln > 0) ? c_dkgray : make_color_rgb(90, 14, 50);
if (_vis_k > 0) {
    var _ex1 = max(_x, _bx1);
    var _ex2 = min(_x + _w * _vis_k, _bx2);
    if (_ex2 > _ex1) {
        draw_rectangle_color(_ex1, _y, _ex2, _y + _h, _c1, _c1, _c2, _c2, false);
        // แสงวิ่งในหลอด
        var _sx = _ex1 + ((current_time / 6) mod max(1, (_ex2 - _ex1 + 60))) - 30;
        gpu_set_blendmode(bm_add);
        draw_set_alpha(0.25 * _fa);
        draw_set_color(make_color_rgb(255, 120, 140));
        draw_rectangle(clamp(_sx - 20, _ex1, _ex2), _y, clamp(_sx + 20, _ex1, _ex2), _y + _h, false);
        gpu_set_blendmode(bm_normal);
    }
}
draw_set_alpha(0.25 * _fa);
draw_set_color(c_white);
draw_rectangle(_bx1, _y + 1, _bx2, _y + 4, false);
draw_set_alpha(_fa);
draw_set_color(UI_GOLD);
draw_rectangle(_bx1 - 2, _y - 2, _bx2 + 2, _y + _h + 2, true);
// หัวขยายเรืองแสงตอนกำลังยืด
if (_gk < 1) {
    gpu_set_blendmode(bm_add);
    draw_set_color(make_color_rgb(255, 210, 160));
    draw_set_alpha(0.8);
    draw_rectangle(_bx1 - 3, _y - 4, _bx1 + 3, _y + _h + 4, false);
    draw_rectangle(_bx2 - 3, _y - 4, _bx2 + 3, _y + _h + 4, false);
    gpu_set_blendmode(bm_normal);
}
// ประกาย
for (var _si = array_length(bar_sparks) - 1; _si >= 0; _si--) {
    var _sp = bar_sparks[_si];
    _sp.x += _sp.vx; _sp.y += _sp.vy; _sp.vy += 0.12; _sp.l--;
    draw_set_alpha(clamp(_sp.l / 20, 0, 1));
    draw_set_color(UI_GOLD);
    draw_rectangle(_sp.x - 1, _sp.y - 1, _sp.x + 1, _sp.y + 1, false);
    if (_sp.l <= 0) array_delete(bar_sparks, _si, 1);
}
draw_set_alpha(1);

// ★ มีเกราะ: เลือดเป็นสีฟ้าซีด + กรอบฟ้าเรือง + ช่องเกราะเหนือกรอบ
if (shield > 0) {
    var _scol = make_color_rgb(110, 190, 255);
    var _pulse = 0.6 + 0.4 * sin(current_time / 120);

    draw_set_alpha(0.45);
    draw_set_color(_scol);
    draw_rectangle(_x, _y, _x + _w * _k, _y + _h, false);

    draw_set_alpha(_pulse);
    draw_rectangle(_x - 3, _y - 3, _x + _w + 3, _y + _h + 3, true);
    draw_rectangle(_x - 4, _y - 4, _x + _w + 4, _y + _h + 4, true);
    draw_set_alpha(1);

    // ช่องเกราะ (ต้องฟันอีกกี่ที)
    var _py = _y - 52;
    for (var _i = 0; _i < shield_hp_max; _i++) {
        var _px = _x + _i * 24;
        draw_set_color(c_black);
        draw_rectangle(_px - 1, _py - 1, _px + 20, _py + 10, false);
        draw_set_color((_i < shield_hp) ? _scol : c_dkgray);
        draw_rectangle(_px, _py, _px + 19, _py + 9, false);
    }
    // เวลาเกราะที่เหลือ
    var _tw = shield_hp_max * 24 - 4;
    draw_set_color(c_black);
    draw_rectangle(_x - 1, _py + 13, _x + _tw + 1, _py + 17, false);
    draw_set_color(_scol);
    draw_rectangle(_x, _py + 14, _x + _tw * (shield / shield_time), _py + 16, false);

    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    ui_text(_x + _tw + 10, _py + 8, L("เกราะ - ใช้ดาบฟันให้แตก", "Shield - break it with melee"), 0.48, _scol);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}

// ขีดแบ่งเฟส (โชว์เมื่อหลอดขยายเต็ม)
draw_set_alpha(_na);
draw_set_color(UI_GOLD);
if (is_final) {
    draw_line(_x + _w / 3, _y - 2, _x + _w / 3, _y + _h + 2);
    draw_line(_x + _w * 2 / 3, _y - 2, _x + _w * 2 / 3, _y + _h + 2);
} else {
    draw_line(_x + _w / 2, _y - 2, _x + _w / 2, _y + _h + 2);
}

// ★ ตัวเลขเลือด
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
ui_text(480, _y + _h / 2, string(max(0, ceil(hp))) + " / " + string(max_hp), 0.42, c_white);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// =====================================================================
// ★ ไม้ตาย / มึนงง
// =====================================================================
if (state == "ult" || state == "ult_boom" || ult_flash > 0) {
    var _uk = (state == "ult") ? (1 - ult_t / ult_time) : 1;
    draw_set_alpha(0.1 + 0.25 * _uk + 0.05 * sin(current_time / 70));
    draw_set_color(c_red);
    draw_rectangle(0, 0, 960, 540, false);
    draw_set_alpha(1);
}
if (state == "ult") {
    draw_set_font(fnt_dialog);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    var _pulse = 1 + 0.06 * sin(current_time / 90);
    draw_set_color(c_black);
    draw_text_transformed(481, 91, L("ไม้ตาย! เข้าไปฟันขัดจังหวะ (กระสุนไม่เข้า)", "Ultimate! Get close and strike to interrupt (immune to shots)"), 0.85 * _pulse, 0.85 * _pulse, 0);
    draw_set_color(c_red);
    draw_text_transformed(480, 90, L("ไม้ตาย! เข้าไปฟันขัดจังหวะ (กระสุนไม่เข้า)", "Ultimate! Get close and strike to interrupt (immune to shots)"), 0.85 * _pulse, 0.85 * _pulse, 0);

    // เกจขัดจังหวะ
    var _gx = 330;
    var _gy = 118;
    var _gw = 300;
    draw_set_color(c_black);
    draw_rectangle(_gx - 2, _gy - 2, _gx + _gw + 2, _gy + 14, false);
    draw_set_color(c_yellow);
    draw_rectangle(_gx, _gy, _gx + _gw * min(1, ult_gauge / ult_need), _gy + 12, false);
    // เวลาที่เหลือ
    draw_set_color(c_black);
    draw_rectangle(_gx - 2, _gy + 18, _gx + _gw + 2, _gy + 24, false);
    draw_set_color(c_red);
    draw_rectangle(_gx, _gy + 19, _gx + _gw * (ult_t / ult_time), _gy + 23, false);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
if (ult_flash > 0) {
    draw_set_alpha(ult_flash / 30);
    draw_set_color(c_white);
    draw_rectangle(0, 0, 960, 540, false);
    draw_set_alpha(1);
}
if (state == "stunned") {
    draw_set_font(fnt_dialog);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_yellow);
    draw_text_transformed(480, 96, L("มึนงง! รุมเลย", "Stunned! Attack now!"), 0.8, 0.8, 0);
    draw_set_color(c_black);
    draw_rectangle(378, 110, 582, 117, false);
    draw_set_color(c_yellow);
    draw_rectangle(380, 111, 380 + 200 * (stun_t / stun_time), 116, false);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
draw_set_color(c_white);
