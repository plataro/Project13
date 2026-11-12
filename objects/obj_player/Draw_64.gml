var _bx = 24;
var _by = 24;
var _bw = 200;
var _bh = 20;

// เลือด
draw_set_color(c_black);
draw_rectangle(_bx - 2, _by - 2, _bx + _bw + 2, _by + _bh + 2, false);
draw_set_color(c_red);
draw_rectangle(_bx, _by, _bx + _bw * (max(hp, 0) / max_hp), _by + _bh, false);

draw_set_font(fnt_dialog);

// สกิล 1: ช่องกระสุน 6 ช่อง
var _sy = 60;
draw_set_color(c_white);
draw_text_transformed(_bx, _sy - 5, "1", 0.6, 0.6, 0);
for (var _i = 0; _i < shot1_max; _i++) {
    var _px = _bx + 24 + _i * 22;
    draw_set_color(c_black);
    draw_rectangle(_px - 1, _sy - 1, _px + 16, _sy + 16, false);
    draw_set_color((_i < shot1_ammo) ? c_aqua : c_dkgray);
    draw_rectangle(_px, _sy, _px + 15, _sy + 15, false);
}
// แถบรีโหลด
if (shot1_reload_timer > 0) {
    var _rw = max(shot1_max, 4) * 22 - 6;
    draw_set_color(c_black);
    draw_rectangle(_bx + 23, _sy + 20, _bx + 25 + _rw, _sy + 26, false);
    draw_set_color(c_orange);
    draw_rectangle(_bx + 24, _sy + 21, _bx + 24 + _rw * (1 - shot1_reload_timer / shot1_reload), _sy + 25, false);
}

// สกิล 2: แถบคูลดาวน์ (โชว์เมื่อปลดแล้ว)
var _s2y = 96;
var _s2w = max(shot1_max, 4) * 22 - 6;
if (skill2_unlocked) {
draw_set_color(c_white);
draw_text_transformed(_bx, _s2y - 5, "2", 0.6, 0.6, 0);
draw_set_color(c_black);
draw_rectangle(_bx + 23, _s2y - 1, _bx + 25 + _s2w, _s2y + 16, false);
var _ready = (skill2_timer <= 0);
draw_set_color(_ready ? c_yellow : c_gray);
draw_rectangle(_bx + 24, _s2y, _bx + 24 + _s2w * (_ready ? 1 : 1 - skill2_timer / skill2_cooldown), _s2y + 15, false);
}

draw_set_color(c_white);

// ★ พลังโจมตี
draw_text_transformed(_bx, 124, "ATK " + string(round(player_atk() * player_stats().atk)) + "   [I] สถานะ", 0.6, 0.6, 0);

// ★ ไอเท็มบัฟที่เลือก + บัฟที่ทำงาน
var _bl = buff_list();
var _bid = _bl[global.buff_sel];
var _bn = variable_struct_exists(global.save.buff_items, _bid) ? global.save.buff_items[$ _bid] : 0;
var _hasany = false;
for (var _q = 0; _q < array_length(_bl); _q++) if (variable_struct_exists(global.save.buff_items, _bl[_q]) && global.save.buff_items[$ _bl[_q]] > 0) _hasany = true;
if (_hasany) {
    draw_set_color(buff_data(_bid).col);
    draw_text_transformed(_bx, 144, "[F] " + buff_data(_bid).name + " x" + string(_bn) + "  [V] เปลี่ยน", 0.55, 0.55, 0);
}
var _bxx = _bx;
for (var _q2 = 0; _q2 < array_length(global.buffs); _q2++) {
    var _bdd = buff_data(global.buffs[_q2].id);
    draw_set_color(_bdd.col);
    draw_text_transformed(_bxx, 164, _bdd.name + " " + string(ceil(global.buffs[_q2].t / 60)), 0.5, 0.5, 0);
    _bxx += 120;
}
// ★ สถานะผิดปกติของผู้เล่น (ข้างหลอดเลือด)
var _sx2 = _bx + _bw + 14;
if (st_burn > 0)   { draw_set_color(c_orange); draw_text_transformed(_sx2, _by + 2, "ไฟไหม้! (กลิ้งดับ)", 0.55, 0.55, 0); _sx2 += 130; }
if (st_poison > 0) { draw_set_color(make_color_rgb(140, 220, 90)); draw_text_transformed(_sx2, _by + 2, "พิษ", 0.55, 0.55, 0); _sx2 += 50; }
if (st_stun > 0)   { draw_set_color(c_yellow); draw_text_transformed(_sx2, _by + 2, "มึน", 0.55, 0.55, 0); }
draw_set_color(c_white);

// เหรียญ + ยา
draw_hud_money();