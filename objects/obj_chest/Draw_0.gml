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

if (!opened) {
    // ★ สีหีบตามชนิด: ธรรมดา = ไม้ / เครื่องประดับพิเศษ = ม่วงขอบทอง / ยา = แดงมีกากบาท
    var _special = (acc != "");
    var _potchest = (!_special && potion > 0 && gold <= 0 && shot_up <= 0 && !trial);
    var _c1 = _special ? make_color_rgb(70, 40, 100) : (_potchest ? make_color_rgb(150, 45, 50) : make_color_rgb(150, 95, 40));
    var _c2 = _special ? make_color_rgb(50, 26, 76) : (_potchest ? make_color_rgb(110, 30, 36) : make_color_rgb(110, 65, 25));
    draw_set_color(_c1);
    draw_rectangle(_x - 24, _y - 34, _x + 24, _y - 2, false);
    draw_set_color(_c2);
    draw_rectangle(_x - 24, _y - 42, _x + 24, _y - 30, false);
    if (_special) {
        draw_set_color(make_color_rgb(255, 210, 120));
        draw_rectangle(_x - 24, _y - 42, _x + 24, _y - 2, true);
        draw_rectangle(_x - 25, _y - 43, _x + 25, _y - 1, true);
    }
    if (_potchest) {
        draw_set_color(c_white);
        draw_rectangle(_x - 2, _y - 28, _x + 2, _y - 8, false);
        draw_rectangle(_x - 10, _y - 20, _x + 10, _y - 16, false);
    } else {
        draw_set_color(_special ? make_color_rgb(255, 210, 120) : c_yellow);
        draw_rectangle(_x - 4, _y - 30, _x + 4, _y - 20, false);
    }
} else {
    draw_set_color(make_color_rgb(95, 60, 30));
    draw_rectangle(_x - 24, _y - 30, _x + 24, _y - 2, false);
    draw_set_color(make_color_rgb(60, 40, 20));
    draw_rectangle(_x - 24, _y - 52, _x + 24, _y - 44, false);
}

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
