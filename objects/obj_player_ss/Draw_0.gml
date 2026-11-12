var _a = (respawn_timer > 0 && (respawn_timer mod 8 < 4)) ? 0.35 : 1;
draw_sprite_ext(sprite_index, image_index, round(x), round(y), face * sc, sc, 0, c_white, _a);

// ★ เอฟเฟกต์ฟันดาบ (โค้งครึ่งวงหน้าตัว)
if (atk_t > 0 && atk_t <= 13) {
    var _k = clamp(1 - (atk_t - 3) / 10, 0, 1);
    var _cx = x + face * 10;
    var _cy = y - 44;
    var _head = (face > 0) ? (80 - 150 * _k) : (100 + 150 * _k);
    draw_primitive_begin(pr_trianglestrip);
    for (var _i = 0; _i <= 8; _i++) {
        var _aa = _head + face * 70 * (_i / 8);
        var _al = (1 - _i / 8) * 0.8 * min(1, atk_t / 4);
        draw_vertex_color(_cx + lengthdir_x(70, _aa), _cy + lengthdir_y(70, _aa), c_white, _al);
        draw_vertex_color(_cx + lengthdir_x(36, _aa), _cy + lengthdir_y(36, _aa), c_white, 0);
    }
    draw_primitive_end();
}

// กด F1 ค้างเพื่อดูกล่องชน
if (keyboard_check(vk_f1)) {
    draw_set_color(c_lime);
    draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);
	draw_text(bbox_left, bbox_top - 40, "grounded=" + string(grounded) + " vsp=" + string(vsp) + " hsp=" + string(hsp));
    draw_set_color(c_white);
}