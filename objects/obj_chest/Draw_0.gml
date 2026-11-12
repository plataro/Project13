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
    draw_set_color(make_color_rgb(150, 95, 40));
    draw_rectangle(_x - 24, _y - 34, _x + 24, _y - 2, false);
    draw_set_color(make_color_rgb(110, 65, 25));
    draw_rectangle(_x - 24, _y - 42, _x + 24, _y - 30, false);
    draw_set_color(c_yellow);
    draw_rectangle(_x - 4, _y - 30, _x + 4, _y - 20, false);
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
