// ★ หน้าสถานะ (สไตล์ UI ใหม่ + ภาพตัวละคร) — placeholder
open_t = min(1, open_t + 1 / 12);
var _ok = 1 - power(1 - open_t, 3);
draw_set_alpha(0.7 * _ok);
draw_set_color(c_black);
draw_rectangle(0, 0, 960, 540, false);
draw_set_alpha(1);
ui_panel(px, py, px + pw, py + ph, _ok);
draw_set_alpha(_ok);

draw_set_font(fnt_dialog);
draw_set_valign(fa_middle);
draw_set_halign(fa_left);
ui_text_bold(px + 22, py + 24, L("สถานะตัวละคร", "Character Status"), 0.66, UI_GOLD);
draw_set_halign(fa_right);
ui_text(px + pw - 22, py + 24, ((global.input_dev == "pad") ? L("B ปิด", "B close") : (input_label("status") + L(" / Esc ปิด", " / Esc close"))), 0.42, UI_MUTED);
draw_set_halign(fa_left);
draw_set_color(UI_GOLD_DARK);
draw_line(px + 20, py + 42, px + pw - 20, py + 42);

var _st = player_stats();
var _s = global.save;
var _sd = shot_data(_s.shot_lv);
var _hp = instance_exists(obj_player) ? obj_player.hp : global.player_hp;

// ===== ซ้าย: ภาพตัวละคร =====
var _fx1 = px + 20;
var _fy1 = py + 56;
var _fx2 = px + 184;
var _fy2 = py + 250;
draw_rectangle_color(_fx1, _fy1, _fx2, _fy2, make_color_rgb(50, 44, 70), make_color_rgb(50, 44, 70), make_color_rgb(16, 14, 24), make_color_rgb(16, 14, 24), false);
// แสงด้านหลัง
draw_set_alpha(0.18 * _ok);
draw_set_color(UI_GOLD);
draw_circle((_fx1 + _fx2) / 2, _fy1 + 90, 60 + 4 * sin(current_time / 400), false);
draw_set_alpha(_ok);
var _pd = portrait_data().a;
var _ps = _pd.sprite;
var _emo = _pd.emotions.normal;
if (instance_exists(obj_player) && obj_player.hp <= 1 && variable_struct_exists(_pd.emotions, "sad")) _emo = _pd.emotions.sad;
var _sw = sprite_get_width(_ps);
var _sh = sprite_get_height(_ps);
var _sc = min((_fx2 - _fx1 - 8) / _sw, (_fy2 - _fy1 - 8) / _sh);
var _dw = _sw * _sc;
var _dh = _sh * _sc;
var _breath = sin(current_time / 600) * 1.5;
draw_sprite_part_ext(_ps, _emo, 0, 0, _sw, _sh, (_fx1 + _fx2) / 2 - _dw / 2, _fy2 - 4 - _dh + _breath, _sc, _sc, c_white, _ok);
draw_set_color(UI_GOLD);
draw_rectangle(_fx1, _fy1, _fx2, _fy2, true);
draw_set_color(UI_GOLD_DARK);
draw_rectangle(_fx1 + 3, _fy1 + 3, _fx2 - 3, _fy2 - 3, true);

// หัวใจใต้ภาพ
var _hx = _fx1 + 4;
for (var _h = 0; _h < global.max_hp; _h++) {
    var _hcx = _hx + 8 + _h * 18;
    draw_set_color((_h < _hp) ? make_color_rgb(230, 60, 70) : make_color_rgb(60, 40, 50));
    draw_circle(_hcx - 3, _fy2 + 14, 4, false);
    draw_circle(_hcx + 3, _fy2 + 14, 4, false);
    draw_triangle(_hcx - 7, _fy2 + 15, _hcx + 7, _fy2 + 15, _hcx, _fy2 + 23, false);
}
// อาวุธ / เกราะ
ui_icon((_s.weapon == "hammer") ? "hammer" : "sword", _fx1 + 10, _fy2 + 40, 7, UI_GOLD);
ui_text(_fx1 + 24, _fy2 + 40, weapon_data(_s.weapon).name, 0.45, UI_TEXT);
ui_icon("gem", _fx1 + 10, _fy2 + 62, 7, make_color_rgb(150, 170, 200));
ui_text(_fx1 + 24, _fy2 + 62, (_s.armor == 0) ? L("ไม่มีเกราะ", "No armor") : ((_s.armor == 1) ? L("เกราะหนัง", "Leather Armor") : L("เกราะเหล็ก", "Iron Armor")), 0.45, UI_TEXT);

// ===== กลาง: ค่าสถานะ =====
var _rows = [
    [L("หัวใจ", "Hearts"),        string(_hp) + " / " + string(global.max_hp), make_color_rgb(230, 80, 90)],
    [L("พลังโจมตี", "Attack"),     string(round(player_atk() * _st.atk)) + ((_st.atk != 1) ? ("  (+" + string(round((_st.atk - 1) * 100)) + "%)") : ""), make_color_rgb(240, 130, 100)],
    [L("โอกาสคริ", "Crit Chance"),      string(round(_st.crit * 100)) + "%", make_color_rgb(255, 200, 90)],
    [L("ดาเมจคริ", "Crit Damage"),      "x" + string_format(_st.critdmg, 1, 1), make_color_rgb(255, 170, 70)],
    [L("ความเร็ว", "Speed"),      string(round(_st.spd * 100)) + "%", make_color_rgb(140, 230, 160)],
    [L("ลดดาเมจรับ", "Damage Reduction"),     "-" + string(_st.def), make_color_rgb(150, 170, 200)],
    [L("พลังยิง", "Fireball"),       string(_sd.ammo) + L(" นัด | x", " shots | x") + string(_sd.dmg), make_color_rgb(255, 150, 60)],
    [L("ติดสถานะศัตรู", "On-hit Effects"),  ((_st.burn > 0) ? (L("ไฟ ", "Burn ") + string(round(_st.burn * 100)) + "% ") : "") + ((_st.poison > 0) ? (L("พิษ ", "Poison ") + string(round(_st.poison * 100)) + "% ") : "") + ((_st.stun > 0) ? (L("สตัน ", "Stun ") + string(round(_st.stun * 100)) + "%") : "") + ((_st.burn + _st.poison + _st.stun) <= 0 ? "-" : ""), make_color_rgb(200, 140, 255)]
];
var _sx1 = px + 204;
var _sx2 = px + 450;
ui_text_bold(_sx1, py + 62, L("ค่าสถานะ", "Stats"), 0.5, UI_GOLD, false);
for (var _i = 0; _i < array_length(_rows); _i++) {
    var _y = py + 92 + _i * 29;
    if (_i mod 2 == 0) {
        draw_set_alpha(0.35 * _ok);
        draw_set_color(UI_BG2);
        draw_rectangle(_sx1, _y - 13, _sx2, _y + 13, false);
        draw_set_alpha(_ok);
    }
    draw_set_color(_rows[_i][2]);
    draw_triangle(_sx1 + 6, _y, _sx1 + 11, _y - 5, _sx1 + 16, _y, false);
    draw_triangle(_sx1 + 6, _y, _sx1 + 11, _y + 5, _sx1 + 16, _y, false);
    ui_text(_sx1 + 24, _y, _rows[_i][0], 0.45, UI_MUTED);
    draw_set_halign(fa_right);
    ui_text_bold(_sx2 - 8, _y, _rows[_i][1], 0.45, UI_TEXT, false);
    draw_set_halign(fa_left);
}

// ===== ขวา: เครื่องประดับ =====
ui_text_bold(acc_x1, py + 62, L("เครื่องประดับที่สวม (2 ช่อง)", "Equipped Accessories (2 slots)"), 0.5, UI_GOLD, false);
for (var _k = 0; _k < 2; _k++) {
    var _sy = py + 92 + _k * 32;
    var _id = (_k < array_length(_s.acc_eq)) ? _s.acc_eq[_k] : "";
    draw_set_color((_id == "") ? UI_BG : make_color_rgb(60, 50, 28));
    draw_rectangle(acc_x1, _sy - 13, acc_x2, _sy + 13, false);
    draw_set_color((_id == "") ? make_color_rgb(70, 62, 86) : UI_GOLD);
    draw_rectangle(acc_x1, _sy - 13, acc_x2, _sy + 13, true);
    ui_icon("gem", acc_x1 + 14, _sy, 7, (_id == "") ? make_color_rgb(70, 62, 86) : make_color_rgb(120, 220, 255));
    ui_text(acc_x1 + 28, _sy, (_id == "") ? L("- ว่าง -", "- empty -") : acc_data(_id).name, 0.45, (_id == "") ? UI_MUTED : UI_TEXT);
}
ui_text_bold(acc_x1, acc_y0 - 18, L("ที่มี (คลิก = สวม/ถอด)", "Owned (click = equip/remove)"), 0.5, UI_GOLD, false);
var _list = acc_list();
var _row = 0;
for (var _a = 0; _a < array_length(_list); _a++) {
    if (!acc_owned(_list[_a])) continue;
    var _rr = acc_rect(_row);
    var _eqd = acc_equipped(_list[_a]);
    var _hv = (hover_acc == _list[_a]);
    draw_set_color(_eqd ? make_color_rgb(60, 50, 28) : (_hv ? make_color_rgb(60, 52, 78) : make_color_rgb(30, 27, 42)));
    draw_rectangle(_rr[0], _rr[1], _rr[2], _rr[3], false);
    draw_set_color(_eqd ? UI_GOLD : (_hv ? UI_GOLD_DARK : make_color_rgb(60, 54, 74)));
    draw_rectangle(_rr[0], _rr[1], _rr[2], _rr[3], true);
    ui_text(_rr[0] + 8, (_rr[1] + _rr[3]) / 2, acc_data(_list[_a]).name, ui_fit(acc_data(_list[_a]).name, 0.4, acc_cw - 14), _eqd ? make_color_rgb(255, 225, 120) : UI_TEXT);
    _row++;
}
if (_row == 0) ui_text(acc_x1, acc_y0 + 10, L("ยังไม่มี (ซื้อได้ที่ร้านอัญมณี)", "None yet (buy at the Jeweler)"), 0.42, UI_MUTED);

// ===== ล่าง: บัฟ / สถานะผิดปกติ (เป็นไอคอน) =====
var _by = py + ph - 108;
draw_set_color(UI_GOLD_DARK);
draw_line(px + 20, _by - 14, px + pw - 20, _by - 14);
ui_text_bold(px + 22, _by, L("บัฟ / สถานะ", "Buffs / Status"), 0.48, UI_GOLD, false);
var _cx = px + 140;
var _any = false;
for (var _b = 0; _b < array_length(global.buffs); _b++) {
    var _bd = buff_data(global.buffs[_b].id);
    var _kk = global.buffs[_b].t / global.buffs[_b].t0;
    draw_set_color(UI_BG);
    draw_rectangle(_cx, _by - 14, _cx + 28, _by + 14, false);
    draw_set_color(_bd.col);
    draw_rectangle(_cx + 2, _by - 12 + 24 * (1 - _kk), _cx + 26, _by + 12, false);
    draw_set_color(UI_GOLD_DARK);
    draw_rectangle(_cx, _by - 14, _cx + 28, _by + 14, true);
    ui_text(_cx + 34, _by, _bd.name + " " + string(ceil(global.buffs[_b].t / 60)) + L("วิ", "s"), 0.42, UI_TEXT);
    _cx += 44 + string_width(_bd.name) * 0.42 + 36;
    _any = true;
}
if (instance_exists(obj_player)) {
    var _sts = [["burn", obj_player.st_burn, L("ไฟไหม้", "Burning")], ["poison", obj_player.st_poison, L("พิษ", "Poisoned")], ["stun", obj_player.st_stun, L("มึน", "Stunned")]];
    for (var _q = 0; _q < 3; _q++) {
        if (_sts[_q][1] <= 0) continue;
        draw_set_color(make_color_rgb(50, 20, 24));
        draw_rectangle(_cx, _by - 14, _cx + 28, _by + 14, false);
        draw_set_color(make_color_rgb(200, 80, 80));
        draw_rectangle(_cx, _by - 14, _cx + 28, _by + 14, true);
        ui_icon(_sts[_q][0], _cx + 14, _by, 9, c_white);
        ui_text(_cx + 34, _by, _sts[_q][2], 0.42, make_color_rgb(255, 150, 140));
        _cx += 34 + string_width(_sts[_q][2]) * 0.42 + 20;
        _any = true;
    }
}
if (!_any) ui_text(px + 140, _by, "-", 0.45, UI_MUTED);

// ไอเท็มบัฟที่ถือ
ui_text_bold(px + 22, _by + 40, L("ไอเท็มบัฟ", "Buff Items"), 0.48, UI_GOLD, false);
var _ix = px + 140;
var _bl = buff_list();
var _anyi = false;
for (var _j = 0; _j < array_length(_bl); _j++) {
    var _n = variable_struct_exists(_s.buff_items, _bl[_j]) ? _s.buff_items[$ _bl[_j]] : 0;
    if (_n <= 0) continue;
    var _bd2 = buff_data(_bl[_j]);
    var _sel = (global.buff_sel == _j);
    var _tw = string_width(_bd2.name + " x" + string(_n)) * 0.42 + 36;
    draw_set_color(_sel ? make_color_rgb(60, 50, 28) : UI_BG);
    draw_rectangle(_ix, _by + 28, _ix + _tw, _by + 52, false);
    draw_set_color(_sel ? UI_GOLD : make_color_rgb(70, 62, 86));
    draw_rectangle(_ix, _by + 28, _ix + _tw, _by + 52, true);
    ui_icon("potion", _ix + 13, _by + 40, 7, _bd2.col);
    ui_text(_ix + 26, _by + 40, _bd2.name + " x" + string(_n), 0.42, UI_TEXT);
    _ix += _tw + 8;
    _anyi = true;
}
if (!_anyi) ui_text(px + 140, _by + 40, "-", 0.45, UI_MUTED);
ui_text(px + 22, py + ph - 26, input_label("buff_use") + L(" ใช้บัฟ | ", " use buff | ") + input_label("buff_next") + L(" เปลี่ยน", " switch"), 0.4, UI_MUTED);

// ปุ่มปิด
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

// ★ กล่องคำอธิบายเครื่องประดับที่ชี้ (ข้างเมาส์)
if (hover_acc != "") {
    var _dsc = acc_data(hover_acc).desc + (acc_equipped(hover_acc) ? L("  | คลิกเพื่อถอด", "  | click to remove") : L("  | คลิกเพื่อสวม", "  | click to equip"));
    var _tw2 = string_width(_dsc) * 0.42 + 20;
    var _tx1 = clamp(_mx - _tw2 - 10, 4, 956 - _tw2);
    var _ty1 = _my + 14;
    if (pad_on) {   // ★ จอย: วางกล่องใต้ช่องที่เลือก
        var _prr = acc_rect(pad_i);
        _tx1 = clamp(_prr[2] - _tw2, 4, 956 - _tw2);
        _ty1 = _prr[3] + 6;
    }
    draw_set_alpha(0.95 * _ok);
    draw_set_color(UI_BG);
    draw_rectangle(_tx1, _ty1, _tx1 + _tw2, _ty1 + 26, false);
    draw_set_alpha(_ok);
    draw_set_color(UI_GOLD);
    draw_rectangle(_tx1, _ty1, _tx1 + _tw2, _ty1 + 26, true);
    draw_set_halign(fa_left);
    ui_text(_tx1 + 10, _ty1 + 13, _dsc, 0.42, make_color_rgb(200, 230, 255));
}
var _ch = point_in_rectangle(_mx, _my, close_x1, close_y1, close_x2, close_y2);
draw_set_color(_ch ? make_color_rgb(110, 54, 58) : make_color_rgb(80, 40, 44));
draw_rectangle(close_x1, close_y1, close_x2, close_y2, false);
draw_set_color(_ch ? UI_GOLD : UI_GOLD_DARK);
draw_rectangle(close_x1, close_y1, close_x2, close_y2, true);
draw_set_halign(fa_center);
ui_text((close_x1 + close_x2) / 2, (close_y1 + close_y2) / 2, L("ปิด (", "Close (") + input_label("status") + ")", 0.5, UI_TEXT);

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
