// =====================================================================
// ★ HUD (placeholder): หน้าตัวละคร + หลอดเลือด (ซ้ายบน) / ช่องสกิล (ล่างกลาง) / เงิน (ขวาบน)
// =====================================================================
if (!is_undefined(global.boss_intro)) exit;   // ★ ระหว่างเปิดตัวบอส ซ่อน HUD ทั้งหมด
draw_set_font(fnt_dialog);

// ---- ค่าที่ต้องจำระหว่างเฟรม ----
if (!variable_instance_exists(id, "hud_hp")) {
    hud_hp = hp;            // หลอดเลือดที่ค่อย ๆ ลด
    hud_trail = hp;         // แถบขาวตามหลัง
    hud_prev_hp = hp;
    hud_hurt_t = 0;
    hud_parts = [];         // พาร์ติเคิลสีแดงจากปลายหลอด
    hud_pop = array_create(6, 0);
    hud_prev_cd = array_create(6, 0);
}

var _hp = max(hp, 0);
var _ui_busy = instance_exists(obj_dialogue) || instance_exists(obj_shop) || instance_exists(obj_skilltree)
            || instance_exists(obj_status) || instance_exists(obj_cutscene);

// =====================================================================
// ซ้ายบน: หน้าตัวละคร + เลือด
// =====================================================================
var _fx = 14;
var _fy = 12;
var _fs = 64;
var _bx = _fx + _fs + 10;
var _by = 20;
var _bw = 220;
var _bh = 18;

// โดนตี = จำไว้ + พ่นพาร์ติเคิลจากปลายหลอด
if (_hp < hud_prev_hp) {
    hud_hurt_t = 30;
    var _ex = _bx + _bw * (_hp / max_hp);
    repeat (14) {
        array_push(hud_parts, { x: _ex, y: _by + random(_bh), vx: random_range(1.5, 5), vy: random_range(-3, 1.5), life: irandom_range(20, 38), s: random_range(2, 4) });
    }
}
if (_hp > hud_prev_hp) hud_trail = _hp;   // ฟื้นเลือด = แถบตามทันที
hud_prev_hp = _hp;
if (hud_hurt_t > 0) hud_hurt_t--;

hud_hp = lerp(hud_hp, _hp, 0.12);           // หลอดจริงค่อย ๆ ลด
if (abs(hud_hp - _hp) < 0.01) hud_hp = _hp;
if (hud_hurt_t <= 10) hud_trail = lerp(hud_trail, hud_hp, 0.06);   // แถบขาวค้างแป๊บแล้วไหลตาม

// กรอบหน้าตัวละคร
var _shake = (hud_hurt_t > 20) ? irandom_range(-2, 2) : 0;
ui_panel(_fx + _shake, _fy, _fx + _fs + _shake, _fy + _fs);
var _pd = portrait_data();
var _ps = _pd.a.sprite;
var _emo = _pd.a.emotions;
var _img = _emo.normal;
if (hud_hurt_t > 0 && variable_struct_exists(_emo, "surprised")) _img = _emo.surprised;
else if (_hp <= 1 && variable_struct_exists(_emo, "sad")) _img = _emo.sad;
var _pw = sprite_get_width(_ps);
var _psc = (_fs - 8) / _pw;
draw_sprite_part_ext(_ps, _img, 0, 0, _pw, _pw, _fx + 4 + _shake, _fy + 4, _psc, _psc, (hud_hurt_t > 20) ? make_color_rgb(255, 150, 150) : c_white, 1);

// หลอดเลือด
draw_set_color(c_black);
draw_rectangle(_bx - 2, _by - 2, _bx + _bw + 2, _by + _bh + 2, false);
draw_set_color(make_color_rgb(50, 20, 24));
draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, false);
draw_set_color(make_color_rgb(255, 235, 200));
draw_rectangle(_bx, _by, _bx + _bw * clamp(hud_trail / max_hp, 0, 1), _by + _bh, false);
var _low = (_hp <= 1);
var _hc = _low ? merge_color(make_color_rgb(200, 30, 40), make_color_rgb(255, 90, 90), 0.5 + 0.5 * sin(current_time / 120)) : make_color_rgb(210, 40, 50);
draw_rectangle_color(_bx, _by, _bx + _bw * clamp(hud_hp / max_hp, 0, 1), _by + _bh, make_color_rgb(240, 80, 80), make_color_rgb(240, 80, 80), _hc, _hc, false);
// ขีดแบ่งหัวใจ
draw_set_color(c_black);
for (var _h = 1; _h < max_hp; _h++) {
    var _hx = _bx + _bw * _h / max_hp;
    draw_line_width(_hx, _by, _hx, _by + _bh, 2);
}
draw_set_color(UI_GOLD_DARK);
draw_rectangle(_bx - 2, _by - 2, _bx + _bw + 2, _by + _bh + 2, true);
draw_set_valign(fa_middle);
ui_text_bold(_bx + 6, _by + _bh / 2, string(_hp) + " / " + string(max_hp), 0.48, c_white);
draw_set_valign(fa_top);

// พาร์ติเคิลสีแดง
for (var _pi = array_length(hud_parts) - 1; _pi >= 0; _pi--) {
    var _p = hud_parts[_pi];
    _p.x += _p.vx;
    _p.y += _p.vy;
    _p.vy += 0.2;
    _p.vx *= 0.96;
    _p.life--;
    draw_set_alpha(clamp(_p.life / 20, 0, 1));
    draw_set_color((_p.life mod 6 < 3) ? make_color_rgb(255, 60, 60) : make_color_rgb(180, 20, 30));
    draw_rectangle(_p.x, _p.y, _p.x + _p.s, _p.y + _p.s, false);
    if (_p.life <= 0) array_delete(hud_parts, _pi, 1);
}
draw_set_alpha(1);

// แถวใต้หลอด: ATK + สถานะผิดปกติ
var _ry = _by + _bh + 8;
ui_text(_bx, _ry, "ATK " + string(round(player_atk() * player_stats().atk)), 0.48, UI_GOLD);
var _sx2 = _bx + 74;
// ★ สถานะผิดปกติเป็นไอคอน (กรอบแดงกะพริบ) + คำสั้น ๆ
var _sts = [["burn", st_burn, "กลิ้งดับไฟ!", c_orange], ["poison", st_poison, "พิษ", make_color_rgb(140, 220, 90)], ["stun", st_stun, "มึน", c_yellow]];
for (var _q = 0; _q < 3; _q++) {
    if (_sts[_q][1] <= 0) continue;
    var _fl = 0.5 + 0.5 * sin(current_time / 120);
    draw_set_color(make_color_rgb(40, 16, 20));
    draw_rectangle(_sx2, _ry - 1, _sx2 + 20, _ry + 19, false);
    draw_set_color(merge_color(make_color_rgb(140, 40, 40), make_color_rgb(255, 90, 90), _fl));
    draw_rectangle(_sx2, _ry - 1, _sx2 + 20, _ry + 19, true);
    ui_icon(_sts[_q][0], _sx2 + 10, _ry + 9, 7, c_white);
    ui_text(_sx2 + 25, _ry, _sts[_q][2], 0.42, _sts[_q][3]);
    _sx2 += 32 + string_width(_sts[_q][2]) * 0.42;
}

// บัฟที่ทำงาน (ไอคอนเล็ก + เวลา)
var _bxx = _bx;
for (var _q2 = 0; _q2 < array_length(global.buffs); _q2++) {
    var _bd = buff_data(global.buffs[_q2].id);
    var _k = global.buffs[_q2].t / global.buffs[_q2].t0;
    draw_set_color(c_black);
    draw_rectangle(_bxx, _ry + 22, _bxx + 22, _ry + 44, false);
    draw_set_color(_bd.col);
    draw_rectangle(_bxx + 2, _ry + 24 + 18 * (1 - _k), _bxx + 20, _ry + 42, false);
    ui_text(_bxx + 26, _ry + 25, string(ceil(global.buffs[_q2].t / 60)), 0.42, UI_TEXT);
    _bxx += 52;
}

// ★ คอมโบ + ดาเมจรวม (ซ้าย ใต้ HUD)
if (!_ui_busy) draw_combo_hud();

// =====================================================================
// ล่างกลาง: ช่องสกิล
// =====================================================================
if (!_ui_busy) {
    var _ham = (global.save.weapon == "hammer");
    var _sz = 48;
    var _gap = 12;
    var _n = 6;
    var _x0 = 480 - (_n * _sz + (_n - 1) * _gap) / 2;
    var _y0 = 540 - _sz - 26;

    // [ปุ่ม, ไอคอน, คูลดาวน์ 0-1, ล็อก, จำนวน, กำลังทำงาน]
    var _atk_cd = (attack_cd > 0) ? attack_cd / max(1, (combo == 9) ? charge_end_lag : attack_end_lag) : 0;
    var _s1_cd = (shot1_reload_timer > 0) ? shot1_reload_timer / shot1_reload : ((shot1_timer > 0) ? shot1_timer / shot1_gap : 0);
    var _slots = [
        ["คลิก",  _ham ? "hammer" : "sword", _atk_cd, false, (state == PState.ATTACK && combo > 0 && combo < 9) ? string(combo) : "", state == PState.ATTACK],
        ["ค้าง",  "charge", 0, !_ham, "", state == PState.CHARGE],
        ["1",     "fire", _s1_cd, false, string(shot1_ammo), false],
        ["2",     "fire3", skill2_unlocked ? skill2_timer / skill2_cooldown : 0, !skill2_unlocked, "", false],
        ["Space", "roll", (roll_cd_timer > 0) ? roll_cd_timer / max(1, roll_cooldown) : 0, false, "", state == PState.ROLL],
        ["Q",     "potion", 0, global.save.potions <= 0, string(global.save.potions), false]
    ];
    for (var _i = 0; _i < _n; _i++) {
        var _sl = _slots[_i];
        // เด้งตอนคูลดาวน์เพิ่งหมด
        if (hud_prev_cd[_i] > 0 && _sl[2] <= 0) hud_pop[_i] = 1;
        hud_prev_cd[_i] = _sl[2];
        if (hud_pop[_i] > 0) hud_pop[_i] = max(0, hud_pop[_i] - 0.08);
        ui_slot(_x0 + _i * (_sz + _gap), _y0, _sz, _sl[0], _sl[1], _sl[2], hud_pop[_i], _sl[3], _sl[4], _sl[5]);
    }

    // เกจชาร์จค้อนบนช่อง "ค้าง"
    if (state == PState.CHARGE) {
        var _cxs = _x0 + 1 * (_sz + _gap);
        draw_set_color(c_black);
        draw_rectangle(_cxs - 1, _y0 - 10, _cxs + _sz + 1, _y0 - 4, false);
        draw_set_color((charge_t >= charge_time) ? c_yellow : c_orange);
        draw_rectangle(_cxs, _y0 - 9, _cxs + _sz * (charge_t / charge_time), _y0 - 5, false);
    }

    // ไอเท็มบัฟที่เลือก (ขวาของแถบ)
    var _bl = buff_list();
    var _hasany = false;
    for (var _q = 0; _q < array_length(_bl); _q++) if (variable_struct_exists(global.save.buff_items, _bl[_q]) && global.save.buff_items[$ _bl[_q]] > 0) _hasany = true;
    if (_hasany) {
        var _bid = _bl[global.buff_sel];
        var _bn = variable_struct_exists(global.save.buff_items, _bid) ? global.save.buff_items[$ _bid] : 0;
        var _fxs = _x0 + _n * (_sz + _gap) + 8;
        ui_panel(_fxs, _y0 + 4, _fxs + 150, _y0 + _sz - 4, 0.9);
        draw_set_valign(fa_middle);
        ui_text_bold(_fxs + 10, _y0 + _sz / 2 - 7, "[F] " + buff_data(_bid).name, 0.42, buff_data(_bid).col);
        ui_text(_fxs + 10, _y0 + _sz / 2 + 9, "x" + string(_bn) + "   [V] เปลี่ยน", 0.38, UI_MUTED);
        draw_set_valign(fa_top);
    }
}

// =====================================================================
// เลือดใกล้หมด: ขอบจอแดงเต้นเบา ๆ
// =====================================================================
if (_hp == 1 && _hp > 0) {
    var _la = 0.18 + 0.12 * sin(current_time / 150);
    var _lc = make_color_rgb(200, 0, 20);
    var _lw = 90;
    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_color(0, 0, _lc, _la); draw_vertex_color(0, 540, _lc, _la);
    draw_vertex_color(_lw, 0, _lc, 0); draw_vertex_color(_lw, 540, _lc, 0);
    draw_primitive_end();
    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_color(960, 0, _lc, _la); draw_vertex_color(960, 540, _lc, _la);
    draw_vertex_color(960 - _lw, 0, _lc, 0); draw_vertex_color(960 - _lw, 540, _lc, 0);
    draw_primitive_end();
}

draw_set_color(c_white);

// ขวาบน: เงิน / SP / อาวุธ
draw_hud_money();
