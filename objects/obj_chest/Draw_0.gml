var _x = round(x);
var _y = round(y);

draw_set_color(make_color_rgb(40, 30, 20));
draw_set_alpha(0.35);
draw_ellipse(_x - 26, _y - 6, _x + 26, _y + 6, false);
draw_set_alpha(1);

// ★ เขตบททดสอบ (ตอนกำลังสู้)
if (trial && !opened && trial_state == 1) {
    draw_set_color(make_color_rgb(150, 70, 255));
    draw_set_alpha(0.35 + 0.15 * sin(current_time / 150));
    draw_ellipse(_x - trial_r, _y - trial_r * 0.7, _x + trial_r, _y + trial_r * 0.7, true);
    draw_ellipse(_x - trial_r + 3, _y - trial_r * 0.7 + 2, _x + trial_r - 3, _y + trial_r * 0.7 - 2, true);
    draw_set_alpha(1);
}

// ★ หีบเครื่องประดับพิเศษ: ออร่าทอง + ประกายหมุน / หีบยา: ออร่าแดง
if (!opened && acc != "") {
    gpu_set_blendmode(bm_add);
    draw_set_color(make_color_rgb(255, 200, 90));
    draw_set_alpha(0.25 + 0.15 * sin(current_time / 180));
    draw_circle(_x, _y - 22, 48, false);
    for (var _sp = 0; _sp < 4; _sp++) {
        var _sa = current_time / 8 + _sp * 90;
        draw_set_alpha(0.8);
        draw_circle(_x + lengthdir_x(36, _sa), _y - 22 + lengthdir_y(20, _sa), 2, false);
    }
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
}
if (!opened && acc == "" && potion > 0 && gold <= 0 && shot_up <= 0 && !trial) {
    gpu_set_blendmode(bm_add);
    draw_set_color(make_color_rgb(255, 80, 90));
    draw_set_alpha(0.2 + 0.1 * sin(current_time / 220));
    draw_circle(_x, _y - 22, 40, false);
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
}
// ★ หีบพลัง/บททดสอบ: ออร่าม่วงกะพริบ
if (!opened && (shot_up > 0 || trial)) {
    gpu_set_blendmode(bm_add);
    draw_set_color(make_color_rgb(150, 70, 255));
    draw_set_alpha(0.25 + 0.15 * sin(current_time / 200));
    draw_circle(_x, _y - 22, 44, false);
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
}

// ★ ภาพหีบ (ปิด/เปิด) ย้อมสีตามชนิด: ธรรมดา = ปกติ / เครื่องประดับพิเศษ = ม่วงทอง / ยา = แดง / บททดสอบ = ม่วง
var _special = (acc != "");
var _potchest = (!_special && potion > 0 && gold <= 0 && shot_up <= 0 && !trial);
var _tcol = c_white;
if (_special) _tcol = make_color_rgb(230, 180, 255);
else if (_potchest) _tcol = make_color_rgb(255, 150, 150);
else if (shot_up > 0 || trial) _tcol = make_color_rgb(200, 170, 255);
var _csc = 3;
var _hop = (!opened && near) ? abs(sin(current_time / 160)) * 2 : 0;   // เด้งเบา ๆ ตอนอยู่ใกล้
draw_sprite_ext(opened ? spr_chest_open : spr_chest_close, 0, _x, _y - _hop, _csc, _csc, 0, _tcol, 1);

draw_set_font(fnt_dialog);
draw_set_halign(fa_center);
if (!variable_instance_exists(id, "pr_a")) pr_a = 0;
pr_a = lerp(pr_a, (near && !opened) ? 1 : 0, 0.2);
ui_prompt(_x, _y - 62, input_label("interact"), trial ? L("บททดสอบ: ชนะศัตรู 3 รอบ", "Trial: survive 3 waves") : L("เปิดหีบ", "Open chest"), pr_a, trial ? make_color_rgb(200, 120, 255) : UI_GOLD);
draw_set_font(fnt_dialog);
draw_set_halign(fa_center);
if (trial && !opened && trial_state == 1) {
    draw_set_color(make_color_rgb(210, 150, 255));
    draw_text_transformed(_x, _y - 74, L("รอบ ", "Wave ") + string(max(1, trial_wave)) + " / " + string(trial_waves) + L("  |  อย่าออกนอกวง", "  |  Stay inside the circle"), 0.6, 0.6, 0);
}
draw_set_halign(fa_left);
draw_set_color(c_white);
