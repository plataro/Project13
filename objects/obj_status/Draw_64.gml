var _gold = make_color_rgb(200, 170, 110);
draw_set_alpha(0.7);
draw_set_color(c_black);
draw_rectangle(0, 0, 960, 540, false);
draw_set_alpha(1);
draw_set_color(make_color_rgb(36, 32, 48));
draw_rectangle(px, py, px + pw, py + ph, false);
draw_set_color(_gold);
draw_rectangle(px, py, px + pw, py + ph, true);
draw_rectangle(px + 3, py + 3, px + pw - 3, py + ph - 3, true);

draw_set_font(fnt_dialog);
draw_set_valign(fa_middle);
draw_set_halign(fa_left);
draw_set_color(c_white);
draw_text(px + 24, py + 28, "สถานะตัวละคร");

var _st = player_stats();
var _s = global.save;
var _sd = shot_data(_s.shot_lv);
var _hp = instance_exists(obj_player) ? obj_player.hp : global.player_hp;

// ===== ซ้าย: ค่าสถานะ =====
var _rows = [
    ["หัวใจ",        string(_hp) + " / " + string(global.max_hp)],
    ["พลังโจมตี",     string(round(player_atk() * _st.atk)) + ((_st.atk != 1) ? ("  (+" + string(round((_st.atk - 1) * 100)) + "%)") : "")],
    ["โอกาสคริ",      string(round(_st.crit * 100)) + "%"],
    ["ดาเมจคริ",      "x" + string_format(_st.critdmg, 1, 1)],
    ["ความเร็ว",      string(round(_st.spd * 100)) + "%"],
    ["ลดดาเมจรับ",     "-" + string(_st.def)],
    ["พลังยิง",       string(_sd.ammo) + " นัด · แรง x" + string(_sd.dmg)],
    ["อาวุธ",         weapon_data(_s.weapon).name],
    ["เกราะ",         (_s.armor == 0) ? "-" : ((_s.armor == 1) ? "เกราะหนัง" : "เกราะเหล็ก")],
    ["ติดสถานะศัตรู",  ((_st.burn > 0) ? ("ไฟ " + string(round(_st.burn * 100)) + "% ") : "") + ((_st.poison > 0) ? ("พิษ " + string(round(_st.poison * 100)) + "% ") : "") + ((_st.stun > 0) ? ("สตัน " + string(round(_st.stun * 100)) + "%") : "") + ((_st.burn + _st.poison + _st.stun) <= 0 ? "-" : "")]
];
for (var _i = 0; _i < array_length(_rows); _i++) {
    var _y = py + 74 + _i * 32;
    draw_set_color(c_ltgray);
    draw_text_transformed(px + 30, _y, _rows[_i][0], 0.7, 0.7, 0);
    draw_set_color(c_white);
    draw_text_transformed(px + 190, _y, _rows[_i][1], 0.7, 0.7, 0);
}

// ===== ขวา: เครื่องประดับ =====
draw_set_color(_gold);
draw_text_transformed(px + 440, py + 74, "เครื่องประดับที่สวม (2 ช่อง)", 0.7, 0.7, 0);
for (var _k = 0; _k < 2; _k++) {
    var _sy = py + 104 + _k * 34;
    draw_set_color(make_color_rgb(56, 48, 70));
    draw_rectangle(px + 440, _sy - 14, px + pw - 24, _sy + 14, false);
    draw_set_color(c_white);
    var _id = (_k < array_length(_s.acc_eq)) ? _s.acc_eq[_k] : "";
    draw_text_transformed(px + 452, _sy, (_id == "") ? "- ว่าง -" : (acc_data(_id).name + "  ·  " + acc_data(_id).desc), 0.62, 0.62, 0);
}
draw_set_color(_gold);
draw_text_transformed(px + 440, py + 186, "ที่มี (คลิก = สวม/ถอด)", 0.7, 0.7, 0);
var _list = acc_list();
var _row = 0;
for (var _a = 0; _a < array_length(_list); _a++) {
    if (!acc_owned(_list[_a])) continue;
    var _ry = py + 214 + _row * 30;
    var _eqd = acc_equipped(_list[_a]);
    draw_set_color((hover_acc == _list[_a]) ? make_color_rgb(90, 80, 112) : make_color_rgb(48, 42, 62));
    draw_rectangle(px + 440, _ry - 2, px + pw - 24, _ry + 26, false);
    draw_set_color(_eqd ? c_yellow : c_white);
    draw_text_transformed(px + 452, _ry + 12, (_eqd ? "[สวม] " : "") + acc_data(_list[_a]).name + "  ·  " + acc_data(_list[_a]).desc, 0.6, 0.6, 0);
    _row++;
}
if (_row == 0) {
    draw_set_color(c_gray);
    draw_text_transformed(px + 452, py + 226, "ยังไม่มี (ซื้อได้ที่ร้านอัญมณีในหมู่บ้าน)", 0.6, 0.6, 0);
}

// ===== ล่าง: บัฟ / สถานะผิดปกติ =====
var _by = py + ph - 96;
draw_set_color(_gold);
draw_text_transformed(px + 30, _by, "บัฟที่ทำงานอยู่", 0.7, 0.7, 0);
var _bt = "";
for (var _b = 0; _b < array_length(global.buffs); _b++) {
    var _bd = buff_data(global.buffs[_b].id);
    _bt += _bd.name + " " + string(ceil(global.buffs[_b].t / 60)) + "วิ   ";
}
if (instance_exists(obj_player)) {
    if (obj_player.st_burn > 0) _bt += "[ไฟไหม้]  ";
    if (obj_player.st_poison > 0) _bt += "[พิษ]  ";
}
draw_set_color(c_white);
draw_text_transformed(px + 190, _by, (_bt == "") ? "-" : _bt, 0.6, 0.6, 0);
var _it = "";
var _bl = buff_list();
for (var _j = 0; _j < array_length(_bl); _j++) {
    var _n = variable_struct_exists(_s.buff_items, _bl[_j]) ? _s.buff_items[$ _bl[_j]] : 0;
    if (_n > 0) _it += buff_data(_bl[_j]).name + " x" + string(_n) + "   ";
}
draw_set_color(_gold);
draw_text_transformed(px + 30, _by + 30, "ไอเท็มบัฟ (F ใช้ · V เลือก)", 0.7, 0.7, 0);
draw_set_color(c_white);
draw_text_transformed(px + 260, _by + 30, (_it == "") ? "-" : _it, 0.6, 0.6, 0);

// ปุ่มปิด
draw_set_color(make_color_rgb(110, 60, 60));
draw_rectangle(px + pw - 150, py + ph - 50, px + pw - 20, py + ph - 14, false);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_text_transformed(px + pw - 85, py + ph - 32, "ปิด (I)", 0.75, 0.75, 0);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
